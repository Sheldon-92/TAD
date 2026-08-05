# Spec Compliance Review — HANDOFF-20260805-lite-pricing-gate-protocol (P1a)

Model: harness=claude-code | model=deepseek-v4-flash | route=host
（机械捕获：`ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`（第三方 host 端点）、`ANTHROPIC_MODEL=deepseek-v4-flash`（运行时自报）；`~/.claude/settings.json` `.model`=`opus[1m]`（配置 alias，env 优先）。）

- Reviewer: TAD Layer 2 Group 0 spec-compliance reviewer
- 日期: 2026-08-05
- Scope: NARROW — handoff §4/§5/§6/§7、四份 skill diff、台账全文、post-impl-check.sh + allow.txt（未扩展浏览）

---

## 逐条判定

- **AC1** PASS — 14 个字面量全部逐字存在（post-impl-check.sh 重跑静默；更强证据：插入节 50 行内容与 §4.1 规格块 byte diff 全零，字面量在 diff 覆盖范围内）【执行实证】
- **AC2** PASS — 位置正确且两 skill 逐字节相同（`sed -n` 提取 + `cmp`：alex-lite 350–399 / blake-lite 404–453，`cmp` 零差异）【执行实证】
- **AC3** PASS — 台账存在、表头 8 列、分隔行逐字、无数据行（独立复核：`grep -E '^\|' | grep -v '^|-\{3,\}|' | wc -l` = 1，仅表头）【执行实证】
- **AC4** PASS — 纯插入 2 行、零删除（numstat awk 静默）【执行实证】
- **AC5** PASS — tracked 围栏静默（BASE 以来新增改动文件全在授权集）【执行实证】
- **AC5b** PASS — 3 个预存在脏 tracked 文件（NEXT.md / ac-verification.md / gate-design.md）哈希前后一致【执行实证】
- **AC6** PASS — untracked 围栏静默（新文件全在授权集；comm -13 全文核对）【执行实证】
- **AC7** PASS — `.agents/` 两镜像含该节且与 canonical 字节一致（AC7 grep/cmp 静默 + release-verify parity PASS）【执行实证】

verdict: **PASS**（0 P0 / 0 P1 / 2 P2）

---

## 任务 1：§4.1 逐字比对（14 个字面量 + awk 命令 + 两 skill 逐字节）

**判定：PASS（内容 50/50 行逐字节相同）**

- 方法：`sed -n '130,179p' handoff`（§4.1 规格块）vs `sed -n '350,399p' alex-lite` 做 byte diff。
- 结果：`50a51 > <blank>` —— 唯一差异是节末（`## Forbidden` 前）多一个**空行**（`od -c` 实证：仅 `\n`）。
- 14 个字面量、awk 扫描命令（含 `awk -v t="$(date +%F)"` 整块）全部逐字节命中。
- 空行判定：不属 14 个受保护字面量；handoff AC2 注明确认本条只做**两 skill 互比**、不与规格原文比对（Gate2-R3 P2-3 残余，handoff 明示已知并接受）；且该空行在两侧对称存在（cmp 通过的前提）。→ P2-1（见下），不构成 FAIL。
- 两 skill 逐字节：`cmp /tmp/sec-alex-lite.txt /tmp/sec-blake-lite.txt` 零输出。【执行实证】

## 任务 2：post-impl-check.sh 重跑

**判定：PASS** — 8 条 AC（AC1/AC2/AC3/AC4/AC5/AC5b/AC6/AC7）全部输出 `PASS (silent)`，8 个 AC*.txt 结果文件均为空。【执行实证】

脚本与 handoff §5 AC1–AC7 命令逐条对照：命令逻辑一致；仅 AC7 缺 `bash .tad/hooks/lib/release-verify.sh parity .` 调用（见 P2-2），且每条 AC 输出重定向至结果文件 + 汇总 echo（对"无输出"期望的呈现层改编，FAIL 检测语义不变）。

## 任务 3：插入位置

**判定：PASS** — alex-lite：`## 跨角色请求消歧`(334) < `## 约束准入（新增约束前必须定价）`(350) < `## Forbidden`(401)；blake-lite：388 < 404 < 455。两个 skill 均满足「Forbidden 之前、跨角色请求消歧 之后」。【执行实证】

## 任务 4：台账结构

**判定：PASS** —
- 表头 8 列：`awk -F'|'` NF=10（含首尾空字段 = 8 列）。
- 分隔行：`grep -Fx '|---|---|---|---|---|---|---|---|'` 逐字命中。
- 无数据行：`grep -E '^\|' | grep -v '^|-\{3,\}|' | wc -l` = 1（仅表头）；`^\|[^-]` 计数 = 1。
- 全文与 §4.2 规格块 byte diff 零差异（含 4 行 blockquote 说明、末尾换行）。【执行实证】

## 任务 5：parity

**判定：PASS** — `bash .tad/hooks/lib/release-verify.sh parity .` → `VERDICT: parity PASS (exit 0)`，`✅ .claude/skills <-> .agents/skills byte-identical`。【执行实证】
备注（阅读推断）：`.agents/` 的**生成方式**（parity --fix vs 手工 cp）无法从仓库状态观测；可观测要求（字节一致）成立。

