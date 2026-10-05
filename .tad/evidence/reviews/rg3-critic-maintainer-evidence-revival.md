# Critic Review: maintainer-evidence 证据载体选型（S1 盘点＋S2 Decision Brief）

> 独立性声明：本评审由独立 session 产出（session: c6175ab3-d36c-4575-a180-495e5f7cfae4 / model: Muse Spark），评审人不是 findings 作者。
> 同 session 自评永不是有效 Critic（→ DEGRADED_WITH_APPROVAL，RG3 不得 PASS）。
> 复用 `research-challenge-prompt.md` findings 变体 + `research-quality-rubric.md`；不另起 rubric。
> 判据认 `.tad/gates/research-gate-canonical-checklist.md` RG3 节原件四项；被审产物：S1 summary＋manifest、S2 Brief（均只读未改）。
> 独立性载体（AC7）：本会话标识 c6175ab3-d36c-4575-a180-495e5f7cfae4；S1 执行者 449e8e64-b7e3-44e1-8097-9dc03d8b9cb6（summary 第 4 行在盘可查）；S2 执行者 208ee03a-98d3-4065-b1fc-5ca7ab3b40c8（Brief 头部在盘可查）——三者互不相同。**C-T4 终核：通过**（三方会话标识均在盘、互异；本步 verdict 侧比对成立，C-T4 全关闭条件满足）。

## Source 抽查

抽查方法：Critic 本会话独立实跑（git 只读＋盘上直读），不转述 PM/执行者数字。manifest 抽 6 行覆盖四类＋CJK，逐行回盘验存在性、字节数与 sha 比对；Brief 抽 3 组数字断言回 S1 summary 与 manifest 重算验值；另全量复跑 summary 复跑命令序列于当前盘面验 FR3 口径。

### manifest 抽查（6 行）

| Claim（manifest 行归类） | 来源（实跑命令） | 来源原文实际所说（实跑输出要点） | Verdict |
|---|---|---|---|
| `.tad/archive/.sha-manifest.txt` 归 carried，bytes=19616 | `git hash-object -- <path>` vs `git ls-tree maintainer-evidence -- <path>` | 盘上 sha `70fb0b37…` ＝ 分支 blob `70fb0b37…`，字节 19616 与行内一致 | ✅ |
| `.tad/evidence/README.md` 归 stale-content | 同上 | 盘上 `fef23ee3…` ≠ 分支 `0e454df4…`（与 summary 的 stale 样本行数值全等） | ✅ |
| `.tad/archive/by_task/COMPLETION-20260828-local-wiki-research-framework.md` 归 no-carrier，bytes=13377 | `test -f`＋`stat`＋`git ls-tree` | 盘上存在 13377 B；分支无此路径（ls-tree 空） | ✅ |
| `.tad/archive/handoffs/COMPLETION-20260427-tad-token-efficiency.md` 归 branch-only，bytes=null | `test -f`＋`git ls-tree` | 盘上不存在；分支 blob `42d3e9f7…` 在位 | ✅ |
| `.tad/evidence/maintenance/2026-06-10-…/Colin声音项目__archive.txt.gz` 归 carried（CJK 路径，C-T1 样本） | 同 carried 验法（路径经 argv 直传） | 盘上 sha `0530ca3a…` ＝ 分支 blob `0530ca3a…`；ls-tree 默认输出对该路径加引号转义，证 C-T1 伪差集机理在盘可见 | ✅ |
| `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/base-commit.txt` 归 no-carrier，bytes=41 | `test -f`＋`stat`＋`git ls-tree` | 盘上存在 41 B；分支无此路径 | ✅ |

补充全量核对（Critic 独立重算）：manifest 逐行计数 carried 4355／stale-content 5／no-carrier 8706／branch-only 16、总行 13,082，与 summary 四锚逐一全等；按类字节重算 carried 65,863,779 B／stale 18,755 B／no-carrier 46,878,109 B，与 summary 字节小计全等；manifest 内非 ASCII 路径 12 行全归 carried（与 summary CJK 节一致）。

复跑验证（FR3）：按 summary 复跑命令序列在当前盘面实跑（无剔除）：NOCARRIER=8715／STALE=5／CARRIED=4355／BRANCH_ONLY=16／A=13075。差额 +9 件 no-carrier 逐件枚举，恰为枚举时点后落盘的本链自产物 9 件（manifest、summary、S1/S2 完工说明、PM 验盘 ×2、Brief、S2/S3 激活包），与 summary 的 FR3 剔除/新增解释规则一致；交集三锚未动，分类口径稳定可复跑。

### Brief 数字断言抽查（3 组，回 S1 summary 验值）

