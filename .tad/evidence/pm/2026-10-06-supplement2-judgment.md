# PM 判断 — 技术研究席提案补充件二（三条补短板，2026-10-06）

对象：tech-radar `consult/tad-sweep/proposal-supplement-2-shortboards.md`。三条均经本席盘上逐项验实，全部属实，逐条裁如下。

## 一、状态面说旧话两处：采纳，已当场回写

- (a) AGENTS.md 头部 Runtime status 段与同文件 Known Gaps 自相矛盾（头写 OC/Cursor 无 hooks、Known Gaps 写 P2 已实施）——属实，且此段已随 v3.2.0 刷新进全席装机。已回写：三家均 hook-enabled、残余边界 R-OC-1/R-OC-2/R-CU-1 指针入 Known Gaps。
- (b) EPIC-20261006 的 Phase Details 四段 Status 行仍 Planned——属实；且本席验盘时另发现 Phase Map 第 3 行同病（P3 收口时只回写了票与完事卡、Epic 本体漏改），一并回写。根因与 R1 的 P2 同类：收口回写面清单不全。
- 「纳入收口扫清单」采纳：publish-protocol step3e（State-Surface Closeout）已补第 4 项「散文状态面回读」——语义状态面不入脚本（脚本只查字面），收口执行者人工回读 AGENTS.md 状态段与当期 Epic/链 Status 行，不一致当场回写、漏读不许宣告完成。
- 传播注记：(a) 的回写在主线，装机侧随下一版本点刷新到达；在此之前各席 AGENTS.md 头部该段仍旧文，以 Known Gaps 段为准（两段冲突时后段为当期事实）。

## 二、借 4 设决策点：采纳，列 R3 具名输入

解冻条件已有数据（incidents 组 Recall@3 4/8 为四组最弱、无答案误报 3/5），顺延无期限确实不妥。裁：下一轮自查批（R3）具名输入「借 4 解冻评估」——以 incidents 组为试验面判一次三层索引结构对该组的召回增益，判不立项亦可，须有判读记录落盘。本判断同时把 R2 基线的粒度发现（patterns 判分只到文件级、条目级索引缺失）列为该评估的并行观察项。

## 三、C-12 具名化：采纳，列 R3 具名输入

验实：C-12（OC/Cursor 无 runtime freshness 台账）仅以「Deferred by reference」挂在 AGENTS.md Known Gaps 与 P3 范围排除注记中，无日期、无触发条件——属实。裁：R3 具名输入「C-12 台账补建评估」：为 opencode/cursor 两运行时建 runtime-compat 台账条目并纳入 freshness 校验面，或给出明示不建的判读与触发条件，二选一须落盘。C-5/C-11 性质不同（功能投影与 updater 门），维持 deferred、本次不动。

## R3 输入面汇总（至此）

借 4 解冻评估（incidents 试验面）、C-12 台账补建评估、R3 救援备份另立票（R2 组 3 评估建议）、candidate 冻结目录去向（PM 另裁，可并入 R3 设计步呈报）。R3 立项时点由 PM 排期（补测小单 2026-10-10 先行）。
