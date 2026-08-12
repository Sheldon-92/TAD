# LITE Handoff: v2.41.0 安装路径冒烟测试（F8）

**Date**: 2026-08-11
**Revision**: 6（rev1 FAIL 6×P0 → rev2；复核 1 CONDITIONAL（1 个 P0 复活 + 4×P1）→ rev3；
复核 2 CONDITIONAL（0 个 P0，2×P1）→ rev4；复核 3 CONDITIONAL（唯一条件：REGISTRY 判据换 props）→ rev5；
reviewer 已就该替换预先声明"改完无条件转 PASS，不需第五轮"。
rev6 = 执行期判据缺陷修复（Blake 在 AC10b 实跑发现）：skills 根级 `*.md`（doc-organization.md）契约性不装
但 AC10/AC10b 豁免清单漏列 → 正确安装上必然 false FAIL。rev6 补 AC10 预期缺失 + AC10b 第 1 组豁免 +
AC19 缺口。权限面无变化，mandate 仍 revision 4。
**每一版的修订本身都在本机空跑**，见 L2.25 表末尾）
**Series**: Epic full-capability-extraction-retirement 的 Phase 3c follow-up F8（其余 follow-up：registry 陈旧、CHANGELOG 历史失序、Layer 2 advisory 478 处、前一单三项残留）

## 目标（含"为什么"）

v2.41.0 已推到 GitHub，但**从没有人从 GitHub 装过它**。Phase 3c 选择 publish-only（不 sync）的
全部立论就是"下游自己拉"——这条拉取路径至今未被跑通一次，而 `tad.sh` 恰在 2.41.0 的变更集内。
本单端到端跑通两条全新安装路径（`curl | bash`、`npx`）与两个升级变体，产出可复核证据。
发现问题只能发 2.41.1 向前修（远端不可回退），所以越早跑越好。

## 不做什么

- 不修任何被发现的缺陷（本单只诊断；修复另起一单，走 2.41.1）
- 不改 `tad.sh` / `README.md` / `package.json` / `CLAUDE.md` / `bin/tad-install.mjs`
- 不 push、不打 tag、不做 sync、不碰远端任何 ref
- **不写入任何存活下游项目**（升级 fixture 只做只读复制，源项目一个字节都不动）
- 不覆盖 2.30.0 以外的任何下游版本；不覆盖 `--platform claude-code` / `--platform codex` /
  `--packs` 子集三条分支。全部作为已知缺口由 AC19 显式声明，不假装已覆盖。

## 背景事实（设计期已核实 + rev1 审查复核；每条附代码载体）

1. **两条安装路径都跟 `main`，不跟 tag。** `tad.sh:28` `DOWNLOAD_URL=…/archive/refs/heads/main.tar.gz`、
   `tad.sh:29` `VERSION_URL=…/raw/main/.tad/version.txt`；`npx github:Sheldon-92/TAD` 拉默认分支。
   **本单验证的是 main-tracking 路径**，tag 路径无人使用。
2. **npx 路径不是交互式，且与 curl 路径共用同一个 `tad.sh`。**
   `bin/tad-install.mjs:85` `execFileSync('bash', [TAD_SH_PATH, '--platform','both','--yes'])`。
   ⚠️ **直接后果**：两条路径共享同一份实现，**同一个 bug 会在两侧同样发生**，
   所以 AC9（A==B）对"安装器自身有 bug"零判别力。判别力必须来自 AC10b 的内容级比对。
   README:154 的"交互式 `npx`"是过时描述 —— 记录为文档漂移，本单不修。
3. **tad.sh 的写入全部相对 CWD。** 全文无 `$HOME` / `~/` / 绝对 `/tmp` 写入；
   `tad.sh:1570` `curl … | tar -xz` 把源树解到 CWD 下的 `TAD-main/`，`tad.sh:1865` 收尾清理。
   ⚠️ **由此，唯一现实的越界向量是 CWD 走失**（Bash 工具每次调用 cwd 重置）——见 AC12 的 `pwd -P` 断言。
   唯一界外写入是 npm 缓存 `$HOME/.npm/_cacache`（npx 路径），mandate 内如实列明。
4. **`_tad_ver_cmp` 对畸形版本号是安全的**：`${A[i]:-0}` 补齐缺失分量、非数字分量归零，
   故 `""`→`0.0.0`、`1.5`→`1.5.0`、`2.1`→`2.1.0` 都正确判为"需升级"。**不要把它当缺陷去验**。
5. **选 2.30.0 作 fixture 的理由：它是出现次数最多的下游版本（≥6，现场普查为准）。**
   ⚠️ **rev1 更正（rev1 此处写错并标成"不必重查"，是本单最该被抓的一条）**：
   `.tad/migrations/` 中**不存在** `2.30.0-to-*.yaml`（实测清单为 `2.19.0-to-2.19.1` … `2.26.0-to-2.27.0`
   与 `2.31.2-to-2.32.0`，2.27.0→2.31.2 与 2.30.0 起点均为断链）。`resolve_chain`
   （`.tad/hooks/lib/migration-engine.sh:676-709`）会报 `chain gap at 2.30.0` 并 `exit 2`，
   被 `tad.sh:1131` 降级为 warning。**因此本单不会触及 migration engine 的实际迁移路径**——
   这是已知缺口，写入 AC19。原先"跨度大能压到 migration engine"的说法**事实相反**。
6. **`tad.sh` 从不安装自身，也不安装 `bin/`。** `.tad/platform-codes.yaml` 的
   `both.extra_root_files` 只有 `AGENTS.md`；全文无 `cp …/tad.sh ./` 或 `bin/` 拷贝。
   旁证：32 个下游项目中 31 个无 `bin/`、18 个无 `tad.sh`。
7. **capability-packs 是 registry-only**：`tad.sh:791-794` 对 `capability-packs` 目录只拷
   `pack-registry.yaml` 一个文件（发布树里该目录有 316 个文件）。
8. **升级会无条件覆盖 `.tad/project-knowledge/README.md`**：`tad.sh:1620`(install) /
   `1722`(upgrade) / `1800`(migrate) 三处均无条件 `cp`。实测 fixture 的该文件与 2.41.0 版**不同**。
9. **fixture 的两条"保护分支"都不可达**（实测 `menu-snap`）：
   `grep -c 'TAD:PROJECT-CONTENT-BELOW' CLAUDE.md` == **0**（无合并锚点 →
   `merge_claude_md` 走 `tad.sh:1341` 整体覆盖）；
   `find .claude/skills -maxdepth 2 -name '.tad-pack-meta.yaml' | wc -l` == **0**
   （无 pack meta → `copy_pack_skill_smart` 走 `tad.sh:597` Case 1b 整体覆盖）。
   **所以"定制被保留"在本 fixture 上是不可能发生的**——AC15 因此改为验证"覆盖行为符合预判"。

## 文件清单

**创建**（全部在 `.tad/evidence/acceptance-tests/install-smoke-v2410/`）：
- `verify.sh` —— 主执行脚本
- `AC01.txt` … `AC19.txt`（含 `AC10b.txt`、`AC12b.txt`）—— 逐条 AC 的原始输出
- `AC09-diff.txt`、`AC10-expected-missing.txt`、`AC10-real-missing.txt`、`AC10b.txt`
- `AC11.txt`、`AC14-baseline.txt`、`AC14-after.txt`、`AC14-symlinks-before.txt`、`AC14-symlinks-after.txt`
- `AC15-preconditions.txt`
- `scope-baseline.txt`
- `findings.md`
- `.tad/evidence/journal/install-smoke-v2410-2026-08-11.md` —— raw journal

**修改**：无。本单不修改任何既有文件。

**工作目录**（仓库外，不进 git）：`WORK=$(mktemp -d /private/tmp/tad-install-smoke.XXXXXX)`。
`preflight-baselines` 动作**一次性** `mkdir -p "$WORK/A" "$WORK/B" "$WORK/U" "$WORK/REF"`。
⚠️ **`"$WORK/U2"` 绝不预建** —— 它由 AC12b-pre 的 `cp -R` 创建。BSD `cp -R src dst` 在 `dst`
**已存在为目录**时产生 `dst/$(basename src)` 的嵌套，而非把内容铺进 `dst`（本机已复现：
预建 `U2` 后 `cp -R U U2` → `U2/U/marker.txt`，`U2/marker.txt` 不存在）。
`WORK` 实际值写进 `AC01.txt` 首行。**不得硬编码任何 session 专属 scratchpad 路径。**

## 实现约束

- **Bash 工具跑的是 zsh 5.9，不是 bash**（`patterns/shell-portability.md` 2026-08-05）：
  禁止 `for f in $VAR`、禁止数组、禁止 `[ "$a" \< "$b" ]`、禁止裸 glob（无匹配时 zsh 直接报
  `no matches found`，rev1 审查中已现场复现）。文件清单一律字面量逐行。
  `verify.sh` 以 `#!/bin/bash` 起首并用 `bash verify.sh` 调用。
  **所有变量展开一律加引号**（`"$WORK/A"` 而非 `$WORK/A`），本文件正文亦按此书写。
- **超时用 perl alarm，不要用 `timeout`/`gtimeout`** —— 本机实测两者**都不存在**。可用形式
  （实测超时退 142、正常退 0）：`/usr/bin/perl -e 'alarm shift; exec @ARGV' 900 npx -y github:Sheldon-92/TAD`。
  curl 自带 `--max-time 120`。长跑网络命令**不得裸跑**。
- **摘要清单统一用这一个形式**（AC11/AC14/AC16 共用，已对 CJK 路径实测）：
  `find "<dir>" -type f -print0 | xargs -0 /usr/bin/shasum -a 256 | LC_ALL=C sort -k2`
  **输出格式即 `<sha256>␠␠<path>`，按路径排序**。本文件正文一律用该格式描述，
  不再出现 `path<TAB>sha256` 的写法。
- 禁止用 `awk` 做任何字符串相等比较（`patterns/shell-portability.md` 2026-08-05：
  macOS `/usr/bin/awk` 把任意两个 CJK 字符串判为相等，而 AC19 的普查会扫到中文目录名）。
