# TAD Installation Guide

**Version 2.25.0 — Universal AC-Driven Gate**

## 安装方式

### 方式 1: curl（推荐，一行全量安装）

```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash
```

默认 Claude Code 全套 + 全部 25 个 packs。无需 Node.js，只需 bash + curl。

Codex 用户或选择特定 packs：
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --platform codex --packs web-frontend,web-backend
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
cat .tad/version.txt          # 应显示 2.25.0
ls .claude/skills/ | wc -l    # 应 >= 20（框架 skills + packs）

# 使用 Claude Code
claude .                       # 打开项目

# Terminal 1: 设计与规划
/alex

# Terminal 2: 实现与执行
/blake
```

## 升级现有项目

```bash
# 任选其一：
npx github:Sheldon-92/TAD                            # npx（推荐）
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash  # curl
```

脚本自动检测现有安装，保留你的 handoffs、evidence、project-knowledge，只更新框架文件。

## 平台说明

| 平台 | 说明 | 安装大小 |
|------|------|----------|
| Claude Code | 完整安装，含全部 SKILL + hooks | ~200KB |
| Codex CLI | 瘦版，不含 86K alex/blake SKILL + hooks | ~120KB |

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

当 Claude Code 额度用完时，用 Codex CLI 继续 TAD 工作流：

```bash
# 前提：已安装 codex CLI + 配置 OpenAI 认证
codex --version

# 启动
bash .tad/codex/codex-tad-alex.sh    # Alex
bash .tad/codex/codex-tad-blake.sh   # Blake
```

已知限制：无 AskUserQuestion 工具、无并行 reviewer、无 auto-hooks。详见 `.tad/codex/` 目录。

## 常见问题

**Q: Claude Code 没有识别 TAD？**
A: 检查 `.claude/skills/` 目录是否存在且包含 SKILL.md 文件。重启 Claude Code。

**Q: /alex 命令不可用？**
A: 确认 `.claude/skills/alex/SKILL.md` 存在。如果缺失，重新运行安装命令。

**Q: 如何只安装特定 packs？**
A: `npx tad-framework --packs web-frontend,web-backend` 或 `bash tad.sh --packs web-frontend,web-backend`

**Q: npm 和 curl 有什么区别？**
A: npm 有完整的交互式 pack 选择（每个 pack 附说明）；curl 只选平台，packs 通过参数指定。功能完全相同。
