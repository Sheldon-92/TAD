# HANDOFF: 残余清理——代码、测试与例行扫描（Epic Phase 5b）

- Epic：`.tad/active/epics/EPIC-20261008-multi-harness-restore-and-cleanup.md`，Phase 5，第三批
- 日期：2026-10-09。作者：Alex（Conductor）。修订：2（按设计审查 `phase5b-design-review.md` 的 1 个 P0、12 个 P1 修订，并新增工作包 C）
- 事实依据：`.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase5-grounding.md` 的 A.1、A.4、A.5、A.7、D、E、F 各节（行号以当前工作区为准，动手前重新 grep）
- 基线提交：`9c2ad3bb`（5a 批 1 已提交）。本 handoff 派发时没有其他实现者在改仓库；三个工作包文件集互不相交。

## 1. 目标与边界

把 Phase 5 调研列出的代码类残余清掉：过期的测试断言、workflow 脚本里的四处小缺陷、空的 `npm test`、过期注释、停摆的例行扫描，并补上「悬空路径引用」的检查工具。做完后：

- `installer-data-safety-fixture.sh --case all` 不再带着 5 个已知失败；
- `npm test` 真的跑测试；
- 有一条命令能回答「被跟踪的文件里有没有指向不存在路径的引用」。

### 1.1 本 handoff 不做的事（已裁定）

| 事项 | 裁定 | 理由 |
|---|---|---|
| 修改 `tad.sh` | **禁止** | 本批不含安装器改动。若某个测试只有改 `tad.sh` 才能过，停下来报告，不要改 |
| 指针目录 `SKILL.md` 被刷新时覆盖用户对 `description:` 的改动 | 不修，写进文档 | 带 `tad_pointer: true` 标记的文件就是 TAD 生成物；指针模式是显式 opt-in |
| SIGKILL 后残留 `.tad-agent.*`、Phase 2 模板替换前无提示、台账去空白匹配、预检加删除前双重哈希的耗时、备份根在同步目录时无提示 | 不修，记入 CHANGELOG 的已知限制（Phase 6） | 均无数据丢失；改动都落在 `tad.sh` |
| `tad-update.sh` 的平台自动识别改成能认出 Claude Code 项目 | 不做，只改注释和报错文案 | 4a-2 安全审查的结论：可伪造的判定不能触发写 `settings.json`／`CLAUDE.md` |
| `save-skill`／`save-workflow` 写 `.claude/skills/local/`、Capability Builder 投影归属 | 不做 | 需要人做设计决定 |
| 版本号 | 保持 `3.2.0` | Phase 6 统一提升 |
| 依赖扫描 `deps-scan.sh` 的重跑 | Conductor 在验收当天联网执行 | 需要网络；结果文件不能手改 |

### 1.2 不可触碰

- `tad.sh`、`.tad/provenance/**`、`.tad/templates/**`、`.agents/skills/**`、`.tad/capability-packs/**`。
- 人的三个未提交文件：两份 `secret-detection-rules.md`、`docs/pm/status.md`。不打开、不改、不暂存、不还原。
- 仓库自己的 `.claude/` 目录：不读、不建、不改。
- 公开文档与状态面（5a 批 1 刚定稿）：`README.md`、`ROADMAP.md`、`AGENTS.md`、`PROJECT_CONTEXT.md`、`OBJECTIVES.md`、`NEXT.md`、`docs/**`（A13 新建的 `docs/legacy/tad-cli-v1.4.sh` 除外）、`.tad/active/**`、`.tad/brain-index.md`、`.tad/runtime-compat/**`。
- 不 `git add`、不提交、不推送、不切分支。Conductor 负责暂存和提交。

## 2. 工作包

三个工作包文件集不相交，可由三个实现者并行。A10 与 B6 有一处文案耦合，见各自条目。

### 工作包 A：workflow、测试入口、检查工具、注释

**A1. `pack-dogfood.workflow.js` 的错误声明统计**（调研 E.1-1）
现状：评审把「未发现明确错误」之类的说明写进 `wrong_claims`，评审失败时的占位 `['judge failed']` 也被计成错误声明。
要求：
- 评审 prompt 明确：没有错误声明时 `wrong_claims` 必须是 `[]`，不得放说明文字。
- 汇总时把评审失败单独计入返回对象的 `judge_failures`（数组，元素含包名），不计入 `packs_with_wrong_claims`。
- 汇总时丢弃 `wrong_claims` 里**整条（去首尾空白、转小写、去末尾标点后）等于**具名常量 `NO_FINDING_SENTINELS` 中某项的条目。常量至少含：`''`、`none`、`n/a`、`no wrong claims`、`no errors found`、`未发现明确错误`、`未发现错误`、`无`。不做前缀匹配，不判断「是否含具体断言」——前缀规则会吞掉「No rate limit exists; actual is 100/min」这种真的错误声明。
- 评审失败的行不进入 `rows`、`pack_wins`、`ties`、`control_wins`、`packs_with_wrong_claims`，只进 `judge_failures`；`total` 仍等于派发的包数，另加 `judged` 字段。（现状：失败占位同时带 `winner: 'tie'`，会被计进平局。）

**A2. 两个 workflow 的危险默认值**（E.1-2）
`pack-dogfood.workflow.js` 与 `pack-upgrade.workflow.js` 的 `DEFAULT_PACKS` 改成 `[]`。没有传 `packs` 时走已有的「no packs」错误返回，错误文案要说明必须显式传 `packs`（现有文案还在说「Edit DEFAULT_PACKS」，一并改掉）。同步改两个文件头部说明里「DEFAULT_* 作为兜底」的句子。`pack-upgrade` 会改写规范包，这是本条的安全意义。

**A3. `epic-audit.workflow.js` 的代理计数**（E.1-3）
`total_agents_spawned` 现在由综合代理自己填，是模型猜的。从 `SYNTHESIS_SCHEMA` 里去掉 `workflow_meta`，改为脚本计算：`(是否跑了探测代理 ? 1 : 0) + 派发的分析代理数（`epicPaths.length`）+ 派发的质疑代理数（`validAnalyses.length`）+ (是否跑了综合代理 ? 1 : 0)`，挂到返回对象上。按「派发数」算，不按「成功返回数」。综合代理失败返回 null 时，把计数挂到一个新对象上返回。空结果分支是 `(探测 ? 1 : 0)`，不得写死 `1`（路径由 `args` 传入时探测代理不跑）。`workflow_meta` 也要从 schema 的 `required` 里去掉。

**A4. `surplus-scan.workflow.js` 的描述**（E.1-4）
`meta.description` 现在说「写两个文件」，实际脚本不写任何文件。改为：返回渲染好的计划 markdown 和 JSON 及其目标路径，自身不写文件，由调用方落盘。

**A5. `package.json`**（E.2、F9）
- `keywords` 加 `claude-code`、`opencode`、`cursor`。
- `scripts.test` 改为 `bash .tad/tests/run-all.sh`。
- **不改 `engines`**（改已发布包的 engines 是发版决定）。在完成报告里写明新脚本实际需要的最低 Node 版本及依据，交 Phase 6 决定。

