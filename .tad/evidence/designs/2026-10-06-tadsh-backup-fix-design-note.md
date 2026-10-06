# 设计说明 — tad.sh 备份面收窄与落点迁移（TASK-20261006-TADSH-BACKUP-FIX）

**作者**：Alex（Solution Lead）｜**日期**：2026-10-06｜**票**：`.tad/active/TICKET-20261006-tadsh-backup-fix.md`
**配套 HANDOFF**：`.tad/active/handoffs/HANDOFF-2026-10-06-tadsh-backup-fix.md`

## 1. 现状实测（亲读 tad.sh 全路径，行号以 2026-10-06 盘面为准）

### 1.1 备份/回滚面清单

| 面 | 位置 | 现行行为 |
|---|---|---|
| `backup_existing()` | tad.sh L483–503 | 目标仓已有 `.tad` 时 `cp -R .tad ".tad.backup.$(date +%Y%m%d_%H%M%S)"`（同秒碰撞后缀 `.n` 递增，FR-1）；落**项目根**（同步盘内）；整份复制、零排除；失败即中止（set -e→EXIT trap）；结果存全局 `BACKUP_PATH`（相对路径） |
| 调用点 | tad.sh L2772（main 流程内） | 下载/版本校验/平台解析/冲突预检/人确认**之后**、首个项目变更之前调用一次；随后 `NEED_ROLLBACK=1`（L2774）+ `take_rollback_snapshot`（L2777） |
| `take_rollback_snapshot()` | L1885–1915 | 把 `BACKUP_PATH` 绝对化为 `BACKUP_PATH_ABS`；另在 tmp 建 `ROLLBACK_SNAP`（mktemp 0700）快照 AGENTS.md/GEMINI.md/.codex/hooks.json/.agents/skills 与预存顶层清单 `ROLLBACK_PRE_TOP`；**不**快照 .tad 内部（.tad 归 step-1 独占） |
| `rollback_on_failure()` | L1985–2127 | EXIT trap 在 `NEED_ROLLBACK=1` 时触发。step-1（L2000–2019）：`BACKUP_PATH_ABS` 须过 `assert_under_root`（L303，根内防线），`restore_dir_entry` 把备份**整目录**原子换回 `$TARGET_ROOT/.tad`，成功后 `rm -rf` 消费备份；失败则保留备份并大声报错。无 BACKUP_PATH 且 .tad 在 = 全新安装 → 整删 .tad。step-2 清单驱动恢复快照件；step-4/4b 清本轮新建件；4d 枚举 `.tad-migrate-backup.*` 与 `.tad-backup/` 为「保留待人工恢复」 |
| 三入口 | `detect_state`（L2247）+ main case | `install`（fresh/partial）、`upgrade`（同大版本旧版）、`migrate`（跨大版本/old/v1.x）三路**共用** L2772 的 `backup_existing`——修一处即覆盖三入口 |
| migrate 结构备份 | L2940–2951 | migrate 路另有 `.tad-migrate-backup.<ts>` 整份复制落项目根——是旧布局**数据救援源**（运行中从中拷出用户数据），语义不同，见 §6 边界 |
| 引擎 `.tad-backup/` | L1666–1784（call_migration_engine 内 do_backup） | 迁移引擎按条目备份被删条目（`$TARGET/.tad-backup/<from>-to-<to>/`），与 backup_existing 无关，不在本票面 |
| 更新器 tad-update.sh | `.tad/scripts/tad-update.sh` | apply 走下载的 tagged tad.sh（备份逻辑不在更新器内）；仅 L185 展示串写着 `Backup: .tad.backup.<timestamp-or-unique-suffix>`，须随新落点改字面 |
| 独立 rollback 命令 | 不存在 | 回滚只有同轮 EXIT-trap 一条路；`BACKUP_PATH` 是轮内变量——**任何代码都不跨轮读 `.tad.backup.*`**（grep 全仓证实：除注释/枚举外无读者） |

