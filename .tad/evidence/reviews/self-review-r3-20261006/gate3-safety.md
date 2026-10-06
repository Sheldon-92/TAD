# Gate 3 SAFETY 评审 — TAD 本体自查批 R3（补充件三改法落地）

- 评审面：SAFETY（独立会话；未参与设计与实施；与 CODE 评审互不可见）
- 被审对象：实施提交 `4ad330e1`（组 3）、`0099fbc0`（组 1）、链务 `5b572bd7`；COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-self-review-r3.md`；实验全套 `.tad/evidence/self-review-r3-20261006/g2-borrow4-trial/`
- 判据：`.tad/gates/gate-canonical-checklist.md` Gate 3 节（含证据否决款）；HANDOFF §4.1.3 判读表、§4.2.3 跑题协议、§4.2.4 冻结判据
- 评审法：不采信被审方自报数字——关键值一律本席从盘面重跑/复算（重跑两支检查脚本于活仓＋六棵 fixture 树＋两棵 freshness 控制树；重抽两子集 cmp；三件冻结哈希复算；manifest diff；判分逐题对照）

## 激活自报

- 读过的仓内原件：`AGENTS.md`；`.tad/project-knowledge/principles.md`；`.tad/project-knowledge/patterns/_index.md`；`.tad/brain-index.md`（路由段）；`.tad/tasks/gate-execution.md`；`.tad/gates/gate-canonical-checklist.md` Gate 1–4 节。
- patterns 全文 3 条：Gate Design（验证完整性／claims-need-carriers）、AC Verification（fail-safe 须有 undecidable 输入面／空集真空 PASS）、Pack Evaluation（盲评逐行 provenance 核／负控判别／噪声地板）。
- brain-index 路由命中：Gate Design、AC Verification、Pack Evaluation、Runtime Adapter Checklist，与本步四审面对应。
- 与任务书冲突：无。

## Verdict：PASS

四审面全部以本席独立复算坐实，无污染信号、无静默放行、无日期粉饰。两条观察级 findings（F-S1/F-S2）不阻塞本门，处置指向 Gate 4 与后续票，见末节。

---

## ① 实验盲法完整性（组 2）——成立，§4.2.4 INVALID 不触发

**角色分离**：抽取者＝Blake 本人（HANDOFF 组 2 红线明定：Blake 只做机械抽取与判分）；builder、runner 为两个独立子会话。抽取的机械性有硬证据：build-record Section A 在册命令为两条 `grep -E … > file` 重定向（题面不进抽取者上下文）＋跑前计数先验（题集/期望集各 `grep -cE`＝13）。本席按在册命令原样重抽，两子集与冻结件 `cmp` 均无声（逐字相同）——抽取可复现、无手改。

**三件冻结哈希（本席跑后复算，与在册值逐字一致）**：
- `questions-subset-13.md` = `5f15be1faff20412ad82094a98011c81c2bf810a6723cfbd167881036c125419`
- `expected-subset-13.md` = `04acb2a7580567b817010e4da3a264754b60a6794e85fd0b49c4e7f32784368a`
- `trial-index/routing.md` = `c755465a1cfba4a6de22f16978344563a284bd4107b7ee8ae97baa34821387eb`（run-trace 记跑前冻结、判分时复验一致）

**权威面零触碰**：`authority-manifest-before.sha256` 与 `-after.sha256`（28 行）`diff` 为空（本席实跑）；抽查 brain-index.md、patterns/_index.md 两行哈希与活文件现值相同；drawers 25 件计数符，抽查 pack-collision-detection 副本与源文件 sha256 相同（builder 在册 TOTAL=25 FAIL=0）。

**盘面时间链自洽**：questions mtime 22:07Z → routing mtime 22:09Z（冻结）→ runner 22:10Z 启、22:11Z 止 → run-trace 22:11:57Z 落盘。顺序与声明一致，无跑后改索引的时序空间。

**builder/runner 读物自签逐项核**：
- builder（build-record §B.3）：实读＝仓根 AGENTS.md、incidents/_index.md、25 件 drawer 副本（其写作素材，设计明许）、自产 routing.md；声明未开 questions/expected 子集、R2 证据目录、HANDOFF 及增补——禁读清单与 §4.2.2/§4.2.3 逐项对齐。Section B 系盲追加（未读 Section A），属声明内行为。
- runner（run-trace 自签原文）：实读＝questions 子集、三检索面（brain-index → patterns/_index → routing.md，面序与 §4.2.3 一致）、仓根 AGENTS.md；声明未开语料本体、drawers/、expected 子集、build-record、R2 结果件、HANDOFF。

**runner 打开仓根 AGENTS.md 一事的判读（本席专判）**：**不触禁读面，不构成污染，INVALID 不触发。** 依据：(1) §4.2.3 runner 禁读清单为语料本体、drawers/、expected-subset、R2 结果件、build-record 五项，AGENTS.md 不在其内；(2) AGENTS.md 内容为角色与路由面，不含期望答案、题面、判据数值，无泄漏载荷；(3) 该文件在 run-trace 中逐字披露（自签＋Blake 判分注记），且声明未作检索面——返回序列全为 drawer stem，与三面检索自洽。此披露正是盲法留痕机制设计要捕获的形态：偏离协议字面的动作被记录、被判读，而非被隐藏。

**判分复算**：expected 子集 Q33–Q40 期望 stem 与 run-trace 返回逐题相同（8/8 命中且全在第 1 位）；Q41–Q45 期望无答案、返回全空（误报 0）。experiment-report 逐题表、指标行（Recall@3 8/8、误报 0、Recall@1 8/8）与两源文件复算一致；按 §4.2.4 立项建议线（≥6/8 且误报 ≤3）机械套用得「建议立项」，自洽。基线引用（4/8、误报 3/5）与 Gate 2 tech 评审对 R2 结果件的核值一致。

## ② check8 豁免防线（组 1，承接 Gate 2 tech F-T4）——防线成立

**豁免的实际形态（逐字登记）**：豁免登记在被检脚本本体 `.tad/hooks/lib/state-surface-check.sh` L336–341——常量 `C8_PAIR1_EXEMPT_1='had "no lifecycle hooks"; superseded by Epic Phase 3'`，上方注释块含登记日期（2026-10-06）与用途说明。本席计数核验：全脚本恰 1 条豁免常量（`C8_PAIR1_EXEMPT` 共 3 处出现＝1 定义＋2 使用：存在性 INFO 检查与 index() 遮蔽），恰 1 对配对（无 PAIR-2），旧文模式 3 条常量。

**登记一条豁免的动作成本与可见性**：必须编辑发版门检查脚本本体并走 git 提交＋评审链——全仓可见性最高的面之一。F-T4 的自指性担忧由此得到结构性回答：能登记者必然已持有改脚本的同一权限（同样能改模式集或检查本身），登记不新增任何权限，只新增一条带日期、带理由、diff 可见的字面行；且遮蔽只认逐字全等（awk `index()` 循环切除，不认正则、不认近似），开口宽度恰为一条字面串。此与 check4 OLD_PAT 维护点先例同构，本席同意 Gate 2 tech 的可接受判读。

**失效豁免只 INFO**：豁免串不在受治块中时只打 `INFO check8: … registration hygiene`，不改判读——本席在 pos/outside 两树日志与活仓实跑中均亲见该 INFO 与 PASS 并存，设计表（§4.1.3 末行）与实现一致。

**辖区枚举外零扫描**：check8 代码只打开一个文件（`$REPO/AGENTS.md`），文件内只抽锚定 blockquote 块与 Known Gaps 节 P2 行。负控复核（本席逐树亲跑检查脚本，非只读日志）：outside 树块外 `## Historical Notes` 节的旧文原句未被扫、exit 0；neg 树 exit 1 且恰 1 条 FAIL（check8，三模式并列点名，含跨行折行归一化后的 `no lifecycle hooks`）；undecidable 树（事实源锚缺失）exit 1 点名 `fact-source anchor missing`；anchor-missing 树 exit 1 点名 `governed surface anchor missing`；pos/exempt 两树 exit 0。六树结果与在册日志逐项相同。另：`0099fbc0` 对该脚本为纯增（+95/−0），check1–7 代码逐字未动；活仓实跑 exit 0、PASS 普查 7（check1–6＋check8）、check7 INFO（龄 0 天）。

