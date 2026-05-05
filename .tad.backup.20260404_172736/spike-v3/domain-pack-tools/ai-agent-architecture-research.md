# AI Agent Architecture — 研究成果

**日期**: 2026-04-02
**来源**: Claude Code 源码分析 + OpenClaw 项目分析 + Anthropic API 文档 + 主流框架对比
**用途**: ai-agent-architecture Domain Pack 的设计基础

---

## 核心发现：三层可靠性模型

所有生产级 agent 系统都用三层约束：

```
Layer 1: Prompt 引导（最弱 — 可被 rationalize 绕过）
Layer 2: Hook/中间件执行（中等 — 框架层强制）
Layer 3: 架构约束（最强 — 设计上不可能违反）
```

### 不同环境的实现

| 层 | Claude Code | OpenClaw | Anthropic API | NeMo Guardrails |
|---|---|---|---|---|
| Prompt | SKILL.md, CLAUDE.md | AGENTS.md + SOUL.md | system prompt | (N/A) |
| Hook/中间件 | settings.json hooks (PreToolUse/PostToolUse) | HEARTBEAT.md 规则 + openclaw.json safeBins | 应用层中间件代码 | Input/Output/Execution rails |
| 架构约束 | permissions.deny + terminal 隔离 | Agent 模板结构 | tool_use schema + strict: true | Colang DSL |

---

## 各环境详细分析

### Claude Code（最佳实践参考）

**来源**: .tad/spike-v3/README.md + 源码分析

1. **Tool 系统**: 每个工具声明 `isConcurrencySafe()`, `isReadOnly()`, `isDestructive()` — 框架自动分批执行
2. **Hook 系统**: 26 种事件，4 种类型（command/prompt/agent/http）。PreToolUse 可 BLOCK（exit 2）
3. **Enforcement 优先级**: `permissions.deny > hooks > allow > user prompt`（deny 不可被 hook 覆盖）
4. **Coordinator 模式**: Research → Synthesis → Implementation → Verification 四阶段
5. **记忆系统**: LLM-driven selection（Sonnet sidequery 选 ≤5 条相关记忆）
6. **Context 管理**: 4 种 compaction 策略（auto/session memory/micro/partial）

### OpenClaw（用户当前项目）

**来源**: /Users/sheldonzhao/01-on progress programs/my-openclaw-agents/

1. **架构**: Monorepo，每个 agent = workspace/（AGENTS.md + SOUL.md + HEARTBEAT.md）
2. **哲学**: Human-in-the-loop — agent 做 80% 搜集/整理，人做 20% 判断/创意
3. **Enforcement 机制**:
   - SOUL.md: `⚠️ MANDATORY` 模板格式（prompt-only，同 TAD 的 MUST 一样弱）
   - HEARTBEAT.md: "NEVER loop" 规则（来自 ¥74 成本事故教训）
   - AGENTS.md: SQL 参数化查询强制 + 禁用列名清单
   - openclaw.json: `safeBins` 可执行文件白名单
4. **缺失**: 没有类似 Claude Code 的 Hook 系统。所有约束都是 prompt 级别
5. **好模式**: 
   - 错误跳过继续（graceful degradation）
   - 单次执行架构（防止无限循环）
   - Changelog 协议（memory/YYYY-MM-DD-{slug}.md）
   - State file 作为 source of truth（不依赖 DB timestamp）

### Anthropic API（Menu Snap 等 app 会用）

1. **Function calling / tool_use**: 
   - `strict: true` 确保 AI 输出严格匹配 schema
   - `input_schema` 定义参数类型 — AI 不能调未定义的工具
   - `client.messages.parse()` 自动验证响应
2. **Tool 文档 = 合约**: "Purpose line + 示例 + 严格类型，不留猜测空间"
3. **已知风险**: AI 编造不存在的工具/参数、无限循环、缺失上下文、过时记忆
4. **应用层验证必须**: API 只做 schema 验证，语义验证（参数组合是否合理）需要应用代码

### 主流框架对比

| 框架 | 核心 enforcement | 特点 |
|------|-----------------|------|
| LangGraph | 状态图节点条件 + 状态持久化 | 最适合有状态工作流 + 崩溃恢复 |
| CrewAI | 角色定义 + 记忆层级 + 任务委托 | 最快原型（小团队友好） |
| AutoGen | 终止条件 + 自定义验证器 | 最强自治性但风险最大 |
| NeMo Guardrails | Input/Output/Execution 三层 rails | 最强安全（GPU 加速，50-150ms）|

### 关键数字

> "10 步 agent 在 85% 准确率下失败率 80%。3 步 agent 同样准确率失败率只有 39%。"

→ **减少 agent 步骤数比提高单步准确率更有效**

---

## 8 个通用 Agent 架构模式

不绑定任何特定环境，适用于所有 agent 系统：

### 1. 三层验证门控
```
Schema 层: 结构正确吗？（类型、必填字段、值域）
语义层:    逻辑正确吗？（参数组合合理吗？上下文匹配吗？）
权限层:    允许执行吗？（当前状态是否允许这个操作？）
```

### 2. 不可变约束设计
- 关键行为定义为不可协商的规则（不是建议）
- 约束在系统层执行（hook/deny/schema），不靠 agent 自律
- OpenClaw 的 MANDATORY 模板 + Claude Code 的 permissions.deny

### 3. 人在回路边界
- 定义不可逆操作阈值（按领域不同）
- 超过阈值自动升级到人类审批
- 追踪人类 approve/reject 来优化阈值

### 4. 错误反馈设计
- 具体（"这个参数错了" 不是 "error"）
- 可操作（"试试这个参数" 不是 "请重试"）
- 防无限循环（3 次同类错误触发 circuit breaker）

### 5. 幂等操作模型
- 多步操作支持从任意步恢复
- 每步有状态快照（crash recovery）
- 执行前 dedup 检查（防重复副作用）

### 6. 纵深防御
- 多层独立约束，优先级明确
- 硬约束不可被软约束覆盖（deny > hook > prompt）
- 没有单点故障

### 7. 工具文档即合约
- Purpose + 示例 + 严格参数类型
- 错误条件和升级路径文档化
- 让 AI 不可能幻觉出不存在的工具（strict schema + validation）

### 8. 生产环境检查清单
- 状态持久化方案（用什么工具？）
- 错误通信计划（怎么告诉 agent 出了什么错？）
- 人工升级流程（什么时候、怎么升级？）
- 可观测性（在哪记录关键决策？）
- 故障模式测试（某个服务挂了会怎样？）

---

## 对 Domain Pack 设计的建议

ai-agent-architecture pack 应该教的不是"怎么写 AGENTS.md"，而是"**怎么在任何环境中构建可靠的 agent**"。

Capabilities 应围绕上述 8 个模式设计，而不是围绕特定框架。每个 capability 的产出是**设计决策文档 + 架构图**，适用于用户选择的任何运行环境（Claude Code / OpenClaw / 自建）。
