---
gate: gate2
road: fit
task_id: TASK-20261004-MAINTAINER-EVIDENCE-REVIVAL
subject_path: .tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md
subject_type: design
subject_sha256: 2680499d86bfdd62493eba1a86e2624da0bec08db1f7971131016203f2ce92db
subject_bytes: 50588
reviewed_step_id: tad-phase3-anchor-design-01
review_step_id: tad-phase3-anchor-gate2-fit-01
step_kind: review
tad_scope: na-research
pm_seat: 📐 TAD
executor_id: Alex 设计会话（step_id=tad-phase3-anchor-design-01，Muse 原生 subagent）
reviewer_role: alex
reviewer_id: Alex Gate 2 fit 独立评审会话（session c7afba9b-f6e3-4b53-9db2-0085699f5bfe）
verdict: CONDITIONAL
basis: 五项适配判据中程序合规、研究轨契约、问题适配三项 PASS；F-2 等价收口与形态适配两项主体成立但各有一条 P1 须处置（程序步序与 §6.2 字面步序的衔接留痕、Gate 2 记录位补 verdict 锚定字段），均不阻塞 Gate 2 合并裁定，处置时点写死于 conditions。
reviewed_at: 2026-10-04T21:46:43Z
evidence:
  - .tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md
  - .tad/active/handoffs/HANDOFF-2026-10-04-maintainer-evidence-revival.md
  - .tad/evidence/completions/2026-10-04-tad-phase3-anchor-design-note.md
  - .tad/evidence/pm/2026-10-04-phase3-anchor-pm-verify.md
  - .tad/gates/research-gate-canonical-checklist.md
  - .tad/evidence/phase3-census.md
  - .tad/evidence/phase3-inflight-chains.md
conditions:
  - "C1（P1-1）：HANDOFF 的步序（Gate 2 双审在登记之前、S1 precheck 在登记确认之后）与 gm HANDOFF-gm-phase3 §6.2 字面步序（(d) 补立链含 Gate 2、(e) 首链才跑 precheck）之间，靠台账 C-P3-4 操作定义的『锚链＝首链本身』（无补立链席）衔接成立；PM 报 GM 锚链证据时须显式点明此衔接依据，若 GM 要求字面步序留痕裁定，须在台账当事席节记一行后 S0 才算全关。此条件不阻塞本路 verdict 与 Gate 2 合并裁定。"
  - "C2（P1-2）：HANDOFF §Gate 2 两路记录表未含 verdict 文件的 subject 锚定字段（subject_sha256／subject_bytes）；本路 verdict 已按模板全集自带锚定，但 HANDOFF 记录位本身不可从 HANDOFF 单件复算锚。PM 回填合并裁定时，须在两路记录表各补一行：verdict 文件 sha256 与字节数（对落盘件实算）。补齐时点＝S0 precheck 首跑之前；未补齐不许进 S1。"
---

# Gate 2 FIT 评审 — maintainer-evidence 分支复活锚链（📐 TAD 首链）

## 门 1 合同锚定（FIT 评审基准）

- 本链门 1 合同载体（立项件）：`.tad/active/TICKET-20261004-maintainer-evidence-branch-revival.md`（事实节＋两项待决：载体选型、影响面逐件盘点先行）。
- 程序合同：gm 仓 `/home/hatch/workspace/yun-sync/gm/.tad/active/handoffs/HANDOFF-gm-phase3.md` §4.3（verdict 路名/字段口径）、§6.2(e)（首链程序）；gm 台账 `/home/hatch/workspace/yun-sync/gm/.tad/active/epics/tad-full-implementation/phase3-rollout-ledger.md` procedure 修订第 6 条 F-2 全文与「C-P3-4 定论」节（操作定义＋等价边界五条）；gm 设计 `/home/hatch/workspace/yun-sync/gm/.tad/evidence/designs/2026-10-04-gm-phase3-design.md` §2.3、§4.3。
- 判据 SSOT：本仓 `.tad/gates/research-gate-canonical-checklist.md`（RG1–RG4）。
- verdict 字段全集：硬拦 v2 §4.2 经 gm §4.3 指针定位至 gm 仓 `.tad/templates/local/verdict-template.md` 字段表＋`reviewed_at`；本件 frontmatter 已按该全集自查齐备（gate/road/subject_path/subject_type/subject_sha256/subject_bytes/reviewed_step_id/review_step_id/executor_id/reviewer_role/reviewer_id/verdict/basis/reviewed_at/evidence/conditions，并附 task_id/step_kind/tad_scope/pm_seat 追溯字段）。subject_sha256 与 subject_bytes 于评审当刻对 HANDOFF 实算（50,588 B 与 PM 验盘记录一致），reviewed_at ≥ subject mtime（21:40:38Z）。
- 评审方式：HANDOFF 全文、设计完工说明（11 条裁量点）、PM 验盘记录、立项票、普查 D35/D36/D44 行、在飞链第 8/10 行、RG 判据原件、gm 三件原件相关节，全部亲读；本评审为独立会话，与设计会话（executor_id 所指）及技术路评审不共享上下文。

