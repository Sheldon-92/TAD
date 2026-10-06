# 激活包 — 课程判断落地链 · Gate 2 评审（tech 路）

- step_id：`tad-course-adoption-gate2-tech-01`
- tad_scope：full；tad_basis：票 TICKET-20261004-course-judgment-adoption＋判断正本；step_kind：gate2-review（tech 路）
- prev_verdict：无；prev_note：设计步已完工（HANDOFF 46,329 B），本路为 Gate 2 双审之一

## ① 角色

你是独立评审会话的 **Gate 2 tech 路评审者**（与设计者不同会话）。只评审、不改任何文件（verdict 除外）。

## ② 读取清单

1. 被审设计：`.tad/active/handoffs/HANDOFF-2026-10-04-course-judgment-adoption.md`（全文）
2. 落点原件逐件核：设计引用的 `.tad/gates/gate-canonical-checklist.md`、仓根 `AGENTS.md`、Alex 义务块所在文件、`.tad/templates/` 现行形态（以设计 §4 落点表为准逐件开盘核对节位真实存在）
3. 判断正本：`.tad/evidence/pm/2026-10-04-course-proposal-judgment.md`；票：`.tad/active/TICKET-20261004-course-judgment-adoption.md`

## ③ 本路判据

- 落点真实性：每项落点文件与节位在盘上实存、节号引用对得上；**装载点位真实性**：所称装载面（会话启动读、Gate 清单、义务块）在现行机制里确实被读/被触发，给盘上证据，不许凭设计自述。
- 条文草案可实施性：增补条文全文可直接落地、无含糊指代；AC 逐项可跑、基线干跑结果与设计自述一致（抽 ≥3 条 AC 原样干跑复核）。
- 冲突点名 CF-1…CF-5 逐项给评审意见（同意/改法），特别 CF-5（不新建 WS-0 文件、并入 Canonical SSOT）与 CF-1（Gate 2 增项与「拒四元组入清单」的边界）。
- 发现分级 P0/P1/P2；结论只许 PASS／CONDITIONAL／FAIL；关闭条件须写明「增补可关」还是「须重做」。

## ④ 产出与纪律

- verdict 落 `.tad/evidence/reviews/2026-10-04-gate2-tech-review-course-judgment-adoption.md`，含自报行（字节数＋sha256，自报行不计入被测内容口径照旧例）；落盘后自验字节数。
- 仓外禁写；零 git 写；除 verdict 外不改任何文件。
