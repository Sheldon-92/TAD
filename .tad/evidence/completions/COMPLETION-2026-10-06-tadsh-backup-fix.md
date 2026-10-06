---
# gate3_verdict: filled by Blake as a Gate 3 POST-STEP (value ∈ pass|fail|partial).
# ⚠️ Do NOT fill at creation — the verdict does not exist until /gate 3 runs.
gate3_verdict:
---

# Implementation Completion Report

**From:** Blake (Agent B - Execution Master)
**To:** Alex & Human
**Date:** 2026-10-06
**Project:** TAD 本体（安装器 tad.sh）
**Task ID:** TASK-20261006-TADSH-BACKUP-FIX
**Handoff ID:** HANDOFF-2026-10-06-tadsh-backup-fix.md ＋ HANDOFF-2026-10-06-tadsh-backup-fix-SUPPLEMENT-1.md（冲突以增补为准，已按此实施）

---

## 🔴 Gate 3 v2: Implementation & Integration Quality (Blake必填)

**执行时间**: 2026-10-06 13:51 UTC

### Layer 1 (Self-Check)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Build Passes | ✅ | `bash -n tad.sh` 与 `bash -n .tad/scripts/tad-update.sh` 均通过（shell 项目，无编译） |
| Tests Pass (100%) | ✅ | 隔离 fixture 14/14 场景全绿：VM（phase2-test.log）＋ grokbox 骨架（grokbox-test.log）；红基线 14/14 红在盘（red-baseline.log / red-baseline-gb.log，未改源、最终版测试脚本复测） |
| Lint Passes | ✅ | 无 shellcheck 基础设施在盘；以 `bash -n` ＋ AC14 回归链（--verify-denylist ＋ detect-state-test 12/12）代偿，见 ac14-regression.log |
| TypeScript Compiles | N/A | 纯 bash 项目 |

### Layer 2 (Expert Review)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| spec-compliance | ⏳ | 待 Gate 3 独立双审对 §9.1 AC1–AC16 逐行执行验证（本件 §测试证据已逐行回填实测结果） |
| code-reviewer | ⏳ | 待 Gate 3 独立会话（Blake 不自审） |
| test-runner | ⏳ | 同上；测试脚本在盘可重跑（`bash .tad/hooks/lib/tad-backup-test.sh`） |
| security-auditor | ⏳ | 本件含删除语义（风险卡 REQ-1–4），待 Gate 3 SAFETY 路对 C4/C5/C6 删除与拒绝路径独立审 |
| performance-optimizer | N/A | 无性能面 |

### Evidence

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert Evidence | ⏳ | Gate 3 评审落盘后回填 |
| Ralph Loop Summary | ✅ | `.tad/evidence/ralph-loops/tadsh-backup-fix_state.yaml` ＋ `tadsh-backup-fix_summary.md` |
| Acceptance Verification | ✅ | §8.6 证据全套在 `.tad/evidence/tadsh-backup-fix-20261006/`（清单见 Evidence Checklist） |

### Knowledge Assessment

| 检查项 | 状态 | 说明 |
|--------|------|------|
| ⚠️ New Discoveries Documented | ✅ | Yes — 2 条（见 Knowledge Assessment 节）；因写集边界未直写 project-knowledge，留 Alex 蒸馏落盘 |
| ⚠️ Skillify Candidate | ❌ | No: 本次发现属既有 shell-portability 家族的两条新实例，未达独立 skillify 门槛 |
| ⚠️ Workflow Pattern Discovered | ✅ | Yes: defect in restore-verify probe（diff -rq 与悬空链接）＋ defect in backup naming（同秒命名复用使保留排序反转）；均记于 Knowledge Assessment |

### Git

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Changes Committed | ❌ | NONE — 本链 git 只读（HANDOFF §10.2：提交由 PM 收口管，Blake 不自行 commit/push） |

**Gate 3 v2 结果**: ⏳ 待独立双审（Blake 自检全绿，不自填结论）

---

## Reflexion History

what_failed: Phase 0 首轮红基线中 size 用例在未改源上假绿（备份路径按 harness cwd 解析失败、字节数测得 0、断言空转通过）。
root_cause_hypothesis: 用例未先断言备份目录真实存在，空测与真测在退出码上不可区分（shell-portability 已记的同族坑：查找为空喂给 continue 型判据）。
revised_approach: size 用例先断言 BACKUP_PATH 非空且目录在盘、备份字节 >0，再测比例；红基线以最终版脚本对 git HEAD 的 tad.sh 在 VM＋grokbox 骨架重测，14/14 红。
confidence: high

