# Gate 2 Tech Review — Epic Phase 2「持续测量层」设计（HANDOFF-2026-10-06-epic-p2-measurement）

- 评审路：tech（独立会话）；日期：2026-10-06
- 对象：`.tad/active/handoffs/HANDOFF-2026-10-06-epic-p2-measurement.md`
- 开审对锚：实测 76,370 B／sha256 `ff8eda17a1131e339b04e6cb59afc00f575d8e4472e6ad13ec631933a40b071a`，与送审锚逐字全等
- PM 裁断件 `.tad/evidence/pm/2026-10-06-epic-p2-design-rulings.md` 已读，D-1–D-4 不重议
- 审法：§2 基线锚逐项只读复算（未跑会写日志的看守脚本本体，按其源码口径独立复算四锚）；sync 脚本与 migration 子命令、引擎 resolve 段逐行读源核对；minor detect-only 原样实跑

## 结论：CONDITIONAL（P0＝0／P1＝2／P2＝3）

两处 P1 均为件 2.0 §4.0 的文本口径缺陷，修订为一行级改动、不动机制与 AC 编号；修订落盘后本路无须重审全文，PM 定点核销账即可。其余八件的技术前提全部亲测成立。

## §2 基线锚复算结果（MQ-1–MQ-11）

- **MQ-1 成立**：version.txt＝3.0.2；POINTER 首行逐字 `# TAD 常驻指针 — 📐 TAD`；git 未跟踪（ls-files 0）；`TAD_TOP_DENY` 在 tad.sh L588（值 sync-registry.yaml／brain-index.md），POINTER 不在内、随顶层文件派生传播，与 GM 登记实况相符。
- **MQ-2 成立（设计时点值）**：按看守脚本源码口径独立复算——STALE＝2、CARRIED＝13072、BRANCH_ONLY＝9、分支尖 `459ab78f…`、TIP_AGE_DAYS＝1，四锚中三项与设计值逐值全等，STALE 2 件点名与实盘逐一对上（`.tad/evidence/knowledge-usage-log.jsonl`、`.tad/evidence/pm/downstream-versions.md`）。NOCARRIER 复算时点为 151（设计时点 147）：增量 +4 全为设计落盘后本批自产件（completions +1＝本 Phase 设计说明、pm +3＝件 2.8 登记件／件 2.9 定性件／D 裁断件），另有 1 件为目录构成归类边界差（archive 内 closeout-batch 命名件）、非实差。此漂移正是 §4.0 判据锚所述形态，Blake Phase 0 另行冻结，不构成锚误。
- **MQ-3 成立（逐值全等）**：清单实测 13,130 行；类别×outcome 计数与 MQ-3 六行逐一全等（no-carrier/synced 8714、carried/pending 4355、no-carrier/embedded-repo 40、branch-only/kept 9、branch-only/dropped 7、stale-content/synced 5）；按脚本源码队列口径（class∈{no-carrier, stale-content}∧outcome=pending）现队列＝0。谱系亲验：`8713ea4e` 为现尖祖先、区间恰 1 笔提交且标题为脚本自产形态——默认调用（禁 `--expect-base`）成立。
- **MQ-4 成立**：publish-protocol 步序实测 step3→3b→3c→3c2→3c3→3d→3e→step4（行号 75/84/98/144/164/178/211/233），step3f 挂 3e 与 step4 之间位置可照行；publish-ops §2 现至 §2.5（§2.6 为空号）、§5 标题与行号（L163）逐字对上、§3/§3.1 在盘。
- **MQ-5 成立（原样实跑）**：`release-verify.sh version <repo> 3.1.0 3.0.2` 实跑得 25 hits／20 文件，与设计时基线逐值全等。
- **MQ-6 成立**：仓内三案提及仅判断正本（pm/tasks 面 grep 坐实）；仓外指针逐个在盘——notes-02 第 1 条（其 L13 三案定性原文）、notes-05 第 7 条（批量回放样本格式）、proposal-package 的 B1/C1/C4/D5 原文均与设计引用对位；C4 原文的四项核对＋step_id 保留即件 2.3 断言集来源，对位无误。
- **MQ-7 成立（亲测）**：以 git 跟踪面 grep `📐`，除 POINTER 本体（未跟踪）外仅 `.agents/skills/tad/SKILL.md:159`「📐 **Adaptive**」一处，与种子亲测逐字全等——同病扫描须带自指位置判读的设计前提成立。
- **MQ-8 成立**：gate-execution Gate 3 节起于 L150。
- **MQ-9 成立**：`.tad/templates/root-cause-report.md` 在盘（1,549 B）。
- **MQ-10 成立**：Phase 1 链 HANDOFF（archive）／COMPLETION／五份 gate 评审件逐个在盘。
- **MQ-11 成立**：`.tad/migrations/` 最新 hop 为 `2.43.0-to-2.43.1.yaml`，3.x 三段全缺；前例字段集实测 schema_version/from/to/generated_by/note/delete/rename，from/to 带引号（HA-3 锚假设与实盘一致）。release-verify migration 子命令 case 起于 L361（设计记 L360 为其注释头行，不差）；无 tag 早退在 L376–380（设计记 L377 一带，对）；MANIFEST 路径于 L418 算出；「无 D/R → PASS」早退在 L462–466，其前全程不验 MANIFEST 存在——**漏格定位逐行坐实**。

