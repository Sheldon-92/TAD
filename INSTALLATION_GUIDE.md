# TAD Installation Guide

**Version 2.43.1 — Alex / Blake is the Default**

## 安装方式

### 方式 1: curl（推荐，一行全量安装）

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

默认双平台安装（Claude Code + Codex）+ 全部 25 个 packs。无需 Node.js，只需 bash + curl。首次安装与后续升级在不传 `--platform` 时均为双平台；只有 Claude Code 的旧项目升级后自动补齐 Codex 文件，项目数据（handoffs、evidence、project-knowledge）保持不变。

只要单平台（显式覆盖默认值）：
```bash
# 仅 Claude Code
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes --platform claude-code

# 仅 Codex，或选择特定 packs
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes --platform codex --packs web-frontend,web-backend
```

CI / 脚本化（跳过确认提示）：
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```

### 方式 2: npx（交互式，需要 Node.js）

```bash
npx github:Sheldon-92/TAD
```

交互式选择平台（Claude Code / Codex CLI）和 capability packs，每个 pack 附一句话说明。

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
cat .tad/version.txt          # 应显示 2.43.1
ls .claude/skills/ | wc -l    # 应 >= 20（框架 skills + packs）

# 使用 Claude Code
claude .                       # 打开项目

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

安装后，当前项目内置一个更新入口，三个平台共用同一个 helper：

- **Claude Code**：`$tad-update`（skill）
- **Codex**：`$tad-update`（skill，与 Claude Code 字节一致）
- **OpenCode**：`/tad-update`（**updater-only**：仅提供更新入口，不包含 Alex/Blake/Gate 角色、hooks 或 gate 能力）

流程：先运行 `--check` 查看当前/远程版本与备份位置（只读、不改任何文件）；确认要更新后再显式确认并执行 apply。helper 会在每次项目变更前自动备份，且仅在你确认后调用官方安装器。不支持静默自动更新——`--yes` 只能在你明确批准后使用。

## 平台说明

| 平台 | 说明 | 安装大小 |
|------|------|----------|
| Claude Code | 完整安装，含全部 SKILL + hooks | ~200KB |
| Codex CLI | 完整安装，含 alex/blake SKILL + hooks | ~120KB |

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

TAD 完整支持 Codex CLI（v0.130+），使用同一套 SKILL.md 文件：

```bash
# 前提：已安装 codex CLI + 配置 OpenAI 认证
codex --version

# 仅 Codex（skills 安装到 .agents/skills/）
bash tad.sh --platform codex --yes

# 双平台（同时安装 .claude/skills/ + .agents/skills/，推荐）
bash tad.sh --platform both --yes

# 使用：在 Codex 中输入 $alex 或 $blake 激活角色
```

**安装内容**：
- `.agents/skills/` — 完整 SKILL.md + 24 capability packs
- `.codex/hooks.json` — 按 Codex CLI 0.146+ schema 自动生成的 lifecycle hooks
- `AGENTS.md` — 角色触发词和 capability pack 表

**已知限制**：
- Codex hooks 不支持 `type: prompt`（LLM 内联安全检查），详见 `.tad/guides/hooks-platform-mapping.md`
- Codex 无等价的 Skill matcher，`pre-accept-check.sh` 和 `pre-gate-check.sh` 需手动运行
- skill 引用按各自 `.agents/skills/<skill>/` 基目录解析；激活时间约 65 秒

## 常见问题

**Q: Claude Code 没有识别 TAD？**
A: 检查 `.claude/skills/` 目录是否存在且包含 SKILL.md 文件。重启 Claude Code。

**Q: /alex 命令不可用？**
A: 确认 `.claude/skills/alex/SKILL.md` 存在。如果缺失，重新运行安装命令。

**Q: 如何只安装特定 packs？**
A: `npx github:Sheldon-92/TAD --packs web-frontend,web-backend` 或 `bash tad.sh --packs web-frontend,web-backend`

**Q: npm 和 curl 有什么区别？**
A: npm 有完整的交互式 pack 选择（每个 pack 附说明）；curl 只选平台，packs 通过参数指定。功能完全相同。
