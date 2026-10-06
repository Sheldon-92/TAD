# Gate 2 fit 评审 — HANDOFF-2026-10-06-self-review-r3

| 项 | 内容 |
|---|---|
| 评审对象 | `/home/hatch/workspace/yun-sync/TAD/.tad/active/handoffs/HANDOFF-2026-10-06-self-review-r3.md`（82,771 B） |
| 票 | `.tad/active/TICKET-20261006-self-review-r3.md`（TICKET-20261006-self-review-r3） |
| 评审性质 | Gate 2 双审之一（fit 面：范围贴合／AC 覆盖／边界合规）；独立会话，未参与设计，与 tech 评审互不可见、未沟通 |
| 判据 | `.tad/gates/gate-canonical-checklist.md` Gate 2 节（SSOT）；评审规程 `.tad/tasks/gate-execution.md` |
| 评审方式 | 只读评审，未改被审件与任何正文 |
| 日期 | 2026-10-06 |

## Verdict：PASS

无 P0／P1 级 fit 缺陷。findings 共 5 条，全部为 INFO／建议级注记，不设核销条件（见 §6）。

---

## 1. 激活自报

按 `~/workspace/skills/tad-alex/SKILL.md` 激活协议在目标仓（$REPO＝`/home/hatch/workspace/yun-sync/TAD`）执行：

