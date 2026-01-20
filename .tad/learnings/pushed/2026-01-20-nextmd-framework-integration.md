## Learning Entry

- **Date**: 2026-01-20 17:15
- **Agent**: Human + Claude (协作设计)
- **Category**: workflow
- **Status**: pushed

### 发现

**问题: NEXT.md 规则放在全局配置中的问题**

1. **范围过广**: 全局 `~/.claude/CLAUDE.md` 中的 NEXT.md 强制规则会应用到所有项目，包括非软件开发项目
2. **规则重复**: TAD 框架内的 `doc-organization.md` Skill 已有 NEXT.md 规则，与全局规则重复
3. **触发点不强制**: TAD 内的规则是 `recommended`，不是阻塞点
4. **识别逻辑**: 如果项目有 CLAUDE.md（项目级配置），那一定是 TAD 项目，应该由框架内部管理

### 建议

**解决方案：将 NEXT.md 规则从全局配置迁移到 TAD 框架内部触发点**

1. **全局配置精简**
   - 移除 NEXT.md 强制规则
   - 只保留语言偏好、工作习惯等通用规则

2. **TAD 框架内集成触发点**

   | 触发点 | Agent | 动作 |
   |--------|-------|------|
   | Gate 3 通过后 | Blake | 标记实现任务完成，添加集成任务 |
   | Gate 4 通过后 | Blake | 标记交付任务完成，添加反馈任务 |
   | *handoff 创建后 | Alex | 添加 Blake 的实现任务 |
   | *accept 执行时 | Alex | 标记完成，添加后续任务 |
   | *exit 退出前 | Both | 检查 NEXT.md 是否已更新（阻塞） |

3. **阻塞机制**
   - `*exit` 命令前必须检查 NEXT.md 是否已更新
   - Gate 3/4 通过后自动触发 NEXT.md 更新

4. **规则内容**
   - 格式：English only（避免 UTF-8 CLI bug）
   - 大小控制：500 行以内
   - 归档：超限时移到 docs/HISTORY.md

### 来源

menu-snap 项目实践中发现：全局规则会影响所有项目，但 NEXT.md 只适用于软件开发项目

### 相关文件

- `~/.claude/CLAUDE.md` (精简后的全局配置)
- `.claude/commands/tad-blake.md` (添加 next_md_rules, exit_protocol)
- `.claude/commands/tad-alex.md` (添加 next_md_rules, exit_protocol, accept_command.step4)
- `.claude/commands/tad-gate.md` (Gate 3/4 Post_Pass_Actions)
- `.claude/skills/doc-organization.md` (已有规则，作为参考)

### 实施要点

**设计原则：**
- 全局规则只放真正通用的内容
- 框架特定规则嵌入框架内部触发点
- 触发点必须是阻塞点才能确保执行

**识别逻辑：**
- 有项目级 CLAUDE.md → TAD 项目 → 框架内部规则生效
- 无项目级 CLAUDE.md → 非 TAD 项目 → 不强制 NEXT.md

---

> 此记录由 /tad-learn 命令生成
> 待 Human 确认后推送到 TAD 仓库