- **`comm` 输入纪律**（`patterns/shell-portability.md` 2026-08-05）：喂给 `comm` 的两份快照必须
  各自经**单次全局 `LC_ALL=C sort`**（不得分块排序后拼接），消费前先 `LC_ALL=C sort -c` 自检。
  该条目记载真实仓库上分块排序产生 185 假阳性 / 1 真违规。
- **查表禁用 `grep -F` 配锚点**（`patterns/shell-portability.md` 2026-08-10）：`-F` 关闭正则，
  尾部 `$` 变字面量，查表恒空、守卫变死代码。按路径查摘要一律用 `grep -E` 或精确字段比较。
- **每个 `ACnn.txt` 消费前必须断言非空**。zsh 的重定向先于命令查找：函数名拼错会产生
  **空文件 + exit 127**，而空文件看起来像"跑过了"。
- ⚠️ **`grep -v` 在过滤掉全部输入时退出码为 1** —— 而"完全没有差异"正是 AC10b 四组的**期望结果**。
  若 `verify.sh` 用了 `set -e` 或 `set -o pipefail`，成功路径反而会中断脚本。
  一律写成 `diff … | grep -v … | grep -c . || true`，把**差异行数**取进独立变量再断言，
  **不得依赖管线退出码**。
- **所有 AC 的命令输出一律以 `2>&1` 捕获落盘**。`tad.sh` 的 `log_info/log_warn/log_success`
  均为裸 `echo -e` 走 **stdout**，但 migration engine 的 `REJECT: chain gap …` 走 **stderr**
  （`migration-engine.sh` 内 `printf … >&2`）——只抓 stdout 会漏掉 AC14 依赖的那条证据。
- 每条 AC 的 `ACnn.txt` 末行写 `RESULT: PASS|FAIL|RECORD-ONLY`。

## AC

- AC1（前置状态）: 记录 `WORK` 路径。取三个 SHA：
  `git rev-parse HEAD`、`git ls-remote https://github.com/Sheldon-92/TAD.git refs/heads/main | cut -f1`、
  `git rev-parse 'v2.41.0^{commit}'`，三者**完全相同**。
  **另记录 `git rev-parse origin/main` 作为对照**（它读本地追踪 ref，未 fetch 时是陈旧快照，
  结构上无法发现"远端被推了新 commit"——所以真值取 `git ls-remote`）。
  `head -1 .tad/version.txt` == `2.41.0`。任一不成立 → 立即 BLOCK。
- AC2（线上产物 == 发布产物）: `curl -sSL --max-time 120 https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh`
  的 SHA-256 == 本地 `tad.sh` 的 SHA-256；且同法取 `.tad/version.txt` 首行 == `2.41.0`。
  不等 → FAIL 并记录双方 SHA。
- AC3（路径 A 执行）: 在空目录 `"$WORK/A"` 内执行
  `curl -sSL --max-time 120 https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes`，
  退出码 == 0，**且 stdout 含 `TAD v2.41.0 Ready`**（`tad.sh:1870` 的收尾横幅）。
  后一半不可省：`curl | bash` 的经典失败是下载中断导致 bash 执行**截断脚本**后正常退出，
  收尾横幅是"跑到了最后一行"的唯一证据。
- AC4（路径 A 版本）: `head -1 "$WORK/A/.tad/version.txt"` == `2.41.0`。
- AC5（路径 A 入口齐全）: 下列 **7 项**在 `"$WORK/A/"` 下全部成立，逐条落盘：
  `CLAUDE.md`(-f)、`AGENTS.md`(-f)、`.claude/skills/alex-lite/SKILL.md`(-f)、
  `.claude/skills/blake-lite/SKILL.md`(-f)、`.agents/skills/alex-lite/SKILL.md`(-f)、
  `.tad/hooks/`(-d)、`.codex/hooks.json`(-f，platform=both 生成物)。
  **补充记录（无判定）**：`test -e "$WORK/A/tad.sh"` 与 `test -e "$WORK/A/bin/tad-install.mjs"` 的结果落盘。
  依据背景事实 §6，二者**缺失是预期行为**；若意外存在，反而说明安装器行为变更，记入 findings。
- AC6（无下载残留）: `test ! -e "$WORK/A/TAD-main"` 成立（`tad.sh:1865`）。
  **注**：AC3 FAIL 时本 AC 结果无独立含义（失败路径不走清理），届时标 `RECORD-ONLY`。
- AC7（路径 B 执行）: 在空目录 `"$WORK/B"` 内执行
  `/usr/bin/perl -e 'alarm shift; exec @ARGV' 900 npx -y github:Sheldon-92/TAD`，退出码 == 0，
  **且 stdout 含 `TAD v2.41.0 Ready`**。`-y` 必须有（否则 npx 停在未缓存包的确认提示，
  非交互下即挂死）。退出码 142 == 超时，判 FAIL 并记为**超时**而非安装失败。
- AC8（路径 B 版本与入口）: `head -1 "$WORK/B/.tad/version.txt"` == `2.41.0`，
  且 AC5 的同一 7 项在 `"$WORK/B/"` 下成立，同样附那 2 项无判定记录。
- AC9（两路径等价）: `diff -rq "$WORK/A" "$WORK/B" > AC09-diff.txt`。断言：差异行数 == 0。
  **唯一可解释的差异类别**：`.tad-pack-meta.yaml` 的 `installed_date:` 行 —— 该字段为
  `date +%Y-%m-%d`（**只到日、无时刻；文件内路径为相对路径、无绝对路径**，`tad.sh:382/404/410`
  已核实并在真实安装产物上验证）。故仅当 A、B 两次安装**跨越零点**时才可能差异；同日内应为 0。
  **出现任何其它 meta 差异（尤其 `sha256:` 行）一律按真缺陷处理，不得归入"元数据差异"。**
  下列任一出现差异即 FAIL：任一 `SKILL.md`、任一 `.tad/capability-packs/**/*.yaml`、
  任一 `.tad/hooks/**`、`.claude/settings.json`、`.codex/hooks.json`、`.tad/version.txt`。
  ⚠️ 本 AC 对"安装器自身有 bug"零判别力（背景事实 §2：两路径共用同一 `tad.sh`），
  判别力由 AC10b 提供。
- AC10（相对发布 commit 树的完整性 —— 按类别锁，并显式扣除安装器契约性不安装的子树）:
  `git archive <AC1 实测 SHA> | tar -x -C "$WORK/REF"`。枚举「存在于 `REF` 但不存在于 `A`」的
  全部路径，先按下列**预期缺失前缀**分流到 `AC10-expected-missing.txt`（不构成 FAIL，须完整落盘）：
  - `.tad/capability-packs/` 下**除 `pack-registry.yaml` 外的全部**（`tad.sh:791-794` registry-only）
  - `.tad/` 的 zero-touch 与 transient 目录（`tad.sh:223-249` `TAD_DENY_LIST`）：
    `active/ archive/ evidence/ pair-testing/ decisions/ github-registry/`
    `research-notebooks/ skill-library/ skillify-candidates/ memory/ dependencies/ working/`
    `spike-v3/ reports/ checklists/ domains/`
  - `.tad/project-knowledge/` 下**除 `README.md` 外的全部** ⚠️ 不可整棵豁免：
    `tad.sh:1620`（install 分支）单独 `cp` 该 README，且带 `2>/dev/null || true`——**失败是静默的**，
    整棵豁免会把一次真实的拷贝失败静默归入"预期"。这是 deny-list 中唯一"目录整体不装、
    但有单个文件要装"的特例，也最容易被前缀豁免吃掉。
  - `.tad/sync-registry.yaml`（`TAD_TOP_DENY` —— 实测该变量只含这一个文件名，
    故 `.tad/` 顶层其余 **20** 个文件**全部会被安装**，见 AC10b 第 5 组）
  - `.claude/agents/`、`.claude/commands/`、`.claude/rules/`、`.claude/settings.json.v2-backup`
    （安装器不拷贝；预先列明以免执行者当成发现）
  - **`.claude/skills/*.md` 与 `.agents/skills/*.md` 的根级 md 文件**（rev6 补，执行期实跑发现）：
    `tad.sh:822`（claude 侧）与 `tad.sh:883`（agents 侧）skills 拷贝循环都是 `for skill_dir in "$src"/.claude/skills/*/`
    —— 只遍历**子目录**，根级 `*.md` 从不安装。实测唯一实例 `doc-organization.md`（v1.4 时代遗留，
    v1.5 起 skills 全目录化，无任何 SKILL.md 引用它；升级归档 `tad.sh:1704/1784` 显式豁免保留
    `doc-organization.md`——按用户文件处理）。**若出现根级 md 之外的未预期前缀 → 仍按真缺陷进 findings。**
  - 仓库工作文件（安装器不拷贝）：`tad.sh`、`bin/`、`package.json`、`.codex/`、`.vscode/`、
    `docs/`、`assets/`、`supabase/`、`tad/`、`tad-work/`、`scripts/`、`.gitignore`、
    `CHANGELOG.md`、`ROADMAP.md`、`NEXT.md`、`OBJECTIVES.md`、`PROJECT_CONTEXT.md`、
    `INSTALLATION_GUIDE.md`、`LICENSE`、`README.md`、`tad-intro*.html`

  剩余清单 `AC10-real-missing.txt` 的断言（四类全成立 → PASS）：
  (a) 不含匹配 `^\.claude/skills/.*/SKILL\.md$` 或 `^\.agents/skills/.*/SKILL\.md$` 或
      `^\.tad/skills/.*/SKILL\.md$` 的任何行 —— 必须用 `grep -E` 写全锚点，
      **不得用 `grep 'SKILL\.md'`**（会误捕
      `.tad/evidence/pack-quality/negative-controls/bad-structure-SKILL.md`）；
  (b) 不含 `^\.tad/capability-packs/pack-registry\.yaml$`；
  (c) 不含任何 `^\.tad/hooks/` 下的文件；
  (d) 不含 `CLAUDE.md`、`AGENTS.md`、`.tad/project-knowledge/README.md`。
  ⚠️ **上述"预期缺失前缀"本身是硬编码 allow-list**，正是 `principles.md` 2026-06-01 警告的形态。
  可接受的理由是它有界且逐项有代码载体（每条标了行号）。**若剩余清单出现未预期前缀，
  一律进 findings 而非静默归入预期。**
