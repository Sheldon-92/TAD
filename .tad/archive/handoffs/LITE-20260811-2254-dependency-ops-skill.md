# LITE Handoff: dependency-ops capability skill + 真实依赖变更 dogfood

**Date**: 2026-08-11
**Revision**: 4（rev1 FAIL 4×P0 → rev2；复核 1 CONDITIONAL：原 4 全 CLOSED + 4 个新 P0 → rev3；
复核 2 CONDITIONAL：4 个新 P0 全 CLOSED + 1 P0 / 2 P1 / 5 P2 → 本版。
⚠️ 三轮的新缺陷高度同形：**修复只落到成对表述的一半**）
**Series**: Epic full-capability-extraction-retirement **Phase 4**（10 格中的第 6 格；3c/F8 已闭）

## 目标（含"为什么"）

CLAUDE.md §2 明列 `*deps` 系列为 **lite 已知无等价物**（"操作协议在 full `references/` 内，
lite 读取权限明确排除"）。本单建 `dependency-ops` capability skill 关闭该缺口，
并**在同一单内用一次真实依赖变更 dogfood 它** —— 只建不跑等于交付一个从未被执行过的协议，
这正是 F8 刚验证过的失败家族（机制存在 ≠ 机制可达）。

dogfood 对象已在设计期实测确定：**`gh` 2.96.0 → 2.97.0**（上游 2026-07-31 发布，11 天前；
`gh` 是 L1 tier，安全缓冲 7 天 → 11 > 7，**恰好越过可评估线**）。同期 `yq` 与 `jq` 的上游版本
与本地完全相同 —— 也就是说这一轮**恰好只有一个依赖动了**，既不是零变更（检测不出东西、
空跑）也不是一堆变更（噪声淹没判别力）。

## 不做什么

- **不迁 `deps_init`**：TAD 的 registry 早已存在，`init` 是一次性能力；迁一个永不被调用的能力
  只增加表面积。归入 Phase 5「次级能力处置」。
- **不改 `.tad/hooks/lib/deps-scan.sh`**：复用，不重写。新 skill 只编排它。
- **不动 full**：不改 `.claude/skills/alex/SKILL.md`、不改 `deps-protocol.md`。退休 full 是 Phase 8。
- **不 push / 不打 tag / 不 sync**。
- **不升级 `gh` 以外的任何 Homebrew formula**。
- 不改 REGISTRY.yaml 中 `gh` 以外的任何依赖条目。

## 背景事实（设计期实测，附载体）

1. **源协议共 4+1 个子协议、176 行**：`deps_show` / `deps_init` / `deps_add` / `deps_check` /
   `deps_update`（`.claude/skills/alex/references/deps-protocol.md`）。判断内核（tier buffer、
   relevance、limitation resolution）在 **`/alex` SKILL body 的 STEP 3.5b**，不在该 reference 内。
2. **`deps-scan.sh` 存在且可执行**（10636 字节，`.tad/hooks/lib/deps-scan.sh`）；
   模板 `.tad/templates/deps-registry-template.yaml` 存在。
3. ⚠️ **扫描结构性只覆盖一半**：协议 Notes 明写 `registry: null` 的依赖被跳过。实测 registry 中
   `notebooklm-cli` / `rsync` / `claude-code-cli` 三者 `registry: null` → **永远 skipped**。
   本 skill 覆盖 3/6，**不得声称覆盖 6 个**。
4. ⚠️ **源协议含一条跨 session 悬空依赖**：`deps_update` 第 5 步要求"查**本 session** 里
   STEP 3.5b 标记过的 `potentially_resolved`"。STEP 3.5b 是 **full Alex 的启动扫描**，
   而 **lite 不跑任何启动扫描** —— 照搬会得到一个永远指向空气的引用。本单必须切断它（见 D2）。
5. **全部 6 个依赖当前均已逾期**：`last_checked` 全为 `2026-07-14`（28 天前）。
   L1 窗口 7 天 → `gh`/`yq`/`jq`/`rsync` 逾期 21 天；L2 窗口 14 天 →
   `notebooklm-cli`/`claude-code-cli` 逾期 14 天。
6. **`scan-results.yaml` 语义已陈旧**：`last_scan: 2026-07-14`，其中 3 个成功项全标
   `version_changed: true`，但 registry 在 **7-15** 就把版本钉成了扫描所见的值 ——
   扫描结果比 registry 早一天，那三个 `true` 现已不成立。
7. **上游实测与 `version_changed` 的真实算法（rev2 更正：rev1 的论证来源是错的）**：
   `deps-scan.sh:236-243` 的判据是
   `sed 's/^v//' <upstream_latest>` **!=** `sed 's/^v//; s/\.x$//' <current_version>`，
   **不与上一次扫描结果比**。而 `gh`/`yq`/`jq` 在 REGISTRY 里都是 `registry: homebrew`
   （L53/L83/L118），走 `deps-scan.sh:148-154` 分支，故 `upstream_latest` 取自
   **`brew info --json=v2 <name> | jq -r '.formulae[0].versions.stable'`**，**不是 GitHub release tag**。
   实测：`brew info` 给出 `gh=2.97.0` / `yq=4.53.3` / `jq=1.8.2`；本地 `2.96.0` / `4.53.3` / `1.8.2`
   → `true` / `false` / `false`，AC7 三条断言成立。
   ⚠️ rev1 用 GitHub tag（`jqlang/jq` = `jq-1.8.2`）论证同一结论 —— **结论侥幸对，论证链是断的**：
   若某条目改成 `github_releases`，`sed 's/^v//'` 剥不掉 `jq-` 前缀，`jq-1.8.2 != 1.8.2`
   会误报 `true`。本单不改任何 `registry` 字段。
   （这正好撞上本契约自己引用的 `ac-verification.md` 2026-08-11 第 (1) 条：判据须逐字取自实现。）
8. **命名与结构约定**：kebab-case 目录 + `name:`/`description:` YAML frontmatter（缺失则安装成功
   但 skill **静默永不激活**，`pack-build-rules.md` 2026-05-07）。Phase 3a 先例 `release-runbook`
   为 148 行 SKILL + `references/`。

## 设计决定

- **D1 — 单文件，不拆 references。** 源协议仅 176 行 4 个子协议。拆 references 会触发
  circular trigger（`load_when` 引用只在 reference 内定义的步骤，`principles.md` 2026-06-09），
  且 lite 读 reference 需额外授权 —— 等于把刚解决的问题重新造一遍。
- **D2 — 切断跨 session 依赖（承接背景事实 §4）。** `deps_update` 的 limitation-resolution 判定
  输入改为**当次 check 取得的 `changelog_text`**（同一单内可获得），不再引用任何启动扫描输出。
- **D3 — 形态为 skill 而非 MCP。** 判据（`pack-build-rules.md` 2026-06-23）："把工具名全删掉还有
  价值吗" → tier buffer / relevance / limitation resolution 全是判断，有价值 → skill 正确。
- **D4 — 真实升级 `gh`，不做 fixture。** `deps_update` 记录的是"某依赖**已被**升级"；
  不真升级则该子协议整条不可达，AC 变成空跑。⚠️ 这是本单唯一的系统级变更，见 mandate。

## 文件清单

**创建**：
- `.claude/skills/dependency-ops/SKILL.md`
- `.agents/skills/dependency-ops/SKILL.md`（逐字节镜像，parity 是发布门）
- `.tad/evidence/acceptance-tests/dependency-ops-skill/`：`source-coverage.md`（AC1 映射表）、
  `AC*.txt`、`brew-before.txt` / `brew-after.txt`、`registry-before.yaml`、`scope-baseline.txt`、
  `findings.md`
- `.tad/evidence/journal/dependency-ops-skill.md`

**修改**：
- `.tad/dependencies/REGISTRY.yaml`（**仅 `gh` 条目**的 `current_version` / `version_pinned_at` /
  `last_checked`；⚠️ **用 Edit 工具，禁用 `yq -i`** —— DEP-003 记载 `yq -i` 会规范化整个文件）
- `.tad/dependencies/scan-results.yaml`（由 `deps-scan.sh` 自行改写，不手改）

## 实现约束

- ⚠️ **日期一律运行时自导出，禁止硬编码。** 开工第一条命令**逐字为**：
  ```
  ROOT="$(git rev-parse --show-toplevel)" && \
  test "$ROOT" = "/path/to/TAD" && \
  mkdir -p "$ROOT/.tad/evidence/acceptance-tests/dependency-ops-skill" && \
  date "+%Y-%m-%d" > "$ROOT/.tad/evidence/acceptance-tests/dependency-ops-skill/TODAY.txt" && \
  test -s "$ROOT/.tad/evidence/acceptance-tests/dependency-ops-skill/TODAY.txt" && \
  cat "$ROOT/.tad/evidence/acceptance-tests/dependency-ops-skill/TODAY.txt"
  ```
  **三条都不可省**：
  `git rev-parse` + 等值断言**锁住 cwd**（本契约 L170 已认定"Bash 工具的 cwd 不保证"，
  该前提对本条同样成立）；`mkdir -p` 防目录不存在（裸重定向实测 `exit 1`）；
  `test -s` 防"重定向早于命令查找"留下的空文件（`shell-portability.md` 2026-08-05）。
  ⚠️ **`mkdir -p` 单独使用会把一次响亮的失败换成静默的成功**：cwd 错时整条链仍 `exit 0`，
  TODAY.txt 落在别处，后续断言自洽地读同一个错文件，直到收尾才发现 evidence 目录是空的
  （已实测复现）。**P0-NEW-4 之所以被抓到，正因为裸重定向 `exit 1` 叫得很响。**
  该命令须在 `preflight-baselines` 内、且早于 `scope-baseline.txt` 采集。
  此后**所有日期断言一律用 `"$(cat "$ROOT/.tad/evidence/acceptance-tests/dependency-ops-skill/TODAY.txt")"`**，
  AC11 的 `grep -Fxq` 命令同样改用 `$ROOT` 前缀。
  rev1 把 `2026-08-11` 写死在 AC5/AC8/AC11 里，而本单跨零点几乎必然（契约写于 22:54）——
  那会在**正确执行**上判 FAIL。
  若 `TODAY` ≠ `2026-08-11`，AC8 的期望值按
  `overdue_L1 = (TODAY − 2026-07-14) − 7`、`overdue_L2 = 同式 − 14` 重算，并在 `findings.md`
  记录重算依据。evidence 目录与 journal 一律用不带日期的
  `dependency-ops-skill` / `dependency-ops-skill.md`，避免路径漂移。
- **Bash 工具跑 zsh 5.9**：禁 `for f in $VAR`、禁数组、禁 `\<`、禁裸 glob；变量一律加引号
  （`patterns/shell-portability.md` 2026-08-05）。