### 1.2 体量实测（本仓 .tad，2026-10-06）

- `.tad` 总计 **163M**。其中 `evidence` **133M**、`archive` **17M**——两数据面合计 150M ≈ **92%**。
- 安装器实际写面（deny-list 派生集）各目录 du -sm 求和 ≈24M（du 按目录向上取整），票面口径约 15M；无论哪个数，备份面收窄后回 **MB 级**成立。
- 本机活标本：`yun-sync/gm/` 仓根现存 `.tad.backup.20260917_143603`、`.tad.backup.20261004_232810`、`.tad.backup.20261005_150258`、`.tad.backup.20261006_115001` 四份＋`.tad-migrate-backup.*` 一份——缺陷形态与票面一致（GM 证据件原文未同步到本 VM，票面为权威转述）。

### 1.3 可复用的现成机制（不新立第二套）

- **deny-list 派生**：tad.sh L569–594 内嵌 `TAD_ZERO_TOUCH`（A 类 12 项）∪ `TAD_TRANSIENT`（C 类 5 项）＝ `TAD_DENY_LIST`，`TAD_TOP_DENY`（sync-registry.yaml、brain-index.md），`TAD_REGISTRY_ONLY=capability-packs`（只同步 pack-registry.yaml）；派生函数 `derive_framework_dirs`（L603）、`derive_framework_top_files`（L622）已是安装器**写面**的定义，且与 `.tad/hooks/lib/derive-sync-set.sh` 有 `--verify-denylist` 漂移闸看守。备份面直接复用同一派生 ⇒「备份面 ≡ 安装器写面」由构造保证，不新增第二份清单。
- 同秒碰撞递增后缀循环（L486–493）、`cp -R` 大写 -R（BSD 悬空符号链接纪律）、`restore_dir_entry/restore_file_entry` 的 stage-verify-rename 原子还原、`# RM-OK:` 删除标注惯例——全部沿用。

## 2. 设计决策

### D-1 备份集定义：备份面 ≡ 安装器写面（deny-list 派生，逐路径定清）

备份集 B ＝ 在**目标仓现有** `.tad` 上求值：`derive_framework_dirs(".")` ∪ `derive_framework_top_files(".")`，外加子路径规则 `capability-packs/pack-registry.yaml`（仅注册表文件，树身不入）。以本仓 `.tad` 顶层逐项定清（规则生成，正反两面）：

**进备份（框架与配置面）**：agents、codex、context、cross-model、data、eval、gates、guides、hooks、logs、migrations、ralph-config、references、regression-samples、runtime-compat、schemas、scripts、skills、sub-agents、tasks、templates、tests、workflows（以上为当前在册的非 deny 目录；**新目录默认进**——deny-list 方向，与 principles「Deny-List Beats Allow-List for Sync Sets」同向）；顶层文件除 deny 两件外全进（CHANGELOG.md、README.md、TAD-POINTER.md、TAD-VERSION、config*.yaml、deprecation.yaml、discipline-floor*.md、manifest.yaml、mcp-registry.yaml、platform-codes.yaml、portable-extract.sh、portable-rules.md、project-detection.yaml、routing-contract.yaml、skills-config.yaml、version.txt 等）；`capability-packs/pack-registry.yaml` 单文件。

**排除（数据面，逐项）**：`evidence/`（133M，证据数据面）、`archive/`（17M，归档数据面）、`active/`（在飞工作面：handoffs/epics/session-state）、`project-knowledge/`（各仓自有知识，安装器 zero-touch 从不写）、`pair-testing/`、`decisions/`、`dependencies/`、`github-registry/`、`research-notebooks/`、`skill-library/`、`skillify-candidates/`、`memory/`（以上 A 类 zero-touch 12 项全列）、`working/`、`spike-v3/`、`reports/`、`checklists/`、`domains/`（C 类 transient 5 项全列）；顶层文件 `brain-index.md`（各仓生成物）、`sync-registry.yaml`；`capability-packs/` 树身（仅注册表入，理由：树身是各仓可独立 fork 的包体，安装器同步时也只对注册表负责）。

