# brain-index 再生成验证件 — Epic Phase 4 件 4.2（2026-10-06，Blake）

生成器：`.tad/hooks/lib/brain-index-gen.sh`（原稿 sha256 `654086a21b31a99ec04b7b55542e1b4abb643bee394ce829926e4abfafae15e1`，修复后 sha256 `6fcea7454e962f1132bb2c1fb94c0e43994d20ebde2a22f0cadfe102254caf7d`）。修复范围照增补 B1 全量点位：`cut` 12 处＋标题日期后缀 sed 1 处，另脚本头补编码契约＋装载点注释行。节结构与字段口径未动。

## A. 修复实现

- **截断（12 处）**：`cut -c1-120`／`cut -c1-80` 全部改为 `utcut 120`／`utcut 80`——字节上限截断＋剔除尾部不完整多字节序列（perl 原始字节操作，仓内既有工具；结果与 locale 无关）。禁用式「脚本内强制 LC_ALL=C.UTF-8」未采用（B1 明示无效）。
- **标题剥离（1 处，L39）**：原 `sed 's/ *[-—] *…'` 的字节类 `[-—]` 在 POSIX locale 下按字节匹配、可劈裂 `—`——改为 `utstrip_title`：`—` 按其完整 UTF-8 字节序列 `\xe2\x80\x94` 原子匹配，其余语义（可选 `inception`／`AMENDED ` 组＋日期锚尾）与原 BRE 逐项对齐。
- 单元探针（`LC_ALL=C` 环境外亦同）：`utcut` 对「身份精髓」cap 6/7/8 均输出完整字符「身份」（cap 7 时第 7 字节为残字首字节、正确剔除）；ASCII cap、空输入、cap 120 直通均正常。`utstrip_title` 六探针：连字符日期／`—`＋中文标题日期／`— AMENDED` 日期／无日期 inception 保留／Deny-List 全标题／非日期后缀不动——全过。

## B. AC10/AC11 fixture（隔离骨架，`LC_ALL=C` 干跑）

骨架＝真实 `principles.md`＋`AGENTS.md`＋patterns `_index.md` 副本＋空节目录，新旧生成器同跑对照：

| 生成器 | 严格 UTF-8 解码 | NEL(U+0085) 计数 | §1 标题行（16 行）与源标题去后缀后逐字比对 |
|---|---|---|---|
| 修复后 | **OK** | **0** | **16/16 全等** |
| 修复前（对照） | FAIL（byte 759 处） | — | 不符 |

判别力：同一 fixture 对旧生成器判 FAIL、对新生成器判 PASS——AC10 非空过。
AC11 两行分段判读（照 B2）：Deny-List 行——标题段（sed 剥离损段）产物为 `Deny-List Beats Allow-List for Sync Sets; Version Grep Must Scope to git-ls-files; diff-r is the Universal Omission Catcher`，与源标题去日期后缀后逐字相等；AI/Human 行——标题本身未损、摘要段（cut 损段）产物可严格解码、无残字，标题 `AI/Human Judgment Domain Awareness — Agent 应自觉判断域归属` 与源标题去后缀后逐字相等。

## C. AC12/AC13 真仓首轮复产

- 实跑：`LC_ALL=C bash .tad/hooks/lib/brain-index-gen.sh` → `.tad/brain-index.md` 298 行／27,432 B（复产前 24,904 B／2026-09-16）。
- 编码：严格解码 OK、NEL 字符计数 0。
- check7 回读：`INFO check7: brain-index generated 2026-10-06, age 0d`（无 WARN 行）；state-surface 全检 exit 0（PASS，version 3.1.0）。
- 覆盖抽核：`runtime-adapter-instance-{codex,cursor,opencode}` 三行在册（§2 patterns 行经步 2 补索引传导）、`EPIC-20261006` 行在册、§1 Principles 行数 16 ＝ `principles.md` 的 `###` 计数 16。

## D. AC12B 置旧向判读（增补 B3）

