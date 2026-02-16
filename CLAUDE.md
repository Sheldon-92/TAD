# TAD 框架使用规则

> 此文件是路由层：告诉 Claude **什么时候**做什么。
> 具体执行协议在各 agent 命令文件中（/alex, /blake, /gate, /tad-maintain）。

---

## 1. Handoff 读取规则 ⚠️ CRITICAL

**读取 `.tad/active/handoffs/` 下的任何文件时：**

检测到 handoff → 必须调用 /blake → 必须过 Gate 3 + Gate 4

**禁止**:
- ❌ 读取 handoff 后直接实现（绕过 Blake）
- ❌ 实现完成后跳过 Gate 3/4
- ❌ 不通过 Blake 就修改代码

**原则**: 有 Handoff → 必须用 Blake → 必须过 Gates

**豁免**: `/tad-maintain` 的 CHECK/SYNC 模式读取 handoff 做健康检查，不触发此规则。

---

## 2. TAD Framework 使用场景

### 使用 TAD

| 命令 | 触发条件 |
|------|----------|
| `/alex` | 新功能 (>3 文件), 架构变更, 复杂多步骤需求, 多模块重构 |
| `/alex` + `*bug` | Bug found, need quick diagnosis. Alex diagnoses → creates express mini-handoff for Blake |
| `/alex` + `*discuss` | Product direction question, strategy discussion, no handoff needed |
| `/alex` + `*idea` | New idea to capture, not ready for implementation yet |
| `/alex` + `*playground` | 任务涉及前端/UI 设计，需要可视化探索 |
| `/blake` | 有 active handoff, Alex 已创建 handoff, 用户说"开始实现" |
| `/blake` (release) | 常规 patch/minor 版本发布（按 RELEASE.md SOP 执行）|
| `/alex` → `/blake` | Major/breaking 发布（Alex 先创建 release-handoff）|
| `/gate` | Gate 1 (设计前), Gate 2 (handoff 前), Gate 3 (实现后), Gate 4 (验收) |

### 跳过 TAD

- 单文件 Bug 修复、配置调整、文档更新、紧急热修复
- 用户明确说"不用 TAD，直接帮我..."

### Adaptive Complexity

Alex 自动评估复杂度 (Small/Medium/Large/Skip) 并建议流程深度。
**人类做最终决策**，Alex 不可自主决定流程深度。

### Epic/Roadmap

多阶段任务 (需 2+ 个 handoff) → Alex 建议创建 Epic (详见 tad-alex.md)。
**约束**: 同一 Epic 内同时只能有 1 个 Active phase。

---

## 3. Quality Gates 概览

6 条核心规则（详细协议在 /gate 和 agent 命令中）:

规则 0: Alex handoff 前 → 必须苏格拉底式提问 (⚠️ BLOCKING - 未提问直接写 handoff = VIOLATION) (详见 tad-alex.md)
规则 1: Handoff 初稿 → 必须专家审查 + P0 修复 → 再 Gate 2 (详见 tad-alex.md)
规则 2: Blake 实现后 → Gate 3 (详见 tad-gate.md)
规则 3: 集成后 → Gate 4 (详见 tad-gate.md)
规则 4: Gate 不通过 → 阻塞，必须修复
规则 5: Gate 3/4 通过 → 必须包含 Knowledge Assessment（⚠️ BLOCKING - 缺少则 Gate 无效）(详见 tad-gate.md)

**Gate 是强制检查点，不可跳过。**
**禁止**: 仅根据文档描述判定 Gate 4 通过 — 必须调用 subagent 实际验证（禁止纸面验收）。

---

## 4. Terminal 隔离 ⚠️ CRITICAL

Alex = Terminal 1, Blake = Terminal 2。
**人类是 Alex 和 Blake 之间唯一的信息桥梁。**

Alex: 需求分析 → 设计 → 写 handoff → STOP → 等人类传递
Blake: 读 handoff → 实现 → Gate 3/4 → STOP → 等人类反馈

**禁止**:
- ❌ Alex 在同一 terminal 调用 /blake
- ❌ Alex 直接执行实现代码（即使在 Terminal 1 内）
- ❌ Blake 在同一 terminal 调用 /alex
- ❌ Agent 直接与另一 Agent 通信（必须经过人类）

### Alex (Solution Lead) - Terminal 1
- ✅ 需求分析、方案设计、创建 handoff、Gate 1/2/4、验收
- ❌ 不写实现代码、不执行 Blake 的任务

### Blake (Execution Master) - Terminal 2
- ✅ 代码实现、测试、部署、Gate 3
- ❌ 不独立设计、必须基于 handoff

---

## 5. Plan Mode 禁止 ⚠️ CRITICAL

**当 TAD agent（Alex 或 Blake）处于激活状态时，禁止使用 `EnterPlanMode`。**

TAD 自带完整规划流程（苏格拉底提问 → 设计 → 专家审查 → Handoff），与 Claude Code 内置 Plan Mode 不兼容。

**禁止**:
- ❌ Alex 激活时调用 EnterPlanMode（Alex 的 *analyze → *design → *handoff 就是规划流程）
- ❌ Blake 激活时调用 EnterPlanMode（Blake 按 Handoff 执行，不需要额外规划）
- ❌ 任何 TAD 命令执行期间进入 Plan Mode

**如果检测到 Plan Mode 触发倾向**：直接使用 TAD 对应的工作流步骤替代。

---

## 6. 违规处理

违反以上规则时：
1. **立即停止**当前操作
2. **调用正确的** agent/command
3. **按规范流程**从头重新执行

---

## 7. 执行层协议位置

| 协议 | 位置 |
|------|------|
| 苏格拉底提问、专家审查、Epic 管理、配对测试 | `tad-alex.md` |
| Ralph Loop、并行执行 | `tad-blake.md` |
| Gate 详细检查、Knowledge Assessment、Evidence 规则 | `tad-gate.md` |
| 文档维护、Handoff 清理 | `tad-maintain.md` |
| 版本发布 | `tad-alex.md` (策略) + `tad-blake.md` (执行) |

---

## 8. Project Knowledge (Auto-loaded)

Project-specific learnings auto-loaded at startup via @import.
Non-existent files are silently skipped. See .tad/project-knowledge/README.md for format.

> Maintenance: If total knowledge exceeds ~30KB, consolidate per README.md guidelines.

@.tad/project-knowledge/architecture.md
@.tad/project-knowledge/code-quality.md
@.tad/project-knowledge/security.md
@.tad/project-knowledge/testing.md
@.tad/project-knowledge/ux.md
@.tad/project-knowledge/performance.md
@.tad/project-knowledge/api-integration.md
@.tad/project-knowledge/mobile-platform.md
@.tad/project-knowledge/frontend-design.md
