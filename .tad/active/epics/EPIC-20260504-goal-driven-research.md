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

### Phase 4-6 Success Criteria (Research Execution Quality — added 2026-05-31)
- [ ] `*research-plan` 按复杂度自适应触发动态种子/对抗 challenge（effort-scaling 阶梯,不再默认跳过）
- [ ] notebook 超期自动 → 💤 dormant（非阻塞状态 hook）；`ai-agent-tutorials`(1 源空壳)归档
- [ ] dogfood 证据: 重跑 tad-evolution-research，trace 显示动态种子真触发（`seed_origin` ≥1）+ 对抗 challenge 跑了
- [ ] persona 视角种子化: 种子问题前生成 3-4 stakeholder 视角，每视角出子问题
- [ ] 5 维 LLM-judge 质量鲁棒（复用 Codex+Gemini）跑在 findings 上，低分警告（advisory 不阻塞）
- [ ] *analyze research-gate 强化: "决策依赖外部信息"时主动建议研究（对的时刻触发）
- [ ] Phase 4-6 改动经 dogfood 验证后 *sync 到 14 下游项目

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Cross-Project Sync Wizard (方案 C) | ⏭️ Skipped | — | 用户决定手动补 REGISTRY，跳过向导基础设施。Phase 1 包含手动注册步骤。 |
| 1 | Business Objective Definition | ✅ Done | HANDOFF-20260504-goal-driven-phase1 | OBJECTIVES.md OKR template + Alex STEP 3.8 gap analysis + 内容副业 REGISTRY 11 notebooks + OBJECTIVES O1/O2 |
| 2 | Autonomous Research Strategy | ✅ Done | HANDOFF-20260504-autonomous-research-phase2 | *research-plan command (5-step protocol: read→plan→confirm→execute→update OBJECTIVES). Validated: menu-snap research-plan-2026-05-04.md + 4 notebooks generated + OBJECTIVES KR research status tracked. |
| 3 | Research-Decision Loop | ⬚ Planned | — | 研究→决策追踪 + 决策→行动→结果反哺 + `--caller` flag |
| 4 | Wire Engine + Lifecycle + Dogfood | ✅ Done | HANDOFF-20260531-research-engine-wire-phase4.md | effort-scaling 触发 + dormant hook + 空壳归档 + dogfood: seed_origin 0→2 + 对抗 challenge 自动触发(DR-20260531) — 引擎插电成功 (commit 92bbfc3+merge 4c84b09) |
| 5 | Breadth + Quality Gate | 🔄 Active | — | persona 视角种子化 + 5 维 LLM-judge 鲁棒(复用 Codex+Gemini, advisory) |
| 6 | Adoption + Sync Rollout | ⬚ Planned | — | 强化 *analyze research-gate(对的时刻触发) + *sync 推 14 下游项目 |

### Phase Dependencies
Phase 0 独立（解决基础设施问题）。Phase 1→2→3 顺序依赖。
Phase 4→5→6 顺序依赖（先插电触发，再加广度+打分，最后推广采用）。
Phase 4-6 与 Phase 3 无依赖（Phase 3 是 director/决策层，Phase 4-6 是 execution-quality 层）—— 可独立推进。
执行根因（2026-05-31 *discuss 调查）: 动态种子 0 次使用、对抗 challenge 2/25 使用 —— 高级流程"造了不插电"(同 trace-instrumentation-fix paper-machine 模式)。

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
- Phase 4-6 (2026-05-31) 来自 *discuss 研究能力评估：内部审计 + 14 项目普查 + 开源 landscape 对标。
  外部对标证据 — TAD 已领先：持久 notebook / 跨模型对抗验证 / 源质量分层 / findings→AC。
  TAD 缺：视角多样化(STORM persona) / effort-scaling(Anthropic) / 质量打分鲁棒(Anthropic) / CRAG 条带过滤(推后)。

---

## Phase Details (Phase 4-6)