- **AC10b（内容级等价 —— 本单判别力的主要来源，不可省）**: 下列四组全部 `differ` 行数 == 0 → PASS：
  1. `diff -rq "$WORK/REF/.claude/skills" "$WORK/A/.claude/skills" | grep -v '\.tad-pack-meta\.yaml' | grep -v 'doc-organization\.md'`
     （rev6 补：`doc-organization.md` 为契约性不装，豁免依据见 AC10 预期缺失清单；**仅豁免该文件本身**，
     其它任何差异——尤其任一 `SKILL.md`、`capability-packs/**/*.yaml`、`.tad/hooks/**`——仍按真缺陷 FAIL）
  2. `diff -rq "$WORK/REF/.tad/hooks" "$WORK/A/.tad/hooks"`
  3. `cmp -s "$WORK/REF/CLAUDE.md" "$WORK/A/CLAUDE.md"` 且 `cmp -s "$WORK/REF/AGENTS.md" "$WORK/A/AGENTS.md"`
  4. `diff -rq "$WORK/A/.claude/skills" "$WORK/A/.agents/skills" | grep -v '\.tad-pack-meta\.yaml'`
     （platform=both 的双写一致性）
  5. **`.tad/` 的 20 个顶层文件**（`TAD_TOP_DENY` 只排 `sync-registry.yaml`）。清单**逐行字面量书写**，
     不得用 glob（zsh 无匹配即报错）：
     `CHANGELOG.md` `README.md` `brain-index.md` `config-agents.yaml` `config-cognitive.yaml`
     `config-execution.yaml` `config-platform.yaml` `config-quality.yaml` `config-workflow.yaml`
     `config.yaml` `deprecation.yaml` `manifest.yaml` `mcp-registry.yaml` `platform-codes.yaml`
     `portable-extract.sh` `portable-rules.md` `project-detection.yaml` `routing-contract.yaml`
     `skills-config.yaml` `version.txt`
     对**全部 20 个**逐个 `cmp -s "$WORK/REF/.tad/<f>" "$WORK/A/.tad/<f>"`，全部成立。
     **`version.txt` 不排除**：发布树该文件为 `2.41.0\n`（7 字节，`od -c` 实测），
     安装器写的 `echo "$TARGET_VERSION" > .tad/version.txt` 中 `TARGET_VERSION` 由
     `derive_target_version` 从**同一个文件**导出、`echo` 补回换行 → 产出逐字节相同的 7 字节，
     故 `cmp` 在正确安装上成立，排除它换不来任何可满足性。
     ⚠️ 排除它反而开洞：AC4 只查 `head -1`，若 `version.txt` 变成 `2.41.0\n<垃圾>\n`，
     两条都会通过。若此处真的 MISMATCH，那是**一条值得报的真发现**（安装器写出的
     version.txt 与发布产物字节不一致），按 finding 落盘，不要当成契约缺陷。
     ⚠️ `.tad/portable-extract.sh` 正是 `principles.md` 2026-06-01 记载的"被扩展名 allow-list
     静默漏掉"的那个文件（`tad.sh:271` 注释直接引用该事故）。它此前不在任何 AC 覆盖内。
  6. `cmp -s "$WORK/REF/.claude/settings.json" "$WORK/A/.claude/settings.json"` 且
     `diff -rq "$WORK/REF/.claude/workflows" "$WORK/A/.claude/workflows"` 差异行数 == 0。
     `settings.json` 缺失或损坏 == 所有 hook 失效，是安装质量的核心面，此前零覆盖。

  完整输出落 `AC10b.txt`。**理由**：AC5 的 `test -f` 对 0 字节文件成立，AC10 只枚举路径，
  AC9 因两路径共用同一 `tad.sh` 会把同一 bug 在两侧同样复现 —— 若无本 AC，
  一个"文件全在、内容全错"的安装可以让 20 条 AC 全绿。
- AC11（升级 fixture 构建，源只读）: 源 = `/Users/sheldonzhao/01-on progress programs/menu-snap`（2.30.0）。
  构建**前**用指定管线记录源的 `.tad/` `.claude/` `.agents/` 摘要（`<sha256>␠␠<path>`，按路径排序）
  → `AC11.txt`；`cp -R` 其 TAD 表面（`.tad/`、`.claude/`、`.agents/`、`tad.sh`、`CLAUDE.md`、
  `AGENTS.md`，存在哪个拷哪个）到 `"$WORK/U/"`。**全部操作结束后**重算同一摘要，
  断言与构建前**完全相同**。不同 → 立即停止全部后续动作并上报（污染真实项目是本单最严重的失败模式）。
  **体量与降级**：实测源 `.tad` 为 9559 文件 / 255M。若耗时不可接受，允许有界降级：
  可裁剪 `.tad/active/research/saas-billing/node_modules/`（文件数大头）与 `.tad/evidence/` 的子目录，
  但**每个顶层子目录至少保留一个文件**（否则 AC14 失去判别力），且必须在 `findings.md` 记录裁剪内容。
- AC12b-pre（U2 预复制 —— 必须在 AC12 之前执行）: 在 AC15 植入与 AC14 基线记录**完成之后**、
  AC12 执行**之前**，用**内容拷贝**形式（与 AC11 一致，**不是** `cp -R "$WORK/U" "$WORK/U2"`）：
  `mkdir -p "$WORK/U2" && cp -R "$WORK/U/." "$WORK/U2/"`
  随后立即三条断言，全部落 `AC12b.txt` 开头：
  (i) `test ! -e "$WORK/U2/U"` —— **目录嵌套专用探针**。BSD `cp -R src dst` 在 `dst` 已存在为目录时
      产生 `dst/$(basename src)`；若 `U2/U` 存在即说明发生了嵌套，此时后续全部断言无意义。
  (ii) `test -d "$WORK/U2/.tad"`
  (iii) `head -1 "$WORK/U2/.tad/version.txt"` == `2.30.0`
  ⚠️ 这三条不可省。若 U2 因嵌套而**没有 `.tad/`**，`curl | bash` 在那里跑的是一次**全新安装**
  而非升级；全新安装不打印 `Nothing to do`，所以 AC12b 的空跑硬禁抓不到它，
  而 AC13 的版本断言照样会通过 —— AC12b 与 AC13 双双报绿而 curl **升级**路径一次都没跑。
- AC12（升级执行，本地 tad.sh 变体）: 用**单条**命令，`cd` 与 `bash` 不得分处两次工具调用：
  `cd "$WORK/U" && test -f ./tad.sh && [ "$(pwd -P)" = "$WORK/U" ] && bash tad.sh --yes`
  退出码 == 0。`pwd -P` 断言与 `&&` 短路共同保证 CWD 正确 —— 这是本单唯一现实的越界防护
  （背景事实 §3）。
  **且 stdout 须同时满足 AC12b 的 (a)(b) 三个条件**（禁 `Nothing to do`、含预告期证据、
  含执行期证据）。本 AC 若只查退出码会比 AC12b 弱，而两个变体的失败模式完全相同。
  ⚠️ **本 AC 跑的是 fixture 自带的 2.30.0 版 `tad.sh`**。四个锚点**文本已实查与 2.41.0 版逐字相同**，
  但**行号不同**：预告期证据在 `menu-snap/tad.sh:1040`（非 1537）、执行期证据在 `:1208`（非 1718）、
  migration 证据在 `:707`（非 1131）、收尾横幅在 `:1359`。**判定一律按文本，行号仅供复核定位。**
  另：2.30.0 版**没有** 2.41.0 的"下载后复判早退"块（`Nothing to do` 全文仅 `:1014` 状态闸一处），
  故条件 (a) 对本变体是冗余保险而非主要防线。
- AC12b（升级执行，curl 变体）: 同样的 CWD 纪律，在 `"$WORK/U2"` 内执行
  `cd "$WORK/U2" && [ "$(pwd -P)" = "$WORK/U2" ] && curl -sSL --max-time 120 https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes`
  退出码 == 0，**且同时满足两个 stdout 条件**：
  (a) **不得含** `Nothing to do` —— `tad.sh:1584-1590` 在 `CURRENT_VERSION >= TARGET_VERSION` 时
      直接 `exit 0`；出现即判 FAIL 并记为"变体空跑"。
  (b) **必须含两条 upgrade 证据，缺一不可（二者层级不同）**：
      - **预告期证据** `handoffs, evidence, project-knowledge`（`tad.sh:1537`，upgrade 分支专属）。
        ⚠️ 锚点只取这段文本，**不要写成 `✓ Preserved: handoffs`**：源码是
        `${GREEN}✓ Preserved:${NC} handoffs, …`，冒号与 `handoffs` 之间夹着 ANSI 重置码，
        连写模式实测匹配 **0** 次。migrate 分支（`tad.sh:1545`）也含 `✓ Preserved:` 但后半段是
        `All your work data will be migrated`，故必须取无色码段才既能匹配又能区分三分支。
      - **执行期证据** `→ Updating CLAUDE.md...`（`tad.sh:1718`，全文唯一、upgrade 分支专属，
        且位于 `copy_framework_files` 与 `call_migration_engine` **之后**）。
      ⚠️ 为什么两条都要：预告块（`tad.sh:1522-1547`）在 `AUTO_YES` 判断**之前**无条件执行，
      所以预告期证据只证明 `ACTION` 被**判定**为 upgrade，不证明 upgrade 分支**跑到了**。
      反例：`PROBE_OK != 1` 时 `tad.sh:1509` 强制 `ACTION=upgrade` → 预告照打 →
      `tad.sh:1584-1590` 早退 `Nothing to do` → 此时预告期证据出现而执行期证据不出现。
  ⚠️ (a)(b) 缺一不可：只禁 `Nothing to do` 无法区分"升级"与"误落成全新安装"——
  后者正是 U2 目录嵌套时会发生的事。
- AC13（升级后版本）: `head -1 "$WORK/U/.tad/version.txt"` == `2.41.0`
  且 `head -1 "$WORK/U2/.tad/version.txt"` == `2.41.0`。
