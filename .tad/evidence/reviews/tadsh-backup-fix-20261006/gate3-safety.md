# Gate 3 SAFETY 路独立评审 — TASK-20261006-TADSH-BACKUP-FIX（tad.sh 备份缺陷修复）

**评审者**：Blake 评审身份，独立会话（未参与本链设计与实施；与 CODE 路互不可见）
**日期**：2026-10-06
**对象锚（评审时实测）**：
- HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-tadsh-backup-fix.md`（44,721 B／sha256 `dbc7d56c…`，与增补件自报一致）＋ `…-SUPPLEMENT-1.md`（15,136 B）
- COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-tadsh-backup-fix.md`（25,820 B／sha256 `ebe93c54…`，与任务书锚一致）
- 风险卡 `.tad/evidence/risk-cards/risk-TASK-20261006-TADSH-BACKUP-FIX.md`（REQ-1–4；在盘文本与 HANDOFF §11 草案逐项一致）
- 被审代码：`tad.sh`（工作区，3,494 行）、`.tad/scripts/tad-update.sh`、`.tad/hooks/lib/tad-backup-test.sh`（32,069 B）

**方法**：规程原件按 tad-blake 激活壳进仓读（principles／patterns 索引／Gate Canonical Gate 3 节／evidence-collection）；C1–C6、restore helper、校验探针逐段亲读盘面代码；被审方测试套件在隔离 fixture 面**全新复跑**；另以同法 sed 抽取真函数构造作者测试未覆盖的对抗场景 12 例（脚本暂存 /tmp，结论在下）；git 全程只读。未对任何真实项目仓运行 tad.sh。

---

## 总判：CONDITIONAL

删除面、回滚面、探针、冻结令四条安全主线全部成立（见逐项）；唯一条件为一条 P2（F-S1）：`resolve_backup_root` 在符号链接别名落点路径上，物理拒绝触发**之前**已对目标内既存目录执行 `chmod 700`——拒绝本身有效、无数据损失，但与 NFR1／C1「首个项目变更前中止、零痕迹拒绝」的书面合同在该路径上不符。修复面小（拒绝判定前置于任何 mkdir/chmod 效应），关闭条件见 F-S1。其余为 P3 观察项，不阻塞。

---

## 五个重点面逐项结论

### ① 删除面安全（prune 删除集合 ⊆ 本仓组 ∩ 严格名模式 ∩ 非最新 2 份完整份）— ✅ 成立

代码面（tad.sh `prune_backups` L573 起亲读）：受害者只来自 `"$_gdir"/*` 一层 glob（组外路径构造上不可达）；`[ -d ]` 门＋严格正则 `^[0-9]{8}_[0-9]{6}(\.[0-9]+)?$` 双门；无 manifest 者按残份先清；完整份按 (时间戳, 后缀数值 `%012d`) 排序取最新 2（增补 N1 的数值序在码不在话）；删除前逐份 `dirname == _gdir` 断言＋ `# RM-OK:tad-backup-retention` ＋ log 点名；删除失败只 warn（AC8 合同）；刚写份兜底占第二保留位。对抗复核（本人实跑，全过）：

- **他组备份**：作者 retention 用例植入他组完整份＋非模式垃圾目录，清旧后字节完好（复跑绿）；prune 入参只有本组目录，跨组构造上无路径。
- **符号链接受害者**（作者未覆盖，本人补）：组内模式名符号链接指向组外带 manifest 的目录——prune 只删链接本体，组外目录与哨兵字节完好（ADV-A）。残份内含指向组外文件的链接——`rm -rf` 不跟随，组外文件完好（ADV-B）。
- **同名异路仓**：repo-key 用例两机绿——plain 组与 `-<cksum8>` 后缀组 origin 各自正确、保留计数独立；C2 只认完整份旁的 origin.txt（N5 在码：`[ -f manifest ]` 前置才读 origin）。
- **0700 权限面**：resolve_backup_root 对根 `mkdir -p`＋`chmod 700`、repo_group_key 对组目录同（N5 认领在码）；作者 location 用例断言新建根/组 =700；本人补测既存 755 根目录被收紧为 700（ADV-G）。注：对**操作者自设**的既存目录无条件 chmod 700 是 C1 规格明文行为，非缺陷；其与 F-S1 的交叠见该条。
- **模式名常规文件**（本人补）：组内模式名普通文件不被删除（`[ -d ]` 门，保守方向，ADV-C）。
- **时钟回拨兜底**（本人补）：组内植入两份未来日期完整份后以较旧的刚写份调 prune——刚写份存活且完整份恰 2（ADV-D）。

