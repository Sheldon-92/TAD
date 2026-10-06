# Epic: TAD 自优化（Self-Optimization）

**Epic ID**: EPIC-20261006-tad-self-optimization
**Created**: 2026-10-06
**Owner**: Alex

---

## Objective
把 TAD 从「流程完备」推进到「口径无陈账、效果可复量、运行时全适配」的自维护体系：先清掉 v3.0.1 留下的口径与校验陈账，再建成可持续复跑的测量层，补齐 OpenCode/Cursor 两平台的 hooks 适配与真机证据，最后处理体量与知识复产。本 Epic 的全部件目均已定性（PM 判断正本、完事卡遗留、GM 输入登记、Known Gaps 与自查 R1 在册），各 Phase 只做落地设计与实施，不再重开判断。

## Success Criteria
- [ ] 四个 Phase 全部以完整 TAD 链（设计→Gate 2 双审→实施→Gate 3 双审→Gate 4）收口，Phase Map 全 ✅
- [ ] state-surface 检查全绿（含 check5 索引旧引用清零），且发版清单新增「校验器对发布源自检」与「活体回归」两项硬项、各至少实跑过一个发版批次
- [ ] 命名回归样本集 ≥3 案在盘且可一条命令复跑，其中至少一案完成过一次真实回放并留复跑记录
- [ ] OpenCode 与 Cursor 两平台各有至少一份真机全链 transcript 在盘（Known Gaps P4 关闭）
- [ ] 仓体量有逐项处置盘点表，且较 R1 基线 521M 实测下降（幅度以 Phase 4 盘点后定案为准入判据）
- [ ] brain-index 有在册的再生成机制与周期，索引年龄可由 Phase 1 所立断言读出并判读

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | 本体清账批 | ✅ 已收口 | v3.0.2 | 遗留五条＋GM 三件＋提案四件全销账；发版口径与校验面定案 |
| 2 | 持续测量层 | ✅ 已收口 | v3.1.0 | 命名回归样本集＋复跑挂 Gate 3；中断续跑验收脚本；活体回归入发版清单 |
| 3 | 运行时适配补全 | ⬚ Planned | — | OpenCode/Cursor hooks 适配落地＋两平台真机全链 transcript |
| 4 | 体量与知识复产 | ⬚ Planned | — | 521M 逐项处置盘点；brain-index 再生成机制与周期在册 |

### Phase Dependencies
顺序执行（发版节律与判据依赖使然，非全部硬依赖）：Phase 2 依赖 Phase 1（根因模板供演练记录、发版清单基座在 Phase 1 定案）；Phase 3 依赖 Phase 2（活体回归与中断续跑脚本是真机回归的判据工具）；Phase 4 仅依赖 Phase 1 所立的索引新鲜度断言（作其验收复用），与 Phase 2/3 无硬依赖，排末位系 PM 排期口径。**跨 Phase 硬约束**：Phase 1 件 1.3（minor/major 史述面口径）必须在任何 minor 升版（Phase 2 起提议）之前定案，否则 version 门在 minor/major 转硬拦、发版即红。

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: 本体清账批

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
一次清掉三类已定性陈账：v3.0.1 收口批完事卡遗留五条、GM 3.0.1 刷新批实测上报的本体输入三件、技术研究提案包经 PM 判断采纳的四件（其中 A2 并入遗留 1）。全为已定性落地活，本 Phase 只作落点设计与条文/代码定案，不新开判断。**不在范围**：下游仓的存量处置（genesis 补落、hooks.json 重刷由 GM 刷新面处理，本 Phase 只定本体侧生成与口径）；校验器与投影契约之外的 pack 体系改造；E5/E2（KA 演进）属后续自查批设计输入，不在本 Phase。

#### Input
- v3.0.1 完事卡遗留节（`docs/pm/open-cards/done-20261005-tad-closeout-batch.md`）
- GM 输入登记三件（`.tad/evidence/pm/2026-10-05-gm-input-*.md`）
- 提案判断正本（`.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md`）
- CF-3 分诊与裁定两件（`.tad/evidence/pm/2026-10-05-closeout-batch-cf3-*.md`，件 1.2/1.3 的判据前例）