- **任何 `comm` / `sort` 集合运算，两侧 `sort` 与 `comm` 都要加 `LC_ALL=C`**
  （`shell-portability.md` 2026-05-31 CJK 幻影交集 / 2026-08-05 `comm` 在非全局排序输入上静默说谎）。
  AC14 的围栏比对适用本条（仓库 884 条 porcelain 条目，路径含空格与中文）。
- **所有 `brew` 调用一律前置 `HOMEBREW_NO_AUTO_UPDATE=1`——包括脚本内部的间接调用**。
  ⚠️ `deps-scan.sh:148` 内部有 `brew info --json=v2 "$name"`，那是 **AC7 的 `upstream_latest`
  的唯一数据源**；AC5 的命令若不带该前缀，扫描会触发隐式 `brew update`，tap 前进后
  `upstream_latest` 变成 2.98.0 → **AC7 的期望值 `2.97.0` 在正确执行上 FAIL**，
  且 AC9 评估的 changelog 与 AC10 实际升到的版本可能不是同一个。
  （rev2 初稿只给 AC10/AC19 加了前缀，唯独漏了藏在脚本里的这条 —— 机械套用"所有 brew 调用"时
  跳过了间接调用。）
  **例外**：纯配置查询子命令 `brew --cellar` / `--cache` / `--prefix` 不触发 auto-update，
  可不带前缀（AC18 用的就是 `brew --cellar`）。
- **REGISTRY.yaml 一律用 Edit 工具修改，禁用 `yq -i`**（DEP-003 / `shell-portability.md`
  2026-05-31）。`yq` 只用于**只读**查询与合法性校验。
- 所有命令输出以 `2>&1` 捕获落盘；每个 `ACnn.txt` 末行写 `RESULT: PASS|FAIL|RECORD-ONLY`；
  消费前断言非空。
- 网络命令带超时：`curl --max-time 120`；`deps-scan.sh` 见 AC5 的完整命令
  （perl alarm 包装 + **显式绝对 project-root 参数**；本机无 `timeout`/`gtimeout`，F8 已实测）。
- **evidence 与 journal 的路径不带日期**：`.tad/evidence/journal/dependency-ops-skill.md`
  （rev1 写的 `-2026-08-11.md` 会在跨零点后与实际日期不符）。

## AC

- AC1（源覆盖 —— Phase 3a 先例要求）: 产出 `source-coverage.md`，含**两张**映射表，
  **基准唯一来源是本契约末尾的「附录 A：源协议逐条抄录」**。
  ⚠️ **执行者不得打开 `.claude/skills/alex/references/deps-protocol.md`** —— blake-lite 的
  Forbidden 明确排除 `.claude/skills/*/references/`，且 CLAUDE.md §2.5 规定
  「Lite 的有效权限是 `role ∩ skill ∩ accepted Execution Mandate`」，**mandate 不能扩张到
  skill Forbidden 之外**。用户 2026-08-11 的授权只给了 alex-lite（设计期），不传递给执行者。
  Alex 已在授权内把全部内容抄进附录 A。
  - **表 A（编号 Step，19 条）**：`deps_show` 3 / `deps_add` 5 / `deps_check` 5 / `deps_update` 6，
    各自映射到新 SKILL.md 的哪一节。断言：19 条全部有承载，无 `UNMAPPED`。
  - **表 B（Constraints / Notes，9 条 —— 非编号但承重）**：`deps_add` Constraints 2 条、
    `deps_check` Notes 4 条、`deps_update` Constraints 3 条，逐条映射。
    断言：其中**下列 4 条必须逐条落进 SKILL.md 正文的可执行措辞**（非附注、非"参见"）：
    (1) **N-K2** —— `registry: null` 的依赖被跳过（点名 notebooklm-cli / rsync / claude-code-cli）：AC6 的依据
    (2) **C-U1** —— REGISTRY.yaml 一律用 Edit 工具修改，`yq -i` 会规范化全文：AC4(c)/AC11 的依据
    (3) **C-U2** —— 只更新目标依赖条目，其余条目保持逐字节不变：AC11(ii) 的依据
    (4) **C-U3** —— 用户对 limitation 是否已解决不确定时，保守地保持 `resolved_by_upstream: false`
    （编号与附录 A.6 的对账口径一致，映射时按编号对，不按散文对）
    其余 5 条允许标 `NOT-MIGRATED: {逐条理由}`，但不得标 `UNMAPPED`。
  - `deps_init` 的 **5 条 Step + 3 条 Constraints** 全部列为 `NOT-MIGRATED: Phase 5`（口径与附录 A.6 一致，不算 UNMAPPED）。
  - **表 B 缺失、或任一表出现 `UNMAPPED`、或上述 4 条中任一条未落进正文 → AC1 FAIL。**
  ⚠️ rev1 只锁编号 Step，会为一份**把这 9 条承重约束一条都没迁**的 skill 签发"覆盖完整"证书 ——
  而被漏掉的恰好是 AC6 / AC11 / AC4(c) 的全部依据。
- AC2（frontmatter 载荷）: `.claude/skills/dependency-ops/SKILL.md` 首行为 `---`，且含
  `name: dependency-ops` 与非空 `description:`。缺失则 skill 静默永不激活
  （`pack-build-rules.md` 2026-05-07）。
- AC3（双平台 parity）: `cmp -s .claude/skills/dependency-ops/SKILL.md
  .agents/skills/dependency-ops/SKILL.md` 成立（逐字节）。
- AC4（无悬空引用 —— D1/D2 的验证）: 对新 SKILL.md 断言三则，全部成立：
  (a) `grep -c 'skills/[^ ]*/references/'` == 0（lite 读不到 references）
  (b) `grep -cE 'STEP 3\.5b|启动扫描|startup scan|dependency evolution check|上一次扫描|previous scan|本 session|potentially_resolved'` == 0
      （切断跨 session 悬空引用，背景事实 §4）
      **并追加正向断言**：limitation-resolution 小节中必须出现 `changelog` 或"当次 check 取得的"
      字样，`grep -c` ≥ 1 —— 证明判定输入指向**当次**获取物（D2）。
      ⚠️ 只做缺席检查是作者预知的 grep，改写措辞即可绕过而语义不变；正向断言才锁住语义。
  (c) `grep -c 'yq -i'` == 0（REGISTRY 写入禁用 `yq -i`，DEP-003）
- AC5（check 能力可执行）: 用新 skill 的 check 流程跑（**必须显式传绝对 project-root**：
  `deps-scan.sh:16` 是 `ROOT="${1:-.}"`，依赖 cwd，而 Bash 工具的 cwd 不保证）：
  `HOMEBREW_NO_AUTO_UPDATE=1 /usr/bin/perl -e 'alarm shift; exec @ARGV' 300 bash "/path/to/TAD/.tad/hooks/lib/deps-scan.sh" "/path/to/TAD"`
  ⚠️ **`HOMEBREW_NO_AUTO_UPDATE=1` 前缀不可省**（`deps-scan.sh:148` 内部调 `brew info`，见实现约束）。
  退出码 == 0，且 `yq -r '.last_scan' .tad/dependencies/scan-results.yaml` 的输出
  **== `TODAY.txt` 的内容**（不得硬编码日期；且该字段在文件里是**带引号**的，
  裸 `grep 'last_scan: 2026-08-11'` 会 0 匹配 —— 必须走 `yq -r`）。
- AC6（覆盖面如实 —— 不得假装覆盖 6 个）: 新扫描结果中 `scan_status: success` 恰为 **3** 条、
  `skipped` 恰为 **3** 条；且 skipped 的三个名字逐个落盘，必须是
  `notebooklm-cli` / `rsync` / `claude-code-cli`（`registry: null`，结构性永远跳过）。
- AC7（真实变更被检出）: 新扫描结果中 `gh` 的 `upstream_latest` == `2.97.0`
  且 `version_changed: true`；同时 `yq` 与 `jq` 的 `version_changed` == **false**
  （它们的上游与本地相同 —— 这一条是**判别力对照**：若三个都报 true，说明比较的是陈旧基线而非现状，
  见背景事实 §6）。
- AC8（逾期检测按各自 tier）: show 流程输出中，6 个依赖**全部**被标为逾期，逾期天数按
  `TODAY.txt` 运行时重算：L1 组（`gh`/`yq`/`jq`/`rsync`）== `(TODAY − 2026-07-14) − 7`，
  L2 组（`notebooklm-cli`/`claude-code-cli`）== `(TODAY − 2026-07-14) − 14`。
  断言：show 输出的逾期天数 **== 公式基于 `TODAY.txt` 算出的单一值，逐位相等**。
  ⚠️ 期望值一律运行时算出，**不得把 21/14 或 22/15 任何一组写进断言**；
  输出与公式值不符即 FAIL —— **包括"输出恰好是设计期的 21/14 而当日公式值为 22/15"这种情形，
  那正是硬编码的证据**。（rev2 初稿写"两者都算 PASS"，恰好放行了这条 AC 要防的那个东西。）
  **并且**：SKILL.md 中须写明"逾期 N 天"的定义为「超出安全窗口的天数」——
  源协议未定义该口径，是本单显式选定；AC8 断言 SKILL 的定义与实际计算口径一致
  （否则这条 AC 与 SKILL 由同一人写，必然自洽而无判别力）。
- AC9（relevance 判定必须落到具体能力）: 输入为**完整 changelog**：
  `gh api repos/cli/cli/releases/latest | jq -r '.body' > AC9-changelog-full.txt`
  （设计期实测 11285 字符）。⚠️ **不得使用 `scan-results.yaml` 里的 `changelog_text`** ——
  `deps-scan.sh:13 MAX_CHANGELOG_CHARS=2000` 会把它截断到 **18%**，而本 AC 同时承担
  breaking-change 把关，用 18% 的正文把关等于不把关。
  产出 `HIGH|MEDIUM|LOW` 判定 + 一行理由，**理由必须逐字引用 REGISTRY 中 `gh` 的
  `capabilities_used` 里的某一条**（四条之一：GitHub API access / Release creation and tag
  management / PR creation and review / Repository metadata queries）。
  泛泛的"与本项目相关"判 FAIL —— 无载体的判定不是判定。
  **追加独立断言**：在全文中检索 breaking change / removal / 不兼容变更；
  判定为「是」→ **停止，不执行 `upgrade-gh`**，落盘并上报。
- AC10（真实升级，D4）: 命令**必须逐字为**
  `HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade gh`
  （后一个环境变量是**回滚能力的载体**，见 recovery_policy）。之后 `gh --version` 首行含 `2.97.0`。
- AC18（回滚能力仍在）: 升级后 `ls -1 "$(brew --cellar)/gh"` **同时含 `2.96.0` 与 `2.97.0`**，
  落盘 `AC18.txt`。断言失败 == 旧 keg 已被清理 == **回滚能力丢失**，
  须在 `findings.md` 中把该动作升级为「单向门」并上报。
