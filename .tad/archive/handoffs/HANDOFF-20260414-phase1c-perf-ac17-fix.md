---
task_type: code
e2e_required: no
research_required: no
---

# Handoff: Phase 1c — Perf Hardening + AC17 fail-OPEN Fix

**From:** Alex | **To:** Blake | **Date:** 2026-04-14
**Epic:** EPIC-20260413-symmetric-quality-enforcement.md (Phase 1c/5)
**Process Depth:** Light TAD (Spike, 4-6h budget)
**Priority:** P0 (blocks Phase 3 production implementation)

---

## 1. Executive Summary

Phase 1b 交付 PARTIAL ACCEPT，留下 2 个 must-fix 缺口：
1. **AC17 missing_dep fail-OPEN**（真安全洞）— jq 缺失时 hook 静默放行，fleet 任何没装 jq 的机器上 enforcement 直接失效。
2. **Perf PARTIAL** — p95 104-114ms 超阈值 4-14ms，但 N=30 过小，无法区分噪声 vs 真回归。

Phase 1c 目标：**用 N=100 单轮重测明确 perf 结论**；**用硬 jq 依赖 guard 修复 AC17**；**补齐 timeout fail-closed 触发验证**；**仅在 perf 真超阈值时优化 evidence-validator 热路径**。完成后产出 GO / NO-GO，Phase 3 方可启动。

---

## 2. Scope & Decisions (from Alex Socratic Inquiry)

| # | Decision | Choice | Rationale |
|---|----------|--------|-----------|
| 1 | AC17 fix 策略 | 硬 deny + 明确错误 | `command -v jq \|\| (printf deny-JSON; exit 2)`。最严格，对称 Epic 原则。Guard 在 hook 入口即跑，早于任何 payload 处理。 |
| 2 | Perf 样本规模 | N=100 单轮，p95<100ms 通过 | 1b 的 N=30 太小易受单次 GC/IO 扰动；N=100 给出 CLT 下置信区间 ~±10%。4 个 hook 各测，全部须 PASS。 |
| 3 | Validator 优化触发 | 仅在 p95≥100ms 时优化 | 先测后判。噪声 → 结案；真回归 → awk 单进程化 + keyword cache。避免猜测式优化。 |
| 4 | Timeout 触发 | 只加 timeout 一个 | 1b 已覆盖 4/5 fail-closed 向量，仅缺 timeout。不扩大到系统性全扫。 |

---

## 3. Deliverables

### 3.1 Spike 目录
`.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/`

### 3.2 修复后的 hook 文件（从 1b hardened-*.sh 拷贝为起点，1b 证据保持不动）
- `hooks-v2/hardened-pretool-interceptor.sh` — 加 jq dependency guard at top
- `hooks-v2/hardened-override-detector.sh` — 同上
- `hooks-v2/hardened-evidence-validator.sh` — 同上 + 可选热路径优化
- `hooks-v2/hardened-bash-watcher.sh` — 同上
- `hooks-v2/lib/dep-guard.sh` — 新文件，共享 guard 函数

### 3.3 测试与结果
- `test-ac17-missing-jq.sh` — AC17 回归脚本（隔离 PATH 验证 jq 缺失时硬 deny + JSON 完整性）
- `test-exit-code-contract.sh` — 经验验证 exit 0 + stdout deny JSON 在 Claude Code 2.1.92+ 下真的阻断 Write
- `test-timeout-trigger.sh` — Scenario A (慢 stdin) + Scenario B (大 payload) 两个 fail-closed 场景
- `bench-n100.sh` — N=100 单轮性能重测
- `verify-apples-to-apples.sh` — diff hooks-v2/ vs Phase 1b 目录，确认只差 dep-guard 行
- `test-fixtures/pretool-write.json` — pretool-interceptor 热路径 fixture
- `test-fixtures/override-env.json` — override-detector 热路径 fixture
- `test-fixtures/validator-handoff.json` — evidence-validator 热路径 fixture
- `test-fixtures/bash-rm.json` — bash-watcher 热路径 fixture
- `results/ac17-retest.tsv` — missing_dep 从 FAIL → PASS 证据
- `results/exit-code-contract.tsv` — exit 0 契约经验验证
- `results/apples-to-apples.txt` — diff 输出（应为空或只含 dep-guard 行）
- `results/bench-n100.tsv` — 原始 400 样本 + `results/stats-summary.tsv`
- `results/timeout-trigger.tsv` — 两 scenario 的 timeout fail-closed 结果
- `results/optimization-delta.tsv`（条件产物）— 仅当触发优化时产出