**A6. 新文件 `.tad/tests/run-all.sh`**
- 依次运行可离线、不写 `$HOME` 的测试，任一失败则以非零退出，最后一行打印 `RUN-ALL: PASS` 或 `RUN-ALL: FAIL (<名单>)`。
- 每个 shell 测试用 `/bin/bash` 调用（不是 `bash`：本机 PATH 上的 bash 是 5.x，而 hook 脚本的 shebang 是 `/bin/bash` 3.2）。每执行一个测试先打印一行 `RUN <名字>`。
- 纳入能通过的测试。设计审查实跑的现状：`detect-state-fixture.sh`（21 项通过）和 `yolo-harness-runner.test.mjs` 通过；`gate-exercise.sh` 失败（临时仓库里缺 hop manifest，报「exited 1 but for the wrong reason」）；`yolo-recovery.test.mjs`、`yolo-round.test.mjs` 失败（后者列着已不存在的 `.claude/skills/...` 路径）。这些 `.test.mjs` 不 import `node:test`，是普通脚本，用 `node <文件>` 跑即可。对三个失败的测试各给出原因归类（测试过期／真实缺陷），写进 `EXCLUDED` 行和完成报告；**不要为了凑数修它们**，除非修法只是把过期路径改对且你能说明原意。
- 必须纳入：`detect-state-fixture.sh`、`yolo-harness-runner.test.mjs`、`tad-install-fixture.sh`（A8）、`check-path-refs`（A9）、`hook-envelope-fixture.sh`（工作包 C 新增；它还不存在时先留一行按文件是否存在决定 RUN 或 EXCLUDED 的逻辑）。
- 每个被排除的测试打印一行 `EXCLUDED <名字>: <原因>`。`installer-data-safety-fixture.sh` 与 `tad-update-fixture.sh` 耗时长（前者约 5 分钟），默认排除，设 `TAD_TEST_FULL=1` 时纳入；纳入时必须把 `TAD_BACKUP_ROOT` 指到 `mktemp -d` 的目录，不得写 `$HOME/.tad-backups`。
- 兼容 `/bin/bash` 3.2。

**A7. `.tad/hooks/startup-health.sh` 的只读告警**（E.5，原 4a-2 的 FR7）
背景：Phase 1 实测，项目里的 `CLAUDE.md` 会让 Claude Code 不再加载 `AGENTS.md`。安装后用户新建一个 `CLAUDE.md`，TAD 的路由就悄悄失效。
要求：当 `AGENTS.md` 存在、`CLAUDE.md` 是普通文件（不是符号链接）且其中没有独占一行的 `@AGENTS.md` 时，在 SessionStart 的摘要末尾追加：` | CLAUDE.md has no @AGENTS.md line: Claude Code will not load AGENTS.md`。
- 只读，不改任何文件；退出码仍恒为 0；输出仍是合法 JSON。
- 判定用 `grep -Eq '^@AGENTS\.md[[:space:]]*$'`，与 `tad.sh` 里 `claude_adopt_notice_md` 的写法一致。
- 该 hook 在四家都会运行。这句告警只对 Claude Code 有意义，但脚本无法可靠判断自己跑在哪家，所以措辞点名 Claude Code，不做平台判断。

**A8. 新文件 `.tad/tests/tad-install-fixture.sh`**（E.5）
`bin/tad-install.mjs` 目前只有静态检查。写一个行为夹具：在 `mktemp -d` 里放一个假的 `tad.sh`（只把收到的参数写到文件），让 `tad-install.mjs` 调用它，断言：
- `--platform claude-code` 原样传到；`--platform codex`、`opencode`、`cursor` 同理；
- `--platform both` 被拒绝，退出码非零，stderr 含 `codex` 与 `claude-code`（现状只提示这两个，照现状断言）；
- `--platform claude-code,codex` 被拒绝，退出码非零，stderr 含四个合法取值；
- 不传 `--platform` 时的行为与 `bin/tad-install.mjs` 当前代码一致（先读代码，把实际行为写成断言）。
注入方式（设计审查已验证可行）：`tad-install.mjs` 用自身所在目录的上一级找 `tad.sh`。在 `mktemp -d` 里建 `bin/` 和 `.tad/`，拷入 `bin/tad-install.mjs` 与 `.tad/platform-codes.yaml`（`pack-registry.yaml` 只在传 `--packs` 时需要），旁边放假的 `tad.sh`，从这个副本运行。**不改仓库里的 `bin/tad-install.mjs`。**
不得联网，不得安装任何东西到真实目录。每类断言通过时打印一行 `ok <说明>`，最后一行 `TAD-INSTALL-FIXTURE: PASS` 或 `FAIL`。

**A9. 新文件 `.tad/scripts/check-path-refs.mjs` 与 `.tad/scripts/path-refs-allowlist.txt`**（A.1、A.4、A.5、A.7-1）
用途：扫描 `git ls-files` 列出的文本文件，抽取 `.tad/...` 与 `.claude/...` 形式的路径引用，报告指向仓库里不存在路径的引用。调研 A.1 有一份 Python 原型（报告第 22–66 行），把它的分类规则移植过来，只用 Node 内置模块。
- 用法：`node .tad/scripts/check-path-refs.mjs [--root <dir>] [--list]`。默认根是仓库根。退出码：0 = 没有未豁免的悬空引用；1 = 有，并逐条打印 `DANGLING <file>:<line> <ref>`；2 = 用法或环境错误。
- 存在性判定：引用路径等于某个被跟踪文件，或是某个被跟踪文件的目录前缀，即视为存在。用 `git ls-files`，不用文件系统的存在性测试（本仓库有未跟踪的 `.claude/` 和被忽略的本地文件，按文件系统判断的结果在干净克隆里不可重现）。只扫文本文件：按扩展名跳过图片、压缩包等二进制。
- 以下类别不算悬空，判定规则原样取自原型，写在脚本里并带注释：只存在于下游项目的安装目标路径（`.claude/skills/...` 等）、下游运行时才创建的目录（只限未跟踪／被忽略的那些：`evidence`、`logs`、`archive`、`reports` 等，照原型的清单；`.tad/context`、`.tad/working`、`.tad/pair-testing` 这类有被跟踪文件的目录**不**整体豁免）、含占位符的路径（`{name}`、`<x>`、`*`、`YYYY`）。
- 整文件跳过的清单（脚本顶部的具名常量），取原型的 `EXC` 加 `HIST`：`CHANGELOG.md`、`docs/archive/`、`docs/legacy/`、`docs/HISTORY.md`、`docs/MIGRATION-*`、`docs/releases/`、`docs/pm/`、`.tad/spike-v3/`、`scripts/archive/`、`tad-work/archive/`、`.agents/skills/_archived/`、`.tad/deprecation.yaml`、`.tad/migrations/`、`.tad/tests/`、`.tad/eval/`、`.tad/decisions/`、`.tad/memory/`、`.tad/CHANGELOG.md`、`.tad/manifest.yaml`、`experiments/`、`.tad/scripts/*.test.mjs`、`.tad/active/{handoffs,designs,requirements,epics}/`、`.tad/project-knowledge/{incidents,patterns}/`；再加检查工具自己的两个文件（`check-path-refs.mjs`、`path-refs-allowlist.txt`）。**不要自行加宽这份清单**；觉得需要加，写进完成报告由 Conductor 决定。设计审查用这份清单实跑，工作区剩 58 条引用，与调研 A.4／A.5 的手工清单吻合。
- 其余「悬空但正确」的引用进 `.tad/scripts/path-refs-allowlist.txt`，按 `(file, ref)` **精确相等**匹配，不做前缀或通配匹配：每行 `<file>\t<ref>\t<理由>`，`#` 开头为注释。以调研 A.4、A.5 的清单为起点。**允许清单里每一行都要有具体理由；不许用通配把整类问题盖掉。** 一条允许清单项如果不再匹配任何引用，脚本打印 `STALE-ALLOW` 警告（不影响退出码）。
- 目标：在最终工作区上退出 0。若剩下的悬空引用在本工作包无权修改的文件里（如 `NEXT.md`、`AGENTS.md`、`tad.sh`），属于「悬空但正确」的进允许清单并写理由；属于真悬空的**不要进允许清单**，列进完成报告，由 Conductor 处理（此时脚本退出 1 是正确结果）。根目录 `tad` 文件要搬走（A13），不要为它加允许清单项。
- 用法错误或不在 git 仓库里运行时退出 2。
- 在 `release-verify.sh` 里加一个 `path-refs` 模式，调用这个脚本并按既有模式的格式打印 `VERDICT:` 行；更新该脚本的 usage 文本。不把它接进任何聚合门（Phase 6 决定）。

