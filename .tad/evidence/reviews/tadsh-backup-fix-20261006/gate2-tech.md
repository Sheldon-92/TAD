# Gate 2 技术路独立评审 — TASK-20261006-TADSH-BACKUP-FIX（tad.sh 备份缺陷修复设计）

**评审人**：Alex（Solution Lead），Gate 2 技术路独立会话（与契合路互不可见、未沟通）
**日期**：2026-10-06
**总判**：**CONDITIONAL PASS**（三条阻断条件 T-C1…T-C3 须落进 HANDOFF 修订并经 PM 核销后转 PASS；条件均为定点补钉，不要求重设计）

**激活自报**：已按 tad-alex 薄壳协议进 TAD 仓读原件——`AGENTS.md`、`.tad/project-knowledge/principles.md`、`.tad/project-knowledge/patterns/_index.md`，并按索引选读 `patterns/shell-portability.md`、`patterns/ac-verification.md`（≤3 条纪律内）；判据认 `.tad/gates/gate-canonical-checklist.md` Gate 2 节。本评审全程只读（干跑仅在 /tmp 内构造 fixture 与抽取函数实跑）；未运行 tad.sh 本体、未碰任何真实项目仓。

**评审对象锚**（开工复算，与派发锚全等）：
- HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-tadsh-backup-fix.md`：44,721 B／sha256 `dbc7d56c80139a929db4c281ab00c8c1e71bfc903e1b615aacec0bba0786c32b`，AC1–AC16。
- 设计说明 `.tad/evidence/designs/2026-10-06-tadsh-backup-fix-design-note.md`：16,505 B。
- 风险卡 `.tad/evidence/risk-cards/risk-TASK-20261006-TADSH-BACKUP-FIX.md`：3,139 B，与 HANDOFF §11 草案逐项一致（REQ-1…4＋证伪式假设表齐备、信号均可观察）。

---

## 1. 现状陈述核验（重点①：亲读 tad.sh 全路径）——PASS

逐项亲读/实跑复核，HANDOFF §2.2 与设计说明 §1 的现状陈述**全部对位**：

| 陈述 | 实测 |
|---|---|
| tad.sh 共 3,109 行 | `wc -l tad.sh` = 3109 ✓ |
| `backup_existing` L483–503，`cp -R .tad` 整份零排除、项目根相对落点、同秒 `.n` 递增（L486–493）、`BACKUP_PATH` 为相对路径 | 亲读 L483–503，逐项相符 ✓ |
| 调用点唯一：main L2772；其后 L2774 `NEED_ROLLBACK=1`、L2777 `take_rollback_snapshot`；位于下载/校验/平台解析/冲突预检/人确认之后、首个项目变更之前 | grep 全仓 `backup_existing` 仅 L483 定义＋L2772 调用；亲读 L2755–2790 相符 ✓ |
| install/upgrade/migrate 三入口共用该调用点 | ACTION 在 L2600–2674 由 `detect_state` 分流赋值，case 分发在备份调用**之后**（L2780 起），三路必经 L2772 ✓ |
| MQ2 十行函数行号（assert_under_root 303／restore_dir_entry 1944／restore_file_entry 1969／rollback_on_failure 1985／take_rollback_snapshot 1885／discard_rollback_snap 1921／resolve_tmpdir 96／derive_framework_dirs 603／derive_framework_top_files 622） | grep 定位逐行全等 ✓ |
| step-1 现以 `assert_under_root "$BACKUP_PATH_ABS"` 把关（L2001）＋`restore_dir_entry` 整目录换回（L2002）、成功消费备份（L2003 `# RM-OK:rollback-backup-consumed`） | 亲读 L1996–2019，相符 ✓ |
| 快照对绝对 `BACKUP_PATH` 走 `/*)` 分支原样通过（MQ3 贯通性） | 亲读 L1893–1898，相符 ✓ |
| migrate 结构备份 L2940–2951 独立存在；引擎 `.tad-backup/` L1666 起独立机制 | 亲读两处，相符（§4.6 边界划定正确）✓ |
| tad-update.sh 仅 L185 展示串涉旧落点 | 亲读 L180–190：`echo "Backup:  .tad.backup.<timestamp-or-unique-suffix>"`，AC16 两 grep 口径（旧串现计数 1、改后应 0；`tad-backups` 改后 ≥1）可判别 ✓ |
| 本仓 `.tad` 总体量 163M | `du -sm .tad` = 163 ✓（evidence/archive 分项以设计说明实测为准，本审未复测分项） |
| deny 集与 §4.1 排除清单恒等（A 类 12／C 类 5／顶层 2） | 亲读 L569–594，逐项相符 ✓ |
| §4.1「进」目录 23 项 | 以 sed 抽取真源派生函数实跑（见 §2）：派生输出 24 项 = §4.1 的 23 项 + `capability-packs`（见 Finding F1） |

