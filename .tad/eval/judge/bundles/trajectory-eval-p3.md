
# HANDOFF: trajectory-eval-p3

---
# Quality Chain Metadata (Alex 必填)
task_type: mixed      # 协议文件编辑 + bash 脚本 + 实跑验证
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/eval"]
skip_knowledge_assessment: no
gate4_delta: []
---

---

## §9.1 Spec Compliance Checklist (excerpt)
## 9.1 Spec Compliance Checklist ⚠️ PRIMARY VERIFICATION SOURCE

---

## §6 Implementation Steps (head)
## 6. Implementation Steps

## 6.1 Micro-Tasks

| # | File | Operation | Verification | Est. |
|---|------|-----------|--------------|------|
| 1 | assemble-bundle.sh | active-first 查找（最小 diff） | AC4 sep-phase2 回归 byte-diff 空 + AC11 active 路径实跑 | 15m |
| 2 | step4d-run.sh | prepare/finalize 两子命令（4.2A 契约） | AC7 降级 + AC11 active | 30m |
| 3 | acceptance-protocol.md (.claude) | 新增 step4d 块 | AC1 scoped greps + AC3 line-set | 30m |
| 4 | acceptance-protocol.md (.agents) | byte 同步 | `diff -q` 空 | 5m |
| 5 | gate-roi-report.sh | 按 4.2C **五节**实现 | AC5 实跑（率 + lower bound + 五节） | 75m |
| 6 | 实跑 E2E | 对 trajectory-eval-p2（archived）跑 prepare→spawn→finalize 全流程 | AC6 json 合法 | 20m |
| 7 | 降级测试 | 移开 judge-prompt.md → `prepare` exit 0 + skip 行 → 恢复（test -f 确认） | AC7 | 10m |

### 判断点
micro-1 回归 diff 非空 → 停，回 Alex（格式漂移 = 校准失真风险，不许"看起来差不多"）。

## 6.7 AC Dry-Run Log
**AC Dry-Run Log** (Alex step1d at 2026-07-02):
- AC3 基线 (pre-impl): `grep -cE 'BLOCKING|MANDATORY|VIOLATION' .claude/skills/alex/references/acceptance-protocol.md` → **5**（实测）；AC3 要求 post ≥5 且 line-set forward-missing = 0
- AC2 基线 (pre-impl): `diff -q` 两镜像 → identical（实测）
- AC8 基线 (pre-impl): `grep -rl 'eval/rubric' CLAUDE.md .claude/skills .agents/skills | wc -l` → **0**（实测）
- `date -v-30d` → 2026-06-02（BSD 可用，实测）
- ROI 数据源体量 (pre-impl 实测): gate_result 50 条 / bugfix 前缀 6 / 非空 gate4_delta 7 —— AC5 的"非空输出"可满足
- AC1/AC4-AC7/AC9-AC10 (post-impl): raw form `bash -n` 语法验证通过；不 mock
- AC3 时序漏洞自查修正 (2026-07-02): `git show HEAD:` 会随 Blake 提交移动 → 基线钉死为 commit `3a9c82e`；钉死后命令对当前未修改文件 LIVE 实跑 = 0 ✓
- AC9 LIVE 实跑（当前状态）= 0 ✓（基线已钉死 `git diff 3a9c82e`）
- 专家审查后第二轮 (2026-07-02)：修订版 AC1/AC5/AC7/AC11 raw form `bash -n` 通过；AC1 awk 端模式与起始模式不互斥实测 ✓；advisory linter 1 WARN（AC3 表格转义，raw form 已实跑 0）+ 1 INFO（'judge: skipped' sentinel——AC7 断言输出存在而非文件零出现，self-leak 反转不适用）

---

## 7. File Structure

---

## §9.2 Expert Review Audit Trail
（§9.2 Audit Trail 行数从第 2 节移除——衡量协议活动量不衡量发现数，代理无效 [DA P2-2]）
每节末尾附"复算命令"一行（Gate 4 一键 re-derive）。
硬约束：只读脚本（除自身报告外零副作用）；BSD-safe（**用 `find` 不用 `**` globstar** [CR P1]）；数据源缺失 → 该节 N/A 不崩溃。

