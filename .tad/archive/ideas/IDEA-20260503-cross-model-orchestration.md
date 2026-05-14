# Idea: Cross-Model Orchestration — Sub-Agent 调度 Codex/Gemini 实现多模型协作

**ID:** IDEA-20260503-cross-model-orchestration
**Date:** 2026-05-03
**Status:** promoted
**Scope:** large

---

## Summary & Problem

在 Claude Code session 内通过 Agent tool 开子 terminal 调用 Codex CLI 和 Gemini CLI，利用三个平台的差异化能力实现任务分工和跨模型互审。解决单模型"自己审自己"的盲点问题，同时利用用户已有的三平台会员资源（Claude Max 20% + GPT Plus + Gemini Pro 免费额度）。

核心发现（2026-05-03 *discuss 研究）：
- Claude Code：多文件推理最强（92% 首次正确率），主力实现
- Codex CLI：Code Review 最强（88% LiveCodeBench，唯一抓到向后兼容问题的），独立审查
- Gemini CLI：实时研究最强（内置 Google Search Grounding，减少幻觉 ~40%），研究+事实核查
- 业界先例：Mozilla AI "The Star Chamber" 已验证多 LLM 共识审查模式有效

## 架构草案

```
Blake (Claude Code Session) — 协调者
  ├── 自己做：复杂多文件实现（最强项）
  ├── Codex 子 agent：独立 Code Review（不同模型 = 不同盲点）
  ├── Gemini 子 agent：Research + 事实核查（实时 web grounding）
  └── Fallback 链：Codex 超额 → Claude sub-agent; Gemini 超额 → Claude WebSearch
```

Terminal 隔离不冲突：Codex/Gemini 是"工具"不是"agent"，等同于 Blake 调 code-reviewer 子 agent。

## Spike 结果 (2026-05-03)

**Verdict: GO (3/3)** — Commit fcd0ea6, archived.
- ✅ Gemini CLI 可从 Claude Code sub-agent 调用（`gemini -p` 非交互模式）
- ✅ Codex + Gemini 统一 review 输出格式可行（同一 prompt 模板）
- ✅ Fallback 错误检测可行（exit code ≠ 0 + error keyword grep）

## 关键认知演进

### Round 1: 跨模型 Review（*discuss 研究 → spike 验证）
- Claude 实现 + Codex 审查 + Gemini 研究的三角分工
- severity 分歧需要共识解决策略（Gemini 3 P0 vs Codex 2 P0）

### Round 2: 跨模型能力编排（*discuss 第二轮研究）
超越 review，发现每个平台有独特的非编程能力：
- **Codex → GPT Image-2 图片生成**：UI mockup、图表、icon，内置 skill
- **Gemini → Deep Research**：多步自主研究 + 引用，有专门 CLI 扩展
- **Gemini → 图片生成**：Gemini 3 Pro Image，4K 分辨率，多轮编辑
- **Claude → 视频生成**（待验证）
- 未来更多能力会持续出现（各平台迭代极快）

### Round 3: 协议固定、能力可插拔（核心设计原则）
**静态能力目录会快速过时。** 平台能力变化太快（每月都有新功能发布），维护固定列表不可持续。

正确的设计思路：
- **固定的是编排协议**：调用模式 (prompt→CLI→解析输出→fallback)、输出格式统一、错误检测、降级链
- **可插拔的是具体能力**：新能力出现 → 写一个 prompt 模板 + 注册到 catalog → TAD 立刻可用
- 类比：Domain Pack 机制（工作流固定、工具可插拔）的跨平台版本

### Round 4: Shell Access = 万能集成层（最底层洞察，2026-05-03）

**Sub-agent 能力不是 Claude Code 独有的。** 2026-04 四大 CLI（Claude Code, Codex, Gemini, OpenCode）全部具备 sub-agent + 并行执行 + 自定义 agent 配置。趋同已发生。

**真正的洞察不是"Claude Code 能调 Codex"，而是：任何有 shell 权限的 AI agent 天然就是万能工具编排器。**