- AC14（用户数据 —— 冻结集 + 授权写入集，本单最重要的一条）:
  升级**前**对 `"$WORK/U"` 下四棵子树用指定管线记录 → `AC14-baseline.txt`：
  `.tad/active/`、`.tad/evidence/`、`.tad/project-knowledge/`、`.tad/memory/`（存在哪棵记哪棵）。
  升级后重算 → `AC14-after.txt`。
  - **冻结集断言**：两文件在**排除 `.tad/project-knowledge/README.md` 这一条路径后** `diff` 为空。
    任何其它差异逐条落盘并判 FAIL。
  - **授权写入集正向断言（不可省，否则"排除"就等于"盲区"）**：升级后
    `cmp -s "$WORK/U/.tad/project-knowledge/README.md" "$WORK/REF/.tad/project-knowledge/README.md"`
    必须成立 —— 即该文件**确实**被换成 2.41.0 版（依据 `tad.sh:1722` 无条件 `cp`）。
    若它反而未变，说明 upgrade 分支未执行，同样 FAIL。
  - **排除的唯一理由**：背景事实 §8。实测 fixture 副本与 2.41.0 版不同，故"逐字节不变"按原文不可满足。
  - **`.tad/active/`、`.tad/evidence/` 保持全树冻结**：`tad.sh` 对二者只做 `mkdir -p`
    （空目录，`find -type f` 不可见）；migration engine 因断链 `exit 2` 零写入（背景事实 §5）。
    **`AC12.txt` 中须留有 migration 被跳过的证据行**，锚点钉死为 stdout 上那条确定的串
    `Migration skipped: manifest invalid or chain gap (exit 2)`（`tad.sh:1133` 的 `log_warn`）。
    ⚠️ 不要用 `chain gap` 做锚点：engine 自己的 `REJECT: chain gap at 2.30.0` 走 **stderr**，
    两个来源都含该词，用它会分不清抓到的是哪一条（这也是「实现约束」要求全程 `2>&1` 的原因）；
    **若该行未出现（说明 engine 真的跑了迁移），本 AC 的冻结集必须重新论证后才可判定**，
    不得直接判 PASS。
  - **`.tad/memory/`**：`tad.sh` 全文无写入，全树冻结。
  - **符号链接盲区（须落盘）**：`find -type f` 不含符号链接。实测 fixture 源含 7 个符号链接
    （全在 `.tad/active/research/saas-billing/node_modules/.bin/`，且**全为相对链接**）。
    故须另跑
    `find "$WORK/U/.tad" "$WORK/U/.claude" "$WORK/U/.agents" -type l -exec ls -ld {} \; | LC_ALL=C sort`
    前后各一次（→ `AC14-symlinks-before.txt` / `AC14-symlinks-after.txt`）并 diff，断言为空。
- AC15（覆盖行为符合预判 —— 由 fixture 状态推导，**不是**"定制必被保留"）:
  升级**前**记录三项 fixture 事实 → `AC15-preconditions.txt`：
  - (p1) `grep -c 'TAD:PROJECT-CONTENT-BELOW' "$WORK/U/CLAUDE.md"`（实测源为 **0**）
  - (p2) `find "$WORK/U/.claude/skills" -maxdepth 2 -name '.tad-pack-meta.yaml' | wc -l`（实测源为 **0**）
  - (p3) 两个植入点路径，**必须一个 pack skill**（在 `pack-registry.yaml` 中有条目，如
    `academic-research`）**与一个非 pack skill**（如 `alex`）**各一处**，不是"任选一个"
  - (p4) `cmp -s "$WORK/U/.tad/project-knowledge/README.md" "$WORK/REF/.tad/project-knowledge/README.md"`
    在**升级前**必须**不成立**（两者确实不同）。这是 AC14 正向断言的判别力前提：
    若升级前二者已相同，那条 `cmp -s` 恒真，正向断言退化为"什么也没证明"，
    须在 `findings.md` 如实标注"该断言本轮退化为恒真"。今日实测 fixture 与 2.41.0 版 **DIFFER**。

  植入标记 `<!-- TAD-SMOKE-CUSTOM-MARKER-AC15 -->` 于：`CLAUDE.md` 末尾 + 上述两个 `SKILL.md` 末尾。
  **预判（由 p1/p2 与 `tad.sh` 分支推导，写在升级之前）**：
  p1==0 → `merge_claude_md` 走 `tad.sh:1341` 整体覆盖 → CLAUDE.md 标记**预期消失**，
  且 `CLAUDE.md.bak` **预期存在且含标记**；
  p2==0 → pack skill 走 `copy_pack_skill_smart` Case 1b（`tad.sh:597`）整体覆盖 → 标记**预期消失**；
  非 pack skill 走 `tad.sh:839 cp -r` 无条件覆盖 → 标记**预期消失**。
  **断言**：升级后三处实际结果与上述预判**逐项一致** → PASS；任一项与预判不符 → FAIL 并落盘实际分支。
  **附加断言**：`test -f "$WORK/U/CLAUDE.md.bak"` 且其中标记 `grep -c` == 1 ——
  这是"用户内容未被静默丢弃"的**唯一**现存保护，比标记本身是否存活更重要。
  **findings 必须写明**：本 fixture 无合并锚点、无 pack meta，因此 hash-skip 保护分支
  （`copy_pack_skill_smart` Case 4）与 `merge_claude_md` 有锚点分支**在本单中不可达、完全未被验证**
  —— 这是本单最大的覆盖缺口，须进 AC19。
- AC16（范围围栏 —— TAD 仓库未被本单改动）: 开工前记录 TAD 仓库 `git status --porcelain -uall`
  完整集合 + 全部 dirty tracked 路径的摘要 → `scope-baseline.txt`。收尾时重算，
  断言差异仅落在下列**契约声明的排除清单**内：
  - **本单产物**：`.tad/evidence/acceptance-tests/install-smoke-v2410/**`、
    `.tad/evidence/journal/install-smoke-v2410-2026-08-11.md`、本契约文件本身、
    本单事务锁 `.tad/active/handoffs/LITE-20260811-1951-install-smoke-v2410.md.txn-lock`、
    归档目标 `.tad/archive/handoffs/LITE-20260811-1951-install-smoke-v2410.md`
  - **框架自写路径（每项标注写入者）** —— `patterns/ac-verification.md` 2026-08-10：
    仓库自身 hook 在执行期写入，不排除则围栏按原文不可满足：
    - `.tad/evidence/traces/**` — `trace-step.sh`、`post-write-sync.sh` 的 `record_trace`
    - `.tad/evidence/decisions/**` — `lib/askuser-capture.sh`（PostToolUse `AskUserQuestion`；
      **本单必然触发**：contract/mandate 决策与最终验收都走 AskUserQuestion）
    - `.tad/logs/**`
    - `.tad/active/precompact/**` — `precompact-session-snapshot.sh`
    - `.tad/active/session-state.md` — `post-write-sync.sh`
    - `.tad/memory/**` — native auto-memory
    - **`.tad/research-notebooks/REGISTRY.yaml`** — `notebook-dormant-sync.sh` 的
      `recompute_notebook_dormancy`（SessionStart 触发，每次 startup/resume/compact 都会写）。
      ⚠️ **不做整条排除，改为「限定形状」排除**：整条排除会让"本单误写该文件"这一 **mandate
      违约行为对围栏完全失明**，而它恰好本就 dirty，人工肉眼也难分辨。具体做法：
      preflight 时除摘要外**另存一份完整副本**到
      `.tad/evidence/acceptance-tests/install-smoke-v2410/registry-baseline.yaml`；
      收尾若摘要变化，做**结构化属性路径比对**（**不是行级文本比对** —— 行级会被尾注释击穿，见下）：
      ```
      yq -o=props '.' "$BASE/registry-baseline.yaml"         | LC_ALL=C sort > "$BASE/reg-b.props"
      yq -o=props '.' .tad/research-notebooks/REGISTRY.yaml  | LC_ALL=C sort > "$BASE/reg-c.props"
      diff "$BASE/reg-b.props" "$BASE/reg-c.props" > "$BASE/reg.propsdiff" || true
      ```
      断言两则，**两条都成立才 PASS**：
      - **(i) 路径闭合**：`reg.propsdiff` 中每条 `^[<>]` 行的**属性路径**（`=` 左侧去空白）
        必须匹配 `^notebooks\.[0-9]+\.status$`（`grep -E`，**不得用 `grep -F`** ——
        `patterns/shell-portability.md` 2026-08-10）。出现任何其它路径 → **FAIL**（那不是 hook 写的）。
      - **(ii) 值域闭合**：每条 `^>` 行的**值**（`=` 右侧去空白）∈ `{active, dormant}`。
        出现 `archived` 或其它值 → **FAIL**（hook 的 `select(.status != "archived")` 决定它永不写 archived）。

      **为什么用 props 而非行级正则**：真实 `REGISTRY.yaml` 的 `status` 行有 4 种形态，其中
      `:127` 是 `    status: dormant # active / dormant / archived` —— **带行尾注释**。
      行级正则的 `(active|dormant)[[:space:]]*$` 对它实测匹配 **0** 次，该条目一旦翻转即误 FAIL
      （今日恰好不翻转，属运气不属设计）。`yq -o=props` 剥离注释、缩进与引号形态，从根上免疫。
      **数量护栏**（不设硬上界——执行者无法独立获得"翻转条数"这个基数：它由运行时的
      `now - last_queried > threshold` 决定，要算就得重实现 hook 逻辑，那不是独立验证）：
      变化路径数 > 5 时**不自动 FAIL**，但必须在 `findings.md` 逐条列出并附各自的
      `last_queried` 与 age，供人复核。批量篡改仍会被 (i)(ii) 之外的人工复核捕获。
      **保留行级 `diff registry-baseline.yaml REGISTRY.yaml` 落盘作人读辅助，但判定权归 props 比对。**
      **时机敏感性（须落盘）**：`notebooks.0` 当前 `status: active` / `last_queried: 2026-07-12`，
      相对 2026-08-11 的 age **恰为 30**，而 hook 条件是 `age_days > 30`（**严格大于**）→
      今日不翻转、次日翻转。故本守卫是否被真正触发**取决于执行日期**。preflight 须记录执行日期与
      `yq -r '.research_notebook.dormant_after_days' .tad/config-workflow.yaml`（实测 30）。
      这与 AC9 的 `installed_date` 跨零点是同一类时机敏感性。
      **依据（逐字取自实现，不靠字段名的语义联想）**：`lib/notebook-lifecycle.sh` 的
      `recompute_notebook_dormancy` **唯一的写操作**是 `yq -i '(… | .status) = env(STATUS)'`，
      且 `STATUS` 值域被限定为 `{active, dormant}`；`last_queried` 在该函数中**仅被读取**
      （用于算 age），从不写回；`dormancy` 这个字段名在实现中**根本不存在**。
      ⚠️ **不得把 `last_queried` 放进白名单** —— 它恰是 `*research` / notebook 生命周期操作会改的
      字段，即"非 hook 写入 REGISTRY.yaml"最可能长的样子；放行它等于把守卫开在它要防的那扇门上。
      完整 diff（props 与行级两份）无论 PASS 与否都落盘。
      **preflight 须一并记录 `command -v yq` 与 `yq --version`**：该 hook 在
      `lib/notebook-lifecycle.sh` 开头有 `command -v yq >/dev/null 2>&1 || return 0` 守卫，
      **yq 缺席时全程 no-op**，此时本 carve-out 应收紧为"REGISTRY.yaml 必须逐字节不变"
      （更强的断言），并在 findings 记录该收紧。本机实测 yq 在场（mikefarah v4.53.3）。
      **规范化风险已实测排除**：`yq '.' REGISTRY.yaml` 与原文 `diff` 为 **0 行**
      （mikefarah v4.53.3 对本文件完美 round-trip，注释/缩进/引号/空行全保）。
      若未来文件结构变化，需重测此项。
    - `.tad/brain-index.md` — 由 `lib/brain-index-gen.sh` **整体重写**，形状约束不可行。
      preflight 一并记录其 `shasum` 到 `scope-baseline.txt`；收尾若变化，
      **必须在 findings 中指认触发它的 hook**；指认不出即 FAIL。
      （rev2 写的"确认 mtime，未变则删掉该行"无基线可比，不可执行，已作废。）
  - **开工时已 dirty 的 tracked 文件：其摘要必须不变。** 该集合的**数量与内容以 preflight 实测为准**，
    逐路径落盘，**不得硬编码计数**（`principles.md` 2026-06-01：永不 pin 绝对计数，改为 live 断言）。
    `.tad/research-notebooks/REGISTRY.yaml` 若在该集合内，按上述限定形状处理，不计入"必须不变"。