what_failed: root-guard 用例三变体全红但原因错位——拒绝日志已打出、退出码却被 harness 吞掉。
root_cause_hypothesis: do_backup 子 shell 无 set -e，backup_existing 返回 1 后 printf 成功把 rc 冲成 0；生产 tad.sh 有 set -e 故真实行为正确，错在 harness 的 rc 传播。
revised_approach: do_backup 显式捕获并以该 rc 退出子 shell；复测 root-guard 绿，且其余用例不受影响。
confidence: high

what_failed: restore 用例中目录型条目（hooks）还原在 stage-verify 步失败，文件型条目正常。
root_cause_hypothesis: restore_dir_entry 的校验用 GNU diff -rq，它在目录比对时解引用符号链接，遇悬空链接 exit 2；fixture 按 HANDOFF §6 规格在框架目录内放了悬空链接（AC13 面），旧 helper 对该载荷类必然校验失败——属先在缺陷被本链 fixture 首次照出。
revised_approach: 两个 restore helper 的 4 处校验点改用链接安全的 _tad_tree_equal（比条目类型、cmp 比字节、readlink 比链接目标，POSIX 工具）；helper 的原子还原合同与消息面不变。此为实现层探针修正，已在本件与实施说明中显式披露，留 Gate 3 裁断。
confidence: high

what_failed: grokbox 全量复跑 retention 红：同秒 4 连跑后剩 3 份（内容 v2/v3/v4），VM 同轮次绿。
root_cause_hypothesis: run3 的 prune 删掉同秒 base 名后，run4 按「首个空位」复用 base 名——最新备份戴最旧名，(时间戳,后缀) 排序反转；prune 的「刚写份永不删」兜底又使本轮零删除。VM 轮次跨秒未触发。
revised_approach: 命名改 max(同秒后缀)+1（base 被清后也不复用）；prune 保留集加兜底（刚写份不在最新 2 时占第二保留位）；retention 用例加 date() 影子确定性同秒回归场景，两机复测全绿。
confidence: high

---

## 📋 实施总结

### 完成的工作
- C1 `resolve_backup_root`（tad.sh L498）：落点解析与校验——默认 `$HOME/.tad-backups`（以 $HOME 构造）、`TAD_BACKUP_ROOT` 覆盖须绝对、0700、规范化后断言不等于/不落入目标根（目标根钉 `backup_existing` 执行时 cwd 的 `pwd -P`，增补 N2）；相对/根内在首个变更前拒绝。
- C2 `repo_group_key`（L539）：仓组键 = basename 清洗（`tr -c`）；同名异路以完整份 origin.txt 比对分流 `-<cksum 前 8 位>`（N5：只认完整份 origin、无可读 origin 按自有组）；组目录由本组件建并 chmod 700（N5 认领）。
- C4 `prune_backups`（L573）：严格名模式枚举；无 manifest 残份先清且不占名额；完整份按 (时间戳, 后缀数值) 排序留最新 2（增补 N1 排序键）；删除逐份断言组内前缀＋ `# RM-OK:tad-backup-retention` ＋ log 点名；删失败只 warn（AC8 实测）；保留集兜底保证刚写份恒在保留集内。
- C3 `backup_existing` 重写（L636）：`.tad` 不在直接返回（原行为）；拷贝集 = `derive_framework_dirs` ∪ `derive_framework_top_files` 直接派生（无第二份名单，grep 自证）；capability-packs 特判只拷注册表文件（增补 S2.1）；同秒命名 max+1 不复用（见 Reflexion 4）；写序 pre-top.txt（增补 S3.1 顶层全量枚举）→ origin.txt → manifest.txt 最后写（条目 LC_ALL=C 排序、registry 以全路径行、末行 `version=`，S2.2）；`BACKUP_PATH` 改绝对路径；成功后调 C4；项目根遗留 `.tad.backup.*` 一行提示（FR8，零读写）。
- C5 `assert_under_backup_root`（L2272）：三条全过才放行——规范路径严格位于规范备份根下、基名合时间戳模式、manifest 在；根值取同轮进程全局（不重解析 env）。
- C6 `rollback_on_failure` step-1 改写（L2285 内）：换 C5 闸；manifest 域逐条目原子还原（路由按备份侧载荷类型，registry 行恒走 file 路由，增补 S2.3；类型翻转先点名报错保备份，N3；任一失败即停、跳过清新建、备份保留、已还原条目不回滚，N4/AC7）；全成后按 S3.4 清新建（判据 = 不在 pre-top.txt 且不在保全集；capability-packs 无无条件豁免）；成功消费备份（`# RM-OK:rollback-backup-consumed` 沿用、注释改注新闸）；覆盖消息逐条目列 manifest 条目；无备份的全新安装分支与 step-2…5 一字未动。
- 校验探针修正（披露项）：`_tad_tree_equal`（L2188）替换 restore_dir_entry/restore_file_entry 内 4 处 `diff -rq` 校验（理由与范围见遗留问题/实施说明）。
- C7：`.tad/scripts/tad-update.sh` L185 展示串改新落点文案（AC16 实测旧串 0、新串含 `tad-backups` 1 处）。
- 全局：`TAD_BACKUP_ROOT_ABS` / `BACKUP_GROUP` 两行初始化（L82–83）。
- tad.sh 3,109 → 3,494 行；deny-list 三段赋值块与两个 derive 函数与 HEAD 逐字节相同（AC15 口径实测）。

