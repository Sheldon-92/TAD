# 完工说明 — TAD 自优化 Epic 设计步（Alex，2026-10-06）

- 步名：Epic 正本设计（用户 2026-10-06 令：先设计成 Epic、再逐 Phase 执行；PM 定四 Phase 结构派本步成文）
- 交付件：`.tad/active/epics/EPIC-20261006-tad-self-optimization.md`（26,055 B，写后 `wc -c` 自验）
- 纪律自报：本步只写 Epic 正本与本说明两件；仓外零写、git 零写操作；session-state 未动（本步为 Epic 立项设计、非链内换步，Phase Map 与 Context 节已在 Epic 内就位）。

## Epic 章节在册清单（行号为落盘实测）

| 章节 | 行 |
|------|----|
| 标题＋Epic ID/Created/Owner 头 | L1 |
| Objective | L9 |
| Success Criteria（6 条） | L12 |
| Phase Map（4 Phase 表＋Phase Dependencies＋Derived Status） | L22 |
| Phase Details | L41 |
| Phase 1: 本体清账批 | L43 |
| Phase 2: 持续测量层 | L104 |
| Phase 3: 运行时适配补全 | L154 |
| Phase 4: 体量与知识复产 | L202 |
| 发版衔接（版号提议表＋链形态建议） | L248 |
| Context for Next Phase（Completed/Decisions/Known Issues/Next Phase Scope 四节齐） | L261 |
| Notes | L281 |

每 Phase 节内模板要件齐：Status／Execution／Scope（含不在范围）／Input／Output／件目表／Acceptance Criteria／Files Likely Affected／Dependencies／Notes。

## 逐 Phase 件目计数

| Phase | 件目行数 | 构成 |
|-------|---------|------|
| Phase 1 本体清账批 | 11 行（12 个点名件） | 遗留五条（1.1–1.5）＋GM 输入三件（1.6–1.8）＋提案吸收（1.9 A1 变形／1.10 B1／1.11 D3）；提案 A2 按 PM 口径并入 1.1 行内点名，不双立 |
| Phase 2 持续测量层 | 7 行 | 2.1 C1（头条）／2.2 D5（先导）／2.3 C4／2.4 C3／2.5 C6 前置口／2.6 B2（设计内评估）／2.7 C2（第二阶段，明示依赖 C1 数据） |
| Phase 3 运行时适配补全 | 5 行 | 3.1 OpenCode hooks／3.2 Cursor hooks／3.3 真机回归（承接 P4）／3.4 C5／3.5 F1（先核可声明面） |
| Phase 4 体量与知识复产 | 3 行 | 4.1 体量盘点与处置（521M 基线）／4.2 brain-index 再生成机制与周期／4.3 知识沉淀存量复产 |
| 合计 | 26 行 | — |

发版提议（仅提议，定案归 PM）：Phase 1 → patch v3.0.2；Phase 2 → minor v3.1.0；Phase 3 → minor v3.2.0；Phase 4 → patch v3.2.1（可由 PM 裁并入 Phase 3 minor 批）。跨 Phase 硬约束已写入 Phase Dependencies：件 1.3 史述面口径必须先于任何 minor 升版定案。

## 与 PM 给定结构的偏差清单

结构性偏差：**无**。Phase 划分、Epic ID、目标表述、链形态（一链一 Phase、完整 TAD 链）、发版衔接要求均照 PM 定结构成文。以下三件为件内口径澄清，非结构偏差，一并报明：

1. **Phase 1 件目行数**：PM 结构作「遗留五＋GM 三＋提案四」共 12 件，其中 A2 与遗留 1 为同一件事（PM 自注「A2 与遗留 1 合并」），故件目表以 11 行呈现、A2 在件 1.1 行内点名并入——件未减，仅行合并。
2. **Phase 4 件 4.3 单列**：PM 结构 Phase 4 作「体量瘦身＋知识索引复产」两件；出处 R1 的 P5 原文含「知识沉淀停产」半句（incidents 停 2026-06、patterns 索引停 2026-09-29），本设计将其从 4.2 中单列为 4.3 以便 AC 化（4.2 专管 brain-index 生成机制，4.3 管存量索引补齐）。若 PM 认定属增件，可并回 4.2，不影响其余结构。
3. **Phase 3 编号消歧注**：R1 所称 P1 与 AGENTS.md Known Gaps 所称 P2 为同一缺口，本 Epic 统一以 Known Gaps 编号为准，已在 Phase 3 Notes 明注，避免后续链内混引。

## 读取清单打勾回执

- [x] 薄壳 `~/workspace/skills/tad-alex/SKILL.md` → 仓内原件：仓根 `AGENTS.md`（角色与 Knowledge Ingress、Known Gaps L173 起 P2/P4 原文已读）
- [x] `.tad/project-knowledge/principles.md`（含「Measure Before Optimizing」「Single-User CLI 机械强制边界」两条与本 Epic 相关原则，已在 Phase 3 Notes 对照）
- [x] `.tad/project-knowledge/patterns/_index.md`（命中面：Gate Design／Hook Contracts／Release & Sync，未超三条全文上限——本步为 Epic 结构设计，未需展开全文）
- [x] Epic 模板原件 `.tad/templates/epic-template.md`（章节形态照模板）
- [x] 输入 1：判断正本 `.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md`（批次映射为 Phase 划分主依据）
- [x] 输入 2：完事卡 `docs/pm/open-cards/done-20261005-tad-closeout-batch.md`（遗留五条原文）
- [x] 输入 3：GM 输入登记三件（genesis／hooks.json／driftcheck，均 2026-10-05 登记件）
- [x] 输入 4：自查 R1 `.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`（P1 代码锚 L519/L1299、P5 基线 521M 与停产日期）
- [x] brain-index 路由查核：AGENTS.md L43 路由在册；索引本体新鲜度问题即件 1.9/4.2 的出处，未另展开

## 待 PM 留意（非偏差，设计内已注明的未定点）

- 件 1.1 的定案方向（改校验器口径 vs 改投影契约）留 Phase 1 设计内裁断，本 Epic 只钉「Gate 2 须收口此选择」。
- Phase 1 若干落点路径（校验器、driftcheck、存档件实指）在件目与 Files 节以「以设计核实为准」标注：本步未逐一开文件核路径，避免以未核路径污染 Epic；Phase 1 设计步须逐件核实后写入 HANDOFF。
- Phase 4 的体量降幅未预设数字：按「Measure Before Optimizing」原则，准入判据定为「盘点后定案」，Epic Success Criteria 已按此措辞。
