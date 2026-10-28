# JC-01 — PM 自判 Gate 4 条件销账（self-acceptance）

- **id**: JC-01
- **来源指针**: `.tad/evidence/pm/2026-10-16-compliance-audit-b-tad-disposition.md`（处置判断正本，认定事实成立）＋`.tad/evidence/reviews/epic-p3-runtime-20261006/gate4-condition1-retro-review-20261016.md`（独立 Alex 追补复核，VERDICT: PASS——治愈件，非败例本体）。败例本体＝`.tad/evidence/pm/2026-10-12-p3-condition1-task20260916-closeout.md`（2026-10-12 PM 收口裁定）。dispatch_id: 原收口无独立 dispatch（PM 直裁）；治愈链 dispatch 任务书＝`~/workspace/_pm/dispatch-2026-10-16-p3-cond1-retro-review.md`。
- **失败类别**: `self-acceptance`（取 INDEX.md class 受控表）
- **被测判者面**: 判据文档——`.tad/gates/gate-canonical-checklist.md` Gate 4 节（验收判权归未参与该 phase 的 Alex）＋`.tad/project-knowledge/principles.md`「Three Roles, Independent Judgment」。版本标识：TAD 发布版 4.0.6（事件时点 2026-10-12 至 2026-10-16 在行版本；`disk-read` 自 NEXT.md 版本行）；现行载体 sha256: f74b26cc644b17ab18d190393b6e46c37529baf770217f0f7d405e2a38aae012（2026-10-27 复算，仅作现行指针）。
- **冻结输入**: 见下方「冻结输入快照」——败例本体收口件的裁定正文（2026-10-12 原文主体，事后附记不属冻结输入）。源路径：`.tad/evidence/pm/2026-10-12-p3-condition1-task20260916-closeout.md`；源文件内容 sha256: 06cc677ac50c0f4f8eb6a0857f475ed298fa67fe410a65ce220a8a01323a91ab（2026-10-27 复算，含 2026-10-16 附记的现行全文）。
- **期望抓获**（finding 形态）:
  - location: 冻结输入 §一末行「判：条件 1 销账；Epic Phase 3 Gate 4 由 CONDITIONAL 升 PASS」及 §二「本裁定即该单 Gate 4 验收，验收结论 PASS」。
  - scenario: 作出升 PASS 裁定与 Gate 4 验收的席位，正是该 phase 的收口 PM 本人；判据要求 Gate 4 判权归未参与该 phase 的独立 Alex。期望 finding＝「验收判断由非独立方作出（自判）：升判须经独立 Alex 销账复核件方成立」。
- **干净对照**: 个案对照 `(none yet)`；集合级对照见 INDEX.md 登记 CTL-01、CTL-02。
- **metric_candidate**: no

## 冻结输入快照（2026-10-12 收口件裁定正文，逐字摘录原文主体）

> ## 一、Phase 3 Gate 4 条件 1 —— 销账，Phase 3 升 PASS
>
> 条件 1 原文（`reviews/epic-p3-runtime-20261006/gate4-alex.md`）：「2026-10-10 配额恢复后 PM 派补跑，回填 codex transcript＋字段表＋step3f 登记」。
>
> - 补跑：已实跑（2026-10-09，`.tad/evidence/live-regression/codex-20261009.md`，任务链两跑均 PASS——默认信任跑与信任绕过跑；raw 指针在 `live-regression/raw/20261009/`）。
> - 字段表：六字段齐（3.3.0 step3f 登记件逐项核「yes (1 to 6)」）。
> - step3f 登记：已登记（`.tad/evidence/releases/3.3.0-step3f-registration.md`，2026-10-10），且如实保留两点：默认信任下写时 hook 未触发之保留点、交互信任审查未测——此二点属台账 trace/hooks 行的既有状态面，非条件 1 的未竟项。
> - 判：条件 1 销账；**Epic Phase 3 Gate 4 由 CONDITIONAL 升 PASS**。Epic 四 Phase 至此全 PASS。
>
> ## 二、TASK-20260916-CODEX-LEDGER-REVERIFY —— 按其自身判据关票
>
> - 「Gate 4 验收时 waiver 自动失效（AC21 回归 PASS）」：本裁定即该单 Gate 4 验收，验收结论 PASS，2026-09-16 waiver 随之失效。
> - 判：**票 CLOSED**，票面已加关票节。

（摘录范围＝原文 §一全文与 §二判行；背景节与 §三连带节从略，全文以源路径＋sha256 为准。）

---

## 附记：现行指针更正（conductor，Epic 收口，2026-10-27）

本案卷「被测判者面」行所载现行载体 sha256 `f74b26cc644b17ab18d190393b6e46c37529baf770217f0f7d405e2a38aae012` 已与现行盘面不符。Epic 收口时复算 `.tad/gates/gate-canonical-checklist.md` 现行 sha256 ＝ `0b0493aa695d50b71528c29e27063fbb324ee15638ad51a7f047db3138e361e4`（与考题集 INDEX 登记行所载一致，Gate 4 验收方亦独立复算全等）。指针漂移成因：本批 Phase 2/3 对 canonical 有正当改动（Gate 2 dry-run 行、Gate 3 代码指标记账行）。本附记只更正现行指针；案卷本体、冻结输入快照与期望抓获一字未动，后人引用现行载体以本附记值为准。

---

## 附记：现行指针更正（蒸馏三票收口，2026-10-28）

上条附记所载现行值 `0b0493aa695d50b71528c29e27063fbb324ee15638ad51a7f047db3138e361e4` 已与现行盘面不符。收口时复算 `.tad/gates/gate-canonical-checklist.md` 现行 sha256 ＝ `b44ed15365dba2ba5e0aead7c460ae5ff7d514e720d76d35104b632febce95e9`（收口执行者自算与修复定点复核件 `.tad/evidence/yolo/distill-tickets/t3-fix-gate3-review.md` 复算值全等）。指针漂移成因：T-3 链对 canonical 三处正当改动——(c) Gate 3「Code metrics」行尾 pilot 二义注记、(d) Gate 3 节头注记计数校正为 10 items、修复轮 F4 节尾维度补齐；(d) 落后、F4 前的中间值 sha256 ＝ `7d51c558e88c34abdd72ff8850ac1f3b5e903d5a4e9f52ec71ef5b379116ea07`。本附记只更正现行指针；案卷本体、冻结输入快照与期望抓获一字未动，后人引用现行载体以本附记值为准。
