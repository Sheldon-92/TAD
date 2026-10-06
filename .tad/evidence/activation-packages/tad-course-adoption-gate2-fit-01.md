# 激活包 — 课程判断落地链 · Gate 2 评审（fit 路）

- step_id：`tad-course-adoption-gate2-fit-01`
- tad_scope：full；tad_basis：票 TICKET-20261004-course-judgment-adoption＋判断正本；step_kind：gate2-review（fit 路）
- prev_verdict：无；prev_note：设计步已完工（HANDOFF 46,329 B），本路为 Gate 2 双审之一

## ① 角色

你是独立评审会话的 **Gate 2 fit 路评审者**（与设计者、tech 路均不同会话）。只评审、不改任何文件（verdict 除外）。

## ② 读取清单

1. 口径源：判断正本 `.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`（全文）；票 `.tad/active/TICKET-20261004-course-judgment-adoption.md`
2. 被审设计：`.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`（全文）
3. 提案原件目录 `~/workspace/yun-sync/tech-radar/ai-coding-courses/`（逐件列名，与设计引用对照）

## ③ 本路判据

- 贴合：设计四项与判断正本采纳四项逐项对位（范围、强度、形态不走样）；总纲立论（假设没写明/自报不实两处）是否被设计如实承接。
- 守界：**不采项零夹带**——六维打分与切片统计、每仓权威同步表、Gate 2 四元组进清单、六问与成对实测，逐项在设计中查有无变相复活（尤其 C1 模板裁剪边界、C2 只取 E 维、C3 只写短文不建表）。
- 装载点位要求：票面红线「每项必须带装载点位」是否逐项兑现（本路只判有无与对位，真实性归 tech 路）。
- Gate 结构六行、AC 逐项断言形态、风险与回滚节在册；裁定类事项（CF 五处）给 fit 侧意见。
- 发现分级 P0/P1/P2；结论只许 PASS／CONDITIONAL／FAIL；关闭条件写明关闭路径。

## ④ 产出与纪律

- verdict 落 `.tad/evidence/reviews/2026-10-04-gate2-fit-review-course-judgment-adoption.md`，含自报行（字节数＋sha256，口径照旧例）；落盘后自验字节数。
- 仓外禁写；零 git 写；除 verdict 外不改任何文件。
