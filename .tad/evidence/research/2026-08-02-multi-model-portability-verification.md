# 多模型/多平台通用化 — 实证核查（不靠记忆）

> **日期**: 2026-08-02 | **方法**: 本地 CLI 直查 + WebSearch 多轮 | **触发**: 用户计划主力转 Codex + DeepSeek（经 Claude Code），要求机制与知识通用化
> **背景讨论**: lite 通道 review + 优化方向（同日 *discuss 会话）

## 核查结论速览

| 待核查断言 | 核查结果 | 证据 |
|---|---|---|
| "Codex 无 Workflow/hooks 等价物"（2026-06 memory） | ❌ **已过时** | 本地 codex-cli 0.146.0 + 官方 changelog：hooks 引擎 v0.124 起 stable（PostToolUse/UserPromptSubmit/`/hooks` TUI）、plugin 系统 + marketplace（可捆绑 hooks+skills）、sub-agent addressing、goals 默认开启、Starlark exec policy、thread automations、cloud tasks、remote-control、computer use (macOS) |
| SKILL.md 跨平台兼容性 | ✅ **已是开放标准** | Anthropic 2025-12 开源 Agent Skills 规范；OpenAI 数周内为 Codex/ChatGPT 采用同一 SKILL.md 规范；同一 skill 文件夹可 symlink 进 `.claude/skills/` 与 `.agents/skills/`；兼容 Claude Code / Cursor / Gemini CLI / Codex CLI / Antigravity |
| DeepSeek 走 Claude Code | ✅ **官方支持（DeepSeek 侧）** | DeepSeek 官方文档：`ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic`；模型映射 opus→v4-pro、sonnet/haiku→v4-flash。注意：Anthropic 侧仅"容忍"非官方支持；已知怪癖：metadata.user_id 字符限制、/v1/models 预检 404 |
| DeepSeek V4 agent 工作流可靠性 | ⚠️ **有明确短板** | MCP-Atlas 工具调用：Opus 4.7 77.3% vs V4 Pro 73.6%，差距集中在 >4 步连续工具链；V4 Flash 单工具+清晰 schema 可靠、复杂链/判断题/异常恢复弱；**实测案例：DeepSeek 做 planner 时 100% 调用记在自己头上、从未调起 subagent（0 次 spawn）** |
| 本地 Codex 现状 | codex-cli 0.146.0，`~/.codex/` 含 skills/ rules/ memories(sqlite)/ plugins/ prompts/ goals；config.toml 有 notify hook（turn-ended → 用户自装 computer-use client） | 本地直查 |

## 对 TAD 通用化设计的直接影响

1. **U1 大幅简化**：SKILL.md 已是跨厂商标准 → `.claude/skills/` ↔ `.agents/skills/` 的手工逐字节镜像可能整体替换为 symlink 或单目录（需验证 tad.sh 安装路径与下游拷贝对 symlink 的处理；parity 验证器角色转为查 symlink 完整性）。
2. **⚠️ 最重要的新风险 — reviewer spawn 是 DeepSeek 的已证失效点**：TAD lite 的唯一/双防线依赖执行模型主动 spawn 独立 reviewer（L2.5/L3）。DeepSeek 有"planner 从不调 subagent"的公开实测先例。弱模型跑 Blake 时，"禁止自审替代"的 prompt 级禁令可能静默失效。缓解方向：(a) reviewer 步骤机械化验证（Completion 必须含 reviewer 独立产出的 evidence 文件路径，无文件 = 未审）；(b) reviewer 改为人触发的强模型会话（lite 本就"人输命令切角色"，把 reviewer 也做成显式角色切换）；(c) 混编：执行 DeepSeek、审查 Claude/Codex 强档。
3. **>4 步工具链退化** → lite 的紧凑脊柱 + Lite Progress 阶段检查点恰好是弱模型友好形态；full TAD 的长链协议在 DeepSeek 上风险更高。lite-first 的又一论据。
4. **证据链缺口**：智能家居部分单实际由 DeepSeek 执行（用户口述），但 handoff/Completion/RouteDecision 均未记录执行模型身份 → 无法回溯做模型×质量归因。**建议：Completion 与 RouteDecision 增加 `Model:` 字段**（harness + model + 路由方式），成本一行，是 harness×模型实测矩阵的数据基础。
5. Codex 自动化层不但等价且部分更强（marketplace/cloud/remote-control/Starlark policy）→ "自动化层降级为 Claude 专属增强"的旧判断作废；新原则：自动化契约抽象定义（做什么），per-platform 实现（用什么做），两侧各自实现 + parity 检查。