### 4.3 Data Models
trajectory-judge.json：沿用 Phase 2 schema。ROI 报告：markdown + 每节复算命令行。

### 4.4 度量口径
已在 4.2C 各节原地定义（不引用继承）。gate4_delta 归入"Caught pre-ship（Gate 4 晚期拦截）"而非 escape——它是 Gate 4 抓到的差距，归 escape 属语义倒置（DA P0-1）。escape 只计 bugfix 前驱（行为性证据），且必须带分母/率 + lower-bound 免责声明。

### 4.5 UI / API
N/A

---

## 5. 🆕 强制问题回答
## 9.2 Expert Review Status (Alex 必填)
### Audit Trail
| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0: active-first 路径（FR2 的存在目的）零 AC 覆盖——AC4/AC6 全走 archive 回落；叠加全路径静默降级 = 坏掉也永久无声 no-op | AC11 新增（active slug 实测）+ §6 micro-1/2 | Resolved |
| code-reviewer | P1: step4d 是协议 prose 不可测（AC7 无 exit code 可断言） | §4.2A（抽出 step4d-run.sh prepare/finalize）+ AC7 重写为脚本测试 | Resolved |
| code-reviewer | P1: AC1 `blocking: false` 全文件 grep vacuous（已有 4 处） | AC1 改 awk 块内 scoped grep（端模式与起始模式不互斥已核对） | Resolved |
| code-reviewer | P1: reviews 路径无日期 → 窗口过滤未定义；`**` globstar BSD 不可用 | §4.2C 第 2 节（slug 关联到带日期 handoff 文件名；强制 find） | Resolved |
| code-reviewer | P2: AC3 对纯重排不敏感；trace 窗口方法未指明；active bundle 代表性 | 接受（additive-only 下重排不构成风险，已注明）；§4.2C 第 1 节（按 ts 字段过滤）；§10.2 注明 | Resolved |
| data-analyst | P0-1: gate4_delta 归入 escape 属语义倒置——会使 enforcement 决策高估漏出率 | §4.2C 第 2 节（移为"Gate 4 晚期拦截"）+ §4.4 更新 | Resolved |
| data-analyst | P0-2: 无分母/率——原始计数对战略决策不可解读 | §4.2C 第 3 节（分子/分母/百分比强制）+ AC5 率行 grep | Resolved |
| data-analyst | P1-1: per-file-per-level 去重压缩发现数、方向性低估 gate 价值 | §4.2C 第 2 节（finding-level `P[01]-[0-9]+` 去重 + 无编号回落单列 + lower bound 脚注） | Resolved |
| data-analyst | P1-2: 静默修复不可见 → escape 是下界 | §4.2C 第 3 节 + AC5（"lower bound" 免责声明强制） | Resolved |
| data-analyst | P1-3: n=3-10 逐维均值是虚假精度 | §4.2C 第 4 节（n<10 逐轨迹行，n≥10 均值表） | Resolved |
| data-analyst | P2-1: enforcement 决策需要"哪道门拦最多" | §4.2C 新增第 5 节（gate × verdict 交叉表） | Resolved |
| data-analyst | P2-2: §9.2 Audit Trail 行数是无效代理 | §4.2C 第 2 节已移除该项 | Resolved |
| (Alex step1d 自查) | AC3/AC9 `git show HEAD:` 随 Blake 提交移动 → 永假 PASS | AC3/AC9 基线钉死 commit 3a9c82e | Resolved |

### Experts Selected
1. **code-reviewer** — 协议文件 SAFETY line-set 纪律 + additive sibling 正确性 + shell 脚本边界（本任务最大风险面是改 Alex 自己的验收协议）
2. **data-analyst** — ROI 四节指标口径（escape 双口径、去重规则、空窗口行为）的测量有效性

