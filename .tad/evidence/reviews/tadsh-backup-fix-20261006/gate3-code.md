# Gate 3 评审 — CODE 路（独立评审）

**任务**: TASK-20261006-TADSH-BACKUP-FIX（tad.sh 备份缺陷修复）
**评审者**: Blake 评审身份，独立会话（未参与本链设计与实施；与 SAFETY 路互不可见）
**日期**: 2026-10-06
**评审对象**:
- HANDOFF `.tad/active/handoffs/HANDOFF-2026-10-06-tadsh-backup-fix.md` ＋ 增补 `HANDOFF-2026-10-06-tadsh-backup-fix-SUPPLEMENT-1.md`（S1–S4、N1–N5）
- COMPLETION `.tad/evidence/completions/COMPLETION-2026-10-06-tadsh-backup-fix.md`（实测 25,820 B／sha256 `ebe93c54ff96fc51320754e724f81f6ed0608d446c7c4dfc1c1b4cca29abf805`，与任务书锚值一致）
- 风险卡 `.tad/evidence/risk-cards/risk-TASK-20261006-TADSH-BACKUP-FIX.md`
- 实施说明 `.tad/evidence/completions/2026-10-06-tadsh-backup-fix-impl-note.md`
- 盘面代码：`tad.sh`（3,494 行；HEAD 3,109 行）、`.tad/scripts/tad-update.sh`、`.tad/hooks/lib/tad-backup-test.sh`（32,069 B）

**评审方法**: 不采信完工件转述。评审者本人：① 在本机隔离沙箱自跑全套 fixture（`bash .tad/hooks/lib/tad-backup-test.sh`，TALLY PASS=14 FAIL=0）及 AC14 命令链原文（rc=0）；② 以最终版测试脚本对 `git show HEAD:tad.sh` 复跑红基线 4 例（set-equality/location/guard/retention 均红且红因正确）；③ 另写独立探针（保留集跨秒＋后缀≥10 混合、命名 max+1、_tad_tree_equal 语义矩阵、清新建保全集实路演练）全过；④ 逐行亲读 tad.sh 备份节（L488–745）、`_tad_tree_equal` 与两 restore helper（L2180–2256）、C5 闸（L2272）、C6 step-1（L2285–2392），并以 git diff 逐 hunk 核写集。全部复跑只在 mktemp 隔离面，未以 tad.sh 碰任何真实项目仓，git 只读。

---

## 总判：CONDITIONAL PASS

AC1–AC16 全部由评审者独立执行验证通过（下表）；Canonical Gate 3 七项中六项成立、一项（Code/deliverable complete）附条件。**唯一条件**：披露偏离项 `_tad_tree_equal` 探针替换（见 §3）须由 Gate 4（Alex）追认——该偏离经评审者独立判读为合同不变的探针修正、且为 HANDOFF 自身 fixture 规格所迫，不需要代码返工；追认前本路不给无条件 PASS。P2-2 与 P3 三项为后续票注记，不阻断。

---

## 1. Canonical Gate 3 七项

| 项 | 结论 | 证据 |
|---|---|---|
| Code/deliverable complete | ⚠️ CONDITIONAL | C1–C7＋S1–S4＋N1–N5 全部在盘（行号锚与实施说明 §2 一致，逐段亲读核对）；唯一越出 §7.2 字面写集的改动为两 restore helper 的校验探针（§3），已披露、待追认 |
| §9.1 Spec Compliance | ✅ | AC1–AC16 逐行独立执行，全过（§2） |
| Evidence files exist | ✅ | `.tad/evidence/tadsh-backup-fix-20261006/` 六件在盘：red-baseline.log／red-baseline-gb.log（均 0/14）、phase1-test.log（11 过＋3 Phase-2 面红，与完工件描述一致）、phase2-test.log（14/14，含 restore B/P/A 三段全树清单）、grokbox-test.log（14/14）、ac14-regression.log |
| Evidence replayable | ✅ | 评审者重跑全套与在盘日志同结果（14/14）；红基线重跑同结果（红因一致） |
| Git commit done | ✅（NONE 合规） | 本链 git 只读为 HANDOFF §10.2 明定，COMPLETION 记 NONE，提交归 PM 收口 |
| Knowledge Assessment complete | ✅ | COMPLETION KA 节非空（2 条发现），留 Alex 蒸馏的处置与写集边界一致 |
| Provenance non-empty | ✅ | COMPLETION Provenance 表逐 CREATE 文件有行 |

**证据纪律核对（E 维）**：完工件自报与评审者重算逐项比对——COMPLETION 字节/sha（25,820／ebe93c54…）、tad.sh 行数（3,109→3,494）、测试脚本字节（32,069）、AC15 赋值行计数（0）、AC16 计数（0／1）、测试 TALLY（14/14）、detect-state（12/12）、非本链改动文件数（7）——全部与盘面相符，无一行触发证据否决。

