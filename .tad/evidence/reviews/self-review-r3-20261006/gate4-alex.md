# Gate 4 验收 — TAD 本体自查批 R3（补充件三改法落地）

- 验收席：Alex（Solution Lead），独立会话，未参与本批设计、实施与 Gate 2/3 双审
- 被验对象：TICKET-20261006-self-review-r3 全批——HANDOFF 正本＋SUPPLEMENT-1＋SUPPLEMENT-2、实施提交 `4ad330e1`/`0099fbc0`、COMPLETION（补落后全件）、Gate 2/3 四评审件、两 PM 裁定件、组 2 实验全套
- 判据：`.tad/gates/gate-canonical-checklist.md` Gate 4 节；规程 `.tad/tasks/gate-execution.md` Gate 4 节；票 Done 标准为终判据
- 验收法：不采信被审方自报——活仓终态、冻结哈希、写集、台账行数均由本席从盘面重算（见 §2.2）；COMPLETION 补落三处逐项在盘核对（见 §1）
- 日期：2026-10-06

## Verdict：PASS

全批 Done 各项齐备，Gate 链完整，无未决 post-implementation 阻塞；Gate 3 CODE 唯一条件 F-1 经本席定点核对关闭（§1）。借 4 终裁建议独立成节（§4）：**建议立项，范围限定四条**，终裁权在 PM。

---

## 激活自报

- 激活壳：`~/workspace/skills/tad-alex/SKILL.md` 全文已读，按其激活协议在目标仓 $REPO = /home/hatch/workspace/yun-sync/TAD 执行；Step 0 已断言票文件绝对路径实存（3,244 B）。
- 实际读过的原件（逐件）：`AGENTS.md`（全文）；`.tad/project-knowledge/principles.md`（全文）；`.tad/project-knowledge/patterns/_index.md`（全文）；`.tad/brain-index.md`（路由段）；`.tad/tasks/gate-execution.md`（Gate 4 节）；`.tad/gates/gate-canonical-checklist.md`（Gate 4 节为本步判据 SSOT）。
- patterns 选中 3 条（经 _index/brain-index 路由命中，本步以其纪律执行）：Gate Design（claims-need-carriers、验证完整性——支撑 F-1 载体核对口径）、AC Verification（dry-run 与逐项断言——支撑活仓复算）、Memory and Learning（knowledge assessment 与 D35 记账）。
- 被验面读取：票本体、HANDOFF 正本（82,771 B）＋增补一（10,523 B）＋增补二（12,355 B）、Gate 2 fit（PASS）/tech（CONDITIONAL）两评审件、PM 两裁定件（Gate 2 合并裁定、AC-G1-7 裁定）、Gate 3 CODE（17,714 B）/SAFETY（11,840 B）两评审件、COMPLETION 补落后全件（14,357 B）、组 2 experiment-report（6,174 B）、补充件二判断正本＋补充件三追记。
- 发现的冲突：无任务书与仓内原件的冲突。被验面内部的自报/盘面差异均已在链内处置并在本件复核（F-1 载体截断，见 §1；AC-G1-7 期望冲突，见 §3）。

## §1 F-1 定点核对（Gate 3 CODE 条件）——关闭，CODE 转 PASS

CODE 关闭条件三项，本席逐项在盘核对（COMPLETION 现件 14,357 B，与 PM 验值一致）：