#### Output
发版与校验口径全部定案成文：校验器定案且自检入发版清单；版本改面口径恒久修订落 publish 面；minor/major 史述面处置口径成文；session-state 索引旧引用清零（check5 转绿）；AC11 计数口径订正落盘；安装器初装 genesis manifest 生成＋migration 判读口径；hooks.json 存档件与生成器同式收敛＋自检语义比对口径；driftcheck (r) registry-only 形态单列且三层口径一致；发版断言含「激活读单路径实存＋生成型索引新鲜度」；证据规程入负证据纪律补强句；根因报告三段式模板在册。

#### 件目表

| # | 件目 | 出处 |
|---|------|------|
| 1.1 | 校验器漂移定案：`capability-skill.sh validate` frontmatter 键集口径与现行 26 件投影整体不一致（全数退出 2、未被任何发布规程引用）——改校验器口径或改投影契约二选一定案；定案后「校验器以发布源为正控样本自检」入发版清单（**提案 A2 并入本件**） | 完事卡遗留 1；判断正本 A2 |
| 1.2 | 版本口径恒久修订：「字面量封顶两处」作废，publish-protocol／相关模板措辞改以 Must-Version Registry 断言面＋发布前例定改面 | 完事卡遗留 2；CF-3 裁定 5 |
| 1.3 | minor/major 史述面口径：升 minor/major 时 version 门转硬拦，168 件历史叙述面的处置口径（改写边界／豁免登记形态）先行成文——本 Epic 后续 minor 升版的前置件 | 完事卡遗留 3；CF-3 裁定 6 |
| 1.4 | session-state 索引旧引用清理：state-surface check5 四项 FAIL（索引指向 B 线已迁档件）逐项清理至转绿 | 完事卡遗留 4 |
| 1.5 | 登记面计数口径订正：HANDOFF 模板 §9.1 方法文「26 对」按目录数计、实登记面 25 对（`agent-computer-interface/` 无 CAPABILITY.md），方法文订正为登记面口径 | 完事卡遗留 5 |
| 1.6 | 初装 genesis manifest：`--source` 全新初装落创世清单，升级时 migration engine 不再恒报 chain gap REJECT；设计前先盘 migration engine 的 manifest 消费面 | GM 输入登记 `2026-10-05-gm-input-migration-genesis.md` |
| 1.7 | hooks.json 排版收敛：发布源存档件改为生成器同式（紧凑单行）为
主处置；自检口径对 hooks.json 明示「语义（值序列）比对为准」作双保险 **[Gate 2 裁断注记（2026-10-06 PM 合并裁定）：方向反转——设计亲测坐实生成器 heredoc 产出为非法 JSON（jq exit 5）、存档件为合法正本，故改为 heredoc 向存档件逐字节对齐，语义比对口径不变；实施以 HANDOFF §4.7 与裁定件为准，本行原措辞作废]** | GM 输入登记 `2026-10-05-gm-input-hooks-json-format.md` |
| 1.8 | driftcheck (r) 形态单列：registry-only pack 在 driftcheck 口径里单列 (r) registry-only，与真缺件 (c) 区分；源仓断言／目标仓 driftcheck／探针 frontmatter 三层对「设计形态 vs 真缺件」的区分同口径 | GM 输入登记 `2026-10-05-gm-input-driftcheck-registry-only.md` |
| 1.9 | 路由实存＋索引新鲜度断言（A1 变形）：发版断言扩为「激活读单所列路径全部实存＋生成型索引（brain-index）新鲜度在阈内」；阈值与判读形态在设计内定（判读以索引年龄可读为准，复产机制归 Phase 4） | 判断正本 A1 |
| 1.10 | 负证据纪律判据补强（B1）：结论依赖「某事未发生」时须附正向探针实证或标注证据强度——以一句定义＋探针要求入证据规程，不新立文件 | 判断正本 B1 |
| 1.11 | 根因报告三段式模板（D3）：定因／定界／验证三段模板入 `.tad/templates/`（拟名 `root-cause-report.md`，以设计核定为准）＋规程指针一句，补「Gate FAIL 先出根因」有规矩无模板的缺口 | 判断正本 D3 |