一点设计性质记录（非 finding）：事实源在场但不含 `(implemented` 时判 PASS＋INFO（§4.1.3 判读表明定）——check8 守的是「矛盾」而非「陈旧」本身；事实源 bullet 的任何改动同走 git＋评审链，与本防线的信任基同构，接受。

## ③ freshness 校验器 fail-closed（组 3）——成立，本席亲跑复现

**改动面**：`4ad330e1` 对 `runtime-freshness-verify.sh` 为 +16 行——2 条台账路径定义、2 个缺文件守卫（exit 2）、2 个 `check_ledger` 调用；规则表逐字未动。台账清单为脚本内显式四行枚举（codex／claude-code／opencode／cursor），无 glob、无目录扫描——新台账不可能静默入面或脱面，增删必须改脚本走评审。claude-code 退休跳过（INFO、永不 exit 2）为 v3.0.0 既有设计、代码内注明，非本批新增。

**两控制树（本席亲跑复现退出码）**：
- missing-cursor 树：`ERROR: missing ledger …/cursor.md`＋`GATE: runtime-freshness exit=2`，实测 exit 2。
- malformed-date 树：opencode `entry_headless` 行 `invalid last_verified date 'not-a-date'` → exit 2（在册日志与本席复跑一致）。
- 坏日期防线不止一处：last_verified 格式正则不过 → exit 2；日期解析失败（days_between）→ exit 2；volatility 非枚举值 → exit 2；必填字段缺失 → exit 2；TODAY 格式坏 → exit 2。

