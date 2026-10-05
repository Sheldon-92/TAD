# Phase 3 在飞链判定表 — 📐 TAD（批 1 · 程序步 (a)）

- 制表：Alex（Solution Lead），step_id=`tad-phase3-census-01`，2026-10-04
- 判法：设计 §3.3 机械判法＋台账 C-T1 勘误 operative 口径——§2f 分界为闸代码硬编码固定日 **2026-10-04**；分流日期权威只认链首步 claim 的 ts；stamp `stamped_at` 仅作申诉证据；两路皆无据按新规判（fail-closed）。
- 查盘范围：`.tad/active/handoffs/` 全件、`.tad/active/` 两票、`.tad/active/session-state.md` 索引、仓内 stamp/claim 件检索（`find .tad -iname "*stamp*" -o -iname "*claim*"` 仅命中一篇无关 IDEA 件，即本仓无 stamp/claim 落盘件）。

| # | 链 | 链首步日期与据 | stamp/claim 据 | 判定 | 状态 | 备注 |
|---|---|---|---|---|---|---|
| 1 | TASK-20261004-TAD-STATE-SURFACE-CLOSEOUT（自查 R1 第一批） | 2026-10-04（HANDOFF/COMPLETION 文件名日期与 reviews 件日期） | 仓内无 stamp/claim；COMPLETION Provenance 记原生 subagent 通道 | **新规**（无据，fail-closed 归新规） | 已收口（Gate 4 PASS，2026-10-04；六笔本地提交未 push） | 与本席 (b) 登记（enabled_at 2026-10-04）同日：链与登记的先后、及无 stamp 是否合规，存疑待 GM 判（见完工说明存疑 ①） |
| 2 | hillclimb 链（EPIC-20260816 内 task4/task5） | 2026-09-29（HANDOFF 文件名日期） | 无 | **旧规**（链首步 < 2026-10-04） | 已收口（session-state 索引行：Gate 4 PASS、提交 `b78173b3`） | 其 HANDOFF/COMPLETION 件普查期间在 `.tad/active/handoffs/` 的在列情况两次查盘不一致（见完工说明存疑 ④） |
| 3 | claude-removal 链（HANDOFF-2026-09-15-claude-removal-plan） | 2026-09-15 | 无 | **旧规** | **状态不明**：Gate 3 件在盘（`reviews/2026-09-15-gate3-adjudication-claude-removal.md` 等），但 active 内无 COMPLETION，HANDOFF status 仍停 `READY_FOR_GATE2` | 子件：`HANDOFF-2026-09-15-claude-decouple-design.md` 已自标 SUPERSEDED；`HANDOFF-2026-09-15-claude-removal-plan-codex.md` 为 DRAFT 摘要（正文未落盘）。收口与否待 PM 核（存疑 ②） |
| 4 | notebooklm-deprecation 链 | 2026-09-15 | 无 | **旧规** | 已收口（`COMPLETION-20260915-notebooklm-deprecation.md` 在盘） | HANDOFF status 字段未回写，仍停 `READY_FOR_GATE2`（存疑 ③） |
| 5 | platform-adapters P1P3 链（EPIC-20260816） | 2026-09-15 | 无 | **旧规** | 已收口（COMPLETION 在盘；Gate 4 证据 2026-10-04 改终态入仓） | HANDOFF status 未回写；收口件未迁 archive（普查表 D36） |
| 6 | tad-research-mechanism 链 | 2026-09-15 | 无 | **旧规** | 已收口（`COMPLETION-20260915-tad-research-mechanism.md` 在盘） | HANDOFF status 未回写（存疑 ③） |
| 7 | EPIC-20260816 phase2-partial 链 | 2026-08-16 期 | 无 | **旧规** | 部分收口（`COMPLETION-20260816-phase2-partial-p0-fix.md` 自标 partial） | 余项由该 Epic 文件夹 session-state 与后续链承接 |
| 8 | TICKET-20261004-maintainer-evidence-branch-revival | 未开链（票 OPEN 未排期） | 无 | 不适用（无链首步） | 未开工 | 已定为本席 Phase 3 首链选题（PM 裁定），开链后按新规走 |
| 9 | TASK-20260916-CODEX-LEDGER-REVERIFY（TICKET-20260916） | 2026-09-16 立项 | 无 | **旧规**时期立项 | 挂起未收口，无 HANDOFF 在盘 | 保持开放，不得顺手虚关（PM 既定口径） |
| 10 | Phase 3 批 1 本席链（本普查步 tad-phase3-census-01 起） | 2026-10-04 | 无——C-P3-4 定论 (b) 登记前形态：不调 precheck、不产 stamp/claim | **新规链**（练关等价登记后首个 impl 步起走 precheck） | 在飞（程序步 (a) 普查） | 等价登记只辖 Phase 3 推广链派发面，不等于毕业（stage 仍 quiz-pending、graduated=false） |

附记：`.tad/active/epics/capability-builder-v1/` 与 `framework-health-repair/` 文件夹内 session-state 为上述两 Epic 的子链状态件（2026-09 期，旧规时期产物），不单列行。