**A10. `.tad/scripts/tad-update.sh`**（E.3）
- 第 116–122 行附近的注释改为如实描述：四家共用 `.agents/skills`，`detect_platform` 因此只凭 `.agents/skills/alex` 判断并只报告 `codex`；本脚本的 `--platform` 只接受 `codex` 与 `claude-code`（`tad.sh` 和 `tad-install.mjs` 接受四个，这是已知差异，写进注释）；用它升级 Claude Code 项目时，`tad.sh` 只保持已有的 skill 链接是最新的（平台粘性），要完整刷新 Claude Code 投影须显式传 `--platform claude-code`。删掉「automatic detection is a later release」。注释里**不写**「四个平台都是有效目标」。
- 第 76–82 行的 `--platform` 校验：接受集合保持 `codex|claude-code` 不变，**不加** `opencode`／`cursor`。只改 `both|*claude*` 分支的文案，固定为：`tad-update: --platform '<值>' is not a valid target. Valid for this updater: codex, claude-code`（工作包 B 的夹具会断言这句话，一字不差）。`*)` 分支的文案可同样统一。退出码不变（2）。
- **不改 `detect_platform` 的返回值。**
- `tad.sh` 第 4061 行附近有一句注释说「tad-update.sh always calls the installer with --platform codex」，已不准确；`tad.sh` 本批冻结，把它记进完成报告的「发现但没修」。

**A11. 注释与小文案**
- `.tad/hooks/lib/runtime-freshness-verify.sh:34-41`：注释和两条 INFO 文案说 Claude Code 路径「已移除」。实际逻辑是：台账缺失或含 `RETIRED|DEPRECATED` 才跳过，现在的台账两者都不是，所以是受门控的。把注释和文案改成描述这个逻辑，不改判断本身。
- `.tad/dependencies/REGISTRY.yaml:190-196`：`files_depending` 里的 `.claude/skills/`、`.claude/workflows/` 是下游安装目标，保留；补上 `.claude/agents/`（4a-2 新增的投影）。
- `.tad/guides/pack-collision-detection.md` 第 64 行附近：删掉「`*sync`-maintained source copy」（`*sync` 已退役）。两棵树内容已分叉（`.tad/capability-packs/<pack>/` 有 `CAPABILITY.md`、`install.sh`；`.agents/skills/<pack>/` 有 `SKILL.md`、`examples/`；同名 reference 文件内容也有差异）。改成：`.tad/capability-packs/` is the pack-authoring tree (CAPABILITY.md, install.sh, pack-registry.yaml); its reference files can differ from the runtime-loaded `.agents/skills/` tree. It is NOT the ref anchor. 不要写「规范源」或「投影」，除非你有 `git log` 证据并在报告里引用。

**A12. GitHub Registry 扫描：明确退役（可逆）**（D.2）
`.tad/github-registry/scan-log.yaml` 的 `last_scan` 改为 `null`，在它上方加注释：例行扫描于 2026-10-09 暂停，原值 `"2026-09-04"`，43 条待审候选保留在本文件，恢复方法是跑一次 `*research-github scan`。其余内容不动。注释里再加一句：恢复后的第一次扫描 previous `last_scan` 为 null，跳过 rejected 条目的清理（`research-github` SKILL 的清理规则没有覆盖 null）。设计审查已确认 Alex SKILL 的 STEP 3.9 以 `last_scan == null` 为静默条件，其他读取方也能处理 null。

**A13. 根目录的旧 `tad` 文件**（F4）
它是 v1.4 时代的 CLI，引用了早已删除的文件，`package.json` 的 `files` 不分发它。先确认没有**活跃**文件引用 `./tad`（已知的历史提及：`docs/legacy/**`、`docs/releases/v1.4-release.md`、`scripts/archive/upgrade-to-v1.2.sh`，不处理）；确认后把它移到 `docs/legacy/tad-cli-v1.4.sh`（用普通 `mv`，Conductor 负责 git 侧），并在文件第二行加一句注释说明它是历史文件、不再维护。若发现有上述之外的文件引用它，停下来报告。`docs/legacy/tad-cli-v1.4.sh` 是本批唯一允许在 `docs/**` 下新建的文件。

**A14. `INSTALLATION_GUIDE.md`**（调研 B 节点名给 4a-2 之后处理的行）
- 行号以实际为准，按标题定位（`### 升级到 v3.0.0`、`## 平台说明`）。
- 「升级到 v3.0.0」一节：在节标题下加一句 `> 本节记录 v3.0.0 当时的行为，属历史说明；Claude Code 现已重新是安装目标，见上方「接管」说明。` 不写版本号，不改写原有句子。本节里已有的「v3.3.0」字样留给 Phase 6 统一处理，在完成报告里列出位置。
- 「平台说明」表补到四行。每行只写三件事：安装目标 `--platform <x>`、skill 发现路径（Claude Code：`.claude/skills/` 下指向 `.agents/skills/` 的链接；其余三家：`.agents/skills/`）、hook 配置文件（Claude Code：`.claude/settings.json`，仅在该文件不存在时写入；Codex：`.codex/hooks.json`，需在 Codex 里完成 hook 信任审查后才生效，未接 PreCompact；Cursor：`.cursor/hooks.json`；OpenCode：`.opencode/plugins/tad-hooks.ts`）。不抄验证状态，表后写一句 `各平台验证状态见 docs/MULTI-PLATFORM.md 的状态表`。禁用词：「一等」「一流」「first-class」「first class」「hook-enabled」「四家均已验证」「verified on all four」。
- `/tad-update`（`tad-update.sh`）只接受 `codex` 与 `claude-code`；涉及它的句子不得暗示它能用于 `opencode`／`cursor`。
- 加一条说明：安装会把项目根的 `AGENTS.md` 换成 TAD 的版本，原文件先备份为 `AGENTS.md.pre-tad.<时间戳>`（设计审查核对的现状：`tad.sh` 第 1693 行附近，备份名 `AGENTS.md.pre-tad.<YYYYmmdd-HHMMSS>[.n]`，只在文件内容不同才备份；照实写）。这一句记录的是当前行为；它是否是人认可的长期契约尚未裁定，完成报告里注明。
- 指针模式一句：`TAD_CLAUDE_SKILL_MODE=pointer` 生成的 `SKILL.md` 带 `tad_pointer: true`，属于 TAD 生成物，每次安装会按源重新生成，不要手改。

### 工作包 B：安装器夹具的过期断言

文件：`.tad/tests/installer-data-safety-fixture.sh`、`.tad/tests/tad-update-fixture.sh`。其余文件只读。

整跑夹具和 `r1` 都会比较整棵树的 `git status`，所以整跑时不能有别的实现者正在改仓库。A、C 两个工作包会并行；因此 B 自己的中间运行按用例单跑（`--case <名字>`），最终的 `--case all` 由 Conductor 在 A、C 落地后执行。你自己整跑时若见到 `git status` 变化，先确认是不是别人的改动，再下结论。

先整跑一次 `bash .tad/tests/installer-data-safety-fixture.sh --case all`，确认失败的正好是 `ac2.6a`、`ac2.6b`、`ac2.8`（两条）、`r1`。不是这五条就停下来报告。

**B1. `ac2.6a`**（调研 E.4）：用例写于 Claude Code 平台不生成 hook 的年代，后来被机械地改成 `codex`，而只有 `codex` 平台会重新生成 `.codex/hooks.json`（`tad.sh` 第 1743 行附近），「必须不动」在 codex 下不可能成立。把该用例 2.2.0 那一半的 `run_install codex` 改为 `run_install opencode`，保持对三条弃用路径逐字节不变的断言。先用 `git log -L` 核对用例最初用的平台和意图，在用例注释里写明改了什么、为什么。若 opencode 的投影本身会动这三条路径中的任何一条，停下来报告，不要放宽断言。

**B2. `ac2.6b`**：根文件 `AGENTS.md` 的安装契约自 2026-08-17 起就是「先备份再覆盖」。改为断言：用户原来的 `AGENTS.md` 在备份文件里字节一致；`GEMINI.md` 与 `.codex/config.toml` 未被触碰。

**B3. `ac2.8`（b）外部工作目录回滚探针**：`rollback_on_failure` 自 `f9f397bc` 起要求备份位于 `TAD_BACKUP_ROOT` 下、目录名形如 `YYYYMMDD_HHMMSS`、含 `manifest.txt`。探针还在造旧式的 `.tad.backup.PROBE`。改为在沙箱的 `TAD_BACKUP_ROOT` 下造一个带 manifest 的备份，并把 harness 抽取的函数集合补齐到当前实现需要的那些。