**活仓终值（本席亲跑）**：exit 1，`Total: 31 entries | PASS: 29 | WARN: 1 | BLOCK: 1`——与 g3-freshness-after.log 逐字一致；31＝12（R2 终值）＋19（OC 10＋CU 9，预登记增量，本席逐台账数行核验：opencode.md 11 行含表头、cursor.md 10 行含表头）；19 条新行全 PASS。

## ④ 残差诚实面——成立，无日期粉饰

- `git log` 实测：`.tad/runtime-compat/codex.md` 最后改动为 R2 实施提交 `4b4f305a`；R3 三笔提交（4ad330e1／0099fbc0／5b572bd7）触碰 codex.md 的次数为 0／0／0。
- 两 C 类行盘面现值：context_compaction、trace_evidence_capture 的 last_verified 均仍为 **2026-08-03**（与 freshness 日志「64 days」自洽：2026-08-03 → 2026-10-06 恰 64 天），next_review 均仍 2026-09-02，status 均仍 verified_partial——与 R2 终值逐字相同，未被「顺手刷新」。
- R3 终跑的残差集与 R2 终局分段逐一相同：BLOCK 恰 {codex context_compaction}、WARN 恰 {codex trace_evidence_capture}，归属开放票 TASK-20260916 与 2026-10-10 补测——以两分支增量断言（exit 1 由预登记残差集唯一造成）如实呈报，未凑 exit 0。NFR3（禁改日期凑绿）守住。

## Findings

- **F-S1（观察，不阻塞）实验灵敏度注记**：runner 逐题只返回 1 个候选（协议明许少于 3），故本轮 Recall@3 与 Recall@1 机械重合（同为 8/8）——主指标的证据深度实为 @1 级。此事 Blake 已在 run-trace 与 experiment-report 两处自报，判读按冻结判据机械套用无误；但「建议立项」进入 Gate 4 终裁时应按此注记计权：本轮证明的是「drawer hook 判别词使正确 drawer 首位命中＋无答案题零误报」，未测出 @3 深度下的排序行为。若后续立项票再跑同类实验，建议预登记「逐题恰返回 3 候选」或按实返深度计分。另本轮为单跑 13 题、无噪声地板复测；命中侧余量（8/8 对基线 4/8）显著高于合理的复跑噪声，本席不要求本批补跑。
- **F-S2（观察，不阻塞）freshness 校验器的两处非 fail-closed 残面（均前于本批、规则表不在本批写集内）**：(a) `next_review` 列格式不设防——非空但非日期时被静默跳过逾期检查（last_verified 列则严格 exit 2）；其风险被 last_verified 龄期门（high >30 天 BLOCK）兜底，故仅为观察。(b) 台账文件在场但表头锚不命中时该台账贡献 0 行且不报错；被预登记行数总量（Total 增量断言）在批级人工核对兜底。建议 PM 在后续票中考虑：next_review 格式坏 → exit 2；表头缺失 → exit 2。本批不动，符合 HANDOFF「规则表不变」边界。

## 收口

- Gate 3 SAFETY：**PASS**。F-S1 交 Gate 4 在借 4 立项终裁时计权；F-S2 交 PM 排后续票。
- 本评审只读完成，未改任何实施件；与 CODE 评审无沟通。