#### Acceptance Criteria
- [ ] 11 行件目逐件关闭，每件有落盘件与判据复算记录；state-surface check1–5 全 PASS（check5 由红转绿为本 Phase 硬指标）
- [ ] 校验器定案方向成文且已实施：定案后校验器对发布源正控样本自检通过，并已写入发版清单
- [ ] 件 1.3 口径成文在盘（后续 Phase 提议 minor 升版时可直接引用，不再临时分诊）
- [ ] genesis manifest：隔离副本初装实证——初装后 manifest 在盘、随即模拟一次升级不报 chain gap REJECT
- [ ] driftcheck 三层口径一致性实证：同一 registry-only 样本在源仓断言／driftcheck／探针三面判读不矛盾（不再一面判红一面判绿）

#### Files Likely Affected
- `.tad/hooks/lib/capability-skill.sh`（MODIFY，件 1.1 若定案走改校验器路；路径以设计核实为准）
- publish-protocol／release-runbook 发布面原件（MODIFY，件 1.1/1.2/1.9；落点以设计核实为准）
- `tad.sh`（MODIFY，件 1.6 安装器 genesis 生成；件 1.7 生成关系核实）
- `.codex/hooks.json`（MODIFY，件 1.7 存档件同式收敛；以设计核实存档件实指为准）
- pack-registry-driftcheck 与 scan-packs 相邻判读面（MODIFY，件 1.8；路径以设计核实为准）
- `.tad/active/session-state.md` 及其索引面（MODIFY，件 1.4）
- HANDOFF 模板原件（MODIFY，件 1.5 §9.1 方法文）
- `.tad/tasks/evidence-collection.md`（MODIFY，件 1.10 补强句）
- `.tad/templates/root-cause-report.md`（CREATE，件 1.11；文件名以设计核定为准）
- 发版断言脚本面（MODIFY，件 1.9；与 v3.0.1 所立 state-surface／scan 断言同面扩展）

#### Dependencies
None (can execute independently)——本 Phase 是全 Epic 的起点。

#### Notes
- 件 1.1 二选一（改校验器 vs 改投影契约）是本 Phase 唯一需要设计内裁断的点，Gate 2 须就此给出明确结论，不许带 CONDITIONAL 把选择留到实施。
- 件 1.9 只立断言与判读，不做索引复产（复产机制归 Phase 4）；断言阈值定得过紧会在 Phase 4 落地前让每次发版判红，设计时须留「索引年龄可读＋超阈告警」与「硬拦」的分级口径。
- A1 的他侧副本缺失 sighting（技术研究席四方实测与本仓盘面矛盾）待跨侧复核，其结论只影响是否转 GM 同步/安装面处置，不改变件 1.9 的本体口径。

### Phase 2: 持续测量层

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
把 TAD 的质量判据从「每件事判一次」推进到「有固定样本可复量」：真实失败例固化为命名回归样本集，复跑机制挂入 Gate 3 自检；配齐中断续跑验收脚本与活体回归发版硬项；先以桌面演练实证设计假设。**不在范围**：任何训练/调参本体（C6 只取样本汇集与标签定义前置口）；失败聚类（C2）只在本 Phase 末段以 C1 实产数据为据设计，不空转先行；评测工具选型（C7 口径：先借声明式样本形态，工具须核许可证与数据出站后另议）。

#### Input
- 提案判断正本 C 组与 D5/B2/C6 各条（`.tad/evidence/pm/2026-10-06-tad-sweep-proposal-judgment.md`）
- Phase 1 产出：根因模板（演练记录载体）、发版清单基座（活体回归硬项的挂载面）
- 在库失败素材三案的原始证据链（激活失守、S6 串台、日志误判；指针由设计步逐案落实）

