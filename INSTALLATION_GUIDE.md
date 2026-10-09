# TAD Installation Guide

**Version 3.2.0 — Alex / Blake is the Default, Codex / OpenCode / Cursor / Claude Code are supported runtimes**

## 安装方式

### 方式 1: curl（推荐，一行全量安装）

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

默认安装（Codex）+ 全部 25 个 packs。无需 Node.js，只需 bash + curl。首次安装与后续升级用同一命令；升级不会删除你的既有文件，项目数据（handoffs、evidence、project-knowledge）保持不变。

平台参数（显式覆盖默认值）：

```bash
# codex（默认；或 opencode / cursor / claude-code）
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes --platform codex --packs web-frontend,web-backend
```

> `--platform both` 自 v3.0.0 起不再提供：安装器会在改动任何文件前停下并打印说明。
> `--platform claude-code` 自 v3.3.0 起再次可用：除 `.agents/skills/` 外，安装器还会为 Claude Code 投放
> `.claude/skills/<名>` 符号链接（指向 `.agents/skills/<名>`，不是副本）、在**已存在**的 `CLAUDE.md` 末尾追加一个
> 只含 `@AGENTS.md` 的受管块，并在目标没有 `.claude/settings.json` 时放入 TAD 的 hook 注册（已有且不同的原样保留，
> 结尾汇总会写明「TAD hooks are NOT registered」）。其他平台不会向 `.claude/`、`CLAUDE.md` 投放或追加内容（既有的弃用清理行为不变）。
> 给**已装同版本 TAD** 的项目加装 Claude Code，请用 `--platform claude-code --force`（不带 `--force` 时安装器照旧什么都不做，但会打印这条提示）。
> v2.x 时代留下的 `.claude/skills/<名>` **镜像目录**：只要逐字节证明是 TAD 发过的文件，`--platform claude-code` 会先存档再替换成新链接；证明不了的原样保留（详见下方「从旧版 Claude Code 安装升级」）。
> 从 2.43 之前的版本升级到 `claude-code` 时，旧迁移清单里按路径删除 `.claude/skills/...` 的条目会因路径经过 TAD 刚建的符号链接而被迁移引擎整体拒绝（退出码 2，仅告警）：该版本步骤里的其余删除一并跳过，旧版本遗留的陈旧文件会留在原处，需要时请手工清理。
> 详见下方「升级到 v3.0.0」。

CI / 脚本化（跳过确认提示）：

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

### 方式 2: npx（交互式，需要 Node.js）

```bash
npx github:Sheldon-92/TAD
```

交互式选择 capability packs，每个 pack 附一句话说明（安装目标：codex / opencode / cursor / claude-code）。

> 需要 Node.js 14+。不想装 Node.js 就用上面的 curl。

### 方式 3: Git clone

```bash
git clone https://github.com/Sheldon-92/TAD.git .tad-source
cd .tad-source && bash tad.sh
cd .. && rm -rf .tad-source
```

## 安装后

```bash
# 验证安装
cat .tad/version.txt          # 应显示 3.2.0
ls .agents/skills/ | wc -l    # 应 >= 20（框架 skills + packs）

# 默认（Alex / Blake —— 两个 terminal，人是唯一信息桥梁）
/alex           # Terminal 1: 设计与规划
/blake          # Terminal 2: 实现与执行

# 🧊 已冻结的实验（lite —— 显式调用仍完全可用）
/alex-lite      # 设计与规划（已冻结）
/blake-lite     # 实现与执行（已冻结）
```

## 升级现有项目

```bash
# 任选其一：
npx github:Sheldon-92/TAD                            # npx（推荐）
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes  # curl
```

脚本自动检测现有安装，保留你的 handoffs、evidence、project-knowledge，只更新框架文件。

### 项目内更新（`$tad-update` / `/tad-update`）

安装后，当前项目内置一个更新入口，两个 harness 共用同一个 helper：

- **Codex**：`$tad-update`（skill）
- **OpenCode**：`/tad-update`（**updater-only**：仅提供更新入口，不包含 Alex/Blake/Gate 角色、hooks 或 gate 能力）

流程：先运行 `--check` 查看当前/远程版本与备份位置（只读、不改任何文件）；确认要更新后再显式确认并执行 apply。helper 会在每次项目变更前自动备份，且仅在你确认后调用官方安装器。不支持静默自动更新——`--yes` 只能在你明确批准后使用。

