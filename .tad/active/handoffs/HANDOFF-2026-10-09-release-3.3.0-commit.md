# HANDOFF: 3.3.0 发版提交的准备（Epic Phase 6b）

- Epic：`.tad/active/epics/EPIC-20261008-multi-harness-restore-and-cleanup.md`，Phase 6 第二部分
- 日期：2026-10-09。作者：Alex（Conductor）。修订：2（按设计审查 `phase6b-design-review.md` 的 9 个 P1 修订）
- 事实依据：`.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase6-grounding.md`（下称「调研」；§2 版本清单、§3 迁移清单、§4 CHANGELOG 素材、§6 分支与标签）与各阶段 gate 报告
- 前置：Phase 6a 已提交、台账已重新生成。基线提交由 Conductor 在派发消息里给出（`<BASE>`）。
- **本 handoff 的终点是「本地有一个可以发布的提交」。不推送、不打标签。** 仓库的发版规程（`publish-protocol.md` step4）要求人确认后才能发布。

## 1. 目的

把版本从 3.2.0 提到 3.3.0，并让这次提交能如实通过发版门：迁移清单、CHANGELOG、全部版本字样、安装器里三处文案小修、发版记录。做完后由 Conductor 提交、重新生成台账、逐个运行发版门并把原始输出落盘。

### 1.1 已裁定的事

| 事项 | 裁定 |
|---|---|
| 迁移清单内容 | 空清单（`delete: []`、`rename: []`）。本 Epic 没有删除或改名任何随安装分发的文件。**清单里不得出现 `.claude/`、`CLAUDE.md`、`.codex/hooks.json` 下的任何条目**：迁移引擎没有台账校验，写进去就可能删用户数据。对旧 `.claude/` 内容的接管由 `tad.sh` 完成，写进 CHANGELOG 的升级说明，不写进清单 |
| `version . 3.3.0 3.2.0` 这个门 | 版本提升后仍会因 `docs/pm/**` 里的历史记录退出 1。沿用 3.2.0 的先例：用一份覆盖 100% 命中的分诊记录放行，不改写历史记录，不碰 `docs/pm/status.md` |
| CHANGELOG 里缺的 3.0.1、3.0.2、3.1.0、3.2.0 四条 | 各补一条简短条目，取自各自**发版提交**的说明（来源见 F2），并注明「事后补记」。不展开 |
| 3.3.0 条目的日期 | 写 2026-10-09。实际推送日期若不同，由人在推送前只改这一行标题 |
| 真机回归的证据范围 | 四家 2026-10-09 的固定任务回归是在提交 `e6485404` 加当时工作区上做的（版本提升之前，安装器自报 3.2.0），形态是单个代理执行固定任务并自审，没有 Alex→Blake 派发；发版提交本身没有重跑。CHANGELOG 和发版记录都要写明 |
| `tad.sh` 的改动范围 | 只限 F5 列出的各处。不改任何逻辑（第 4 处会让颜色转义被正确解释，这是唯一的输出变化） |
| 下游项目版本扫描（`scan-downstream-versions.sh`） | 本次不运行（它会读这台机器上的其他项目）。在发版记录里写明未运行，留给人 |
| CHANGELOG 的措辞 | 与文档同一条线：不得出现「一等」「一流」「first-class」「first class」「hook-enabled」「四家均已验证」「verified on all four」「fully supported」；每家的证据与限制照 6a 定稿的台账和 `docs/MULTI-PLATFORM.md` 写 |

### 1.2 不可触碰

`.tad/provenance/**`（Conductor 提交后重新生成）、`.tad/templates/claude/**`、`bin/**`、`.tad/hooks/**`（F4 点名的 `state-surface-check.sh` 一行除外）、`.tad/tests/**`、`.tad/runtime-compat/**`、`.tad/migrations/` 下已有的文件、`docs/pm/**`、`.tad/active/**`、`.tad/decisions/**`、`.tad/archive/**`、人的三个未提交文件（两份 `secret-detection-rules.md`、`docs/pm/status.md`：不打开、不暂存、不还原）、仓库自己的 `.claude/` 目录。不 `git add`、不提交、不推送、不打标签、不切分支。不运行 `gen-claude-provenance.sh`。

## 2. 工作项

**F1. 迁移清单** 新建 `.tad/migrations/3.2.0-to-3.3.0.yaml`，格式照 `.tad/migrations/3.1.0-to-3.2.0.yaml`：`schema_version: 1`、`from: "3.2.0"`、`to: "3.3.0"`、`generated_by: "manual"`、`note: |`、`delete: []`、`rename: []`。`note` 用英文写三件事：本次发版恢复 Claude Code 安装目标并清理残余；没有随安装分发的文件被删除或改名，所以两个列表为空；对旧 `.claude/` 内容的接管由安装器完成（先存档、可还原、只替换能逐字节证明出自 TAD 的文件），不通过本清单。

