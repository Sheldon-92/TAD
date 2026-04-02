## Learning Entry

- **Date**: 2026-01-20 14:40
- **Agent**: Blake
- **Category**: workflow, checkpoint
- **Status**: pushed

### 发现

在 TAD 框架中，output-format 模板虽然存在于 `.tad/templates/output-formats/`，但缺乏明确的触发机制和证据存储规范。

**问题表现**:
1. Subagent 输出格式不一致，有时不按模板输出
2. Gate 检查无法验证审查是否真正执行（纸面验收问题）
3. 审查证据缺乏可追溯性，难以回溯历史审查
4. 12 个 output-format 模板使用率低

### 建议

建立完整的 **Template Trigger and Storage System**：

#### 1. 配置层 (config.yaml)
新增 `template_triggers` 配置节，定义：
- MANDATORY 模板：Gate 3 (testing-review) 和 Gate 4 (security-review, performance-review)
- RECOMMENDED 模板：code-review, refactoring-review
- SELF-USE 模板：Alex/Blake 自用参考

#### 2. 存储层
统一存储到 `.tad/evidence/reviews/` 目录，使用命名规范：
```
{YYYY-MM-DD}-{type}-{brief-description}.md
```

#### 3. 强制层 (Gate 检查)
- Gate 3 通过条件：必须有 testing-review 证据文件
- Gate 4 通过条件：必须有 security-review 和 performance-review 证据文件
- 无证据文件 = Gate 无法通过（Hard Block）

#### 4. 工作流程
```
Blake 调用 Subagent → Subagent 读取 Template → Subagent 输出 Evidence → Gate 检查 Evidence
```

### 来源

项目实践中发现的问题 + 用户设计的解决方案

### 实现文件

已实现的文件变更：
- `.tad/config.yaml` - 新增 template_triggers 配置（~90行）
- `.tad/gates/gate-execution-guide.md` - 更新 Gate 3/4 要求
- `.claude/commands/tad-gate.md` - 更新 Gate 检查逻辑
- `CLAUDE.md` - 新增 "4. Output Template Rules" 章节
- `.tad/evidence/reviews/` - 新建证据存储目录

### 价值

1. **确保审查质量**：通过证据文件强制验证审查执行
2. **可追溯性**：历史审查记录可查
3. **标准化输出**：Subagent 输出格式统一
4. **模板利用率提升**：12 个模板有了明确的使用场景

---

> 此记录由 /tad-learn 命令生成
> 已推送到 TAD 仓库
