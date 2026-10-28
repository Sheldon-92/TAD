# TICKET — Gate 2 合同评审增机械行：handoff 首行 `---`＋dispatch_id 入 front matter、§9.1 用形态 A（T-1b）

- **Status**: OPEN（待分诊）
- **Owner**: TAD PM（Muse 侧 TAD 席位，分诊属主）

## 1. 背景

生产侧合规形态的文本早已齐备，缺的只是生产时的执法点：

- 模板 `.tad/templates/handoff-a-to-b.md` 第 1 行即 `---`、`real_paths:` 在其 front matter 内、§9.1 表头即形态 A（`| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |`）。
- `.agents/skills/cora/references/conductor-protocol.md` 第 112 行 Y3 派发文亦写明「Include YAML frontmatter … and `dispatch_id: {id}` in it」。

但 r4-batch 四份合同全部以 `dispatch_id:` 为首行、front matter 随后，且 Phase 4 起 §9.1 出现形态 B 表头并在本批内传播——没有任何一道门在生产时按上两处文本核过合同头形。T-1（`.tad/active/TICKET-20261028-checker-false-negative.md`）已定案甲面：检查器对已在野形态作定位层容忍、让归档回归集原样过检。按 patterns/gate-design.md 2026-10-16 consumer tolerance 条目，对本项目自产形态的容忍必须配生产侧修复，容忍只留给已在野的旧件；否则容忍永久化、新合同继续以被容忍形态产出。本票即该对侧义务，经 T-1 设计件 §3 建议项 3 提出、conductor 2026-10-28 裁断③立票。

## 2. 范围

- Gate 2 合同评审清单增一机械行（落点以执行时现行文本为准：`.tad/gates/gate-canonical-checklist.md` Gate 2 节及/或其 gate SKILL 同步面），内容为：**handoff 首行须为 `---` 且 `dispatch_id` 位于 front matter 块内；§9.1 表头须为形态 A**。
- 新合同自此按该行收敛；检查器（gate3-check.sh）的定位层容忍不撤销，只服务存量已在野件。
- 明确不在范围：回改任何存量 handoff 或评审件形态；撤销或收窄 T-1 的检查器容忍；改动 §9.1 方法文法。

## 3. 触发/验收

- 触发：任一新 handoff 合同进入 Gate 2 评审时，该机械行可被评审人机械核验（读首行、front matter 内 dispatch_id 位置、§9.1 表头形态三项，全为盘面事实，不需判断）。
- 验收：新增清单行在盘且措辞含三项核验点；以其后首份新合同为活验收样本——该行被实际核过并在 Gate 2 记录中留痕（合规或不合规均留痕，不合规时合同退回改形而非靠检查器容忍过门）。