- AC17（围栏正反双控 —— `patterns/ac-verification.md` 2026-08-05）:
  **负控**：在 `.tad/domains/` 下临时创建 `SMOKE-FENCE-PROBE.txt`（已核实该路径非 gitignore，
  对 `git status -uall` 可见），重跑围栏逻辑，断言它**被报出**；随后删除探针，
  并在收尾断言 `test ! -e .tad/domains/SMOKE-FENCE-PROBE.txt`（探针必须在同一动作内销毁，
  不得留到 commit）。
  **正控须跑两次**：(a) 全部 evidence `git add` 后；(b) 本契约归档移动完成后。两次都必须静默通过。
  三次运行的原始输出全部落盘。缺任一控 → 围栏不算验证过。
- AC18（界外写入如实申报）: 记录 npx 运行前后 `du -sh "$HOME/.npm/_cacache"` 两个数
  （用 `"$HOME"` 不用 `~`：波浪号作为数据携带时不展开，`patterns/shell-portability.md` 2026-08-06）。
  本 AC **无 PASS/FAIL 判定**（`RECORD-ONLY`），只要求如实落盘 —— 契约明列 npm 缓存为已接受的
  界外写入，不假装"零界外写"。
- AC19（缺口显式声明）: `findings.md` 必须含一节，内容由**执行时刻现场重算**得出，不得硬编码：
  - 下游版本分布：遍历 `"/Users/sheldonzhao/01-on progress programs"/*/` 读 `.tad/version.txt`，
    `LC_ALL=C sort | uniq -c`（禁用 `awk` 比较，目录名含中文）。
    ⚠️ 引号只包**不含 glob** 的部分——路径含空格，整体加引号会让 `*/` 失效，整体不加引号在
    `#!/bin/bash` 下会按空格拆成三段。
  - 显式声明"本单仅覆盖 `2.30.0`，上表其余版本全部未覆盖"
  - 未覆盖的平台组合：`--platform claude-code`、`--platform codex`、`--packs` 子集
  - 未覆盖的分支：`copy_pack_skill_smart` Case 4（hash-skip）、`merge_claude_md` 有锚点分支、
    migration engine 有效链路（本 fixture 断链）
  - 未覆盖的检查面：`.tad/hooks/**` 可执行位、`.claude/settings.json` JSON 合法性、
    `.codex/hooks.json` 生成正确性
  - **U2 上未跑 AC14/AC15**（curl 变体的数据零损失未验）
  - **skills 根级 `*.md` 不安装**（rev6 补）：`.claude/skills/doc-organization.md` 与
    `.agents/skills/doc-organization.md` 在发布树存在但安装器契约性不装（`tad.sh:822/883` 只遍历子目录）；
    `tad.sh:1704/1784` 升级时显式豁免保留它。新装项目不会获得该文件——是否为期望行为待产品裁定。
  - **本单验证的是 `both` 平台**；`doc-organization.md` 的缺失在单平台（claude-code / codex）下
    行为未单独验证（与 `--platform` 子集同为已知缺口）。
  缺此节 → FAIL（沉默截断会被读成"全覆盖"）。

## 知识引用

- `.tad/project-knowledge/patterns/shell-portability.md`（2026-08-05 zsh 条目）—— Bash 工具跑 zsh，
  不词分割、数组 1-indexed、`\<` 报错、裸 glob 报错；导出「实现约束」的书写要求。
- 同文件（2026-08-05 `comm` 条目）—— 非全局排序输入会让 `comm` 静默说谎（真实仓库上 185 假阳性
  / 1 真违规）；导出 AC16/AC17 的单次全局 `LC_ALL=C sort` + `sort -c` 自检纪律。
- 同文件（2026-08-10 `grep -F` 条目）—— `-F` 关闭正则锚点，尾部 `$` 变字面量导致查表恒空、
  守卫变死代码；导出「按路径查摘要一律用 `grep -E`」。
- 同文件（2026-06-11 npx 条目）—— `npx <pkg>` 会触发网络解析/下载/挂死，非本地探针；
  **由此导出的是 timeout 要求**。⚠️ 更正：该条目**未涉及** `-y` 标志；`-y` 的依据是 npm 自身
  对未缓存包的交互确认行为，不是这条知识（rev1 审查指出原引用此处属断章）。
- `.tad/project-knowledge/patterns/ac-verification.md`（2026-08-10 摘要围栏条目）—— 排除清单是
  **契约义务**不是实现补丁，且须枚举 telemetry/journal/session-state/**lock file**/index cache；
  导出 AC16 的完整排除清单（rev1 漏了 lock file、decisions、REGISTRY.yaml 三类）。
- 同文件（2026-08-05 正反双控条目）—— 只测负控只证明闸能拒，不证明它放行合法工作；
  导出 AC17 的双控 + 探针需对被测机制可见。
- 同文件（**2026-08-06「Before Trusting a Guard, Measure Whether Its Trigger Condition Can Even
  Occur」**）—— 验证了机制存在 ≠ 验证了机制在本 fixture 上可达；这正是 rev1 的 AC15 踩的坑
  （只确认 smart-copy 分支存在，未确认它在无 pack-meta 的 fixture 上可达）。导出 AC15 改为
  "先记录 p1/p2 前置事实、由分支推导预判、再断言实际与预判一致"。
- `.tad/project-knowledge/patterns/release-sync.md`（2026-08-06 修订段）—— 防护要测**文件系统**
  （`diff -rq` / `test ! -e`），永不用 `git status` 判断树内容；导出 AC9/AC10/AC10b/AC14 一律用
  文件系统级比对。
- `.tad/project-knowledge/principles.md`（2026-06-01 全局计数条目）—— 当同一产物也会**合法移除**
  被清点项时，全局计数无法区分合法移除与 must-cover 丢失；导出 AC10 按类别锁**并显式扣除**
  registry-only / deny-list 的合法移除（rev1 只做了前半，故必红）。

## Execution Mandate

mandate_id: `install-smoke-v2410` | revision: 4 | authority_mode: contract-mandate

**revision 4 相对 revision 2 的变更点（权限面的实质扩大，须随 revision 一并接受）**：
`local_write_evidence` 新增第 (6) 项围栏探针 `.tad/domains/SMOKE-FENCE-PROBE.txt`
（AC17 负控专用，生命周期限定在该动作内，收尾断言其不存在）。
rev4 / rev5 / rev6 **均未再扩大任何权限面**（rev4 收紧 REGISTRY 白名单并同步元数据；
rev5 把 REGISTRY 判据从行级正则换成 props 比对；rev6 补 `doc-organization.md` 的豁免
——三者都是 AC 判据的变更，不是权限变更）。
故 mandate 停在 `revision: 4`，而文档 `Revision: 6` —— 两者刻意不同步：
mandate revision 只跟踪**权限面**，文档 revision 跟踪全部修订。
（本行原写"文档 Revision: 5"，rev6 后未随文档头同步，Alex 于 L5 验收时更正。
这已是本单第二次出现同类元数据漂移——第一次由复核 2 的 P1-R2 抓到。）
⚠️ 元数据同步是必须的：lite 以 `revision` 为接受单位、`Execution Transactions` 以
`mandate_revision` 绑定授权 —— 若人在 `revision: 2` 上签字，签的是**没有探针授权**的那一版。
status: accepted | desired_outcome: 端到端验证 v2.41.0 的两条全新安装路径与两个升级变体真实可用，
产出可独立复核的证据与缺口声明；本单只诊断不修复。