**B4. `ac2.8`（a）回滚后漂移——先判别，再动手**：注入故障的运行结束后，执行
`find <target>/.tad/active <target>/.tad/archive <target>/.tad/evidence <target>/.tad/pair-testing <target>/.tad/reports -type f`
- 有文件：是迁移路径预期留下的内容，测试的过滤条件过期。把用例的前提改到升级形态的版本（如 3.1.0），并让过滤认得 `.tad-migrate-backup.*`（`rollback_on_failure` 明确把它列为「保留供手工恢复」）。
- 两种情况都要把用例的前提改到升级形态的版本（3.1.0）并让过滤认得 `.tad-migrate-backup.*`；改完之后若仍有漂移，才进入下面的判断。夹具结束时会清理沙箱，判别用的 `find` 要在清理之前执行（临时加一行，不要留在提交里）。
- 没有文件（只剩空目录）：这是安装器回滚清扫的缺陷。**不要改 `tad.sh`，不要改测试让它通过。** 把 find 的输出、目标目录的 `ls -laR .tad | head -80`、相关的 `tad.sh` 行号写进完成报告，交给 Conductor。该用例保持失败。

**B5. `r1`**：这是写死在 2026-09-03 那张 handoff 范围上的围栏，只要工作区有任何别的改动就失败。改成它能可靠回答的问题：夹具运行前后 `git status --porcelain` 的输出相同（夹具自己没有弄脏仓库）。

**B5b. `states` 用例的文案断言**：`tad-update-fixture.sh` 第 482 行附近断言 `--platform both` 的输出含 `was removed in TAD v3.0.0`。工作包 A（A10）会把这句改成 `tad-update: --platform '<值>' is not a valid target. Valid for this updater: codex, claude-code`。把断言改为匹配新文案（至少含 `is not a valid target` 与 `claude-code`），并更新第 449、475 行附近的过期注释。`states` 用例今天是通过的，改完必须仍然通过（在 A10 落地后验证；A 还没落地时先说明，由 Conductor 复跑）。

**B6. `tad-update-fixture.sh`**：逐个用例实跑（`backup`、`states`、`consent`、`download-safety`、`opencode-preservation`、`full-upgrade`、`release-gates`；`remote-release` 需要网络，跳过并注明）。4a-2 的实现者报告 `backup`、`consent`、`download-safety`、`opencode-preservation`、`full-upgrade`、`release-gates` 在当前工作区失败，原因未定。对每个失败用例给出归类：测试过期／环境依赖（脏工作区、写 `$HOME`、需要网络）／`tad-update.sh` 或 `tad.sh` 的真实缺陷，并附证据（失败输出、相关代码行、`git log` 里改变行为的提交）。
- 测试过期或环境依赖：修测试。环境依赖的要么在夹具里隔离掉（沙箱 `HOME`、沙箱 `TAD_BACKUP_ROOT`），要么在不满足前置条件时打印 `SKIP <原因>` 而不是 FAIL。
- 真实缺陷：不改产品代码，写进完成报告，该用例保持失败。
- 这一条先做两小时以内的调查。到点还没有归类清楚的用例，如实列出查到哪一步，不要猜。

所有夹具运行都必须把 `TAD_BACKUP_ROOT` 指到 `mktemp -d` 的目录；不得向 `$HOME/.tad-backups` 写入。动手前后各记一次 `ls $HOME/.tad-backups 2>/dev/null | wc -l`，数字必须相同。

### 工作包 C：Codex 的写后 hook 取不到文件路径

文件：`.tad/hooks/lib/hook-envelope.sh`、`.tad/hooks/post-write-sync.sh`、新文件 `.tad/tests/hook-envelope-fixture.sh`。其余只读。

背景（Phase 4b 真机回归发现，诊断见 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase4b-codex-postwrite-diagnosis.md`）：Codex 0.159.3 在 `apply_patch` 之后确实调用了 PostToolUse hook，但它发来的信封里 `tool_input` 只有 `command`（补丁正文），没有 `file_path`／`path`。`hook-envelope.sh` 因此得到空的 `HOOK_FILE_PATH`，`post-write-sync.sh` 在「路径为空」处打印 `{}` 退出。结果：Codex 上写 `.tad/evidence/` 下的文件不留 trace 行，而另外三家都留。实测到的信封（已脱敏）：

`{"hook_event_name":"PostToolUse","tool_name":"apply_patch","cwd":"<proj>","tool_input":{"command":"*** Begin Patch\n*** Add File: .tad/evidence/diag-note.md\n+diag\n*** End Patch"},"tool_response":"..."}`

**C1. 从补丁正文取路径。** 在 `hook-envelope.sh` 里：当工具名是 `apply_patch` 且按现有逻辑取到的路径为空时，从 `tool_input.command` 里取以 `*** Add File: `、`*** Update File: ` 开头的行，以及 `*** Move to: ` 行（改名后的新路径）。`*** Delete File:` 不取（文件已不存在，写后处理没有对象）。
- 路径相对于信封的 `cwd`；诊断确认 hook 的工作目录就是它，不需要加前缀。
- 补丁正文是模型写的，按不可信输入处理：只做文本提取，不 `eval`、不拼进命令；含控制字符的路径丢弃；绝对路径和含 `..` 段的路径丢弃（现有流程对这类路径怎么处理，先读 `post-write-sync.sh` 弄清，保持一致，不放宽）；最多取 20 条。
- 一个补丁可以改多个文件。`post-write-sync.sh` 现在处理单一路径。优先做法：让它对每条路径各走一遍现有处理。如果这样改动超出一个小循环（比如要重排脚本的主体），退一步：只处理第一条位于 `.tad/` 下的路径（没有则第一条），并在完成报告里写明这个限制。**不改其他三家的行为**：有 `file_path`／`path` 的信封必须和现在逐字节同样的结果。
- 兼容 `/bin/bash` 3.2；有 `jq` 和没有 `jq` 两条路径都要能工作（先看 `hook-envelope.sh` 现有的两条路径是怎么写的）。

**C2. 新夹具 `.tad/tests/hook-envelope-fixture.sh`。** 在 `mktemp -d` 的假项目里把信封喂给 `post-write-sync.sh`，断言 `.tad/evidence/traces/<当天>.jsonl`：
- Codex `apply_patch` Add File（上面的实测信封）→ 有一行 `evidence_created`，`file` 指向该文件；
- `Update File`、`Move to` 各一例；
- 多文件补丁（按你实现的是循环还是取第一条，写对应的断言）；
- 只有 `Delete File` 的补丁 → 没有新行，退出 0；
- 恶意路径（`../../x`、绝对路径、含换行）→ 没有新行，退出 0，项目目录外没有新文件；
- 其他三家不回归：Claude Code 的 `Write` 信封（`tool_input.file_path`）、Cursor 与 OpenCode 现在走的信封形态各一例（从 `.tad/hooks/lib/cursor-post-write.sh` 和 `.tad/templates` 或 OpenCode 插件源码里看它们实际传什么），断言与改动前相同的行；
- 写到非 TAD 路径（项目根下的普通文件）→ 没有新行（与现状一致）。
每条断言通过打印 `ok <说明>`，最后一行 `HOOK-ENVELOPE-FIXTURE: PASS` 或 `FAIL`。用 `/bin/bash` 运行被测脚本。

**C3. 不做的事。** 不改 `.codex/hooks.json` 的生成（在 `tad.sh` 里，本批冻结；匹配器 `^apply_patch$` 已证实能匹配）。不改台账和文档（Conductor 依据真跑结果另行处理）。`ask_user_question` 匹配器没有实测，不动。

## 3. 验收标准

| # | 标准 | 验证 |
|---|---|---|
| AC1 | 两个 workflow 默认不选任何包；`pack-dogfood` 把评审失败单列；`epic-audit` 的计数由脚本算；`surplus-scan` 描述如实 | §4 脚本 `A`；Conductor 另外不带参数真跑一次 `pack-dogfood` 与 `pack-upgrade`，期望返回 no-packs 错误且不派发任何代理 |
| AC2 | `npm test` 运行真实测试并以 0 退出，输出末行 `RUN-ALL: PASS`，被排除的测试逐条说明 | 脚本 `A` |
| AC3 | `startup-health.sh` 在三种 `CLAUDE.md` 状态下输出正确，恒退出 0，输出为合法 JSON | 脚本 `A` |
| AC4 | `tad-install-fixture.sh` 通过，且覆盖 §A8 的四类断言 | 脚本 `A` |
| AC5 | `check-path-refs.mjs` 在仓库上退出 0（批 1 文件里的悬空引用除外，须在完成报告列出）；在植入悬空引用的临时仓库上退出 1；允许清单每行有理由 | 脚本 `A` |
| AC6 | §A10–A14 的文案与文件变更到位 | 脚本 `A` |
| AC7 | `installer-data-safety-fixture.sh --case all`：`FAIL=0` 且 `PASS>=172`（基线 167 通过 + 5 失败，五条失败都应变成通过，不得靠删断言）；或只剩 B4 判定为安装器缺陷的 `ac2.8` 漂移那一条并附证据（此时 `PASS>=171`）。确需合并断言的，在完成报告里逐条说明 | 脚本 `B` |
| AC8 | `tad-update-fixture.sh` 每个离线用例：通过、`SKIP` 带原因、或失败并附「真实缺陷」的证据 | 完成报告 + Conductor 复跑 |
| AC10 | Codex 的 `apply_patch` 信封能产生 trace 行（工作包 C） | 脚本 `C`；Conductor 另在沙箱里用 Codex 真跑一次 |
| AC9 | 不可触碰的文件未变；`$HOME/.tad-backups` 条目数未变；版本号仍为 3.2.0；`state-surface`、`installer-destructive-guard`、`provenance`、`skill-body-verify` 仍通过 | 脚本 `GUARD` |

## 4. 验收脚本

Conductor 编写并运行。实现者可以复制到自己的 `mktemp -d` 目录里跑；认为某条检查写错了，不要绕过，告诉 Conductor 是哪一行、为什么。

用法：`P5B_BASE=9c2ad3bb /bin/bash <脚本> A|B|C|GUARD|ALL`（在仓库根目录运行）。`B` 与 `GUARD` 须在没有其他人改仓库时运行。

### §9.1-RAW

```bash
#!/bin/bash
# Phase 5b acceptance. Run from the repo root: P5B_BASE=<commit> /bin/bash <this> A|B|C|GUARD|ALL
set -u
REPO="$(pwd)"
BASE="${P5B_BASE:?set P5B_BASE}"
WORK="$(mktemp -d)" || exit 2
trap 'rm -rf "$WORK"' EXIT
FAILS=0
ok()  { printf '  ok   %s\n' "$1"; }
bad() { printf '  FAIL %s\n' "$1"; FAILS=$((FAILS + 1)); }
has() { grep -qF -- "$2" "$1" 2>/dev/null; }          # has <file> <fixed string>
hasE() { grep -qE -- "$2" "$1" 2>/dev/null; }         # hasE <file> <ERE>
yes_() { if "$@"; then ok "$DESC"; else bad "$DESC"; fi; }
no_()  { if "$@"; then bad "$DESC"; else ok "$DESC"; fi; }
WF=.tad/workflows/claude