## 逐审面结论

### ① 基线锚
如上，MQ-1–MQ-11 全成立（两处行号/措辞级微差见 P2-2、P2-3，不影响实施）。

### ② 件 2.0 清单追加→sync→对账链
脚本源码逐行核毕：队列选取（class∈{no-carrier, stale-content}∧outcome=pending）、处置表冲突断言（queue∩keep/drop→exit 2）、载体冲突守卫（gitlink 前缀／.git 组件→exit 2）、存在性预扫、plumbing 写树、提交标题形态（`chore(evidence): sync … (sync-maintainer-evidence)`，与谱系断言同构、后续运行不断言失效）、销账回写只动队列类 pending 行并逐行填 sha/commit、NO-OP 语义（树不变 exit 3）——与 §4.0 步骤 4–5 及 AC2/AC3 的预期逐项严丝合缝。增量集两件账本件的口径矛盾见 P1-2；supersede 措辞见 P1-1。

### ③ 件 2.1 判分规则可执行性
评分块形态与 pack-eval 前例同构亲验（`grep -oE … | sort -u | wc -l` 计数形态在 pack-eval-runner 源码 L26 注记在册）；PASS 式（distinct ≥3 ∧ must_not＝0）、control 判别力（≤1 有效／≥2 标 INVALID 且整轮 FAIL）、runner 只 check/score 不 spawn 的边界，均可照行实现且 AC5–AC10 可实跑判读。案二 must_not 的字面化缺口见 P2-1。

### ④ 件 2.3 五断言与 selftest 负控
五断言逐条可照行（effects.log 行数与键唯一、未提交编辑 sha 前后相等、证据哈希对快照、step_id 终值＝初值）；破坏路（无视账本全量重跑）必然使断言 1（已完成 step 效应行各恰 1 行）与断言 3（总行数＝5 且无重复键）FAIL，AC14 的判读式成立。断言集与 C4 原文四项＋step_id 对位无误。

### ⑤ 件 2.9 在船断言寄生点与引擎回归判别点
寄生点真实存在且位置正确：MANIFEST 在 L418 算出、diff 分流在其后，断言插于早退（L462–466）之前不扰动其他子命令（改动限 migration case 分支内，CF-4 的 version detect-only 基线比对＋`bash -n` 守卫足够）。fixture 三态与子命令真实语义相容（`git describe --tags --abbrev=0 HEAD^` 取前置 tag、无 D/R 前提下现行脚本必 PASS 而改后必报 MISSING HOP，判别力成立）。引擎判别点亲验坐实：migration-engine resolve 段（L687–728）——hop 在链时链解析走通、无 NOTE；链首缺 hop 且 genesis 的 installed_version 与 from 相符才打印 `NOTE: genesis-anchored …`；genesis 版本不符落 REJECT、中段缺 hop 落 REJECT——AC27 的正控（输出不含 genesis-anchored NOTE）与两负控不回归均有真实代码路径支撑。

## 设计内裁断 · 本路明确表态

**(i) 件 2.0 陈旧行「追加 supersede 行」主案：成立。** 机制经脚本源码坐实：队列按行选取，旧行 outcome＝synced 不入队、不被回写触碰；新行入队后按 path 填 sha/commit，账目可追溯且不破只增纪律。但 §4.0 步骤 3 的**理由陈述与字段值与两件实盘行不符**（见 P1-1），须按 P1-1 修订后实施。备选「就地改 carried 行 class」**按其字面不成立**：两件旧行均非 carried 类（见 P1-1），且仅改 class 不翻 outcome=pending 根本不入队——备选若要可行须连 outcome 一并改写，那就已是改账而非记账，更劣于主案。