authorized_consequence_classes:
- `network_read` —— 只读拉取 `raw.githubusercontent.com/Sheldon-92/TAD/main/*`、
  `github.com/Sheldon-92/TAD/archive/refs/heads/main.tar.gz`、`github.com/Sheldon-92/TAD.git`
  （`git ls-remote`）与 npm registry
- `local_read_external` —— 只读 `/Users/sheldonzhao/01-on progress programs/*/.tad/version.txt`
  （AC19 现场普查）与 `menu-snap` 的 TAD 表面（AC11 fixture 源）；**零写入**
- `local_write_scratch` —— 写入 `mktemp -d` 出的临时工作根及其全部子目录
- `local_write_evidence` —— 写入下列**六个**路径：
  (1) `.tad/evidence/acceptance-tests/install-smoke-v2410/`（含 `registry-baseline.yaml`）、
  (2) `.tad/evidence/journal/install-smoke-v2410-2026-08-11.md`、(3) 本契约文件本身、
  (4) 本单事务锁、(5) 归档目标 `.tad/archive/handoffs/LITE-20260811-1951-install-smoke-v2410.md`、
  (6) **围栏探针 `.tad/domains/SMOKE-FENCE-PROBE.txt`**（AC17 负控专用；
      创建后**必须在同一动作内删除**，收尾断言其不存在）。
  ⚠️ 第 (6) 项是 rev3 补的：rev2 的 binding 写死"不得写 `.tad/` 其它任何位置"，
  而 AC17 负控**必须**写它——AC 要求做的事被 mandate 禁止，执行者会在 AC17 停机问人。
- `external_cache_write` —— npx 写 `$HOME/.npm/_cacache`（标准 npm 缓存，唯一界外写入，AC18 申报）
- `local_commit` —— task-scoped append-only；仅提交本单产物 + 本契约与其归档移动。
  commit 数量是 agent 自主的技术基数，不是人的授权字段（对齐 Phase 3b 原则）。

target_scope:
- 临时工作根：`mktemp -d /private/tmp/tad-install-smoke.XXXXXX` 的返回值及其子树（A/B/U/U2/REF）
- 仓库内写入：仅 `local_write_evidence` 列明的路径
- 只读来源：`01-on progress programs/*/.tad/version.txt`、`menu-snap` 的 TAD 表面
- 远端：只读，无任何写入

consequence_bindings:
- `network_read` → 上列 URL 前缀 + npm registry；无认证、无凭据
- `local_read_external` → 上列两个只读来源；**任何写入即违约**
- `local_write_scratch` → 仅 `"$WORK"` 子树；`WORK` 必须由 `mktemp -d` 产生，不得硬编码
- `local_write_evidence` → 仅上列**六个**路径；**不得写 `.tad/` 其它任何位置**。
  第 (6) 项探针的生命周期限定在 AC17 负控内，收尾必须已不存在。
- `external_cache_write` → 仅 `$HOME/.npm/_cacache`
- `local_commit` → 仅本单产物与契约归档；不得 amend 历史 commit，不得触及远端

max_blast_radius: 一个临时目录树（可 `rm -rf` 全删）+ 仓库内一个新 evidence 目录 + 一个 journal
文件 + npm 缓存。**无远端影响、无身份/凭据、无对任何存活下游项目的写入。**

explicit_exclusions:
- **禁止在 `"$WORK"` 之外的任何路径执行 `bash tad.sh` 或 `npx github:Sheldon-92/TAD`
  —— 尤其禁止在 TAD 仓库根执行**（在仓库根跑一次安装会覆盖框架文件，是本单最大的自伤面）。
  AC12/AC12b 的 `pwd -P` 断言是该禁令的机制载体。
- 禁止写入任何存活下游项目（`menu-snap` 及其余全部）—— 只读 + `cp -R`，AC11 前后摘要比对为**事后
  探测器**（不是防护；真正的防护是 `cp -R` 的单向性 + BSD `cp -R` 不跟随符号链接 + fixture 的
  7 个符号链接全为相对链接）
- 禁止 `git push`、禁止创建/移动 tag、禁止任何远端写
- 禁止 sync 操作、禁止调用 `release-runbook` 的 publish/sync 流程
- 禁止修复本单发现的任何缺陷（含 README 文档漂移）—— 修复另起一单
- 禁止修改 `tad.sh`、`README.md`、`package.json`、`CLAUDE.md`、`bin/tad-install.mjs`、
  `.tad/hooks/`、`.claude/settings*.json`
- 禁止删除 `.tad/active/handoffs/LITE-20260811-1512-publish-v2410.md.txn-lock`
  （前一单的孤儿锁，不属本单范围）

recovery_policy: `partial` —— 任一路径失败时**保留 `"$WORK"` 全部现场供诊断（不得清理）**，
把失败点、退出码、完整输出落盘，其余 AC 继续跑完（诊断单的价值在覆盖面）。
⚠️ 这与"临时目录用完即删"的直觉相反，是刻意的。
仓库侧只新增文件，无需回滚；确需回滚则删除新增 evidence 目录即可。
**唯一硬停条件**：AC11 的源项目摘要前后不一致（污染了真实项目）→ 立即停止全部后续动作并上报。

expires_when: 本单人工验收通过并归档，或用户显式撤销。

acceptance: {decision: accepted, decided_at: 2026-08-11T21:08:58-0400, source: L3 contract decision}

## Execution Transactions

transactions:
- transaction_id: `install-smoke-v2410-t1`
  mandate_id: `install-smoke-v2410`
  mandate_revision: 4
  lock_path: `.tad/active/handoffs/LITE-20260811-1951-install-smoke-v2410.md.txn-lock`
  state_version: 0
  state: planned
  targets: `"$WORK"` 子树、`local_write_evidence` 列明的**六个**路径
  consequence_classes: [`network_read`, `local_read_external`, `local_write_scratch`,
    `local_write_evidence`, `external_cache_write`, `local_commit`]
  commit_shas: []
  actions:
  - {action_id: `preflight-baselines`, state: pending}        # AC1 + mkdir A/B/U/REF（⚠️ 不建 U2）+ scope-baseline + registry-baseline.yaml + brain-index sha + AC18 前值
  - {action_id: `verify-online-artifact`, state: pending}     # AC2
  - {action_id: `path-a-curl-install`, state: pending}        # AC3–AC6
  - {action_id: `path-b-npx-install`, state: pending}         # AC7–AC8 + AC18 后值
  - {action_id: `compare-a-vs-b`, state: pending}             # AC9
  - {action_id: `completeness-vs-release-tree`, state: pending} # AC10
  - {action_id: `content-equivalence`, state: pending}        # AC10b
  - {action_id: `build-upgrade-fixture`, state: pending}      # AC11（含源只读断言）
  - {action_id: `seed-customizations`, state: pending}        # AC15 前置植入 + AC14 基线 + 符号链接基线
  - {action_id: `clone-u2-before-upgrade`, state: pending}    # AC12b-pre ⚠️ 必须早于下一步
  - {action_id: `run-upgrade-local-tadsh`, state: pending}    # AC12
  - {action_id: `run-upgrade-curl`, state: pending}           # AC12b
  - {action_id: `verify-upgrade-outcome`, state: pending}     # AC13–AC15
  - {action_id: `scope-fence-and-controls`, state: pending}   # AC16–AC17(a)，内部顺序见下，不可乱
    # ⚠️ 内部四步顺序必须为：
    #   ① AC17 负控（建探针 → 跑围栏 → 断言被报出 → 删探针 → 断言 test ! -e）
    #   ② AC16 收尾围栏重算（此刻探针必须已不存在）
    #   ③ git add 全部 evidence
    #   ④ AC17 正控 (a)
    # AC16 的收尾重算不得在探针尚存时执行：探针刻意不在 AC16 排除清单内
    #（排除它会让负控的"被报出"断言不可证伪），此时跑 AC16 必然误 FAIL。
  - {action_id: `write-findings-and-journal`, state: pending} # AC19
  - {action_id: `independent-review`, state: pending}
  - {action_id: `commit-evidence`, state: pending}
  - {action_id: `post-archive-fence`, state: pending}         # AC17(b) 归档后正控

## L2.25 空跑记录（设计期在本机实测 + rev1 审查复核）