### 3.4 报告
- `SPIKE-REPORT.md` — 结论 GO / NO-GO，含 AC 逐条对照
- `COMPLETION-REPORT.md` — Gate 3 attestation（强制产物）

---

## 4. Implementation Details

### 4.1 AC17 Fix — Dependency Guard 实现

**位置**：所有 hook 脚本文件顶部（在 `set -euo pipefail` 之后，任何 stdin/payload 读取之前）。

**共享函数** `lib/dep-guard.sh`：
```bash
#!/bin/bash
# Hard-deny if required dependencies missing.
# Must be sourced BEFORE any payload processing.
# SECURITY: Pin PATH to eliminate attacker-controlled PATH influence on command -v.
export PATH=/usr/bin:/bin:/usr/local/bin

# SECURITY: require_dep's $1 MUST be a hardcoded literal (grep-checkable).
# Never call require_dep with a variable — future contributors must add new literal calls instead.
# Belt-and-suspenders: whitelist regex enforces this contract at runtime.
require_dep() {
  local dep="$1"
  if ! [[ "$dep" =~ ^[a-z0-9_-]+$ ]]; then
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"TAD enforcement error: invalid dep name passed to require_dep. Contact TAD maintainer."}}'
    exit 0
  fi
  if ! command -v "$dep" >/dev/null 2>&1; then
    # Cannot use jq here (it may be the missing dep). Emit hardcoded deny.
    # Exit 0 + stdout deny JSON is the validated Claude Code permission-gate contract
    # (Epic 1 Phase 2a proved this; exit != 0 may be treated as hook error → fail-OPEN).
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"TAD enforcement requires dependency (missing). Install jq/awk or use TAD_OVERRIDE in next prompt."}}'
    exit 0
  fi
}
```

**每个 hook 顶部按需声明自己的 deps**（不在 dep-guard.sh 里预先调用 —— 避免 over-broad denial surface）：
```bash
# pretool-interceptor.sh, override-detector.sh, bash-watcher.sh:
source "${BASH_SOURCE[0]%/*}/lib/dep-guard.sh"   # symlink-safe, not $0
require_dep jq

# evidence-validator.sh (uses both):
source "${BASH_SOURCE[0]%/*}/lib/dep-guard.sh"
require_dep jq
require_dep awk
```

**关键设计点**：
- 不依赖 jq 生成 deny JSON（jq 自己可能就是缺失的那个）—— 用 printf hardcode
- **exit 0 + stdout deny JSON**（而非 exit 2）—— 经 Epic 1 Phase 2a 验证为 Claude Code permission-gate 契约；exit != 0 可能被当作 hook error 导致 fail-OPEN，正是要修的那个 bug
- deny JSON 里**不插入 $dep 变量**—— 消息体完全硬编码，杜绝 JSON injection 风险（即便 $dep 是 literal，pattern 本身不安全就是坏样板）
- PATH 固定在 guard 入口 —— 消除 TOCTOU 攻击面
- `${BASH_SOURCE[0]%/*}` 替代 `$(dirname "$0")` —— 处理 symlink 和非 CWD 调用
- Per-hook dep 声明 —— bash-watcher/override-detector 只要 jq，不白白要求 awk

**Override-when-jq-missing 的决策**：接受此 edge case 损失。用户场景：jq 缺失时，即使输入 TAD_OVERRIDE 也会被 guard 硬拦。理由：(a) jq 缺失是系统配置 bug，不是常规工作状态；(b) override 本意是紧急人类豁免，紧急情况下 `brew install jq`（或换机器）比给 override 做特殊 grep-fallback 更安全；(c) 任何 pre-jq override 解析路径都是新攻击面。用户看到 deny 消息就知道该装 jq。

### 4.2 Perf 重测 — bench-n100.sh