**(ii) 件 2.9 断言「寄生 release-verify 机器面」主案：成立。** 漏格机理已逐行坐实（义务 prose 在 step3d 已存在而 v3.0.2 仍漏船，根因即无机器断言）；寄生点（MANIFEST 算出后、无 D/R 早退前）与判读归属（step3d 既有门）正确，且满足 PM「不新设清单步」指令。「仅 step3d prose 断言句」备选即已失败过一次的形态，不取。

## 问题清单

### P1-1（件 2.0 §4.0 步骤 3：supersede 的理由与字段值误述实盘行，须实施前修订）
亲测两件旧行真值：`.tad/evidence/knowledge-usage-log.jsonl` 的现有行 class＝**stale-content**、outcome＝synced；`.tad/evidence/pm/downstream-versions.md` 的现有行 class＝**no-carrier**、outcome＝synced。设计步骤 3 称「旧 carried 行 class 不在队列类内、天然惰性」并给新行附 `"supersedes": "carried-row"`——两处均与实盘不符：两件旧行**不存在 carried 类行**；且两旧行的 class 恰都在队列类内，其惰性 solely 来自 outcome≠pending（队列须 pending）。机制结论不变（主案成立，见上），但清单是只增永久账本：按现文实施将写入一条指向不存在之行的 provenance 字段、且理由句误述队列语义，AC1 的字段检查不验 supersedes 值、Gate 3 无从拦截。**修订要求**：步骤 3 的理由句改按真值陈述（旧行 outcome＝synced 故不入队），supersedes 字段改为记录被代行的实际标识（其 class／outcome／commit），或给出与两件真值相符的固定值；§9.2 与 §4.0 中「carried 行」表述同步更正。

### P1-2（件 2.0 §4.0：增量集定义与预期残余自相矛盾，须实施前定谳）
步骤 1–2 的增量集＝A−B（仅剔 EXCL 两件），按此集逐件生成行将**包含** `execution-manifest.jsonl` 与 `branch-disposition.tsv` 两件账本件本身（亲测：两件均不在分支树上——分支该目录仅 decision-brief.md，且两件正是 MQ-2 构成中 research 2 件）；但步骤 6 的预期残余明文称「清单与处置表自身等不在分支的账本件」为同步后残余，A 线先例亦从未把账本件入队（分支上至今无清单本体）。两处口径必居其一，且 AC1「增补行 path 集与 A−B 集逐件相等」直接继承此定义——Blake 在 Phase 0 必撞。附带机理：清单本体若入队，sync 的销账回写在同步后即改写清单本体，分支所载清单必为回写前形态、此后恒自陈旧一格。**修订要求**：§4.0 明文定谳账本两件入不入增量集（本路建议：不入，与先例及步骤 6 预期一致，并把排除项写进步骤 1 的集定义），AC1 的 A−B 定义同步对齐。

### P2-1（件 2.1：案二 must_not 尚无字面形态，注记）
§4.1 把 must_not 固定为评分块的 `must_not_pattern`（grep -oE 交替式），但案二的 must_not 以语义陈述给出（「命令仍写同一固定路径且无提示」），无字面 pattern 形态；案一、案三的 must_not 可字面化。实施时须把案二 must_not 落成字面 pattern（如固定路径字面串），且 AC6 未含 must_not_pattern 在盘非空的检查——建议 Gate 3 判读时逐案验其非空，本路不设为关闭条件。

### P2-2（MQ-1 措辞精度，注记）
「正文 8 行全以『本仓』自指」为约数表述：POINTER 实为标题＋引文行＋8 条 bullet，其中 7 条含「本仓」、1 条引 gm 侧技能壳源路径。要害实情（首行原文、全文仅一处席名、无第二处席名）已亲验成立，AC23 判据不依赖此句。不设条件。

### P2-3（行号微差，注记）
release-verify migration case 标签实在 L361，设计记「L360 起」为其注释头行；不影响寄生点定位。不设条件。

## 关闭条件汇总

本路 CONDITIONAL 的关闭条件仅两项，均为 §4.0 文本修订：(1) P1-1 的理由句与 supersedes 字段值按实盘真值更正；(2) P1-2 的账本两件归属明文定谳并与 AC1 集定义对齐。两项修订落盘、PM 定点核后，本路结论自动转 PASS，不必重派全审。

自报行：正文 11961 B／sha256 `5c160a942cd1dc5c7ed7aa789f4163887fb7996515ad5bdcf3c98d59c9bfceb0`（本行不计入正文，落盘后以 head -c 11961 复算为准）