**F2. CHANGELOG** 在 `CHANGELOG.md` 顶部（`## [3.0.0]` 之上）按该文件现有格式加：
- `## [3.3.0] - 2026-10-09`，分节 `### Added`、`### Changed`、`### Fixed`、`### Known limits`、`### Upgrade notes`。素材在调研 §4.2，但那是 5b、6a 完成之前写的：凡标着「未提交」「进行中」的条目，以当前仓库和以下文件为准重新核对——`phase4b-gate-report.md`、`phase4a-gate-report.md` 第五、六节、`phase4a2-gate-report.md` 第七节、`phase5b-completion-{A,B,C}.md`、`phase6a-completion-D.md`（以及 `-E.md`，若存在）、`docs/MULTI-PLATFORM.md` 状态表。
- 必须写到的内容：
  - 开头一段说明与 3.0.0 条目的关系：3.0.0 停止提供 Claude Code 安装目标；本次恢复为四个安装目标共用一棵 skill 树（`.agents/skills/`），Claude Code 通过 `.claude/skills/` 下的逐个链接读取。
  - Added：`--platform claude-code`；Claude Code 投影的各部分及各自的条件（skill 链接；只在**已有**的 `CLAUDE.md` 里维护 `@AGENTS.md` 引用块，不新建；hook 只在项目没有 `.claude/settings.json` 时注册，命令锚定到项目根；子代理定义只新建）；旧安装的接管（台账证明、存档后替换、`--claude-adopt=apply|plan|off`）；平台粘性及其关闭方式；十个 workflow 及其他三家的手动编排说明；`npm test`、路径引用检查、新增的发版门检查。
  - Changed：同版本的项目要加 Claude Code 投影需 `--force`（安装器会打印 `CLAUDE-HINT`）；弃用清理在 `--platform claude-code` 时跳过 `.claude/` 与 `.codex/hooks.json` 下的条目，其他平台下 `.claude/commands/*` 的删除须台账证明；文档改为描述四个安装目标；3.2.0 之后已在 main 上但未随版本发布的安装器改动（提交 `4b4f305a`：先读它的说明和 diff，只写其中用户可见的部分）。
  - Fixed：Codex 写后 hook 不留痕（原因、修法一句话）。验证条件照实写：绕过 hook 信任审查的一次性沙箱里的运行留下了 trace 行（修复后的专项复测两次：单文件补丁一行、双文件补丁两行，见 `phase4b/codex-d-retest.md`；固定任务回归的第二次运行一行），默认信任下的运行没有留下。hook 命令锚定；pack workflow 的默认包；其余用户可见的修复。
  - 在 Added 或 Known limits 里写一句真机回归的证据范围（§1.1 那一行的内容）。
  - Known limits：逐条照搬事实，不软化——Codex 的 hook 配置在完成信任审查前不生效，真实信任审查流程未测；Claude Code 已有且不同的 `settings.json` 时不注册 hook；从项目子目录启动的 Claude Code 会话不加载项目级 hook；交互式 Claude Code 会话未测；OpenCode 会话启动 hook 没有模型可见的效果；Codex 未接 PreCompact；各家自然压缩未测；任何平台的安装都会写 `.cursor/hooks.json` 与 `.opencode/plugins/tad-hooks.ts`；`tad-update.sh` 的 `--platform` 只接受 `codex` 与 `claude-code`；接管只在沙箱夹具上跑过，没有在真实下游项目上跑过；把 `.claude/` 纳入 git 的项目会看到一批删除和新增链接需自行提交；`SIGKILL` 之后的两种残留；台账的 `MANIFEST.sha1` 只防意外损坏；平台粘性的判定可被两个手工文件伪造，影响限于 skill 链接；旧 skill 很多的项目升级较慢（64 个约 72 秒）；同步工具对符号链接的处理未测；十个 workflow 里哪些没有带代理真跑过（照 `phase3-gate-report.md`）；路径引用检查器已知的漏检形态；测量所用的 CLI 版本；Claude Code 投影的下载（curl）安装路径没有被任何测试覆盖，全部测试用的是 `--source`；安装结束时的快速开始文案四个平台相同，没有提 Claude Code 的链接和 Codex 的信任审查；按名字调用 skill 的证据强度（Claude Code 强；Codex、Cursor 各一次运行；OpenCode 是模型自己读文件）；备份根位于同步目录时没有提示；两个同名且没有普通备份的项目共用一个存档组；Phase 2 的 hook 模板现在可被替换而确认前没有提示；确认前的提示可能在用户自写、实际会被保留的 `settings.json` 上出现。指针模式（`TAD_CLAUDE_SKILL_MODE=pointer`）：被用户改过的指针文件会被当作用户文件保留（照 `INSTALLATION_GUIDE.md` 现在的说法核对后写）。
  - Upgrade notes：迁移链从哪些已装版本可以解析到 3.3.0（3.2.0、3.1.0、3.0.2、3.0.1：设计审查用引擎的 dry-run 核对过），哪些会遇到缺口（3.0.0 与 2.44.x：迁移被跳过并给出警告，安装继续）。措辞用「迁移链可解析」，不要写「升级正常」：没有人为这次发版用 `tad.sh` 实际跑过这些升级。旧式 `.claude/` 安装的 Claude Code 用户怎么升级、怎么预览、怎么关闭；`settings.json`、`CLAUDE.md` 正文、用户自己的 hook／权限／MCP 逐字节保留；Codex 用户须完成 hook 信任审查；三种安装命令。安装命令逐条对照 `tad.sh --help`、`bin/tad-install.mjs` 的用法文本和 `tad-update.sh` 的用法文本核对后再写；`tad.sh` 里提到的 `npx tad-framework@latest` 是否可用无法核实，CHANGELOG 里不要写它，只写 `npx github:Sheldon-92/TAD`。curl 那条命令写成「可用的安装方式」，并在 Known limits 里已说明它未被测试覆盖。
- `## [3.2.0] - 2026-10-06`、`## [3.1.0] - 2026-10-06`、`## [3.0.2] - 2026-10-06`、`## [3.0.1] - 2026-10-05` 四条补记：每条一两行，末尾注明 `(entry added retrospectively in 3.3.0)`。内容取自发版提交的说明：3.0.1 取 `git log -1 --format=%B v3.0.1`；3.0.2 取 `git log -1 --format=%B e1fc91c1`（标签 v3.0.2 指向的是之后的一个文档提交，不要用它）；3.1.0 取 `9acf585d`；3.2.0 取 `bc4a8137`；另可引用 `.tad/migrations/3.0.1-to-3.0.2.yaml`、`3.0.2-to-3.1.0.yaml`、`3.1.0-to-3.2.0.yaml` 的 note。每条只写这些来源里有的事实。这四条正文里出现的 `3.2.0` 等字样会被 `version` 门记为命中，属预期，进分诊记录，不要为此改写。
- 每一条陈述你都要能指到依据（文件或提交）。完成报告里附一张「CHANGELOG 条目 → 依据」的表。写不出依据的不要写。