```bash
#!/bin/bash
# N=100 single-run latency benchmark. Clean measurement (no per-step instrumentation).
# Each hook gets its OWN hot-path fixture so measurements reflect real dispatch cost,
# not early-exit on non-matching event.
# Writes TSV: hook_name, sample_idx, latency_ms

set -euo pipefail
set -o noclobber
cd "$(dirname "$0")"

OUT="results/bench-n100.tsv"
mkdir -p results
[[ -f "$OUT" ]] && mv "$OUT" "${OUT}.bak.$(date +%s)"
printf 'hook\tsample\tlatency_ms\n' > "$OUT"

# Per-hook hot-path fixture (see §3.3 for fixture contents):
declare -A FIXTURE=(
  [pretool-interceptor]=test-fixtures/pretool-write.json
  [override-detector]=test-fixtures/override-env.json
  [evidence-validator]=test-fixtures/validator-handoff.json
  [bash-watcher]=test-fixtures/bash-rm.json
)

for hook in pretool-interceptor override-detector evidence-validator bash-watcher; do
  fixture="${FIXTURE[$hook]}"
  for i in $(seq 1 100); do
    # Two perl spawns per sample add ~14ms overhead. Document in SPIKE-REPORT.md.
    start=$(perl -MTime::HiRes=time -e 'printf "%.6f\n", time')
    bash "hooks-v2/hardened-${hook}.sh" < "$fixture" > /dev/null 2>&1 || true
    end=$(perl -MTime::HiRes=time -e 'printf "%.6f\n", time')
    latency_ms=$(perl -e "printf \"%.2f\n\", ($end - $start) * 1000")
    printf '%s\t%d\t%s\n' "$hook" "$i" "$latency_ms" >> "$OUT"
  done
done

# Compute p50, p95, p99 per hook — BSD-awk + external sort pattern (no asort needed)
echo "" > results/stats-summary.tsv
printf 'hook\tp50\tp95\tp99\tn\n' > results/stats-summary.tsv
for hook in pretool-interceptor override-detector evidence-validator bash-watcher; do
  awk -F'\t' -v h="$hook" 'NR>1 && $1==h {print $3}' "$OUT" | sort -g | \
    awk -v h="$hook" 'BEGIN{c=0} {a[++c]=$1} END{
      if (c==0) exit 1
      p50=a[int(c*0.5)]
      p95=a[int(c*0.95)]
      p99=a[int(c*0.99)]
      printf "%s\t%.2f\t%.2f\t%.2f\t%d\n", h, p50, p95, p99, c
    }' >> results/stats-summary.tsv
done
cat results/stats-summary.tsv
```

**Perl timer overhead 处理**：两次 perl spawn 给每个样本加 ~14ms（实测）。SPIKE-REPORT.md 必须明确标注 "raw latency includes ~14ms timer overhead; Phase 1a clean baseline was 37ms median, so for apples-to-apples comparison subtract ~14ms from raw numbers"。p95<100ms 阈值用 raw 数字判（因为生产环境也有 fork 开销，只是 hook 本身不含 timer — perl overhead 是测量开销，向保守方向倾斜）。

**Pass/Fail 判定**（imperative — per AC Precision knowledge entry）：
- **All 4 hooks must have p95 < 100ms** (strict, blocking)
- At least 3 of 4 hooks must have median < 50ms (**non-blocking sanity metric**, logged not gating)

**若 N=100 显示 p95 ≥100ms**：触发 §4.4 优化路径。

### 4.3 Timeout Fail-Closed 测试

Hook 必须在 payload 处理死循环或卡住时**自己**超时并 fail-closed（deny）。**不延后到 Phase 3**—— spike 必须当场证明 fail-closed 成立。

**实现方式**：在每个 hook 的 stdin read 路径外层包一个 `read -t 2`（2 秒读不到数据就 timeout），timeout 触发时 hook 自己 emit deny JSON 并退出。不依赖外层 `timeout` wrapper。