### Overall Assessment (post-integration)
- code-reviewer: CONDITIONAL PASS → 1 P0 + 3 P1 + 3 P2 全部 Resolved

---


# COMPLETION: trajectory-eval-p3

---
gate3_verdict: pass
---

# Completion Report: trajectory-eval-p3
## TAD v3.1 - Evidence-Based Development

**Task ID:** TASK-20260702-003
**Handoff:** HANDOFF-20260702-trajectory-eval-p3.md
**Epic:** EPIC-20260701-trajectory-eval-harness.md (Phase 3/3 — FINAL)
**Completed By:** Blake (Agent B)
**Date:** 2026-07-02
**Git Commit:** 7b8ba01

---

## Executive Summary

Delivered the final phase of the Trajectory Eval Harness Epic: (1) `step4d_trajectory_judge` additive sibling in acceptance-protocol.md — advisory auto-run judge evaluation at every *accept; (2) `step4d-run.sh` prepare/finalize wrapper with triple skip-check graceful degradation; (3) `gate-roi-report.sh` 5-section ROI report with escape rate/lower-bound/per-gate attribution; (4) `assemble-bundle.sh` active-first path resolution. E2E validated on trajectory-eval-p2 (judge scores: D1=4 D2=3 D3=4 D4=5 D5=4). Three freeze constraints verified clean.

---

## Deliverables

| # | Deliverable | Status | Evidence |
|---|-------------|--------|----------|
| 1 | assemble-bundle.sh active-first | ✅ DONE | AC4 sep-phase2 byte-diff empty |
| 2 | step4d-run.sh prepare/finalize | ✅ DONE | AC7 degradation + AC11 active path |
| 3 | acceptance-protocol.md step4d block | ✅ DONE | AC1 scoped grep 6/6 + AC3 line-set 0 |
| 4 | acceptance-protocol.md .agents mirror | ✅ DONE | AC2 diff -q SAME |
| 5 | gate-roi-report.sh (5 sections) | ✅ DONE | AC5 all checks pass |
| 6 | E2E judge evaluation | ✅ DONE | AC6 jq VALID |
| 7 | Degradation test | ✅ DONE | AC7 judge: skipped + exit=0 |

---

## §9.1 Results

| AC | Expected | Actual | Status |
|----|----------|--------|--------|
| AC1 | block ≥20 lines + 6 markers ≥1 | 41 lines, all 6 markers present | ✅ |
| AC2 | SAME | SAME | ✅ |
| AC3 | forward-missing=0, markers ≥5 | 0, 5 | ✅ |
| AC4 | SAME (byte-diff empty) | SAME | ✅ |
| AC5 | exit=0, sections≥5, rate≥1, lb≥2, 复算≥5 | 0, 5, 1, 3, 5 | ✅ |
| AC6 | VALID | VALID | ✅ |
| AC7 | judge: skipped + exit=0 + RESTORED | all three met | ✅ |
| AC8 | 0 | 0 | ✅ |
| AC9 | 0 | 0 | ✅ |
| AC10 | 0 out-of-scope files | 0 | ✅ |
| AC11 | ACTIVE_OK | ACTIVE_OK | ✅ |

---

## Layer 2 Expert Review

| Reviewer | Verdict | Key Findings | Evidence |
|----------|---------|-------------|----------|
| code-reviewer | PASS (after P1 fix) | P1-1: grep -H flag (fixed); P1-2: UNRECOVERABLE filter (fixed) | .tad/evidence/reviews/blake/trajectory-eval-p3/code-reviewer.md |
| spec-compliance | PASS (10/10 SATISFIED) | All ACs verified with live commands | .tad/evidence/reviews/blake/trajectory-eval-p3/spec-compliance.md |

---

## Implementation Decisions

