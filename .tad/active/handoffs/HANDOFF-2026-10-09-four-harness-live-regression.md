# HANDOFF: 四家真机回归（Epic Phase 4b）

- Epic：`.tad/active/epics/EPIC-20261008-multi-harness-restore-and-cleanup.md`，Phase 4b
- 日期：2026-10-09。作者：Alex（Conductor）。修订：1
- 事实依据：`.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase4b-grounding.md`（下称「调研」）
- 性质：**只做测量，不改产品**。本 handoff 的交付物是证据和一张结果表；台账与文档的更新由 Conductor 依据结果另行安排。

## 1. 目的

用当前源码树把 TAD 装进四个一次性项目（Claude Code、Codex、Cursor、OpenCode 各一个），各用该 harness 的非交互命令真跑，记录每项能力「观察到了什么」。文档里每一格支持声明都要落到这里的某一条证据上；测不出来的就写测不出来。

**结果只有四种取值**，不许有别的说法：

| 取值 | 含义 |
|---|---|
| `OBSERVED` | 有判据要求的客观证据（文件里的行、事件流里的事件），不是模型自述 |
| `NOT-OBSERVED` | 按协议跑了，判据没有出现。这是有效结果，照实记 |
| `NOT-MEASURABLE` | 该 harness 的非交互模式没有办法观察到（说明原因） |
| `BLOCKED` | 没跑成（额度、鉴权、工具报错）。附错误原文。**不得改写成其他取值** |

模型说「hook 触发了」不算证据。判据见 §3。

## 2. 纪律

1. 安装器只在 `mktemp -d` 下的沙箱项目里运行，命令固定为：
   `cd <proj> && TAD_BACKUP_ROOT=<tmp>/bk /bin/bash /Users/sheldonzhao/云同步/TAD/tad.sh --source /Users/sheldonzhao/云同步/TAD --platform <p> --force --yes </dev/null`
   不在 TAD 仓库或任何真实项目里运行安装器或 harness。
2. 每个沙箱项目：`git init`，提交一个 `README.md`，安装后再提交一次（这样之后 `git status` 能显示 harness 运行改了什么）。
3. 不读 `~/.claude/`、`~/.codex/auth*` 及任何凭据文件；不打印名字以 CLAUDE、ANTHROPIC、OPENAI、CURSOR、OPENCODE 开头的环境变量的值；不设 `CLAUDE_CONFIG_DIR`。
4. 原始输出（事件流、日志）只放在 `mktemp -d` 目录里。进仓库的只有**脱敏后的摘录**：去掉邮箱、用户名、`/Users/<名字>` 路径（换成 `<HOME>`）、组织名、权限规则列表、用户级 skill／插件清单。每条摘录保留足以证明判据的最少行数。
5. 提示词不得要求模型做沙箱项目之外的任何事。不使用 `--force`、`--yolo`、`--auto`、`--pure`、`--dangerously-skip-permissions` 之类放宽权限的开关；例外只有 §3.2 写明的那一个 Codex 开关。
6. 每个 harness 的模型请求上限：Claude Code 8 次、Codex 7 次、Cursor 6 次、OpenCode 5 次。到上限就停，没跑的格子记 `BLOCKED（达到请求上限）`。Claude Code 每次加 `--max-budget-usd 0.50`。
7. 顺序：先 Codex（额度最不确定；出现 `turn.failed` 或额度信息就停止 Codex，其余格子记 `BLOCKED` 并附原文），再 Claude Code、Cursor、OpenCode。
8. 全部前台运行，每条 harness 命令加超时（建议 300 秒），stdin 一律 `</dev/null`。超时记 `BLOCKED（超时）`。卡住或有疑问就给 Conductor（`main`）发消息，不要原地等。
9. 结束时删除自己的临时目录；删除前把要留的摘录写进仓库的证据目录。

## 3. 检查项与判据

每个沙箱装好后，在 `AGENTS.md` 末尾追加一行唯一口令 `TAD-CANARY-<8 位随机十六进制>`（每个 harness 不同），并提交。

### 3.1 通用检查（四家都做，除非标明）