### Phase 4: Wire Engine + Lifecycle + Dogfood
**Status**: ✅ Done (Gate 4 PASS 2026-05-31 — mechanism proven; dogfood bounded, full tad-evolution refresh = optional follow-up)
**Notes**: Impl commit 92bbfc3, merged 4c84b09. 2-round expert review (code-reviewer + backend-architect) round1 found 4 P0 incl. AR-001 SAFETY conflict → human chose Option B (DR-20260531 carve-out) → round2 all RESOLVED, impl review 0 P0. Dogfood: seed_origin 0→2 (incl. 1 dynamic), Codex+Gemini challenge auto-fired (no keystroke, carve-out working), both correctly rated bounded findings INSUFFICIENT. Surfaced AKU governance-as-code (only 14.5% of 2303 agent context files specify governance) as a TAD capability-pack gap → Phase 6 / future research candidate.
**Context for Phase 5**: Engine now fires. Phase 5 (persona-seeding + 5-dim rubric) reads the persisted `research_complexity` key. The Phase 4c challenge already returned structured INSUFFICIENT/ADEQUATE/STRONG verdicts — Phase 5's 5-dim rubric extends this into a scored gate. dormant hook live (SessionStart); will recompute on next sessions as notebooks cross 30d.
**Scope**: 让已存在但从未触发的高级研究流程真正运行。`*research-plan` 当前用 opt-in + 默认跳过门控制动态种子/对抗 challenge，导致动态种子 0 次、对抗 2/25 次使用。改为**复杂度自适应触发阶梯**（effort-scaling，借 Anthropic）：简单事实→浅单遍 / 对比性→动态种子 / 复杂 landscape→种子+对抗。同时加**非阻塞状态 hook** 让超期 notebook 自动 →💤 dormant（只改状态，不阻塞任何操作，不碰"机械强制拒用"红线），归档 `ai-agent-tutorials` 空壳。NOT in scope: persona 种子化、质量打分门（Phase 5）。
**Input**: 现 `*research-plan` 协议（alex/SKILL.md）+ research-notebook lifecycle 规则
**Output**: 自适应触发的 `*research-plan` + dormant hook + dogfood 证据文件
**AC**:
- [ ] AC4.1: `*research-plan` 含 effort-scaling 阶梯，按任务复杂度决定是否跑动态种子/对抗（不再默认跳过门）
- [ ] AC4.2: 非阻塞 hook 把 `last_queried` 超 `dormant_after_days` 的 notebook status→dormant；REGISTRY 验证体现
- [ ] AC4.3: `ai-agent-tutorials`(source_count 1) 归档
- [ ] AC4.4: **dogfood** 重跑 tad-evolution-research 全流程；trace 中 `seed_origin` ≥1（动态种子真触发）+ 对抗 challenge 产物存在；产出与 2026-05-05 旧 findings 对比有提升
**Files Likely Affected**: `.claude/skills/alex/SKILL.md`(research_plan_protocol) CREATE/MODIFY; `.claude/skills/research-notebook/SKILL.md`(lifecycle) MODIFY; `.tad/hooks/` dormant hook CREATE; `.tad/research-notebooks/REGISTRY.yaml` MODIFY
**Dependencies**: 独立于 Phase 3；是 Phase 5 的前置
**Execution**: pending（手动 handoff）

### Phase 5: Breadth + Quality Gate
**Status**: ⬚ Planned
**Scope**: 在已插电的引擎上补两个真实 gap。(1) **persona 视角种子化**(借 STORM)：种子问题前生成 3-4 个 stakeholder persona（如用户/实现者/怀疑者/运维），每视角派生子问题，攻克"单一角度问题树"。(2) **5 维 LLM-judge 质量鲁棒**(借 Anthropic)：findings 产出后跑事实/引用/完整性/源质量/效率 5 维 0-1 打分，**复用现有 Codex+Gemini 对抗基建**，低分**警告不阻塞**。NOT in scope: CRAG 条带过滤、独立引用 pass、mind-map（推后）。
**Input**: Phase 4 的自适应触发引擎
**Output**: persona 种子化逻辑 + 5 维鲁棒打分步骤（写入 research_plan_protocol）
**AC**:
- [ ] AC5.1: 种子生成前产出 3-4 persona，每 persona ≥1 子问题，写入 question tree
- [ ] AC5.2: findings 后跑 5 维鲁棒（复用 challenge 基建），输出 0-1 分 + 维度明细
- [ ] AC5.3: 低分 advisory 警告，不阻塞 findings 进入下一步（符合单用户 CLI anti-机械强制）
- [ ] AC5.4: 鲁棒在 ~20 个固定案例上校准（防 LLM-judge 漂移）
**Files Likely Affected**: `.claude/skills/alex/SKILL.md`(research_plan_protocol persona + rubric) MODIFY
**Dependencies**: 依赖 Phase 4
**Execution**: pending

### Phase 6: Adoption + Sync Rollout
**Status**: ⬚ Planned
**Scope**: 解决"9/14 装了不用"。验收目标是**对的时刻触发**而非使用率数字——强化 `*analyze` Socratic 阶段的 research-gate：检测到"决策依赖外部信息"时主动建议建 notebook/研究（该用的项目被提醒，不该用的不打扰）。验证后用 `*sync` 把 Phase 4-6 全部改动推到 14 下游项目。
**Input**: Phase 4+5 验证过的引擎
**Output**: 强化的 research-gate（alex SKILL）+ sync 完成报告（14 项目）
**AC**:
- [ ] AC6.1: `*analyze` Socratic/STEP 3.8 在"决策依赖外部信息"信号下主动建议研究（含明确触发条件文本）
- [ ] AC6.2: 不该研究的任务类型（如纯配置/下载插件）不触发建议（负向测试）
- [ ] AC6.3: `*sync` 把 research_plan_protocol + research-notebook lifecycle + dormant hook 推到 14 项目，post-flight 验证版本/文件
**Files Likely Affected**: `.claude/skills/alex/SKILL.md`(research-gate) MODIFY; sync 机制（已存在）
**Dependencies**: 依赖 Phase 4+5
**Execution**: pending