- AC19（附带升级可见）: 升级前后各跑
  `HOMEBREW_NO_AUTO_UPDATE=1 brew list --formula --versions` 落盘
  （`brew-before.txt` / `brew-after.txt`），**`--formula` 不可省**：不带它时会因本机 3 个
  未信任 tap 的 cask 加载失败而**退出码 1**（实测），错误文本还会随 `2>&1` 混进证据文件。
  断言：两文件行数均 ≥ 180 且退出码 == 0；`diff` 后差异**恰为 2 行**
  （`< gh 2.96.0` / `> gh 2.97.0`）。
  ⚠️ 出现**任何一个 `gh` 以外的 formula** → 立即停止并上报（rev1 的"≥3 才停"过松：
  设计期实测 `brew deps gh`、`brew deps --installed gh`、`brew uses --installed gh` **均为空**，
  `brew upgrade gh --dry-run` 报 `Would upgrade 1 outdated package`，预期附带升级 == **0**）。
- AC11（update 记录 + 邻居零触碰）: 用 **Edit 工具**（禁 `yq -i`）改 REGISTRY.yaml 的 `gh` 条目：
  `current_version` → `2.97.0`、`version_pinned_at` → `TODAY.txt` 内容、
  `last_checked` → `TODAY.txt` 内容（**禁止硬编码日期**）。
  **改完后三行须逐字为**（保持与相邻条目一致的字面形态：版本号带引号、日期不带）：
  `    current_version: "2.97.0"` / `    version_pinned_at: <TODAY>` / `    last_checked: <TODAY>`，
  逐行用 `grep -Fxq` 确认，**占位符须先展开**（`-F` 是固定字符串匹配，不会替换 `<TODAY>`）：
  `grep -Fxq "    version_pinned_at: $(cat "$ROOT/.tad/evidence/acceptance-tests/dependency-ops-skill/TODAY.txt")" "$ROOT/.tad/dependencies/REGISTRY.yaml"`
  ⚠️ 不钉字面形态的话，掉引号或顺手加引号都会让 diff 仍是 6 行、
  AC11(ii) 仍绿、`yq '.'` 仍退 0 —— 格式漂移完全静默。
  断言两则：
  (i) 上述三个字段确已改为目标值；
  (ii) **其余 5 个依赖条目逐字节不变** —— 以 `registry-before.yaml` 为基线，
       `diff` 的变化行（`^[<>]`）必须**全部落在 `gh` 条目的行区间内**，且总变化行数 == 6
       （3 个字段 × 各 1 增 1 删）。任何 `gh` 区间外的变化行 → FAIL（那就是 `yq -i` 式的全文规范化）。
- AC12（YAML 仍合法）: `yq '.' .tad/dependencies/REGISTRY.yaml > /dev/null` 退出 0，
  且 `yq '.dependencies | length'` == **6**。
- AC13（limitation resolution 分支：本轮不可达，显式声明而非假装）:
  实测 `gh` 的 `known_limitations` 为 **`[]`** → `deps_update` 第 5 步的 limitation-resolution 分支
  **在本轮 dogfood 上结构性不可达**。断言：`findings.md`（AC16 的缺口小节）中
  **显式声明该分支未被验证**，
  并说明为何不用其它依赖替代（`yq` 的 DEP-003 / `rsync` 的 DEP-004 本轮上游无变更，
  强行触发就成了合成 fixture）。
  ⚠️ 直接应用本仓库知识：`ac-verification.md` 2026-08-11「守卫判据须在真实数据的全部形态上空跑」
  与 2026-08-06「Before Trusting a Guard, Measure Whether Its Trigger Condition Can Even Occur」。
- AC14（范围围栏）: 开工前记录 `git status --porcelain -uall` 全集 + dirty tracked 路径摘要
  → `scope-baseline.txt`；收尾重算，差异仅允许落在：
  - 本单产物：`.claude/skills/dependency-ops/**`、`.agents/skills/dependency-ops/**`、
    `.tad/evidence/acceptance-tests/dependency-ops-skill/**`、
    `.tad/evidence/journal/dependency-ops-skill.md`、本契约及其归档目标、本单事务锁
  - 授权修改：`.tad/dependencies/REGISTRY.yaml`、`.tad/dependencies/scan-results.yaml`
  - 框架自写路径（F8 已验证的清单，每项标注写入者）：`.tad/evidence/traces/**`（`trace-step.sh` /
    `post-write-sync.sh`）、`.tad/evidence/decisions/**`（`lib/askuser-capture.sh`，本单必然触发）、
    `.tad/logs/**`、`.tad/active/precompact/**`、`.tad/active/session-state.md`（`post-write-sync.sh`）、
    `.tad/memory/**`、`.tad/research-notebooks/REGISTRY.yaml`（`notebook-dormant-sync.sh`，
    SessionStart 触发；按 F8 的 props 限定形状判定：变化路径必须匹配
    `^notebooks\.[0-9]+\.status$` 且值 ∈ `{active,dormant}`）、`.tad/brain-index.md`（变化须指认 hook）
  - 开工时已 dirty 的 tracked 文件：摘要不变。**数量与内容以 preflight 实测为准，不硬编码计数**。
- AC15（围栏正反双控）: **负控**在 `.tad/domains/` 建 `DEPS-FENCE-PROBE.txt`，断言被报出，随后删除
  并断言不存在。**正控**在全部产物 `git add` 后重跑，断言静默通过。
  ⚠️ **本单负控须同时打到围栏两半**（F8 遗留缺口）。负控 B 的对象**指定为
  `.tad/evidence/acceptance-tests/lite-pricing-gate-protocol/AC6.txt`**：
  先 `shasum -a 256` 落盘 → 追加一行 `# DEPS-FENCE-PROBE-B` → 断言 audit 半边**报出**
  → 删除该行 → 断言 `shasum` **逐字节复原为篡改前值**（以 shasum 为准，不以"看着没变"为准）。
  **探针 B 的选择准则（三条须同时满足；换文件时须重新逐条实测，不可沿用）**：
  **(1) 在开工时的 dirty tracked 基线集内** —— 否则落进 `fence_audit` 的
  "基线无摘要 → 不比对"分支，**对 audit 半边天然不可见**（`NEXT.md` 就是这么被否掉的）；
  **(2) 无任何 hook 或活跃单引用** —— 否则执行期的真实写入与探针篡改混在一起，
  "还原"断言不可判（因此排除 `lite-discoveries.md`（本单必写 journal）、
  本 Epic 文件（收尾会更新）、`research-notebooks/REGISTRY.yaml`（hook 自写））；
  **(3) 纯文本 evidence，非可执行脚本、非协议契约。**
  ⚠️ (1) 与 (2) 是**相反方向的同一个错误**：前者让探针对围栏不可见，后者让还原断言不可判 ——
  两侧都会让负控假通过。
  当前选择的三条实测依据：在 dirty 集内（11 个之一）✅ / `grep -rl` 确认 `.tad/hooks` 与
  `.claude` 下零引用 ✅ / 对应单 `COMPLETION-20260805-lite-pricing-gate-protocol.md` 已归档、
  `.tad/active/` 下唯一提及就是本契约本身 ✅（该文件自 2026-08-05 起未被改动）。
  （rev2 初稿曾指定 `NEXT.md`，空跑发现它**当前不 dirty**、不在基线集内，已按准则 (1) 否掉。）
  只打未跟踪探针只能验 fresh 半边（F8 的已知缺口，本单顺手补上）。
- **AC17（skill 承重性 —— 单文件复演，本单判别力的主要来源）**:
  ⚠️ 没有这一条，**新建的 skill 可以是一个从未被打开的文件而 19 条 AC 全绿** ——
  因为 AC5–AC12 的命令逐字写在本契约里，执行者读契约即可跑完整个 dogfood，
  没有任何一条要求"经由新 skill"。那正是本契约开篇引以为戒的 F8 失败家族
  （只建不跑），只是把"没跑"藏进了"跑了，但跑的不是它"。
  做法：spawn 一个**全新上下文**的 reviewer，**只喂给它
  `.claude/skills/dependency-ops/SKILL.md` 一个文件**（不给本契约、不给附录 A、
  不给 `deps-protocol.md`）。
  ⚠️ **题面必须逐字为下列文本**，落盘 `AC17-prompt.txt` 并与本处 `diff` 为空 ——
  题面由契约提供，**不由执行者撰写**（执行者自拟题面 = 泄题：把答案写进问句里，
  reviewer 一样"仅凭 SKILL.md"作答且全中）：
  ```
  附件是一个 capability skill 的完整内容，也是你唯一的信息来源。请仅凭它回答：
  Q1 我要检查项目依赖的上游有没有更新，给出完整可执行的命令序列，并说明结果去哪里读。
  Q2 我刚把某个工具从 A 版升到了 B 版，要在注册表里记录这件事：改哪几个字段？
     用什么工具改？为什么不能用 yq -i？如果我只想更新这一个依赖，
     怎么保证注册表里其它条目不被动到？
  Q3 展示依赖表时，"逾期 N 天"的 N 是怎么算的？各 tier 的窗口是多少天？
  Q4 有哪些依赖不会被扫到？为什么？
  Q5 如果注册表里新增一个 registry 为 npm 的依赖，检查流程会发生什么？
     它与现有这些依赖在扫描结果上有什么不同？
  Q6 我要把 yq 从 4.53.3 更新到 4.54.0 并记录这件事。请按该文件给出你会执行的
     完整动作序列（具体文件、具体字段、具体工具），并说明动作完成后，
     你如何验证「除 yq 以外的条目一个字节都没被动过」。
  每问请标注答案来自该文件的哪一节，并判断该节是**可照做的操作指令**
  还是**事后补充的说明性文字**。若某问文件中没有答案，直接回答"文件中无此信息"。
  ```
  **Q5 判分基准（写进契约，执行者不得自拟 —— 否则判分方就是被测方）**：
  最低合格答案须含 **(i)** 该依赖**会被扫到**（走 npm 分支查最新版本），
  不像 `registry: null` 的三个那样被结构性跳过。
  完整答案另含 **(ii)** 它是**当前唯一真正拿得到 security advisories 的一类** ——
  `deps-scan.sh:212-219` 只对 `npm`(NPM)/`pypi`(PIP) 设 ecosystem，
  现有三个 homebrew 依赖 ecosystem 恒为空、公告分支**永不执行**。
  **(i) 缺失 → FAIL；(i) 有而 (ii) 无 → PASS，但须在 `findings.md` 记为覆盖薄弱点。**
  设计期实测：`deps-scan.sh:167-185` 确有 `npm)` 分支，本机 `npm` 已装
  （`/opt/homebrew/bin/npm` 11.5.1），不会落进 `npm not found` 分支 ——
  **Q5 有确定答案，不存在"无正确答案而误 FAIL"的风险。**
  **Q6 判分基准（真正的反小抄探针）**：答案须
  (1) 点名 `.tad/dependencies/REGISTRY.yaml` 的 `current_version`/`version_pinned_at`/`last_checked`
  三字段；(2) 点名用 **Edit 工具**而非 `yq -i`（C-U1）；
  (3) 给出**一个可执行的邻居不变性验证手段**（基线快照 + diff / 逐字节比对之类，C-U2 的可执行形态）。
  三项缺一 → **AC17 FAIL**。
  ⚠️ **Q6 承担 Q5 承担不了的角色**：Q1–Q5 都是围绕 `gh` 的检索题，
  "复制源协议 + 末尾抄一段 `gh` 的 FAQ"能全中；**Q6 换了依赖对象且要求给出验证手段，
  小抄不可迁移**。（Q5 的最低答案其实从 K1 就能推出——K1 原文已列 "GitHub/npm/PyPI/Homebrew"——
  所以 Q5 本身不反小抄，真正反小抄的是 Q6 与下面的 (iii)。）
  断言三则，**全部成立才 PASS**：
  (i) Q1–Q6 **全部**答得出，且与**本契约已登记的实测值**（L2.25 空跑记录 / 背景事实 / 上述判分基准）
      一致；任一项答"文件中无此信息"或答错 → FAIL。
      ⚠️ 基准是**契约登记值**而非"本单实测" —— AC17 现已提前到 `run-check` 之前，届时本单尚未实测；
  (ii) **Q5 是泛化探针** —— 源协议中无现成答案，只有真正把流程写成可复用步骤的 SKILL 才答得出。
       一份"逐字复制源协议 + 末尾 FAQ 小抄"必然在此处失败；
  (iii) **反小抄**：Q1/Q2/Q3 三问的答案，其出处标注必须落在被 reviewer 判定为
       **「可照做的操作指令」**的小节里。若答案只出现在 FAQ / 注释 / 附录性文字中 →
       **FAIL**（那说明 skill 承载的是信息，不是流程）。
  任一断言 FAIL → **AC17 FAIL，且 AC1 的"全部有承载"同时作废**。
  reviewer 原始回答落盘 `AC17.txt`。该 reviewer 与契约复查 reviewer、实现后 reviewer
  均为不同 spawn，禁自审替代。
  ⚠️ **本 AC 必须早于 `upgrade-gh`**（见 Execution Transactions 的 `skill-load-bearing-gate`）——
  绝不能把一次不可回退的真实系统升级，花在一份还没被证明承重的 skill 上。