| 编号 | 检查 | 做法 | `OBSERVED` 的判据 |
|---|---|---|---|
| a | `AGENTS.md` 被自动加载 | 问：「你的指令里有没有一个以 TAD-CANARY- 开头的口令？有就原样回复，没有回复 NONE。不要读取任何文件。」Claude Code 加 `--tools ""`。其余三家无法禁用工具，须检查事件流／输出里有没有对 `AGENTS.md` 的读取调用 | 回答含正确口令，**且**事件流里没有读 `AGENTS.md` 的工具调用。有读取调用则记 `NOT-OBSERVED（经文件读取得到，无法区分）` |
| b | TAD skill 可被发现并按名字调用 | 按该 harness 的调用方式触发 `tad-help`（Claude Code：`/tad-help`；Codex：`$tad-help`；Cursor、OpenCode：`/tad-help`，不行则「使用名为 tad-help 的 skill」），要求回复该 skill 正文里的一个特征串（先从 `.agents/skills/tad-help/SKILL.md` 里选一个不会出现在 `AGENTS.md` 里的短语） | 回答含该特征串，且事件流显示 skill 被加载（skill 工具调用，或对该 `SKILL.md` 的读取）。两者记清是哪一种 |
| c | 会话启动 hook 触发 | 问：「你在本次会话开始时收到的 TAD 启动健康摘要原文是什么？没有就回复 NONE。不要读取任何文件，不要运行命令。」 | 回答含 `TAD v3.2.0 \|` 开头的摘要，且事件流里没有运行 `startup-health.sh` 的工具调用。Claude Code 另须事件流里有 SessionStart 的 `hook_response` 且退出码 0 |
| d | 写文件后的 hook 触发 | 让模型用该 harness 的写文件工具创建 `.tad/evidence/p4b-note.md`（一行内容）。同一会话再创建项目根下的 `p4b-control.txt` 作对照 | 运行后从 shell 检查 `.tad/evidence/traces/<当天>.jsonl`：有一行 `evidence_created` 且 `file` 指向 `p4b-note.md`；对照文件没有对应行。只看文件，不看模型怎么说 |
| e | 压缩 hook | 只在 Claude Code 上试一次：`claude -p "/compact"` 之类的非交互触发是否可行（先查 `claude --help`）。其余三家不试 | `.tad/active/precompact/snapshot-*.md` 出现。试不出来记 `NOT-MEASURABLE（非交互模式下无法触发压缩）` |
| f | 子代理定义可见（仅 Claude Code） | 检查事件流 `system/init` 里的 agents 列表，或 `claude agents` 之类的只读命令 | 列表里有 `spec-compliance-reviewer` |

OpenCode 的 c 项直接记 `NOT-MEASURABLE`：它的会话创建事件没有向模型注入内容的通道，`startup-health.sh` 也不写文件（调研 §4）。不要为了测它去改插件。

### 3.2 各家特别事项

**Codex**
- 命令：`codex exec --ephemeral -s read-only --json -C <proj> "<问题>" </dev/null`；d 项用 `-s workspace-write`，并在提示词里要求使用 `apply_patch`（hook 的匹配器是 `^apply_patch$`，shell 重定向不会匹配）。
- hook 信任：项目里的 `.codex/hooks.json` 属于未受管 hook，Codex 要求先做信任审查。c、d 两项**各跑两遍**：
  1. 不带任何信任开关。这是用户装完后默认会遇到的情况，结果单独成行（`c-default`、`d-default`）。
  2. 带 `--dangerously-bypass-hook-trust`，**仅限这个一次性沙箱**。结果记为 `c-trusted`、`d-trusted`。这是本协议唯一允许的放宽开关；如果运行环境拒绝执行这条命令，不要换别的办法绕，记 `BLOCKED（未获准使用信任旁路）` 并告诉 Conductor。
- 额外一项 `g`：一次 `codex exec --json` 会话，确认 JSONL 会话输出可被捕获（记录事件类型清单，不记内容）。这是台账 `trace_evidence_capture` 一行需要的复核。
- 额外一项 `h`：Codex 的压缩。TAD 没有给 Codex 接 PreCompact hook。只查 `codex --help`、`codex exec --help`、`codex features list` 里与 compact 有关的条目并原样记录，不发模型请求。结论只能是「平台有／没有该事件；TAD 未接线；投递未测」，不要写成已验证。

**Claude Code**
- 命令：`claude -p "<问题>" --output-format stream-json --verbose --include-hook-events --no-session-persistence --max-budget-usd 0.50`，在沙箱项目根目录下运行（从子目录启动会丢项目 hook，这一点已测过，不重复）。
- 用户级的 skill、hook、权限规则会混进每个会话。b 项因此要有负对照：在一个没有装 TAD 的空目录里跑同一问题，确认特征串不出现。摘录里不得带用户级清单。
- d 项：`--permission-mode acceptEdits --tools "Write"`。
- 交互式会话是否加载 `AGENTS.md`／skill／hook 无法从这里测量，结果表里单列一行 `NOT-MEASURABLE（需人在交互会话里确认）`。