**判据（一句话）**：安装器从不写的路径，备份不需要备；安装器会写的路径，备份必须备全。排除集若漏一项框架面 → 回滚还原不全（REQ-1 证伪信号抓）；备份集若多含一项数据面 → 体量与「同步盘外落点」目的同时落空（同信号抓）。

**防递归（三层）**：① 落点在项目树之外（D-2），`.tad` 内永不出现备份目录，`cp -R` 源集合由派生函数枚举、逐项拷贝，天然不含备份自身；② 硬闸：解析后的备份目标若落在 `$TARGET_ROOT` 之内（env 覆盖误设）→ 首个变更前拒绝并中止；③ 冗余防御：拷贝循环对名为 `.tad.backup.*` / `.tad-migrate-backup.*` 的条目显式跳过（即使将来有人把备份塞回 .tad 内也不会自吞）。

### D-2 落点与命名

- 根：`${TAD_BACKUP_ROOT:-$HOME/.tad-backups}`（env 覆盖遵循仓内 env-var 惯例，供隔离测试与 grokbox 骨架重定向；须为绝对路径、不得解析进目标根，否则拒绝）。
- 结构：`<根>/<仓组键>/<时间戳>[.n]/`，时间戳沿用 `%Y%m%d_%H%M%S`＋同秒递增后缀（复用现循环）。
- 仓组键：目标根 `pwd -P` 的 basename，字符清洗（`[A-Za-z0-9._-]` 外 → `_`）。同名异路防撞：每份备份内写 `origin.txt`（目标根规范绝对路径）；若组内已有备份的 origin 与当前目标不一致 → 本组键改用 `<basename>-<cksum(规范路径) 前 8 位>`（cksum 为 POSIX/BSD 安全）。保留策略按最终组键分组，互不串扰。
- 每份备份内容：`.tad/` 子树（仅备份集条目，保持相对结构）、`manifest.txt`（逐行：备份集顶层条目名；末行 `version=<version.txt 内容>`）、`origin.txt`。**manifest 最后写**——manifest 在 ＝ 完整备份的标记（保留计数与回滚消费都只认带 manifest 的份）。
- 权限：根与仓组目录创建时 `chmod 700`（与 ROLLBACK_SNAP 0700 先例一致；备份含配置面，按用户私有数据对待）。
- `BACKUP_PATH` 自创建起即为**绝对路径**（新落点天然绝对）；`take_rollback_snapshot` 的绝对化逻辑不变。

### D-3 保留策略（每仓最近 2 份，写新自动清旧）

- 时机：新份**完整写入并落 manifest 之后**才清旧；备份失败（中止安装）不清任何旧份。
- 对象：仅本仓组键目录内、名合严格模式 `^[0-9]{8}_[0-9]{6}(\.[0-9]+)?$` 的目录。排序 `LC_ALL=C sort`（时间戳名的字节序即时序，同秒后缀排其基名之后——区域排序坑纪律：凡枚举一律 LC_ALL=C）。
- 计数：只数带 manifest 的完整份，保留最新 2 份完整份；无 manifest 的残份（中断的 cp）不占名额、优先清除。
- 删除：逐份 `rm -rf` 并加 `# RM-OK:tad-backup-retention` 标注（仓内删除收口惯例）；删除前断言该路径在仓组目录内（前缀校验）。
- **清旧失败的行为（写死）**：best-effort——`log_warn` 记明份名与原因，**不**中止安装、**不**删刚写的新份、**不**扩大删除范围重试。代价上限＝多留几份 MB 级备份，与正确性无关。这一条是风险卡 REQ-2 的对应需求。

### D-4 rollback 读新落点（两处必改，缺一即回归）