#### Output
命名回归样本集（固定输入／允许工具／判分规则／版本／轨迹／证据路径六要素齐）与一条命令复跑入口；复跑结果挂 Gate 3 自检的接法成文且实跑过一次；Gate 链状态图与一次中断恢复桌面演练记录；中断续跑验收脚本（隔离副本、中断—恢复核对、step_id 保留）；活体回归条目入发版清单（与 Phase 3 真机回归的衔接口径写明）；轨迹→评分前置口（样本汇集与标签定义，含「Gate PASS 不得直接当奖励信号」约束入文）；B2 变更证据试验的评估结论（采/不采及理由）；C2 失败聚类的设计（以 C1 实产数据为据）或顺延决议。

#### 件目表

| # | 件目 | 出处 |
|---|------|------|
| 2.1 | 命名回归样本集（头条）：激活失守／S6 串台／日志误判三案固化为可复跑样本，六要素齐备；规程／模型／技能变更时回放，复跑挂 Gate 3 自检 | 判断正本 C1 |
| 2.2 | 流程状态图＋中断恢复桌面演练（先导）：为一条完整 Gate 链画状态与允许转换、人工中断点、证据指针；选一次已归档任务做停—查—恢复演练并记录丢失信息 | 判断正本 D5 |
| 2.3 | 中断续跑验收脚本：隔离副本里中断—恢复核对（已执行工具、未提交编辑、重复副作用、Gate 证据），job 身份保留原 step_id | 判断正本 C4 |
| 2.4 | 活体回归入发版清单：每 runtime 至少一条活体回归 transcript 列为发版硬项；本 Phase 定清单条目与判读口径，真机执行面与 Phase 3 衔接 | 判断正本 C3；AGENTS.md Known Gaps P4 |
| 2.5 | 轨迹→评分接口前置口：样本汇集与标签定义（去标识化、人工抽查误奖、保留集不参与调参）；约束明文：Gate PASS 不得直接当奖励信号 | 判断正本 C6 |
| 2.6 | 变更 diff／checkpoint 返工证据试验（设计内评估）：与现行 Gate 3 逐值复算＋fixture 三态实证对照，评估增量是否大于成本，给采/不采结论 | 判断正本 B2 |
| 2.7 | 失败聚类与趋势行（第二阶段）：样本复跑产生数据后建失败归因聚类与跨版本趋势载体；无数据则本 Phase 只留接口定义与顺延决议 | 判断正本 C2 |

#### Acceptance Criteria
- [ ] 样本集 ≥3 案在盘，每案六要素齐，一条命令可全量复跑且产出逐案 PASS/FAIL 与证据路径
- [ ] 桌面演练记录在盘（含丢失信息清单），其结论已回写件 2.3 的脚本判据（演练不是表演，与脚本互为印证）
- [ ] 中断续跑脚本在隔离副本实跑通过：中断后恢复无重复副作用、step_id 不变、Gate 证据完整
- [ ] 发版清单含活体回归硬项且条目可判读（缺 transcript 即红的判法成文）
- [ ] 件 2.6 有成文评估结论；件 2.7 有设计或顺延决议（不许无声消失）

#### Files Likely Affected
- 回归样本集目录（CREATE，落点与命名以设计核定为准，建议置 `.tad/` 下专设目录并入索引面）
- Gate 3 自检接面（MODIFY，复跑结果挂载；落点以设计核实为准）
- 发版清单面（MODIFY，件 2.4；与 Phase 1 定案的发版清单同面续写）
- 中断续跑验收脚本（CREATE，落点以设计核定为准）
- 状态图与演练记录（CREATE，落 `.tad/evidence/` 相应面）

#### Dependencies
Phase 1（根因模板与发版清单基座）。

#### Notes
- 本 Phase 是全 Epic 唯一「能力建设」型 Phase，其余三者为清账/适配/处置型；设计时警惕把样本集做成一次性文档——判据锚在「可复跑」三字上。
- 样本素材三案的原始证据分散在各链证据面，设计步须逐案落指针，不许凭记忆重构样本（样本失真则测量层地基失真）。
- C7 工具后选纪律贯穿本 Phase：样本形态先行，任何工具引入须先过许可证与数据出站核查。

