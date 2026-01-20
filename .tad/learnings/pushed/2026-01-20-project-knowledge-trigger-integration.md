## Learning Entry

- **Date**: 2026-01-20
- **Agent**: Alex (during acceptance review)
- **Category**: workflow
- **Status**: pushed

### 发现

Project Knowledge 的触发机制在 `.tad/project-knowledge/README.md` 中定义了：
- Gate 3 Pass → Blake 记录实现发现
- *review Complete → Alex 记录审查洞察

但这个触发定义从未被集成到实际的强制执行流程中：
- `quality-gate-checklist.md` 的 Gate 3/4 checklist 没有相关 checkbox
- `gate-execution-guide.md` 没有 Knowledge Capture Step
- `CLAUDE.md` 的强制规则没有提及
- `/gate` 命令的 Gate 4 部分没有 Post_Pass_Actions
- `/blake` 的 completion_protocol 没有 knowledge 步骤

这导致 Agent 在执行 Gate 时不会被触发去记录 project knowledge，即使 README 声称"Knowledge capture is part of Gate 3 and *review, not a separate step"。

### 建议

**TAD 框架设计原则补充**：

1. **触发机制必须集成到强制执行点**
   - 任何需要 Agent 执行的动作，必须在以下至少一个位置定义：
     - `CLAUDE.md` 强制规则
     - 对应命令的 yaml 流程定义
     - Gate checklist 的 checkbox
   - 仅在 README/文档中声明意图是不够的

2. **检查清单**：新增触发机制时，确保更新：
   ```
   [ ] CLAUDE.md 强制规则
   [ ] quality-gate-checklist.md (如果是 Gate 相关)
   [ ] gate-execution-guide.md (如果是 Gate 相关)
   [ ] tad-gate.md Post_Pass_Actions
   [ ] tad-alex.md 或 tad-blake.md 的流程定义
   ```

3. **文档断层检测**：定期审查是否有"声明了意图但未集成执行"的情况

### 来源

- 项目实践：完成 User System 验收后，未触发 project-knowledge 记录
- 用户反馈：指出应该是方法论定义问题，而非"习惯"问题
- 审计结果：发现 README 定义与实际执行流程断层

### 相关文件

- `.tad/project-knowledge/README.md` - 定义了触发点但未被集成
- `.tad/gates/quality-gate-checklist.md` - 已修复，添加了 Knowledge Capture checkbox
- `.tad/gates/gate-execution-guide.md` - 已修复，添加了 Knowledge Capture Step
- `CLAUDE.md` - 已修复，添加了规则 5
- `.claude/commands/tad-gate.md` - 已修复，Gate 4 添加了 knowledge_capture
- `.claude/commands/tad-blake.md` - 已修复，completion_protocol 添加了 step3

### 修复内容

本次已完成的修复：
1. `CLAUDE.md` 添加规则 5 和 "Project Knowledge 记录规则" 子章节
2. `quality-gate-checklist.md` Gate 3 & 4 添加 "Knowledge Capture (MANDATORY)" 检查项
3. `gate-execution-guide.md` Gate 3 & 4 添加 "Knowledge Capture Step"
4. `tad-gate.md` Gate 4 Post_Pass_Actions 添加 knowledge_capture
5. `tad-blake.md` completion_protocol 添加 step3 和 knowledge_capture

---

> 此记录由 /tad-learn 命令生成
> 已推送到 TAD 仓库