### 修改的文件
```
tad.sh                      # C1–C6 + _tad_tree_equal + 两行全局（见上行号锚）
.tad/scripts/tad-update.sh  # 仅 L185 展示串（C7）
```

### 新增的文件
```
.tad/hooks/lib/tad-backup-test.sh            # 隔离 fixture 测试（14 场景，sed 抽取真函数，不重实现）
.tad/evidence/tadsh-backup-fix-20261006/     # 本链测试日志 6 件（红基线×2、phase1、phase2、grokbox、ac14）
.tad/evidence/ralph-loops/tadsh-backup-fix_state.yaml / _summary.md
.tad/evidence/completions/COMPLETION-2026-10-06-tadsh-backup-fix.md（本件）
.tad/evidence/completions/2026-10-06-tadsh-backup-fix-impl-note.md（实施说明）
```

### §9.1 AC1–AC16 逐条实测结果

| AC | 结果 | 实测载体 |
|----|------|---------|
| AC1 备份集与派生集逐项集合相等 | ✅ PASS | `--case set-equality` 两机绿：manifest 行集与派生集 diff 空；递归内容集相等（S2.4）；7 个数据面/包树哨兵 grep 命中 0（phase2-test.log、grokbox-test.log） |
| AC2 体量回 MB 级 | ✅ PASS | `--case size` 两机绿：备份字节 < fixture .tad 总字节 20%（fixture 总量 ≈5.63MB、备份载荷 ≈90B＋三件元数据，见 restore 用例 B 清单）；≥5M 文件零入备份 |
| AC3 落点盘外＋根/组 700 | ✅ PASS | `--case location` 两机绿：项目根条目集与 .tad 清单备份前后不变；根与组目录权限实测 700 |
| AC4 默认落点 $HOME/.tad-backups | ✅ PASS | `--case default-home` 两机绿（HOME 重定向沙箱、无 env 覆盖） |
| AC5 保留策略 | ✅ PASS | `--case retention` 两机绿：4 连跑后完整份恰 2 且为最新两份；残份清且不占名额；同秒确定性回归（date 影子）绿；N1 植入 .9/.10/.11 后保留 .11、清 .9（后缀数值序） |
| AC6 还原正确性（AC6 断言对） | ✅ PASS | `--case restore` 两机绿：框架面逐字节回备份时点（改/删/注册表/顶层文件四路实测）；新建框架文件与目录被清；数据面全树哈希在「备份后用户改动时点」与「回滚后时点」逐文件相等（phase2-test.log 内 B/P/A 三段清单对照）；S3.5 顶层悬空链接回滚后存活且仍悬空；S2.5 包树哨兵完好 |
| AC7 还原失败合同 | ✅ PASS | `--case restore-failure` 两机绿，三子场景：(a) 备份内目录条目被换成文件 → 备份保留、报错点名 scripts、先行还原的 hooks 不回退、清新建跳过（N4）、无 .rollback-staging 残留（N3）；(b) 文件条目被换成目录 → 保留＋点名 config.yaml；(c) 条目载荷被删 → 保留＋点名 hooks |
| AC8 清旧失败不阻塞 | ✅ PASS | `--case prune-failure` 两机绿：以 rm() 影子对指定旧份注入删除失败（root 下 chmod 造不出真失败，故用函数影子，方法已披露）→ 备份 rc=0、warn 点名该份、新份完好、可删旧份照常清、完整份计数 3（新＋最新旧＋卡住份） |
| AC9 同名异路分组 | ✅ PASS | `--case repo-key` 两机绿：两组键相异、origin 各自正确、保留计数独立；含空格仓名清洗为 sp_ace |
| AC10 新闸负控 | ✅ PASS | `--case guard` 两机绿：四路伪造 BACKUP_PATH_ABS（根外／名不合模式／无 manifest／**目标根内植入**）全被拒并点名，目标 .tad 字节不动，真备份未被消费（目标根内一路为旧 assert_under_root 必放行、新闸必拒的判别例） |
| AC11 落点指进项目被拒 | ✅ PASS | `--case root-guard` 两机绿：根内路径、根==目标、相对路径三变体全拒；项目树哈希前后不变且根内变体零建目录（快速路径在 mkdir 前拒绝） |
| AC12 遗留备份零触碰 | ✅ PASS | `--case legacy` 两机绿：预置 `.tad.backup.20000101_000000` 经备份＋回滚全程哈希不变；备份输出含遗留提示行 |
| AC13 悬空链接纪律 | ✅ PASS | `--case symlink` 两机绿：框架目录内悬空链接备份成功、备份内仍为链接且目标未改（大写 -R 语义） |
| AC14 回归防退化 | ✅ PASS | HANDOFF 原文命令链实跑 rc=0：`bash -n` ✓、`--verify-denylist` PASS（17 条与 lib 一致）、detect-state-test 在盘且 12/12 PASS（ac14-regression.log） |
| AC15 写集边界 | ✅ PASS | 本链变更 = tad.sh ＋ .tad/scripts/tad-update.sh（改）＋ tad-backup-test.sh 与本链证据件（增）；`git diff -- tad.sh \| grep -cE '^[+-]TAD_(ZERO_TOUCH\|TRANSIENT\|TOP_DENY)='` = 0（增补 S4 口径）；两个 derive 函数体与 verify_denylist_drift 与 HEAD 逐字节相同（cmp 实测）。注：工作区另有先在于本链的未提交改动（brain-index 等 7 文件与若干 untracked 件），非本链所写，本件不认领、明细见实施说明 |
| AC16 更新器文案 | ✅ PASS | `grep -c 'Backup:  .tad.backup'` = 0；`grep -c 'tad-backups'` = 1 |

