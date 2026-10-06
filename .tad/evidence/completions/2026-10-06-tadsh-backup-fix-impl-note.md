# 实施说明 — TASK-20261006-TADSH-BACKUP-FIX（给 GM 验盘）

**日期**: 2026-10-06
**实施**: Blake（Execution Master，内部 subagent 会话）
**判据**: HANDOFF-2026-10-06-tadsh-backup-fix.md（44,721 B）＋增补 SUPPLEMENT-1（15,136 B，冲突以增补为准）＋ PM 合并裁定（Gate 2 PASS）
**完工件**: `.tad/evidence/completions/COMPLETION-2026-10-06-tadsh-backup-fix.md`（AC1–AC16 逐条实测在彼）
**版本**: `.tad/version.txt` 未动（3.1.0）——本链不单独发版，随自优化 Epic 最终版统一发布；**解冻与发版是两回事，本件只支撑解冻判定**。

---

## 1. 一句话结论

tad.sh 的升级前备份已从「整份 `.tad` 拷进项目根、从不清」改为「只备框架派生集、默认落 `~/.tad-backups/<仓组>/<时间戳>/`、每组留最新 2 份自动清旧、回滚按 manifest 精确还原」；隔离 fixture 14 场景在 VM 与 grokbox 两机全绿，建议 GM 按 §4 清单验盘后解冻。

## 2. 改动行段（最终盘面行号，供逐段验盘）

| 文件 | 位置 | 内容 |
|------|------|------|
| tad.sh | L82–83 | 新增全局 `TAD_BACKUP_ROOT_ABS=""`、`BACKUP_GROUP=""` |
| tad.sh | L498 起 `resolve_backup_root` | C1：默认 `$HOME/.tad-backups`；env 覆盖须绝对路径；根目录 0700；规范化后等于/落入目标根即在首个变更前拒绝（目标根 = 备份执行时 cwd 的 `pwd -P`，增补 N2） |
| tad.sh | L539 起 `repo_group_key` | C2：basename 清洗；同名异路按完整份 origin 比对分 `-<cksum 前 8 位>`；组目录 0700 由本组件建 |
| tad.sh | L573 起 `prune_backups` | C4：严格名模式枚举；无 manifest 残份先清；完整份 (时间戳,后缀数值) 序留最新 2；删除断言组内前缀＋ `# RM-OK:tad-backup-retention` ＋点名；删失败只 warn；刚写份恒在保留集（兜底） |
| tad.sh | L636 起 `backup_existing`（整段重写） | C3：拷贝集 = `derive_framework_dirs` ∪ `derive_framework_top_files` 直接派生（第二份名单不存在）；capability-packs 只拷 pack-registry.yaml 单文件（S2）；同秒命名取 max 后缀+1 不复用已清名；写序 pre-top.txt → origin.txt → manifest.txt（最后写=完整判据，条目 LC_ALL=C 排序、末行 `version=`）；`BACKUP_PATH` 绝对；项目根遗留 `.tad.backup.*` 一行提示零读写（FR8） |
| tad.sh | L2188 起 `_tad_tree_equal`（新） | **披露项**：链接安全的目录/文件相等探针（类型＋cmp 字节＋readlink 目标） |
| tad.sh | L2220 / L2244 `restore_dir_entry` / `restore_file_entry` | 4 处 stage-verify 由 `diff -rq` 改 `_tad_tree_equal`（两 helper 为回滚 step-1 与 step-2 快照还原共用，**合同与消息不变**，见 §5） |
| tad.sh | L2272 起 `assert_under_backup_root` | C5：备份根下＋严格名模式＋manifest 在，三条全过才放行（换掉旧 `assert_under_root` 在 rollback 的用法；原函数保留供迁移引擎自用） |
| tad.sh | L2285 起 `rollback_on_failure` step-1 | C6：manifest 域逐条目原子还原（路由按备份侧载荷类型、registry 恒走文件路由）；类型翻转/条目失败 → 保留备份、点名报错、跳过清新建（N3/N4）；成功后按 pre-top.txt 判据清本轮新建（保全集 = DENY∪TOP_DENY；包树无无条件豁免，S3.4）→ 消费备份；step-2…5 与无备份分支一字未动 |
| .tad/scripts/tad-update.sh | L185 | 展示串：`Backup: ~/.tad-backups/<repo>/<timestamp> (framework only, keeps latest 2)`（AC16） |
| .tad/hooks/lib/tad-backup-test.sh | 新增（32,069 B） | 隔离 fixture 测试：sed 抽取 tad.sh 真函数执行，14 场景，两机可跑 |

`tad.sh` 3,109 → 3,494 行（+385）。git diff 的 hunk 全部位于上表行段内，可用 `git diff --stat -- tad.sh .tad/scripts/tad-update.sh` 与行号锚对照验。

## 3. fixture 结论（可复跑）