**F3. 版本字样** 调研 §2.1 的表是清单，逐行处理；动手前对每个文件重新 grep，行号可能已变。
- 改成 3.3.0 的：`.tad/version.txt`、`.tad/TAD-VERSION`、`.tad/config.yaml`（两处）、`package.json`、`README.md`（第 3 行、「Should show」一行、文末欢迎语）、`INSTALLATION_GUIDE.md`（第 3 行、「应显示」一行）、`.agents/skills/alex/SKILL.md`、`.agents/skills/blake/SKILL.md`、`.agents/skills/tad-help/SKILL.md` 三处版本标记、`PROJECT_CONTEXT.md`（两处）、`docs/MULTI-PLATFORM.md`（第 3 行与文末）、`AGENTS.md` 的 `Runtime status (v3.2.0)`、`docs/CODEX-USER-GUIDE.md`「应显示」一行、`.tad/capability-packs/pack-registry.yaml` 的 `synced_from_version`（只手改这一行，不运行 `scan-packs.sh`）、两个 handoff 模板各两处。`tad.sh` 的 `TARGET_VERSION` 见 F5。
- **不得改的**：`AGENTS.md` 里「step3f grading is HARD for all three from v3.2.0」（历史事实；`AGENTS.md` 只改 `Runtime status (v3.2.0)` 这一处）；`.tad/migrations/` 下已有文件；`CHANGELOG.md` 里你新补的 3.2.0 条目；`.tad/archive/**`、`.tad/active/**`、`.tad/decisions/**`；`docs/pm/**`。不要用全局替换；每处单独改。
- `NEXT.md` 第 10 行附近的状态行：不只改数字（「3.2.0（已发布版本）」只换数字就成了假话）。改为：`**当前版本**：3.3.0（发版提交已在本地准备好，等待人确认后推送并打标签）｜ **在途**：EPIC-20261008 恢复 Claude Code 支持，收尾阶段，未推送、未打标签`，其后的内容保留。`### 🔄 ACTIVE … (target v3.3.0)` 一节同样更新到这个状态，标题保持 `### 🔄 ACTIVE` 开头，不要标成已完成。
- `ROADMAP.md` 第 3 行的 `for v3.2.0` 改为 `for v3.3.0`。
- `INSTALLATION_GUIDE.md` 与 `.tad/agents/claude/spec-compliance-reviewer.md` 里原有的「自 v3.3.0 起」／「Since 3.3.0」字样此时成立，保留；在完成报告里列出它们的位置。
- README 文末欢迎语和 `docs/MULTI-PLATFORM.md` 文末签名行属于「版次签名」，按 `publish-ops.md` §3.1 是编辑性决定：本次裁定为随版本更新，在分诊记录里记一行。

**F4. `state-surface-check.sh` 的 `OLD_PAT`** 该文件 check4 用 `OLD_PAT` 抓「当前小版本的两段式写法」（写成 `Version 3.3` 而不是 `Version 3.3.0`），命中即失败；`publish-ops.md` §3.1 规定每次小版本提升要把它挪到新的小版本。现在停在 `3\.1`（3.2.0 发版时漏了这一步）。设计审查已从代码和历史确认只有一种读法：
- 第 129 行改为：`OLD_PAT='(Version|v)\*{0,2}:?\*{0,2} ?3\.3([^0-9.]|$)'`
- 同文件第 210、212 行两条消息里写死的 `'3.1'` 改为 `'3.3'`。
- 整个文件的改动应正好是这三行（diff 6 行）。
- 成对对照（用 `grep -qE` 对新模式执行，把结果写进完成报告）：`Version 3.3`、`**Version 3.3 — x`、`Version: v3.3)`、`v3.3` 应当命中；`Version 3.3.0`、`Version 3.3.0 — x`、`TAD v3.3.0` 应当不命中。
- 注意：五个状态文件（`AGENTS.md`、`README.md`、`INSTALLATION_GUIDE.md`、`docs/MULTI-PLATFORM.md`、`PROJECT_CONTEXT.md`）里若出现裸的 `v3.3` 或 `Version 3.3`，check4 会变红。改完版本字样后跑 `state-surface` 确认。

**F5. `tad.sh` 五处**（只这五处；改后 `/bin/bash -n tad.sh` 必须通过；行号为设计审查在 HEAD 上核对的位置，动手前重新 grep）
1. 第 26 行 `TARGET_VERSION="3.2.0"` → `"3.3.0"`。
2. 第 893 行的注释 `# v3.2 (Epic multi-harness-restore, Phase 2)` 改为 `# v3.3 (Epic multi-harness-restore, Phase 2)`。**第 896 行的 `# v3.2 (Epic P3): lifecycle hooks now land for both …` 是 3.2.0 那次发版的历史事实，不得改。**
3. 第 4061 行注释 `# tad-update.sh always calls the installer with --platform codex, so a project` 改为：`# tad-update.sh forwards an explicit --platform codex|claude-code; without it, detection yields codex (or stops as ambiguous), so a project`（后续行如需顺一下语句可以改，只限这段注释）。
4. 第 5956 行 `echo "Learn more: ${BLUE}${REPO_URL}${NC}"` 少了 `-e`，颜色转义被原样打印。改为 `echo -e "Learn more: ${BLUE}${REPO_URL}${NC}"`（与第 548、5433、5516、5954 行的写法一致）。
5. Claude Code 安装摘要里的两处非英文：第 3922 行以「`.claude/settings.json` 通常会被提交」开头的那行，改为 `.claude/settings.json is usually committed; it registers 4 scripts under .tad/hooks/ that run at session start, after file writes, before compaction and after questions.`（保持该行原有的输出方式和缩进）；第 3918 行句尾的括注 `(可手工并入；自动合并随后续版本提供)` 删除，英文部分已表达同样的意思。设计审查确认仓库里没有测试断言这两处原文。
- 不得新增、删除或移动任何 `rm`、`rmdir`、`mv` 语句。改完跑 `bash .tad/hooks/lib/release-verify.sh installer-destructive-guard .` 和 `bash tad.sh --verify-denylist`（只是自检，不安装任何东西），把结果写进报告。**不要以其他任何方式运行 `tad.sh`。**

