# TICKET — R4 蒸馏文本补完包（corr 定义／Q1 指针／pilot 二义注记／MECE 计数／§10 载体点名）

- **Status**: OPEN（待分诊执行）
- **Owner**: TAD PM（Muse 侧 TAD 席位，分诊属主）

## 1. 范围与逐点草案

五点互相独立，任一点被评审打回不连带其余四点。

- (a) **corr 行类型定义**：`.tad/evidence/tiering-log.md` 表头「行类型」处补一段（草案）：「更正行（行首标 `corr`）：由评审或复核在收口时追加，对计划行/recon 行的计数或口径错误作对账更正；原行不回改；字段同计划行，pointer 须指 finding 出处与落行凭据。」（已由 conductor 于落票时定：扩围，定义见下。复看行（行首标 `review` 加日期）：由蒸馏报告作者在 Epic 蒸馏复看时追加，或由 PM 在发版前复看时追加；第二字段记复看对象/范围，declared、suggested、agree、sensitive_hit、file_count 五字段不适用时均填 `—`，pointer 字段记复看载体指针、结论与下次复看点。见蒸馏报告 §4 注。）
- (b) **Q1 就地指针**：`.tad/evidence/yolo/r4-batch/phase1-design.md` §6 P5-2 首段末以附记形态加一行（草案）：「本段所称 `.tad/runtime-compat/ledgers/` 子目录不存在；兼容评估面以校验器脚本常量四件为准，更正与确认见 HANDOFF-20261027-r4-phase5-borrow4.md §2.2 与 §10.5 Q1。」原文不回改。
- (c) **pilot 二义注记**：`.tad/gates/gate-canonical-checklist.md` Gate 3「Code metrics」行尾或 Gate 2「Pilot declared」行尾加一句（草案，落一处即可）：「注：本节『试点链』指代码指标记账的试点名单，与 Gate 2『Pilot declared』的同构单元先行 pilot 不是一事，勿混。」不改任何既有术语本体（改名成本遍及已落盘文本，不成比例）。
- (d) **MECE 注记计数校正**：canonical Gate 3 节头注记「9 items」改「10 items」（该节现列 10 项，亲验在盘），改后按文件头纪律重新 sync `.agents/skills/gate/SKILL.md` 同位置注记，并跑 drift check（条目集合 diff 为空）。
- (e) **guide §10 载体点名**：`.tad/templates/acceptance-verification-guide.md` §10 Delivery rule 中「the delivery record」后补载体名分（草案）：「…the delivery record — the verify-output citation row in the delivering chain's completion report Evidence section (see `.tad/templates/completion-report.md`) — points at it.」若落票评审认为载体应为项目侧文件，改指项目证据面的具名节，但必须落成一个具名载体，不许维持无名状态。

## 2. 触发/验收

逐点以 grep/diff 为据：(a) 表头含 corr 定义且与已落 corr 行形态相符；(b) 设计 P5-2 附记在盘、原句逐字未动；(c) 注记在盘且两义各有指针；(d) 两文件注记同为 10 且 drift diff 为空；(e) §10 出现具名载体路径。五点全过才算本票完成，部分完成按点记账。

## 收口（2026-10-28）

终局：实施 r4t-t3-impl-1 五点全落。Gate 3 独立复核 CONDITIONAL（p0=0，p1=2，p2=2）→ 修复轮 r4t-t3-fix-1（F1 注记传播 SKILL、F2 回报勘误、F3 附记改名＝conductor 裁断、F4 节尾维度补齐）→ 修复定点复核 PASS（p0=0，p1=0，p2=0）。verdict 件：`.tad/evidence/yolo/distill-tickets/t3-gate3-review.md`、`.tad/evidence/yolo/distill-tickets/t3-fix-gate3-review.md`。

状态：CLOSED