### 从旧版 Claude Code 安装升级

旧安装器（≤2.44.6）把 skill 整目录复制到 `.claude/skills/<名>`、整文件覆盖 `.claude/settings.json`、把 TAD 正文并进 `CLAUDE.md` 顶部、把 workflow 复制到 `.claude/workflows/`，没有留下任何标记。
`--platform claude-code` 现在会按**内容**识别其中确为 TAD 发过的文件，其余一律不动。

1. **先看计划**：`--claude-adopt=plan`（或环境变量 `TAD_CLAUDE_ADOPT=plan`）只打印 `CLAUDE-ADOPT-PLAN adopt=… retire=… left=… user=…` 和逐条目行，项目与备份目录都不改。已是同版本时需配 `--force` 才会走到这一步。经 `npx` 或 `tad-update.sh` 安装时用环境变量传这个选项。
2. **被替换的**：与某个已发版本逐字节相同的 skill 目录（含旧 `cp -r` 留下的 `<名>/<名>/` 自嵌套副本）、整文件等于某个已发版本（或只差空白）的 `settings.json`、`CLAUDE.md` 里等于某个已发版本的 TAD 头部（标记线 `<!-- TAD:PROJECT-CONTENT-BELOW -->` 以下你写的内容逐字节保留）、与已发版本相同的 `.claude/workflows/*` 文件。替换后由原有投影建符号链接、放入 hook 模板、追加 `@AGENTS.md` 引用块。
3. **原样保留的**：改过一个字节的 skill、多出文件的目录、含 `local/` 的目录、目录里有符号链接的、你自己建的 skill、带你自己键的 `settings.json`、头部被改过的 `CLAUDE.md`、改过的 workflow。每个都有一行 `CLAUDE-ADOPT-LEFT <路径> (<原因>)`。
4. **存档位置**：`<备份根>/<项目名>/claude-adopt/<时间戳>/`（备份根默认 `~/.tad-backups`，可用 `TAD_BACKUP_ROOT` 指定），在项目之外；含 `tree/`（被替换条目的原样副本，含接管前完整的 `CLAUDE.md`）、`done.tsv`、`plan.tsv`、`report.md`。保留策略不会清理它，确认无误后自行删除。只存档被替换的条目，没被动的不会被复制出去。
5. **阻断型 hook 不再注册**：旧 `settings.json` 注册的 `PreToolUse` 检查（`pre-accept-check.sh`、`pre-gate-check.sh`）随旧文件一起不再生效，脚本仍在 `.tad/hooks/`。
6. **手工还原一个条目**：从存档的 `tree/<路径>` 拷回 `<路径>`；原位置若已是链接，先删链接，不要直接 `mv` 覆盖。若项目把 `.claude/` 纳入 git，替换会显示为删除加新增链接，需自行提交。
7. **降级为只报告**：没有 SHA-1 工具、台账缺失或损坏、备份根无法解析、`.claude` 是符号链接、或存在上次中断留下的 `.tad-adopt-tomb.*` 时，安装照常成功，但只打印 `CLAUDE-ADOPT-DEGRADED <原因>` 与分类，不替换任何东西。`--claude-adopt=off` 完全回到不接管的行为。
8. 同步工具（如 Syncthing）对符号链接的处理未测。

### 升级到 v3.0.0（平台支持整合）

1. **只用 Codex 的用户**：无需操作。`npx tad-framework` / `curl | bash` 现在默认装
   `.agents/skills`；`--platform codex` 为默认。
2. **Claude Code 的用户**：自 v3.0.0 起请直接以 AGENTS.md 方式使用（Claude Code
   ≥2.1.277 原生读取本仓 `AGENTS.md`，角色与门禁可直接加载）。升级**不会删除、
   不会改写**你现有的 `.claude/`（含 skills、settings.json、hooks、MCP、权限配置），
   旧文件可自行保留或清理。
  （**TAD 不会代删**）。
3. **脚本里传 `--platform both` 的用户**：该参数自 v3 起不再
   提供（`--platform claude-code` 自 v3.3.0 起已恢复，见上），安装器会**在改动任何文件前**停下并打印说明。请改传 `--platform codex`（或 `claude-code`），或直接重跑：
   - 本地 updater：`bash .tad/scripts/tad-update.sh --platform codex --yes`
   - npm：`npx tad-framework@latest --platform codex`
   - curl：`curl -fsSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --platform codex --yes`

   > 若你用**旧版（≤2.44.6）自带 updater**：它会自动探测出 `both` 并原样透传 →
   > v3 会 fail-before-mutation 停下。用上面任一条恢复命令即可，**不会丢文件**。