## 任务 6：§6 注意事项

**判定：PASS** —
1. **awk 无字符串相等判断**：post-impl-check.sh 中 awk 仅 AC4 一处（numstat 字段 `$2!="0"` / `$1+0==0`，纯 ASCII 数字，非 CJK 串，符合 §6.1 例外）；skill 节内 awk 仅 ISO 日期比较（纯 ASCII）。两处均不触发本机 awk 中文比较缺陷。【执行实证】
2. **无计数类自检引入**：脚本中唯一 `grep -c` 是 AC3 的台账数据行计数（handoff §5 AC3 原文逐字，计数对象是台账行而非 skill 内 MUST/禁止 词——不构成 §6.3 警告的自踩场景）。【执行实证】
3. **无 NEXT.md 改动**：AC5b 前后哈希 `cmp -s` 一致；NEXT.md mtime 2026-08-04 22:12 早于实现（skill 2026-08-05 10:23、台账 10:24）；其 BASE 以来 diff 内容全部为 2026-08-04 队列条目（证据重放 advisory 等），与本单无关。【执行实证】

---

## Findings

**P0（必修）**：无。

**P1（应修）**：无。

**P2（建议）**：
1. 插入节末尾（`## Forbidden` 前）比 §4.1 规格块多一个空行。【执行实证】不属 14 个受保护字面量，且 handoff AC2 明示只做跨 skill 互比（P2-3 残余已知并接受），故不阻塞；如需与规格块全字节一致，删掉该空行即可（两侧对称删）。
2. post-impl-check.sh 的 AC7 未包含 handoff §5 AC7 命令块中的 `bash .tad/hooks/lib/release-verify.sh parity .` 调用（已由本 reviewer 单独执行，PASS；handoff 期望 parity 判定行贴进 Completion 作为 provenance——脚本留空则该 provenance 需人工补跑）。【执行实证】

**信息性备注（非缺陷）**：
- 尚无 COMPLETION 报告（DoD 待办，评审阶段属预期）；4 份 skill + 台账已 staged、未 commit，staged 集合恰为授权集，3 个预存在脏文件未被误暂存。【执行实证】
- handoff 文件本身 untracked（`??`），但 mtime 00:24 早于快照（10:21），且 `git_tracked_dirs` 不含 `.tad/active`——设计使然，AC6 不受影响。【执行实证】

---

## 执行证据

1. `env | grep -E '^ANTHROPIC_(BASE_URL|MODEL|SMALL_FAST_MODEL)='` → `ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic` / `ANTHROPIC_MODEL=deepseek-v4-flash`；`jq -r '.model // "unset"' ~/.claude/settings.json` → `opus[1m]`；`git log --oneline -3` → HEAD `31a96aa`（= BASE）。
2. `bash .tad/evidence/acceptance-tests/lite-pricing-gate-protocol/post-impl-check.sh` →
   ```
   === AC results ===
   AC1: PASS (silent)
   AC2: PASS (silent)
   AC3: PASS (silent)
   AC4: PASS (silent)
   AC5: PASS (silent)
   AC5b: PASS (silent)
   AC6: PASS (silent)
   AC7: PASS (silent)
   ```
3. `sed -n '130,179p' HANDOFF…md > /tmp/sec-spec.txt; diff /tmp/sec-spec.txt /tmp/sec-alex-lite.txt` → 唯一输出 `50a51 > <空行>`；`sed -n '51p' /tmp/sec-alex-lite.txt | od -c` → `0000000 \n`。
4. `cmp /tmp/sec-alex-lite.txt /tmp/sec-blake-lite.txt` → 零输出（BYTE-IDENTICAL）。
5. `grep -n '^## ' .claude/skills/alex-lite/SKILL.md | grep -E '约束准入|Forbidden|跨角色请求消歧'` → `334:## 跨角色请求消歧` / `350:## 约束准入（新增约束前必须定价）` / `401:## Forbidden`；blake-lite → 388 / 404 / 455。
6. `bash .tad/hooks/lib/release-verify.sh parity .` → `VERDICT: parity PASS (exit 0)` / `✅ .claude/skills <-> .agents/skills byte-identical`。
7. 台账：`grep -F '| 日期 | skill |'` → `NF=10`；`grep -Fx '|---|---|---|---|---|---|---|---|'` → 命中；`grep -E '^\|' | grep -v '^|-\{3,\}|' | wc -l` → `1`；`diff <(sed -n '193,201p' handoff) ledger` → 零差异（LEDGER VERBATIM）。
8. `grep -n 'awk' post-impl-check.sh` → 仅 `35: | awk 'BEGIN{n=0} …'`（AC4）。
9. `git diff 31a96aa -- NEXT.md | head` → 内容为 2026-08-04 队列条目；`stat -f '%Sm'` → NEXT.md 2026-08-04 22:12（早于实现 10:23）。
10. `comm -13 untracked-before.txt untracked-after.txt | grep -vE "$ALLOW"` → 空；全量新文件仅 `$S/AC*.txt`、`post-impl-check.sh`、`sec-*.txt`（均在授权集）。
11. `git status --porcelain --untracked-files=no` → staged 恰为 4 skill + 台账；3 预存在脏文件保持 unstaged。