case_A() {
  echo "== A1-A4 workflow scripts"
  DESC="pack-dogfood DEFAULT_PACKS is empty";   yes_ hasE $WF/pack-dogfood.workflow.js 'DEFAULT_PACKS[[:space:]]*=[[:space:]]*\[\]'
  DESC="pack-upgrade DEFAULT_PACKS is empty";   yes_ hasE $WF/pack-upgrade.workflow.js 'DEFAULT_PACKS[[:space:]]*=[[:space:]]*\[\]'
  DESC="pack-dogfood reports judge_failures";   yes_ has $WF/pack-dogfood.workflow.js 'judge_failures'
  DESC="pack-dogfood no longer stores the judge-failed marker as a wrong claim"; no_ hasE $WF/pack-dogfood.workflow.js "wrong_claims:[[:space:]]*\\[[[:space:]]*['\"]judge failed"
  DESC="pack-dogfood has the NO_FINDING_SENTINELS constant"; yes_ has $WF/pack-dogfood.workflow.js 'NO_FINDING_SENTINELS'
  DESC="pack-dogfood reports judged count"; yes_ hasE $WF/pack-dogfood.workflow.js 'judged[[:space:]]*[:,]'
  DESC="pack workflows no longer tell the user to edit DEFAULT_PACKS"; no_ grep -qi 'edit DEFAULT_PACKS' $WF/pack-dogfood.workflow.js $WF/pack-upgrade.workflow.js
  DESC="epic-audit schema has no workflow_meta"; no_ has $WF/epic-audit.workflow.js 'workflow_meta'
  DESC="epic-audit still returns total_agents_spawned"; yes_ has $WF/epic-audit.workflow.js 'total_agents_spawned'
  DESC="surplus-scan description no longer claims to write artifacts"; no_ hasE $WF/surplus-scan.workflow.js 'writes exactly two'
  DESC="surplus-scan description says the caller persists"; yes_ hasE $WF/surplus-scan.workflow.js '^[[:space:]]*description:.*(caller|writes nothing)'
  for f in pack-dogfood pack-upgrade epic-audit surplus-scan; do
    # meta must stay a pure literal at the top of the file
    DESC="$f still begins with export const meta"; yes_ hasE $WF/$f.workflow.js '^export const meta = \{'
  done

  echo "== A5-A6 npm test"
  DESC="package.json test script is run-all.sh"; yes_ has package.json '"test": "bash .tad/tests/run-all.sh"'
  for k in claude-code opencode cursor codex; do DESC="keyword $k"; yes_ has package.json "\"$k\""; done
  DESC="package.json version still 3.2.0"; yes_ has package.json '"version": "3.2.0"'
  DESC="run-all.sh passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/tests/run-all.sh
  n0=$(ls "$HOME/.tad-backups" 2>/dev/null | wc -l | tr -d ' ')
  ( npm test > "$WORK/npm.log" 2>&1 ); rc=$?
  [ "$rc" = 0 ] && ok "npm test exit 0" || bad "npm test exit $rc (see below)"
  [ "$(tail -1 "$WORK/npm.log")" = "RUN-ALL: PASS" ] && ok "last line RUN-ALL: PASS" || { bad "last line is: $(tail -1 "$WORK/npm.log")"; tail -15 "$WORK/npm.log"; }
  DESC="run-all executed at least 4 tests"; yes_ test "$(grep -c '^RUN ' "$WORK/npm.log")" -ge 4
  DESC="run-all invokes shell tests with /bin/bash"; yes_ has .tad/tests/run-all.sh '/bin/bash'
  DESC="run-all prints EXCLUDED lines with a reason"; yes_ hasE "$WORK/npm.log" '^EXCLUDED [^:]+: .+'
  DESC="installer fixture excluded by default"; yes_ hasE "$WORK/npm.log" '^EXCLUDED installer-data-safety-fixture'
  n1=$(ls "$HOME/.tad-backups" 2>/dev/null | wc -l | tr -d ' ')
  [ "$n0" = "$n1" ] && ok "npm test left \$HOME/.tad-backups alone ($n0)" || bad "\$HOME/.tad-backups entries $n0 -> $n1"

  echo "== A7 startup-health"
  sh_run() { # sh_run <dir>: prints additionalContext; exit code goes to $WORK/sh.rc (runs in a subshell)
    ( cd "$1" && printf '%s' '{"hook_event_name":"SessionStart","source":"startup"}' | /bin/bash "$REPO/.tad/hooks/startup-health.sh" ) > "$WORK/sh.json" 2>"$WORK/sh.err"; echo $? > "$WORK/sh.rc"
    node -e 'const j=JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"));process.stdout.write(j.hookSpecificOutput.additionalContext)' "$WORK/sh.json" 2>/dev/null || echo "__NOT_JSON__"
  }
  mk() { d="$WORK/$1"; mkdir -p "$d/.tad"; echo "# agents" > "$d/AGENTS.md"; echo "$d"; }
  d=$(mk s1); printf '# mine\n' > "$d/CLAUDE.md"; out=$(sh_run "$d")
  case "$out" in *"CLAUDE.md has no @AGENTS.md line"*) ok "warns: CLAUDE.md without @AGENTS.md";; *) bad "no warning; got: $out";; esac
  [ "$(cat "$WORK/sh.rc")" = 0 ] && ok "hook exit 0" || bad "hook exit $(cat "$WORK/sh.rc")"
  d=$(mk s2); printf '# mine\n@AGENTS.md\n' > "$d/CLAUDE.md"; out=$(sh_run "$d")
  case "$out" in *"CLAUDE.md"*|__NOT_JSON__) bad "unexpected for a CLAUDE.md with @AGENTS.md: $out";; *) ok "quiet: CLAUDE.md with @AGENTS.md";; esac
  d=$(mk s3); out=$(sh_run "$d")
  case "$out" in *"CLAUDE.md"*|__NOT_JSON__) bad "unexpected with no CLAUDE.md: $out";; *) ok "quiet: no CLAUDE.md";; esac
  d=$(mk s4); printf 'see @AGENTS.md inline\n' > "$d/CLAUDE.md"; out=$(sh_run "$d")
  case "$out" in *"CLAUDE.md has no @AGENTS.md line"*) ok "warns: mention that is not on its own line";; *) bad "inline mention treated as a reference: $out";; esac
  d=$(mk s5); rm "$d/AGENTS.md"; printf '# mine\n' > "$d/CLAUDE.md"; out=$(sh_run "$d")
  case "$out" in *"CLAUDE.md"*|__NOT_JSON__) bad "unexpected with no AGENTS.md: $out";; *) ok "quiet: no AGENTS.md";; esac
  d=$(mk s6); ln -s AGENTS.md "$d/CLAUDE.md"; out=$(sh_run "$d")   # the common CLAUDE.md -> AGENTS.md link
  case "$out" in *"CLAUDE.md"*|__NOT_JSON__) bad "unexpected for a symlinked CLAUDE.md: $out";; *) ok "quiet: CLAUDE.md is a symlink";; esac
  d=$(mk s7); printf '# mine\n' > "$d/CLAUDE.md"; cp "$d/CLAUDE.md" "$WORK/s7.before"; sh_run "$d" >/dev/null
  cmp -s "$d/CLAUDE.md" "$WORK/s7.before" && [ "$(ls -A "$d" | wc -l | tr -d ' ')" = 3 ] && ok "read-only: nothing written" || bad "hook changed the project directory"
  DESC="startup-health passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/hooks/startup-health.sh

  echo "== A8 tad-install fixture"
  if [ -f .tad/tests/tad-install-fixture.sh ]; then
    DESC="tad-install-fixture passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/tests/tad-install-fixture.sh
    ( /bin/bash .tad/tests/tad-install-fixture.sh > "$WORK/ti.log" 2>&1 ); rc=$?
    DESC="tad-install-fixture last line is PASS"; yes_ test "$(tail -1 "$WORK/ti.log")" = "TAD-INSTALL-FIXTURE: PASS"
    DESC="tad-install-fixture printed at least 6 ok lines"; yes_ test "$(grep -c '^ok ' "$WORK/ti.log")" -ge 6
    [ "$rc" = 0 ] && ok "tad-install-fixture exit 0" || { bad "tad-install-fixture exit $rc"; tail -10 "$WORK/ti.log"; }
    for t in claude-code opencode cursor both 'claude-code,codex'; do DESC="fixture mentions $t"; yes_ has .tad/tests/tad-install-fixture.sh "$t"; done
    DESC="bin/tad-install.mjs unchanged since base"; yes_ git diff --quiet "$BASE" -- bin/tad-install.mjs
  else bad "tad-install-fixture.sh missing"; fi

  echo "== A9 path reference checker"
  if [ -f .tad/scripts/check-path-refs.mjs ]; then
    node .tad/scripts/check-path-refs.mjs > "$WORK/pr.log" 2>&1; rc=$?
    [ "$rc" = 0 ] && ok "check-path-refs exit 0 on the repo" || { bad "check-path-refs exit $rc"; grep '^DANGLING' "$WORK/pr.log" | head -20; }
    T="$WORK/neg"; mkdir -p "$T/.tad/real"; ( cd "$T" && git init -q . && echo x > .tad/real/a.md \
       && printf 'see `.tad/real/a.md` and `.tad/gone/missing-file.md`\n' > doc.md && git add -A >/dev/null )
    node .tad/scripts/check-path-refs.mjs --root "$T" > "$WORK/neg.log" 2>&1; rc=$?
    [ "$rc" = 1 ] && ok "negative control: exit 1 on a planted dangling reference" || bad "negative control exit $rc (want 1)"
    DESC="negative control names the planted reference"; yes_ hasE "$WORK/neg.log" '^DANGLING doc\.md:1 .*\.tad/gone/missing-file\.md'
    DESC="negative control does not flag the existing path"; no_ hasE "$WORK/neg.log" '^DANGLING .*\.tad/real/a\.md'
    ( cd "$WORK" && node "$REPO/.tad/scripts/check-path-refs.mjs" --root "$WORK/not-a-repo" > "$WORK/neg2.log" 2>&1 ); rc=$?
    [ "$rc" = 2 ] && ok "exit 2 outside a git repository" || bad "outside a git repository: exit $rc (want 2)"
    if [ -f .tad/scripts/path-refs-allowlist.txt ]; then
      bare=$(grep -v '^#' .tad/scripts/path-refs-allowlist.txt | grep -v '^[[:space:]]*$' | awk -F'\t' 'NF < 3 || $3 ~ /^[[:space:]]*$/' | wc -l | tr -d ' ')
      [ "$bare" = 0 ] && ok "every allow-list row has a reason" || bad "$bare allow-list rows without a reason"
      wild=$(grep -v '^#' .tad/scripts/path-refs-allowlist.txt | awk -F'\t' '$1 ~ /\*/ || $2 == "*"' | wc -l | tr -d ' ')
      [ "$wild" = 0 ] && ok "no wildcard allow-list rows" || bad "$wild wildcard allow-list rows"
    else bad "allow-list file missing"; fi
    DESC="release-verify passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/hooks/lib/release-verify.sh
    /bin/bash .tad/hooks/lib/release-verify.sh path-refs . > "$WORK/rv.log" 2>&1; rc=$?
    [ "$rc" = 0 ] && hasE "$WORK/rv.log" '^VERDICT:.*PASS' && ok "release-verify path-refs PASS" || bad "release-verify path-refs rc=$rc: $(tail -1 "$WORK/rv.log")"
  else bad "check-path-refs.mjs missing"; fi

  echo "== A10-A14 text and file changes"
  U=.tad/scripts/tad-update.sh
  DESC="tad-update: no 'later release'";            no_ has $U 'later release'
  DESC="tad-update: no 'codex is the only target'"; no_ has $U 'codex is the only target'
  DESC="tad-update: no 'was removed in TAD v3.0.0'"; no_ has $U 'was removed in TAD v3.0.0'
  DESC="tad-update: comment names stickiness";      yes_ hasE $U '[Ss]tick'
  DESC="tad-update: bash 3.2 syntax";               yes_ /bin/bash -n $U
  d0=$(git show "$BASE:$U" | awk '/^detect_platform\(\)/,/^}/' | cksum); d1=$(awk '/^detect_platform\(\)/,/^}/' $U | cksum)
  [ "$d0" = "$d1" ] && ok "detect_platform body unchanged" || bad "detect_platform body changed"
  ( PROJECT_ROOT="$WORK" /bin/bash $U --platform both > "$WORK/u.log" 2>&1 ); rc=$?
  [ "$rc" = 2 ] && ok "tad-update --platform both rejected (rc=2)" || bad "tad-update --platform both rc=$rc (want 2)"
  DESC="rejection uses the agreed message"; yes_ has "$WORK/u.log" "is not a valid target. Valid for this updater: codex, claude-code"
  ( PROJECT_ROOT="$WORK" /bin/bash $U --platform cursor > "$WORK/u2.log" 2>&1 ); rc=$?
  [ "$rc" = 2 ] && ok "tad-update --platform cursor still rejected (not widened)" || bad "tad-update --platform cursor rc=$rc (behaviour widened?)"
  DESC="tad-update comment does not claim four valid targets for this script"; no_ hasE $U '四个平台都是有效目标|all four (platforms )?are valid targets'
  F=.tad/hooks/lib/runtime-freshness-verify.sh
  DESC="freshness: no 'v3.0.0 removal' message";    no_ has $F 'v3.0.0 removal'
  DESC="freshness: no 'runtime path was removed'";  no_ has $F 'runtime path was removed'
  DESC="freshness: bash 3.2 syntax";                yes_ /bin/bash -n $F
  c0=$(git show "$BASE:$F" | grep -vE '^[[:space:]]*#' | grep -v 'echo "INFO' | cksum); c1=$(grep -vE '^[[:space:]]*#' $F | grep -v 'echo "INFO' | cksum)
  [ "$c0" = "$c1" ] && ok "freshness logic unchanged outside comments and INFO text" || bad "freshness logic changed"
  DESC="REGISTRY lists .claude/agents/";            yes_ has .tad/dependencies/REGISTRY.yaml '.claude/agents/'
  DESC="pack-collision guide no longer says *sync-maintained"; no_ has .tad/guides/pack-collision-detection.md 'sync`-maintained'
  S=.tad/github-registry/scan-log.yaml
  DESC="scan-log last_scan is null";                yes_ hasE $S '^last_scan:[[:space:]]*null'
  DESC="scan-log comment keeps the old date";       yes_ hasE $S '^[[:space:]]*#.*2026-09-04'
  p0=$(git show "$BASE:$S" | grep -c 'status: pending'); p1=$(grep -c 'status: pending' $S)
  [ "$p0" = "$p1" ] && ok "scan-log pending candidates kept ($p1)" || bad "scan-log pending $p0 -> $p1"
  [ ! -e tad ] && ok "root tad file is gone" || bad "root tad file still present"
  [ -f docs/legacy/tad-cli-v1.4.sh ] && ok "legacy CLI kept under docs/legacy" || bad "docs/legacy/tad-cli-v1.4.sh missing"
  G=INSTALLATION_GUIDE.md
  DESC="guide: AGENTS.md backup named";             yes_ has $G 'AGENTS.md.pre-tad.'
  DESC="guide: pointer files are generated";        yes_ has $G 'tad_pointer: true'
  for h in 'Claude Code' 'Codex' 'Cursor' 'OpenCode'; do
    n=$(awk '/^## 平台说明/{f=1;next} f&&/^## /{f=0} f' $G | grep -c "^| *\**$h")
    [ "$n" -ge 1 ] && ok "guide: platform table has a row for $h" || bad "guide: platform table has no row for $h"
  done
  DESC="guide: no banned support claims";           no_ hasE $G '一等|一流|first-class|first class|hook-enabled|四家均已验证|verified on all four'
  awk '/^### 升级到 v3\.0\.0/{f=1;n=0;next} f{n++; if(n<=4) print}' $G | grep -q '历史' && ok "guide: v3.0.0 section marked historical right under its heading" || bad "guide: v3.0.0 section has no historical note under its heading"
  DESC="guide: Codex hook trust review mentioned";  yes_ hasE $G '信任'
  DESC="completion report A exists"; yes_ test -f .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase5b-completion-A.md
}