- **实际读了哪些原件（逐件路径）**：
  - `/home/hatch/workspace/yun-sync/TAD/AGENTS.md`（全文）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/principles.md`（全文）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/project-knowledge/patterns/_index.md`（全文）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/gates/gate-canonical-checklist.md`（全文，Gate 2 节为本步判据）
  - `/home/hatch/workspace/yun-sync/TAD/.tad/tasks/gate-execution.md`（全文，本步规程原件）
  - 被审件与读取清单：票本体、HANDOFF 全文、风险卡 `/home/hatch/workspace/yun-sync/TAD/.tad/evidence/self-review-r3-20261006/risk-card.md`（4,918 B）、PM 判断正本 `.tad/evidence/pm/2026-10-06-supplement2-judgment.md`＋追记 `2026-10-06-supplement3-judgment-addendum.md`、补充件三原文 `/home/hatch/workspace/yun-sync/tech-radar/consult/tad-sweep/proposal-supplement-3-howto.md`
- **patterns 选中哪几条（≤3）**：`gate-design.md`（Gate 职责与判读诚实度）、`ac-verification.md`（AC 文法、空集真空、双分支增量断言、逐项断言先例）、`handoff-design.md`（handoff 结构与范围估计）。三件均与本步（fit 审）直接命中。
- **brain-index 路由命中什么**：`.tad/brain-index.md` 已查——其节结构为 Principles／Patterns／Project Knowledge／Active Handoffs／Evidence Directories 等通用路由，对 R3 三组主题（状态面断言／召回实验／runtime-compat 台账）无专条路由命中；本步资料面由任务书读取清单直接给定，不经 brain-index 二次路由。
- **发现的冲突**：一处口径差，已按「以仓内原件（canonical SSOT）为准」处置并登记于 finding F-2（风险卡落点 vs canonical 模板注记默认路径）。另注：`gate-execution.md` 的 Gate 2 清单是旧式通用清单，与 canonical 的 SSOT 声明并存，本审判读一律以 canonical Gate 2 节为准。

## 2. 检查面 ①：票面三组范围 ↔ HANDOFF 逐组对应（无漏项、无夹带）

| 票面 | HANDOFF 对应 | 判定 |
|---|---|---|
| 组 1：具名活状态面（首例 AGENTS 头部段）与事实源关键词级矛盾即红 | §4.1 check8＋PAIR-1 配对登记（受治面＝AGENTS 头部 Runtime status 块；事实源＝Known Gaps P2 bullet） | ✅ 对应 |
| 组 1：先答豁免法，答不出则判不实施、保留 step3e 第 4 项人工回读为终态（该结论同样算交付） | §4.1.2 三层豁免法（辖区枚举／锚定抽取／逐字豁免登记）正面作答并选实施；降级路径未丢失——风险卡 ASM-1 动作预置「收缩重验仍不成立则降级不实施（票面预置结论）、报 PM 裁」，§2.1 明注 step3e 第 4 项保留不删 | ✅ 对应（含失败分支的交付路径） |
| 组 1：fixture 用本次原文、正负控成对 | §4.1.4 五树（pos／neg／exempt／outside／undecidable），旧头部块自 `git show a1c3dffd^:AGENTS.md` 机械抽取并以 sha256 冻结（P-2 定案值在册） | ✅ 对应 |
| 组 2：只读试验索引、盘层副本、不回写权威；mempalace wings/rooms/drawers；只取 incidents | §4.2.2 构造法（wing 机械映射／room 聚类／drawer 一件一档）＋索引根落在批 evidence 目录、不在权威树下；FR4＋AC-G2-2 权威面前后清单对账 | ✅ 对应 |
| 组 2：R2 同题子集（8＋5）同口径复跑；判据设计步落字、开跑前冻结；起始值 Recall@3 ≥＋2 且误报不升 | §4.2.3 三面竞争保真口径；§4.2.4 判据定案（立项线 Recall@3 ≥6/8 且误报 ≤3，与票面起始值及 PM 追记「终值由 Alex 设计定案、起始值为提案例」一致）；冻结时点＝Gate 2 PASS | ✅ 对应 |
| 组 2：试验期不选向量后端；ChromaDB 许可本批不解；产出实验报告＋判读、PM Gate 4 终裁 | §4.2.4 向量后端行＋报告末节注记；Phase 3 步骤 5；§1.3 明示立项另走票/Epic | ✅ 对应 |
| 组 2 附带：R2 基线粒度发现（patterns 条目级索引缺失）列并行观察项（补充件二判断 §二） | Phase 3 步骤 5 要求 experiment-report 末节记此观察项（只记不扩围处置） | ✅ 无漏 |
| 组 3：照 Codex 台账同构建 OC/Cursor 两台账、字段抄 codex.md | §4.3.1 列位解析契约＋11 列逐字同构；§4.3.2 逐行行集（OC 10 行／CU 9 行）逐行带出处 | ✅ 对应 |
| 组 3：首填用 P3 落地件版本＋2026-10-06 活体 PASS 指针 | §4.3.2 每行 source 列指 INS-OC/INS-CU、PROBE、TR-OC/TR-CU | ✅ 对应 |
| 组 3：纳入 freshness 校验面；触发条件落字 | §4.3.4 显式枚举扩围三处逐字改动＋缺文件 exit 2 守卫；§4.3.3 触发句三处逐字稿（两台账＋AGENTS 条目双通道） | ✅ 对应 |
| 组 3：Deferred 行改具名条目，C-5/C-11 不动 | §4.3.5 逐字改写稿（Deferred 行只删 C-12、新增 C-12 具名 bullet）＋AC-G3-5 per-term 断言锁定 | ✅ 对应 |

**不在范围核对（防夹带）**：借 4 只评估不立项（§1.3＋§4.2.4 双重明示）；不顺手刷新 codex 台账 C 类 2 条（§1.3 明示排除，freshness 以双分支增量断言处置，NFR3 禁改日期凑绿）；不动 tad.sh、`.sync-conflict` 件；不解 ChromaDB 许可；批内不升版（AC-X-2）。补充件三改法一的「头部单源化指针改造」未入本批——经核为 PM 追记的裁定边界（追记只采纳断言评估入 R3，头部回写已于补充件二阶段办完），非漏项（见 F-5）。写集内未见票面外交付物。

## 3. 检查面 ②：24 行 AC 覆盖与可判性

行数点算：P-1..P-5（5，pre-impl 基线，Verified Output 已由 Alex 实测回填）＋AC-G1-1..7（7）＋AC-G2-1..5（5）＋AC-G3-1..5（5）＋AC-X-1..2（2）＝**24 行**，与设计步登记相符。

覆盖映射（FR → AC）：FR1→G1-1＋G1-7（回归）；FR2→G1-2..G1-6（五树逐树一行）；FR3→G2-3（结构）＋G2-4（冻结与盲法留痕）＋G2-5（报告与判读）；子集派生→G2-1；FR4→G2-2；FR5→G3-1（格式与触发行逐项）＋G3-2（行数定案 10/9）；FR6→G3-3（增量恒等）＋G3-4；FR7→G3-4（缺文件／坏日期两跑均 exit 2）；FR8→G3-5（per-term 0/1/1/1）；全批边界→X-1（写集集合断言）＋X-2（版本 3.2.0）。**三组交付与各自负控全覆盖**：负控面为组 1 neg＋undecidable 两棵必红树（另 exempt/outside 两棵防误伤树）、组 3 两棵控制树、组 2 冻结哈希与禁读自签（污染侦测，G2-4）。

可判性：每行 Verification Method 均为 command／fixture／path-check 合法文法，无纯散文行（合 canonical Gate 1 文法与 Gate 3 逐行执行口径）；「在场断言」纪律落实（G1-1 要求 `PASS check8` 行在场而非只看退出码；G3-3 要求汇总行字面与新面 BLOCK/WARN 为 0，防空集真空通过）。G3-3 钉死日期复算（2026-10-06）与 §4.3.4 时限注记、§8.4 滑期摩擦项配套，可判且防滑期凑绿。

## 4. 检查面 ③：组 2「判不立项亦为合格交付」分支的 AC 判读行

**有对应判读行，分支完整。** §4.2.4 判据表三分支齐全：立项建议线（Recall@3 ≥6/8 且误报 ≤3 → 建议立项，正式立项另走票/Epic、PM Gate 4 终裁）、关闭线（其余一切结果含 5/8 → 关闭记因，须逐项写明未达哪条线）、INVALID（冻结件哈希不符或禁读路径被打开 → 判读作废、不得支持立项、本批内不许改判据重跑）。AC-G2-5 要求 experiment-report 含「判读行（建议立项／关闭记因／INVALID 三选一且与数值自洽）」，三分支逐一落到 AC 判读面；§9 汇总口径与票 Done 一致——组 2 交付＝实验报告＋判读，立项与否不是合格条件。风险卡 ASM-3 的作废动作与此一致（INVALID 记成因、重跑由 PM 另票）。

## 5. 检查面 ④：写集清单与票面边界自洽

§7.1 新建面：两份台账＋批证据目录全套产物（含 g1 五树与 runner、g3 控制树与日志、g2 试验全套 8 类件），与 §4 各组产物表逐项对得上。§7.2 修改面恰 3 件（`runtime-freshness-verify.sh`、`AGENTS.md`、`.tad/hooks/lib/state-surface-check.sh`），与 §4.3.4／§4.3.5／§4.1.1 的改动声明一一对应。零改动断言明列 tad.sh、codex.md、claude-code.md、release-verify.sh、publish-protocol、`.tad/version.txt`、R2 基线四件、incidents 语料与两索引面；AC-X-1 以 `git diff` 集合断言机械封闭（五件全在且无多余，base 哈希记 COMPLETION）。组 2 写集不出批 evidence 目录（NFR4），试验索引为盘层副本、不回写权威（FR4＋AC-G2-2 对账），与票面边界自洽。§4.4 回滚按组分立、提交顺序（组 3→组 1→组 2）与 §6 Phase 顺序一致；组 2 无主仓提交时记 NONE 的处置与 AC-X-1 的五件构成（G3 四件＋G1 一件）不冲突。

## 6. 检查面 ⑤：风险卡触发项与 dogfood 声明

风险卡（`.tad/evidence/self-review-r3-20261006/risk-card.md`）§0 逐项核对 canonical 触发集，命中两项：发布门判定脚本改动（state-surface-check.sh、runtime-freshness-verify.sh，按 L3/生产面论）＋仓根 AGENTS.md 改动（全席装机源）；未命中项逐项给了理由（单仓、无新连接器/依赖、全改动 git 可回滚、无密钥/公网/金额）。与 HANDOFF Gate 2 节 Risk card 行的登记一致。证伪式假设表 ASM-1..3 三列齐（假设句＋证伪信号＋停/作废动作），且动作与 HANDOFF 设计互锁（ASM-1 降级路径＝票面预置结论；ASM-2 禁改日期凑绿＝NFR3；ASM-3 作废口径＝§4.2.4 INVALID）；REQ4 以 AC 机械覆盖不占假设表额度，处置合理。dogfood 声明在风险卡 §0 成段（本批即风险卡机制当批 dogfood、fixture 自指取事故原文），与本批设计互证；票面未要求 dogfood 字样，此声明为设计步按批惯例自加，不构成对应缺口。gc 专项显式声明不适用（非遗漏），合 gc 预检纪律。

## 7. Findings（5 条，全部 INFO／建议级，无核销条件）

| # | 级别 | 内容 | 指针 |
|---|---|---|---|
| F-1 | INFO | §1.3「不是要做的」未复述票面排除项中的 candidate 冻结目录与 R3 救援备份两项；写集已由 §7＋NFR4＋AC-X-1 机械封闭，不构成越界通道，仅复述完整性瑕疵 | HANDOFF §1.3 vs 票「不在范围」段 |
| F-2 | INFO | 风险卡落点为批证据目录，与 canonical Gate 2 节注记的模板默认落点（`.tad/evidence/risk-cards/risk-<task_id>.md`）不同；票面明定本批证据目录、且 HANDOFF 与风险卡全链指针一致无双义，PM 裁定时知悉即可 | canonical Gate 2「Risk card」项；票「证据目录」行 |
| F-3 | 建议 | FR2 的「runner 退出 0」在 AC 层由五树日志期望等价覆盖、无独立断言行；建议 Gate 3 时 COMPLETION 按 §8.6 回填 runner 汇总退出码一行即闭合（执行注记，非设计缺陷） | HANDOFF §3.1 FR2；§9.1 AC-G1-2..6 |
| F-4 | INFO | AC-G2-5 行本身只验判读行在场与逐题行计数，判读与数值的自洽复算显式留 Gate 4——与 canonical Gate 4「从盘上重算」纪律一致，可接受 | HANDOFF §9.1 AC-G2-5 |
| F-5 | INFO | 补充件三改法一的「头部单源化」未入本批，经核属 PM 追记裁定边界（只采纳断言评估入 R3），非设计漏项；记录于此防后续误读 | PM 追记 §一；补充件三 §一.3 |

## 8. Canonical Gate 2 其余项（fit 面顺带核对）

- Expert review complete (min 2)：双审（fit＋tech）组织中，HANDOFF §9.2 如实登记 PENDING、未自审自批——本件即其一。
- Architecture／Components／Functions verified／Data flow mapped：§4 组件规格到文件与行集、§5 MQ2 函数行号清单、MQ3 列位对照表均有实物支撑（实现正确性归 tech 审）。
- Load points declared：§4.5 逐项登记装载面与触发时点，含 step3e 第 4 项保留不删的明示。
- §1.4 卸载记录三项诚实登记（含任务书所列 R2 基线路径与盘上实存不符的冲突，按实存件为准）——与盘面相符，认可其处置。

**结论**：设计答全票面三组、边界无越界、AC 覆盖完整可判、组 2 关闭/INVALID 分支有判读行、风险卡对应成立。Gate 2 fit 面 **PASS**，建议 PM 结合 tech 评审裁定。