| 条件 | 在盘核对 | 结论 |
|---|---|---|
| (i) AC-X-1 行证据格补全＋「写集分开列」节（含 base 哈希） | AC-X-1 行在册，证据列含两实施提交完整哈希 `4ad330e1a693…`、`0099fbc0342…`；写集分开列节在册：base `26637423bd3ba7a79e21b0de8ded856dbc8ce464` 明记，两实施提交分开列（4 件＋1 件），链务四提交单独披露。本席以 git 独立复算：两提交与 base 均实存，`git show --name-only` 并集逐字＝ {runtime-freshness-verify.sh、state-surface-check.sh、runtime-compat/cursor.md、runtime-compat/opencode.md、AGENTS.md}，与分开列及 §7 五件集全等 | ✅ |
| (ii) AC-X-2 整行（含 Verified Output） | AC-X-2 行在册：`cat .tad/version.txt` 输出 `3.2.0`、未升版、version.txt 不在两实施提交内。本席复算 version.txt 现值＝`3.2.0`，且写集并集不含 version.txt | ✅ |
| (iii) Knowledge Assessment 节三条全文（含观察 1） | 「📖 Knowledge Assessment」节在册三条：观察 1（AC-G3-2 读法依赖，含 F-2 全文转录与注记判定段）、观察 2（语料布局与清单探针）、观察 3（drawer 判别词与召回瓶颈）；头部 KA 表与节内判读一致（均为既有 patterns 当批实例、不新立 pattern、不 skillify） | ✅ |
| 截断标记零残留 | 本席 `grep -c "truncated"` 于 COMPLETION ＝ **0**；全文通读无残行 | ✅ |
| 头部 verdict 记法 | frontmatter `gate3_verdict: pass` 已回填，AC 表后注记明写双审终值与「待 PM／Gate 4 定点核对后生效」——本件即该定点核对，核对通过，记法生效 | ✅ |

**结论：Gate 3 CODE 条件 F-1 关闭，CODE verdict 转 PASS。** 至此 Gate 3 双审终值＝CODE PASS＋SAFETY PASS，无条件遗留（F-2 为 advisory 不升级，CODE 已判读，本席同意；其顺手改形建议记 §5 残项面备查）。

## §2 全批终判（对票 Done 逐项）

### 2.1 Done 五项

| # | 票 Done 项 | 判读 |
|---|---|---|
| 1 | 组 1：断言＋fixture 对全绿（或不实施判读落盘） | ✅ 实施路线成立：豁免法三层构造经 Gate 2 双审与 PM 裁定放行；check8 已入 `state-surface-check.sh`（`0099fbc0` 纯增 +95/−0，Gate 3 CODE 代码审读逐项对位）；五树＋锚缺失必跑全绿（Gate 3 双审各自亲跑复核）；本席活仓复跑 exit 0 且含 `PASS check8` 行（§2.2） |
| 2 | 组 2：实验报告＋判读 | ✅ experiment-report 在册：13 题逐题表、三项指标、§4.2.4 冻结判据机械套用判读「建议立项」；盲法完整性经 SAFETY 独立复算成立（INVALID 不触发）；本席复算冻结哈希与清单 diff（§2.2）。判读终裁见 §4 |
| 3 | 组 3：两台账入 freshness 面且复跑有终值、Deferred 行已改具名 | ✅ 两台账在盘（opencode.md 数据行 10、cursor.md 数据行 9，本席计数复核）；freshness 钉死日期复跑终值 Total 31（§2.2）；AGENTS.md Known Gaps 的 C-12 已为具名条目（built 2026-10-06，含触发条件落字），C-5/C-11 维持「Deferred by reference」原行未动（本席激活读 AGENTS.md 时逐字确认） |
| 4 | Gate 4 PASS | ✅ 本件 verdict（见卷首） |
| 5 | 票 CLOSED | ⏳ 验收侧结论：**可关票**。关票与归档/推送为 PM 动作（本席任务书明禁自行关票）；票面已回写「待 PM 关票」注记（§5） |

### 2.2 活仓终态复算（本席亲跑，2026-10-06）

| 项 | 命令/方法 | 实测 | 期望 |
|---|---|---|---|
| state-surface | `bash .tad/hooks/lib/state-surface-check.sh --repo .` | exit 0；含 `PASS check8: PAIR-1 governed block carries no stale pattern contradicting the fact source`（另有登记卫生 INFO 一行，设计内行为） | exit 0＋PASS check8 在场 |
| freshness | `release-verify.sh freshness . 2026-10-06` | exit 1；`Total: 31 entries \| PASS: 29 \| WARN: 1 \| BLOCK: 1`；BLOCK/WARN 四行全属 [codex]，含 [opencode]/[cursor] 者 0 | Total 31；残差集恒为预登记 {codex context_compaction BLOCK、codex trace_evidence_capture WARN}（归 TASK-20260916／10-10 补测，未凑绿） |
| 版本 | `cat .tad/version.txt` | `3.2.0` | 3.2.0，批内不升版 |
| 实验冻结链 | `sha256sum` routing/questions/expected 三件；`diff` authority-manifest before/after | routing `c755465a1cfba4a6…`、questions `5f15be1faff20412…`、expected `04acb2a7580567b8…`，均与 build-record/run-trace 冻结值一致；manifest diff 为空（28 行） | 全等；diff 空 |
| 实验载体 | `grep -cE` 逐题行于 experiment-report | 13 | 13（Q33–Q45） |
| 写集 | git 并集复算 | 恰 §7 五件（见 §1 (i)） | 恰五件 |