## 2. AC1–AC16 逐条独立结论

| AC | 结论 | 评审者独立证据 |
|---|---|---|
| AC1 备份集＝派生集 | ✅ PASS | 自跑 `--case set-equality` rc=0；亲读 C3：拷贝集直接调 `derive_framework_dirs`/`derive_framework_top_files`，备份节内无第二份名单字面量；registry 特判只拷单文件（S2.1 在码）；manifest 递归内容集与派生集相等、7 哨兵命中 0（用例断言在盘可查） |
| AC2 体量 | ✅ PASS | 自跑 `--case size` rc=0（备份字节 <20% 且 >0、≥5M 文件零入备份；用例已含防空测断言） |
| AC3 落点盘外＋700 | ✅ PASS | 自跑 `--case location` rc=0（项目根与 .tad 清单备份前后不变、根/组权限实测 700）；C1/C2 代码认领 chmod 与 HANDOFF N5 一致 |
| AC4 默认落点 | ✅ PASS | 自跑 `--case default-home` rc=0（HOME 沙箱、无 env 覆盖，路径形如 `$HOME/.tad-backups/proj/<ts>`） |
| AC5 保留策略 | ✅ PASS | 自跑 `--case retention` rc=0；另以独立探针 A1–A3 复核（见 §4）——跨秒混合＋后缀 .9/.10/.11 混排＋同秒 .1–.12 全梯，保留集恒为最新两份；残份先清不占名额（用例断言） |
| AC6 还原正确性 | ✅ PASS | 自跑 `--case restore` rc=0（框架面四路变异全还原、新建框架目录被清、数据面 B/P/A 对照中数据面保持 P 时点、S3.5 顶层悬空链接存活且仍悬空、S2.5 包树哨兵完好）；独立探针 D 复核清新建保全集实路（见 §4） |
| AC7 还原失败合同 | ✅ PASS | 自跑 `--case restore-failure` rc=0，三子场景（目录→文件、文件→目录、载荷被删）均：备份保留、点名、先行还原不回退、清新建跳过、无 `.rollback-staging` 残留；代码层 N3 类型翻转前置检查亲读确认（file 路由先查目标侧 `-d`，含符号链接指向目录的情形） |
| AC8 清旧失败不阻塞 | ✅ PASS | 自跑 `--case prune-failure` rc=0。方法注记：以 rm() 函数影子注入删除失败（root 下 chmod 造不出真失败），完工件已披露——评审者接受此法：被测路径（prune 的 warn＋点名＋不阻塞）正是影子所达之处，且删失败分支在 prune 代码中亲读可见（两处 rm 均走 warn 分支、函数恒 return 0） |
| AC9 同名异路分组 | ✅ PASS | 自跑 `--case repo-key` rc=0（组键相异、origin 各自正确、计数独立、空格名清洗）；C2 代码：只认完整份 origin（N5）亲读确认 |
| AC10 新闸负控 | ✅ PASS | 自跑 `--case guard` rc=0，四路伪造（根外／名不合／无 manifest／**目标根内植入**）全拒并点名、目标字节不动、真备份未被消费。判别力另由红基线反证：HEAD 旧代码对目标根内伪造路径**实际执行了还原并消费了伪造备份**（评审者自跑 guard 红例日志在案），新闸为真修复而非空转 |
| AC11 落点指进项目被拒 | ✅ PASS | 自跑 `--case root-guard` rc=0（根内／根＝目标／相对路径三变体全拒，项目树哈希不变，根内变体零建目录——快速路径在 mkdir 前拒绝，代码亲读确认）。残余见 P3-2 |
| AC12 遗留零触碰 | ✅ PASS | 自跑 `--case legacy` rc=0（预置遗留份经备份＋回滚全程哈希不变、提示行在输出中）；FR8 代码仅 glob＋log、零读写 |
| AC13 悬空链接纪律 | ✅ PASS | 自跑 `--case symlink` rc=0（备份内仍为链接、目标未改）；与 §3 探针修正互为表里 |
| AC14 回归 | ✅ PASS | 评审者实跑 HANDOFF 原文命令链 rc=0：`bash -n` 过、`--verify-denylist` PASS（17 条）、detect-state-test 在盘 12/12 |
| AC15 写集边界 | ✅ PASS | §5 逐项核完：S4 口径计数 0、deny 赋值块与 HEAD 逐字节相同、两 derive 函数＋`copy_framework_files`＋`take_rollback_snapshot`＋`verify_denylist_drift` 与 HEAD 逐字节相同（sha256 比对）、hunk 位置全在声明行段内、tad-update.sh 仅 L185 一行 |
| AC16 更新器文案 | ✅ PASS | 评审者实测：`grep -c 'Backup:  .tad.backup'`＝0、`grep -c 'tad-backups'`＝1；新串字面与 C7 规格一致 |

