## Learning Entry

- **Date**: 2026-01-20 15:30
- **Agent**: Human + Claude (协作发现)
- **Category**: skill
- **Status**: pending

### 发现

**问题**：配置了大量 Skills（40+个）在 `.claude/skills/` 目录，但在实际执行任务时，这些 Skills 从未被主动读取和参考。

**表现**：
- Alex 调用 code-reviewer subagent 时，不会先读取 code-review Skill
- Skills 只是"躺在目录里的文档"，没有被融入工作流
- Subagents 执行时没有参考对应的 checklist 和 best practices

**根本原因**：
- Claude Code 的 Skills 机制只是基于 description 做语义匹配
- 没有强制规则要求在调用 subagent 前先读取对应 Skill
- Skills 和 Subagents 之间缺乏映射关系

### 建议

**在 3 个层面建立 Skills 参考规则：**

1. **CLAUDE.md** - 新增 "Skills 参考规则" 章节
   - Subagent ↔ Skill 映射表
   - Scene ↔ Skill 映射表
   - 强制执行规则（调用 subagent 前必须先 Read 对应 Skill）
   - 正确/错误流程示例

2. **tad-alex.md** - 在 mandatory_review 部分
   - 每个 subagent 配置添加 `skill_path` 字段
   - 添加 `pre_action` 要求先读取 Skill
   - 添加 `skill_reading_rule` 明确违规后果
   - 添加 `correct_flow_example` 展示正确流程

3. **Skills 格式标准化**
   - 目录结构：`.claude/skills/{skill-name}/SKILL.md`
   - 必须包含 frontmatter（name, description）
   - 必须包含 TL;DR checklist
   - 必须包含 output format

**核心规则**：
```
调用 subagent 前 → 必须先 Read 对应 Skill 文件
Skill 中有 checklist → 执行时必须逐项检查
Skill 中有 output format → 输出必须符合格式
```

### 来源

menu-snap 项目实践中发现，已在该项目中实施并验证有效

### 相关文件

- `CLAUDE.md` (section 3.2)
- `.claude/commands/tad-alex.md` (mandatory_review.skill_reading_rule)
- `.claude/skills/code-review/SKILL.md` (标准格式示例)

### 附加建议：Skills 精简

当前 40+ Skills 过多，建议：
1. 分析 Skills 使用频率
2. 保留核心 Skills（~10个）
3. 合并相似 Skills
4. 删除项目无关的 Skills

---

> 此记录由 /tad-learn 命令生成
> 待 Human 确认后推送到 TAD 仓库
