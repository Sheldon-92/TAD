## Learning Entry

- **Date**: 2026-01-07 22:30
- **Agent**: Alex
- **Category**: methodology
- **Status**: pending

### 发现

TAD 的 learnings 系统未被使用，导致：

1. **learnings/ 目录为空**：pending/, pushed/, suggestions/ 都没有实质内容
2. **问题重复出现**：Anthony Advisor 经历多轮迭代，仍有根本性架构问题（模板 vs Agent）
3. **没有根因分析**：问题修复后没有记录"为什么会出现这个问题"
4. **没有预防措施**：同类问题可能再次发生

典型案例：Anthony Advisor
- 第一轮：实现了后端 API，但 UI 没连接
- 第二轮：连接了 UI，但是模板机器人
- 第三轮：还是模板机器人，用户不满意
- 根因：从一开始架构设计就是"模板+状态机"而非"真 Agent"

如果第一轮就记录 learning，可能避免后续迭代。

### 建议

1. **问题发生时强制记录**：

   ```yaml
   learning:
     date: 2026-01-07
     problem: Anthony Advisor 是模板机器人，不是真Agent
     root_cause: 架构用了硬编码模板而非LLM生成
     fix: 重构为 Persona + Context + LLM 架构
     prevention: 设计阶段明确"动态生成 vs 静态模板"决策
   ```

2. **在 Alex 描述中增加**：
   - 每次发现实现与预期不符时，必须创建 learning entry
   - 分析根因，不只是修复表面问题

3. **定期 Review**：
   - 每周/每个 milestone review learnings
   - 提取模式，更新 TAD 流程

4. **Learning 分类**：
   - `architecture`: 架构决策问题
   - `communication`: Alex↔Blake 沟通问题
   - `scope`: 范围理解偏差
   - `quality`: 质量标准不清晰

### 来源

Menu Snap 项目实践：
- Anthony Advisor 多轮迭代仍有根本问题
- `.tad/learnings/` 目录为空
- 同类问题（模板 vs 动态）可能在其他功能重复

### 相关文件

- `.tad/learnings/` - 需要真正使用
- `.tad/agents/agent-a-architect.md` - 需要添加 learning 记录职责

---

> 此记录由 /tad-learn 命令生成
> 待 Human 确认后推送到 TAD 仓库