**F6. 发版记录**（目录 `.tad/evidence/releases/`，被 git 忽略；照该目录里 3.2.0 的同名文件的格式）
- `3.3.0-version-triage.md`：版本字样和 CHANGELOG 都写完后运行 `bash .tad/hooks/lib/release-verify.sh version . 3.3.0 3.2.0`，把每一条剩余命中（输出里以 `STALE:` 标出的行）按「路径:行 / 命中文本 / 类别 / 依据」逐条列出，覆盖 100%，每条都写出 `路径:行`。预期的剩余命中有三类，都不要去「修」：`docs/pm/**` 里的历史记录与 PM 自有状态文件；`AGENTS.md` 里那句关于 3.2.0 的历史事实；`CHANGELOG.md` 正文里提到 3.2.0 的行（补记条目、升级说明）。出现这三类之外的命中，先判断是不是漏改的现行文件：是就改，不是就归类并写依据。另记一行版次签名的编辑决定（见 F3）。
- `3.3.0-step3f-registration.md`：登记四份 2026-10-09 的记录（`.tad/evidence/live-regression/{claude-code,codex,cursor,opencode}-20261009.md`）各自的结论。对每一份先做规程要求的检查并写下结果：六个字段齐全；执行日期 2026-10-09 不早于上次发版日期 2026-10-06；原始输出指针存在（`.tad/evidence/live-regression/raw/20261009/`）。写明安装源是提交 `e6485404` 加当时的工作区，其中包含人未提交的对 `.agents/skills/code-security/references/secret-detection-rules.md` 的修改；写明链的形态（单代理、自审）；写明 runtime 集合新增 claude-code 的日期与原因（step3f 要求在发版记录里注明）；写明 Codex 的保留事项（默认信任下写后留痕未出现；绕过信任的运行里出现）；写明这些运行是在 Codex 写后 hook 修复提交（`e6485404`）之后的树上做的，还是之前（看各记录里记的源提交）。不要写「全部通过」这类概括句，逐家列。
- 下游版本扫描未运行，写一行并说明原因（见 §1.1），并注明：这是规程里的阻断步骤，被跳过须由人在发版记录里确认豁免；Conductor 会在最终报告里向人提出。
- `3.3.0-closeout.md`：留出两节待 Conductor 填写——发版提交的 `git show --name-only` 输出（规程 step3e 第 1 项要求版本提升与 `NEXT.md`、`ROADMAP.md` 在同一提交）、各发版门的原始输出。你只建文件和标题。

**F7. 索引** 运行 `bash .tad/hooks/lib/brain-index-gen.sh`（它只重写工作区里被跟踪的 `.tad/brain-index.md`，不做任何 git 操作），然后 `bash .tad/hooks/lib/state-surface-check.sh --repo .`，确认 check7 显示索引年龄 0 天、没有 WARN，并确认输出文件是合法 UTF-8（`iconv -f UTF-8 -t UTF-8 .tad/brain-index.md >/dev/null`）。两条命令的结果写进完成报告。把这一步放在所有文字改动之后。

## 3. 验收标准

| # | 标准 | 验证 |
|---|---|---|
| AC1 | `version-sweep . 3.3.0` 退出 0；仓库里不再有该门清单内的 3.2.0 | 脚本 `F` |
| AC2 | `version . 3.3.0 3.2.0` 的全部剩余命中都在分诊记录里，且没有一条是现行文件漏改 | 脚本 `F` + Conductor 核对 |
| AC3 | 迁移清单存在、字段正确、两个列表为空、不含 `.claude`／`CLAUDE.md`／`.codex` 字样的条目 | 脚本 `F` |
| AC4 | `CHANGELOG.md` 有 3.3.0 条目和四条补记，含规定的五个分节，无禁用词，「Known limits」含 §2 F2 列出的要点 | 脚本 `F` + 实现审查逐条核对依据 |
| AC5 | `tad.sh`：语法通过；`installer-destructive-guard` 通过且标记数不变；`--verify-denylist` 通过；与基线相比的差异只落在 F5 的五处 | 脚本 `F` + 审查读 diff |
| AC6 | `state-surface` 通过，brain-index 年龄 0 天 | 脚本 `F` |
| AC7 | 不该改的没改：`AGENTS.md` 的 3.2.0 历史句、既有迁移清单、`docs/pm/**`、台账、模板里的 hook 配置 | 脚本 `F` |
| AC8 | 提交并重新生成台账之后：`structural`、`version-sweep . 3.3.0`、`migration . 3.3.0`、`installer-destructive-guard`、`provenance`、`state-surface`、`freshness` 全部退出 0；`npm test` 通过；安装器数据安全夹具的失败集合不比基线多 | 脚本 `FINAL`（Conductor） |

## 4. 验收脚本

Conductor 编写并运行。用法：`P6B_BASE=<BASE> /bin/bash <脚本> F|FINAL`，在仓库根目录运行。`FINAL` 在提交和台账重新生成之后、打标签之前运行。认为某条检查写错了，告诉 Conductor 是哪一行、为什么。

### §9.1-RAW

