# TAD 框架使用规则

> 路由层：什么时候做什么。执行协议在 /alex, /blake, /gate, /tad-maintain。

## 1. Handoff 读取规则 ⚠️ CRITICAL

读取 `.tad/active/handoffs/` → 必须调用 /blake → 必须过 Gate 3 + Gate 4。
禁止：读取后直接实现、跳过 Gate、不通过 Blake 改代码。
豁免：`/tad-maintain` CHECK/SYNC 模式。
豁免 2：`LITE-*.md`（TAD Lite 通道，见 §2.5）→ 本节规则不适用，含"跳过 Gate/不通过 Blake"禁令。

## 2. 使用场景

| 命令 | 触发条件 |
|------|----------|
| `/alex` | 新功能 (>3 文件), 架构变更, 复杂需求, 多模块重构 |
| `/alex` + `*bug` | Bug 诊断 → express handoff |
| `/alex` + `*discuss` | 产品/策略讨论 (no handoff) |
| `/alex` + `*idea` | 捕获想法 |
| `/alex` + `*learn` | 苏格拉底式学习 |
| `/alex` + `*publish` | GitHub 发布 |
| `/alex` + `*sync` | 同步到注册项目 |
| `/blake` | 有 handoff → 实现；常规发布 |
| `/gate` | Gate 1-4 |
| 深度研究 | 需要持久积累的研究任务 → `*research`（Alex 自动判断 Quick/Standard/Deep 级别） |
| 能力包升级 | Domain Pack 升级为 Capability Pack（升级/重建/capability pack）→ 调用 `/capability-upgrade` 按 5 阶段流程执行 |

跳过 TAD：单文件修复、配置调整、文档更新、用户说"直接帮我"。
Adaptive Complexity：Alex 评估建议，**人类做最终决策**。
Epic：多阶段任务 → Epic，同时只能 1 个 Active phase。
研究工具排除：遇到研究型任务时，不要 invoke `/deep-research` skill 或 spawn generic Agent 做 web search。用 `*research` 统一入口（默认走 NotebookLM 持久知识库）。

### 2.5 Lite 通道（用户显式选择，Alex 不自动推荐）
`/alex-lite` → `/blake-lite`：≤5 文件、非协议契约的小任务，或额度紧张时。契约文件 `LITE-*.md`。
豁免：§1 handoff 规则、§3 规则 0-5 对 Lite 不适用，代之以内置约束——一页纸契约 +
实现后强制 1 个 fresh reviewer（禁自审替代）+ 人两次拍板 + AC 可运行 + 验收即归档。
方向互斥：full `/blake`、`/alex` 一律忽略 `LITE-*.md`；`/blake-lite` 只接受 `LITE-*.md`。
Terminal：lite 下角色切换由**人输入命令**完成（可同 terminal）；agent 仍禁止自行调用另一角色。

## 3. Quality Gates

- 规则 0: Handoff 前必须苏格拉底提问 (⚠️ BLOCKING)
- 规则 1: Handoff 必须专家审查 (min 2) + P0 修复 → Gate 2
- 规则 2: 实现后 → Gate 3 | 规则 3: 集成后 → Gate 4
- 规则 4: Gate 不通过 → 阻塞 | 规则 5: Gate 必须含 Knowledge Assessment (⚠️ BLOCKING)

Gate 是强制检查点。禁止纸面验收 — 必须 subagent 实际验证。

规则 0-5 适用于 full 通道；Lite 通道的等价约束见 §2.5 与 lite skills 内置条款。

## 4. Terminal 隔离 ⚠️ CRITICAL

Alex = Terminal 1, Blake = Terminal 2。**人类是唯一信息桥梁。**
禁止：同 terminal 调用另一 agent、Alex 写代码、Blake 独立设计、跳过人类传递。
TAD agents 禁止使用 EnterPlanMode（TAD 自带规划流程）。

## 4.5 Post-Compact Recovery ⚠️

三层防线：Layer 0 = PreCompact hook 机械快照（自动落盘），Layer 1 = agent 自检，Layer 2 = 用户手动触发。

**Layer 0（机械快照，自动）**：每次压缩前 PreCompact hook 写 `.tad/active/precompact/snapshot-*.md`
（newest-wins，保留最新 5 个；字段：When/Trigger/Session/Git HEAD/Git/Active handoffs/Active epics）；
压缩后 SessionStart(source==compact) 自动注入提醒行。

**每次回复前自检（Layer 1 自检，强制）：**
- **Blake**：我知道当前 handoff 的完整文件路径吗？
- **Alex**：我知道当前工作模式 + 正在处理的 handoff/草稿吗？

**如果答案是 NO（或不确定）：**
1. Read `.tad/active/session-state.md`（如果存在）+ 最新 `.tad/active/precompact/snapshot-*.md`（Layer 0 机械快照）
2. 重新运行 `/blake` 或 `/alex` 重载完整协议
3. 从 session-state.md 的 `Current Position` 继续

如果 self-check 没触发（Layer 1 失效），用户可手动说：
"Read .tad/active/session-state.md" 触发 Layer 2 恢复。

## 5. 违规处理

违规 → 立即停止 → 调用正确 agent → 从头执行。

## 6. 协议位置

| 协议 | 位置 |
|------|------|
| 苏格拉底、专家审查、Epic、配对测试 | `/alex` |
| Ralph Loop、并行执行 | `/blake` |
| Gate 检查、Knowledge Assessment | `/gate` |
| 文档维护、Handoff 清理 | `/tad-maintain` |

## 7. Project Knowledge (Auto-loaded)

@import 自动加载，不存在的文件静默跳过。超 30KB 时整合。

@.tad/project-knowledge/principles.md
@.tad/project-knowledge/patterns/_index.md
@.tad/project-knowledge/testing.md
@.tad/project-knowledge/ux.md
@.tad/project-knowledge/performance.md
@.tad/project-knowledge/api-integration.md
@.tad/project-knowledge/mobile-platform.md
@.tad/project-knowledge/frontend-design.md

## 7.5 Memory Capture Layer

原生 auto-memory 已重定向至 `.tad/memory/`(via settings.local.json,DR-20260712)。
memory = Capture 层(native 自由写);*accept 蒸馏循环将其与 Blake journal 一起锻造进 project-knowledge。
`.tad/memory/` 归 native 管辖:TAD 侧只读。user 型/敏感 memory 已 gitignore(public repo)。
下游项目 opt-in:`bash .tad/hooks/lib/memory-redirect.sh --enable`。

<!-- TAD:PROJECT-CONTENT-BELOW -->