### Phase 3: 运行时适配补全

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
补齐 Known Gaps 的 P2 与 P4：OpenCode 与 Cursor 两平台的 lifecycle hooks 适配（SessionStart / PostToolUse、TAD trace emission、ask-user capture）落地，并以真机全链回归给出实跑证据；同时落运行时接入前置件（执行适配器声明清单）与派发权限声明的核查结论。**不在范围**：C-5 slash 投影、C-11 updater `--platform` gate、C-12 runtime freshness ledger（Known Gaps「Deferred by reference」三件，不在本 Phase 夹带，是否立项另议）；Codex 平台 hooks 本体（已在册，非本 Phase 对象）。

#### Input
- AGENTS.md Known Gaps 原文（仓根 L173 起：P2、P4 与 Deferred 三件的边界）
- 自查 R1 的 P1 节（`.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`：`tad.sh` L519/L1299 代码锚）
- Phase 2 产出：活体回归发版硬项口径、中断续跑验收脚本（真机回归的判据工具）

#### Output
OpenCode plugin（`.opencode/plugins/tad.ts`）与 Cursor hooks（`.cursor/hooks.json`）两适配件随安装器分发；两平台各至少一份真机全链 transcript 在盘，Known Gaps P4 关闭、P2 关闭或降为残项清单；执行适配器声明清单成文（新运行时接入前置判据）；F1 权限声明的通道可声明面核查表与定案（可声明者入派发卡/回执，不可声明者明示口径，不落空文）。

#### 件目表

| # | 件目 | 出处 |
|---|------|------|
| 3.1 | OpenCode hooks 适配：`.opencode/plugins/tad.ts` 实现 SessionStart / PostToolUse 等 lifecycle 点位、trace emission、ask-user capture，安装器分发面同步 | AGENTS.md Known Gaps P2；R1 P1 |
| 3.2 | Cursor hooks 适配：`.cursor/hooks.json` 同等点位落地，安装器分发面同步 | AGENTS.md Known Gaps P2；R1 P1 |
| 3.3 | 真机回归（承接 Phase 2 件 2.4/2.3）：两平台各跑至少一条真机全链（激活→派发→Gate 证据→收口），transcript 在盘；中断续跑脚本在至少一平台实跑 | AGENTS.md Known Gaps P4；判断正本 C3/C4 |
| 3.4 | 执行适配器声明清单（C5）：新运行时接入前逐项声明（入口、认证、扩展来源、工作区权限、状态与失败信号、证据出口），逐项映射现有 step_id／started／done 与 Gate 证据 | 判断正本 C5 |
| 3.5 | 派发权限声明（F1）：先核各通道（Codex 沙箱、Cursor、OpenCode、原生 subagent）权限可声明面，再定声明入派发卡与证据回执的形态；不可编程声明的通道明示固定口径 | 判断正本 F1 |

#### Acceptance Criteria
- [ ] 两平台适配件在盘且经安装器在隔离副本装出、点位逐项实测触发（非仅文件存在）
- [ ] 两平台真机全链 transcript 各 ≥1 份在盘，覆盖激活、派发、Gate 证据、收口四段
- [ ] Known Gaps 节更新：P2/P4 关闭或残项逐项点名（不许整节静默删除）
- [ ] 件 3.4 声明清单成文且已用两平台适配各回填一份实例（清单不是空表）
- [ ] 件 3.5 核查表在盘：每通道一行（可声明面／固定口径），定案结论成文

#### Files Likely Affected
- `.opencode/plugins/tad.ts`（CREATE）
- `.cursor/hooks.json`（CREATE）
- `tad.sh`（MODIFY，安装器分发面与平台判定）
- `.tad/codex/README.md`（MODIFY，适配状态回写；以设计核实为准）
- AGENTS.md Known Gaps 节（MODIFY，关闭/残项回写）
- 真机 transcript 证据（CREATE，落 `.tad/evidence/` 相应面）

#### Dependencies
Phase 2（活体回归口径与中断续跑脚本为真机回归判据工具）。