1. **根外防线换锚**：step-1 现以 `assert_under_root "$BACKUP_PATH_ABS"` 把关——新落点在根外，该断言必然拒绝，回滚会大声拒绝并保留备份（不丢数据，但失败安装失去自动还原＝功能退化，违票面第 4 条）。改设专用闸 `assert_under_backup_root`：规范化后的 `BACKUP_PATH_ABS` 必须 ① 位于规范化备份根之下；② 基名合时间戳模式；③ 内含 manifest.txt。三条全过才许 step-1 消费（含成功后 `rm -rf` 消费备份——删除语义改由本闸背书，`# RM-OK:` 标注同步改注）。防线意图不变：绝不对任意路径做还原/删除，只认本机制自产的备份。
2. **还原语义改清单域**：现 step-1 是整目录换回（`restore_dir_entry 备份 → .tad`）——备份不再含数据面后，整换会把目标的 evidence/archive/active **删掉**（备份里没有 → 换回后不存在），是本设计最危险的一步。改「manifest 域还原」：
   - 逐条目还原：对 manifest 每行 E，用现有 `restore_dir_entry`/`restore_file_entry` 原子还原 `$BACKUP/.tad/E` → `$TARGET_ROOT/.tad/E`；`capability-packs/pack-registry.yaml` 以文件粒度还原，capability-packs 目录本身永不整删。
   - 清本轮新建：当前 `.tad` 顶层条目 C 若不在 manifest 且不在数据面保全集（＝ `TAD_DENY_LIST ∪ TAD_TOP_DENY ∪ {capability-packs}`）→ 判为本轮新建的框架条目，经 `assert_under_root` 后删除（与现 step-4 的「只删本轮所建」哲学一致）。
   - 数据面条目：不在 manifest 的数据面条目**一律原样保留**——包括备份之后被用户/其他进程改动过的（安装器从不写它们，还原也无权碰）。
   - 任一条目还原失败：沿现行合同——已还原条目保持、备份**整体保留**不消费、大声报错点名路径、`_kept_list` 记账；覆盖清单消息（L2123）照旧逐面列 restored/removed/preserved。
   - 无 BACKUP_PATH 的全新安装分支（整删 .tad）**不变**（那时 .tad 全部为本轮所建，无数据面可伤）。
- 与承接 B 的对齐仅限验证法：承接 B 转常设的回退还原验证法＝「变更前全树哈希 → 操作 → 还原 → 全树哈希对照」，本链 AC 的还原验证沿用同法——fixture 全 `.tad` 哈希前后对照，框架面须逐字节回到备份时点、数据面须逐字节等于「备份后用户改动完」的时点。两个断言面（还原面＝manifest 条目集／全 `.tad` 面）合称**本链 AC6 断言对**，为本链自有命名：承接 B 裁断（`.tad/evidence/pm/2026-10-06-epic-p3-carryB-ruling.md`）的分子/分母唯一指其 (ii) 维工时口径，本链不复用该术语指称断言对，不另立第二套判据。
  〔订正注记 2026-10-06：本段原稿把「分子＝还原面、分母＝全树面」归于承接 B 裁断名下并称「分子分母同定义」；经 Gate 2 契合路评审 F-1 亲读裁断件指出该归属不实——裁断写死的分子/分母唯一指 (ii) 维工时口径（分子＝稳态周期耗时、分母＝链工时）。已按 PM 合并裁定 S1 改写如上，原句删除，特此留痕，不静默订正。增补件：`.tad/active/handoffs/HANDOFF-2026-10-06-tadsh-backup-fix-SUPPLEMENT-1.md` S1。〕

### D-5 存量旧备份兼容：显式不管（附判据）＋一行可见性