case_B() {
  echo "== B installer data-safety fixture (about 5 minutes)"
  n0=$(ls "$HOME/.tad-backups" 2>/dev/null | wc -l | tr -d ' ')
  s0=$(git status --porcelain | cksum)
  TAD_BACKUP_ROOT="$WORK/bk" /bin/bash .tad/tests/installer-data-safety-fixture.sh --case all > "$WORK/fx.log" 2>&1
  tail -1 "$WORK/fx.log"; grep -E '^=== Summary' "$WORK/fx.log"
  f=$(grep -c '❌' "$WORK/fx.log")
  if [ "$f" = 0 ]; then ok "fixture: no failing case"
  else
    other=$(grep '❌' "$WORK/fx.log" | grep -vc 'ac2\.8: post-rollback drift')
    [ "$other" = 0 ] && echo "  NOTE only ac2.8 post-rollback drift fails: acceptable ONLY with B4 evidence of an installer defect" || bad "fixture failing cases: $(grep '❌' "$WORK/fx.log" | tr '\n' ';')"
  fi
  # baseline was PASS=167 FAIL=5: each of the five must turn into a pass, not disappear
  floor=172; [ "$f" = 0 ] || floor=171
  p=$(grep -E '^=== Summary' "$WORK/fx.log" | sed -E 's/.*PASS=([0-9]+).*/\1/')
  [ "${p:-0}" -ge "$floor" ] && ok "fixture PASS count $p >= $floor (baseline PASS 167 + FAIL 5)" || bad "fixture PASS count ${p:-?} < $floor: assertions were removed"
  ( TAD_BACKUP_ROOT="$WORK/bk2" /bin/bash .tad/tests/tad-update-fixture.sh --case states > "$WORK/st.log" 2>&1 ); rc=$?
  [ "$rc" = 0 ] && ok "tad-update-fixture --case states exit 0" || { bad "tad-update-fixture --case states exit $rc"; tail -8 "$WORK/st.log"; }
  DESC="tad-update-fixture asserts the new rejection message"; yes_ has .tad/tests/tad-update-fixture.sh 'is not a valid target'
  DESC="tad-update-fixture no longer asserts the removed message"; no_ has .tad/tests/tad-update-fixture.sh 'was removed in TAD v3.0.0'
  DESC="completion report B exists"; yes_ test -f .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase5b-completion-B.md
  n1=$(ls "$HOME/.tad-backups" 2>/dev/null | wc -l | tr -d ' ')
  [ "$n0" = "$n1" ] && ok "\$HOME/.tad-backups untouched ($n0)" || bad "\$HOME/.tad-backups entries $n0 -> $n1"
  [ "$s0" = "$(git status --porcelain | cksum)" ] && ok "fixture left git status unchanged" || bad "fixture changed git status"
  DESC="fixture passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/tests/installer-data-safety-fixture.sh
  DESC="tad-update-fixture passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/tests/tad-update-fixture.sh
}