| 检查 | 实测结果 |
|---|---|
| AC1 三 SHA 同一 | 均 `9253bdd53a39651d89e6b77c124d961a84ea94f3`（含 `git ls-remote` 真远端）✅ |
| AC2 线上 tad.sh | `f7eac61bf52e708bb5606ea449666541dd08322115b85731ed586b37a57511ec`，与本地**逐字节相同** ✅ |
| AC2 线上 version | `2.41.0` ✅ |
| 执行 shell | `/bin/zsh`，`ZSH_VERSION=5.9`，`BASH_VERSION` 为空 |
| 超时二进制 | `timeout`/`gtimeout` **皆无** → perl alarm（超时退 142 / 正常退 0）✅ |
| AC10 参照树 | `git archive <sha> \| tar -x -C REF` 展开正常 ✅ |
| 摘要管线 | CJK 路径下正常 ✅ |
| AC6 前提 | `tad.sh:1865` 收尾清理 ✅ |
| **AC10 registry-only** | `tad.sh:791-794` 逐字确认；发布树该目录 316 文件，安装落地 1 个 ✅ |
| **AC5 tad.sh/bin** | `both.extra_root_files: ["AGENTS.md"]`，无自拷贝 ✅ |
| **AC14 README 覆盖** | `tad.sh:1620/1722/1800`；fixture 副本与 2.41.0 版 `diff` → **DIFFER** ✅ |
| **AC15 保护分支不可达** | fixture 合并锚点 **0**、pack-meta **0** ✅ |
| **AC16 REGISTRY 冲突** | `notebook-dormant-sync.sh` SessionStart 重写它，而它正是 9 个 dirty 之一 ✅ |
| **migration 断链** | `.tad/migrations/` 无 `2.30.0-to-*.yaml`（链止于 2.27.0，再起于 2.31.2）✅ |
| **rev3-a：`cp -R` 嵌套** | 预建 `U2` 后 `cp -R U U2` → `U2/U/marker.txt`，`U2/marker.txt` **不存在**（缺陷复现）；改用 `mkdir -p U2 && cp -R U/. U2/` → 内容平铺、`U2/U` 不存在、version 可读 ✅ |
| **rev3-b：AC12b 锚点 ANSI** | 源码为 `${GREEN}✓ Preserved:${NC} handoffs, …`。实测 `grep -c '✓ Preserved: handoffs'` → **0**；`grep -c 'handoffs, evidence, project-knowledge'` → **1**。**连写锚点必然误 FAIL**，故 rev3 只取无色码段 ✅ |
| **rev3-c：`grep -v` 退出码** | 全部过滤掉时 `grep -v` 退出 1 —— 而这正是"无差异"的成功路径；`\| grep -c . \|\| true` → `0` ✅ |
| **rev3-d：`.tad/` 顶层文件** | 发布树 21 个 blob，`TAD_TOP_DENY="sync-registry.yaml"` 仅排 1 个 → **20 个会被安装**，此前零内容覆盖（AC10b 第 5 组补上）✅ |
| **rev3-e：install 拷 README** | `tad.sh:1620` `cp -r …/project-knowledge/README.md` 带 `2>/dev/null \|\| true`，**失败静默** → 整棵豁免会吃掉真失败 ✅ |
| **rev3-f：无 `.gitattributes`** | 确认不存在 → `git archive` 的 `REF` 与 GitHub tarball 内容等价，AC10b/AC14 的比对对象成立 ✅ |
| **rev4-a：REGISTRY 形状正则（自写守卫，正反双控）** | 合法 `status: active→dormant` 翻转 → 不匹配行数 **0**（放行）；`last_queried` 被改 → 不匹配行数 **1**（拦下）。两个方向都验过 ✅ |
| **rev4-b：hook 写入面** | `recompute_notebook_dormancy` 唯一写操作 = `yq -i '(… \| .status) = env(STATUS)'`，值域 `{active,dormant}`；`last_queried` 仅第 28/41/43/47 行读取，从不写回；`dormancy` 字段名不存在 ✅ |
| **rev4-c：`version.txt` 字节** | 发布树 `od -c` = `2 . 4 1 . 0 \n`，恰 7 字节 → 安装器 `echo` 产出逐字节相同，第 5 组不必排除它 ✅ |
| **rev4-d：执行期锚点唯一性** | `grep -c 'Updating CLAUDE.md' tad.sh` == **1**（`tad.sh:1718`，upgrade 分支专属）✅ |
| **rev5-a：行级正则的盲区（证伪自己）** | `REGISTRY.yaml:127` = `    status: dormant # active / dormant / archived`，我的行级正则对它匹配 **0** 次 → 该条目翻转即误 FAIL。行级方案作废 ✅ |
| **rev5-b：`yq` round-trip** | `yq '.' REGISTRY.yaml` 与原文 diff = **0 行** → 规范化噪声不存在，"变化行数上界"的动机消失，删除 ✅ |
| **rev5-c：props 守卫三控** | 正控（合法 status 翻转）闭合外 **0** 行→放行；负控（写 `last_queried`）闭合外 **2** 行→拦下；负控2（带尾注释的 `notebooks.7` 翻转）闭合外 **0** 行→**不误 FAIL** ✅ |
| **rev5-d：fixture 锚点（2.30.0 版）** | `menu-snap/tad.sh` 四锚点**文本与 2.41.0 逐字相同**，行号为 1040/1208/707/1359 → AC12 同步安全，判定按文本不按行号 ✅ |

**AC1/AC2 在设计期已为绿。** Blake 重跑的意义是确认这两个值在执行时刻**没有变化**
（例如有人在此期间推了新 commit 到 main），不是重新发现。若 SHA 与上表不符 → 立即停下报告。

## Contract Review

### 首轮（2026-08-11，rev1）
Reviewer: 独立上下文 code-reviewer 子代理 | model=`claude-opus-5[1m]`
首轮 verdict: **FAIL**
P0=6, P1=7, P2=4; 已审 AC 条数: 20
关键发现: (1) AC5/AC8 要求 `tad.sh`、`bin/tad-install.mjs` 存在，而安装器从不安装二者 → 必然误报；
(2) AC10 未扣除 registry-only 与 deny-list 的合法移除 → (a)(b)(d) 三类必红；
(3) AC12b 的 U2 在 AC12 之后建，起始已是 2.41.0 → `tad.sh` 秒退 `Nothing to do` 报绿，
curl 升级路径完全空跑；(4) AC14 把 `.tad/project-knowledge/` 整棵冻结，而升级无条件覆盖其
README.md → 必然误报；(5) AC15 的两条保护分支在本 fixture 上均不可达（无合并锚点、无 pack-meta）
→ 两半必然 FAIL；(6) AC16 排除清单漏 `.tad/research-notebooks/REGISTRY.yaml`（SessionStart hook
写入且本身在 9 个 dirty 之列）、`.tad/evidence/decisions/**`、事务锁、归档目标 → 围栏在正确工作上必红。
**最高价值的单条**：整套 20 条 AC 无一比较"安装产物内容"与"发布产物内容"，
一个"文件全在、内容全错"的安装可以全绿 → 要求新增 AC10b。

### 增量复核 1（2026-08-11，rev1→rev2 diff）
Reviewer: 同一 reviewer | model=`claude-opus-5[1m]`
verdict: **CONDITIONAL** —— 6 个 P0 关闭 5 个，1 个（P0-3）以新形态复活；新增 4 个 P1。
关键发现:
- **P0-N1（阻塞）**：rev2 同时采纳 P1-7（preflight 预建 `U2`）与 P0-3（`cp -R U → U2`），
  两条各自正确的修法在 BSD `cp -R` 语义上撞车 → `U2/U/` 嵌套 → U2 无 `.tad/` →
  curl 变体退化为**全新安装**；全新安装不打印 `Nothing to do`，故 rev2 新加的硬禁抓不到，
  而 AC13 照样通过 → AC12b+AC13 双绿而 curl 升级路径未跑。**与 rev1 的 P0-3 后果相同，换了条路径到达。**
- **P1-N1**：AC10 把 `.tad/project-knowledge/` 整棵豁免，而 install 分支会单独拷其 `README.md`
  且失败静默 → 真盲区。
- **P1-N2**：`.tad/` 的 20 个顶层文件（含 `portable-extract.sh`）与 `.claude/settings.json`/`workflows/`
  在 AC5/AC10/AC10b 三者中**全部零覆盖**。
- **P1-N3**：AC16 对 `REGISTRY.yaml` 整条排除，使"本单误写它"这一 mandate 违约对围栏**永久失明**。
- **P1-N4**：AC17 负控要写 `.tad/domains/`，而 mandate binding 写死"不得写 `.tad/` 其它位置"
  且无 consequence class 授权 → 执行者会在 AC17 停机问人。
- 确认 rev2 修得对的两处：AC14"migration 跳过证据行不出现则冻结集须重新论证"、
  AC15"预判-实测一致性"——把隐含假设变成了可证伪的落盘项。
- 确认 AC14 的 `cmp -s U/README REF/README` **比对对象选对**（无 `.gitattributes`，`REF` ≡ tarball）。

### rev3 处置（本版）
P0-N1 / P1-N1 / P1-N2 / P1-N4 四项放行条件**全部采纳**；强烈建议项 P1-N3 **也采纳**
（REGISTRY.yaml 由整条排除收敛为限定形状排除 + `registry-baseline.yaml` 副本 +
`brain-index.md` 基线 sha）。P2 全部采纳（`grep -v` 退出码、AC19 引号、AC16 不硬编码计数、
`.claude/agents|commands|rules|settings.json.v2-backup` 进预期缺失、AC15 (p4) 判别力前提）。
**一处对审查建议的修正**：审查者建议 AC12b 断言 `✓ Preserved:` 一行，但源码为
`${GREEN}✓ Preserved:${NC} handoffs, …`，冒号与 `handoffs` 间夹 ANSI 重置码，连写锚点实测匹配 **0** 次。
rev3 改取无色码段 `handoffs, evidence, project-knowledge`（实测匹配 1 次，且能区分
upgrade / install / migrate 三分支）。
**rev3 的修订本身已空跑**（L2.25 表 rev3-a…rev3-f 六行），依据同一条知识：
`ac-verification.md` 2026-08-06「修补守卫的守卫不继承原件的空跑」。

### 增量复核 2（2026-08-11，rev2→rev3 diff）
Reviewer: 同一 reviewer | model=`claude-opus-5[1m]`
verdict: **CONDITIONAL** —— **无 P0 残留**；5 项条件全部正确关闭（P0-N1 的处置比建议更强：
加了针对该缺陷本身的 `test ! -e "$WORK/U2/U"` 专用探针，复发时立即可见）。2 个阻塞 P1 + 3 项建议。
关键发现:
- **P1-R1**：我按建议加的 REGISTRY「限定形状」白名单 `dormancy|dormant|last_queried|status`
  **比实现宽一大截**。读 `lib/notebook-lifecycle.sh` 的 `recompute_notebook_dormancy`：
  唯一写操作是 `yq -i '(… | .status) = env(STATUS)'`，值域 `{active, dormant}`；
  **`last_queried` 仅被读取、从不写回**，而它恰是 `*research` / notebook 操作会改的字段——
  即"非 hook 写入"最可能的形态。**守卫开在了它要防的那扇门上。** `dormancy` 字段名根本不存在。
- **P1-R2**：mandate 元数据未随实质变更同步（正文 Revision 3 / 六个路径，而
  `revision: 2` / `mandate_revision: 2` / "五个路径"）。探针授权是**权限面的实质扩大**，
  人在 `revision: 2` 上签字签的是没有该授权的那一版。
- 建议 3 项：AC12b 的 upgrade 证据应分"预告期/执行期"两层（预告块在 `AUTO_YES` 判断之前
  无条件执行，只证明 `ACTION` 被判定为 upgrade，不证明分支跑到了；反例：`PROBE_OK != 1` 时
  `tad.sh:1509` 强制 `ACTION=upgrade` → 预告照打 → `L1584-1590` 早退）；
  AC10b 第 5 组不应排除 `version.txt`（发布树 7 字节 `2.41.0\n`，安装器产出逐字节相同，
  排除它反而与 AC4 的 `head -1` 叠成"首行对、后面有垃圾"的洞）；
  `scope-fence-and-controls` 须钉死内部四步顺序（AC16 收尾若在探针尚存时跑必然误 FAIL）。