REQ-2 证伪信号（他组最新份／项目文件／遗留备份在清旧后缺失或哈希变化）：**未出现**。

### ② rollback 数据面零触碰（AC6 断言对）— ✅ 成立

代码面（step-1 L2285 起亲读）：还原集只来自 `manifest.txt` 逐行（`version=` 行剔除）；路由按备份侧载荷类型判定，registry 行恒走 file 路由（S2.3 在码，capability-packs 永不走目录整换）；双向类型翻转均先点名报错＋保备份（N3）；任一条目失败即停、跳过清新建（N4 在码，sweep 位于 `_rb_ok=1` 分支内）、备份保留、已还原条目不回退（AC7）。清新建判据为 S3.4 改写版：不在 `pre-top.txt` 且不在 `TAD_DENY_LIST ∪ TAD_TOP_DENY`（capability-packs 无无条件豁免，仅 pre-top 成员身份保护），删除前 `assert_under_root` 把关；pre-top 缺失时整步跳过＋warn（无清单不删，fail-safe 方向正确）。
实测面：restore 用例复跑绿——框架面四路变异（改/删/顶层文件/注册表）逐字节回备份时点；数据面全树清单在「备份后用户改动时点」与「回滚后时点」逐文件相等（含被改 evidence 保持改后字节、备份后新增 evidence 文件存活）；S3.5 顶层悬空链接回滚后存活且仍悬空；S2.5 包树哨兵完好；成功后备份被消费、失败三子场景（目录→文件／文件→目录／载荷缺失）均保留＋点名＋无 `.rollback-staging` 残留。
REQ-3 证伪信号（数据面任一文件哈希漂移或缺失）：**未出现**。

### ③ `_tad_tree_equal` 披露偏离的安全面 — ✅ 不构成校验变弱（一点除外，见 F-S1 外的观察 O1）

披露属实且范围准确：`git show HEAD:tad.sh` 中 `diff -rq` 共 5 处执行点——restore 两 helper 内 4 处（HEAD L1950/1954/1974/1977）已全部换为 `_tad_tree_equal`（现 L2226/2230/2250/2253），第 5 处在 verify_install_complete（见 ⑤）。探针亲读＋本人直测：链接目标漂移判不等（I3）；文件↔链接类型翻转判不等（I4，先判 `-L` 再判类型，翻转构造上不可绕）；空子目录缺失判不等（I5，`find` 条目集逐层比对，与 diff 的 "Only in" 等效）；常规文件 cmp 逐字节；FIFO 等特殊文件双存亦判不等（I6，保守失败方向）；diff 在悬空链接载荷上 exit 2 的原缺陷为真（作者分步 rc 实测在案），新探针是该载荷类下**唯一**能工作的判等法，非放水。
**权限位**：本人实测——仅权限位不同（755 vs 644）的两树，新探针判等，`diff -rq` **同样判等**（I2 双测）。即旧探针从不比权限位，新探针在此维度与旧面**平价**、无变弱。此点特此写明，防后续误读为探针缺陷。
REQ-1 证伪信号（集合 diff 非空／数据面哨兵入备份）：**未出现**（set-equality 复跑绿：manifest 行集与派生集 diff 空、递归内容集相等、7 个数据面/包树哨兵命中 0）。

### ④ 冻结令合规 — ✅ 成立（全程零真实仓运行，与在盘证据互洽）