gate4_delta：**无**。被审方自报数值与本席重算逐项全等；F-1 属载体缺失而非数值不符，已按 §1 补落核销，不构成 delta 条目。

### 2.3 Canonical Gate 4 四项对照

| 项 | 结论 |
|---|---|
| Functional acceptance（§9 AC 达标＋无未决阻塞） | ✅ §9.1 post-impl 19 行经 Gate 3 CODE 全量字面复跑 19/19 达期望，本席抽验活仓终态与冻结链全等（§2.2）；无未决阻塞（§3） |
| Quality evidence complete | ✅ 设计评审（Gate 2 fit＋tech）、实施评审（Gate 3 CODE＋SAFETY）四件齐在盘；性能/UX 面本批不涉（脚本与台账类改动，无 UI、无性能判据面） |
| Subagent issues resolved | ✅ P0/P1 全关（§3 逐项）；余为 advisory/观察级且各有着落（§5） |
| Knowledge Assessment complete | ✅ COMPLETION KA 三条在册（§1 (iii)）；蒸馏判读：三条均为既有 patterns（ac-verification／shell-portability／负证据纪律）的当批实例，不新立 project-knowledge 条目——本席同意 COMPLETION 判读，载体即 COMPLETION KA 节与本批评审件；D35 转写已落（§5） |

## §3 Gate 链完整性与问题关闭逐项

- 设计（Alex，HANDOFF 82,771 B＋风险卡）→ Gate 2 fit PASS／tech CONDITIONAL（P0 F-T1：两行 AC 命令不可执行；P1 F-T2：聚合粒度未写死）→ PM 合并裁定 → SUPPLEMENT-1 落 C1/C2/F-T3 三项、Gate 2 转 PASS。
- 实施 Phase 1 后 Blake 于 AC-G1-7 合规停步（AC 期望与 FR1＋基线形态冲突，F-T1 同类）→ PM 裁定采 (a) 案 → SUPPLEMENT-2 改复合形并附 dry-run 与全表同类扫描（无第二例）→ 续任 Blake 毕 Phase 2–4。
- Gate 3 CODE CONDITIONAL（唯一条件 F-1 载体截断，所缺各行实质经其独立重算成立）＋SAFETY PASS → Blake 补落 → 本席 §1 定点核对关闭。
- 开放 P0/P1：**零**。观察级在册：F-T4（豁免自指性——SAFETY ② 已结构性判读可接受，关闭）、F-2（AC-G3-2 读法依赖——维持注记级，见 §5）、F-S1（实验灵敏度——§4 计权）、F-S2（freshness 两处前存残面——§5 登记）。

## §4 借 4 判读复核与终裁建议（供 PM 终裁）

**建议：立项（限定范围）。** 论证两面并陈，不只引标题值：

**支持面（按 F-S1 计权后的真实强度）**：本轮 runner 逐题只返 1 个候选（§4.2.3 明许），故「Recall@3 8/8」的证据深度实为 @1 级——但这恰使结果更硬而非更软：冻结判据要求的是 @3 ≥6/8，而实测在最严的 @1 口径下即达 8/8（基线 @1 仅 2/8），8 题命中全部落在第 1 位，无一位靠 @3 的宽容位补入。守门面同强：无答案 5 题误报 3/5 → **0/5**，且非靠少答题换来（召回题全数作答且全中）。效度面：盲法经 SAFETY 独立复算成立（重抽 cmp 无声、三哈希跑后全同、manifest diff 空、时间链自洽），INVALID 不触发；单跑 13 题、无噪声地板复测是实情，但命中侧余量（8/8 对 4/8、误报归零）显著高于合理复跑噪声，SAFETY 已判不要求本批补跑。机制解释亦在册：基线自陈的漏检原因是旧文件级索引行缺判别词（厂商名、机制名、阈值），试验索引的 drawer 行正是补此——结果与机制解释互相印证，非孤立的数字跳变。