## 3. 披露偏离独立判读：`_tad_tree_equal` 替代 `diff -rq`（4 处校验点逐处核）

**改动事实**（git diff 逐行核）：`restore_dir_entry` 内 2 处（L2226 stage 校验、L2230 rename 后复验）、`restore_file_entry` 内 2 处（L2250、L2253），恰 4 处，无多无少；仓内其余 `diff -rq` 一处（L1719 `verify_install_complete`）未动，与披露一致。两 helper 为 step-1 与 step-2 快照还原共用——写集字面越出 §4.6「step-2…5 不动」一行，但 helper 的合同（stage-verify-rename 原子性、失败保源、消息面）一字未变，变的只有「相等」的测法。

**等价性判读**（独立探针 C 语义矩阵，评审者自跑）：
- 常规文件：`cmp -s` 与 diff 同为逐字节比对，等价。
- 目录：条目集（find 全量枚举）＋逐条目递归（类型／字节／链接目标），与 `diff -rq` 的「Only in＋内容比对」集合语义等价。
- 符号链接：**语义不同且新探针更对**。GNU diff 在目录比对时解引用链接、比目标内容，悬空链接直接 exit 2（评审者实测：两棵逐字节相同的含悬空链接树，`diff -rq` rc=2）——stage 校验的职责是验「拷贝是否忠实」，cp -R 拷贝的是链接本身，链接目标串相等才是忠实判据。旧探针在此载荷上不是更严，是恒失败。
- 悬空链接载荷：新探针判等（目标串同即等），还原得以完成——正是 AC13 的合法载荷；若无此修正，AC6 的 restore 用例（hooks 目录内含悬空链接）必然在 verify 步失败，**HANDOFF 的 fixture 规格（§6 明定框架目录内悬空链接）与指定 helper 探针自相矛盾**，实施在探针层消解矛盾是唯一不改合同的路径。
- 特殊文件（FIFO 等）：新探针判「存在即不等」→ 还原大声失败、备份保留（保守方向）；旧 diff 对特殊文件同样报错。失败方向一致且安全。
- 两探针均不比权限/时间戳，无差。

**结论**：偏离成立且必要，属实现层探针修正而非设计变更；本路**接受**，条件仅为 Gate 4 留痕追认（建议同时把 L1719 的同病灶列后续票，完工件已有此建议）。若 Gate 4 不追认，替代路径（C6 私有化 helper）只增代码重复、不增安全，本路不推荐。

## 4. 重点复核：同秒命名单调不复用与保留集判定

**代码亲读**：命名取同秒同名兄弟的最大数字后缀＋1（非首个空位），base 名被 prune 释放后不复用；prune 排序键为（时间戳字符串, %012d 补零的数值后缀），保留集取排序末二，另有兜底：刚写份不在保留集且在枚举内时占第二保留位（保计数＝2 且刚写份恒不删）。

**独立探针结果**（评审者自写、自跑，非被审方用例）：
- A1 跨秒混合（`20261005_235958`、同秒 `.9/.10/.11`、`20261006_000000`、`20261006_000001` 六份）：保留恰为最新两份 `20261006_000000`＋`20261006_000001`，`.11` 未因字节序误留。
- A2 时钟回拨兜底（刚写份戴最旧名）：刚写份与全局最新份被保留，计数恒 2。
- A3 同秒全梯 `.1`–`.12`＋base 共 13 份：保留恰 `.11`＋`.12`。
- B1/B2 预置 base＋`.9`＋`.10` 后同秒真跑 `backup_existing`：新份取 `.11`（max+1），跑后 prune 保留 `.10`＋`.11`。
- 结论：保留集判定在后缀 ≥10 与跨秒混合下恒对，N1 修法成立；被审方 fixture 的 N1 子测（`.9/.10/.11` 植入）与本探针互证。

**清新建保全集实路补测**（被审方 fixture 未覆盖的一格）：评审者探针 D 在真代码路径上构造「失败运行新建 DENY 目录 `reports/`（含文件）、新建 TOP_DENY 文件 `sync-registry.yaml`、新建框架目录」后回滚——`reports/` 与 `sync-registry.yaml` 被保全集保住、框架目录被清、框架文件被还原。保全集 grep 的数据基础（`TAD_DENY_LIST`/`TAD_TOP_DENY` 为换行分隔）亦经亲读确认，判定非空转。

## 5. 写集封口（本链 vs 并行链）