```bash
#!/bin/bash
# Phase 6b acceptance. Run from the repo root: P6B_BASE=<commit> /bin/bash <this> F|FINAL
set -u
REPO="$(pwd)"
BASE="${P6B_BASE:?set P6B_BASE}"
WORK="$(mktemp -d)" || exit 2
trap 'rm -rf "$WORK"' EXIT
FAILS=0
ok()  { printf '  ok   %s\n' "$1"; }
bad() { printf '  FAIL %s\n' "$1"; FAILS=$((FAILS + 1)); }
has() { grep -qF -- "$2" "$1" 2>/dev/null; }
hasE() { grep -qE -- "$2" "$1" 2>/dev/null; }
yes_() { if "$@"; then ok "$DESC"; else bad "$DESC"; fi; }
no_()  { if "$@"; then bad "$DESC"; else ok "$DESC"; fi; }
RV=.tad/hooks/lib/release-verify.sh
BANNED='一等|一流|first-class|first class|hook-enabled|四家均已验证|verified on all four|fully supported'
REL=.tad/evidence/releases

case_F() {
  echo "== F1 migration manifest"
  H=.tad/migrations/3.2.0-to-3.3.0.yaml
  DESC="hop manifest exists"; yes_ test -f $H
  DESC="from 3.2.0"; yes_ hasE $H '^from: "3\.2\.0"$'
  DESC="to 3.3.0"; yes_ hasE $H '^to: "3\.3\.0"$'
  DESC="delete list empty"; yes_ hasE $H '^delete: \[\]$'
  DESC="rename list empty"; yes_ hasE $H '^rename: \[\]$'
  DESC="no entry lines (- path / - from) in the manifest"; no_ hasE $H '^[[:space:]]*-[[:space:]]+(path|from|type):'
  DESC="no merge or verify section"; no_ hasE $H '^(merge|verify):'
  for o in 3.1.0-to-3.2.0 3.0.2-to-3.1.0; do DESC="existing manifest $o unchanged"; yes_ git diff --quiet "$BASE" -- .tad/migrations/$o.yaml; done

  echo "== F2 CHANGELOG"
  C=CHANGELOG.md
  DESC="3.3.0 entry present"; yes_ hasE $C '^## \[3\.3\.0\] - 2026-10-[0-9]{2}$'
  first=$(grep -n '^## \[' $C | head -1); case "$first" in *'[3.3.0]'*) ok "3.3.0 is the top entry";; *) bad "top entry is: $first";; esac
  for v in 3.2.0 3.1.0 3.0.2 3.0.1; do DESC="retrospective entry for $v"; yes_ hasE $C "^## \[${v//./\\.}\] - 2026-10-0[0-9]$"; done
  DESC="retrospective entries are marked as such (4)"; yes_ test "$(grep -c 'added retrospectively in 3.3.0' $C)" -ge 4
  ord=$(grep -n '^## \[' $C | head -6 | sed -E 's/.*\[([0-9.]+)\].*/\1/' | tr '\n' ' ')
  [ "$ord" = "3.3.0 3.2.0 3.1.0 3.0.2 3.0.1 3.0.0 " ] && ok "entries in descending order" || bad "entry order: $ord"
  awk '/^## \[3\.3\.0\]/{f=1;next} f&&/^## \[/{exit} f' $C > "$WORK/e.md"
  for h in 'Added' 'Changed' 'Fixed' 'Known limits' 'Upgrade notes'; do DESC="3.3.0 has section $h"; yes_ hasE "$WORK/e.md" "^### $h"; done
  DESC="3.3.0 entry has no banned support claim"; no_ grep -qiE -- "$BANNED" "$WORK/e.md"
  awk '/^### Known limits/{f=1;next} f&&/^### /{exit} f' "$WORK/e.md" > "$WORK/k.md"
  for kw in '[Tt]rust' 'settings\.json' 'subdirectory|sub-directory' '[Ii]nteractive' 'OpenCode' 'PreCompact' 'tad-update' 'SIGKILL' 'MANIFEST' 'symlink|symbolic link' 'sandbox' 'compaction' 'cursor/hooks\.json|\.cursor/hooks' '72' 'curl|download' 'quick-start|quick start' '[Pp]ointer' 'one run' 'sync'; do
    DESC="Known limits covers /$kw/"; yes_ hasE "$WORK/k.md" "$kw"
  done
  DESC="Known limits says the trust-review path was not exercised"; yes_ hasE "$WORK/k.md" 'bypass|not exercised|not been exercised|was not tested'
  DESC="Known limits has at least 20 bullets"; yes_ test "$(grep -cE '^[[:space:]]*- ' "$WORK/k.md")" -ge 20
  DESC="3.3.0 entry states the evidence scope (run before the bump, on e6485404)"; yes_ has "$WORK/e.md" 'e6485404'
  DESC="3.3.0 entry says the regression was a single-agent chain"; yes_ hasE "$WORK/e.md" 'single-agent|single agent'
  DESC="3.3.0 Changed mentions --force for same-version projects"; yes_ has "$WORK/e.md" -- '--force'
  DESC="Upgrade notes speak of the migration chain, not of tested upgrades"; yes_ hasE "$WORK/u.md" '[Mm]igration chain'
  DESC="3.0.2 retrospective entry is not sourced from the docs commit"; no_ hasE $C 'chain records' 
  awk '/^### Upgrade notes/{f=1;next} f&&/^### /{exit} f' "$WORK/e.md" > "$WORK/u.md"
  for kw in 'claude-adopt' 'plan' '3\.0\.0' '2\.44' 'npx github:Sheldon-92/TAD' 'trust'; do DESC="Upgrade notes covers /$kw/"; yes_ hasE "$WORK/u.md" "$kw"; done
  DESC="CHANGELOG does not advertise the unverified npm package name"; no_ has "$WORK/e.md" 'npx tad-framework'
  DESC="3.3.0 entry relates itself to 3.0.0"; yes_ hasE "$WORK/e.md" '3\.0\.0'
  DESC="existing 3.0.0 entry untouched"; yes_ test "$(git show "$BASE:$C" | awk '/^## \[3\.0\.0\]/{f=1} f' | cksum | cut -d' ' -f1)" = "$(awk '/^## \[3\.0\.0\]/{f=1} f' $C | cksum | cut -d' ' -f1)"

  echo "== F3 version tokens"
  /bin/bash $RV version-sweep . 3.3.0 > "$WORK/vs.log" 2>&1; rc=$?
  [ "$rc" = 0 ] && ok "version-sweep . 3.3.0 exit 0" || { bad "version-sweep . 3.3.0 exit $rc"; grep '❌' "$WORK/vs.log" | head -8; }
  DESC="version.txt is 3.3.0"; yes_ test "$(cat .tad/version.txt)" = "3.3.0"
  DESC="TAD-VERSION is 3.3.0"; yes_ test "$(cat .tad/TAD-VERSION)" = "3.3.0"
  DESC="tad.sh TARGET_VERSION 3.3.0"; yes_ hasE tad.sh '^TARGET_VERSION="3\.3\.0"'
  DESC="package.json 3.3.0"; yes_ has package.json '"version": "3.3.0"'
  DESC="AGENTS.md runtime status v3.3.0"; yes_ has AGENTS.md 'Runtime status (v3.3.0)'
  DESC="AGENTS.md keeps the 3.2.0 history sentence"; yes_ has AGENTS.md 'from v3.2.0'
  DESC="ROADMAP header v3.3.0"; yes_ hasE ROADMAP.md '^> .*for v3\.3\.0'
  nx=$(grep '当前版本' NEXT.md | head -1)
  nxv=$(printf '%s' "$nx" | sed -E 's/.*当前版本\*\*：([0-9.]+).*/\1/')
  [ "$nxv" = 3.3.0 ] && ok "NEXT.md current version is 3.3.0" || bad "NEXT.md current version reads: $nxv"
  case "$nx" in *已发布版本*) bad "NEXT.md calls 3.3.0 a published version";; *) ok "NEXT.md does not call 3.3.0 published";; esac
  case "$nx" in *未推送*) ok "NEXT.md status line says not pushed";; *) bad "NEXT.md status line does not say 未推送";; esac
  DESC="NEXT.md says push/tag await the human"; yes_ hasE NEXT.md '等待人确认'
  DESC="NEXT.md Epic section is still ACTIVE"; yes_ hasE NEXT.md '^### 🔄 ACTIVE .*EPIC-20261008'
  DESC="NEXT.md does not mark the Epic done"; no_ hasE NEXT.md '✅.*EPIC-20261008'
  /bin/bash $RV version . 3.3.0 3.2.0 > "$WORK/v.log" 2>&1; rc=$?
  grep 'STALE: ' "$WORK/v.log" | sed -E 's/^.*STALE: //' > "$WORK/v.hits"
  cut -d: -f1 "$WORK/v.hits" | sort -u > "$WORK/v.files"
  DESC="version gate parser is not vacuous (saw the AGENTS.md history hit)"; yes_ grep -q '^AGENTS\.md:' "$WORK/v.hits"
  live=$(grep -v -e '^docs/pm/' -e '^AGENTS\.md$' -e '^CHANGELOG\.md$' "$WORK/v.files" | tr '\n' ' ')
  [ -z "$live" ] && ok "version gate: remaining hits only in docs/pm, the AGENTS.md history line, CHANGELOG body (rc=$rc)" || bad "version gate: 3.2.0 remains in live file(s): $live"
  [ "$(grep -c '^AGENTS\.md:' "$WORK/v.hits")" = 1 ] && ok "AGENTS.md has exactly one remaining 3.2.0 line" || bad "AGENTS.md has $(grep -c '^AGENTS\.md:' "$WORK/v.hits") remaining 3.2.0 lines"
  if [ -f $REL/3.3.0-version-triage.md ]; then
    ok "version triage record exists"
    miss=0; while IFS= read -r h; do [ -n "$h" ] || continue; loc=$(printf '%s' "$h" | cut -d: -f1,2); grep -qF "$loc" $REL/3.3.0-version-triage.md || { miss=$((miss + 1)); [ "$miss" -le 3 ] && echo "       untriaged: $loc"; }; done < "$WORK/v.hits"
    [ "$miss" = 0 ] && ok "triage record lists every remaining hit by path:line ($(wc -l < "$WORK/v.hits" | tr -d ' ') hits)" || bad "$miss hits are missing from the triage record"
  else bad "version triage record missing"; fi
  n=$(git diff "$BASE" -- AGENTS.md | grep -cE '^[+-][^+-]')
  [ "$n" = 2 ] && ok "AGENTS.md: exactly one line changed" || bad "AGENTS.md: $n changed lines (want 2: one removed, one added)"
  DESC="INSTALLATION_GUIDE keeps its 'since v3.3.0' wording"; yes_ has INSTALLATION_GUIDE.md '自 v3.3.0 起'
  DESC="subagent definition keeps 'Since 3.3.0'"; yes_ has .tad/agents/claude/spec-compliance-reviewer.md 'Since 3.3.0'
  for f in $(git ls-files '.tad/migrations/*.yaml' | grep -v '3.2.0-to-3.3.0'); do git diff --quiet "$BASE" -- "$f" || bad "existing manifest changed: $f"; done; ok "existing manifests compared with base"
  for f in .tad/migrations/3.1.0-to-3.2.0.yaml; do DESC="history untouched: $f"; yes_ git diff --quiet "$BASE" -- "$f"; done
  DESC="docs/pm untouched by this work"; yes_ test -z "$(git diff --name-only "$BASE" -- docs/pm | grep -v '^docs/pm/status\.md$')"

  echo "== F4 OLD_PAT"
  SS=.tad/hooks/lib/state-surface-check.sh
  DESC="state-surface-check passes bash 3.2 syntax check"; yes_ /bin/bash -n $SS
  OP=$(sed -n "s/^OLD_PAT='\(.*\)'\$/\1/p" $SS)
  case "$OP" in *'3\.3('*) ok "OLD_PAT targets 3.3";; *) bad "OLD_PAT is: $OP";; esac
  for smp in 'Version 3.3' '**Version 3.3 — x' 'Version: v3.3)' 'v3.3'; do printf '%s\n' "$smp" | grep -qE -- "$OP" && ok "control: '$smp' is caught" || bad "control: '$smp' is not caught by OLD_PAT"; done
  for smp in 'Version 3.3.0' 'Version 3.3.0 — x' 'TAD v3.3.0'; do printf '%s\n' "$smp" | grep -qE -- "$OP" && bad "control: '$smp' is wrongly caught by OLD_PAT" || ok "control: '$smp' passes"; done
  DESC="check4 messages no longer say '3.1'"; no_ has $SS "'3.1' edition-number"
  n=$(git diff "$BASE" -- $SS | grep -cE '^[+-][^+-]')
  [ "$n" = 6 ] && ok "state-surface-check diff is exactly the three lines" || bad "state-surface-check diff is $n changed lines (want 6: three removed, three added)"

  echo "== F5 tad.sh"
  DESC="tad.sh passes bash 3.2 syntax check"; yes_ /bin/bash -n tad.sh
  /bin/bash $RV installer-destructive-guard . > "$WORK/dg.log" 2>&1; rc=$?
  [ "$rc" = 0 ] && ok "installer-destructive-guard PASS" || bad "installer-destructive-guard rc=$rc"
  m0=$(git show "$BASE:tad.sh" | grep -c 'RM-OK:'); m1=$(grep -c 'RM-OK:' tad.sh)
  [ "$m0" = "$m1" ] && ok "RM-OK marker count unchanged ($m1)" || bad "RM-OK markers $m0 -> $m1"
  for w in rm rmdir mv; do
    a=$(git show "$BASE:tad.sh" | grep -cE "(^|[^[:alnum:]_./-])$w[[:space:]]"); b=$(grep -cE "(^|[^[:alnum:]_./-])$w[[:space:]]" tad.sh)
    [ "$a" = "$b" ] && ok "count of lines with a $w command unchanged ($b)" || bad "lines with a $w command: $a -> $b"
  done
  bash tad.sh --verify-denylist > "$WORK/dl.log" 2>&1 && ok "verify-denylist" || bad "verify-denylist: $(tail -1 "$WORK/dl.log")"
  n=$(git diff "$BASE" -- tad.sh | grep -cE '^[+-][^+-]')
  [ "$n" -le 24 ] && ok "tad.sh diff is small ($n changed lines)" || bad "tad.sh diff is $n changed lines (F5 is five small edits)"
  DESC="tad.sh: Phase 2 comment says v3.3"; yes_ has tad.sh '# v3.3 (Epic multi-harness-restore, Phase 2)'
  DESC="tad.sh: keeps the 3.2.0 P3 history comment"; yes_ has tad.sh '# v3.2 (Epic P3): lifecycle hooks now land for both'
  DESC="tad.sh: Epic comments no longer say v3.2"; no_ hasE tad.sh '# v3\.2 \(Epic multi-harness-restore'
  DESC="tad.sh: stale tad-update comment gone"; no_ has tad.sh 'always calls the installer with --platform codex'
  DESC="tad.sh: no Chinese line about settings.json in the summary"; no_ has tad.sh '通常会被提交'
  DESC="tad.sh: no colour variable printed by a plain echo"; no_ hasE tad.sh '^[[:space:]]*echo "[^"]*\$\{(RED|GREEN|YELLOW|BLUE|CYAN|NC)\}'
  DESC="tad.sh: the GitHub link line uses echo -e"; yes_ has tad.sh 'echo -e "Learn more: ${BLUE}${REPO_URL}${NC}"'
  DESC="tad.sh: no CJK text left in the Claude summary lines"; no_ has tad.sh '可手工并入'

  echo "== F6-F7 records and index"
  DESC="step3f registration record exists"; yes_ test -f $REL/3.3.0-step3f-registration.md
  for r in claude-code codex cursor opencode; do DESC="registration names $r-20261009"; yes_ has $REL/3.3.0-step3f-registration.md "$r-20261009"; done
  DESC="registration records the Codex caveat"; yes_ hasE $REL/3.3.0-step3f-registration.md '[Tt]rust'
  DESC="registration records the downstream scan was not run"; yes_ hasE $REL/3.3.0-step3f-registration.md 'scan-downstream|下游'
  /bin/bash $RV state-surface . > "$WORK/ss.log" 2>&1 && ok "state-surface PASS" || { bad "state-surface: $(tail -1 "$WORK/ss.log")"; grep -E '^FAIL' "$WORK/ss.log" | head -4; }
  DESC="brain-index age is 0 days (check7)"; yes_ grep -qE 'check7.*age 0d' "$WORK/ss.log"
  DESC="brain-index is valid UTF-8"; yes_ iconv -f UTF-8 -t UTF-8 .tad/brain-index.md
  DESC="registration records the install source commit"; yes_ has $REL/3.3.0-step3f-registration.md 'e6485404'
  DESC="registration records the human's uncommitted file in the install source"; yes_ has $REL/3.3.0-step3f-registration.md 'secret-detection-rules'
  DESC="closeout record skeleton exists"; yes_ test -f $REL/3.3.0-closeout.md
  DESC="brain-index regenerated in this change"; no_ git diff --quiet "$BASE" -- .tad/brain-index.md

  echo "== scope"
  for p in .tad/provenance .tad/templates/claude bin .tad/tests .tad/runtime-compat; do
    ch=$( { git diff --name-only "$BASE" -- "$p"; git status --porcelain -- "$p" | cut -c4-; } | sort -u )
    [ -z "$ch" ] && ok "unchanged since base: $p" || bad "changed since base: $p ($(echo "$ch" | head -3 | tr '\n' ' '))"
  done
  ch=$( { git diff --name-only "$BASE" -- .tad/hooks; git status --porcelain -- .tad/hooks | cut -c4-; } | grep -v 'lib/state-surface-check\.sh$' | sort -u )
  [ -z "$ch" ] && ok "hooks: only state-surface-check.sh changed" || bad "hooks: unexpected changes ($ch)"
  ch=$( { git diff --name-only "$BASE" -- .agents/skills; git status --porcelain -- .agents/skills | cut -c4-; } | grep -v 'secret-detection-rules\.md$' | grep -v -e '^\.agents/skills/alex/SKILL\.md$' -e '^\.agents/skills/blake/SKILL\.md$' -e '^\.agents/skills/tad-help/SKILL\.md$' | sort -u )
  [ -z "$ch" ] && ok "skills: only the three version markers changed" || bad "skills: unexpected changes ($ch)"
  for f in alex blake tad-help; do
    n=$(git diff "$BASE" -- .agents/skills/$f/SKILL.md | grep -cE '^[+-][^+-]')
    [ "$n" = 2 ] && ok "$f/SKILL.md: exactly one line changed" || bad "$f/SKILL.md: $n changed lines (want 2: one removed, one added)"
  done
  git diff --cached --quiet && ok "nothing staged" || bad "something is staged"
  DESC="HEAD unchanged (no commit by the implementer)"; yes_ test "$(git rev-parse HEAD)" = "$(git rev-parse "$BASE")"
  allowed='^(\.tad/version\.txt|\.tad/TAD-VERSION|\.tad/config\.yaml|package\.json|README\.md|INSTALLATION_GUIDE\.md|PROJECT_CONTEXT\.md|AGENTS\.md|NEXT\.md|ROADMAP\.md|CHANGELOG\.md|tad\.sh|docs/MULTI-PLATFORM\.md|docs/CODEX-USER-GUIDE\.md|\.agents/skills/(alex|blake|tad-help)/SKILL\.md|\.tad/capability-packs/pack-registry\.yaml|\.tad/templates/(handoff-a-to-b|deliverable-handoff)\.md|\.tad/migrations/3\.2\.0-to-3\.3\.0\.yaml|\.tad/hooks/lib/state-surface-check\.sh|\.tad/brain-index\.md)$'
  extra=$( { git diff --name-only "$BASE"; git ls-files -o --exclude-standard; } | grep -vE "$allowed" | grep -v -e 'secret-detection-rules\.md$' -e '^docs/pm/status\.md$' -e '^\.claude/' | sort -u )
  [ -z "$extra" ] && ok "only in-scope files changed" || bad "out-of-scope changes: $(echo "$extra" | head -4 | tr '\n' ' ')"
  DESC="no file under .claude/ is tracked"; no_ test -n "$(git ls-files .claude | head -1)"
  DESC="completion report exists"; yes_ test -f .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase6b-completion.md
}

case_FINAL() {
  echo "== FINAL (after the release commit and ledger regeneration, before any tag)"
  [ -z "$(git tag --points-at HEAD)" ] && ok "HEAD is not tagged yet" || bad "HEAD already carries a tag: $(git tag --points-at HEAD | tr '\n' ' ')"
  DESC="no v3.3.0 tag exists"; no_ git rev-parse -q --verify refs/tags/v3.3.0
  for m in "structural $REPO $REPO" "version-sweep . 3.3.0" "migration . 3.3.0" "installer-destructive-guard ." "provenance ." "state-surface ." "freshness ."; do
    # shellcheck disable=SC2086
    /bin/bash $RV $m > "$WORK/f.log" 2>&1; rc=$?
    [ "$rc" = 0 ] && ok "release-verify $m" || { bad "release-verify $m rc=$rc: $(tail -1 "$WORK/f.log")"; }
  done
  relc=$(git log -1 --format=%H -- .tad/version.txt)
  git show --name-only --format= "$relc" | sort -u > "$WORK/rc.files"
  for f in .tad/version.txt NEXT.md ROADMAP.md CHANGELOG.md .tad/migrations/3.2.0-to-3.3.0.yaml tad.sh; do DESC="the commit that bumps version.txt also contains $f"; yes_ grep -qxF "$f" "$WORK/rc.files"; done
  okc=0; for n in $(awk '/^  - name:/{print $3}' .tad/capability-packs/pack-registry.yaml 2>/dev/null | tr -d '"') alex blake; do bash .tad/scripts/capability-skill.sh validate "$REPO" "$n" >/dev/null 2>&1 || { okc=$((okc + 1)); echo "       capability-skill validate failed: $n"; }; done
  [ "$okc" = 0 ] && ok "capability-skill validate: all registry packs plus alex and blake" || bad "capability-skill validate: $okc failures"
  [ -z "$(git status --porcelain | grep -v -e 'secret-detection-rules\.md$' -e ' docs/pm/status\.md$' -e '^?? \.claude/$')" ] && ok "tree is clean apart from the human's files" || bad "uncommitted changes: $(git status --porcelain | grep -v -e 'secret-detection-rules\.md$' -e ' docs/pm/status\.md$' -e '^?? \.claude/$' | head -4 | tr '\n' ';')"
  DESC="no file under .claude/ is tracked"; no_ test -n "$(git ls-files .claude | head -1)"
  ( npm test > "$WORK/npm.log" 2>&1 ); rc=$?
  [ "$rc" = 0 ] && [ "$(tail -1 "$WORK/npm.log")" = "RUN-ALL: PASS" ] && ok "npm test PASS" || { bad "npm test rc=$rc: $(tail -1 "$WORK/npm.log")"; }
  /bin/bash .tad/hooks/lib/skill-body-verify.sh > "$WORK/f.log" 2>&1 && ok "skill-body-verify" || bad "skill-body-verify: $(tail -1 "$WORK/f.log")"
  bash tad.sh --verify-denylist > "$WORK/f.log" 2>&1 && ok "verify-denylist" || bad "verify-denylist: $(tail -1 "$WORK/f.log")"
  /bin/bash .tad/hooks/lib/pack-registry-driftcheck.sh > "$WORK/f.log" 2>&1 && ok "pack-registry-driftcheck" || bad "pack-registry-driftcheck: $(tail -1 "$WORK/f.log")"
  [ "$(git merge-base HEAD main)" = "$(git rev-parse main)" ] && ok "main is an ancestor of HEAD (fast-forward possible)" || bad "main is not an ancestor of HEAD"
}

case "${1:-F}" in
  F) case_F ;; FINAL) case_FINAL ;;
  *) echo "usage: P6B_BASE=<commit> $0 F|FINAL" >&2; exit 2 ;;
esac
echo "== TOTAL FAILS: $FAILS"
[ "$FAILS" = 0 ]
```

