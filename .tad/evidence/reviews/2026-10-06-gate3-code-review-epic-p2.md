# Gate 3 评审（CODE 路）— Epic Phase 2「持续测量层」实施

- 评审者：独立会话 Gate 3 CODE 路（与实施、SAFETY 路不同会话）。
- 对象：HANDOFF-2026-10-06-epic-p2-measurement（78,569 B／sha256 `e680d83ad8…`，开审复算与派发锚全等）；实施自报 COMPLETION-2026-10-06-epic-p2-measurement（12,317 B／sha256 `93f02cc6…`，与自报全等）。
- 判据链：票 TICKET-20261006-epic-p2-measurement；PM 裁断三件（design-rulings／gate2-merged-ruling／first-run-ruling）。
- 审法：AC1–AC30 逐条原样实跑复算（自建 fixture 与副本复跑，不采信实施方捕获件之处逐项注明）；按 gate-canonical-checklist 的证据否决子款执行。

## 结论：CONDITIONAL（P0＝0／P1＝1／P2＝2）

唯一关闭条件为 AC24 的扫描覆盖口径（见 P1-1）：PM 二选一裁断落盘后本路转 PASS。其余 AC 判读见下表；AC7/AC8 按 PM 首跑裁断判读，不作本批否决项。

## AC 逐条复算（本审实测值）