`git status` 改动面共 9 个已跟踪文件。本链认领恰 2 个：`tad.sh`、`.tad/scripts/tad-update.sh`（仅 L185 一行）；新增认领：`.tad/hooks/lib/tad-backup-test.sh` 与本链证据目录、ralph-loops 两件、completions 两件（均 untracked 新文件）。其余 7 个已跟踪改动（`.agents/skills/alex/references/publish-protocol.md`、`.tad/brain-index.md`、`.tad/hooks/lib/brain-index-gen.sh`、`.tad/project-knowledge/incidents/_index.md`、`.tad/project-knowledge/patterns/_index.md`、`.tad/tasks/evidence-collection.md`、`.tad/templates/completion-report.md`）与 untracked 的 Epic P4 件，经 hunk 内容核对均非本链所写（属并行在飞链），完工件「7 文件」计数与盘面一致、本链未认领他人改动亦未漏报自家改动。`tad.sh` 全部 hunk 落在：全局初始化（+5 行）、备份节（C1–C4 重写区）、`_tad_tree_equal` 新增、两 helper 各 2 行探针、 C5 新增、step-1 区段——无一落在 deny 赋值块、derive 函数、拷贝面、迁移面（`.tad-migrate-backup.*` 区段零 hunk）。`.tad/version.txt`、session-state 未动（git status 零命中）。

## 6. 风险卡 ASM 复核（Gate 3 复核点）

| REQ | 证伪信号 | 评审者复核结果 |
|---|---|---|
| REQ-1 备份集＝派生集 | AC1 diff 非空／数据面哨兵入备份 | 信号未现：set-equality 自跑绿、哨兵命中 0 |
| REQ-2 prune 删除集合三重交集 | 他组/项目文件/遗留哨兵缺失或变哈希 | 信号未现：retention、repo-key、legacy 自跑绿，他组与非模式目录完好 |
| REQ-3 rollback 只动 manifest 域 | 数据面哈希漂移/缺失 | 信号未现：restore 数据面对照相等；探针 D 保全集实路成立 |
| REQ-4 落点盘外＋每组 ≤2 | 根内新备份目录／组内完整份 ≥3 | 信号未现：location、retention、探针 A/B 均合 |

## 7. Findings 分级

**P0**：无。
**P1**：无。

**P2-1（流程条件，本判 CONDITIONAL 的唯一来源）**：`_tad_tree_equal` 探针替换越出 HANDOFF §4.6/§7.3 字面写集（两 helper 与 step-2 共用）。已充分披露、经本路独立判读为合同不变的必要修正（§3）；须 Gate 4 追认留痕后转无条件 PASS。不需要返工。

**P2-2（功能注记，后续票）**：清新建的粒度是 `.tad` 顶层——若失败运行在**备份时点已存在**的 `capability-packs/` 目录内新建了 `pack-registry.yaml` 本体（备份时点该文件不存在、manifest 无 registry 行），回滚后该文件残留（顶层条目 `capability-packs` 在 pre-top 内、受保护，嵌套文件不在清扫面）。影响面窄（已安装仓的注册表恒在盘），与 S3.4 的顶层判据设计一致，非实施缺陷；记注供 Alex 在 Gate 4 决定是否立后续票。

**P3-1**：人工预置带前导零的后缀名（如 `<ts>.08`）会命中 shell 八进制解释（命名 max 计算与 prune 的 %012d 格式化）；脚本自产名恒无前导零，实际不可达。记注即可。

**P3-2**：`resolve_backup_root` 的物理（解符号链接）根内检查在 `mkdir -p`＋chmod 之后——经符号链接别名指向项目内的根会被拒，但拒绝前已在项目内建出该目录（留痕）；字面路径形态（AC11 三变体）均在 mkdir 前快速拒绝、零痕迹。属纵深注记，不影响 AC11 判读。

**P3-3**：实施说明 §6 的先在改动清单有两处路径写松（evidence-collection 实为 `.tad/tasks/` 下、publish-protocol 实为 `.agents/skills/alex/references/` 下）且含一条已不在盘的条目（gate-3-code-review-checklist.md 当前未修改）；COMPLETION 本件的计数（7）与盘面一致。仅文档瑕疵，不影响 AC15 判读。

## 8. 评审者声明

- 本评审与 SAFETY 路独立、互不可见；结论仅代表 CODE 路。
- 全部行为复跑在 mktemp 隔离 fixture 内完成，未对任何真实项目仓运行 tad.sh，未删改任何存量备份，git 全程只读。
- 被审方自报与盘面重算的全部比对点相符（§1），无证据否决触发。

**自报**：本件字节数与 sha256 于落盘后由 `wc -c`／`sha256sum` 实测，随评审回执上报（自引用值不写进正文，循本链惯例）。

**Reviewer**: Blake（Gate 3 CODE 路独立评审）
**Date**: 2026-10-06
**Verdict**: CONDITIONAL PASS（条件：Gate 4 追认 §3 探针偏离；无代码返工项）