隔离副本将 Generated 回填 `2026-09-20`（age 16d）跑 state-surface：输出 `WARN check7: brain-index age 16d exceeds 14d (advisory; not counted as FAIL)`——出现 WARN 且明示 advisory 不计 FAIL（骨架缺根文件引起的 check1/3 FAIL 为骨架伪影，与 check7 判读无关）。结合 §C 新鲜向（age 0d、INFO、无 WARN），件 1.9 断言双向实测齐备。

## E. 基线口径注记

设计锚记在盘索引「NEL 15」为孤立 NEL 计数；Phase 0 原始字节计数为 17（含合法多字节序列续接字节）。本件与 AC10 的 NEL 判据统一为：**严格解码后 U+0085 字符计数**（复产产物＝0）。

## F. AC14/AC15 fixture — tad.sh 刷新路径接线（Phase 1 步 4 续做，2026-10-06，Blake 续做）

**串行前置（增补 B5）**：备份修复链已收口提交 `f9f397bc`；续做开工复算 tad.sh sha256＝`459b9fc92311a837d482fddfd6311cc3d017a28ca5aa8493173753351de87f98`，与修复后新锚全等，方开工。

**接线 diff（tad.sh 一处）**：`upgrade` 分支 `copy_framework_files "$TAD_SRC"` 之后、迁移引擎之前，新增与初装分支逐字相同的注释＋调用（+4 行）。调用点终态（grep）：定义 L1409、初装 L3225、**刷新 L3324**——覆盖初装与刷新两路。接线后 tad.sh sha256＝`0eaa2d18d6046cfdfd751d7500466f6e07d31c0b6e804bfbe0527f13457b58c7`；`bash -n` 通过。ASM-3 对照：初装路径与既有刷新语义零改动，diff 恰一处调用点（函数自带缺生成器/失败双 WARN 守卫，未新增守卫代码）。

**骨架 fixture 三跑**（隔离目录、HOME 重定向至 fixture 内、`bash tad.sh --source <源> --platform codex --yes` 全程实跑；源＝本仓在盘树，负控源为排除 `.git`/`.worktrees`/evidence/archive 的拷贝）：

| 跑 | 形态 | 结果 |
|---|---|---|
| 1 刷新正控 | 老装机骨架（`.tad/version.txt`＝3.0.2、无 brain-index、预置 handoff 哨兵件）以本仓为源刷新 | **PASS**：日志 `Upgrading to v3.1.0...`；生成行位于框架同步（日志 L35）之后、迁移引擎（L47）之前——新调用点实火；产物 `.tad/brain-index.md` 存在，`Generated: 2026-10-06`（当日），120 行／5,954 B，sha256 `6df99aef…`；python3 严格 UTF-8 解码 OK、NEL＝0；version.txt→3.1.0；哨兵件完好（deny-list 未伤项目数据） |
| 2 初装回归 | 空目录以本仓为源初装 | **PASS**：`Installing TAD Framework...` 路生成 brain-index（`Generated: 2026-10-06`，sha256 `af87b88d…`），严格解码 OK、NEL＝0，version.txt＝3.1.0——初装路不回归 |
| 3 缺生成器负控 | 源拷贝刻意剔除 `.tad/hooks/lib/brain-index-gen.sh`，老装机骨架（3.0.2、无生成器无索引）刷新 | **PASS（fail-open）**：exit 0、刷新全程完成（version.txt→3.1.0）；WARN 原文 `brain-index generator not present in target tree: .tad/hooks/lib/brain-index-gen.sh — .tad/brain-index.md was not generated`（日志 L46，位置在同步后/迁移前）；brain-index.md 未生成——只 WARN 不中断、不静默，与初装路径同一函数同一口径 |

**tad.sh 自检段（AC27 相关项）**：三跑均实装触发并通过——`Self-check passed: 91 derived paths (diff-clean) + 23 top-level files present (platform: codex)`，三跑 exit 均为 0、均以 `✅ TAD v3.1.0 Ready!` 收尾。

过程留痕：负控源首建走 /tmp（512M tmpfs）中途空间不足失败，已删除残拷贝、改落 home 盘仓外 scratch 重建（85M）后跑通；fixture 目录与负控源均为一次性隔离面，跑后清除，关键值已全量转录本节。
