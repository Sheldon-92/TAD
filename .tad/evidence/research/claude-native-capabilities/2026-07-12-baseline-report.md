# 2026年7月 Claude Code 与生态系统原生能力景观分析报告

## 1. 模型层级分析：Fable 5 与 Mythos 5 的演进

2026年下半年，Anthropic 正式确立了 Mythos 级（Mythos-class）模型层级。根据 2026 年 6 月发布并于 7 月完成重新部署的规格，Fable 5 与 Mythos 5 在复杂工程任务与长程推理能力上显著超越了前代 Opus 4.x 系列。

### 模型规格与访问架构对比

| 特性 | Claude Fable 5 | Claude Mythos 5 |
| :--- | :--- | :--- |
| **定位** | 经过安全调优的 Mythos 级通用模型 | 原生 Mythos 级模型，解除特定领域限制 |
| **访问权限** | 全球可用（API 及 Pro/Max 订阅计划） | 仅限 Project Glasswing 合作伙伴 |
| **安全逻辑** | 触发安全敏感话题时回退至 Opus 4.8 | 安全限制大幅放宽，专注网络防御与科研 |
| **Effort 逻辑** | 非交互式命令受“模型默认 Effort 保持”约束 | 支持全级别推理（含 Max 与 Ultracode） |
| **定价 (每百万 Token)** | 输入 $10 / 输出 $50 | 输入 $10 / 输出 $50 |

### 战略部署与效能指标
作为架构师，必须识别 Fable 5 的保守安全策略：其安全分类器在大约 5% 的会话中会触发误报（False Positives），此时系统会自动平滑回退至 Opus 4.8。

在软件工程实测中，Fable 5 展现了极高的自主性：
*   **超大规模迁移：** **Stripe** 报告称，在处理其包含 **5000 万行代码的 Ruby 代码库**迁移任务时，Fable 5 仅用 1 天便完成了人类团队需耗时两个月的迁移工作。
*   **代码质量基准：** 在 **Cognition** 的 **FrontierCode** 评测中，Fable 5 在中等 Effort 等级下获得了最高分，证明其在处理陌生工具与长程推理任务时的优越性。

---

## 2. 自动记忆系统 (Auto-Memory) 架构

Claude Code 通过多层级的持久化记忆机制，实现了跨会话的架构决策与项目背景对齐。

### 存储路径与层级结构
1.  **User (全局):** `~/.claude/CLAUDE.md`，存储跨项目的个人偏好。
2.  **Project (项目级):** 项目根目录或 `.claude/CLAUDE.md`（推荐，以保持项目根目录整洁）。
3.  **Local (本地级):** `CLAUDE.local.md`，用于存放不入库的私有配置。

### MEMORY.md 自我维护机制
对于开启了自动记忆的任务，系统维护一个 `MEMORY.md` 文件：
*   **内容限制：** 系统仅会自动读取 `MEMORY.md` 的前 200 行或 25KB 内容。
*   **自动策展 (Curation)：** 当文件超过上述限制时，系统提示词明确指示模型必须执行“自我策展”，对旧记忆进行清理、缩减和摘要化，以维持上下文的高效性。

### 类型化记忆 (Typed Memories)
子代理通过 `memory` 字段在跨会话学习中应用不同作用域：
*   **User:** 存储于 `~/.claude/agent-memory/`，实现经验跨项目共享。
*   **Project:** 存储于 `.claude/agent-memory/`，通过版本控制在团队间共享。
*   **Local:** 存储于 `.claude/agent-memory-local/`，知识仅限于当前副本。

---

## 3. 原生技能系统 (Skill System)

技能系统以 `SKILL.md` 为核心，允许通过 Markdown 定义扩展能力。

### 技能扩展与触发机制
*   **自动发现：** 技能描述（Description）默认加载至上下文。若任务匹配描述，模型自动调用技能内容。
*   **热加载：** 自 **v2.1.152** 起，`/reload-skills` 命令允许在不重启会话的情况下重新扫描技能目录。

### Frontmatter 字段效能优化
在 `SKILL.md` 的 Frontmatter 中，`disable-model-invocation: true` 是优化上下文成本的关键：
*   **参考型技能 (Reference Skills):** 用于提供文档或风格指南。若未禁用调用，其内容会持续占用 Token 成本。
*   **动作型技能 (Action Skills):** 通过设置该字段，技能对模型不可见，仅在用户显式执行 `/skill-name` 时加载，实现“零成本”待命。

---