| AC | 判读 | 本审复算 |
|---|---|---|
| AC1 | PASS | 清单总行 13,285＝13,130＋155；增补 155 行（153 增量＋2 supersede）；非 supersede 增补 path 集与 `phase0-sets.json` 的 incr 集逐件相等（153）；账本两件不在增补行；增补行字段齐、回写后 sha/commit 全填；supersede 值逐件对 B2 裁定真值（`stale-content/synced`、`no-carrier/synced`），两件旧行 (class/outcome/commit) 真值复核相符 |
| AC2 | PASS | `2.0-sync-output.txt`：RESULT=SYNCED、SYNCED=155＝入队行数、BASE=`459ab78f`、NEW_TIP=`ea54399f`；本审 git 复核新尖单亲谱系（parent＝旧尖、脚本自产提交），与 D-2 围栏相符 |
| AC3 | PASS（附 P2-1） | synced 行 8,874、missing-on-branch＝0；朴素逐行读法 mismatch＝2（恰为两件被代旧行，与实施方 reconcile 记录及 COMPLETION 注记一逐值全等）；按 path 最新行读法 mismatch＝0；按行自记 commit 读法抽验 32 行（含两旧行）mismatch＝0；两件盘上现行内容 hash 与分支 blob 逐一全等——分支载的是现行真值 |
| AC4 | PASS | freshness 日志 L17（2026-10-06T06:36:56Z）VERDICT=OK、TIP_AGE_DAYS=0、TIP=`ea54399f`、NOCARRIER=9，与 `2.0-freshness-after.txt` 一致；链末两行（41/OK）与 COMPLETION 差归因一致 |
| AC5 | PASS | 本审亲跑 `regression-replay.sh check` → CHECK PASS、exit 0 |
| AC6 | PASS | 三案评分块在盘：min_discriminative＝3、control_max_hits＝1 全同；判别分支 5/7/6（≥4）；must_not 三案均字面非空（Gate 2 P2 备忘项已验）；README 四节齐（样本格式／评分与通过线／复跑程序／增长规则） |
| AC7 | FAIL 值属实（按 PM 首跑裁断判读） | 本审在运行目录副本上重跑 score 复现：三案冻结 control 的判别 distinct 命中＝4/5/3，均 >1。污染实证本审抽验成立：案一 control 答出 input 中不存在的 `muse-spawn-lint` 与激活闸口径、案三 control 答出 input 外的 TTL 300 秒／401／authorize 细节——属捕获通道效度问题，非样本缺陷；依裁断以 FAIL（已归因）收口、基线顺延 Phase 3，不以本行否决整批 |
| AC8 | FAIL 值属实（同 AC7 判读） | scores.md 在盘，含执行通道／模型／耗时列与失败原因附注；本审重跑 score 与在盘逐值一致（被测 5/5/4、must_not 全 0、整轮 FAIL） |
| AC9 | PASS | gate-execution.md L214 Regression Replay 块在盘：触发五面（skills/tasks/gates/templates/模型路由）齐、「整轮非 PASS 时 Gate 3 不得 PASS，除非 PM 裁断记录在案」句齐、样本集路径与 runner 命令行齐 |
| AC10 | PASS | 本审独立复现：以案一 control 充当 test 输出建副本运行目录跑 score → 案一 INVALID、整轮 FAIL、exit 1 |
| AC11 | PASS | 状态图 S1–S9 九状态；状态表证据指针本审抽提 18 条路径 `test -e` 全在；INT-1–INT-4 四行各有「对应 2.3 断言」列值 |
| AC12 | PASS | 演练记录六节齐（演练点定义／读取清单／逐项判读表／丢失清单／复盘／映射表）；逐项判读 9 项；丢失 L1/L2 已映射、L3 明示未映射＋理由 |
| AC13 | PASS | 本审亲跑 selftest：正路 k=2/k=4 各 5 条 ASSERT 全 PASS、exit 0；输出与实施方记录 `2.3-selftest-output.txt` 逐行同；`bash -n` 过 |
| AC14 | PASS | 本审亲跑复现：破坏路 k=2/k=4 两场景断言 1 与断言 3 各 FAIL。selftest 总出口按 §4.3 机制（两路预期皆符 → exit 0）判读，与 AC 字面「破坏路 exit 非 0」以破坏子路判 FAIL 成立为准 |
| AC15 | PASS | 脚本头注载 INT-1 进程中断／INT-2 压缩中断／INT-3 环境中断／INT-4 人工停步，与状态图分类表逐名一致 |
| AC16 | PASS | publish-ops §5 节首指针句与 §4.3 定稿逐字全等（本审逐字比对） |
| AC17 | PASS | 行号序 step3e（L215）< step3f（L237）< step4（L285）；step3f 含三家 runtime 集 {codex, opencode, cursor}、transcript 六字段、本周期口径（执行日期 ≥ 上一版发布日）、HARD/ADVISORY 判法（baseline-flip）、未登记即红句、Phase 3 兜底全 HARD 句与衔接句，名行与 §4.4 定稿同 |
| AC18 | PASS | publish-ops §2.6（L105）在盘：含预检序与判读口径、明示 step3f 为正本 |
| AC19 | PASS | fixture 核对表在盘：样本 A 判合规、样本 B 逐项点名缺 ②harness 名与版本、⑥原始输出指针；本审抽 grep 复核样本 B 确无该两字段、样本 A 具字段 |
| AC20 | PASS | 接口文档七节齐（汇集面／标签／去标识化／抽查误奖／保留集／约束／非目标）；约束句「Gate PASS 不得直接当奖励信号」grep 命中；数值锚 ≥10%、>5%、≥20% 与 `hash(step_id) mod 5 == 0` 全在盘 |
| AC21 | PASS | 评估五节齐；结论「采」∈{采,不采,缓}；结论节逐字复述判定规则并逐项标 (i)/(iv) 满足；只采回退还原验证一环、试点指针（Phase 3 首链） 在文；与票面红线「B2 只出评估记录」相符 |
| AC22 | PASS | 接口四部齐；FC-1–FC-4 逐类定义＋例齐；阈值 ≥6、≥4 在盘；决议「顺延」所记实数（累积复跑 1、案级 FAIL 3）与首跑 scores 一致；TREND.md 本审实测不存在（禁建守） |
| AC23 | PASS | POINTER 首行逐字 `# TAD 常驻指针`；全文 📐 计数＝0；第 2 行起与基线快照 `2.8-pointer-before.md` 的 diff 为空（本审亲跑 diff） |
| AC24 | **未合字面（P1-1）** | 见问题节。G1/G3 按 §4.8 规定集本审全量复跑均为 0 行；G2 记录的 126 行只覆盖一个窄枚举集、且记录把该集标注为「§4.8 定稿」，与 §4.8 写死的扫描集不符 |
| AC25 | PASS（附注记三成立） | hop 文件六字段（schema_version/from/to/generated_by/note/delete/rename）与 2.43.1 前例同构、from/to 正确、delete/rename 空、note 含追溯补船 provenance 句（点名件 2.9 与定性件路径）；字段序从前例正本形，与 AC25 字段集判据一致，注记三的偏离登记属实 |
| AC26 | PASS | 本审在 /tmp 骨架仓独立复现三态：无 hop → exit 1 且含 `MISSING HOP:`；补合规空操作 hop → exit 0；hop 的 to 改错 → exit 1 且含 `MALFORMED HOP:`。断言代码位置经源码核：MANIFEST 算出后、无 D/R 早退（L484）之前；无 tag 早退（L377）在断言辖区外，与 §4.9 一致 |
| AC27 | PASS | 本审独立复现三例（引擎直跑、genesis 锚定 3.0.1 的 /tmp 目标副本）：A 升 3.0.2 → exit 0、输出不含 `genesis-anchored` NOTE；B from 3.0.0 → REJECT exit 2；C 升 3.0.3 → REJECT 于 3.0.2 exit 2——缺口位置正证新 hop 被 resolve_chain 实际消费，两负控不回归 |
| AC28 | PASS | step3d 在盘含在船断言句与「exit 1 with MISSING HOP/MALFORMED HOP → HARD BLOCK for every release type」分支句；publish-ops §2.4（L88）含断言指针句；publish-protocol step 块数 HEAD 11 → 现 12（仅 +step3f） |
| AC29 | PASS | porcelain 变更集本审逐类归属：改面 4 件（publish-protocol／publish-ops／release-verify／gate-execution）＋建面（两脚本／样本集／hop 文件／POINTER 首行）均 ⊆ §7 写集；清单本体为未跟踪证据件，其行数变化已在 AC1 复算；其余变更为本链自产证据件与批前既存脏面（旧链迁档删除群、往链开跑卡存量、docs/pm），与 COMPLETION 归因一致；改动 .sh 三件 `bash -n` 全过（本审亲跑）；scan-packs 在 /tmp 副本复跑 exit 0、生成 registry 与仓内件逐字节同 |
| AC30 | PASS | `.tad/version.txt`＝3.0.2；version.txt／TAD-VERSION／config.yaml／package.json／tad.sh／AGENTS.md 对 HEAD 的 diff 合计 0 行，本链零 bump |