### 边界复述（HANDOFF §4.6 / §7.3，任务书指定）
- **存量约 150 份 `.tad.backup.*` 清理归 GM** 在用户点头后统一组织——本链未删除、未移动、未读取任何真实仓存量备份；gm 仓根活标本（4 份 `.tad.backup.*` ＋ 1 份 `.tad-migrate-backup.*`）只观察、未触碰。
- **`.tad-migrate-backup.*` 不动**：结构迁移备份（tad.sh L3335 `cp -R .tad "$MIGRATE_BACKUP_DIR"` 一带）语义为旧布局数据救援源，未改一字；建议 PM 另立后续票（HANDOFF 原议）。
- 迁移引擎 `.tad-backup/`（按条目备份）未动；ROLLBACK_SNAP 与 rollback step-2…5 未动（step-2 共用的 restore helper 仅校验探针更换，见披露项，合同不变）。
- `.tad/version.txt` 未动（仍 3.1.0，版本冻结：不单独发版、随 Epic 最终版统一发布）。
- 冻结令遵守：未对任何真实项目仓运行 tad.sh 的安装/升级路径；唯一在真实仓执行的命令是 AC14 原文规定的只读校验链（`--verify-denylist` 在 trap 武装前退出、从不安装；detect-state-test 为 mktemp 隔离）。全部行为验证在 mktemp fixture ＋ grokbox 骨架（/tmp/tadfix-*）内完成。
- session-state 未动（§7.3 写集外，PM 收口管）。