- 测试脚本构造：每场景 mktemp 沙箱＋HOME 与 TAD_BACKUP_ROOT 双重定向，函数以 sed 抽取真源执行、从不运行 tad.sh 本体（脚本头注与代码一致，本人通读 692 行确认无真实仓路径引用）。
- 真实 HOME 下 `/home/hatch/.tad-backups` **不存在**——若本链曾以真实 HOME 对任何仓跑过备份，此目录必被创建；其缺席与「全程沙箱」自报互洽。
- 唯一在真实仓执行的命令链为 AC14 原文只读链：`--verify-denylist` 在 tad.sh L2515–2520 于 rollback trap 武装**之前**执行并 `exit $?` 立即退出（代码亲读：从不进入安装路径）；detect-state-test 为 mktemp 隔离。ac14-regression.log 在盘（deny-list 17 条一致、路由 12/12、链 rc=0）。
- grokbox 面：grokbox-test.log 在盘 TALLY 14/14；骨架在 /tmp/tadfix-*（仓外），未触 grokbox 同步仓本体（COMPLETION Provenance 行）。
- 存量备份：gm 仓根活标本在盘未被本链触碰——现存 `.tad.backup.20261006_115001`（今日 11:50）的成因是旧版安装器在 GM 当日刷新轮的既有缺陷行为、且每仓只剩 1 份与 GM 已组织的存量清理（留最新 1 份）口径吻合；本链 fixture 内以同名构造实测零触碰（legacy 用例复跑绿）。`.tad/version.txt` 仍 3.1.0 且不在 diff 内（版本冻结守）。
- 红基线：red-baseline.log／red-baseline-gb.log 在盘，14/14 红且红因标注为旧行为（落项目根整份拷贝、无 manifest、无保留、旧闸放行目标内伪造路径）——负证据纪律成立，非事后补造（红基线以最终版脚本对 git HEAD 源重测，COMPLETION Reflexion 如实记录首轮 size 假绿与 harness rc 两 bug 的发现与修正过程）。

### ⑤ 负证据纪律与写集外溢 — ✅ 成立

- **verify_install_complete 的另一处 `diff -rq` 未动属实**：现 L1719 的执行行与 HEAD L1477 逐字相同（`diff -rq "$src/.tad/$dir" ".tad/$dir" 2>/dev/null | grep -q "^Only in $src"`），仅行号因本链插入平移；其上方注释行（现 L1674）亦未改。作者「后续票同口径换探针」的建议属建议、未越界先行。
- 写集：`git diff` 的 tad.sh 7 个 hunk 全部落在本链声明行段内（全局 2 行／备份节／`_tad_tree_equal` 新增／两 helper 探针行／C5／C6 step-1）；tad-update.sh 恰 1 行（L185 展示串）；增补 S4 口径实测 `git diff -- tad.sh | grep -cE '^[+-]TAD_(ZERO_TOUCH|TRANSIENT|TOP_DENY)='` = **0**；`derive_framework_dirs`／`derive_framework_top_files`／`verify_denylist_drift` 三函数与 HEAD **逐字节相同**（本人 awk 抽取 cmp 实测）。NFR4（不动 deny-list 与 derive 语义）成立。
- 工作区另有 7 个已修改文件与若干 untracked 件（brain-index 机制、Epic P4 票/卡等），COMPLETION 与实施说明均显式声明为先在/并发链所写、本链不认领；其内容与本链写集无交叠，与同仓 P4 链在飞状态互洽——不构成写集外溢证据。
- COMPLETION 自报与盘面复核**逐项相符**（字节/sha、14/14 两机、AC 逐条载体）；无自报与盘上不符行，证据否决条款不触发。

---

## Findings

### F-S1（P2，CONDITIONAL 唯一条件）— 别名落点在拒绝前已对目标内目录 chmod 700

- **位置**：tad.sh `resolve_backup_root`（L498 起）：字面快速拒绝 → `mkdir -p` → `chmod 700` → 规范化 → 物理拒绝，顺序如此。
- **实证**（本人对抗场景 F）：目标内既存目录 `inner`（755）经符号链接别名作 `TAD_BACKUP_ROOT` 传入——函数 rc=1 正确拒绝、未建备份，但 `inner` 权限已被改成 700（755→700 在拒绝**之前**发生）。字面路径（非别名）落入目标的情形由快速拒绝零痕迹拦下（作者 root-guard 用例绿），本缺陷仅存在于「别名＋既存目录」路径。
- **定性**：无数据损失、删除面不受影响、拒绝最终有效；但 NFR1 与 C1 规格（「失败 `log_error`＋return 1（调用方在变更前中止）」、代码注释自称快速路径「no filesystem write has happened yet」）承诺的是变更前拒绝，该路径上权限变更先于拒绝，属合同偏离。chmod 对象是操作者自己的项目内目录，后果上限为单目录权限收紧（可逆，但可能影响同目录其他工具访问）。
- **关闭条件**（任一）：(a) 将物理落点判定前置——先以不产生副作用的方式规范化（解析父链/realpath 类只读规范化）并完成「等于/落入目标根」拒绝，再执行 mkdir/chmod；或 (b) 经 PM/Alex 裁定接受该偏离并把 NFR1/C1 文案与代码注释改为如实描述（别名路径拒绝前可能收紧该目录权限）。关闭后 SAFETY 路无需重审全链，定点复核此函数即可。

### P3 观察项（不阻塞，记录备查）