## 结论

**CONDITIONAL** —— P0 = 0，P1 = 2。本链的程序走法、研究轨契约、问题对位三面与原件逐条对得上，设计可放行进 Gate 2 合并裁定；两条 P1 都是留痕/锚定面的补强，处置时点已写死（C1 在报 GM 时、C2 在 S0 precheck 首跑前），不要求改设计、不要求重审。

## 逐项核

### 1. 程序合规 — PASS（附 P1-1 留痕条件）

- 登记前形态对齐：C-P3-4 操作定义「登记前形态」明文——census／设计／Gate 2 评审步不调 precheck、以激活包＋任务书纪律运行、不回填造 claim。HANDOFF 的设计步与本评审步均在此形态内（设计完工说明 §4 Provenance 与 PM 验盘记录均记「未调 precheck、未产 stamp/claim」）；HANDOFF 自身未把任何登记前步写成需 precheck 的步。
- S0 三条件与定论「时点（挣得条件）」逐字对齐：定论要求登记发生在「锚链 Gate 2 双审 verdict 落盘、结论 PASS 或 CONDITIONAL 之后，该链首个 impl 步 precheck 之前」，且 📐 TAD 无补立链、锚链＝首链本身。HANDOFF §6 S0 三条件＝①双审落盘且 PASS/CONDITIONAL（CONDITIONAL 须 PM 裁定处置）②GM 等价登记确认已回（台账当事席节有登记行、stage＝pilot-training）③PM 对 S1 stamp 实跑 precheck 首跑 exit 0 且 claim 落盘；§2.3 依赖节与 §8.4 Friction 首行同口径复述，「登记确认前不许跑首个 impl 步 precheck」在设计中无例外口子；§10.1 明文禁 PM_BYPASS 绕 §2f、禁改 stamp 字段造假，与设计 §2.3 第 3 步「不许 PM_BYPASS 绕 §2f」一致。等价边界五条无一被设计触碰（零改闸、graduated 不动、窗口与审计面均留给 GM）。
- stamp 字段与 §2.3 口径一致：HANDOFF 头五键 pm_seat 逐字「📐 TAD」、tad_scope=na-research、step_kind=research、tad_basis=J1,J2；§6 S0 第 3 条 stamp 字段清单另含 handoff_path 与 prev_verdict＝Gate 2 合并裁定。本链首个 precheck 步是研究步（S1），非 full＋impl 步，故 prev_gate2_* 引用强制（WS-G 设计 §3.4 的 full＋impl 面）不适用本步，prev_verdict 取合并裁定的写法与卡面口径不冲突。
- **P1-1（→条件 C1）**：gm HANDOFF §6.2 的字面步序是 (d) 补立链先过 Gate 2、(e) 首链再跑 precheck；本席无补立链，HANDOFF 把首链自身的 Gate 2 前置到登记之前——此衔接的唯一依据是 C-P3-4 操作定义对无补立链席的锚链定义，HANDOFF §2.3 与 Epic 行已引该依据，但未在任何一件里显式写出「(d) 步对本席以首链 Gate 2 顶替」的对位句。衔接本身成立（定论原文即如此定义），缺的只是报 GM 时的一句点明。定为 P1 留痕条件，不阻塞。

### 2. F-2 等价收口适配 — PASS（主体成立，无独立 P1）