#### Notes
- 编号消歧：自查 R1 所称「P1」（强制力只覆盖一个平台）与 AGENTS.md Known Gaps 所称「P2」（hook adapters）指同一缺口，本 Epic 统一以 Known Gaps 编号（P2/P4）为准，R1 编号仅作出处注记。
- 真机回归依赖真实 OpenCode/Cursor 运行时可用（环境面以 infra 环境清单为准，设计步先核环境再定排法）；单用户 CLI 的强制手段边界（principles「Mechanical Enforcement Rejected on Single-User CLI」）在适配设计时必须显式对照，不许把 hooks 做成 fail-closed 拦截面。

### Phase 4: 体量与知识复产

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
处置自查 R1 的 P5：仓体量 521M 的逐项盘点与处置（历史层、实验残留、大件证据面的归档/瘦身口径逐项定），以及知识沉淀复产——brain-index 再生成机制与周期在册、incidents 与 patterns 索引的停产面复产。**不在范围**：知识条目内容本身的改写（复产只管生成机制、周期与存量索引补齐，不动条目正文）；Phase 1 已立的新鲜度断言的判读口径（本 Phase 只供生成面与之对接）。

#### Input
- 自查 R1 的 P5 节（`.tad/evidence/pm/2026-10-04-tad-self-review-r1.md`：521M 基线、incidents 停在 2026-06、`_index.md` 停在 2026-09-22、patterns 索引停在 2026-09-29、根目录多历史层并存）
- Phase 1 件 1.9 产出：索引新鲜度断言（本 Phase 生成机制的验收对接面）
- `.tad/hooks/lib/brain-index-gen.sh`（既有生成器原件，再生成机制以之为基）

#### Output
体量盘点表（顶层逐项：体积、性质、处置决议——保留/归档/删除候选逐项点名，删除类只出候选清单与口径，实际删除逐项另经确认）；瘦身实施后的体量复测值；brain-index 再生成机制（触发点、周期、责任面）成文且首轮复产完成（索引生成日期更新、内容覆盖停产期后新增知识面）；incidents 与 patterns 索引复产至当前。

#### 件目表

| # | 件目 | 出处 |
|---|------|------|
| 4.1 | 体量盘点与处置：以 521M 为基线逐顶层目录盘点（体积/性质/处置决议），历史层（supabase、experiments、spike-v3 等 R1 点名面）逐项定去向并实施可直接实施部分 | R1 P5 |
| 4.2 | brain-index 再生成机制与周期：以 `brain-index-gen.sh` 为基定生成触发点（发版收口/自查轮次）与周期，首轮复产使索引覆盖 2026-09-16 停产点之后的新增知识面，并与件 1.9 断言对接实测（年龄可读、超阈判读正确） | R1 P5；判断正本 A1 残部 |
| 4.3 | 知识沉淀存量复产：incidents 索引（停 2026-06）与 patterns 索引（停 2026-09-29）补齐至当前，复产后索引日期与盘面实存互相可核 | R1 P5 |

#### Acceptance Criteria
- [ ] 盘点表逐项有决议，无「待定」整行悬空；删除候选单独成表且未在本 Phase 擅自执行未确认删除
- [ ] 瘦身后体量复测值在盘并与盘点表可对账（下降额逐项归因）
- [ ] brain-index 生成日期为本 Phase 期内、内容抽核覆盖停产期后新增条目；再生成机制成文（触发点/周期/责任面三要素齐）
- [ ] 件 1.9 断言对复产后索引实测判读正确（新鲜→绿；人为置旧副本→告警/红，分级口径与 Phase 1 定案一致）

#### Files Likely Affected
- `.tad/brain-index.md`（REGENERATE）
- `.tad/hooks/lib/brain-index-gen.sh`（MODIFY，如生成机制需扩展；以设计核实为准）
- incidents 与 patterns 索引文件（MODIFY，存量补齐；路径以盘面为准）
- 体量盘点表与处置记录（CREATE，落 `.tad/evidence/` 相应面）
- 历史层目录（处置对象，逐项以盘点表决议为准）