- 命令：`bash .tad/hooks/lib/tad-backup-test.sh`（仓内任意 cwd；`--case <名>` 单跑）。它从不碰真实仓——每个场景自建 mktemp 项目、HOME 与 TAD_BACKUP_ROOT 双重定向。
- 结果：VM 14/14 PASS、grokbox（/tmp/tadfix-green 骨架）14/14 PASS；红基线（最终版脚本 × git HEAD 的 tad.sh）两机 14/14 红、红因均为旧行为。
- 日志全套：`.tad/evidence/tadsh-backup-fix-20261006/`（red-baseline.log、red-baseline-gb.log、phase1-test.log、phase2-test.log、grokbox-test.log、ac14-regression.log）。phase2-test.log 内含 restore 场景的全树哈希对照（备份时点 B / 用户改动后 P / 回滚后 A 三段清单）：框架面回 B、数据面保持 P、A 中框架面与 B 逐行同哈希。

## 4. 解冻判据对应值（GM 验盘要点）

| 冻结令解除判据 | 对应实测值 | 在盘载体 |
|---------------|-----------|---------|
| 备份面 = 框架面、evidence/archive 不再入备份 | manifest 行集与派生集集合相等（diff 空）；≥5M 哨兵文件零入备份；备份载荷 ≈90 B＋元数据 vs fixture .tad ≈5.63 MB（AC1/AC2 PASS) | phase2-test.log / grokbox-test.log 的 set-equality、size 场景 |
| 备份不再落项目根同步盘 | 项目根条目集备份前后逐字不变；默认落 `$HOME/.tad-backups`（HOME 沙箱实测）；根/组目录 700（AC3/AC4 PASS） | location、default-home 场景 |
| 不再无限攒份 | 4 连跑后完整份恒 = 2 且为最新两份；残份优先清；清旧失败只 warn 不阻塞安装（AC5/AC8 PASS） | retention、prune-failure 场景 |
| 回滚读新落点且只动框架面 | 植入目标根内的伪造备份被新闸拒绝（旧闸必放行——判别例）；数据面全树哈希回滚前后相等；条目失败保留备份并点名（AC6/AC7/AC10 PASS） | restore、restore-failure、guard 场景 |
| 真实仓未被跑过 | 本链 git 写集仅 tad.sh＋tad-update.sh 两文件改动（见 §6）；冻结期内无真实仓安装/升级执行记录；冻结的活标本（gm 仓根 `.tad.backup.*`）哈希未动（fixture 内同名构造实测，真实标本零触碰） | §6 写集自证 |
| 版本冻结 | `.tad/version.txt` = 3.1.0，`git diff` 对其为空 | 盘面直查 |

GM 复核最省力路径：仓内跑一遍 `bash .tad/hooks/lib/tad-backup-test.sh`（约 15 秒）看 TALLY 14/14，再按 §2 行号抽查三处（L636 拷贝集派生、L573 删除断言、L2272 新闸）即可。

## 5. 两处必须知道的实施事实

1. **`_tad_tree_equal` 探针替换（已在 COMPLETION 显式披露，留 Gate 3 裁断）**：HANDOFF 指定的 restore helper 用 `diff -rq` 做 stage 校验，但 GNU diff 在目录比对时解引用符号链接——框架目录内的悬空链接（HANDOFF §6 fixture 规格明定、AC13 的合法载荷）使任一目录条目还原必失败（实测 cp rc=0 / diff rc=2，`--no-dereference` 可解但 BSD diff 无此选项）。故 4 处校验改链接安全探针，helper 的原子还原合同不变；step-2 快照还原共用同一 helper、同等受益。verify_install_complete 处的另一处 `diff -rq`（约 L1697）在写集外、未动。
2. **同秒命名复用缺陷是 grokbox 复跑抓到的**（VM 首轮绿）：刷新风暴正是同秒背靠背连跑——run3 的 prune 释放 base 名、run4 复用后排序反转、留 3 份。已修（max+1 单调命名＋prune 保留集兜底），并加 date() 影子确定性回归场景钉死；两机复测全绿。

## 6. 写集自证与边界

- 本链改动文件：`tad.sh`、`.tad/scripts/tad-update.sh`；新增：`.tad/hooks/lib/tad-backup-test.sh`、`.tad/evidence/tadsh-backup-fix-20261006/`（6 件日志）、`.tad/evidence/ralph-loops/tadsh-backup-fix_*`、`.tad/evidence/completions/` 两件（COMPLETION＋本件）。
- **先在于本链的工作区改动（非本链所写，勿归因）**：`.tad/evidence/evidence-collection.md`、`.tad/gates/gate-3-code-review-checklist.md`、`.tad/incidents/_index.md`、`.tad/patterns/_index.md`、`.tad/publish-protocol.md`、`.tad/scripts/brain-index-gen.sh`、`.tad/templates/completion-report.md`、`.tad/brain-index.md`，及 untracked 的 `.tad/evidence/epic-p4-scale/`、`HANDOFF-2026-10-06-epic-p4-scale-a-ruling.md`、`HANDOFF-2026-10-06-tadsh-backup-fix-SUPPLEMENT-1.md`（增补为他人落盘、本链判据）、`risk-TASK-20261006-EPIC-P4-SCALE.md` 等——均为 Epic 其他链在飞件。
- **存量约 150 份 `.tad.backup.*` 的清理归 GM**（用户点头后统一组织）：本链未删、未移、未读任何真实仓存量备份。
- **`.tad-migrate-backup.*` 未动**：tad.sh L3335 一带的结构迁移备份语义不变，建议 PM 另立后续票评估。
- git 只读：无 commit、无 push；`.tad/session-state` 未动（PM 收口管）。