| # | Decision | Context | Chosen | Escalated? | Human Approved? |
|---|----------|---------|--------|------------|-----------------|
| 1 | `|| true` on ls glob pipelines | `set -euo pipefail` + `ls glob` fails when no match; must not exit | Added `\|\| true` to all ls glob assignments | No | Default |
| 2 | `while IFS= read -r` instead of `for in $(find)` | Project path has spaces ("01-on progress programs") | Used `while ... done < <(find ...)` throughout gate-roi-report.sh | No | Default |
| 3 | `grep -H` for filename prefix | Code reviewer P1-1: single-file grep omits prefix | Added `-H` flag | No | Default |

---

## Friction Status

| Friction Point | Status | Notes |
|----------------|--------|-------|
| Sonnet spawn (E2E judge) | READY | Successful spawn, judge completed |
| BSD date -v | READY | Verified working on macOS |
| jq availability | READY | Available in PATH |

---

## Reflexion History

无 reflexion（Layer 1 AC 验证一次通过）。

两个 shell 兼容性问题在首次编写时就预见到（`|| true` 和 `while read`），未触发 Layer 1 失败。

Code reviewer P1-1/P1-2 在 Layer 2 发现，修复后 Layer 1 重跑一次通过。

---

## Evidence Checklist

- [x] Completion report (this file)
- [x] ROI script: `.tad/eval/judge/gate-roi-report.sh`
- [x] ROI report sample: `.tad/evidence/eval/gate-roi-2026-07-02.md`
- [x] E2E judge JSON: `.tad/evidence/acceptance-tests/trajectory-eval-p2/trajectory-judge.json`
- [x] Regression diff: sep-phase2 bundle byte-diff empty (AC4 verified inline)
- [x] Degradation log: judge: skipped + exit=0 + RESTORED (AC7 verified inline)
- [x] Git baseline: `.tad/evidence/designs/trajectory-eval-p3-git-baseline.txt`
- [x] Blake Layer 2 reviews: `.tad/evidence/reviews/blake/trajectory-eval-p3/*.md` (2 distinct: code-reviewer + spec-compliance)

---

## Knowledge Assessment

**是否有新发现？** ✅ Yes

**Q1 — 值得追溯的发现：**
- `set -euo pipefail` + `grep -oE ... | sort -u | wc -l` 管道：当 grep 无匹配返回 exit 1 时，pipefail 传播到变量赋值导致脚本退出。修复：`{ grep ... || true; } | sort | wc` 把 grep 包在 group command 里。这是 shell-portability 模式的新变体（之前只记录了 `grep -c` 输出 "0" + `|| echo 0` 导致双重输出的问题——这次是 pipefail 与 grep exit code 的交互）。
- `grep -c` + `|| echo 0` 双重输出陷阱：`grep -c` 找到 0 匹配时输出 "0" 且返回 exit 1，`|| echo 0` 再补一个 "0"，变量变成 "0\n0"。修复：`VAR=$(grep -c ...) || true`（不追加额外输出）。

**Q2 — 可复用工作模式？** ❌ No — 本次是直接 additive sibling 集成，无新可复用模式。

**Q3 — Workflow 模式？** ❌ No — 无多 agent 编排。

---

## ROI Report Sample Output (30-day window)

```
Gates run: 46 (Gate 3: 46 pass)
Caught pre-ship: 156 numbered + 47 unnumbered review findings; 4 gate4_delta interceptions
Escaped post-ship: 2/88 = 2.3% (lower bound)
Judge score trend: insufficient data (n=1) — accumulating
Per-gate attribution: Gate 3: 46 pass, 0 partial, 0 fail
```

---

## Sub-Agent Usage

| Agent | Purpose | Evidence |
|-------|---------|----------|
| code-reviewer | Layer 2 code review | .tad/evidence/reviews/blake/trajectory-eval-p3/code-reviewer.md |
| spec-compliance-reviewer | Layer 2 AC verification | .tad/evidence/reviews/blake/trajectory-eval-p3/spec-compliance.md |
| Sonnet judge (fresh spawn) | E2E trajectory evaluation | .tad/evidence/acceptance-tests/trajectory-eval-p2/trajectory-judge.json |

---


# REVIEW: code-reviewer.md

# Code Review: trajectory-eval-p3
Reviewer: code-reviewer (Agent subagent)
Date: 2026-07-02