- AC16（缺口显式声明）: `findings.md` 必须含一节，逐条列出：
  (a) 3 个 `registry: null` 依赖结构性永远 skipped（点名）
  (b) limitation-resolution 分支本轮不可达（AC13）
  (c) `deps_init` 未迁（Phase 5）
  (d) 若有 Homebrew 附带升级（AC19）
  (e) 新 skill 未在下游任何项目验证（本单只在 TAD 仓库内）
  缺此节 → FAIL。

## 知识引用

- `.claude/skills/alex/references/deps-protocol.md` —— **源协议，经用户于 2026-08-11 明确授权
  单文件读取**（alex-lite Forbidden 常态排除 `.claude/skills/*/references/`，唯一常规例外是
  `release-runbook`）。授权边界：**仅此一个文件、仅为 Phase 4 迁移**，不构成对其它 reference 的
  授权，也不修改 Forbidden 本身，**且不传递给执行者**（执行者的基准是附录 A）。
  读取所得（**已逐条抄进附录 A**）：4 个子协议的 **19 条编号 Step + 9 条 Constraints/Notes**、
  `deps-scan.sh` 的调用点、`registry: null` 跳过规则（**N-K2**）、以及
  "用 Edit 不用 `yq -i`"（**C-U1**）与"其余条目逐字节不变"（**C-U2**）这两条我自行设计
  绝对不会想到的操作约束 —— ⚠️ rev1 的 AC1 只数编号 Step，**恰好验不到后面这几条**（见 P0-4）。
- `.tad/project-knowledge/patterns/pack-build-rules.md`（2026-06-23 skill-vs-MCP）——
  "删掉工具名还有价值吗" → deps 的内核是判断 → skill 形态正确（D3）。
- 同文件（2026-05-07 frontmatter）—— 缺 `name:`/`description:` 则安装成功但静默永不激活 → AC2。
- `.tad/project-knowledge/principles.md`（2026-06-09 circular trigger）—— 拆 reference 前须验
  `load_when` 非循环 → 本单单文件不拆（D1）。
- `.tad/project-knowledge/patterns/ac-verification.md`（2026-08-11 守卫判据三重可验证）——
  判据须逐字取自实现 / 在真实数据全部形态上空跑 / 输入基数可独立获得。直接导出 AC9
  （relevance 必须引用具体 `capabilities_used` 条目）与 AC13（不可达分支显式声明而非假装）。
- 同文件（2026-08-05 正反双控 + 探针须对被测机制可见）—— 导出 AC15，并顺手补上 F8 遗留的
  audit 半边负控缺口。
- `.tad/project-knowledge/patterns/shell-portability.md`（2026-05-31 `yq -i` 规范化 / 2026-08-05
  zsh）—— 导出「REGISTRY 一律用 Edit」与实现约束的 zsh 写法要求。

## Execution Mandate

mandate_id: `dependency-ops-skill` | revision: 4 | authority_mode: contract-mandate

**revision 3 相对 revision 1 的变更点（权限面实质变化，须随 revision 一并接受）**：
(1) `system_package_upgrade` 的 binding 把 `HOMEBREW_NO_AUTO_UPDATE=1` 与
`HOMEBREW_NO_INSTALL_CLEANUP=1` **写进命令本身**（后者是回滚能力的载体，不是建议）；
(2) `local_read` 收窄，明确不含 `.claude/skills/*/references/**`，且授权不传递给执行者；
(3) `explicit_exclusions` 新增整条 brew 禁令（`trust`/`untap`/`tap`/`cleanup`/`autoremove`/
单独 `update`）；(4) 硬停阈值从"≥3 个附带升级"收紧为"任何一个非 gh formula"。
⚠️ mandate revision 与文档 Revision 同步升到 3：本次变的是**权限面**，不只是 AC 判据。
status: accepted | desired_outcome: 交付可用的 `dependency-ops` capability skill，
并用一次真实依赖变更（`gh` 2.96.0 → 2.97.0）端到端 dogfood 它，产出源覆盖映射与缺口声明。

authorized_consequence_classes:
- `local_read` —— 读 `.tad/dependencies/`（REGISTRY.yaml + scan-results.yaml）、本契约（含附录 A）、
  知识库、仓库文件。
  ⚠️ **明确不含 `.claude/skills/*/references/**`** —— 那是 blake-lite 的 Forbidden 排除项，
  mandate 不扩张（CLAUDE.md §2.5：有效权限 = `role ∩ skill ∩ accepted mandate`）。
  用户 2026-08-11 的授权只覆盖设计期的 alex-lite，**不传递给执行者**；
  执行者的源协议基准是本契约的附录 A。
- `network_read` —— `deps-scan.sh` 查询上游 registry（GitHub API / Homebrew）；`brew` 的下载
- `local_write_skill` —— 写 `.claude/skills/dependency-ops/` 与 `.agents/skills/dependency-ops/`
- `local_write_registry` —— 写 `.tad/dependencies/REGISTRY.yaml`（**仅 `gh` 条目的 3 个字段**）
  与 `.tad/dependencies/scan-results.yaml`（由脚本改写）
- `local_write_evidence` —— 上列 evidence 目录、journal、本契约、事务锁、归档目标、
  围栏探针 `.tad/domains/DEPS-FENCE-PROBE.txt`（AC15 负控专用，同一动作内销毁）
- ⚠️ **`system_package_upgrade`** —— **仅**
  `HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade gh`。
  **两个环境变量是授权命令的一部分，不是建议**：后者是**回滚能力的唯一载体**，
  "这一步不再是单向门"这个结论完全挂在它上面（见 consequence_bindings、recovery_policy、
  风险节 §1、AC18）。这是本单唯一的**仓库外系统级变更**。
  ⚠️ rev3 初稿此处仍写裸 `brew upgrade gh`，与 binding 不同口径 —— 而人在 L3 接受的正是这张清单，
  且按 P0-NEW-2 自己写下的道理，"我在授权内"那条更容易被援引。同一形状第三次出现，已修正。
- `local_commit` —— task-scoped append-only；仅提交本单产物。commit 数量是 agent 自主的技术基数。

target_scope:
- 仓库内：上列 skill / evidence / registry 路径
- 系统级：Homebrew 的 `gh` formula（**仅此一个**）
- 远端：只读（上游 API 查询），**无任何写入**

consequence_bindings:
- `local_write_registry` → `REGISTRY.yaml` 仅 `gh` 条目的
  `current_version` / `version_pinned_at` / `last_checked` 三字段；**其余 5 个条目逐字节不变**
  （AC11(ii) 是该绑定的机制载体）
- `system_package_upgrade` → **仅** `HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade gh`
  （两个环境变量是 binding 的一部分，不是建议：前者保证 AC7 与 AC10 面对同一个 tap 快照，
  后者保住旧 keg 即回滚能力）。**禁止 `brew upgrade`（无参数）**、禁止 `brew update && brew upgrade`、
  禁止升级任何其它 formula。附带的 bottle 下载（约 13.6MB，落 `$(brew --cache)`）与
  `$(brew --cellar)/gh` 的 keg 增删属该 class 的既有副作用，已计入 blast radius。
- `local_commit` → 仅本单产物；不得 amend 历史 commit，不得触及远端

max_blast_radius: 仓库内两个新 skill 目录 + 一个 evidence 目录 + REGISTRY 的一个条目；
系统级一个 Homebrew formula。**无远端写入、无凭据、无对任何下游项目的写入。**

explicit_exclusions:
- 禁止 `git push`、禁止创建/移动 tag、禁止任何远端写
- 禁止 sync 操作
- 禁止修改 `.tad/hooks/lib/deps-scan.sh`、`.claude/skills/alex/**`、`deps-protocol.md`、
  `CLAUDE.md`、`.claude/settings*.json`、`tad.sh`
- 禁止修改 REGISTRY.yaml 中 `gh` 以外的任何依赖条目
- 禁止用 `yq -i` 写 REGISTRY.yaml（DEP-003：会规范化全文）
- 禁止升级 `gh` 以外的任何 Homebrew formula
- **禁止 `brew trust` / `brew untap` / `brew tap` / `brew cleanup` / `brew autoremove` /
  单独调用 `brew update` / 设置 `HOMEBREW_NO_REQUIRE_TAP_TRUST`。**
  本机有 3 个未信任 tap（`lbjlaq/antigravity-manager`、`stripe/stripe-cli`、`supabase/tap`），
  Homebrew 会在输出里**主动推销**上述修复命令。遇到该告警**原样落盘并忽略**，
  不得"顺手修一下" —— `brew trust` 是持久的、仓库外的信任边界变更，与本单无关。