- 判据：① 回滚只读同轮所建备份（`BACKUP_PATH` 轮内变量，见 §1.1），修复后任一轮的备份必为新格式新落点，**不存在跨版本混读状态**；② 旧 `.tad.backup.*` 今天就没有任何自动读者，纯人工恢复件——不管它，零功能回归；③ 若做「双读过渡」，第二条还原路径必然是整目录语义，与 D-4 清单域还原正面冲突，为零收益引入最高风险面。
- 结论：**不双读**。仅加可见性：`backup_existing` 执行时若项目根存在 `.tad.backup.*` 旧份，`log_info` 一行提示「遗留备份仍在项目根，仅供人工恢复，本机制不再读写」。
- 约 150 份存量清理：票面明示等用户点头后 GM 统一组织，**本链不碰**（写集外）。

### D-6 相邻面边界（盘点过、明确不做）

- `.tad-migrate-backup.*`（L2940）：整份复制同病形态，但它是旧布局迁移的**数据救援源**（运行中要从中读用户数据），且每仓一生至多触发一次（跨大版本），非刷新滚存来源。收窄它需另行设计救援语义——出本票写集，建议 PM 另立后续票跟踪，本链 HANDOFF 明记此边界。
- 引擎 `.tad-backup/`（L1666 起）：按条目备份被删条目，体量由弃用规模决定，非整份复制——不同机制，不动。
- ROLLBACK_SNAP（tmp 0700）：已在盘外、成功即消费，不动。

## 3. 写集与装载点（Gate 2 Load points）

| 文件 | 改动 | 装载点（谁在何时读到） |
|---|---|---|
| `tad.sh` | `backup_existing` 重写（派生集拷贝＋新落点＋manifest/origin＋保留清理＋遗留提示）；新增 helper（备份根解析/仓组键/清旧/新防线闸）；`rollback_on_failure` step-1 换闸＋清单域还原；相关注释与 RM-OK 标注同步 | 安装器本体：curl\|bash / npx / tad-update.sh apply 三路最终都执行 tagged tad.sh，安装/升级/迁移每次运行即装载 |
| `.tad/scripts/tad-update.sh` | 仅 L185 展示串改新落点文案 | 每次 `tad-update.sh` check 输出即装载 |
| `.tad/hooks/lib/tad-backup-test.sh`（新建） | 隔离 fixture 测试（mktemp 沙箱＋HOME/TAD_BACKUP_ROOT 双重定向；函数以 sed 抽取真源执行，沿 detect-state-test 先例，不测复制品） | Gate 3 逐行执行＋Gate 4 复算；发版面是否入 release-verify 本链不改（记为后续候选，不在本写集） |

仓外零写；真实项目仓零运行（冻结令）；legacy 备份零触碰。

## 4. 验证设计（隔离测试仓，真机面 grokbox 骨架）

fixture 构造（沙箱项目）：框架目录＋哨兵文件、数据面目录（evidence 放 ≥5M 填充＋唯一哈希哨兵）、顶层 deny 两文件、capability-packs（注册表＋包树哨兵）、框架目录内悬空符号链接（BSD -R 例）、项目根预置一份旧 `.tad.backup.20000101_000000`。场景 T1–T10 与 HANDOFF §9.1 的 AC1–AC14 一一对应（备份集集合相等/体量、落点与根零新增、保留计数与残份、同秒碰撞、清单域还原全树哈希对照、还原失败保留备份、清旧失败不阻塞、同名异路分组、新防线拒绝根外伪路径、env 覆盖指进项目被拒、遗留备份零触碰、默认 HOME 落点、--verify-denylist 与 bash -n 回归）。细节以 HANDOFF §8/§9.1 为实施正本。

## 5. 风险摘要（全文见 HANDOFF §11 风险卡草案）

最高风险三条：清旧误删（删除语义，靠严格名模式＋组内前缀断言＋只删非最新 2 份封顶损失面）；清单域还原漏面/伤数据面（靠 manifest 集合断言＋全树哈希对照抓）；新防线换锚后被绕（靠负控 fixture：伪造根外路径必须被拒）。三条均有可观察证伪信号与停/回滚动作，草案已成，Gate 2 派发时由 PM 按草案落卡 `.tad/evidence/risk-cards/risk-TASK-20261006-TADSH-BACKUP-FIX.md`。