**限定面（立项范围四条）**：
1. **首批只覆盖 incidents 面**（唯一被试面）。patterns 面条目级粒度是并行观察项，未被本实验测过；向其他知识面推广须各自另出证据，不许以本轮结果外推立项。
2. **只立结构化文本路由**（wings/rooms/drawers 的 markdown 形态，即本轮实测形态）。向量后端不在立项范围；ChromaDB 许可核查继续挂账，若立项后有人提议引入向量后端，许可核查转为该提议的前置件。
3. **后续同类实验预登记「逐题恰返 3 候选」**（或按实返深度计分），使 @3 名实相符——F-S1 纪律，写入立项票判据面。
4. **构造纪律照试验形态冻结**：一实体一 drawer、routing 每 drawer 恰一行、行长 ≤160 字符、行内只放判别词；权威面只读、索引为盘层派生物（可再生、不得回写权威）。

正式立项另走票/Epic，本建议不构成立项本身；PM 终裁后若立项，上四条请写入立项票范围与判据。

## §5 收口记账

- **D35 knowledge-usage-log 转写**：已向 `.tad/evidence/knowledge-usage-log.jsonl` 追加 2 行（chain＝TASK-20261006-SELF-REVIEW-R3，ts 2026-10-06T22:41:24Z）——行一为设计/实施引用集（照 HANDOFF Project Knowledge 摘录节：principles、patterns/_index、ac-verification、shell-portability、memory-and-learning、runtime-adapter-instance-opencode/-cursor、brain-index），行二为 Gate 2/3/4 评审引用集（gate-design、ac-verification、handoff-design、pack-evaluation、shell-portability、gate-canonical-checklist、gate-execution）。转写源为各步在册自报与摘录，非本席新编。
- **票面状态注记**：已在票尾追加 Gate 4 状态注记（verdict PASS、F-1 关闭、借 4 建议、可关票结论、关票归 PM）。票未自行 CLOSED、HANDOFF/COMPLETION 未自行归档。
- **残项登记核对（逐项有着落，无一丢失）**：
  - F-S2 freshness 两处非 fail-closed 残面（next_review 格式坏静默跳过、表头锚不命中贡献 0 行）——gate3-safety.md F-S2 在册，建议 PM 后续票处置（改 exit 2）；均前于本批、规则表不在本批写集内，本批不动属边界内。
  - F-2 顺手改形建议（AC-G3-2 命令改自明形态）——gate3-code.md 在册，后续批次顺手项，非条件。
  - C-5/C-11——AGENTS.md Known Gaps 维持「Deferred by reference」原行，本席已逐字确认未被本批触动。
  - ChromaDB 许可核查——experiment-report Standing items 在册挂账；§4 限定面第 2 条已定其与立项的关系。
  - candidate 冻结目录去向、R3 救援备份另立票——补充件三追记 R3 输入面第 4/5 项在册，票面「不在范围」明示另行处置，非本批遗漏。
  - codex C 类 2 条（context_compaction/trace_evidence_capture）——freshness 残差集如实保留（§2.2），归开放票 TASK-20260916 与 2026-10-10 补测，本批未改日期凑绿（SAFETY ④ 已验 codex.md 本批零触碰）。
  - COMPLETION 落盘字节数自证——Gate 3 CODE F-1 附带建议（收口核对加「字节数＋章节在册」自证），属 PM 流程面，记此备 PM 采择，不作本批条件。
- **留 PM 收口动作**：关票（CLOSED）、HANDOFF＋COMPLETION 迁 `.tad/archive/`（迁档时同步回写 session-state 索引块路径，gate-execution.md 收口注记）、证据同步与 push、借 4 立项终裁。

## 收口

- Gate 4：**PASS**（无条件）。Gate 3 双审终值 CODE PASS（F-1 核销）＋SAFETY PASS；Gate 2 合并 PASS 在册。
- 本验收只读核对＋两处记账面（usage log 追加、票面注记）外，未改任何实施件/设计件/评审件正文。