## 5. 交付

- 完成报告：`.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase6b-completion.md`，含：CHANGELOG 条目 → 依据的对照表；逐文件的版本字样改动清单；F4 的两个对照样例及结果；F5 五处的前后文本；`version` 门剩余命中数；所有没有做的事和原因。
- 全部前台运行；卡住、矛盾、几分钟没有输出，就给 Conductor 发消息。

## 6. 风险

| 风险 | 缓解 |
|---|---|
| CHANGELOG 把限制写轻了，或写了没有证据的话 | 必写要点清单；禁用词；对照表；实现审查由文档审查员逐条核对 |
| 全局替换误改历史记录 | 明令逐处修改；脚本检查历史句和既有清单未变 |
| 迁移清单误删用户数据 | 只允许空清单；脚本检查没有任何条目行 |
| 改 `tad.sh` 引入行为变化 | 只限五处；脚本检查改动行数、标记数、`rm`／`mv` 行数；发版前 Conductor 重跑安装器夹具 |
| 提交后台账过期、标签后再提交让 `migration` 门失效 | Conductor 的顺序：提交 → 重新生成台账并提交 → `FINAL` → 停，不打标签 |
| 文档说的是 3.3.0 而对外仍是 3.2.0 | 本分支在发版提交完成前不推送；推送与打标签须同时进行，由人执行 |