## 追加：本地日志坐实 — DeepSeek 已在生产执行 TAD lite 全链条（2026-08-02 当日核查）

用户口述"Blake 好像都是 DeepSeek"，经 `~/.claude/projects/` session 日志核查坐实：

| Session 日期 | 对应 LITE 单 | 模型 | 轮数 |
|---|---|---|---|
| 2026-08-02 | reminder-reliability（11 AC、F0 路由拦截、reviewer FAIL→PASS 多轮） | **deepseek-v4-flash 100%**（401 轮） | 401 |
| 2026-08-01 | wake-sensitivity（契约审查首轮 FAIL P0=1） | **deepseek-v4-flash 100%**（185 轮） | 185 |
| 2026-07-29/30 | calendar-write、reminder-scheduler | `k3`（API 中转别名，底层模型身份未记录） | ~600 |

**含义（本研究最重要的实证）**：
1. TAD lite 的完整质量机制——R0 路由 F0 判定、契约审查（首轮 FAIL 抓 P0=3）、增量复核（抓 DST 错误）、28 个单元测试、诚实四态失败记录、知识蒸馏——**全部由 v4-flash（最便宜档）执行并产出**，subagent reviewer 由 flash spawn flash 完成多轮。web 报道的"DeepSeek 从不 spawn subagent"未在 TAD 结构下复现。
2. 差异归因假设：TAD lite 把 reviewer spawn 做成**命名的 BLOCKING 协议步骤 + 下游机械检查**（L0.5 grep 契约审查段、L3.5 gate 要求 reviewer verdict、Completion 模板必填 Reviewer 字段）——模型不执行就到不了终态。松散多模型编排（Medium 案例）没有这种强制。= CAAF"断言 + 过程脚手架"论点的生产级复现。
3. **未测量的残留风险**：flash 审 flash = 同模型盲区重叠，抓获率上限未知。建议做一次 model-diversity audit：让 Claude 对一个已 PASS 的 DeepSeek 单重跑 review，测同模型审查漏了什么。
4. `k3` 两单底层模型不可考 = Model 字段缺失的直接代价。字段应记 harness + 模型 + 路由方式（API 别名要展开）。

## 来源（检索日期 2026-08-02）

- DeepSeek 官方: [Using the Anthropic API](https://api-docs.deepseek.com/guides/anthropic_api/) · [Integrate with Claude Code](https://api-docs.deepseek.com/quick_start/agent_integrations/claude_code/) · [awesome-deepseek-agent claude_code.md](https://github.com/deepseek-ai/awesome-deepseek-agent/blob/main/docs/claude_code.md)
- Codex: [官方 changelog](https://developers.openai.com/codex/changelog/) · [Codex CLI in 2026](https://codex.danielvaughan.com/2026/03/27/codex-cli-in-2026-whats-new/) · [April 2026 changelog](https://www.developersdigest.tech/blog/codex-changelog-april-2026) · 本地 codex-cli 0.146.0 直查
- Skills 标准: [AI Agent Skills Guide 2026](https://www.thepromptindex.com/how-to-use-ai-agent-skills-the-complete-guide.html) · [agnostic-claude-skills](https://github.com/channeleden/agnostic-claude-skills/blob/main/docs/guides/agent-skills-for-codex.md)
- DeepSeek 可靠性: [MindStudio V4 Flash vs Sonnet 对比](https://www.mindstudio.ai/blog/deepseek-v4-flash-vs-claude-sonnet-comparison-agents) · [Medium: Run Claude Code on DeepSeek V4 Pro](https://medium.com/@deenuy/run-claude-code-on-deepseek-v4-pro-for-a-fraction-of-the-cost-73d26dd66d23)（subagent 零调用案例）· [NVIDIA 论坛 streaming tool-call issue](https://forums.developer.nvidia.com/t/deepseek-v4-pro-v4-flash-on-nvidia-nim-streaming-tool-calls-do-not-continue-in-claude-code-anthropic-compatible-agent-workflow/368085)