补充核验（设计未明言、本审确认无碍）：`detect-state-test.sh` 在盘（AC14 第三段可实跑）；派生函数定义（L603/622）在 backup_existing（L483）之后，但调用发生在 main 运行期、全部定义已加载，备份时点可调用性成立。

## 2. 备份集「恒等于 deny-list 派生集」的可构造性（重点②）——CONDITIONAL（Finding F1）

派生函数在备份时点可调用、粒度正确：以 sed 抽取 tad.sh L569–594＋L603–635 真源在本仓实跑，`derive_framework_dirs "."` 与 `derive_framework_top_files "."` 输出与 §4.1 正反清单逐项对应（顶层文件 23 件含 version.txt/portable-extract.sh、deny 两件不在内）。

**但 registry-only 分量在 HANDOFF 里没有钉死表示法**，这是本审最重的一条：

- 实测事实：`capability-packs` **不在** TAD_DENY_LIST 内，派生目录输出**包含**它（本审实跑输出第 2 行即 `capability-packs`）。安装器的既有消费方对它一律特判——拷贝面 L1198、校验面 L1459 均以 `if [ "$dir" = "$TAD_REGISTRY_ONLY" ]` 只取注册表文件、跳过树身。
- HANDOFF C3 的操作规程只写「目录走 `derive_framework_dirs "."`…每项 `cp -R ".tad/<项>"`」，**没有**写目录循环须对 TAD_REGISTRY_ONLY 特判；§4.3 manifest 规格「一行一个顶层相对条目（…注册表以 `capability-packs/pack-registry.yaml` 全相对路径一行）」没有明说**不得**同时出现裸 `capability-packs` 目录行；C6 step-2 的路由表（注册表行→file 路由／目录→dir 路由）没有明说该分量**永不**走 dir 路由。
- 两种可 plausible 的读法后果分岔：(a) 按 C3 字面直译 → 整棵 capability-packs 树被 `cp -R` 进备份，违 §4.1「树身不入」与 REQ-1，且真实仓包树体量可观、AC2 在 fixture 上因包树哨兵文件小而**测不出来**；(b) manifest 同时含裸目录行与注册表行、备份只存了注册表（按 §4.1 意图）→ C6 对裸行走 `restore_dir_entry`，该 helper 的语义是 `rm -rf` 目标后整目录换回（亲读 L1944–1962），目标仓的 capability-packs 树身会被一份只含注册表的目录**整换删除**——不可逆数据损失，恰是风险卡 REQ-3 要防的事故形态，只是换了目录。
- 设计说明 D-1/D-4 的**意图**是对的（「仅注册表文件，树身不入」「capability-packs 目录本身永不整删」），但 HANDOFF 是 Blake 的唯一实施依据，意图未落成 C3/§4.3/C6 的钉死条款，且 AC1 的判别力依赖测试枚举深度（见 §5）。

**Finding F1（P1，阻断条件 T-C1）**：HANDOFF 须补钉三处——① C3 目录循环对 `$TAD_REGISTRY_ONLY` 特判（只拷注册表文件，镜像 tad.sh L1198 既有形态）；② §4.3 明示 manifest 中该分量**仅**以 `capability-packs/pack-registry.yaml` 一行表示、禁止裸目录行；③ C6 明示路由按 manifest 行形态判定、capability-packs 分量永不走 dir 路由。并须在 AC1 方法中写明：set-equality 用例对备份内容**递归枚举**比对、且断言包树哨兵在备份内命中 0；restore 用例断言包树哨兵回滚后字节完好。

