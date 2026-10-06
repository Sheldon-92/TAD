# TICKET-20261006-self-review-r3 — 自查批 R3（补充件三改法落地批）

- 立票：2026-10-06，TAD PM。来源：用户当面指令「采纳了就改吧」（2026-10-06 17:03 EDT）——技术研究席提案补充件三（改法版）三条改法经本席判断采纳（判断正本 `.tad/evidence/pm/2026-10-06-supplement2-judgment.md`＋追记 `2026-10-06-supplement3-judgment-addendum.md`），原排 R3 输入面，现提前成批实施。
- 范围（三组）：
  1. **状态面关键词冲突断言**：状态面检查扩一类断言——具名活状态面（首例 AGENTS.md 头部 Runtime status 段）与其事实源（Known Gaps 现行口径）出现关键词级矛盾即红；fixture 用 2026-10-06 本次原文，正负控成对。设计必须先答豁免法：历史叙述面合法引用旧文如何不误伤（参照版本分诊 live/legacy 口径立登记），答不出则本组判不实施、保留 publish-protocol step3e 第 4 项人工回读为终态（该结论同样算本组交付）。
  2. **借 4 解冻评估实验**：只读试验索引（盘层副本、不回写权威），按 mempalace wings/rooms/drawers 结构只取 incidents 组建索引，用 R2 基线同题子集（召回 8 题＋无答案 5 题）同口径复跑；判据数值在设计步落字定案、开跑前冻结（起始值：Recall@3 提升 ≥2 题且无答案误报不升 → 建议立项；否则关闭记因）。试验期不选向量后端；ChromaDB 许可核查为前置挂账、本批不解。产出：实验报告＋借 4 立项/关闭判读（PM 在 Gate 4 终裁）。
  3. **C-12 台账补建**：照 Codex 台账同构为 OpenCode、Cursor 各建一份 runtime-compat 台账（字段抄现行 codex.md），首填用 P3 落地件版本＋2026-10-06 活体 PASS 指针；两份纳入 freshness 校验面；触发条件落字（hooks 投影件变更当轮必复核该两台账）；AGENTS.md Known Gaps 的 Deferred 行改写为具名条目（C-5/C-11 维持原 deferred 写法不动）。
- 不在范围：借 4 正式立项与实现（本批只出评估判读）、ChromaDB 许可核查、candidate 目录与 R3 救援备份（仍挂账、另行处置）、升版（批内不升版，随下一版本点）。
- 链路：Alex 设计（含风险卡）→ Gate 2 双审（fit＋tech）→ PM 裁定 → Blake 实施 → Gate 3 双审 → Gate 4。证据目录 `.tad/evidence/self-review-r3-20261006/`。
- Done：三组各自交付齐（组 1 断言＋fixture 对全绿、或不实施判读落盘；组 2 实验报告＋判读；组 3 两台账入 freshness 面且复跑有终值、Deferred 行已改具名）；Gate 4 PASS；票 CLOSED。