#### Dependencies
Phase 1（件 1.9 新鲜度断言为件 4.2 的验收对接面）。与 Phase 2/3 无硬依赖，顺序排末位系 PM 排期口径。

#### Notes
- 本仓在同步盘（yun-sync）内：任何删除/迁移动作先核同步面影响（对端副本、冲突风险），盘点表须含同步影响一栏；删除类一律候选清单制，本 Phase 不自行执行未确认的大面删除。
- 体量处置忌讳为数字好看误删证据载体：`.tad/evidence/` 与 archive 面是多条已收口链的证据所在，处置口径须先过「证据可达性」一关（与 maintainer-evidence 载体面同源问题，设计时显式对照）。

---

## 发版衔接（版号均为提议，定案归 PM 收口；版本号只写 `.tad/version.txt` 一处）

| Phase | 建议升版 | 理由 |
|-------|---------|------|
| Phase 1 收口 | patch（提议 v3.0.2） | 口径修订＋缺陷定案＋模板新增，无新能力面；件 1.3 口径须在本 Phase 内先于任何 minor 定案 |
| Phase 2 收口 | minor（提议 v3.1.0） | 新增持续测量能力层（样本集＋复跑机制），属能力面扩展；升 minor 时按件 1.3 口径处理史述面 |
| Phase 3 收口 | minor（提议 v3.2.0） | 两平台 hooks 适配为新平台能力面补全 |
| Phase 4 收口 | patch（提议 v3.2.1） | 体量处置与索引复产，无能力面变化；如与 Phase 3 收口相邻，可由 PM 裁并入其 minor 批 |

链形态建议：一链一 Phase、每链走完整 TAD 链（Alex 设计→Gate 2 独立双审→Blake 实施→Gate 3 独立双审→Alex Gate 4→PM 提交推送）；Phase 1 件目多而杂，以一张总 HANDOFF 统辖、件目逐件 AC 化，不拆子链（拆链会让口径类件互相等待）；Phase 2/3 件内耦合紧（判据工具与被测面同链互证），同样一链一 Phase。

---

## Context for Next Phase

### Completed Work Summary
- （Epic 立项时）无 Phase 完成。立项前置已成：v3.0.1 本体收口批全链收口并 push（批尖 `c81ee528`）；技术研究提案包 v1 已经 PM 判断成正本；GM 刷新批三件本体输入已登记。

### Decisions Made So Far
- 批次结构以判断正本「吸收后的批次映射」为骨架，PM 定为四 Phase 一 Epic 逐 Phase 执行；件目归属以本 Epic Phase Map 为准，不再回提案包分组排期。
- 转 GM 分拣面（B3、D4、E 组主体、G1、G2）不入本 Epic；D6 关闭、D1/H1–H3 待核、D2 缓，均不入本 Epic。
- A2 与完事卡遗留 1 为同一件事，合并为件 1.1，不双立。

### Known Issues / Carry-forward
- A1 他侧副本缺失 sighting 与本仓盘面矛盾，待 grokbox 隧道恢复后跨侧复核（已红灯报 GM）；结论不阻塞 Phase 1 开链，只影响件 1.9 之外是否另有同步面处置。
- 件 1.1 的二选一（改校验器口径 vs 改投影契约）留 Phase 1 设计内裁断，Gate 2 须收口此选择。
- Phase 3 的真机环境可用性须在该 Phase 设计步先核（infra 环境清单），不在本 Epic 层预设。

### Next Phase Scope
Phase 1 · 本体清账批：11 行件目（见 Phase 1 件目表）逐件落点设计与 AC 化，一张总 HANDOFF 统辖，走完整 TAD 链，收口提议升 patch v3.0.2。

---

## Notes
- 本 Epic 为 TAD 本体自维护 Epic：判断权与排期在 TAD PM；GM 侧只作输入方（刷新批实测）与下游刷新执行方，不代修本体。
- 每 Phase 收口时由当链 Alex 回写本 Epic 的 Phase Map 状态与 Context for Next Phase 节（模板纪律），进度块（`docs/pm/now.md`）随换步更新。