```bash
# test-timeout-trigger.sh — 两个具体场景都要通过
set -euo pipefail

# Scenario A: 慢 stdin（payload 来源卡住，模拟管道死锁）
# hanging-payload.json 不是有 ReDoS 的 JSON；是 FIFO 模拟：开一个不写完的管道
mkfifo /tmp/tad-slow-fifo.$$
(sleep 10 > /tmp/tad-slow-fifo.$$) &
writer_pid=$!
start=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')
output=$(bash hooks-v2/hardened-evidence-validator.sh < /tmp/tad-slow-fifo.$$ 2>&1 || true)
end=$(perl -MTime::HiRes=time -e 'printf "%.3f\n", time')
elapsed=$(perl -e "printf \"%.3f\n\", $end - $start")
kill $writer_pid 2>/dev/null || true
rm -f /tmp/tad-slow-fifo.$$

# Expected:
#   elapsed < 3s (hook self-aborts, doesn't wait for writer)
#   output contains '"permissionDecision":"deny"'
#   output is valid JSON (jq -e . passes)

# Scenario B: 大 payload 导致 awk 热路径慢
# Use a 10MB synthetic payload with pathological keyword density
# Hook must abort with deny if processing > 2s

printf '%s\t%s\t%s\n' A "$elapsed" "$output" >> results/timeout-trigger.tsv
```

**Pass criteria (strict, all must PASS)**：
- Scenario A: elapsed < 3s AND output 包含 `"permissionDecision":"deny"` AND output 是 valid JSON（`jq -e . <<<"$output"` 退出 0）
- Scenario B: 同样的 deny + JSON 完整性要求，elapsed < 3s

**Failure mode to detect**: 如果 hook 等 stdin 等到被外层 `timeout` 干掉（exit 124）—— 视为 FAIL，因为生产环境 Claude Code 不保证用 timeout wrapper 调用 hook。必须自己超时。

### 4.4 Optional Validator Optimization (Conditional)

**Trigger**：仅当 §4.2 N=100 结果显示 evidence-validator p95 ≥100ms。

**Approach**（按序尝试，测一个停一个）：
1. **Single-awk pattern** — 合并多次 grep/jq 调用为单次 awk 处理（参考 architecture.md "Hook Performance: Single-awk" 条目）
2. **Keyword list caching** — 如果每次调用都重新解析 YAML，改为 session-start 时预解析并缓存到 `.tad/evidence/cache/keyword-map.tsv`
3. **ENVIRON variable passing** — 用户消息经 `ENVIRON["MSG"]` 传 awk，而非 `-v`（避开 `\n`/`\t` 转义陷阱）

**Stop condition**：p95 降到 <100ms 即停，不过度优化。

**Data integrity guardrails**（来自 architecture.md "Hook Data Integrity"）：
- 不用 `\x00` 作 bash `$()` 分隔符（被 shell 吞）；用 `\x1E` (ASCII RS)
- jq 多字段拼接用 `join("\u001e")` 不用 `@tsv`（@tsv 会转义 content 里的 \t）

---

## 5. Files to Create / Modify