case_C() {
  echo "== C Codex apply_patch envelope"
  H="$REPO/.tad/hooks/post-write-sync.sh"
  DESC="hook-envelope.sh passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/hooks/lib/hook-envelope.sh
  DESC="post-write-sync.sh passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/hooks/post-write-sync.sh
  feed() { # feed <dir> <json>: run the hook in <dir>, exit code to $WORK/c.rc
    ( cd "$1" && printf '%s' "$2" | /bin/bash "$H" > "$WORK/c.out" 2>"$WORK/c.err" ); echo $? > "$WORK/c.rc"
  }
  rows() { cat "$1"/.tad/evidence/traces/*.jsonl 2>/dev/null | grep -c "$2"; }
  mkp() { d="$WORK/$1"; mkdir -p "$d/.tad/evidence"; echo "$d"; }

  d=$(mkp c1); echo diag > "$d/.tad/evidence/c1-note.md"
  feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"command":"*** Begin Patch\n*** Add File: .tad/evidence/c1-note.md\n+diag\n*** End Patch"},"tool_response":"ok"}'
  [ "$(rows "$d" 'c1-note.md')" -ge 1 ] && ok "apply_patch Add File leaves a trace row" || bad "apply_patch Add File: no trace row ($(cat "$WORK/c.out" | head -c 120))"
  DESC="trace row is evidence_created"; yes_ grep -q 'evidence_created' "$d"/.tad/evidence/traces/*.jsonl
  [ "$(cat "$WORK/c.rc")" = 0 ] && ok "hook exit 0" || bad "hook exit $(cat "$WORK/c.rc")"

  d=$(mkp c2); echo x > "$d/.tad/evidence/c2-note.md"
  feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"command":"*** Begin Patch\n*** Update File: .tad/evidence/c2-note.md\n@@\n-x\n+y\n*** End Patch"}}'
  [ "$(rows "$d" 'c2-note.md')" -ge 1 ] && ok "apply_patch Update File leaves a trace row" || bad "apply_patch Update File: no trace row"

  d=$(mkp c3)
  feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"command":"*** Begin Patch\n*** Delete File: .tad/evidence/gone.md\n*** End Patch"}}'
  [ "$(rows "$d" 'gone.md')" = 0 ] && [ "$(cat "$WORK/c.rc")" = 0 ] && ok "Delete File only: no row, exit 0" || bad "Delete File only: rows=$(rows "$d" 'gone.md') rc=$(cat "$WORK/c.rc")"

  d=$(mkp c4); before=$(ls -A "$WORK" | wc -l | tr -d ' ')
  feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"command":"*** Begin Patch\n*** Add File: ../../escape-c4.md\n+x\n*** Add File: /tmp/abs-c4.md\n+x\n*** End Patch"}}'
  [ "$(rows "$d" 'c4')" = 0 ] && [ "$(cat "$WORK/c.rc")" = 0 ] && ok "hostile paths: no row, exit 0" || bad "hostile paths: rows=$(rows "$d" 'c4') rc=$(cat "$WORK/c.rc")"
  [ "$before" = "$(ls -A "$WORK" | wc -l | tr -d ' ')" ] && [ ! -e /tmp/abs-c4.md ] && ok "hostile paths: nothing written outside the project" || bad "hostile paths: something was written outside the project"

  d=$(mkp c5); echo x > "$d/.tad/evidence/c5-note.md"
  feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"Write","cwd":"'"$d"'","tool_input":{"file_path":"'"$d"'/.tad/evidence/c5-note.md","content":"x"}}'
  [ "$(rows "$d" 'c5-note.md')" -ge 1 ] && ok "Claude Code Write envelope still leaves a trace row" || bad "Claude Code Write envelope: no trace row (regression)"

  d=$(mkp c6); echo x > "$d/plain.txt"
  feed "$d" '{"hook_event_name":"PostToolUse","tool_name":"apply_patch","cwd":"'"$d"'","tool_input":{"command":"*** Begin Patch\n*** Add File: plain.txt\n+x\n*** End Patch"}}'
  [ "$(rows "$d" 'plain.txt')" = 0 ] && ok "write outside TAD paths: no row" || bad "write outside TAD paths left a row"

  if [ -f .tad/tests/hook-envelope-fixture.sh ]; then
    DESC="hook-envelope-fixture passes bash 3.2 syntax check"; yes_ /bin/bash -n .tad/tests/hook-envelope-fixture.sh
    ( /bin/bash .tad/tests/hook-envelope-fixture.sh > "$WORK/he.log" 2>&1 ); rc=$?
    [ "$rc" = 0 ] && [ "$(tail -1 "$WORK/he.log")" = "HOOK-ENVELOPE-FIXTURE: PASS" ] && ok "hook-envelope-fixture PASS" || { bad "hook-envelope-fixture rc=$rc"; tail -8 "$WORK/he.log"; }
    DESC="hook-envelope-fixture printed at least 9 ok lines"; yes_ test "$(grep -c '^ok ' "$WORK/he.log")" -ge 9
  else bad "hook-envelope-fixture.sh missing"; fi
  for o in startup-health.sh precompact-session-snapshot.sh; do
    DESC="unchanged by package C: .tad/hooks/$o (startup-health is package A's)"; [ "$o" = startup-health.sh ] || yes_ git diff --quiet "$BASE" -- ".tad/hooks/$o"
  done
  DESC="completion report C exists"; yes_ test -f .tad/evidence/yolo/multi-harness-restore-and-cleanup/phase5b-completion-C.md
}

case_GUARD() {
  echo "== GUARD"
  for p in tad.sh .tad/provenance .tad/templates .agents/skills .tad/capability-packs bin; do
    # the two secret-detection-rules.md files carry the human's own uncommitted edits
    ch=$( { git diff --name-only "$BASE" -- "$p"; git status --porcelain -- "$p" | cut -c4-; } | grep -v 'secret-detection-rules\.md$' | sort -u )
    if [ -z "$ch" ]; then ok "unchanged since base: $p"; else bad "changed since base: $p ($(echo "$ch" | head -3 | tr '\n' ' '))"; fi
  done
  DESC="no file under .claude/ is tracked"; no_ test -n "$(git ls-files .claude | head -1)"
  DESC="version.txt still 3.2.0"; yes_ test "$(cat .tad/version.txt)" = "3.2.0"
  R=.tad/hooks/lib
  for m in "state-surface ." "installer-destructive-guard ." "provenance ." "version-sweep . 3.2.0"; do
    # shellcheck disable=SC2086
    bash $R/release-verify.sh $m > "$WORK/g.log" 2>&1; rc=$?
    [ "$rc" = 0 ] && ok "release-verify $m" || bad "release-verify $m rc=$rc: $(tail -1 "$WORK/g.log")"
  done
  bash $R/skill-body-verify.sh > "$WORK/g.log" 2>&1 && ok "skill-body-verify" || bad "skill-body-verify: $(tail -1 "$WORK/g.log")"
  bash tad.sh --verify-denylist > "$WORK/g.log" 2>&1 && ok "verify-denylist" || bad "verify-denylist: $(tail -1 "$WORK/g.log")"
}

case "${1:-ALL}" in
  A) case_A ;; B) case_B ;; C) case_C ;; GUARD) case_GUARD ;;
  ALL) case_A; case_C; case_B; case_GUARD ;;
  *) echo "usage: P5B_BASE=<commit> $0 A|B|C|GUARD|ALL" >&2; exit 2 ;;
esac
echo "== TOTAL FAILS: $FAILS"
[ "$FAILS" = 0 ]
```

## 5. 交付

- 工作包 A 的完成报告：`.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase5b-completion-A.md`
- 工作包 B 的完成报告：同目录 `phase5b-completion-B.md`，含 B4 的判别输出和 B6 逐用例的归类表
- 工作包 C 的完成报告：同目录 `phase5b-completion-C.md`，含多文件补丁的处理方式（循环还是取第一条）和其他三家信封形态的出处
- 报告须写明：实际跑过的命令及其末行输出；没跑的检查；每一处偏离本 handoff 的地方及理由；发现但没修的问题。
- 所有命令前台运行。卡住、矛盾、或某一步几分钟没有输出，就给 Conductor 发消息，不要原地等。

## 6. 风险

| 风险 | 缓解 |
|---|---|
| 为了让夹具变绿而删断言 | 脚本 `B` 要求 PASS 数不低于 172（基线 167 通过 + 5 失败）；每条改动须在用例注释里写明原意和改法；实现审查逐条看 |
| 夹具运行写进真实的 `$HOME/.tad-backups` | 强制沙箱 `TAD_BACKUP_ROOT`；脚本前后比对条目数 |
| 允许清单变成遮羞布 | 每行必须有理由、禁用通配、过期项告警；实现审查抽查 |
| `ac2.8`(a) 其实是安装器缺陷 | B4 先判别；是缺陷就保留失败并上报，由 Conductor 另开安装器修复 |
| 三个工作包并行时整树 `git status` 比较不稳定 | B 的中间运行按用例单跑；脚本的 `B` 与 `GUARD` 由 Conductor 在三个包都落地后运行 |
| 补丁正文是模型写的文本，被 hook 解析 | 只做文本提取；丢弃绝对路径、`..`、控制字符；上限 20 条；夹具含恶意路径用例；实现审查由安全审查员看 |
| 改共享的 hook 信封解析影响另外三家 | 只在「工具名是 apply_patch 且路径为空」时走新分支；夹具含三家现有信封的回归用例 |
| workflow 脚本改动无法用单元测试验证 | 静态检查 + Conductor 不带参数真跑两个 pack workflow |