- 禁止把本次 reference 读取授权类推到其它 `references/` 文件，
  **也不传递给执行者**（授权只给设计期的 alex-lite；blake-lite 的基准是本契约附录 A）

recovery_policy: `partial` —— 仓库侧全部可回滚（新增文件删除、REGISTRY 用 `registry-before.yaml`
还原）。
⚠️ **系统侧（rev2 更正：rev1 的说法过于悲观，且漏掉了让门变双向的手段）**：
`brew upgrade` 默认在升级后自动执行 `brew cleanup <formula>`（`brew upgrade --help` 原文；
实测本机 `HOMEBREW_NO_INSTALL_CLEANUP` **未设置**），会删掉 `/opt/homebrew/Cellar/gh/2.96.0`；
且下载缓存中**没有** 2.96.0 的 bottle（实测 `find "$(brew --cache)" -iname '*gh*'` 为空）——
**默认路径下**回退确需手动取二进制。
**因此本单强制以 `HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade gh` 执行**，
保住 `Cellar/gh/2.96.0` 这个 keg，使回退降级为「重新 link 旧 keg」。
AC18 是该能力的验证载体；它失败即视为回滚能力丢失，须上报。
全局 cleanup（每 30 天对所有 formula）本单不会触发：`~/Library/Caches/Homebrew/.cleaned`
实测为 2026-08-02，距今 9 天 < 30。
**结论：加了这两个环境变量之后，这一步不再是单向门**，但仍是本单唯一的仓库外变更，L3 须明确接受。
判定依据：`gh` 是 L1 tier（缓冲 7 天），2.97.0 已发布 11 天，满足用户全局规则
「新版本等 2-3 天再更新」；且 2.96→2.97 是 minor 升级，无已知 breaking change
（changelog 由 AC9 当场评估——若评估发现 breaking，应在升级**之前**停下报告）。
硬停条件：AC19 的 `diff` 出现**任何一个 `gh` 以外的 formula** → 立即停止并上报。
（与 AC19 同口径。设计期实测 `brew deps gh` / `brew deps --installed gh` /
`brew uses --installed gh` **均为空**，`brew upgrade gh --dry-run` 报
`Would upgrade 1 outdated package`，预期附带升级 == **0**；rev1/rev2 的"≥3 才停"过松，
且当 mandate 与 AC 口径冲突时，"我在授权内"那条更容易被援引来继续执行 —— 故两处必须同口径。）

expires_when: 本单人工验收通过并归档，或用户显式撤销。

acceptance: {decision: accepted, decided_at: 2026-08-12T08:45:32-0400, source: L3 contract decision}

⚠️ **接受时点已跨日（契约写于 2026-08-11 22:54，接受于 2026-08-12 08:45）——
时间炸弹已成为事实而非风险。** 这正是复核 1 的 P0-1 所防的情形：
`TODAY.txt` 现在会取到 `2026-08-12`，AC5 的 `last_scan` 断言随之为 08-12；
AC8 的逾期天数按公式为 `(2026-08-12 − 2026-07-14) − 7 = 22`（L1）与 `− 14 = 15`（L2），
**不是 L2.25 表里登记的 21 / 14**。执行者务必按公式重算，
**照抄 21/14 即为硬编码的证据（AC8 明文 FAIL 条件）**。
人的决策内容：接受契约与 mandate revision 4，**含真实执行
`HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade gh`**（可回滚）。

## Execution Transactions

transactions:
- transaction_id: `dependency-ops-skill-t1`
  mandate_id: `dependency-ops-skill`
  mandate_revision: 4
  lock_path: `.tad/active/handoffs/LITE-20260811-2254-dependency-ops-skill.md.txn-lock`
  state_version: 0
  state: planned
  targets: 上列 skill / evidence / registry 路径 + Homebrew `gh` formula
  consequence_classes: [`local_read`, `network_read`, `local_write_skill`,
    `local_write_registry`, `local_write_evidence`, `system_package_upgrade`, `local_commit`]
  commit_shas: []
  actions:
  - {action_id: `preflight-baselines`, state: pending}      # scope-baseline + registry-before + brew-before
  - {action_id: `author-skill`, state: pending}             # SKILL.md + .agents 镜像
  - {action_id: `source-coverage-map`, state: pending}      # AC1
  - {action_id: `structural-acs`, state: pending}           # AC2–AC4
  - {action_id: `skill-load-bearing-gate`, state: pending}  # AC17 ⚠️ 必须早于 upgrade-gh
    # AC17 是本单判别力的主要来源，而 upgrade-gh 是不可回退成本。绝不能把一次真实系统升级
    # 花在一份还没被证明承重的 skill 上。AC17 FAIL → 停止，回到 author-skill，不执行 upgrade-gh。
  - {action_id: `run-check`, state: pending}                # AC5–AC7
  - {action_id: `overdue-and-relevance`, state: pending}    # AC8–AC9（⚠️ AC9 须在升级前完成）
  - {action_id: `upgrade-gh`, state: pending}               # AC10–AC19
  - {action_id: `record-update`, state: pending}            # AC11–AC12
  - {action_id: `declare-unreachable`, state: pending}      # AC13
  - {action_id: `scope-fence-and-controls`, state: pending} # AC14–AC15，内部顺序见下
  - {action_id: `write-findings-and-journal`, state: pending} # AC16
  - {action_id: `independent-review`, state: pending}
  - {action_id: `commit-evidence`, state: pending}
  - {action_id: `post-archive-fence`, state: pending}       # AC15 正控 (b)

  # ⚠️ `scope-fence-and-controls` 内部顺序（F8 教训，不可乱）：
  #   ① AC15 负控 A（未跟踪探针 → fence-fresh 报出 → 删除 → 断言不存在）
  #   ② AC15 负控 B（篡改一个已 dirty 的 tracked 文件 → audit 半边报出 → 还原 → 摘要复原）
  #   ③ AC14 收尾围栏重算（此刻两个探针均已清除）
  #   ④ git add 全部产物 → AC15 正控 (a)
  # AC14 不得在任一探针尚存时执行 —— 探针刻意不在排除清单内（排除它们会让负控不可证伪）。

  # ⚠️ AC9（relevance 判定）必须在 `upgrade-gh` **之前**完成并落盘：
  #   它是"该不该升"的判断依据；升完再判就成了事后合理化。
  #   若 AC9 判定 changelog 含 breaking change → 停下报告，不执行 upgrade-gh。

## L2.25 空跑记录（设计期在本机实测；Blake 不必重做，但需确认值未变）

| 检查 | 实测结果 |
|---|---|
| **AC1 Step 数** | `deps_show`=3 / `deps_init`=5 / `deps_add`=5 / `deps_check`=5 / `deps_update`=6（两种数法交叉核对一致）→ **待迁 19 条编号 Step + 9 条 Constraints/Notes；`deps_init` 的 5 Step + 3 Constraints 不迁**（口径与 AC1 L161、附录 A.6 一致）✅ |
| **AC8 逾期算术** | ⚠️ **rev3 注**：`2026-08-11 − 2026-07-14` = 28 天 → L1 逾期 21 / L2 逾期 14。**这是设计期快照，不是期望值** —— AC8 要求运行时按 `TODAY.txt` 用公式重算并**逐位相等**；Blake **不得**"确认 21/14 未变"（跨零点即为 22/15，照抄 21/14 恰恰是硬编码的证据）✅ |
| **AC12 yq 只读** | `yq '.dependencies \| length'` → **6** ✅ |
| **AC11 行区间** | `gh` 条目 = REGISTRY.yaml 第 **44–73** 行；三个待改字段在绝对行 **47**(`current_version`) / **48**(`version_pinned_at`) / **71**(`last_checked`) → 变化行必须全部落在 44–73 内，总计 6 行 ✅ |
| **AC19 brew** | ⚠️ **rev3 更正**：`brew list --versions`（不带 `--formula`）实测 **exit 1**（未信任 tap 的 cask 加载失败）；`brew list --formula --versions` → **exit 0，188 行**。AC19 以后者为准 ✅ |
| **AC7 上游实测** | ⚠️ **rev3 更正**：判据源是 `brew info --json=v2 <name> \| jq -r '.formulae[0].versions.stable'`（三者 `registry: homebrew`），**不是 GitHub tag**。实测 `gh=2.97.0` / `yq=4.53.3` / `jq=1.8.2`，本地 `2.96.0`/`4.53.3`/`1.8.2` → true/false/false ✅。（GitHub tag `jq-1.8.2` 只是同一结论的**错误论证路径**，见背景事实 §7） |
| **deps-scan.sh 写面** | 对 `REGISTRY.yaml` **只读**（全 `yq -r`，无 `yq -i`）；只写 `.tad/dependencies/scan-results.yaml`，经 `${OUTPUT}.tmp` + `mv` 原子替换，用 `yq -P '.'` **整文件重生成**（该文件归它所有，授权内）。`last_scan: $TODAY` → AC5 断言成立 ✅ |
| **AC13 前提** | `gh` 的 `known_limitations` 实测为 **`[]`** → limitation-resolution 分支本轮结构性不可达，AC13 的"显式声明"是唯一诚实处置 ✅ |

**执行期注意**：`deps-scan.sh` 运行中会短暂存在 `.tad/dependencies/scan-results.yaml.tmp`；
`mv` 是原子的、正常结束后不残留。若围栏在扫描进行中运行会看到它 —— 故 AC14 的收尾围栏
必须在 `run-check` 动作**完成之后**执行（transactions 的顺序已保证）。

## L2.25 空跑记录（rev2 的修订本身也已空跑）

| 检查 | 实测结果 |
|---|---|
| **rev2-a：`TODAY` 自导出链** | `date "+%Y-%m-%d"` → `2026-08-11`；按公式算 L1=**21** / L2=**14**，与硬编码值一致 → 跨零点自动变 22/15 而不误 FAIL ✅ |
| **rev2-b：`last_scan` 读法** | `yq -r '.last_scan'` → `2026-07-14`；裸 `grep 'last_scan: 2026-07-14'` → **0 命中**（字段带引号）→ 必须走 `yq -r`，rev1 的裸 grep 会必然 FAIL ✅ |
| **rev2-c：`brew list` 退出码** | 不带 `--formula` → **exit 1**；带 `--formula` → **exit 0，188 行** ✅ |
| **rev2-d：三行字面形态** | `grep -Fxq` 对 `    current_version: "2.96.0"` / `    version_pinned_at: 2026-07-15` / `    last_checked: 2026-07-14` **三条全部命中** → 字面形态断言可行 ✅ |
| **rev2-e：探针 B 选错并已更正** | rev2 初稿采纳审查者建议指定 `NEXT.md`，空跑发现 `git status --porcelain NEXT.md` **空输出**（不 dirty、不在基线集内）→ 对 `fence_audit` 天然不可见，负控会假通过。改选 `…/lite-pricing-gate-protocol/AC6.txt`：在 dirty 集内 ✅ / 无 hook 引用 ✅ / 对应单已归档无消费者 ✅ |
| **dirty 集实测** | 当前 **11** 个（rev1 记的 9 个已过时——Knowledge Closeout 又写了两条知识条目）。AC14 已规定"以 preflight 实测为准、不硬编码计数"，无需改 ✅ |

