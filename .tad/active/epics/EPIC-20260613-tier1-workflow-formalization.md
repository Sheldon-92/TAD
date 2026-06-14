# Epic: Tier 1 Workflow Formalization (Claude-only)

**Epic ID**: EPIC-20260613-tier1-workflow-formalization
**Created**: 2026-06-13
**Owner**: Alex (YOLO Conductor)

---

## Objective
把 3 个高频/已验证但仍"靠 agent 临场编排"的 TAD 实践固化成确定性 `.claude/workflows/`。
Claude-only(用户决定 A:Codex 不管;workflows 本就不在 .claude↔.agents parity 范围)。
Alex 不手写交付物——sub-agent 实现,每个过 Gate 3(gate = 实际跑一遍验证)。

## Success Criteria
- [ ] 3 个 workflow 落地 `.claude/workflows/`,各有合规 meta 块(name/description/whenToUse/phases)
- [ ] 每个 workflow 实际 test-run 过(不是纸面)
- [ ] #2 handoff-review 保持 Gate 2 契约(≥2 专家 + 整合 P0 + audit trail),且经专家审查确认无契约漂移
- [ ] 不破坏现有 6 个 workflow

---

## Phase Map

| # | Phase | Status | Key Deliverable |
|---|-------|--------|-----------------|
| 1 | Canonicalize pack-upgrade + dogfood | 🔄 Active | `.claude/workflows/{pack-upgrade,pack-dogfood}.workflow.js`(从本 session 已验证脚本泛化) |
| 2 | Handoff expert-review workflow | ⬚ Planned | `.claude/workflows/handoff-review.workflow.js`(契约保持 + 专家审查) |
| 3 | Deep-research engine upgrade | ⬚ Planned | 升级 deep-research:加 plan + 动态深挖 + saturation 循环 |

### Phase Dependencies
顺序;同时 1 个 Active。每个 phase 独立 Gate 3。

### Derived Status
In Progress (Phase 1 Active) · 0/3

---

## Phase Details

### Phase 1: Canonicalize pack-upgrade + dogfood
**Scope**: 把本 session 已验证的 `batch-upgrade.workflow.js` + `dogfood-all.workflow.js`(在 evidence 目录)泛化成可复用的 canonical workflow,移入 `.claude/workflows/`。解决参数化(args 在 scriptPath 模式不注入 → 用 sidecar 或文档化 const)。NOT in scope:改它们的核心逻辑(已验证)。
**Output**: 2 个 workflow + 合规 meta;test-run 各一次(小样本)。
**AC**: 文件在 .claude/workflows/;meta 合规;test-run PASS;现有 6 个不受影响。

### Phase 2: Handoff expert-review workflow
**Scope**: 把 Alex 每个 handoff 的"fan-out ≥2 专家 → 整合 P0 → audit trail"固化成 workflow。⚠️ 契约保持:必须仍满足 handoff_creation_protocol 的 min 2 experts + P0 integration + audit-trail 表格。按任务类型选专家(code-reviewer 必选 + backend/ux/security/perf 条件触发)。
**Output**: handoff-review.workflow.js;专家审查(code-reviewer + 协议契约 reviewer)确认无漂移;test-run on 一个真实 handoff draft。
**AC**: 契约保持(grep min-2/P0/audit-trail);专家审查 0 P0;test-run 产出合规 audit trail。
**⚠️ 这改 Gate 2 协议契约 → AR-001:必须过专家审查。**

### Phase 3: Deep-research engine upgrade
**Scope**: 升级现有 deep-research 模式(用户决定),加:① 制定研究计划 ② 层层深入 ③ 动态生成 follow-up 提问方向 ④ loop 到 saturation ⑤ 带引用综合。先调研 deep-research/research-methodology 现有覆盖,只补缺口、不重复。
**Output**: 升级后的 research-engine workflow;test-run on 一个真实研究问题,展示多层深挖 + saturation 停止。
**AC**: plan + 动态 follow-up + saturation 停止条件可见;test-run 产出带引用报告;与 NotebookLM(持久库)边界清晰。

---

## Context for Next Phase
（Conductor 每 phase 后更新）

### Decisions Made So Far
- YOLO-conduct;Claude-only(A);deep-research = 升级现有而非新建。
- Alex 不手写交付物;sub-agent 实现 + Gate 3 test-run。

### Notes
- workflows 不在 parity 范围,天然 Claude-only,无需 parity 豁免。
- 源起:2026-06-13 *discuss(用户观察:Solo/NotebookLM/深度研究等反复手工编排 → 该固化)。