## 3. manifest 域逐条目原子还原与数据面零触碰（重点③）——CONDITIONAL（Finding F2；P2 注记 A3/A4）

机制本体成立，亲读 helper 语义确认：

- `restore_dir_entry`/`restore_file_entry`（L1944–1984）的 staging 落点是 `${_dst}.rollback-staging`，即**目标同目录内**——与备份根是否同设备无关，rename 恒在目标文件系统内原子完成；跨设备只发生在从备份根 `cp` 读入 staging 的一程（拷贝语义，无原子性要求）。「跨设备 mv 语义」风险在现行 helper 构造下不存在 ✓。
- 每步 `diff -rq` 双段校验（stage 后、rename 后）；空目录经 `cp -R`＋`diff -rq` 可正确还原（diff 对双空目录返回 0）✓；框架目录内悬空符号链接由大写 `-R` 保链接、`diff -rq` 比链接目标，AC13 的前提成立 ✓；权限位由 `cp -R` 沿现行 F-06 既有语义携带，本链 AC 以内容哈希为判据（§4.5 与承接 B 同口径），不在本链声称范围内，不另立项。
- 数据面零触碰的构造：还原集 R＝manifest（派生集），清新建的保全集＝deny 全集 ∪ {capability-packs}，两集互补覆盖 `.tad` 顶层的数据面条目——**对目录与常规文件成立**。但清新建的判据「C∉R 且 C∉保全集 ⇒ 本轮新建」**不被蕴含**，存在实测反例：

**Finding F2（P1，阻断条件 T-C2）**：/tmp fixture 实测——在 `.tad` 顶层放一悬空符号链接 `dangling-link`，抽取真源派生函数实跑：dirs 输出仅 `hooks`、files 输出仅 `version.txt`，该链接**两边都不在**（`*/` glob 不匹配悬空链接、`[ -f ]` 对悬空链接为假）；而它在 `.tad` 顶层枚举中存在。按 C6 step-3 字面判据，它会被误判「本轮新建」并在回滚时 `rm -rf`——一个**安装前就存在**的用户条目被回滚删除，违 C6 自述的「只清本轮新建」不变式与风险卡 REQ-3 的精神。同一漏洞类还包括顶层 FIFO/套接字等非规
...[truncated 3974 chars]则条目。修法不需要新机制：备份时把 `.tad` 顶层**全量**条目清单（含非规条目）随备份落盘（如 manifest 的 `# pre:` 注释行或独立 `pre-top.txt`），清新建只删「不在备份时点清单内」的条目——这正是仓内既有先例（take_rollback_snapshot 的 ROLLBACK_PRE_TOP，L1901–1906）在一层之下的同构应用。fixture 须加一例：顶层预置悬空符号链接，restore 后断言其仍在且仍为悬空链接。

**P2 注记 A3**（不阻断）：文件条目的类型翻转未在 C6 写明——`restore_file_entry` 不预清目标（亲读 L1968–1984：staging 后直接 `mv`），若某顶层框架文件在失败运行中被换成同名**目录**，`mv` 会把 staging 文件移入该目录内，随后 `diff -rq` 不符返回 1（备份保留、大声报错，失败合同不破），但会在目标内留下一件 `.rollback-staging` 残留、且 abort 清理的 `rm -f "$_stage"` 已找不到它。AC7 构造的失败形态只有「目录→文件」一向。建议 C6 补一句：路由按备份侧类型判定，目标侧类型不符时先点名报错并保留备份（或显式预清），且 restore 用例补「文件→目录」一向。

**P2 注记 A4**（不阻断）：C6 未写明「任一条目还原失败时，清新建步是否仍执行」。按现行失败合同（保全一切待人工），应明示失败即跳过清新建，避免在半还原态继续删除。

另注（与 F1/F2 修复同向）：capability-packs 若为本轮新建（目标原本没有），它在保全集内会被整体保留，其内注册表文件成为回滚后残留——T-C2 的备份时点清单落地后，此例可一并以「清单内/外」判据处置，C6 修订时顺带写明即可。