| Claim（Brief 出处） | 来源 | 来源原文实际所说 | Verdict |
|---|---|---|---|
| 影响面基线：四锚 8706／5／4355／16、盘上两树 13,066 件、三类字节量（Brief 首部＋影响面基线段） | S1 summary 锚行与字节小计；Critic manifest 重算（见上） | summary 锚行 TOTAL_NOCARRIER=8706 等四值；重算全等；8706+5+4355=13066 | ✅ |
| 案二/案三「关键目录 no-carrier 合计约 388 件、约 1.96 MB」（reviews 256、designs 20、completions 4、pm 101、gate4 1、activation-packages 5、decisions 1） | S1 summary 分类计数表；Critic 按 manifest 子目录重算 | 七目录逐项全等，合计 388 件；字节重算 1,960,024 B ≈ 1.96 MB；同段 yolo 占比 7,737/8,706=88.9%、40,078,026/46,878,109=85.5% 复算成立 | ✅ |
| 案一盘上证据：分支尖 8713ea4e 停于 2026-09-06、本地与 origin 跟踪引用同尖、主仓两树 tracked 3 件、无现存同步脚本（三处 grep 零命中） | Critic 实跑 `git log -1`／`git rev-parse` 双查／`git ls-files`／grep 三处；另 `git ls-remote origin maintainer-evidence` 实时核对 | 尖 8713ea4e（2026-09-06，提交信息含 “sync 134 post-phase4 evidence and archive records”）；双尖全等且 ls-remote 远端真身同尖；tracked 恰 3 件且路径与 Brief 列名逐一相同；grep 零命中 | ✅ |

附核：Brief 引 F-18 原文（30.19 MB vs 4.54 MB、evidence 65.49 MB、ZERO_TOUCH、tarball 快照）与 EPIC SC3（两树 `git ls-files`＝0、基线 31,659,251 B、达成 8.70 MB）经 Critic 直读 AUDIT-20260816 F-18 行与 EPIC-20260816 Phase 4/SC3 行，逐值相符；推荐依据 4 引 principles「单人 CLI 优先简单软机制」在 `.tad/project-knowledge/principles.md` 第 38–40 行有原件支撑（转述略松，实质成立）。

## 反例搜寻

搜寻路径：① 以 Brief 推荐依据五条为靶逐条构造反驳；② 回盘实查 Brief 自报的未知项（ls-remote、branch-only 引用面）；③ 对照 F-18/SC3 原件与 R1 例外事实查相容性表述是否过期；④ 以 S1 分布数据（yolo 88.9%）反推案三是否被低估。逐条判定：

1. **「分支可达性被高估」**：carried+stale 仅 4,360/13,066（约三分之一），三分之二证据连分支都没有，案一的「续接」叙事掩盖了主体是新建同步。——**部分成立、不推翻推荐**：事实成立，但 Brief 首部即明示该比例与 8,706 件补同步量，「续接而非重建」一句仅针对分支存量有效性（4,355 件逐字节相同），未据此低估成本。
2. **「origin 他端状态未实查，分支可能在他端已分叉/被弃」**（Brief 未知项 2）：——**不成立**。Critic 本步 `git ls-remote origin maintainer-evidence` 实查远端真身＝8713ea4e，与本地同尖；未知项 2 于 S3 实查关闭（Brief 将其如实列为未知而非冒充已查，口径诚实）。
3. **「看守防不住再停摆」**：四锚复算是事后侦测而非事前强制，且 Brief 未给阈值数值与复算责任人/周期，「唯一已被实证的失效模式可用看守补上」属过度断言。——**部分成立（本评审最强反例）**：侦测≠预防成立，看守规格（阈值、周期、责任人）确未在 Brief 内定死；但 Brief 未知项 6 已自认「执行纪律不可预先验证、看守只能事后发现」，且停摆由静默变显性后，失效代价形态已改变。不断言推翻，但构成下方未解决弱点 1，须在 S4 裁定/执行链设计时补死，不许以「已落看守」含糊带过。
4. **「完全相容是过去时」**：SC3 的 0 已被 R1 单批例外突破（tracked 3 件），F-18 边界实际已破，案一的相容性优势被高估。——**不成立**：3 件系经 Gate 2 合并裁定的显式单批例外，边界的治理机制本身完好；Brief 在案二节如实披露该事实，PM 验盘亦独立实查属实；「常态化」与「逐次裁定例外」的区分正是 Brief 的论证核心，未被偷换。
5. **「案三被低估」**：影响面天然双峰（yolo 独占 88.9%）本是案三最强事实，目录级默认分级可自动定路，「两路缝隙」被夸大；而关键件主仓直读的收益恰被未知项 1 悬置，推荐在证据缺口上偏向了案一。——**不成立**：案一单路同样全量覆盖批量件，案三相对案一的增量只有关键件直读便利（即未知项 1 的未量化收益），成本却是判据修订＋双机制运维；Brief 的置信度已降为「中高」并写明 usage log 攒出高频直读证据时重议，取舍与证据状态匹配。
6. **「覆盖完整≠价值完整」**：8,706 件中批量过程件可能大半无长期保留价值，全量入分支是把保留决策偷换成全量保留。——**部分成立、不属本链缺口**：HANDOFF §3.3 scope-out 明示只盘载体有无、不审证据对错；且 Q4 迁移形态已给「经裁定弃置」出口，保留裁定属执行链。本链口径内不构成缺口，记为执行链提醒。

