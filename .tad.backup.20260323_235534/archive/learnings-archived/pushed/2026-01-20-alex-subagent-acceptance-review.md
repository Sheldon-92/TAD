## Learning Entry

- **Date**: 2026-01-20 14:30
- **Agent**: Human + Claude (协作发现)
- **Category**: workflow / agent-collaboration
- **Status**: pushed

### 发现

Alex 在验收 Blake 完工报告时，默认行为是"纸面验收"——只看文档描述就打勾通过，不会主动调用 subagents 对实际代码进行审查。

**问题表现**：
- Alex 只检查 Blake 提交的文档是否完整
- 不调用 code-reviewer 审查代码质量
- 不调用 ux-expert-reviewer 验证 UX 实现
- 不调用 security-auditor 或 performance-optimizer

**用户发现**：当手动要求 Alex "调用多个专家 agent 进行严格验收"时，Alex 会调用 subagents 进行实际审查，能发现很多有价值的问题。

### 建议

**在 6 个层面强制要求 Alex 验收时必须调用 subagents**：

1. **CLAUDE.md** - 新增 "3.1 Alex 验收规则"
2. **tad-alex.md** - acceptance_protocol 增加 mandatory_review 配置
3. **tad-gate.md** - Gate 4 增加 subagent 审查要求
4. **quality-gate-checklist.md** - Gate 4 新增 "Subagent Review Verification"
5. **gate-execution-guide.md** - Gate 4 说明增加必须调用的 subagents
6. **handoff-b-to-a.md** - 新增 "Alex 验收规则" 提醒

**核心规则**：
- 必须调用：code-reviewer（始终）
- 按需调用：ux-expert-reviewer、security-auditor、performance-optimizer
- 禁止行为：仅做纸面验收

### 来源

menu-snap 项目实践中发现，已在该项目中实施并验证配置有效性

### 相关文件

- `CLAUDE.md` (section 3.1)
- `.claude/commands/tad-alex.md`
- `.claude/commands/tad-gate.md`
- `.tad/gates/quality-gate-checklist.md`
- `.tad/gates/gate-execution-guide.md`
- `.tad/templates/handoff-b-to-a.md`

---

> 此记录由 /tad-learn 命令生成
> 已推送到 TAD 仓库