⚠️ **rev2-e 是本轮最该记的一条**：我直接采纳了审查者点名的文件，没验它是否在基线集内 ——
和 rev1 那次"靠字段名联想凑白名单"是同一个毛病（`ac-verification.md` 2026-08-11 第 (1) 条：
判据须逐字取自实现/实测，不取自"听起来对"）。

## Contract Review

<!-- 以下 5 行是模板规定的机械可读字段（L0.5 准入闸读这里）。逐轮叙事见下方各节。 -->
Reviewer: 独立上下文 code-reviewer（3 轮：首轮 + 增量复核 1 + 增量复核 2）| model=`claude-opus-5[1m]`
首轮 verdict: FAIL
最终 verdict: PASS
P0=9(fixed), P1=21, P2=18; 已审 AC 条数: 19
关键发现: 最重的一条是 rev1 的"新 skill 可以从未被打开而全部 AC 全绿"——AC5–AC12 的命令逐字写在契约里，执行者读契约即可跑完整个 dogfood，没有任何一条要求"经由新 skill"；据此新增 AC17（只喂 SKILL.md 给全新 reviewer 的单文件复演，含 Q6 迁移题反小抄），并把它提前到真实系统升级之前。其余三轮的新缺陷高度同形：**修复只落到成对表述的一半**（recovery_policy 改了风险节没改 / AC19 收紧了 mandate 硬停没收紧 / 两条命令加了 brew 前缀第三条没加 / mandate 的 class 与 binding 不同口径）。另一新形状：为修"目录不存在"加的 `mkdir -p` 把一次响亮的 `exit 1` 换成了静默成功（cwd 错也一路 exit 0），已改为 `git rev-parse` 等值断言 + `mkdir -p` + `test -s` 三段链。

> **`最终 verdict: PASS` 的依据**：复核 2 的 verdict 是 CONDITIONAL，其放行清单 5 项
> （P0-R3-1 / P1-R3-1 / P1-R3-2 / AC17 的 Q5 判分基准与 Q6 / 5 条 P2）**已全部落实**；
> reviewer 在该轮明写"改完做一次定点确认即可转人工，不需要第四轮完整复核"。
> 两处定点确认已实测：`grep -n "brew upgrade gh"` 承重位置只剩带两个环境变量的形态；
> 绝对化的 TODAY.txt 链在错误 cwd 下 `exit 128`（正确拦住）、正确 cwd 下 `exit 0`。
> **P0 计数口径**：首轮 4 + 复核 1 新增 4 + 复核 2 新增 1 = 9，全部 fixed。
> **AC 条数口径**：`grep -oE '^- \*?\*?AC[0-9]+' | sort -u` = **19**（AC1–AC19，
> rev4 已把 `AC10-keg`/`AC10b` 两个带后缀标号改名为 `AC18`/`AC19`，消除计数歧义）。

### 首轮（2026-08-11，rev1）
Reviewer: 独立上下文 code-reviewer | model=`claude-opus-5[1m]`
首轮 verdict: **FAIL** —— P0=4, P1=11, P2=6; 已审 AC 条数: **17**（AC1–AC16 + AC19；
rev1 自称 18，未对账，rev2 已更正口径）
关键发现:
- **P0-1 时间炸弹**：全部日期硬编码 `2026-08-11`，而契约写于 22:54，本单跨零点几乎必然
  → `last_scan` 变 08-12、逾期变 22/15 → **在正确执行上判 FAIL**。
- **P0-2 权限冲突**：用户的 reference 读取授权给的是 **alex-lite（设计期）**，
  而执行者是 **blake-lite**，其 Forbidden 同样排除 `.claude/skills/*/references/`；
  CLAUDE.md §2.5 规定 mandate 不能扩张到 skill Forbidden 之外
  → AC1 的映射基准对执行者**不可达**，会诱导一次协议违规。
- **P0-3 skill 不承重（最严重）**：AC5–AC12 的命令逐字写在契约里，执行者读契约即可跑完整个
  dogfood，**没有任何一条 AC 要求"经由新 skill"** → 新 skill 可以是一个从未被打开的文件而
  19/19 全绿。**本契约开篇引以为戒的 F8 失败家族，被 AC 集原样重演**，
  只是把"没跑"藏进了"跑了，但跑的不是它"。
- **P0-4 AC1 签发假证书**：只锁编号 Step，漏掉 9 条 `Constraints`/`Notes` ——
  而被漏掉的恰好是 AC6（`registry: null` 跳过）、AC11/AC4(c)（Edit 而非 `yq -i`、
  邻居逐字节不变）的**全部依据**。Alex 曾把这三条称为"授权读取的价值所在"，
  却写了个验不到它们的 AC。
- P1 中最有价值的一条（**P1-10**）：`brew upgrade` 默认自动 `brew cleanup`，
  但 `HOMEBREW_NO_INSTALL_CLEANUP=1` 可保住旧 keg → **rev1 说的"准单向门"其实不必是单向的**。
  另实测 `brew deps gh` / `brew uses --installed gh` 均为空、`--dry-run` 只动 1 个包，
  附带升级预期为 **0**（rev1 的"≥3 才停"过松）。
- 审查者肯定的部分：AC13（拒绝用合成 fixture 掩盖不可达分支，且"无替代"论证经穷举验证成立）、
  AC15 的四步内部顺序、AC7 的判别力对照设计、**知识引用 6 条零虚构**。

### rev2 处置（历史；其中探针 B 的 `NEXT.md` 已在 rev3 被否掉并替换）
4 个 P0 + P1-1/2/3/4/5/6/7/8/9/10/11 + P2-1/2/3/5 **全部采纳**：
日期改运行时自导出（`TODAY.txt`）并贯通 AC5/AC8/AC11；新增**附录 A**把源协议 19 条 Step +
9 条 Constraints/Notes 逐条抄进契约，执行者基准改为附录 A 且明禁打开原 reference，
`local_read` binding 同步收紧；**新增 AC17（单文件复演）**——只喂 SKILL.md 给全新 reviewer，
四问答不出即 FAIL 且 AC1 作废；AC1 拆表 A/表 B 并点名 4 条必须落进正文的承重约束；
AC5 补绝对 root 参数与 `yq -r` 读法；AC7 的论证来源更正为 `brew info` 而非 GitHub tag；
AC9 改用完整 changelog（11285 字符）并加 breaking-change 前置停机；
AC10 强制两个 `HOMEBREW_*` 环境变量并新增 **AC18**（回滚能力验证）；
AC19 改 `brew list --formula --versions` 且阈值收紧为"任何非 gh formula 即停"；
AC11 钉死三行字面形态；AC13 删除对不存在 AC19 的引用；AC4(b) 补正向断言；
AC15 负控 B 指名 `NEXT.md` 并以 shasum 判复原；实现约束补 `LC_ALL=C` 与 `HOMEBREW_NO_AUTO_UPDATE=1`；
explicit_exclusions 补禁 `brew trust`/`untap`/`tap`/`cleanup`/`autoremove`/单独 `update`；
recovery_policy 更正为"加两个环境变量后不再是单向门"。

### 增量复核 1（2026-08-11，rev1→rev2 diff）
Reviewer: 同一 reviewer | model=`claude-opus-5[1m]`
verdict: **CONDITIONAL** —— **原 4 个 P0 全部 CLOSED**；但 rev2 引入 **4 个新 P0**（全为
一两行的机械修正，无设计不确定性）+ 8 个 P1 + 7 个 P2。
**审查者点出的根形状**：新 P0 里有三条是同一个毛病 ——
**「修复只落到了成对表述的一半」**：
- recovery_policy 改了"不再是单向门"，而**「风险与注意」§1 仍写"准单向门"** ——
  而那一节正是人在 L3 读的那一节（P0-NEW-1）
- AC19 收紧为"任何一个非 gh formula 即停"，而 **mandate 的硬停仍是 ≥3**；
  两者冲突时"我在授权内"那条更容易被援引来继续（P0-NEW-2）
- AC10/AC19 加了 `HOMEBREW_NO_AUTO_UPDATE=1`，**唯独 AC5 漏了** ——
  而 `deps-scan.sh:148` 内部的 `brew info` 才是 AC7 `upstream_latest` 的**唯一数据源**（P0-NEW-3）

第四条独立：**P0-NEW-4** —— `TODAY.txt` 的目标目录**此刻不存在**，裸重定向实测 `exit 1`，
**P0-1 的整条修复在第一条命令上就断了**。
其余关键 P1：AC8 的"21/14 与 22/15 两者都算 PASS"恰好放行了它要防的硬编码（P1-NEW-1）；
AC17 有三个可绕过口 —— 题面由执行者自撰可泄题、四问全是事实检索题（复制粘贴 + FAQ 小抄即可通过）、
且 AC17 排在 `upgrade-gh` **之后**（P1-NEW-3/4/5）；附录 A 成了执行者不可独立复核的单点真值源（P1-NEW-8）。
**审查者复核并支持了我对探针 B 的替换**（`NEXT.md` → `AC6.txt`），并指出我那三条筛选依据
同时挡住了两个相反方向的错误，建议固化为准则（已采纳）。
**附录 A 经其逐节比对：19 + 9 + init 全部忠实完整，无抄漏无抄错**（唯一"抄弱"处 U5 已补齐）。

### rev3 处置（本版）
4 个新 P0 + 8 个 P1 + P2-1/2/5/6/7 **全部采纳**：
`mkdir -p` + `test -s` 补进第一条命令；风险节 §1 与 mandate 硬停两处**同口径**改正；
AC5 补 `HOMEBREW_NO_AUTO_UPDATE=1` 且实现约束写明"包括脚本内部的间接调用"；
AC8 删掉枚举可接受值、改为"公式单一值逐位相等"；
**AC17 三处加固**（题面逐字钉死并落盘 `diff` 为空、新增 **Q5 泛化探针**反小抄、
出处须落在"可照做的操作指令"小节）**且提前为独立动作 `skill-load-bearing-gate`，
排在 `upgrade-gh` 之前**；mandate 升 `revision: 3` 并列出四条权限面变更；
附录 A 加入**独立核验记录**（该链路的唯一审计载体）+ U5 补齐"未确认则保持 false"；
AC4(b) 禁用词补 `potentially_resolved`；AC15 把探针选择固化为**三条准则**并说明两个相反错误；
知识引用段更新为附录 A 基准 + 9 条 Constraints/Notes；AC1 表 B 改用编号（N-K2/C-U1/C-U2/C-U3）；
AC11 的 `grep -Fxq` 给出占位符展开后的确切命令；176 行数、22:54 时间、`gh api` 的多余前缀均已更正。
**rev3 的修订本身已空跑**：`mkdir -p && date > && test -s && cat` 链 → `exit 0` ✅；
占位符展开后的 `grep -Fxq` → 命中 ✅。