## 缺口分析

决策问题本身：Brief 首行逐字复述 HANDOFF §3.3 决策问题，推荐直接对答其三案取舍，**未被偷换**。

| 子问题 | 对答情况 | Critic 判定 |
|---|---|---|
| Q1 影响面（逐件是谁、无载体/过期各多少） | S1 四锚＋逐件 manifest＋分类计数表＋stale 全量清单 5 件＋日期桶分布 | 答全。Critic 复算与 6 行抽查全等 |
| Q2 载体机制（如何保证新证据自动有载体） | 三案机制描述逐案对答 | 已答，但案一的保证是「收口固定步（流程）＋四锚复算（侦测）」，非机械自动；看守阈值/周期/责任人未定——深度缺口在执行规格，不在比较结论（见未解决弱点 1） |
| Q3 相容性（F-18 与单人运维） | 三案逐案对 F-18 原文/SC3 判据与运维负担作答，Critic 直读原件逐值核对相符 | 答全 |
| Q4 迁移代价（清单如何转执行链输入） | 专节给出三队分法、执行前新鲜度复算、逐件销账字段、案二/三附加列 | 答到输入形态（符合 §3.4「只到输入形态」边界）；其中「登记册由 PM 在执行链设计时生成」一句已轻触执行链设计，Brief 自行标注归属，未冒充本链执行，可接受 |

悬空项：无整条未答问题。未知项 6 条均由 Brief 自行声明，其中未知项 2 已于本步实查关闭（ls-remote 同尖）；未知项 1（关键件直读频率）为推荐的最大证据缺口，Brief 已写明重议条件，属诚实悬置而非遗漏。

## Ratings
ADEQUATE
正文分析：被审两件的全部载重数字经 Critic 独立重算/抽查无一不符，来源全为仓内原件与盘上实测（Tier-1），决策问题与 Q1–Q4 逐条有答，推荐的取舍逻辑与其证据状态匹配（置信度中高＋重议条件）。未给 STRONG 的原因：推荐案的核心防线（新鲜度看守）只有形态、没有阈值/周期/责任人的执行规格，且推荐所依赖的关键前提（关键件直读频率低）目前无数据——结论可采纳，但不是免补强即可直接执行的完成度。

## Quality Rubric
引用 `research-quality-rubric.md`（4 个评分维 + 效率 advisory）；不新建 rubric。

- citation_accuracy = 1.0：载重断言均有 SOURCES 表回指，Critic 抽验的引用（四锚、F-18、SC3、principles）逐一与原件相符。
- factual_accuracy = 1.0：全部重算数字全等，相容性判定与 SC3 原文一致，无编造数值或过度外推（分支尖提交信息转述略去 “chore(evidence):” 前缀，不影响实质）。
- completeness = 0.5：Q1–Q4 均有着落，但 Q2 对推荐案的「自动有载体」保证深度不足（流程＋侦测、看守规格未定），按覆盖深度锚取 0.5。
- source_quality = 1.0：全部载重断言由 Tier-1 一手来源支撑（仓内原件直读＋盘上实测），无 Tier-2/3 依赖。
- overall = mean(1.0, 1.0, 0.5, 1.0) = 0.875 ≥ 0.6 → OK（两准确维均 ≥0.5，不触发 floor 规则）。
- efficiency（advisory）：信号密度高；案二/案三的盘上证据节较案一薄，但与比较所需相称，无注水段落。

## Verdict
PASS — S1 盘点与 S2 Brief 的全部载重断言经独立复算与抽查成立，推荐案一的论证链完整、未知项诚实声明，RG3 四项判据（Source 抽查／最强反例搜寻／Charter 缺口分析／Verdict＋独立性载体）满足，链可进 S4 由 PM 裁定采纳与否。

## 未解决弱点
1. **看守规格未定死**：案一的新鲜度看守缺阈值数值、复算周期与责任人。处置要求（咨询性，随 S4/执行链落地，非本 verdict 的 PASS 条件）：PM 在 S4 裁定或恢复执行链设计中明定三项，并把看守复算结果的落盘位置写进执行链 HANDOFF；算改完的标准＝执行链设计件中出现阈值、周期、责任人三项原文。
2. **推荐前提待数据**：未知项 1（关键件直读频率）只能等 usage log 积累后重议，Brief 已写明重议条件；S4 收口时 PM 宜把该重议条件一并记入裁定留痕。
3. branch-only 16 件与 gitlink 1 件的内容价值未审（本链 scope-out 内），执行链开跑前须按 Q4 形态逐件给保留/弃置意见（Brief 未知项 4/5 已列）。