- 四件落点与台账 procedure 修订第 6 条逐件对位：件一 RG3 verdict → HANDOFF §4.6-1 `.tad/evidence/reviews/rg3-critic-maintainer-evidence-revival.md`，结论口径 PASS 或 CONDITIONAL 且 CONDITIONAL 附处置记录，与 F-2 件一原文一致；件二 Decision Brief → §4.6-2 `.tad/evidence/research/maintainer-evidence-revival/decision-brief.md`，含 SOURCES 表，对应件二「含 SOURCES provenance 表、落研究交付落点」；件三 RG4 记录 → §4.6-3 `.tad/evidence/reviews/rg4-synthesis-maintainer-evidence-revival.md`，rubric 评分＋CHECK 记录位、「CHECK 待人」不冒充，对应件三原文（含台账明文「CHECK 未完成时记『CHECK 待人』，不得冒充已过」）；件四锚行 → §4.6-4 `.tad/evidence/phase3-first-chain.md` 内字面锚 `研究轨收口:` 起始行，列件一路径与结论、件二路径、件三路径，与件四原文及 §9.1 行 7 等价判法改写一致；FR10 与 AC10 把锚行可机器查（三路径 test -f）写进了验收面，超出 F-2 最低要求，方向正确。
- 不套 Build 轨 quartet 的取舍成立：HANDOFF frontmatter 明注「研究轨链：不产 Build 轨 chain 清单；收口认 F-2 等价四件」，§11 给出理由（无代码实现面、台账已预注本席为研究轨代表、F-2 已为此形态定义等价收口），与台账「📐 TAD」节轨道归类预注（研究轨代表）及 F-2 适用席条款（「📐 TAD 的首链若以研究轨形态收口亦适用」）逐字对得上，非席位自择口径。
- 裁量点 4（RG3/RG4 无日期 slug 文件名）可接受：F-2 件一的落点口径是「席仓 `.tad/evidence/reviews/`（或该席研究证据惯例目录，须在首链证据件中注明实际落点）」——目录对、落点将在 first-chain 锚行中注明，文件名形态不在 F-2 的约束面内；slug 式使锚行与 AC grep 路径稳定，收益具体。接受，但提醒：与本仓 reviews 目录的日期前置通行式并存期间，检索这两件须认 slug 名，RG4 记录与 COMPLETION 中宜各留一行互引（建议项，不立条件）。

### 3. 研究轨契约适配（D44）— PASS

逐条对 `.tad/gates/research-gate-canonical-checklist.md` 原件核：

- RG1 四项 ↔ HANDOFF §3.3：决策问题是问题 not 题目 ✓（「哪一案代价最小」的可决策问句，且明注服务哪个决策）；够深验收线可验证 ✓（逐件全覆盖＋四锚可重算＋三案同维度＋RG3 在盘，逐条对应 §9.1 行号）；明确不查已声明 ✓（scope-out 四项成列）；Source 策略 ✓（第一来源面盘上实查、第二来源面仓内原件、不查外网并给理由）。原件 RG1 第四项另含「已有研究检查（search.py 已跑并记录）」——本链以 §2.1 先行件全查（票、R1 报告、本仓 Gate 2 合并裁定、F-18 出处）＋MQ1 搜索证据实跑记录承接，形态等价且有盘上证据，不以未跑某个脚本判缺。判定对得上。
- RG2 四项 ↔ HANDOFF §3.4：问题树 ≥3 个决策锚定子问题 ✓（Q1–Q4 各锚定 S1/S2 产出）；轮次预算＋停止规则 ✓（NFR4＋「四锚重算不一致即停」的总停止规则）；来源优先级 ✓（盘上实查＞仓内原件＞票面估计）；Phase 0c 计划挑战已有结论 — 本项的结论载体就是本次 Gate 2 双审本身：§3.4 明文「双审未落盘前本节视为未挑战，本链不开跑」，把挑战结论的落点与时序写死，处置正确（本 verdict 落盘后此项由双审记录位承接关闭）。
- RG3 四项 ↔ HANDOFF §6 S3：Source 抽查 ✓（manifest ≥5 行回盘验类、Brief ≥3 条数字断言回 summary 验值，量化到可执行）；最强反例已搜寻并记录 ✓；Charter 缺口分析 ✓（§3.3 决策问题与 Q1–Q4 逐条对答情况）；Verdict＋独立性载体 ✓（Critic 与 S1/S2 执行者不同会话、会话标识写入 verdict 件、§8.4 把同会话风险列为无替代的硬摩擦点）。判据引用方式合规：FR7 与 S3 均写「认 RG3 节，不复述」，守判据原件单点规则。
- RG4 四项 ↔ HANDOFF §6 S4＋FR8：结论先行 ✓（S2 成稿时预置、RG4 复核）；置信度＋未知项 ✓（FR6 要求 Brief 给置信度与未知项清单，RG4 复核项含之）；反方案例 ✓；Provenance 表＋human CHECK ✓——原件第四项含「Local Wiki lint.sh PASS」，本仓无对应 lint 面，HANDOFF 以 provenance 表＋CHECK 记录位承接、未假装有 lint，此为本仓形态适配而非缺项（RG4 记录模板认本仓 `.tad/templates/research-quality-rubric.md`，PM 验盘已核模板在架）。CHECK 未完成记「CHECK 待人」与 F-2 件三口径逐字一致，不冒充。

### 4. 问题适配 — PASS