---

## 🔗 Provenance (Artifact Generation Record)

| Artifact | Generation Method | Sub-agent | Notes |
|----------|------------------|-----------|-------|
| tad.sh（C1–C6 等） | Edit tool 定点替换（全局 1 处、备份节整段 1 处、C5 插入 1 处、C6 step-1 替换 1 处）＋ python3 脚本对两 helper 内 4 处校验行机械替换（替换前后 grep 复核） | direct | 每步后 `bash -n` ＋ 对应 --case 复测；行号锚以最终盘面 grep 为准 |
| .tad/scripts/tad-update.sh | Edit tool 单行替换 | direct | AC16 grep 前后计数留痕 |
| .tad/hooks/lib/tad-backup-test.sh | Write tool 三段落盘（骨架＋用例×2 批）＋ 4 次定点 Edit（guard 判别子例、do_backup rc 传播、perm/size 修正、同秒回归场景） | direct | 32,069 B / sha256 `1c398a7d…`；sed 抽取 tad.sh 真函数执行（detect-state-test 先例），零重实现 |
| .tad/evidence/tadsh-backup-fix-20261006/*.log | 测试脚本 stdout 经 tee/重定向直落，红基线附说明头 | direct | 捕获路径按 evidence-collection 唯一化纪律：本链专属目录、逐件命名 |
| grokbox 骨架运行 | scp tad.sh＋测试脚本至 grokbox /tmp/tadfix-{red,green} 后 ssh 执行，结果 scp 回落盘 | direct | 未触碰 grokbox 同步仓本体 |

---

## 🧪 测试证据

### 测试覆盖率
- **单元/场景测试**: fixture 14 场景 × 2 机器（VM ＋ grokbox）全绿；场景与 §9.1 行一一映射（AC14/15/16 为命令/盘面行，另行实测）。
- **红基线**: 未改源上 14/14 红（两机），红因均为旧行为（落项目根整份拷贝、无 manifest、无保留、旧闸误放目标根内伪造路径）。

### 测试输出
```bash
bash .tad/hooks/lib/tad-backup-test.sh            # VM: TALLY PASS=14 FAIL=0（phase2-test.log）
ssh grokbox 'bash /tmp/tadfix-green/.tad/hooks/lib/tad-backup-test.sh'   # grokbox: PASS=14 FAIL=0（grokbox-test.log）
bash -n tad.sh && bash tad.sh --verify-denylist && bash .tad/hooks/lib/detect-state-test.sh   # AC14 链 rc=0（ac14-regression.log）
```

---

## 🤝 Sub-Agent 使用记录

| Sub-Agent | 是否使用 | 使用场景 | 输出摘要 |
|-----------|---------|---------|---------|
| test-runner | ❌ | — | 测试由 Blake 本人以 bash 直跑（每 Phase 后全场景集），输出全量落盘，未另派 |
| bug-hunter | ❌ | — | 两处缺陷（diff 悬空链接、同秒命名复用）由 Blake 在保留沙箱内逐步复现定位（cp/diff 分步实测、组目录与 out.log 对照），未另派 |

---

## 📊 效率数据

### 问题解决记录
| 问题 | 发现时间 | 解决方式 | 耗时 |
|------|---------|---------|------|
| 红基线 size 假绿＋ rc 吞没（harness 两 bug） | Phase 0 | 断言补强＋ rc 显式传播，红基线以最终脚本对 HEAD 重测 | 约 10 分钟 |
| restore 目录条目 verify 失败（diff -rq × 悬空链接） | Phase 2 | 保沙箱分步实测（cp rc=0 / diff rc=2 / --no-dereference rc=0）→ _tad_tree_equal 探针替换 | 约 15 分钟 |
| grokbox retention 留 3 份（同秒命名复用） | Phase 3 复跑 | 组目录名与内容对照定位 → max+1 命名＋保留集兜底＋确定性回归场景 | 约 20 分钟 |

---

## ⚠️ 遗留问题（如有）

### 已知问题
- 📝 **披露项（留 Gate 3 裁断）**：restore_dir_entry / restore_file_entry 的 stage-verify 探针由 `diff -rq` 改为 `_tad_tree_equal`。两 helper 为 step-2 快照还原共用——其合同（原子 stage-verify-rename、失败保源）未变，变化仅在「相等」的测法：diff 在悬空链接载荷上恒失败（exit 2），新探针对文件用 cmp 逐字节、对链接比目标、对特殊文件保守判不等。若 Gate 3 认为共用 helper 不可动，替代路径是 C6 私有化一份 helper（代码重复，Blake 不推荐）。
- 📝 C2 残余：三仓同 basename 且前两仓已占 plain＋同 cksum 后缀键的碰撞未处理（cksum 取自完整路径，三方同后缀概率可忽略）；origin.txt 指向的仓已被删除时组键不回收——均无害（多占一个组目录），HANDOFF 未要求。
- 📝 同秒命名 max+1 扫描只认数字后缀同名兄弟；人工在组目录内放同名异物（如 `<ts>.bak` 目录）不影响命名与保留（名模式不合、prune 不碰），与 REQ-2 口径一致。

### 技术债务
- 无新增技术债登记项；`.tad-migrate-backup.*` 的后续处置按 HANDOFF §4.6 建议由 PM 另立票（非本链债务）。

### 后续改进建议
- 💡 Gate 3/4 若认可 `_tad_tree_equal`，可考虑把 verify_install_complete 中 L1697 的 `diff -rq`（安装校验面，本链写集外未动）在后续票中同口径换探针——其载荷为新装树，同样可能含悬空链接。

---

## 📖 Knowledge Assessment (MANDATORY — Gate 3 BLOCKING)

**是否有新发现？** ✅ Yes

- **类别**: testing / shell-portability（相邻既有条目家族）
- **标题 1**: GNU diff -rq 在目录比对时解引用符号链接，悬空链接使校验恒 exit 2——目录树相等校验须用链接安全探针（类型＋cmp 字节＋readlink 目标）
- **标题 2**: 「首个空位」命名 × 保留删除 = 顺序反转：被 prune 释放的名字被新备份复用后，最新备份在 (时间戳,后缀) 序中变最旧；命名须 max+1 单调，保留集须显式保刚写份
- **内容摘要**: 两条均为本链实测（分步 rc 实测／组目录对照）得出的可复用判据，已完整记入本件 Reflexion History 与实施说明；**已写入**: .tad/project-knowledge/ ❌（写集边界 §7.2 外——留 Alex 在 Gate 4 蒸馏时落 patterns/shell-portability.md，本件即其原料）

---

## 📚 Knowledge Usage (MANDATORY — D35 记账装载点)

```json
{"ts": "2026-10-06T13:51:00Z", "chain": "TASK-20261006-TADSH-BACKUP-FIX", "handoff": ".tad/active/handoffs/HANDOFF-2026-10-06-tadsh-backup-fix.md", "step": "implementation (Blake)", "knowledge": [".tad/project-knowledge/principles.md", ".tad/project-knowledge/patterns/_index.md", ".tad/project-knowledge/patterns/shell-portability.md", ".tad/tasks/evidence-collection.md", ".tad/gates/gate-canonical-checklist.md", ".tad/evidence/pm/2026-10-06-tadsh-backup-fix-gate2-merged-ruling.md", ".tad/evidence/risk-cards/risk-TASK-20261006-TADSH-BACKUP-FIX.md", ".tad/evidence/pm/2026-10-06-epic-p3-carryB-ruling.md"], "purpose": "按 deny-list 排除承重、粒度对粒度验证、LC_ALL=C 集合运算、grep $() 须 || true、~ 不作数据路径等既有判据实施备份/回滚改写并构造隔离 fixture 证据"}
```

本链未变更知识层文件（principles/patterns/incidents 索引零增删），故无 brain-index 再生成义务。

---

## ⚠️ Friction Status (MANDATORY — Gate 3 BLOCKING)

| Friction Point | Status | Action Taken | Approval / Substitute Evidence | Gate Impact |
|----------------|--------|--------------|-------------------------------|-------------|
| §8.4 冻结令：真实项目仓禁跑 tad.sh | READY | 全部行为验证走 mktemp fixture（HOME＋TAD_BACKUP_ROOT 双重定向）＋grokbox /tmp 骨架；真实仓仅执行 AC14 原文只读校验链（--verify-denylist 在 trap 前退出、从不安装） | HANDOFF §9.1 AC14 命令原文即该链；§8.6 证据全套在盘 | resolved |
| §8.4 grokbox 真机面需 SSH 可达 | READY | ssh 探活 GB_OK；红/绿两轮骨架复跑落盘 | red-baseline-gb.log、grokbox-test.log | resolved |
| §8.4 detect-state-test 可能不在盘 | READY | `test -f` 在盘，AC14 链内实跑 12/12 PASS | ac14-regression.log | resolved |
| 实施中发现：restore helper 的 diff -rq 校验与 HANDOFF §6 fixture 规格（框架目录内悬空链接）相撞 | READY | 探针改链接安全比对（合同不变），本件与实施说明显式披露 | phase2-test.log restore 用例 B/P/A 清单；Reflexion 3 | non-blocking（留 Gate 3 对披露项裁断） |
| 实施中发现：同秒命名复用使保留排序反转（grokbox 实测） | READY | max+1 单调命名＋保留集兜底＋确定性同秒回归场景 | grokbox-test.log、phase2-test.log retention 用例 | resolved |

---

## 📂 Evidence Checklist (MANDATORY)

### Ralph Loop Evidence
- [x] State file: .tad/evidence/ralph-loops/tadsh-backup-fix_state.yaml
- [x] Summary: .tad/evidence/ralph-loops/tadsh-backup-fix_summary.md

### Expert Review Evidence
- [ ] Code review: 待 Gate 3 独立双审落盘后回填
- [ ] Testing review: 同上
- [ ] Security review: 待 Gate 3 SAFETY 路（删除语义面）

### Acceptance Verification Evidence（HANDOFF §8.6 口径）
- [x] 红基线日志（VM＋grokbox）：.tad/evidence/tadsh-backup-fix-20261006/red-baseline.log、red-baseline-gb.log（14/14 红，最终版脚本对 git HEAD tad.sh）
- [x] Phase 1/2 全绿日志＋restore 全树哈希对照表：phase1-test.log（Phase 1 时点 11 绿＋3 Phase-2 面红）、phase2-test.log（14/14 绿，内含 B/P/A 三段全树清单）
- [x] grokbox 复跑全绿日志：grokbox-test.log（14/14）
- [x] AC14 回归日志：ac14-regression.log（链 rc=0）
- [x] `git diff --stat` 写集自证：见实施说明「写集自证」节（本链文件清单＋先在改动区分）

### Git Commit
- **Commit Hash**: NONE（git 只读，PM 收口管）
- **Verified**: N/A

### Conditional Evidence (from Handoff metadata)
- **E2E Required (from Handoff)**: no（本链 e2e = 隔离 fixture 全场景脚本，已执行并落盘）
- **Research Required (from Handoff)**: no

---

## 🎯 验收检查清单

Blake确认以下所有项：
- [x] 所有 handoff 要求的功能已实现（C1–C7＋增补 S1–S4＋注记 N1–N5）
- [x] 所有测试通过（有证据）（AC1–AC16 逐条实测，见上表）
- [x] Knowledge Assessment 已完成（非空）
- [x] Evidence Checklist 已勾选（required 项；评审项待 Gate 3 回填）
- [x] 无已知阻塞问题（披露项 1 件，留 Gate 3 裁断，不阻塞实施成立）
- [x] 文档已更新（如需要）（tad-update.sh 文案即文档面；session-state 按写集归 PM）

**Blake声明**: 此实现已完成并可交付 Gate 3 独立双审与用户验收。

---

## 📡 PM Bridge (Optional)

PM-Status: Implementation complete: AC1-AC16 measured green in fixture runs on VM and grokbox; independent Gate 3 review pending.
PM-Next: Gate 3 dual review, then GM disk verification for unfreeze; version stays frozen, no standalone release.
PM-Blockers: none

---

## 📝 Human 验收区

**验收时间**: CHECK 待人

**验收结果**: （待人填）

**验收意见**:
- （待人填）

**后续行动**:
- [ ] Gate 3 独立双审（CODE＋SAFETY）→ Gate 4 → PM 报 GM 验盘解冻

---

**Report Created By**: Blake (Agent B)
**Date**: 2026-10-06
**Version**: 1.0

**自报**: 本件字节数与 sha256 在落盘后由 wc -c／sha256sum 实测，随回执上报（自引用值不写进正文）。本链产出文件自报汇总见实施说明末节。

---

## 📎 追记（2026-10-06，Gate 3 SAFETY 条件 F-S1 定点修复 — Blake 续作）

**起因**：Gate 3 SAFETY 路 verdict（`.tad/evidence/reviews/tadsh-backup-fix-20261006/gate3-safety.md`）唯一条件 F-S1（P2）：`resolve_backup_root` 在「备份根经符号链接别名指向目标内既存目录」时，物理拒绝（rc=1）触发前已对该既存目录执行 `chmod 700`（实测 755→700），与 NFR1/C1「变更前中止、零痕迹拒绝」合同不符。关闭条件取 (a)：物理落点判定前置。

**改动（写集仅两件）**：
- `tad.sh` `resolve_backup_root`（现 L488–553，注释头＋函数体）：重排判定与效应顺序——① 字面快速拒绝（不变，无副作用）→ ② **只读物理解析**：既存目录经 `cd … && pwd -P` 解析；存在但非目录（含悬空链接/普通文件）直接报错 rc=1；尚不存在时经最近既存祖先只读解析出预计物理落点 → ③ 空/`/` 安全检查与**物理 inside-target 拒绝**（别名在此被拦，零痕迹）→ ④ 判定通过后才 `mkdir -p`＋`chmod 700`。本调用新建目录照常 chmod；合法既存根（目标外）的收紧 chmod 700 行为保留、移至拒绝判定之后执行。函数头注释已补记此顺序合同。
- `.tad/hooks/lib/tad-backup-test.sh`：新增场景 `root-alias`（现 L629 起，并登记进 `ALL_CASES` 与文件头场景清单）——符号链接别名指向目标内既存目录（755，含两级内容文件）：断言调用 rc≠0、拒绝有日志、该目录**权限保持 755、内容清单与条目集零变化**；同场景第二段钉住保留行为：目标外既存根（755）备份成功且被收紧为 700。

**实测结果（VM 本地）**：
- 新场景单跑：`PASS root-alias`。
- 全套复跑：**TALLY PASS=15 FAIL=0**（原 14＋新 1，全绿）。
- 负控一（判别力）：将修复前函数体拼回当前 tad.sh（/tmp 骨架）跑新场景 → FAIL，签名恰为 `aliased dir perms changed by refused call: 700 (F-S1)`（拒绝本身仍发生），证明场景钉住的正是本缺陷而非功能缺席。
- 负控二：以 git HEAD 版 tad.sh（本链实施前）跑新场景 → FAIL（旧实现无此拒绝路径）。
- `bash -n` 两文件均通过；`.tad/version.txt` 仍 3.1.0，未动；全程未以 tad.sh 碰任何真实项目仓，git 只读。
- grokbox 骨架复跑未做（按派工口径留 Gate 4 前由 PM 决定）。

**新锚（落盘实测）**：`tad.sh` 157,388 B／sha256 `459b9fc92311a837d482fddfd6311cc3d017a28ca5aa8493173753351de87f98`；`.tad/hooks/lib/tad-backup-test.sh` 34,018 B／sha256 `941d36092921f624b21aff7e4dc80d68bb29d504cc9106fd48f4e9684b0b281c`。

**`gate3_verdict` 仍留空**——本追记只补记修复事实，F-S1 关闭与否由 Gate 3 SAFETY 路定点复核此函数后裁定（verdict 关闭条件原文：定点复核即可、无需重审全链）。

---
## 收口追记（PM，2026-10-06）

- gate3_verdict: PASS（CODE CONDITIONAL 的唯一条件＝披露偏离追认，已由 Gate 4 追认关闭；SAFETY CONDITIONAL 的唯一条件 F-S1 经定点修复＋复核 CLOSED）。
- gate4_verdict: PASS（无条件，gate4-alex.md，10,877 B／sha 99ecaa4c…；偏离 `_tad_tree_equal` 正式追认；终版 fixture 两机 15/15）。
- 本链收口：票 CLOSED、HANDOFF 迁 archive。本体修复随 Epic 最终版（v3.2.0）统一发布；解冻报 GM 验盘（解冻≠发版）。
- 残项后续票级：L1744 diff -rq 同病灶换探针、清新建嵌套粒度一格、.tad-migrate-backup 评估——均登记在 Gate 4 verdict R1–R3，PM 后续自查批处置。
- human CHECK 记「CHECK 待人」。
