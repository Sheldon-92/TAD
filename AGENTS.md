# TAD Framework Rules (Codex CLI)

This file defines TAD rules for Codex CLI. Converted from CLAUDE.md.

## Platform Notes

- **Skill execution**: Self-check mode (read SKILL.md manually instead of calling subagents)
- **Commands**: Use `/prompts:tad_alex`, `/prompts:tad_blake`, etc.
- **Evidence**: Same location `.tad/evidence/reviews/`
- **Skills location**: `.tad/skills/{skill-id}/SKILL.md`

## Command Reference

| TAD Command | Codex Equivalent |
|-------------|------------------|
| /alex | /prompts:tad_alex |
| /blake | /prompts:tad_blake |
| /gate | /prompts:tad_gate |
| /tad-init | /prompts:tad_init |
| /tad-status | /prompts:tad_status |
| /tad-help | /prompts:tad_help |

---

## 1. Handoff 读取规则 ⚠️ CRITICAL

**当读取 `.tad/active/handoffs/` 目录下的任何文件时：**

```
检测到 handoff 文件读取
     ↓
必须立即调用 /prompts:tad_blake 进入执行模式
     ↓
执行实现
     ↓
必须执行 /prompts:tad_gate 3 (Implementation Quality)
     ↓
必须执行 /prompts:tad_gate 4 (Integration Verification)
     ↓
完成交付
```

**禁止行为**:
- ❌ 读取 handoff 后直接开始实现（绕过 Blake 验证）
- ❌ 实现完成后跳过 Gate 3/4 验证
- ❌ 不通过 Blake 就修改代码

**原则**: 有 Handoff → 必须用 Blake → 必须过 Gates

---

## 2. TAD Framework 使用场景

### 必须使用 TAD 的场景

使用 `/prompts:tad_alex` 当：
- 新功能开发（预计修改 >3 个文件）
- 架构变更或技术方案讨论
- 复杂的多步骤需求需要拆解
- 涉及多个模块的重构
- 用户说"帮我设计..."、"我想做一个..."、"如何实现..."

使用 `/prompts:tad_blake` 当：
- 发现 `.tad/active/handoffs/` 中有待执行的 handoff
- Alex 已完成设计并创建了 handoff
- 用户说"开始实现..."、"执行这个设计..."
- 需要并行执行多个独立任务

使用 `/prompts:tad_gate` 当：
- Gate 1: Alex 完成 3-5 轮需求挖掘后，进入设计前
- Gate 2: Alex 完成设计，创建 handoff 前
- Gate 3: Blake 完成实现，提交代码前
- Gate 4: Blake 完成集成，交付用户前

### 可以跳过 TAD 的场景

- 单文件 Bug 修复
- 配置调整（如修改 .env、更新依赖版本）
- 文档更新（README、注释）
- 紧急热修复（生产环境问题）
- 用户明确说"不用 TAD，直接帮我..."

---

## 3. Quality Gates 强制规则

```yaml
规则 0: Alex 写 handoff 前 → 必须进行苏格拉底式提问
规则 1: Alex 创建 handoff → 必须先经过专家审查 → 再执行 Gate 2
规则 2: Blake 完成实现 → 必须执行 Gate 3
规则 3: Blake 完成集成 → 必须执行 Gate 4
规则 4: Gate 不通过 → 阻塞下一步，必须修复
规则 5: Gate 3/4 通过 → 必须检查并记录 project-knowledge（如有新发现）
```

**Gate 是强制检查点，不可跳过。**

---

## 4. Skill Execution (Self-Check Mode)

**Codex CLI 使用 self-check 模式执行技能审查，而非调用 subagents。**

### 执行流程

1. 读取技能定义: `.tad/skills/{skill-id}/SKILL.md`
2. 解析 checklist 项目（按优先级 P0, P1, P2, P3）
3. 针对目标文件执行每项检查
4. 记录每项的 pass/fail
5. 生成证据文件: `.tad/evidence/reviews/{date}-{skill}-{task}.md`
6. P0 项目必须全部通过；P1 根据技能的 max_failures 判定

### 可用技能

| 技能 | SKILL.md 路径 |
|------|--------------|
| Code Review | `.tad/skills/code-review/SKILL.md` |
| Testing | `.tad/skills/testing/SKILL.md` |
| Security Audit | `.tad/skills/security-audit/SKILL.md` |
| Performance | `.tad/skills/performance/SKILL.md` |
| UX Review | `.tad/skills/ux-review/SKILL.md` |
| Architecture | `.tad/skills/architecture/SKILL.md` |
| API Design | `.tad/skills/api-design/SKILL.md` |
| Debugging | `.tad/skills/debugging/SKILL.md` |

---

## 5. Agent 分工边界

### Terminal 隔离规则 ⚠️ CRITICAL

**Alex 和 Blake 必须在不同的 Terminal 运行，禁止在同一个会话中切换角色。**

```yaml
规则: Alex 写完 handoff 后，必须停止并等待人类传递信息给 Blake
      不能在同一个 terminal 调用 /prompts:tad_blake
      人类是 Alex 和 Blake 之间唯一的信息桥梁

流程:
  Terminal 1 (Alex):
    1. 需求分析 → 苏格拉底式提问 → 设计 → 写 handoff
    2. 输出: "Handoff 已创建，请在 Terminal 2 执行 /prompts:tad_blake"
    3. 停止，等待人类反馈

  Terminal 2 (Blake):
    1. 读取 handoff → 执行实现 → Gate 3/4
    2. 输出: "实现完成，请通知 Alex 进行验收"
    3. 停止，等待人类反馈
```

### Alex (Solution Lead) - Terminal 1
- ✅ 需求分析、方案设计、架构规划
- ✅ 创建 handoff 文档
- ✅ 执行 Gate 1 & 2
- ✅ 验收 Blake 的实现
- ❌ 不写实现代码
- ❌ 不执行 Blake 的任务

### Blake (Execution Master) - Terminal 2
- ✅ 代码实现、测试、部署
- ✅ 并行执行多任务
- ✅ 执行 Gate 3 & 4
- ❌ 不独立设计方案
- ❌ 必须基于 Alex 的 handoff

---

## 6. 违规处理

如果违反以上规则（如绕过 Blake、跳过 Gates）：
1. 立即停止当前操作
2. 调用正确的 agent/command
3. 按规范流程重新执行

**这些规则确保 TAD 框架的质量保证体系有效运行。**