**NEW**:
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/hooks-v2/*.sh` (5 files)
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/hooks-v2/lib/dep-guard.sh`
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/test-*.sh` (2 files)
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/bench-n100.sh`
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/results/*.tsv` (3-4 files)
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/SPIKE-REPORT.md`
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/COMPLETION-REPORT.md`
- `.tad/evidence/spikes/SPIKE-20260414-phase1c-ac17-perf-fix/test-fixtures/` (copy from 1b + add `hanging-payload.json`)

**DO NOT MODIFY**:
- Phase 1b spike dir `.tad/evidence/spikes/SPIKE-20260414-quality-enforcement-adversarial/` — 保持 provenance 不动
- 生产 hook 目录 `.tad/hooks/` — Phase 3 才部署

---

## 6. Acceptance Criteria (Strict List-based, per AC Precision entry)

All of AC1-AC14 must PASS (no "N/M PASS" aggregate allowed):

- [ ] **AC1**: `lib/dep-guard.sh` 存在，包含 `require_dep` 函数 + PATH pinning + 白名单 regex `^[a-z0-9_-]+$` + SECURITY 注释
- [ ] **AC2**: 4 个 hardened-*.sh 均 source dep-guard.sh via `${BASH_SOURCE[0]%/*}` (symlink-safe)，且每个 hook 按自己实际所需 `require_dep` (grep 验证：bash-watcher / override-detector / pretool-interceptor 有 `require_dep jq`；evidence-validator 另有 `require_dep awk`)
- [ ] **AC3**: `test-ac17-missing-jq.sh` 运行后 `results/ac17-retest.tsv` 显示 missing_dep PASS（PATH 隔离下 deny 触发，exit 0，stdout 含 hardcoded deny JSON，消息体**不含任何 $dep 变量内插**）
- [ ] **AC4**: AC17 deny 输出通过 JSON 完整性验证 —— `jq -e . <<<"$output"` 退出 0（证明不是乱码或断 JSON）
- [ ] **AC5**: `bench-n100.sh` 完成，`results/bench-n100.tsv` 含 400 行（4 hooks × 100 samples），且每个 hook 使用 §3.3 对应的**热路径 fixture**（不是共享的 standard-payload.json）
- [ ] **AC6**: 4 个 hook 的 p95 均 < 100ms（直接从 `results/stats-summary.tsv` 读出并记录在 SPIKE-REPORT.md；raw 数字 + 减去 ~14ms perl timer overhead 的调整后数字都记录）— **blocking**
- [ ] **AC7**: 4 个 hook 中至少 3 个 median < 50ms — **non-blocking sanity metric**，仅记录不阻断
- [ ] **AC8**: `test-timeout-trigger.sh` 的 Scenario A 和 Scenario B **都** PASS：elapsed < 3s AND output 含 `permissionDecision":"deny"` AND output 通过 `jq -e .` 验证 —— 证明 hook **自己** fail-closed，不依赖外层 timeout wrapper
- [ ] **AC9**: `test-exit-code-contract.sh` 经验证明：在 Claude Code 2.1.92+ 实际运行环境下，`exit 0 + stdout deny JSON` 真的阻断 Write 工具调用 —— `results/exit-code-contract.tsv` 含 session ID + verdict（若此 AC FAIL 则整个 §4.1 设计回炉）
- [ ] **AC10**: SPIKE-REPORT.md 含 Overall: GO 或 NO-GO 明确判定，含每项 AC 逐条 PASS/FAIL 表（PASS 计数不允许替代逐条列表）
- [ ] **AC11**: COMPLETION-REPORT.md 存在（强制产物，per Alex Handoff AC 教训），含 Evidence Checklist 全项勾选 + Gate 3 attestation + 明确的 "New discovery recorded: {path} → '{title}'" 或 "No new discoveries" 声明
- [ ] **AC12**: `verify-apples-to-apples.sh` 确认 hooks-v2/hardened-*.sh 与 1b hardened-*.sh 的 diff **只有** dep-guard source 行和 require_dep 调用行，其他内容字节一致 —— `results/apples-to-apples.txt` 为此 diff 的完整输出，Alex Gate 4 会 cat 这个文件逐行核对
- [ ] **AC13**: 源码含反模式 CI guard —— 新增 `grep -rn 'require_dep "\$' hooks-v2/` 必须返回空（catches variable-based call pattern before it ships）
- [ ] **AC14**: Blake's completion message to Alex 含从 `results/stats-summary.tsv` 抽出的 p95 数字原文（允许 Alex *accept 阶段从 raw TSV 重算对齐，per Gate 4 Verification Integrity 教训）

**Conditional AC (仅 AC6 FAIL 即 p95≥100ms 时触发)**：
- [ ] **AC15**: `results/optimization-delta.tsv` 显示 before/after p95 对比，**before 来自本 spike 的 N=100 基线**（不是 Phase 1b N=30 数字），after < 100ms；COMPLETION-REPORT.md 明确说明采用了哪条优化路径（awk 单进程化 / keyword cache / ENVIRON 传参）

---

## 7. Expert Review Status

| Reviewer | Verdict | P0 Count | Integrated |
|----------|---------|----------|------------|
| code-reviewer | CONDITIONAL PASS | 5 | ✅ All 5 fixed in v2 |
| security-auditor | CONDITIONAL PASS | 2 | ✅ Both fixed + 2 critical P1 adopted |

### P0 Resolution Map

| # | Source | Issue | Resolution |
|---|--------|-------|-----------|
| P0-1 | code | bench awk stats block truncated with `...` | §4.2 now includes full sort-based p50/p95/p99 pipeline inline |
| P0-2 | code+sec | printf `$dep` interpolation unsafe-by-construction | Message body fully hardcoded (no `$dep` inside JSON); whitelist regex `^[a-z0-9_-]+$`; SECURITY comment; AC13 grep guard |
| P0-3 | code | AC8 "verify wrapper in Phase 3" escape hatch | §4.3 rewritten — hook MUST self-abort (Scenario A + B); no Phase 3 deferral |
| P0-4 | code | Missing apples-to-apples diff AC | New AC12 + `verify-apples-to-apples.sh` + `results/apples-to-apples.txt` |
| P0-5 | code | Single fixture for 4 hooks → early-exit invalidates p95 | 4 distinct hot-path fixtures (§3.3); AC5 requires per-hook fixture |
| P0-6 | sec | `exit 2` semantics unverified → possible fail-OPEN | Switched to **exit 0 + stdout deny** (Phase 2a validated contract); AC9 empirically re-verifies in current CC version |
| P0-7 | sec | JSON injection durability gap | Same fix as P0-2 |

### P1 Adopted

- **sec-P1-1 PATH pinning** (high-leverage, eliminates TOCTOU class) — `export PATH=/usr/bin:/bin:/usr/local/bin` at top of dep-guard.sh
- **sec-P1-3 Per-hook deps** (avoid over-broad denial surface) — require_dep calls moved from dep-guard.sh into each hook; each hook declares only its actual deps

### P1 Documented-Decision

- **sec-P1-2 Override-when-jq-missing** — accepted loss (§4.1 final paragraph). Install jq as remediation path; no grep-fallback override (new attack surface not worth it).

⚠️ **本 handoff 不豁免专家审查**（per "Express Handoff is NOT Review-Exemption" 教训）。已完成 2 experts 并行审查 + 所有 P0 整合。

---

## 8. 📚 Project Knowledge (Blake 必读)

Blake 必须在开始实现前 Re-read 以下 knowledge 条目（均来自 `.tad/project-knowledge/architecture.md`）：

| 条目 | 为何相关 |
|------|---------|
| Hook Latency Measurement: Never Use python3 for Per-Step Timing on macOS — 2026-04-14 | bench-n100.sh 使用 perl -MTime::HiRes，禁用 python3 做 per-sample timer |
| Hook Performance: Single-awk vs Per-item grep Loop — 2026-04-07 | §4.4 优化路径的首选 pattern |
| Hook Data Integrity: bash $() Strips \x00; jq @tsv Escapes Content Tabs — 2026-04-14 | §4.4 优化如涉及多字段 awk 处理时必须遵守的数据完整性约束 |
| AC Precision: "≥N Triggers" vs "Specific List of N" — 2026-04-14 | §6 AC 措辞严格使用 "All of X must PASS"，不用聚合计数 |
| Alex Handoff AC Must Explicitly List ALL Required Evidence Files — 2026-04-14 | COMPLETION-REPORT.md 已显式入 AC10，不可遗漏 |
| Gate 4 Verification Integrity — 2026-04-14 | Blake 的 completion message 必须允许 Alex 从 raw TSV 重新计算 p95，不只报告数字 |
| Hook Shell Portability: No grep -P on macOS — 2026-04-03 | 所有脚本必须 BSD-grep 兼容 |

---

## 9. Blake Execution Notes

- Light TAD spike，**预算 4-6h**。若超时 → 立即停并上报，不无限 Ralph Loop。
- Ralph Loop Layer 1 自检 + Layer 2 专家审查（code-reviewer 必选；security-auditor 选看 AC17 fix 的 guard 设计）
- Gate 3 v2 by Blake, Gate 4 v2 by Alex (acceptance 时会从 raw TSV 重新算 p95 对齐报告数字)
- 若 AC11 被触发（perf 真超阈值），在 COMPLETION-REPORT.md 明确说明触发原因 + 采用哪个优化手段 + before/after 对比

---

## 10. Important Notes

- Phase 2 Enforcement Matrix 设计并行进行中 — 但 Blake 只做 1c，不碰 Phase 2/3 任何产物
- Phase 3 生产 hook 部署 BLOCKED on 1c GO — 1c NO-GO 则回 Epic 重新设计
- 1b hardened hooks 目录 **只读**，Phase 1c 新建 `hooks-v2/` 作为 delta
