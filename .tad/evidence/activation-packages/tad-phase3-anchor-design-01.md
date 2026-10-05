# 激活包 — tad-phase3-anchor-design-01（Phase 3 批 1 · 锚链设计步：首链 HANDOFF 创建）

## 1. 角色激活

- 加载激活壳：`tad-alex`（`~/workspace/skills/tad-alex/SKILL.md`，按壳内指引进仓读原件）
- 你是：Alex（Solution Lead）——设计与 HANDOFF 创建、Gate 2 组织、Gate 4 验收
- 角色分离：Alex 不写实现代码；本步只产 HANDOFF 正本一件，不做盘点执行、不出评审结论（Gate 2 双审由后续独立会话任）

## 2. 工作定位

- 工作仓：/home/hatch/workspace/yun-sync/TAD（只写此仓）
- 依据仓（只读）：/home/hatch/workspace/yun-sync/gm
- Epic：EPIC-20261004-tad-full-implementation Phase 3（MT3 批 1）；本席 📐 TAD 为参照席、无补立链，锚链＝首链本身（台账 C-P3-4 定论操作定义）
- 本步：锚链设计——为首链 TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL 创建 HANDOFF 正本；本步无 Gate 判定，HANDOFF 随后过 Gate 2 双审（tech/fit）
- 上一步结论：程序步 (a) 普查 PM 验盘通过（self）：`.tad/evidence/phase3-census.md`（44 行，落实 14／未落实 30）＋`.tad/evidence/phase3-inflight-chains.md`（10 行）在盘
- 登记前形态（C-P3-4 定论）：本步不调 precheck、不产 stamp/claim；Gate 2 双审落盘后 PM 报 GM，GM 练关等价登记（stage→pilot-training）确认后，首链首个执行步才跑 precheck 首跑

## 3. 必读原件清单（读完逐项打勾再开工；勾选留痕随完工说明交回）

- [ ] TAD 仓 `AGENTS.md`、`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`（命中至多 3 条；建议 ac-verification）
- [ ] TAD 仓 `.tad/tasks/handoff-creation.md`（HANDOFF 创建规程原件）与 `.tad/templates/` 内 HANDOFF 模板原件
- [ ] TAD 仓 `.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`（本链立项票，全文）
- [ ] TAD 仓 `.tad/evidence/phase3-census.md` 中 D35/D36/D44 行与 `.tad/evidence/phase3-inflight-chains.md` 第 8 行（本链分流行）
- [ ] gm 仓 `.tad/active/handoffs/HANDOFF-gm-phase3.md` §4.3（verdict 路名与字段口径）、§6.2 (e)（首链程序）、设计 `.tad/evidence/designs/2026-10-04-gm-phase3-design.md` §4.3（首链选题与证据件口径）、§2.3（precheck 首跑口径）
- [ ] gm 台账 `.tad/active/epics/tad-full-implementation/phase3-rollout-ledger.md` procedure 修订第 6 条（F-2 研究轨等价收口四件全文）与 C-P3-4 定论操作定义
- [ ] TAD 仓 `.tad/gates/research-gate-canonical-checklist.md`（研究轨 RG1–RG4 判据原件）
- [ ] TAD 仓 `.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`（本链源头自查报告 P3 节）

## 4. 任务本体

- 目标（一句话）：把「maintainer-evidence 分支停摆处置」设计成一条可按研究轨完整走完的首链——先逐件盘清停摆期无 git 载体的证据影响面，再出载体方案比较与决策简报，经独立 Critic 评审后由 PM 决策收口；选定载体的实际恢复执行不在本链（另立后续链）。
- 链形态（PM 已裁，HANDOFF 须按此设计）：研究轨。tad_scope 在 HANDOFF 头五键中按研究轨口径声明并注明依据；步骤至少含：S1 影响面盘点（机械枚举：盘上 evidence/archive 树 vs maintainer-evidence 分支树差集，逐件清单＋按类/按期计数，方法可复跑）；S2 载体方案比较＋Decision Brief（至少三案：恢复分支同步／主仓例外清单常态化／第三案自拟；每案代价、风险、与 EPIC-20260816 F-18 发行瘦身意图的相容性；Brief 含 SOURCES provenance 表，给 PM 推荐案）；S3 RG3 Critic 独立评审（与执行者不同会话）；S4 收口（RG4 记录＋COMPLETION＋F-2 四件齐，见 §5）。D35 激活并入本链：S1 起在 `.tad/evidence/knowledge-usage-log.jsonl` 写 genesis 行与本链使用行（格式认原件，HANDOFF 写明字段口径，须满足 GM A7 的 handoff/chain 字段可解析要求）。
- precheck 首跑点位（HANDOFF 须写死）：S1 派发前 PM 实跑 precheck（stamp 的 pm_seat 逐字「📐 TAD」），命令/exit/claim 路径记 `.tad/evidence/phase3-first-chain.md`；首跑只在 GM 等价登记确认后执行，HANDOFF 中把「等登记确认」写成 S1 的前置条件。
- 实施依据：以 §3 原件为准；与本包冲突以原件为准并回 PM 报冲突。

## 5. 产出与证据（落盘路径逐件写死）

- 产出物 1（HANDOFF 正本）：`/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md`——按仓内 handoff-creation 规程与模板原件成文：头五键齐（task_id／tad_scope／tad_basis／step_kind／pm_seat 或规程等价字段）、文档勾选清单、Gate 2 双审记录位（留空待两路评审填）、§9.1 式 AC 表逐行带验证方法（覆盖：盘点清单完整性判据、Brief provenance 判据、RG3 独立性、F-2 四件、D35 日志行、first-chain 证据件指针行）、文件结构节列全链落点。
- 产出物 2（完工说明）：`/home/hatch/workspace/yun-sync/TAD/.tad/evidence/completions/2026-10-04-tad-phase3-anchor-design-note.md`——含 §3 打勾回执、HANDOFF 字节数与章节清单、设计裁量点清单（你替 PM 预设的每个选择逐条列明，供 PM 与 Gate 2 评审挑）、Provenance。

## 6. 纪律件

- 只写 §5 两个路径；gm 仓只读；不动 `.tad/` 本体规程与模板原件（只许引用）；不动 docs/pm 保留集与 session-state。
- 不调 precheck、不产 stamp/claim；不冒充 Gate 2 结论（双审记录位只留结构）。
- 影响面数字（约 12,014 件／约 8,500 件无载体）是票面既有数，HANDOFF 中只许作「待 S1 实测复核的先行估计」引用，不许写成已验事实。
- 同名文件绝对路径；在同步目录跑 python 带 PYTHONDONTWRITEBYTECODE=1。

## 7. PM 验收方式

- PM 逐项验：头五键齐、§9.1 文法与验证方法可执行、F-2 四件与 RG 判据引用无转写走样、S1 前置条件含等价登记确认、落点与 §5 一致；随后 PM 另派 Gate 2 双审（tech/fit 不同会话），你不自审。
- 完工回执须含：两产出路径＋字节数、HANDOFF 章节清单、裁量点一句话清单。