- 复核了我对 ANSI 锚点的修正：**(a)(b) 成立**（预告块在 `AUTO_YES` 之前无条件执行；
  `handoffs, evidence, project-knowledge` 全文唯一且能区分三分支），**(c) 有更强锚点**。

### rev4 处置（本版）
2 项阻塞 P1 + 3 项建议 + P2-R5（输出流）**全部采纳**：
REGISTRY 白名单收窄为 `^[<>][[:space:]]*status:[[:space:]]*(active|dormant)[[:space:]]*$`
+ 变化行数上界 + preflight 记录 `yq` 存在性（缺席则收紧为逐字节不变）；
mandate 元数据同步至 `revision: 4` / `mandate_revision: 4` / 「六个路径」+ 变更摘要；
AC12b 的 (b) 拆为预告期 + 执行期两条证据（后者 `→ Updating CLAUDE.md...`，`tad.sh:1718` 全文唯一），
并把同一要求同步进 AC12（此前 AC12 只查退出码，比 AC12b 弱）；
AC10b 第 5 组改为全部 20 个统一 `cmp`；`scope-fence-and-controls` 钉死四步顺序；
全程 `2>&1` 捕获且 AC14 的 migration 锚点钉死为 stdout 上的
`Migration skipped: manifest invalid or chain gap (exit 2)`。
**rev4 新增的那条正则是我自写的守卫，已做正反双控空跑**：合法 `status` 翻转 → 0 条不匹配（放行）；
`last_queried` 被改 → 1 条不匹配（拦下）。见 L2.25 表 rev4-a。

### 增量复核 3（2026-08-11，rev3→rev4 diff）
Reviewer: 同一 reviewer | model=`claude-opus-5[1m]`
verdict: **CONDITIONAL** —— rev4 的全部改动 CLOSED，**唯一放行条件**：REGISTRY carve-out 的判据
从「行级正则 + 变化行数上界」换成「`yq -o=props` 属性路径闭合 + 值域闭合」。
关键发现:
- **我自写的行级正则有真盲区**：`REGISTRY.yaml:127` 是
  `    status: dormant # active / dormant / archived`（**带行尾注释**），
  正则的 `(active|dormant)[[:space:]]*$` 对它匹配 **0** 次 → 该条目一旦翻转即误 FAIL。
  今日恰好不触发（其 age ≈ 100 天，desired == 当前值，无翻转）——**属运气不属设计**。
- **reviewer 收回了自己上一轮的建议**：「变化行数 == 2 × 翻转条数」不可执行 ——
  执行者拿不到基数（由运行时 `now - last_queried > threshold` 决定，要算就得重实现 hook 逻辑，
  那不是独立验证）。且其原始动机（兜住 `yq -i` 规范化噪声）**实测不成立**：
  `yq '.' REGISTRY.yaml` 与原文 diff = **0 行**。
- **实查了我最担心的一条**：fixture 的 2.30.0 版 `tad.sh` 四个锚点**文本与 2.41.0 逐字相同**
  （行号 1040/1208/707/1359）→ AC12 的同步安全，不会误 FAIL。
- **时机敏感性**：`notebooks.0` 的 age 对 2026-08-11 **恰为 30**，而 hook 条件是严格大于 30
  → 今日不翻转、次日翻转。该守卫是否被真正触发取决于执行日期，与 AC9 的 `installed_date`
  跨零点同类。已写进契约要求 preflight 落盘。
- 其余 rev4 改动（mandate 元数据同步、AC12b 双层锚点、AC10b 全 20 个统一 `cmp`、
  四步顺序、`2>&1`）逐条 CLOSED，未引入新缺陷。

### rev5 处置（本版，唯一改动）
按 reviewer 给定原文做**纯替换**：REGISTRY 判据改为 `yq -o=props` 的
(i) 路径闭合 `^notebooks\.[0-9]+\.status$` + (ii) 值域闭合 `{active, dormant}`；
删除不可执行的"变化行数上界"，代之以"变化路径数 > 5 时不自动 FAIL 但须逐条列出供人复核"；
"规范化风险"段改为实测排除；补时机敏感性落盘要求；行级 diff 降级为人读辅助（判定权归 props）。
另按 P2-S1 给 AC12 补 fixture 行号对照说明（判定按文本不按行号）。
**该替换本身已做三控空跑**（L2.25 rev5-c）：正控放行、负控拦下、且对行级正则会击穿的
带尾注释条目**不误 FAIL**。

### 最终 verdict
**PASS**（reviewer 在复核 3 中就该纯替换预先声明"改完无条件转 PASS，不需第五轮"；
替换已按其给定原文落实并三控空跑验证）。
P0=6(全部 fixed), P1=13(全部 fixed), P2=12(全部采纳); 已审 AC 条数: 21（AC1–AC19 + AC10b + AC12b-pre）

## 风险与注意

1. **网络依赖**：三条路径依赖 GitHub 与 npm registry。网络失败不是 GATE FAIL，
   记 `BLOCKED: network` 并保留现场，由人决定重跑时机。
2. **发现缺陷只能向前修**：远端 `main` 与 tag `v2.41.0` 均已发布，不可回退。唯一出路是发 2.41.1。
3. **fixture 保真度的已知上限**：`menu-snap` 副本是**真实安装**，保真度高于任何手工构造的 fixture；
   但它只是**一个** 2.30.0 项目，且恰好无合并锚点、无 pack-meta，导致两条保护分支不可达。
   AC19 强制把这个上限写明。
4. **孤儿锁未处理**：`.tad/active/handoffs/LITE-20260811-1512-publish-v2410.md.txn-lock` 仍在
   （owner pid 21373 已验证死亡，对应契约已归档）。本单 mandate **明确排除**处理它。
   建议由人直接 `rm` 掉，与本单无关。
5. **本单不覆盖单平台与 packs 子集**：Codex 单平台走 deny-delta 裁剪路径，与 `both` 差异最大，
   是下一个最值得补的缺口 —— 写进 findings 而非静默略过。
6. **rev1 的教训（写在这里，因为它会复发）**：rev1 的 6 个 P0 里有 4 个是同一个失败家族——
   **验证了机制存在，没验证机制在本 fixture / 本安装路径上可达**。
   `ac-verification.md` 2026-08-06 有一条专门写这个的条目，rev1 未引用。rev2 已引入。

## Lite Progress

Phase=admission
repair_round=0/3
same_error_count=0/2
verdict=RUNNING
Evidence=.tad/evidence/acceptance-tests/install-smoke-v2410/{AC01.txt,scope-baseline.txt,registry-baseline.yaml}
Next Action=AC2 verify-online-artifact
Phase=implement (BLOCKED at AC10b)
repair_round=0/3
same_error_count=0/2
verdict=RUNNING (AC10b 判据缺陷，非实现缺陷)
Evidence=.tad/evidence/acceptance-tests/install-smoke-v2410/AC10b.txt
Next Action=回 alex-lite 修订 AC10b 豁免清单（加 skills 根级 .md 类别）

### 增量复核 4（2026-08-11，rev5→rev6 diff，执行期判据缺陷修复回流）
Reviewer: 独立上下文 code-reviewer 子代理 | model=`deepseek-v4-flash`（opencode harness）
verdict: **PASS** — P0=0, P1=0, P2=1（建议性，不阻塞）
关键发现:
- 四处修订（Revision 行 / AC10 预期缺失补 skills 根级 md / AC10b 第 1 组豁免 doc-organization.md / AC19 缺口）
  与 Blake 执行期发现完全一致；修订后 AC10b 第 1 组命令实跑差异行数 == 0（原始 26 行 = 25×pack-meta + 1×doc-organization.md）。
- 反向探针 A（豁免词失效→差异现形）与反向探针 B（注入假 SKILL.md 差异→穿透双滤）均实证：
  豁免没有废掉检查，任一 SKILL.md 真缺陷仍会被抓。
- AC9（A vs B）与 AC10b 第 4 组（双写一致性）均不受影响（两侧都无该文件，实跑 0 行）。
- P2-1（建议）：`grep -v 'doc-organization\.md'` 未锚定行尾，理论上 `doc-organization.md.bak` 也会被豁免；
  全树 find 实测无此类文件，当前无实际误豁免面，不要求回改。
- 权限面确认：mandate 仍 revision 4（rev6 只补测量判据，无权限变化），与 L456-466 的 revision 同步规则一致。
Phase=implement (AC 全跑完，F1 发现已记录)
repair_round=0/3
same_error_count=0/2
verdict=RUNNING — AC12/AC13 FAIL = F1 缺陷（诊断单预期产出）；AC14/AC15 在 U2 补跑 PASS
Evidence=.tad/evidence/acceptance-tests/install-smoke-v2410/（AC01-AC19 全落盘 + findings.md 待写）
Next Action=独立审查（L3）

### 执行期审查记录（2026-08-11，L3 独立审查）
- 首轮：CONDITIONAL — P0=0/P1=2/P2=4（P1-1 findings.md 缺失、P1-2 AC17 正控未跑；均已处置）
- 增量复核：PASS — 盲区探针实证（篡改被抓/恢复 CLEAN），NEW-PATH 修正无盲区，两机制配对闭合
- Reviewer: opencode/deepseek-v4-flash（报告：.tad/evidence/reviews/blake/install-smoke-v2410/code-reviewer.md）
Phase=technical-gate
repair_round=0/3
same_error_count=0/2
verdict=GATE PASS — AC 21 条全有证据（AC12/AC13 FAIL=F1 发现，如实）；reviewer 终态 PASS（P0=0，CONDITIONAL 两条件已处置+增量复核通过）；friction 无 BLOCKED；scope 围栏 0 违规；KA=journal captured
Evidence=.tad/evidence/acceptance-tests/install-smoke-v2410/ + .tad/evidence/reviews/blake/install-smoke-v2410/code-reviewer.md
Next Action=L5 等待人工验收 → 归档 → AC17 正控 (b)
