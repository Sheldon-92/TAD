## Learning Entry

- **Date**: 2026-01-07 22:30
- **Agent**: 对话中发现
- **Category**: workflow, agent-collaboration, skill
- **Status**: pushed

### 发现

通过分析 menu-snap 项目的 TAD 执行情况，发现四个关键问题：

1. **流程被绕过** - Claude 直接读取 handoff 文件就开始实现，跳过 Blake 验证和 Gate 3/4
2. **Active Handoffs 状态混乱** - 17 个文件在 active 目录，无法区分 WIP/DONE/BLOCKED
3. **过程开销 vs 价值不匹配** - 小任务走 TAD 太重，大任务需要结构化设计
4. **Skill 不被自动触发** - 描述太抽象，Claude 不知道何时该调用

**核心洞察**: TAD 框架设计得很好，但"可选执行"导致实际上很少被执行。需要从"可选"变为"条件触发"。

### 建议

| 问题 | 建议 |
|------|------|
| 流程被绕过 | 在 CLAUDE.md 添加规则：读取 `.tad/active/handoffs/` 后必须走 Blake 验证 |
| 状态混乱 | Handoff 文件名加状态前缀：`DONE_`、`WIP_`、`BLOCKED_` |
| 开销不匹配 | 定义触发阈值：预计 >1天 或 >3文件 的任务才走 TAD |
| 不自动触发 | 修改 skill 描述，从"是什么"改为"什么时候用" |

### 具体改进方案

#### 1. CLAUDE.md 添加 TAD 触发规则

```markdown
## TAD 框架使用规则

### 必须使用 TAD 的场景
- 新功能开发（预计修改 >3 个文件）
- 架构变更
- 涉及多个模块的重构

### 可以跳过 TAD 的场景
- Bug 修复（单文件）
- 配置调整
- 文档更新
- 紧急热修复

### Handoff 读取规则
当读取 `.tad/active/handoffs/` 目录下的文件时：
1. 必须先调用 /blake 进入执行模式
2. 执行完成后必须调用 /tad-gate 验证
```

#### 2. Handoff 状态前缀规范

```
文件命名: {STATUS}_{AGENT}_{TASK_NAME}.md

STATUS:
- WIP_   : 进行中
- DONE_  : 已完成
- BLOCKED_ : 被阻塞
- (无前缀) : 待开始
```

#### 3. Skill 描述改进示例

```yaml
# Before
tad-alex: /alex Command (Agent A - Solution Lead)

# After
tad-alex: |
  启动设计模式 - 当需要以下工作时激活：
  - 新功能设计（预计 >1天）
  - 架构讨论和方案选择
  - 复杂需求的分析和拆解
```

### 来源

menu-snap 项目实践 - 2026-01-07 TAD 执行情况评估

### 相关文件

- `.tad/learnings/pushed/2026-01-07-handoff-bypass-issue.md`
- `.tad/learnings/pushed/2026-01-07-skill-trigger-conditions.md`
- `.tad/active/handoffs/*.md`
- `.claude/commands/tad-*.md`

---

> 此记录由 /tad-learn 命令生成
> 已推送到 TAD 仓库