**Cursor**
- 命令：`cursor-agent -p --trust --output-format stream-json "<问题>" </dev/null`。`-p` 模式有全部工具且不询问，所以提示词必须严格限定在项目内。
- d 项要求用 Write 工具（匹配器是 Write；shell 或替换类工具不匹配）。

**OpenCode**
- 命令：`opencode run --model opencode-go/deepseek-v4.1-flash --format json "<问题>" </dev/null`。不加 `--pure`（会禁用 TAD 插件）。stdin 不关会永久挂起。
- d 项：插件只处理 `write` 和 `edit` 两个工具。

### 3.3 安装器观察（不发模型请求）

四次安装各记录：退出码、自检行、该平台特有文件清单。并核对调研 §3 列出的四个现象是否仍在，照实记录（不修）：

1. 末行 GitHub 链接两侧出现未被解释的 `\033[0;34m` 字面量；
2. 快速开始文案对四个平台相同；
3. Claude Code 摘要里夹一行中文；
4. 任何平台的安装都会写 `.cursor/hooks.json` 和 `.opencode/plugins/tad-hooks.ts`。

另加一项降级路径演练（调研未覆盖）：在 Claude Code 沙箱的一个副本里，先放一个用户自己写的 `.claude/settings.json`（内容 `{"permissions":{"allow":[]}}`）再安装。记录安装器的摘要怎么说、该文件是否字节不变、hook 是否未注册。然后用 c 项的问题跑一次，预期 `NOT-OBSERVED`。这是「已有 `settings.json` 时 TAD 不注册 hook」这句文档声明的证据。

## 4. 交付

目录 `.tad/evidence/yolo/multi-harness-restore-and-cleanup/phase4b/`（被 git 忽略）：

- `results.md`：
  - 环境：日期、机器（本机 macOS）、四个 CLI 的版本、TAD 源提交（`git rev-parse --short HEAD`）与版本号；
  - 结果表：行 = 检查项（含 Codex 的 `c-default`／`c-trusted`／`d-default`／`d-trusted`／`g`／`h`，以及 Claude Code 的交互面一行、`settings.json` 已存在一行），列 = 四家；每格是四种取值之一加一句依据和摘录文件名；
  - 每家实际发出的模型请求数；
  - 与台账现有说法不一致的地方（逐条：台账哪一行怎么说、这次看到什么）；
  - 没跑的、跑了但你不确信的，单独一节。
- `<harness>-<检查项>.md`：每格一份脱敏摘录，开头写明完整命令行（路径用 `<proj>` 代替）和退出码。
- `installer.md`：§3.3 的记录。

最后给 Conductor 发一条消息：结果表本身，加上任何 `BLOCKED`。

## 5. 验收标准（Conductor 判定）

| # | 标准 |
|---|---|
| AC1 | 结果表每一格都是四种取值之一，且每个 `OBSERVED` 都能在对应摘录里找到 §3 要求的客观判据 |
| AC2 | 没有一格以模型自述为唯一依据 |
| AC3 | 摘录里没有邮箱、用户名路径、凭据、用户级配置清单 |
| AC4 | `$HOME/.tad-backups` 条目数前后相同；TAD 仓库 `git status` 前后相同 |
| AC5 | 请求数不超过 §2 的上限 |
| AC6 | 独立复核者只读摘录就能重现结果表（Conductor 会另派人做这一步） |

## 6. 风险

| 风险 | 缓解 |
|---|---|
| 模型从磁盘上读到答案，冒充「已加载」 | a、c 两项要求事件流里没有读取调用；Claude Code 直接禁用工具 |
| 把「没跑成」写成「不支持」或「通过」 | 四种取值分开；`BLOCKED` 必须附错误原文 |
| harness 把会话、信任状态写进用户目录 | 用 `--ephemeral`／`--no-session-persistence`；无法避免的（Cursor、OpenCode 的会话库）在 `results.md` 里注明 |
| Codex 信任旁路开关被误用到沙箱之外 | 协议只允许在一次性沙箱里对 c、d 两项使用；提示词限定在项目内 |
| 本机 CLI 版本与台账记录的远程主机版本不同 | 结果只代表本机版本，表头写明；不与 2026-10-06 的远程结果合并表述 |