## 4. 子代理 (Subagents) 与代理团队 (Agent Teams)

### 子代理架构与限制
子代理配置存储于 `.claude/agents/`。
*   **工作树隔离 (isolation: worktree):** 默认情况下从 **default branch**（而非当前 HEAD）切出临时分支，确保主 checkout 不受干扰。
*   **嵌套与硬限制：** 支持最高 5 层嵌套。关键约束是 **Depth 5 的代理将失去 `Agent` 工具能力**，无法进一步生成子代理。

### 实验性代理团队 (Agent Teams)
需设置 `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` 环境变量以启用团队目录写入与协作功能。
*   **通信协议：** 领队（Lead）与队员（Teammates）通过 `SendMessage` 通信。
*   **分叉指令 (/fork)：** > `/fork` 命令创建一个继承当前所有对话历史、系统提示及权限的子代理副本，而非从零开始启动 fresh context。

---

## 5. 原生代码审查与验证能力

### 代码审查命令集
Claude 提供基于 Effort 等级的审查能力：
*   **Effort Levels:** 覆盖 `low` 到 `ultra`。
*   **Ultrareview:** 仅在 `ultra` 等级触发，调用云端多代理联合评审（Cloud multi-agent review），利用多模型共识识别复杂漏洞。
*   **指令：** `/code-review`、`/security-review` 及自 v2.1.154 起独立的 `/simplify`（专注于重构而非找 Bug）。

### 验证能力 (/verify)
`/verify` 技能通过实际构建并 **驱动 (Drive)** 应用运行，通过观察实时应用行为而非仅依赖静态测试脚本来确认变更的有效性。

---

## 6. 交互流与计划模式 (Plan Mode)

`/plan` 模式强制执行“先分析后编辑”流程：
*   **决策介入：** 系统在关键逻辑变更点调用 `AskUserQuestion` 工具，确保模型意图与人类预期同步。
*   **专注视图 (Focus View):** 通过 **Ctrl+I** 切换。自 **v2.1.198** 起，该视图会实时计数当前轮次启动的子代理数量，并将后台任务通知合并显示。

---

## 7. 自动化：云端代理、循环与钩子 (Hooks)

### 事件钩子执行逻辑
钩子脚本（如 `PreToolUse`、`PostToolUse`）通过 **JSON 格式（via stdin）** 接收输入，这对编写审计或验证脚本至关重要。

### 质量门禁与退出码
**Exit Code 2** 的特殊处理：
*   若钩子脚本返回退出码 2，系统不会简单终止，而是将其作为 **反馈信息发送给模型并保持代理继续工作**。这允许代理根据拦截结果尝试不同的技术路径。

---

## 8. 生态对比：Codex CLI 与 AGENTS.md 规范

Claude Code 在私有 `.claude/` 结构之外，积极兼容由 **Agentic AI Foundation**（隶属于 Linux 基金会）管理的 `AGENTS.md` 开源规范。

| 特性 | Claude 原生 (.claude/agents/) | 通用 AGENTS.md |
| :--- | :--- | :--- |
| **指令优先级** | **距离当前工作目录最近**的文件获胜 | **距离被编辑文件最近**的文件获胜 |
| **受众定位** | 专注于机器可读的结构化配置 | 平衡机器指令与人类 README 的可读性 |
| **生态互操作** | 深度集成于 Anthropic 原生工具链 | 已被超过 6 万个开源项目（如 OpenAI Codex）采用 |

---

## 9. 路线图回顾：核心特性发布时刻表

*   [x] **2026-07-01:** Claude Fable 5 与 Mythos 5 重新部署，恢复全球访问。
*   [x] **2026-06-23:** 规则变更：Pro/Max 订阅用户需消耗使用点数访问 Fable 5。
*   [x] **2026-06-09:** Claude Fable 5 与 Mythos 5 正式发布，确立 Mythos 级地位。
*   [x] **v2.1.198:** 移除交互式 `/agents` 向导，转向 `.claude/agents/` 直接编辑；Agent SDK 默认禁用内置代理（`CLAUDE_AGENT_SDK_DISABLE_BUILTIN_AGENTS`）。
*   [x] **v2.1.172:** 首次实现子代理 5 层嵌套支持。
*   [x] **v2.1.152:** 引入 `/reload-skills` 动态热加载命令。
*   [x] **v2.1.98:** 引入 `/advisor` 工具，支持双模型引导模式。
*   [x] **2026-04-xx:** 启动 Project Glasswing，向美国政府及基础设施提供商开放 Mythos Preview。