## Freeze Constraint Verification
| Constraint | Status |
|---|---|
| judge-prompt.md / rubric.md ZERO changes | PASS |
| golden-set/ ZERO changes | PASS |
| acceptance-protocol.md existing lines ZERO deletion/modification | PASS — diff purely additive |
| assemble-bundle.sh bundle CONTENT format ZERO drift | PASS — AC4 byte-diff empty |

## Findings

### P1-1: grep -H flag needed for single-file case (gate-roi-report.sh line 59)
When find locates exactly one .jsonl file, grep without -H omits filename prefix. `${line#*:}` then strips into JSON content, breaking jq parsing.
**Status**: FIXED — added `-H` flag

### P1-2: UNRECOVERABLE scores coerced to 0 in Section 4 aggregation (gate-roi-report.sh lines 236-250)
awk `$i+0` coerces "UNRECOVERABLE" string to 0, polluting mean/min/max.
**Status**: FIXED — added numeric filter `if ($i ~ /^[0-9]+$/)`

### P2-1: Section 1/5 jq+awk duplication
Both sections run same pipeline. Low priority, correctness unaffected.
**Status**: ACCEPTED — report-only script

### P2-2: sed with unescaped regex metacharacter (gate-roi-report.sh line 214)
`$JUDGE_DIR` contains `.tad` where `.` is regex metachar. Practically safe since input is find output.
**Status**: ACCEPTED — low risk

### P2-3: Trap quoting style
Works correctly for mktemp paths.
**Status**: ACCEPTED

## Verdict: PASS (after P1-1 and P1-2 fixes applied)

---


# REVIEW: spec-compliance.md

# Spec Compliance Review: trajectory-eval-p3
Reviewer: spec-compliance-reviewer (Agent subagent)
Date: 2026-07-02

## Results

| AC | Description | Status | Evidence |
|----|-------------|--------|----------|
| AC1 | step4d block scoped check | SATISFIED | 41 lines, 6/6 markers ≥1 |
| AC2 | Dual-platform byte mirror | SATISFIED | diff -q → SAME |
| AC3 | SAFETY line-set (additive only) | SATISFIED | forward-missing=0, markers=5 (≥5) |
| AC4 | Assembler regression zero-drift | SATISFIED | sep-phase2 byte-diff empty |
| AC5 | ROI report (5 sections + rate + lb) | SATISFIED | exit=0, sections=5, rate=1, lb=3, 复算=5 |
| AC6 | E2E trajectory-judge.json schema | SATISFIED | jq validation → VALID |
| AC7 | Degradation path silent skip | SATISFIED | "judge: skipped" + exit=0 + RESTORED |
| AC8 | Anti-Goodhart baseline unchanged | SATISFIED | grep count = 0 |
| AC9 | Judge frozen artifacts zero-diff | SATISFIED | git diff = 0 |
| AC11 | Active-first path test | SATISFIED | ACTIVE_OK |

## Summary
NOT_SATISFIED=0, PARTIALLY_SATISFIED=0
10/10 ACs verified SATISFIED.
AC10 (change scope) deferred to Gate 3 scope check.

## Verdict: PASS

---


# REVIEW: code-reviewer.md

# Code-Reviewer Review — HANDOFF-20260702-trajectory-eval-p3

**Reviewer**: code-reviewer (narrow-scope, Gate 2 pre-handoff)
**Date**: 2026-07-02
**Scope**: §4.2 / §6 / §9.1 / §10 + acceptance-protocol.md L100-140 + assemble-bundle.sh (full)
**Verdict**: CONDITIONAL PASS

---

## Summary