- **O1 探针的不可达理论面**：`_tad_tree_equal` 目录分支以 `find` 名录比对＋逐条递归；两侧同名子目录均不可读时，名录相等而内容未比对即判等。该状态在还原流中不可达——staging 的 `cp -R` 对不可读载荷先行失败、走不到校验步。仅记，不要求改。
- **O2 顶层框架文件为符号链接时被解引用备份**：backup 顶层文件循环用普通 `cp`（跟随链接），备份内为实体内容、还原后为常规文件（字节保真、类型由链接变文件）。仅限框架面；顶层悬空链接根本不入派生集，其存续由 pre-top 保护（不还原、不清扫），构造安全。与 HEAD 整树 `cp -R` 的保链接行为有别，属行为注记非安全缺陷。
- **O3 并发同组写入**：两进程同时对同组备份时，先完成方的 prune 可把后一方尚在写入（有模式名、无 manifest）的目录当残份清除。本安装器全线无进程间锁（HEAD 亦无），威胁模型为单操作者 CLI（principles 既定部署前提），不在风险卡 REQ 射程内；仅记。
- **O4 组目录内模式名异物**：人工在组目录内自置的模式名无 manifest 目录会被 prune 当残份删除——该目录位于备份根内、属保留策略辖区（REQ-2 三交集之内），与 C4 规格一致；记明以免误读为越界。

---

## §9.1 SAFETY 相关 AC 行复核（Canonical E 维：每行附证据指针）

| AC | 结论 | 证据指针 |
|---|---|---|
| AC1 集合相等（排除面承重） | PASS | 复跑 `--case set-equality` 绿；phase2-test.log／grokbox-test.log 同名节 |
| AC3 落点盘外＋根/组 700 | PASS | 复跑 location 绿；本人 ADV-G（既存根收紧 700） |
| AC5 保留策略 | PASS | 复跑 retention 绿（含同秒 date 影子回归＋N1 `.9/.10/.11` 子测） |
| AC6 还原正确性（断言对） | PASS | 复跑 restore 绿，B/P/A 三段清单在 phase2-test.log；本评审 ② |
| AC7 还原失败合同 | PASS | 复跑 restore-failure 绿（三子场景） |
| AC8 清旧失败不阻塞 | PASS | 复跑 prune-failure 绿（rm 影子注入，方法已在脚本内披露） |
| AC9 同名异路分组 | PASS | 复跑 repo-key 绿 |
| AC10 新闸负控 | PASS | 复跑 guard 绿（四路伪造全拒，含目标内植入判别例）；本人 ADV-E 补符号链接逃逸一路，亦拒 |
| AC11 落点指进项目被拒 | PASS（附 F-S1） | 复跑 root-guard 绿（三变体）；别名路径的拒绝前副作用见 F-S1 |
| AC12 遗留备份零触碰 | PASS | 复跑 legacy 绿（哈希前后相等＋提示行在） |
| AC13 悬空链接纪律 | PASS | 复跑 symlink 绿（链接保真、目标未改） |
| AC15 写集边界 | PASS | 本评审 ⑤（S4 口径计数 0、三函数 cmp 同 HEAD、hunk 全在声明行段） |

AC2/AC4/AC14/AC16 为非 SAFETY 主面行，本路复跑中随套件全绿（14/14），不另立结论，归 CODE 路。

**风险卡复核点**（卡尾注记：Gate 3 执行 AC1/AC5/AC6/AC9 时逐条对信号核查）：REQ-1 至 REQ-4 的证伪信号**全部未出现**；REQ-2/REQ-3 的停步动作均未触发。

---

## 评审纪律自报

- 纯只读评审：代码与证据只读；复跑仅限 mktemp 隔离 fixture（作者套件 14 例＋本人对抗 12 例，全部在 /tmp 沙箱内构造与销毁）；未以 tad.sh 碰任何真实项目仓；git 只读（status/diff/show）。
- 本人复跑结果：作者套件 **14/14 PASS**（与被审方自报一致）；对抗场景 12 例中 11 例 PASS、1 例（F）拒绝成立但检出 F-S1 的拒绝前副作用。
- 本 verdict 落盘后以 `wc -c`／`sha256sum` 实测自报，随回执上报（自引用值不写进正文，循本仓惯例）。

**Verdict**: CONDITIONAL（唯一条件 F-S1，P2）
**Reviewer**: Blake（Gate 3 SAFETY 路，独立会话）
**Date**: 2026-10-06