### 增量复核 2（2026-08-11，rev2→rev3 diff）
Reviewer: 同一 reviewer | model=`claude-opus-5[1m]`
verdict: **CONDITIONAL** —— rev2 的 4 个新 P0 **全部 CLOSED**；本轮新增 1 P0 / 2 P1 / 5 P2。
关键发现:
- **P0-R3-1 —— 同一形状第三次**：mandate 内部，`authorized_consequence_classes` 写裸
  `brew upgrade gh`，而 `consequence_bindings` 写带两个环境变量的命令。
  **人在 L3 接受的正是那张 class 清单**，而"不再是单向门"这个结论完全挂在它漏掉的
  `HOMEBREW_NO_INSTALL_CLEANUP=1` 上。
- **P1-R3-1（新形状，值得进知识库）**：我修 P0-NEW-4 时加的 `mkdir -p`，
  **把一次响亮的失败换成了静默的成功** —— cwd 错时整条链仍 `exit 0`，TODAY.txt 落在别处，
  后续断言自洽地读同一个错文件。P0-NEW-4 之所以被抓到，正因为裸重定向 `exit 1` 叫得很响。
  同族：`|| true`、`2>/dev/null`、`-f`/`-p`。
- **P1-R3-2**：L2.25 的 AC8 行没跟着 AC8 改，而表头写着"Blake 需确认值未变"——
  等于让 Blake 去确认 21/14，跨零点后要么必然失败、要么把 21/14 当成期望值。
- **AC17 的两个洞**：Q5 无判分基准（判分方就是被测方）；且 Q5 **并不反小抄** ——
  其最低答案从 K1 就能推出（K1 已列 "GitHub/npm/PyPI/Homebrew"），复制粘贴 + FAQ 照样全中。
  ✅ 但我担心的"Q5 无正确答案而误 FAIL"**不成立**：reviewer 实读 `deps-scan.sh:167-185`
  确有 `npm)` 分支，本机 npm 11.5.1 已装。并挖出一个更好的事实：
  `deps-scan.sh:212-219` 只对 npm/pypi 设 ecosystem → **现有三个 homebrew 依赖的
  security advisory 分支永不执行**。
- **方法论最有价值的一条**：我这轮扫了 5 项、都干净；reviewer 多扫 4 项、其中 3 项出问题。
  差别在于**我的清单是靠回忆列的，它的是从 token 出发的**。

### rev4 处置（本版）
1 P0 + 2 P1 + 5 P2 **全部采纳**：
`authorized_consequence_classes` 补齐两个环境变量并写明"是授权命令的一部分，不是建议"；
TODAY.txt 链**绝对化**（`git rev-parse --show-toplevel` + 等值断言 + `mkdir -p` + `test -s`），
AC11 的 `grep -Fxq` 同步改用 `$ROOT`；L2.25 的 AC8 行标注"这是设计期快照，不是期望值"；
**AC17 加 Q5 判分基准（写进契约，执行者不得自拟）+ 新增 Q6 迁移题**（换依赖对象 + 要求给出
邻居不变性的验证手段 —— 小抄不可迁移）+ AC17(i) 基准改为"契约已登记值"（AC17 已提前到实测之前）；
P2：23:54→22:54、17 条→19 条、`deps_init` 口径统一为 5 Step + 3 Constraints、
删除 AC15 的重复段、`brew --cellar/--cache/--prefix` 列为前缀例外。

**rev4 的修订本身已空跑**（token 口径，不靠回忆）：
- 绝对化链在**错误 cwd** 下 `exit 128`（正确拦住）、在正确 cwd 下 `exit 0` ✅
- token 扫描 7 项（`brew upgrade gh` / `TODAY.txt` / `23:54` / `17 条` / `NEXT.md` /
  `deps_init` / `brew list`）：承重位置无一处旧口径；另**自行扫出 1 处残留**
  （L2.25 的"init 5 条不迁"未同步为 5+3）并已修正。

## 风险与注意

1. **`brew upgrade gh` 是本单唯一的仓库外变更，L3 须明确接受。**
   ⚠️ **rev3 更正（rev1/rev2 此处写的"准单向门"是错的，而这一节正是人在 L3 读的那一节）**：
   加上 `HOMEBREW_NO_INSTALL_CLEANUP=1` 后**它不再是单向门** —— 旧 keg
   `Cellar/gh/2.96.0` 会被保留，回退 = 重新 link 旧 keg。**AC18 是该能力的验证载体**；
   只有它失败才退回"准单向门"，届时须立即上报。
   默认路径（不加该环境变量）下 Homebrew 会自动 `brew cleanup gh` 删掉旧 keg，
   且缓存里没有 2.96.0 的 bottle（实测），那时回退才需要手动取二进制。
   **所以需要你接受的是"系统上多了一个 formula 版本变更"，不是"不可逆"。**
   若仍想避免，可把 D4 改为"只到决策点不真升级"——但那样 `deps_update` 整条子协议不可达，
   AC11/AC12 变成空跑（诚实地说，那会显著削弱本单价值）。
2. **`gh` 是 release ops 的依赖**：`files_depending` 列了 4 处（含 `publish-protocol.md`、
   `layer2-audit.sh`、`verify-ac-commands.sh`、`github-registry/REGISTRY.yaml`）。
   升级后若 release 流程行为异常，影响面在下一次 publish 才显现 —— 本单不做 release 回归测试
   （超出范围），须写进 findings 作已知残留。
2b. **本单不验证 skill 在下游可用**：只在 TAD 仓库内验证。下游分发属 Phase 6。
3. **limitation-resolution 分支不可达**（AC13）：这是本单最大的覆盖缺口，且**不应该用合成
   fixture 掩盖** —— 强行触发一个上游没动的依赖，验的是假数据。诚实声明优于假绿。
4. **F1（F8 发现的升级判定缺陷）不在本单范围**：那是 2.41.1 单的事。两者无依赖关系。
5. **源协议里 `deps_check` 第 5 步是"要看某个依赖的 changelog 吗"的追问**——
   在 lite 下这属于 mandate 内的技术步骤，不是独立决策点，**不得作为运行时提问**
   （Lite 授权模型 v2：命令/工具/retry 不在闭集内）。新 skill 措辞须避免把它写成需要审批的动作。

---

## 附录 A：源协议逐条抄录（AC1 的**唯一**映射基准）

> 来源：`.claude/skills/alex/references/deps-protocol.md`（176 行），
> 由 Alex 在用户 2026-08-11 的单文件读取授权内抄录。
>
> **独立核验记录（P1-NEW-8 —— 不得删除）**：本附录已由独立上下文 reviewer
> （`claude-opus-5[1m]`，2026-08-11 增量复核）对源文件逐节比对，结论：19 条 Step、
> 9 条 Constraints/Notes、`deps_init` 的 5+3 条**全部忠实且完整，无抄漏、无抄错**
> （唯一"抄弱"处 U5 已按复核意见补齐）。
> ⚠️ **执行者被明禁打开源文件，因此无法独立发现本附录是否抄漏。**
> AC1 只能证明"SKILL 覆盖了附录 A"，不能证明"附录 A 覆盖了源协议" ——
> **这条核验记录是该链路的唯一审计载体。**
> ⚠️ **执行者不得打开原文件**（blake-lite Forbidden 排除 `.claude/skills/*/references/`，
> 且 mandate 不能扩张到 skill Forbidden 之外）。本附录是执行者的合法基准。

### A.1 `deps_show_protocol` —— 3 条编号 Step

| # | Step |
|---|---|
| S1 | 读 `.tad/dependencies/REGISTRY.yaml`；不存在则建议先跑 `*deps init` |
| S2 | 格式化为表格：`Name / Type / Version / Safety / Last Checked / Limitations`。**安全窗口天数：L1=7d, L2=14d, L3=30d** |
| S3 | 任一依赖的 `last_checked` 早于其 tier 窗口 → 告警 `⚠️ {name} last checked {date} — overdue by {N} days` |

（本节无 Constraints / Notes 小节。）

### A.2 `deps_add_protocol` —— 5 条编号 Step + 2 条 Constraints

| # | Step |
|---|---|
| A1 | 检查 registry 是否存在；不存在则建议先 `*deps init` |
| A2 | 询问依赖名（AskUserQuestion 或对话） |
| A3 | 从项目文件自动探测（package.json / requirements.txt 等）：命中则预填版本、建议 type；未命中则手工询问版本与 type |
| A4 | 富化流程（同 deps_init 的 per-dependency）：type + safety_tier（带默认值）、`capabilities_used`、`known_limitations`、`upstream.repo` |
| A5 | 追加进 REGISTRY.yaml：新增条目、更新 `last_updated`、校验整文件仍是合法 YAML |

**Constraints（2 条，非编号但承重）**
- **C-A1**：不得覆盖同名的已有条目
- **C-A2**：依赖已存在 → 询问用户是否改为「更新」

### A.3 `deps_check_protocol` —— 5 条编号 Step + 4 条 Notes

| # | Step |
|---|---|
| K1 | 跑扫描脚本 `bash .tad/hooks/lib/deps-scan.sh`：查询上游 registry（GitHub/npm/PyPI/Homebrew），结果缓存进 `scan-results.yaml`；脚本按依赖逐个处理错误，单个失败不会崩 |
| K2 | 读结果：解析 `.tad/dependencies/scan-results.yaml` |
| K3 | 显示汇总表：`Dependency / Current / Latest / Released / Days / Changed / Security` |
| K4 | 高亮问题：安全公告（带严重度与摘要）、版本变更（`upstream_latest` 与 `current_version` 不同）、错误与跳过（注明哪些没扫到、为什么） |
| K5 | 追问式跟进："要看某个依赖的 changelog 吗？" → 是则显示该依赖的 `changelog_text` |

**Notes（4 条，非编号但承重）**
- **N-K1**：6 个依赖的扫描约 15–30 秒（顺序 API 调用）
- **N-K2**：⚠️ **`registry: null` 的依赖会被跳过**（预期为 `notebooklm-cli`、`rsync`、`claude-code-cli`）
- **N-K3**：安全公告检查是 best-effort（GitHub GraphQL API）
- **N-K4**：定时扫描见 `.tad/evidence/spikes/cron-deps-scan/cron-prompt.md` 的 cron prompt

