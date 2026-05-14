# Epic: Goal-Driven Research Director

**Epic ID**: EPIC-20260504-goal-driven-research
**Created**: 2026-05-04
**Owner**: Alex
**Promoted from**: IDEA-20260504-goal-driven-research-director

---

## Objective
让 Alex 从"被动执行研究"升级为"业务目标驱动的自主研究总监"。Alex 知道用户的业务目标、自主判断该研究什么、自主发起研究、追踪研究对决策的影响。同时解决跨项目 notebook 管理的 REGISTRY 差距问题（Phase 3 E2E 发现 29 vs 1）。

## Success Criteria
- [ ] Alex 能读取项目的业务目标定义，并据此判断"当前缺少什么研究"
- [ ] Alex 能自主提出研究计划（"为了目标 X，我建议研究 A、B、C"），用户确认后执行
- [ ] 跨项目 notebook 管理：交互式 sync 向导让用户一次性把云端 notebook 分配到正确项目
- [ ] 研究→决策追踪：每个决策可追溯到哪个 notebook/report 提供了依据
- [ ] research-notebook SKILL 支持 `--caller` flag 实现工具层能力围栏

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Cross-Project Sync Wizard (方案 C) | ⏭️ Skipped | — | 用户决定手动补 REGISTRY，跳过向导基础设施。Phase 1 包含手动注册步骤。 |
| 1 | Business Objective Definition | ✅ Done | HANDOFF-20260504-goal-driven-phase1 | OBJECTIVES.md OKR template + Alex STEP 3.8 gap analysis + 内容副业 REGISTRY 11 notebooks + OBJECTIVES O1/O2 |
| 2 | Autonomous Research Strategy | ✅ Done | HANDOFF-20260504-autonomous-research-phase2 | *research-plan command (5-step protocol: read→plan→confirm→execute→update OBJECTIVES). Validated: menu-snap research-plan-2026-05-04.md + 4 notebooks generated + OBJECTIVES KR research status tracked. |
| 3 | Research-Decision Loop | ⬚ Planned | — | 研究→决策追踪 + 决策→行动→结果反哺 + `--caller` flag |

### Phase Dependencies
Phase 0 独立（解决基础设施问题）。Phase 1→2→3 顺序依赖。

---

## Context for Next Phase

### Design Inputs (from Phase 3 E2E + backend-architect)

**跨项目 REGISTRY 差距 (Phase 0 scope):**
- 内容副业 REGISTRY 只有 1 个 notebook，云端有 10 个相关的
- 推荐方案 C：`*research-notebook sync` 获取云端列表 → AskUserQuestion 多选 → "这些属于哪个项目？" → 更新 REGISTRY
- 命名约定 (方案 A) 作为快速补丁可先行

**`--caller` flag (Phase 3 scope):**
- backend-architect P2 建议：在 research-notebook SKILL 内部加 `--caller {alex|blake}` 参数
- 替代当前"Blake SKILL allowlist"方案 → 工具层面强制，不依赖 Blake 自律
- 实现方式：SKILL 协议在每个命令入口检查 caller，forbidden 命令对 blake caller 直接拒绝

**业务目标机制 (Phase 1 scope):**
- 目标定义文件：OBJECTIVES.md（独立于 ROADMAP.md — ROADMAP 是方向，OBJECTIVES 是可量化目标）
- 格式建议：OKR 风格 — Objective (定性) + Key Results (定量)
- Alex 读取时机：STEP 3.8 激活扫描（已有研究态势）扩展为"研究态势 + 目标对齐"

**自主研究发起 (Phase 2 scope):**
- Alex 对比 OBJECTIVES.md 目标 vs REGISTRY 已有研究 → 识别"目标 X 缺少关于 Y 的研究"
- AskUserQuestion 确认后自主执行 `*research-notebook research --mode deep`
- 用 `*research-notebook report` 产出目标导向的研究报告
- 研究完成后 `ingest` 回 notebook 形成闭环

**Research-Decision Loop (Phase 3 scope):**
- 在 handoff §11 Decision Summary 追加 "Research Source" 列（Phase 2 已部分实现 A5）
- 新增：决策→行动→结果追踪（OBJECTIVES.md Key Results 更新）
- Alex *accept 时检查："这个实现是否推进了某个 Key Result？如果是，更新 OBJECTIVES.md"

### Decisions Made So Far
- 跨项目方案：方案 C (交互式 sync 向导) + 方案 A (命名约定) 作为快速补丁
- Alex 自主性：主动提出 + 用户确认（不完全自主）
- 目标格式：OKR 风格 (Objective + Key Results)
- `--caller` flag：Phase 3 实现（与 research-decision loop 一起）

---

## Notes
- 前置完成：EPIC-20260504-notebooklm-research-director (4/4 phases) 提供了全部工具基础
- 本 Epic 是"战略层"，前一个 Epic 是"工具层"
- E2E 发现的 `source list --json` 必要性、language artifact-only 限制等已记入 architecture.md