## 4. 清旧集合界定（重点④）——PASS（P2 注记 A1/A5）

三重收窄构造正确：严格名模式 `^[0-9]{8}_[0-9]{6}(\.[0-9]+)?$`（与现行 `date +%Y%m%d_%H%M%S`＋`.n` 后缀形态相符）＋删除前组内前缀断言＋只计带 manifest 的完整份、残份优先清；清旧失败 warn 不阻塞的合同（D-3）与代价上限论证成立；新份在清旧时点为最新一份，不会被本轮 prune 删除（在 A1 排序前提下）。

**P2 注记 A1**（不阻断，建议随手修）：「LC_ALL=C sort 的字节序即时序」在同秒后缀 ≥10 时不成立——本审实跑：`20261006_120000{.1,.2,.9,.10,.11}` 经 `LC_ALL=C sort` 得序 `base, .1, .10, .11, .2, .9`，尾二（即「保留的最新两份」）是 `.2` 与 `.9`，真正的最新 `.10/.11` 反被清掉；极端情形下（同秒 ≥12 份）刚写的新份也可能被本轮 prune 误删，使随后回滚的 BACKUP_PATH 指向已删目录。真实刷新节奏下同秒十余份概率极低，故不阻断；修法一行：排序键拆为（时间戳, 后缀数值）或断言排序后新份在保留集内。设计说明 D-3 中「同秒后缀排其基名之后」的表述应同步限定为后缀 <10 时成立。

**P2 注记 A5**（不阻断，规格完整性）：AC3 断言「根与组目录权限 700」，但组件规格只在 C1 写了根的 `chmod 700`，组目录的 chmod 无组件认领（AC 会逼出实现，但规格应认领）；C2 读 origin 应限定「任一**完整份**的 origin.txt」（残份在 origin 写入前中断时无此文件，C3 流程为拷贝完才写 origin），并写明组内无 origin 可读时按本仓自有组处理。

**Finding F3 附带核验 — C1 的目标根来源未钉**（P2 注记 A2，不阻断）：设计说明 D-2 硬闸②写作「备份目标落在 `$TARGET_ROOT` 之内 → 拒绝」，但实测 `TARGET_ROOT` 在备份时点为空串（L77 初始化，首次赋值在 take_rollback_snapshot 的 L1886，位于备份**之后**）。实现若照字面引用 `$TARGET_ROOT`，该闸为空转；正确来源是 backup_existing 执行时 cwd 的 `pwd -P`（该函数本体即以 cwd 相对路径工作）。AC11 能确定性抓出错误实现，故不阻断；但 HANDOFF C1 应把目标根来源钉为 `pwd -P`，并明示备份根与目标根**相等**时同样拒绝（现 C1「不在目标根内」的字面前缀＋边界表述对相等情形含糊）。

## 5. fixture 设计的判别力（重点⑤）——CONDITIONAL（Finding F3）

总体强：Phase 0 红基线要求新行为用例在未改源上「红在正确原因」（落点/整份），沿 detect-state-test 的 sed 抽真源先例、不测复制品；哨兵体系分层（数据面唯一哈希哨兵、他组份、项目根文件、遗留份）；guard 用例三类伪路径全负控（AC10）；root-guard 断言项目树哈希不变（AC11）；prune-failure 以不可删旧份构造且断言新份完好（AC8，同用户删除需父目录写权，chmod 构造可达）；restore 以全树哈希对照且含「备份后改数据面」时点（AC6，承接 B 同口径的名副其实落地）。

