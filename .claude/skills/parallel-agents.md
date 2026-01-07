# Parallel Agents Skill

> 来源: obra/superpowers，已适配 TAD 框架

## 触发条件

当 Claude 面对多个独立的问题（如多个测试失败、多个子系统故障）时，自动应用此 Skill。

---

## 核心原则

**"并行处理独立问题，而非顺序调查。"**

当有多个不相关的失败时，分配给多个 Agent 并发工作，而不是一个一个解决。

---

## 使用条件

### ✅ 适合使用
- 多个不相关的测试失败
- 不同子系统独立故障
- 问题可以在不需要跨上下文理解的情况下解决

### ❌ 不适合使用
- 失败之间有相互依赖
- 需要全系统理解
- Agent 会干扰共享状态

---

## 并行执行流程

### Step 1: 按独立域分组

```
失败列表:
├── auth.test.ts (3 failures)     → Agent A
├── payment.test.ts (2 failures)  → Agent B
└── user.test.ts (1 failure)      → Agent C
```

### Step 2: 创建聚焦任务

每个任务应该是：
- **聚焦** - 一个清晰的问题域
- **独立** - 自包含的上下文
- **具体** - 明确的期望输出

**好的任务定义**：
```markdown
## 任务: 修复 auth.test.ts

### 范围
- 文件: tests/auth.test.ts
- 失败数: 3

### 期望输出
- 所有 3 个测试通过
- 不修改其他文件
- 提交修复说明
```

**不好的任务定义**：
```markdown
修复所有失败的测试
```

### Step 3: 并行分发

```typescript
// 使用 TAD 的 Task tool 并行调度
Promise.all([
  dispatchAgent({ task: "Fix auth.test.ts", scope: "auth" }),
  dispatchAgent({ task: "Fix payment.test.ts", scope: "payment" }),
  dispatchAgent({ task: "Fix user.test.ts", scope: "user" })
]);
```

### Step 4: 收集和整合

```
收集结果:
├── Agent A: ✅ auth 修复完成
├── Agent B: ✅ payment 修复完成
└── Agent C: ✅ user 修复完成

检查冲突:
- [ ] 是否有文件被多个 Agent 修改？
- [ ] 合并后测试是否全部通过？
```

---

## 任务模板

```markdown
# Parallel Task: [问题域]

## 背景
[简要描述问题]

## 范围限制
- 只处理: [文件/模块列表]
- 不要修改: [其他文件]

## 期望结果
- [ ] [具体验收标准1]
- [ ] [具体验收标准2]

## 上下文
[必要的代码片段或错误信息]
```

---

## 与 TAD 框架的集成

在 TAD 中，并行 Agent 用于：

```
Blake 执行 → 发现多个独立问题 → 并行 Agents 处理 → 整合结果
                                    ↓
                              [ 此 Skill ]
```

**TAD Subagents 并行使用**：
- `debugging-assistant` - 独立 Bug 调查
- `test-runner` - 分文件运行测试
- `code-reviewer` - 并行审查多个模块

---

## 实际案例

### 场景: 6 个失败分布在 3 个文件

```
失败分析:
- agent-tool-abort.test.ts: 2 failures
- permission-check.test.ts: 3 failures
- config-loader.test.ts: 1 failure

分组: 3 个独立域
├── Agent 1 → agent-tool-abort.test.ts
├── Agent 2 → permission-check.test.ts
└── Agent 3 → config-loader.test.ts

结果:
- 顺序处理: ~30 分钟
- 并行处理: ~12 分钟
- 冲突: 0
```

---

## 常见错误

| 错误 | 正确做法 |
|------|----------|
| 给所有 Agent 相同的模糊任务 | 每个 Agent 有具体范围 |
| 忽略潜在冲突 | 整合时检查文件重叠 |
| 并行处理有依赖的问题 | 只并行处理独立问题 |
| 不验证整合结果 | 合并后运行完整测试 |

---

## 关键心态

> "并行不是为了更快，而是为了在问题独立时避免不必要的串行等待。"

**并行的价值**：
- 更快完成独立任务
- 避免上下文切换开销
- 充分利用可用资源

---

*此 Skill 指导 Claude 在面对多个独立问题时采用并行策略。*