Purpose: wire a calibrated (advisory) trajectory judge into Alex's `*accept` protocol as an
additive sibling `step4d`, add active-first path resolution to `assemble-bundle.sh`, and ship a
30-day `gate-roi-report.sh`. The design is disciplined — three freeze prohibitions with matching
ACs, SAFETY line-set diff pinned to a stable commit, in-place metric definitions. The AC3 baseline
mechanism is empirically sound (verified below). However there is one **P0**: the entire new
active-first code path (FR2's whole reason to exist) is untested by any AC and, combined with the
all-path silent degradation contract, could ship as a permanent silent no-op — the exact
"unconsumed measurement" failure the Epic exists to prevent. Plus two P1 AC-integrity gaps.

**Empirical checks run:**
- `git cat-file -t 3a9c82e` → commit exists; baseline file present at that commit ✓
- AC3 forward-missing on UNMODIFIED file → `0` ✓ (mechanism sound)
- current SAFETY count = 5, baseline @3a9c82e = 5 ✓
- mirrors byte-identical (`diff -q`) → SAME ✓
- `grep step4d acceptance-protocol.md` → empty (no name collision) ✓
- `grep -rn assemble-bundle .claude/skills` → empty (no other caller) ✓
- **`grep -c 'blocking: false'` current = 4** (AC1 vacuousness — see P1-1)
- other 5 markers current = 0 (valid presence markers) ✓
- trajectory-eval-p2 = ARCHIVED (both HANDOFF + COMPLETION in archive/) — see P0-1

---

## 1. Critical Issues (P0)

### P0-1 — The new active-first path (FR2) has ZERO acceptance coverage, and failure is silent
**Focus areas 3 + 4 converge here.**

- AC4 regenerates `sep-phase2` — an **archived** slug → active lookup misses → exercises only the
  **archive fallback** (the old code path).
- AC6 E2E runs on `trajectory-eval-p2` — confirmed **archived** (`archive/handoffs/HANDOFF-…-p2.md`
  + `COMPLETION-…-p2.md` both present) → again archive path only.
- **Result: no AC ever exercises active-first resolution.** Yet FR2's entire purpose is to judge a
  trajectory *at acceptance time, before it is archived* (§1.1). So the one behavior being built is
  the one behavior never verified.
- Compounding factor: NFR1 makes every failure **silently skip** (exit 0 + 1 log line). A broken
  active-first glob (wrong dir, bad `head -1`, empty match) would not error — it would skip forever.
  Every real acceptance would emit `judge: skipped` and accumulate nothing. That is precisely the
  "traces無人消費 / 1-in-328" failure mode cited as this Phase's raison d'être (§1.2, §11.1).
- Blast-radius amplifier: `grep -rn assemble-bundle .claude/skills` is empty — step4d will be the
  **first and only** caller of the assembler, so this AC is the *only* possible guard.

**Required fix**: add an AC that runs the assembler (or the step4d wrapper — see P1-2) on an
**active** slug and asserts a well-formed, non-thin bundle. `HANDOFF-20260702-trajectory-eval-p3`
is live in `active/handoffs/` right now and is a natural fixture. Assert the bundle resolves the
handoff from `active/` (not archive) and contains the frontmatter + §9.1 sections.

---

## 2. Recommendations (P1)

### P1-1 — AC1 marker `blocking: false` is VACUOUS (verified: file already has 4 occurrences)
`grep -c 'blocking: false' acceptance-protocol.md` returns **4** *today* (step4c L108, step4e L112,
step4f L130, + a rationale). AC1's `grep -c ≥1` therefore PASSES even if step4d omits
`blocking: false` entirely — the marker cannot distinguish "step4d correctly advisory" from
"step4d missing the advisory flag." This is the single most safety-relevant marker (it encodes the
whole advisory-not-blocking contract of Intent §1.3) and it is the one that is unverifiable.

**Fix**: scope AC1 to the step4d block. Extract the block first, grep within it, e.g.
`awk '/^  step4d_trajectory_judge:/,/^  step4e_feedback:/' <file>` piped to each `grep -c`.
The other 5 markers currently return 0, so they are valid presence markers — but scoping all 6 to
the block is cheap and closes the "right token, wrong location" hole for the whole set.

### P1-2 — AC7 is not verifiable as written; step4d is prose, not a script
AC7/micro-6 say "移開 judge-prompt.md → **執行 step4d 腳本化部分** → `echo exit=$?`". But step4d is a
protocol YAML/prose block that *Alex-the-agent* executes; the skip logic (`--no-judge` check,
`judge-prompt.md` existence check, JSON validation, skip-line emission) lives in agent prose, not a
script. `assemble-bundle.sh` does **not** check `judge-prompt.md`, so moving that file changes no
script's exit code. There is nothing that emits `exit=$?`. As written the AC cannot be run.


---


# REVIEW: data-analyst.md

---
reviewer: data-analyst
handoff: HANDOFF-20260702-trajectory-eval-p3.md
scope: §1.2, §2.1, §4.2C, §4.4, §9.1 AC5, §10.2
date: 2026-07-02
focus: measurement-methodology validity of the gate-roi-report.sh contract
---

# Data Analyst Review — Trajectory Eval P3

## 1. Critical Issues (P0)

### P0-1: gate4_delta is a CATCH, not an escape — its placement under "Escaped post-ship" inverts its meaning for the strategic decision

**Location**: §4.2C section 3 ("Escaped post-ship"), §4.4

**What the spec says**: "Escaped post-ship" has two sub-items — (a) bugfix-prefix handoffs and (b) non-empty gate4_delta entries. The doc notes both are "deliberately not summed" because the definitions differ. §4.4 repeats this framing.

**What gate4_delta actually records**: From §2.1 and the handoff frontmatter, gate4_delta captures "Alex prediction vs Gate 4 reality" gaps. These are discrepancies CAUGHT BY Gate 4 — the gate worked, it found something. This is the opposite of a post-ship escape. A non-empty gate4_delta is evidence that Gate 4 provided value, not evidence of a defect that got through.

**Why this matters for the strategic decision**: The ROI report feeds the "mechanical enforcement positioning" decision (§1.2). That decision requires distinguishing:
- "Gates catch things" (argues for enforcement) — gate4_delta belongs here
- "Things slip past gates" (also argues for enforcement, differently) — bugfix-prefix handoffs belong here

By housing gate4_delta under the "escape" section — even with a "not summed" disclaimer — the report trains any reader who scans section headers to associate Gate 4 delta with failure rather than with catch. A decision-maker reading the executive summary will read "Escaped: 6 bugfix handoffs + 7 gate4_delta" and conclude gates leak more than they catch. The opposite conclusion is warranted.

**Required fix**: Move gate4_delta to the "Caught pre-ship" section as a distinct sub-item labeled "Late catches at Gate 4 (gate4_delta non-empty)." Alternatively, create a standalone "Gate 4 efficacy" sub-section. The separation from bugfix-prefix counts is correct; the parent section heading is wrong.

---

### P0-2: No denominator requirement — raw counts are uninterpretable for the enforcement decision

**Location**: §4.2C, §9.1 AC5

**What the spec requires**: AC5 checks `exit=0 + ≥4 sections + each section contains a "compound command" line + empty window does not crash`. There is no requirement that the report compute or state rates.

**The problem**: The data in §2.1 gives: 50 gate_result events, 6 bugfix-prefix handoffs, 7 non-empty gate4_delta entries. These raw counts are uninterpretable without a denominator.

- "6 escapes" over 6 total handoffs accepted = 100% escape rate → mechanical enforcement is urgent.
- "6 escapes" over 120 total handoffs accepted = 5% escape rate → acceptable under advisory regime.

The report currently cannot distinguish these cases because it never computes total accepted handoffs in the window. The same problem applies to the "Caught pre-ship" count: is "50 file×level catches" across 6 reviews or 50 reviews?

**For the enforcement decision, rates are load-bearing, not decoration.** A report that delivers raw counts to a strategic decision without normalization can actively mislead.

**Required fix**: AC5 must require two additional outputs:
1. Total handoffs accepted in the window (derivable from archive slug count filtered by date).
2. Escape rate = (a) count / total accepted handoffs, reported as a fraction with the denominator stated explicitly (e.g., "6 / 42 = 14.3%").

The "compound command" (复算命令) line already exists for re-derivation; rates need to be first-class outputs, not optional derivations.

---

## 2. Recommendations (P1)

### P1-1: per-file-per-level dedup collapses finding density — direction of bias works against the ROI narrative, no caveat required

**Location**: §4.2C section 2 ("Caught pre-ship")

**The dedup rule**: `grep -oE 'P0|P1'` per reviewer file, then "each file×level counts once." A review with 5 P0 findings and a review with 1 P0 finding both contribute exactly 1 to the P0 count.

**Bias direction**: This undervalues high-density reviews. If the actual distribution is "most review files have 1-2 findings" then the undercount is modest; if "many reviews have 3-5 findings per level" then the undercount is severe. The direction of bias works AGAINST the strategic narrative (makes gates look less productive than they are), which is conservative but not neutral.

**Is finding-level count feasible?** The handoff references "P0-1/P0-2 numbering conventions" in the focus brief. If review files consistently use structured numbering (e.g., `P0-1`, `P0-2`, `P1-1`), then `grep -oE 'P[01]-[0-9]+'` would count discrete findings rather than file×level presence. This is more accurate and feasible if the convention is consistent.

**Required action (two options, one must be chosen)**:
- Option A: Audit whether the P0-N/P1-N numbering convention is consistent in `.tad/evidence/reviews/**/*.md`. If yes, switch to finding-level grep and update the AC5 verification command accordingly.
- Option B: Retain per-file-per-level dedup but add a mandatory footnote to the "Caught" section output: "Count = files×levels with at least one finding; reviews with multiple findings per severity level are counted once per file×level. This is a structural lower bound."

Without one of these, the count is presented as if it means "N issues caught" when it means "N file×level combinations had at least one issue."

---

### P1-2: Escape count has no explicit lower-bound caveat required in the report output

**Location**: §4.2C section 3, §9.1 AC5

**The survivorship gap**: bugfix-prefix detection only surfaces escapes that resulted in a filed handoff with a `bugfix-` or `fix-` prefix. Escapes that were fixed inline (no handoff filed), fixed in a subsequent feature handoff without the prefix, or silently absorbed into a later refactor are completely invisible to this method.

The §2.1 data confirms 6 bugfix-prefix handoffs in the window. The actual number of escaped defects could be 2x-5x higher. This is not a methodology flaw unique to this spec — it is inherent to any handoff-based escape detection — but the report consumer must know this.

---


# TRACE EVENTS (slug=trajectory-eval-p3, sorted by ts)

/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-07-02.jsonl:{"ts":"2026-07-02T18:01:59Z","type":"handoff_created","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","file":"/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/HANDOFF-20260702-trajectory-eval-p3.md","size_bytes":19723,"slug":"trajectory-eval-p3"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-07-02.jsonl:{"ts":"2026-07-02T19:30:31Z","type":"expert_review_finding","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","context":"2 P1 findings","outcome":"P1","slug":"trajectory-eval-p3","agent":"code-reviewer"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-07-02.jsonl:{"ts":"2026-07-02T19:30:31Z","type":"expert_review_finding","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","context":"3 P2 findings","outcome":"P2","slug":"trajectory-eval-p3","agent":"code-reviewer"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-07-02.jsonl:{"ts":"2026-07-02T19:34:00Z","type":"task_completed","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","file":"/Users/sheldonzhao/01-on progress programs/TAD/.tad/active/handoffs/COMPLETION-20260702-trajectory-eval-p3.md","size_bytes":6220,"slug":"trajectory-eval-p3"}
/Users/sheldonzhao/01-on progress programs/TAD/.tad/evidence/traces/2026-07-02.jsonl:{"ts":"2026-07-02T19:35:32Z","type":"gate_result","project":"TAD","schema_version":"2.0","actor_tag":"agent_inferred","detail_level":"summary","context":"Gate 3: Gate 3","outcome":"pass","slug":"trajectory-eval-p3","agent":"blake"}

---