**Finding F3（P1，阻断条件 T-C3）**：AC15 的第二段验证方法测错了对象。方法为 `git diff -- tad.sh | grep -c 'TAD_ZERO_TOUCH\|TAD_TRANSIENT\|TAD_TOP_DENY'`，期望「名单本体变更行数 0」。但 C6 step-3 按设计**必须**在新增代码里引用现成变量做保全集比对（HANDOFF 原文：「保全集（`TAD_DENY_LIST ∪ TAD_TOP_DENY ∪ {capability-packs}`，用现成变量逐项比对）」），这些新增行必然出现在 diff 中并被该 grep 计数。本审在 /tmp 以两行符合 C6 形态的新增行模拟 diff，计数 = 2 ≠ 0。即：一份完全合规的实现必然触发 AC15 假 FAIL，Gate 3 会被一条测错对象的 AC 卡住（ac-verification 既有教训：计数型断言约束总量不约束位置/对象）。修法：改为只比对三段赋值块本体（如抽取 HEAD 与工作区各自的 L569–594 等价区段做 diff，或只统计 diff 中形如 `^[+-]TAD_(ZERO_TOUCH|TRANSIENT|TOP_DENY)=` 的赋值行），使「引用」与「改定义」可分辨。

与 F1/F2 联动的判别力缺口（已分别写入 T-C1/T-C2）：AC1 未写明递归枚举深度与包树哨兵断言；restore 用例未含顶层非规条目存活断言；AC7 只构造一向类型翻转（A3）。补齐后 fixture 判别力完整。

另核（不立项）：AC14 在未改源上应绿的标注属实（`bash -n`＋`--verify-denylist`＋detect-state-test 均为现行回归面，文件在盘已核）；§9.1 全部 AC 的 Verification Method 均为 command 形态，文法合法；AC2 的 20% 相对量在 fixture 构造下（evidence ≥5M 填充 vs 框架哨兵小文件）有判别力。

## 6. Gate 2 Canonical 对照（技术面）

| 检查项 | 本路结论 |
|---|---|
| Expert review complete (min 2) | 本件为双路之一（技术路）；另一路（契合路）由 PM 另派，本审未见、未沟通 |
| All P0 resolved | 无 P0；三条 P1 以阻断条件 T-C1…T-C3 形式提出，核销后转 PASS |
| Architecture complete | ✅ 备份集派生/落点/保留/还原四件定案完整，D-5 不双读判据成立（grep 证实旧备份无自动读者，与 §4.6 相邻面边界一致） |
| Components specified | ⚠️ C1/C2/C4/C5 规格完整；C3/C6 两处表示法未钉死（F1/F2） |
| Functions verified | ✅ MQ2 十行行号与代码片段逐项亲验全等（§1 表） |
| Data flow mapped | ✅ MQ3/MQ5 与盘面相符（绝对路径 `/*)` 直通、manifest 三消费方、遗留面显式非真源） |
| Risk card | ✅ 已落盘且与草案一致；四条 ASM 均为可证伪句、证伪信号可观察、动作明确 |
| Load points declared | ✅ §7.4 逐文件写明装载面与触发时点，与三入口实测装载路径相符 |

## 7. 阻断条件（核销方式：Alex 修订 HANDOFF 对应节 → PM 盘上核销；无需重跑本审）

### T-C1（F1）
C3 补 registry-only 特判、§4.3 补 manifest 表示唯一性（仅注册表路径行）、C6 补路由禁令（该分量永不走 dir 路由）；AC1 方法补「递归枚举＋包树哨兵备份内命中 0」、restore 用例补「包树哨兵回滚后字节完好」。

### T-C2（F2）
备份产物增加备份时点 `.tad` 顶层全量条目清单（形态任选：manifest 注释行或独立文件，须在 C3/§4.3 写明）；C6 step-3 清新建改为「不在备份时点清单内 且 不在保全集」才删；fixture restore 用例加顶层悬空符号链接存活断言。

### T-C3（F3）
AC15 第二段改为只测三段 deny 赋值块本体变更（抽取比对或赋值行口径），并在 Expected Evidence 中写明「新增代码引用变量名不计」。

## 结论重述

**CONDITIONAL PASS（技术路）**。设计的骨架——派生集复用、盘外落点、manifest 完整标记、清单域还原、严格名模式清旧——经逐行亲验与三组 /tmp 实测探针（派生函数真源抽取实跑、同秒后缀排序、顶层悬空链接派生集归属、AC15 计数模拟）证明构造可行且与现状陈述全等；三条阻断条件全部核销后，本审结论自动转 PASS。

**自报**：本件字节数与 sha256 由落盘后 `wc -c`／`sha256sum` 实测值随回执上报（自引用值不写进正文）。
