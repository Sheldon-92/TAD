## Learning Entry

- **Date**: 2026-01-07 19:30
- **Agent**: Blake (诊断模式)
- **Category**: skill
- **Status**: pending

### 发现

TAD Skills (tad-alex, tad-blake, tad-gate 等) 在 `available_skills` 中的描述过于抽象，导致 Claude 不知道何时应该主动调用。

当前描述示例：
```
tad-alex: /alex Command (Agent A - Solution Lead)
tad-blake: /blake Command (Agent B - Execution Master)
```

这些描述只说明"是什么"，没有说明"什么时候用"。

**实际案例**: 完成了完整的"三层知识架构"任务（修改 4 个文件，实现 KB→RAG→LLM 架构），但没有调用任何 TAD skill。

### 建议

1. **方案 A**: 在 `.claude/commands/tad-*.md` 文件开头添加触发条件章节：
   ```markdown
   ## 自动触发条件
   当以下情况发生时，Claude 应主动调用此 skill：
   - 用户要求实现新功能（修改 >3 个文件）
   - 用户给出复杂的多步骤需求
   - 需要讨论技术方案或架构
   ```

2. **方案 B**: 修改 available_skills 中的 description，使其更具指导性：
   ```
   tad-alex: 启动设计模式 - 当用户要求实现新功能、需要架构讨论时激活
   ```

3. **方案 C**: 在 CLAUDE.md 全局配置中添加 TAD 触发规则

### 来源

项目实践中发现 - menu-snap 项目，Anthony Advisor 三层架构实现任务

### 相关文件

- `.claude/commands/tad-alex.md`
- `.claude/commands/tad-blake.md`
- 所有 `.claude/commands/tad-*.md` 文件

---

> 此记录由 /tad-learn 命令生成
> 待 Human 确认后推送到 TAD 仓库