```
AI Agent (有 shell 权限)
  ├── codex exec ...       → OpenAI 全家桶（GPT-5.5, Image-2, Review）
  ├── gemini -p ...        → Google 全家桶（Gemini 3, Veo, Lyria, Search）
  ├── claude -p ...        → Anthropic 全家桶（Opus, Sonnet, Haiku）
  ├── gh / aws / docker    → DevOps 工具链
  ├── curl -X POST ...     → 任何 REST API
  └── 任何 CLI 工具        → 无限扩展
```

关键推论：
1. **编排不绑定平台**：TAD 用 Claude Code 做编排器是选择（Agent tool 最成熟：subagent_type 分类、model override、worktree isolation），不是锁定
2. **双向可调**：Codex 也能调 Claude Code，Gemini 也能调 Codex——方向是对称的
3. **TAD Method 受益**：TAD Method 的 Codex 用户也能反过来用 Codex 调 Claude Code，同一套编排协议适用于所有方向
4. **不止 AI 工具**：ffmpeg、ImageMagick、pandoc、任何提供 CLI 的工具都是同一个模式——prompt → CLI → 解析输出 → fallback
5. **MCP 是补充不是替代**：MCP 提供结构化工具发现，shell access 提供无限灵活性。两者互补——已注册到 MCP 的工具走 MCP（类型安全），未注册的走 shell（灵活但需要 prompt 模板）

这意味着 TAD 的跨模型编排协议如果设计正确（"协议固定、能力可插拔"），它自动适用于：
- 任何 AI CLI 做编排器（不止 Claude Code）
- 任何 CLI 工具做被编排者（不止 AI 工具）
- 任何方向的调用组合（A→B 和 B→A 用同一套协议）

## 生态扫描：谁在做多模型编排？(2026-05-03 Round 5)

### 三层用户分布

| 层次 | 做法 | 谁在做 | 估计比例 |
|------|------|--------|---------|
| 手动切换 | 同一项目手动用 2-3 个 CLI，择优选用 | 大部分多工具开发者 | ~80% |
| 外部编排器 | 在 AI 之外加 Node.js/Go/容器管理层 | 少数开源项目作者 | ~15% |
| **原生 session 内编排** | **Agent tool + bash 直接 spawn 其他 CLI** | **极少数（包括我们）** | **<5%** |

### 已知外部编排器项目