## 问题

### P1-1（AC24）同病扫描 G2 的执行集与 §4.8 写死的扫描集不符

事实（本审复算）：§4.8 的扫描集 S 写死为 `.tad/templates/`、`.tad/tasks/`、`.tad/gates/`、`.tad/project-knowledge/`、`.tad/scripts/`、`.tad/hooks/`、`.agents/skills/` 全文件加顶层件（本审构造 754 文件）。按此集复跑：G1＝0 行、G3＝0 行（与记录一致）；**G2＝1,098 行**，而实施记录为 **126 行**。126 行经本审复跑确认恰等于一个窄枚举集（`.tad/templates/`＋`.tad/installer.sh`＋`tad.sh`＋四件 SKILL.md＋POINTER＋brain-index.md＋AGENTS.md）的 G2 输出，且该 126 行的逐行判读（全 LEGIT）与记录逐行相符——即记录数字对其实际执行集属实，但扫描记录把该窄集标注为「§4.8 定稿」，与 §4.8 文本不符，COMPLETION 的 AC24 自报「三组按 §4.8 逐字口径」亦不确。缓解面（本审亲验）：G1/G3 两组按规定集全量复跑同为 0 行；G2 规定集余量 972 行经本审以席名/项目名/emoji token 扫描无一命中——同病结论方向（无额外 DISEASE）大概率不变，但 AC24 字面要求的「按规定集执行＋逐行判读」对 G2 未完成。

关闭条件（二选一，PM 裁断落盘）：(a) PM 追认窄集扫描＋本审全集复核（G1/G3 全集 0 行、G2 余量 token 扫描无命中）为足，AC24 以覆盖口径已注明收口；或 (b) 令实施方按 §4.8 规定集补跑 G2 全量并逐行判读，PM 定点核后销账。

### P2-1（AC3）判据字面与 Gate 2 已裁 supersede 形态在重复 path 上的摩擦

AC3 字面作「全部 synced 行 sha 与分支 ls-tree 相等、mismatch＝0」，与 Gate 2 落定的 supersede 追加形态（旧行原样保留）在重复 path 上字面不兼容：朴素读法 mismatch＝2。实施方已在 COMPLETION 注记一完整披露并给两替代读法，本审三读法全复算与自报逐值全等（朴素 2／最新行 0／自记尖抽验 0），且分支对两件的现行内容与盘上逐一全等——实质对账成立。按证据否决子款「不符属口径未注明者，须先注明口径再重算」的程序，自报已注明口径且重算相符，**不触发否决**。建议 PM 收口时追认「每 path 最新 synced 行」读法，并把后续 HANDOFF 的同类 AC 模板句改此口径。不设关闭条件。

### P2-2 文本小疵两处（不设条件）

§4.8 扫描集枚举自称「六树」实列七树，属设计文本计数小疵，PM 裁断 AC24 时可一并知悉。另证据目录存一版中间 runner 评分方言的输出件（`2.1-runner-check-output.txt`，语义与终版 runner 不同）；AC5–AC10 本审均以终版 runner 亲跑复现，判读不受影响，记录备查。

## 证据否决子款执行声明

除 P1-1 的覆盖口径问题（已立条件）与 P2-1 的口径摩擦（自报已注明、复算相符）外，被审方自报数字经本审逐项复算全等：COMPLETION 本体 12,317 B／sha256 `93f02cc6…` 与自报一致；完工说明逐件字节数（publish-protocol 16,637／publish-ops 10,418／release-verify 37,330／gate-execution 10,487／两脚本 6,119 与 5,396／hop 507／三设计件 3,940、6,598、3,884／README 3,610／POINTER 1,623）本审 `wc -c` 逐件相符；AC 计数与实测值（155/13,285、5/5/4、4/5/3、126 等）在各自判读口径下复现。证据否决不触发。
- 自报行：本 verdict 正文 12198 B／sha256 `e2c00dbe95b7345d5ce9ca6b7c92ae08f45c6b8f170239f9dec3669b2efa7aed`（本行不计入正文）。