### A.4 `deps_update_protocol` —— 6 条编号 Step + 3 条 Constraints

| # | Step |
|---|---|
| U1 | 解析命令 `*deps-update <name>` 取依赖名；未给则对话询问 |
| U2 | 校验该依赖存在于 REGISTRY.yaml；不存在则提示 `Dependency '{name}' not in registry. Run *deps or *deps-add.` |
| U3 | 询问新版本："What version did you upgrade {name} to?" |
| U4 | ⚠️ **用 Edit 工具更新 REGISTRY.yaml（NOT `yq -i`，避免整文件规范化）**：`current_version` → 新值、`version_pinned_at` → 今天、`last_checked` → 今天 |
| U5 | 检查 limitation 是否已解决：对每条 `resolved_by_upstream: false` 的 limitation，依据**当次 check 取得的 changelog**（⚠️ D2 已切断源协议原有的"查本 session STEP 3.5b 标记"输入，见下方说明）判断是否可能已解决 → 询问用户 → 确认已解决则改为 `true`；**未确认则保持 `false`** |
| U6 | 输出：`✅ {name} updated to {version}. {N} limitations confirmed resolved.` |

**Constraints（3 条，非编号但承重）**
- **C-U1**：⚠️ **REGISTRY.yaml 的所有修改都用 Edit 工具**（`yq -i` 会规范化整个文件）
- **C-U2**：⚠️ **只更新目标依赖条目，其余条目保持逐字节不变**
- **C-U3**：用户对某条 limitation 是否已解决**不确定**时 → 保守地保持 `resolved_by_upstream: false`

> ⚠️ **D2 的切断点在 U5**：源协议原文要求"查**本 session** 里 STEP 3.5b 标记过的
> `potentially_resolved`"。STEP 3.5b 是 **full Alex 的启动扫描**，lite 不跑任何启动扫描 ——
> 照搬即悬空引用。新 skill 的 U5 判定输入**改为当次 check 取得的 changelog**（同一单内可获得）。

### A.5 `deps_init_protocol` —— 5 条编号 Step + 3 条 Constraints（**NOT-MIGRATED: Phase 5**）

摘要（不迁，仅供 AC1 表 A/B 标注 `NOT-MIGRATED` 时对账）：
扫描项目文件找依赖声明 → LLM 判断筛出关键依赖（含平台/框架/API/主要工具，排除 lodash/uuid 类工具包）
→ AskUserQuestion 多选确认 → 逐依赖富化（type/safety_tier 默认：platform→L2、framework→L3、
api→L1、tool→L1、library→L3） → 从 `.tad/templates/deps-registry-template.yaml` 写出 REGISTRY.yaml。
Constraints：10 个依赖的交互流程应 ≤5 分钟；REGISTRY.yaml 必须是 `yq` 可解析的合法 YAML；
每条至少 1 个 `capabilities_used` 与 1 个 `files_depending`。

### A.6 对账口径

- **表 A 基准 = 19 条**：S1–S3(3) + A1–A5(5) + K1–K5(5) + U1–U6(6)
- **表 B 基准 = 9 条**：C-A1/C-A2(2) + N-K1…N-K4(4) + C-U1/C-U2/C-U3(3)
- **表 B 中必须落进 SKILL.md 正文可执行措辞的 4 条**：**N-K2**、**C-U1**、**C-U2**、**C-U3**
- `deps_init` 的 5 Step + 3 Constraints 全部标 `NOT-MIGRATED: Phase 5`

## Lite Progress

- Phase=admission | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/dependency-ops-skill/ | Next Action=preflight-baselines（TODAY.txt 自导出链） | 阻塞/错误=无 | 备注：L0.5 通过（AC17 加粗样式差异已注明）；L2.25 值全部复核未变（gh 上游 2.97.0 / keg 2.96.0 在位 / dirty 集 11）
## Lite Progress
- Phase=implement | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/dependency-ops-skill/ | Next Action=AC17 skill-load-bearing-gate（spawn 全新 reviewer） | 阻塞/错误=无 | 备注：author-skill+source-coverage+AC1-AC4 完成（C-U2 逐字节字面已补），AC17-prompt 与契约 diff 为空
- Phase=implement | repair_round=0/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/dependency-ops-skill/ | Next Action=upgrade-gh（AC10-AC19） | 阻塞/错误=无 | 备注：AC5-AC9 全 PASS；AC17 首轮 Q3 出处 FAIL → fix → 增量复核转正（repair 计入 Reflexion）；AC9 判定 HIGH（4 个安全漏洞修复 + 无 breaking）
- Phase=ac | repair_round=1/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/dependency-ops-skill/ | Next Action=write journal + L3 independent review | 阻塞/错误=无 | 备注：AC1-AC19 全 PASS/如实声明；AC15 负控 A/B 双控通过（补齐 audit 半边缺口）；scope-baseline 重建为三列格式

### 实现后 L3 独立审查（2026-08-12，Blake spawn）
Reviewer: 独立上下文 general | model=`opencode-go/deepseek-v4-flash` | route=default
首轮 verdict: **CONDITIONAL** —— P0=0, P1=3, P2=7; AC1–AC19 判据全部成立（重跑复现 10 条
可执行 AC；AC10 以 gh --version + keg + log 验证）；REGISTRY 改动严格限于 gh 3 字段无越界。
P1: ① AC17-prompt 未逐字节（已重写为契约原文 diff 空）；② AC17-raw 转述摘要（已补判分保真
说明）；③ AC3.txt SHA 失实（已重跑 f195b405）。P2-2 verify.sh 相对路径已改 $REPO 前缀。
增量复核: 原 P1×3 + P2-2 全 CLOSED；新增 **P1-EPIC**（处置期 EPIC 被外部更新 → 基线摘要
过期 → fence-audit 红）→ 按归因原则同步基线后 CLEAN（外部归因记录入 findings §6）。
最终: **PASS 条件满足**（无未闭合 P0/P1）。
- Phase=review | repair_round=1/3 | same_error_count=0/2 | verdict=RUNNING | Evidence=.tad/evidence/acceptance-tests/dependency-ops-skill/ | Next Action=L3.5 Technical Gate | 阻塞/错误=无 | 备注：L3 CONDITIONAL→增量复核 P1 全 CLOSED；P1-EPIC 外部归因已闭合

## Completion (2026-08-12)
**Commit**: uncommitted（L5 验收后 commit）
**Model**: harness=opencode | model=opencode-go/deepseek-v4-flash | route=default
- 上下文刷新：patterns/ac-verification.md（2026-08-05/06/11 条目）、patterns/pack-build-rules.md（frontmatter/skill-vs-MCP）、patterns/shell-portability.md（zsh 5.9 / yq -i / LC_ALL=C）、principles.md | 关键约束：禁 yq -i、HOMEBREW_NO_AUTO_UPDATE=1 含间接调用、日期运行时自导出 | 成功条件：AC1-AC19 全 PASS/如实声明 + skill 经 AC17 单文件复演证明承重
- 改动文件：.claude/skills/dependency-ops/SKILL.md、.agents/skills/dependency-ops/SKILL.md（镜像）、.tad/evidence/acceptance-tests/dependency-ops-skill/*（AC1-AC19 + verify.sh + source-coverage.md + findings.md + 基线/日志）、.tad/evidence/journal/dependency-ops-skill.md、.tad/dependencies/REGISTRY.yaml（仅 gh 3 字段）、.tad/dependencies/scan-results.yaml（脚本改写）[均清单内]
- Authority: mandate_id=dependency-ops-skill revision=4; bindings: local_write_registry→gh 3 字段、system_package_upgrade→HOMEBREW_NO_AUTO_UPDATE=1 HOMEBREW_NO_INSTALL_CLEANUP=1 brew upgrade gh、local_commit→仅本单产物
- Transactions: dependency-ops-skill-t1: preflight-baselines completed / author-skill completed / source-coverage-map completed / structural-acs completed / skill-load-bearing-gate completed（AC17 PASS）/ run-check completed / overdue-and-relevance completed / upgrade-gh completed / record-update completed / declare-unreachable completed / scope-fence-and-controls completed / write-findings-and-journal completed / independent-review completed / commit-evidence pending（L5 后）/ post-archive-fence pending
- Runtime decisions: avoidable_runtime_prompt_count=0; boundary_change_prompt_count=0; runtime_prompt_reasons=[]
- AC 结果：AC1-AC19 全 PASS（证据见 evidence 目录）；AC13 结构性不可达显式声明；AC17 首轮 Q3 出处 FAIL → fix → 转正
- Reviewer: CONDITIONAL → 增量复核 PASS 条件满足 | model=opencode-go/deepseek-v4-flash（执行实证）。P0=0, P1=3(fixed: AC17-prompt 逐字节化/AC17-raw 保真说明/AC3 SHA 重跑)+P1-EPIC(fixed: 外部归因同步基线), P2=7（其中 P2-2 已修）。摘录："AC1–AC19 判据全部成立……REGISTRY.yaml 改动严格限于 gh 条目 3 字段，无 P0 scope-violation"
- Technical Gate: GATE PASS（AC/evidence 全有原始输出 ✅ / reviewer PASS 条件满足 ✅ / 无 friction ✅ / scope 零越界 ✅ / Knowledge Assessment 三态已标记）
- Knowledge Assessment: journal captured（.tad/evidence/journal/dependency-ops-skill.md）——F8 教训应用 + 围栏三列格式决策 + AC17 Q3 盲点，建议后续 Alex 蒸馏
- 意外发现：gh 2.97.0 changelog 含 4 个安全公告（升级理由从例行升级升级为安全修复）
- follow-up：① release 回归未测（gh files_depending 4 处，下次 publish 观察）② limitation-resolution 分支未验（建议有真实 limitation 依赖时补）③ skill 未下游验证（Phase 6）④ AC19 契约期望行形态与实际双 keg 行不符（契约 P2-5，已如实记录）⑤ scope-baseline 三列格式建议推广到后续围栏单

## Reflexion
- 失败: AC17 首轮 Q3 出处被判"说明性文字" | 假设: 口径定义放"定位与口径"节即可 | 动作: 内联到 deps show 第 3 步操作指令 | 结果: 增量复核转正
- 失败: fence-audit 对 dirty tracked 摘要比对落 NEW-PATH 排除分支（两列基线无 SHA） | 假设: 复用 install-smoke 围栏即可 | 动作: 基线重建三列（状态 SHA 路径）+ base_sha 正则适配 | 结果: 负控 B 实证报出 VIOLATION-DIGEST
- 失败: 处置期 EPIC 外部更新致 fence-audit 红 | 假设: 基线摘要不变即可 | 动作: 按归因原则同步基线 + 记录 | 结果: CLEAN
- 失败: Bash 工具 while 循环内 PATH 丢失 | 假设: 工具环境稳定 | 动作: /bin/sh 包裹或绝对路径 | 结果: 基线正确生成