- 对着票的问题设计：票的两项待决（载体选型、影响面逐件盘点先行）与 HANDOFF 的 S1→S2 顺序一一对应；票面事实（`.gitignore:122/:123` 整树忽略为 F-18 有意设计、分支尖停 2026-09-06 `8713ea4e`）在 §2.1/§2.2 以亲验基线复核入文（分支树 6,596 件、盘上两树 13,056 件为实测值）。票面估计「约 12,014／约 8,500」在 HANDOFF 中只以「票面先行估计、待 S1 实测复核」语境出现（§2.1、§10.1 数字纪律、MQ3 对照行、FR5 禁 Brief 引估计数），未被写成已验事实——此点是本链的诚实承重面，设计守住了。
- 范围守恒明示且合理：§1.3 三条「不是要做的」（不执行恢复、不补造历史、不改闸改规程）＋§7.3 明示不改清单＋AC12 机器验（.gitignore diff exit 0、分支尖复跑、写面清单对 §7），把「选定载体的实际恢复执行不在本链」从声明升为可验约束。分工合理：无逐件影响面清单先行，恢复执行无从销账（票的待决第二项本身即此要求）。
- §11 取舍说得通：研究轨 vs Build 轨的理由落在交付物性质（清单＋决策、无实施面）与台账轨道预注两条硬据上，非偏好陈述。

### 5. 形态适配 — CONDITIONAL（附 P1-2）

- 裁量点 10（Gate 2 记录位不转写 §4.2 字段全集）可接受：HANDOFF §Gate 2 节明注「字段全集以该原件为准，本节只留记录位，不转写字段表」，两路记录表含 verdict 文件路径、reviewer 会话、model、reviewed_at、verdict、P0/P1 数六位——作为 HANDOFF 内的记录位足够，且不转写正合「认原件不认转述」的架构定版（转写即失真）。评审落盘侧的全集义务由各 verdict 件自带 frontmatter 承担（本件已按模板全集自查）。
- **P1-2（→条件 C2）**：记录表六位里没有 verdict 文件的锚定位（subject_sha256／subject_bytes 或 verdict 文件自身 sha）。后果具体：Gate 2 合并裁定回填后，仅凭 HANDOFF 无法复算「被审的正是这版 HANDOFF、落盘的正是这两份 verdict」——锚链是首链 dogfooding 的样本链，此锚缺口会被后续研究轨席照抄。修法轻量且不改设计：PM 回填时在两路记录表各补 verdict 文件 sha256＋字节数一行（对落盘件实算）。定为 P1，时点写死 S0 前，不要求重审。
- 头五键与本仓惯例不冲突：五键逐字形态（task_id/tad_scope/tad_basis/step_kind/pm_seat）与 gm 批 1 开工卡及台账口径一致，PM 验盘已逐字核过；tad_scope=na-research 与头注依据（gm 设计 §4.3＋台账 F-2）成对出现，非裸值。
- 文档勾选清单形态合规：读/验/办三组与 gm 模板口径同式，「验」组把程序步 (a) 普查件、(c) 指针件、Gate 2 双审在盘三项列为链式互验项，缺填退回的纪律写在清单头。
- 裁量点 5（COMPLETION 落 `.tad/evidence/completions/`）接受：与本仓近年实物惯例一致（R1 链 COMPLETION 同落点，PM 验盘已核），且 §7.1 已把该路径写死为唯一落点，不存在双落点漂移。
- D35 并入方式与普查 D35 行口径一致：普查 D35 行记 usage log「0 B 空件、无 genesis 行、无任何使用记录、空件待激活」；HANDOFF §4.5 以 genesis 行为第一行激活、§6 S1 第一动作即写 genesis（文件非空则停下回 PM，与普查状态互为校验）、FR9 要求 genesis 1 行＋本链 usage 行 ≥2 行且全行可 JSON 解析、字段含 chain/handoff 满足 GM A7 读法——激活形态与普查所述缺口逐项对位。

## 问题清单

- P0：无（0 条）。
- P1-1：§6.2 字面步序与本链步序的衔接依据未在任何单件里显式点明（依据在台账 C-P3-4 操作定义内、成立但分散）。→ 条件 C1。
- P1-2：HANDOFF §Gate 2 记录表缺 verdict 文件锚定字段，合并裁定回填后锚不可从 HANDOFF 单件复算。→ 条件 C2。
- 建议项（不计 P 级、不立条件）：① 设计完工说明裁量点 3 的跨日改名预案与 PM 裁定一致，本路 verdict 文件名日期 2026-10-04 与落盘日同日，无需触发；② RG3/RG4 slug 名与 reviews 日期式并存，RG4 与 COMPLETION 宜互引一行（见逐项核 2）。

## 评审边界声明

本 verdict 只出自本会话亲读的原件与 HANDOFF 原文（引用均带文件与节号）；未调 precheck、未产 stamp/claim；未改 HANDOFF 或任何设计件；gm 仓全程只读。本路结论为 CONDITIONAL，Gate 2 合并裁定由 PM 汇总技术路与本路后回填 HANDOFF §Gate 2 节。
