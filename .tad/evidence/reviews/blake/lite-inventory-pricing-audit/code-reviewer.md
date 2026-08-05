# Code Review — HANDOFF-20260805-lite-inventory-pricing-audit (v4) 实现

**Reviewer**: TAD Layer 2 Group 1 code-reviewer | **Model**: deepseek-v4-flash（harness: Claude Code，route: L2G1 code-reviewer）
**Date**: 2026-08-05 | **Verdict**: PASS

---

## 摘要

本单是 6 行改动：4 个 skill（.claude/.agents 各 2）「约束准入」节各替换 1 行 awk 日期正则
（`[0-9]{2}` → 月/日取值约束），台账前言 1 行改 2 行（§3.0）。改动集与契约清单精确吻合，
5 个目标文件 diff 逐字节等于契约目标（AC 常量独立重建证明），无节外改动。本单的本质——
正则语义——经 30 探针边界矩阵 + 462 例穷举（月 00–13 × 日 00–32）独立复跑，全部符合 §3.2
规格；三处 §3.1.1 不变量（+23 偏移、前置过滤行、else MALFORMED 分支）逐一实证完好。
**无 P0、无 P1**，2 条 P2（1 条流程记录、1 条既有设计观察）。AC1/AC2 PASS；AC3 仅 (d) 项
Epic 常量按 handoff 原文为陈旧值，实际文件与用户裁定新常量一致（已知背景，非缺陷）。

---

## 发现

### P0（必修）
无。

### P1（应修）
无。

### P2（建议）

- **P2-1（流程/文档，执行实证）**：handoff §4 AC3(d) 钉死的 Epic 文件 md5 常量
  `1acdc51ec250237bd9e8c49c4be4604d` 已过期——实际文件 md5 =
  `67c977e5b5c7469cf1e195612fb3afc1`，与用户裁定（"更新常量后继续"）一致，偏离已记录在
  `.tad/evidence/acceptance-tests/lite-inventory-pricing-audit/pre-impl-output.txt`
  （"偏离记入 Completion"）。按 handoff 原文逐字跑 AC3 会 FAIL，仅因此项。建议：
  (a) Completion 报告必须显著携带该偏离记录；(b) 后续维护轮把 handoff §4 常量改订为新值，
  维持「常量住在 handoff 里」这道防线不出现书面陈旧（§7 结构性自指残余的同一面）。
  不阻塞——用户已裁定。

- **P2-2（既有设计观察，非回归，执行实证 #16/#17）**：小写 `provisional:` 与全角冒号
  `PROVISIONAL：` 的合法日期行会落入 MALFORMED（内层字面量只匹配半角大写
  `PROVISIONAL: `）。旧正则同样如此（内层字面量未变），且节内明文记载
  「主正则只匹配半角 PROVISIONAL: 前缀」——是刻意设计，不是本单引入。仅记备查，
  未来若台账实际用全角冒号写入会误报，届时应按 §3.3 尺子另起单。

---

## 逐条核查结果（均执行实证）

| 核查项 | 方法 | 结果 |
|---|---|---|
| AC1（4 节 70 行 md5 + 台账 10 行 0 数据行 md5） | 按 §4 原文重跑 | **PASS**（4×`47fd5648…`/70 行；台账 `a81fde7d…`/10 行/0 行） |
| AC2（4 文件各 1 增 1 删 + 台账 2 增 1 删） | 按 §4 原文重跑 | **PASS**（numstat 1/1 ×4 + 2/1 ×1） |
| AC3（(a) HEAD 锚 / (b) skip-worktree / (c) 围栏 / (d) 双 md5） | 按 §4 原文重跑 | (a)(b)(c) **PASS**；(d) Epic 常量陈旧 → FAIL（已知背景，实际文件=新常量 67c977e5…；P1b 判定文件 md5 命中 9da84175…）。按新常量则 PASS（post-impl-output.txt 佐证） |
| AC 常量独立重建（防回显） | HEAD + 契约文本 python3 重建 | 台账 `a81fde7d…`/10 行、两 skill 节 `47fd5648…`/70 行——**常量=目标，非实现回显** |
| 新正则语义（§3.2 十例 + 边界） | 30 探针矩阵，正则行从真实文件逐字节注入 | 13/13-01/01-99/01-39/01-32/01-00/00-15/00-00 → MALFORMED；2024-01-01（含 `\|` 尾）→ OVERDUE；2027-12-31/2027-01-01/当日 → 静默；2027-02-29/02-31/04-31/11-31 → 静默（§3.2 刻意接受）；尾随文本/一位数月日/超长日 → MALFORMED |
| 462 例穷举（月 00–13 × 日 00–32） | 独立复跑 | 90 MALFORMED + 372 静默，与规格逐格吻合 |
| 旧正则负向控制（探针判别力） | 同一矩阵跑旧正则 | 0 MALFORMED（bug 前提复现：非法日期静默/误判 OVERDUE）——探针能抓住未修复态 |
| §3.1.1 不变量 | 逐字节对照 + 功能验证 | ① `+23` 偏移：`printf 'PROVISIONAL: review-by ' | wc -c`=23；2024-10-10、2024-01-01 `\|` 尾均正确 OVERDUE（d 提取未移位）② 前置过滤行（大小写不敏感+全/半角冒号）与文件逐字节一致（hex 对照，含 U+FF1A）③ else MALFORMED 分支在探针与文件中逐字节一致 |
| §3.0 台账前言 | 重建 + 行尾检查 | 替换逐字节=目标两行（含 LF 行尾、全角标点），0 数据行 |
| .claude/.agents parity | cmp | 两对文件逐字节相同 |
| 范围（无第 5 处活副本） | 全仓 grep 新旧正则 | 旧正则剩余命中全在冻结证据/归档/当前 handoff 文档；4 skill 各仅 1 处 match 行；`## Forbidden` 终止行在 4 文件均存在（420/474 行） |