4. **直接调用某个 capability pack 的 `install.sh`**：目标现在是 `.agents/skills/`；
   旧的 `~/.claude/skills/` 安装不会自动迁移或删除。
5. **迁移安全保证**：v3.0.0 **不生成**删除用户 `.claude/**` 的 migration manifest；
   历史 manifest 只读保留。

## 平台说明

| 平台 | 说明 | 安装大小 |
|------|------|----------|
| Codex CLI | 完整安装，含 alex/blake SKILL + hooks | ~120KB |
| OpenCode | skills + AGENTS.md（无 lifecycle hooks，P2） | ~120KB |
| Cursor | skills + AGENTS.md（无 lifecycle hooks，P2） | ~120KB |

Codex 用户可以用更少的 context 跑 TAD 工作流。详见 [Codex CLI 指南](#codex-cli)。

## Capability Packs

TAD 包含 25 个 capability packs，每个提供特定领域的判断规则：

| 类别 | Packs |
|------|-------|
| Web 开发 | web-frontend, web-backend, web-ui-design, web-testing, web-deployment |
| AI/Agent | ai-agent-architecture, ai-prompt-engineering, ai-evaluation, ai-tool-integration, ai-guardrails, agent-memory, agent-orchestration |
| 内容制作 | ai-voice-production, ai-podcast-production, video-creation |
| 数据/检索 | data-engineering, rag-retrieval, knowledge-graph, synthetic-data |
| 安全 | code-security |
| 可观测性 | llm-observability |
| 产品/研究 | product-thinking, research-methodology, academic-research |
| 机器学习 | ml-training |

安装时选择需要的 packs（npx 方式有交互选择）。不选 = 全部安装。

## Codex CLI

TAD 完整支持 Codex CLI（v0.130+），使用同一套 SKILL.md 文件。OpenCode / Cursor 通过同一套 `.agents/skills/` + `AGENTS.md` open-box 可用（激活语法见下）。

```bash
# 前提：已安装 codex CLI + 配置 OpenAI 认证
codex --version

# 安装（skills 安装到 .agents/skills/）
bash tad.sh --platform codex --yes
# 或：bash tad.sh --platform opencode|cursor --yes（skills + AGENTS.md，无 hooks）

# 使用：在 Codex 中输入 $alex 或 $blake 激活角色；在 OpenCode / Cursor 中输入 /alex 或 /blake（skills 也可经模型选择加载）
```

**安装内容（Codex）**：
- `.agents/skills/` — 完整 SKILL.md + 24 capability packs
- `.codex/hooks.json` — 按 Codex CLI 0.146+ schema 自动生成的 lifecycle hooks
- `AGENTS.md` — 角色触发词和 capability pack 表

**已知限制（Codex）**：
- Codex hooks 不支持 `type: prompt`（LLM 内联安全检查），详见 `.tad/guides/hooks-platform-mapping.md`
- Codex 无等价的 Skill matcher，`pre-accept-check.sh` 和 `pre-gate-check.sh` 需手动运行
- skill 引用按各自 `.agents/skills/<skill>/` 基目录解析；激活时间约 65 秒

**Known Gaps（OpenCode / Cursor）**：P2 lifecycle hooks 未实现（`.opencode/plugins/tad.ts`、`.cursor/hooks.json`）；P4 真机回归未跑。

## 常见问题

**Q: Codex 没有识别 TAD？**
A: 检查 `.agents/skills/` 目录是否存在且包含 SKILL.md 文件。确认 `AGENTS.md` 在项目根目录。

**Q: /alex 命令不可用？**
A: 确认 `.agents/skills/alex/SKILL.md` 存在。如果缺失，重新运行安装命令。

**Q: 如何只安装特定 packs？**
A: `npx github:Sheldon-92/TAD --packs web-frontend,web-backend` 或 `bash tad.sh --packs web-frontend,web-backend`

**Q: npm 和 curl 有什么区别？**
A: npm 有完整的交互式 pack 选择（每个 pack 附说明）；curl 只选平台，packs 通过参数指定。功能完全相同。
