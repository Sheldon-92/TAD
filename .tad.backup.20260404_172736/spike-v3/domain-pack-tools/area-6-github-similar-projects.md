# Area 6: GitHub 上类似项目

## 搜索发现

### 高度相关

1. **[danielmiessler/Personal_AI_Infrastructure](https://github.com/danielmiessler/Personal_AI_Infrastructure)**
   - 最接近 Domain Pack 概念的项目
   - "PAI Packs" = 模块化、可独立安装的能力扩展包
   - 40+ skills, specialized agents, automation workflows
   - 原生构建于 Claude Code 之上
   - **值得深入参考其 Pack 架构**

2. **[deanpeters/Product-Manager-Skills](https://github.com/deanpeters/Product-Manager-Skills)**
   - 专门 PM 领域的 skill 包
   - 46 个 PM 方法论 skill (discovery/strategy/delivery/SaaS)
   - 兼容 Claude Code、Codex、AI agents
   - **最接近"PM Domain Pack"但缺少工具集成**

3. **[alirezarezvani/claude-skills](https://github.com/alirezarezvani/claude-skills)**
   - 220+ skills，跨 engineering/marketing/product/compliance
   - 多 agent 平台兼容 (Claude/Codex/Gemini CLI/Cursor)
   - 纯 prompt skills，无工具集成

### 参考价值

4. **[rohitg00/awesome-claude-code-toolkit](https://github.com/rohitg00/awesome-claude-code-toolkit)**
   - 135 agents, 35 skills, 42 commands, 150+ plugins
   - 更像 monorepo 而非领域包

5. **[VoltAgent/awesome-agent-skills](https://github.com/VoltAgent/awesome-agent-skills)**
   - 1000+ agent skills 聚合仓库
   - 跨平台 (Claude/Codex/Antigravity/Cursor)

## 关键发现

**没有发现直接叫 "Domain Pack" 的项目。** 但 PAI 的 "Packs" 概念最接近 — 模块化 + 可独立安装 + 能力扩展。

### TAD Domain Pack 的差异化定位

| 维度 | 现有项目 (PAI, PM-Skills 等) | TAD Domain Pack (目标) |
|------|---------------------------|----------------------|
| 核心 | Prompt skills (纯文本指令) | Tools + Workflow + Standards |
| 产出 | 文本建议 | 实际交付物 (PDF, 图表, 邮件) |
| 集成 | 无或简单 | CLI + MCP 深度集成 |
| 质量 | 无内置检查 | Persona+Checklist review |
| 框架 | 独立 skill 文件 | Pack = 完整领域能力包 |

**最大差异化: "做出东西" vs "写建议"** — 现有项目全是 prompt-only，TAD Domain Pack 的核心价值是通过真实工具产出 artifacts。