---

## 结论

实现与契约逐字节一致，正则语义修复正确且未破坏三处不变量与已知边界；AC1/AC2 全绿，
AC3 唯一 FAIL 项是已裁定更新的陈旧常量（非实现缺陷）。判别力链条完整：AC 常量独立重建
为「HEAD+契约目标」，探针负向控制复现了 bug 前提，预实现 FAIL 记录与零改动基线吻合。
**Verdict: PASS**（P2-1 的 Completion 记录义务随 Blake 收尾单履行）。

## 执行证据

```
$ git rev-parse HEAD
910ab6cd4ea1765cbd4f64b69f4e015a5eac3dbc

$ git diff HEAD -- <5 目标文件>   # 4 skill 各 1 行正则替换；台账 1 删 2 增
diff --git a/.agents/skills/alex-lite/SKILL.md b/.agents/skills/alex-lite/SKILL.md
-    if (match($0, /PROVISIONAL: review-by [0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]*\|?[[:space:]]*$/)) {
+    if (match($0, /PROVISIONAL: review-by [0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])[[:space:]]*\|?[[:space:]]*$/)) {

$ cmp .claude/skills/alex-lite/SKILL.md .agents/skills/alex-lite/SKILL.md   # → IDENTICAL（blake-lite 同）

$ <AC1 原文>   # 输出：
OK   .claude/skills/alex-lite/SKILL.md  (70 行, md5 一致)
OK   .claude/skills/blake-lite/SKILL.md  (70 行, md5 一致)
OK   .agents/skills/alex-lite/SKILL.md  (70 行, md5 一致)
OK   .agents/skills/blake-lite/SKILL.md  (70 行, md5 一致)
OK   .tad/evidence/audits/lite-constraint-ledger.md  (10 行, 0 数据行, md5 一致)
AC1 PASS

$ <AC2 原文>   # 输出：
1	1	.agents/skills/alex-lite/SKILL.md
1	1	.agents/skills/blake-lite/SKILL.md
1	1	.claude/skills/alex-lite/SKILL.md
1	1	.claude/skills/blake-lite/SKILL.md
2	1	.tad/evidence/audits/lite-constraint-ledger.md
AC2 PASS

$ <AC3 原文>   # 输出：
AC3 FAIL Epic 文件被改
AC3 FAIL
# md5 -q EPIC-20260804-lite-as-tad-body.md → 67c977e5b5c7469cf1e195612fb3afc1（=用户裁定新常量）

$ awk -v t="2027-01-01" -f probe.awk grid.txt | grep -c MALFORMED
90        # 462 格：非法月/日 90 → MALFORMED，合法 372 → 静默

$ awk -v t="2027-01-01" -f probe-old.awk grid.txt | wc -l
34        # 旧正则负向控制：0 MALFORMED，bug 前提复现

$ python3 重建：ledger lines=10 md5=a81fde7d53829dc1b91b987fd4a6add9（=AC 常量）
             .claude/skills/alex-lite/SKILL.md: recon section lines=70 md5=47fd564853125c418195b5713c57b1e6 match=True
             .claude/skills/blake-lite/SKILL.md: recon section lines=70 md5=47fd564853125c418195b5713c57b1e6 match=True
```