| 项目 | 架构 | 优劣 |
|------|------|------|
| [ccg-workflow](https://github.com/fengshao1227/ccg-workflow) | Claude 编排 + Codex 后端 + Gemini 前端，Node.js CLI + Go binary，28 命令 | 功能全，但依赖重（Node 20+ / Go 编译 / 6 平台 binary） |
| [claude_code_bridge](https://github.com/bfly123/claude_code_bridge) | WezTerm/tmux 分屏，多 agent 并排运行 | 可视化好，但需要特定终端 + 分屏管理 |
| [Claude-Code-Workflow](https://github.com/catlog22/Claude-Code-Workflow) | JSON 驱动多 agent 框架（Gemini/Qwen/Codex） | 灵活，但 JSON 编排引擎是额外复杂度 |
| [Rover](https://www.blog.brightcoding.dev/2026/04/30/rover-the-revolutionary-ai-agent-manager-every-developer-needs) | AI agent 管理器，容器隔离 + worktree | 隔离强，但容器开销大 |

### 我们的差异化（层次 3）

原生 session 内编排 = **零额外依赖**。不需要装 Node.js 编排器、不需要 Go binary、不需要分屏终端。一行 bash 命令 (`codex exec` / `gemini -p`) 通过 Claude Code 的 Agent tool 或 Bash tool 调用。

ccg-workflow 等项目的存在验证了市场需求（"开发者想要多模型协作"），但它们走了重路径。我们的路径更轻——代价是需要 TAD 级别的协议设计来保证质量（输出格式统一、fallback、共识解决），这正是 TAD 的优势。

仅找到 2 篇博客提到类似的原生编排思路：
- [Hybrid AI Workflows: Spawning Gemini from Claude Code](https://paddo.dev/blog/gemini-claude-code-hybrid-workflow/)
- [When AIs start gossiping about your code](https://byjos.dev/claude-gemini-workflow/)

### 关键判断

**平台能力已经够了（sub-agent + shell = 万能编排），但大多数用户没有意识到这个等式。** 外部编排器项目的作者意识到了需求，但选择了"在 AI 之外造工具"的路径。我们选择"让 AI 自己做编排器"的路径——更轻、更原生、与 TAD 工作流天然集成。

---

## 能力扫描 (2026-05-03 Round 3 全面扫描)

### Codex CLI 能力全景

| 能力 | 描述 | TAD 潜在用途 | 验证状态 |
|------|------|-------------|---------|
| PR Review | 88% LiveCodeBench bug 检测，唯一抓到向后兼容问题 | Gate 3 Layer 2 跨模型审查 | ✅ spike 验证 |
| GPT Image-2 | 图片生成（UI mockup、图表、icon、文字渲染），内置 skill | /playground mockup、handoff 附图 | 未验证 |
| Web Search | 内置搜索（cached + live 模式），默认开启 | Research Decision Protocol 备选 | 未验证 |
| Browser Use | 操作本地开发服务器浏览器 UI | E2E 视觉验证 | 未验证 |
| Sub-agents | 并行产生子 agent | 复杂任务拆分 | 未验证 |
| Cross-session 自动化 | 定时唤醒、监控 Slack/Notion/GitHub PR | CI/CD 监控、PR 状态追踪（不消耗 Claude 额度） | 未验证 |
| Plugin Creator | 内置 @plugin-creator skill | 把 TAD 工作流封装为 Codex plugin | 未验证 |
| MCP 支持 | 第三方工具集成 | 与 Claude Code MCP 互通 | 未验证 |
| /review /fork /side | 内置 slash commands | 快速切换工作流 | 未验证 |

### Gemini CLI 能力全景

| 能力 | 描述 | TAD 潜在用途 | 验证状态 |
|------|------|-------------|---------|
| Google Search Grounding | 实时搜索、减少幻觉 ~40% | 事实核查、依赖评估 | ✅ spike 验证 |
| Deep Research | 多步自主研究 + 引用，CLI 扩展或 API | *discuss、Research Decision Protocol | 未验证（扩展存在） |
| Gemini 3 Pro Image | 高保真图片生成，4K，多轮编辑，字符一致性 | UI mockup、与 Codex Image-2 互补 | 未验证 |
| Veo 3.1 视频生成 | 文本/图片 → 视频（带原生音频） | 产品 demo 自动生成、功能演示视频 | 未验证 |
| Lyria 3 音乐生成 | 文本 → 30s 音轨（含人声、歌词、乐器） | 产品 demo 配乐、UI 音效原型 | 未验证 |
| Extensions 生态 | 社区+官方扩展（Cloud Run、GKE、数据库等） | 基础设施管理 | 未验证 |
| Agent Skills | 推理优先的工具学习系统（按需加载） | 类 Domain Pack 的能力注册机制 | 未验证 |
| 本地 Gemma 模型 | `gemini gemma` 命令跑本地模型 | 离线/隐私敏感场景 | 未验证 |
| MCP 支持 | 资源管理 + 外部系统桥接 | 与 Claude Code MCP 互通 | 未验证 |
| Offline Search | 内置 ripgrep 二进制 | 无网络环境代码搜索 | 未验证 |
| 4 层记忆管理 | prompt-driven memory editing | 长期上下文保持 | 未验证 |

### 按 TAD 工作流映射

```
设计阶段 (Alex)
  ├── 研究：Gemini Deep Research（自动多步 + 引用）
  ├── 视觉探索：Codex Image-2 OR Gemini Imagen（UI mockup）
  ├── 竞品分析：Gemini Search Grounding（实时 web）
  └── 视频原型：Gemini Veo 3.1（概念 → demo 视频）

实现阶段 (Blake)
  ├── 编码：Claude Code（92% 首次正确率，主力）
  ├── 代码审查：Codex PR Review（88% bug 检测）
  ├── 跨模型共识审查：Codex + Gemini 并行 review
  └── 视觉验证：Codex Browser Use（操作本地 dev server）

验收阶段 (Alex Gate 4)
  ├── Demo 生成：Gemini Veo 3.1（截图 → demo 视频）
  ├── 文档核查：Gemini Search Grounding
  └── 配乐/音效：Gemini Lyria 3（demo 视频配乐）

持续运维
  ├── PR 监控：Codex cross-session 自动化（不消耗 Claude 额度）
  └── 依赖安全：Gemini Search Grounding（实时漏洞扫描）
```

### 行业趋势观察

2026-04 四大 CLI 工具（Claude Code, Codex, Gemini CLI, OpenCode）在基础能力上趋同：
sub-agents、plan mode、ask-user、parallel execution、sandboxing、memory、MCP 全部标配。
**结论：共同能力不是差异化价值，独特能力才是。上表中"未验证"项是需要 spike 的差异化能力。**

## Open Questions

- ~~Gemini CLI 能否在 sub-agent 里运行？~~ ✅ 已验证 (spike GO)
- ~~统一输出格式？~~ ✅ 已验证 (spike Test 2)
- ~~Fallback 错误检测？~~ ✅ 已验证 (spike Test 3)
- 能力目录的注册/发现机制：怎么让 Alex/Blake 知道哪些跨模型能力可用？
- 各平台能力更新的跟踪频率：用户发现后手动添加（静态目录过时太快）
- 图片/视频/音频类能力的输出如何集成到 handoff 流程（二进制文件 vs 路径引用）？
- 与 TAD Method 的未来交汇点：此功能是否以后应成为 TAD Method 的可选模块？
- 优先验证哪些能力？（候选：Gemini Deep Research、Codex Image-2、Gemini Veo 3.1）

## Notes

- 研究来源：2026-05-03 Alex *discuss session（三轮），含 13 次 WebSearch
- Spike: SPIKE-20260503-cross-model-orchestration (archived, commit fcd0ea6)
- 参考：[The Star Chamber (Mozilla AI)](https://blog.mozilla.ai/the-star-chamber-multi-llm-consensus-for-code-quality/)
- 参考：[GPT Image-2 in Codex CLI](https://codex.danielvaughan.com/2026/04/27/codex-cli-image-generation-gpt-image-2-visual-development-workflows/)
- 参考：[Gemini Deep Research Extension](https://github.com/allenhutchison/gemini-cli-deep-research)
- 参考：[Gemini Image Generation](https://ai.google.dev/gemini-api/docs/image-generation)
- 参考：[Veo 3.1 Video Generation](https://ai.google.dev/gemini-api/docs/video)
- 参考：[Lyria 3 Music Generation](https://www.genmedialab.com/news/google-lyria-3-gemini-ai-music-generator/)
- 参考：[Codex CLI Features](https://developers.openai.com/codex/cli/features)
- 参考：[Gemini CLI Extensions](https://geminicli.com/extensions/)
- 参考：[Gemini Agent Skills](https://medium.com/google-cloud/your-gemini-cli-extensions-just-got-smarter-introducing-agent-skills-a8fbfa077e7f)
- 参考：[Four-CLI Convergence](https://pub.towardsai.net/claude-code-vs-codex-cli-vs-gemini-cli-vs-opencode-the-real-differences-after-convergence-fe71401f3f8e)
- 参考：[Codex Browser Use](https://chierhu.medium.com/openai-codexs-browser-use-feature-b7dffa761d45)
- 与 TAD Method 方向独立发展，未来可能交汇但不绑定

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: Epic (via *analyze — 2026-05-03) → EPIC-20260503-cross-model-orchestration.md
