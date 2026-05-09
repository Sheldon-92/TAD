# Epic: 质量链全面修复 — Prompt + Hook + Template 三层防线

**Epic ID**: EPIC-20260403-quality-chain-full-repair
**Created**: 2026-04-03
**Owner**: Alex

---

## Objective

修复 v2.7 精简后质量链的系统性缺口。审计发现 ~120 条质量规则中仅 37% 有 Prompt 强制、2.5% 有 Hook 强制、60%+ 无任何执行保障。建立 Prompt（管"必须做什么"）+ Hook（管"做了没有"）+ Template（管"怎么记录"）三层互补防线。

## Success Criteria
- [ ] Blake SKILL.md 恢复完整 Mandatory Rules + Execution Checklist + Anti-rationalization
- [ ] Alex SKILL.md Gate 4 验收清单 + MQ 集成 + Handoff 必填字段强制
- [ ] Handoff 模板增加 task_type / e2e_required / research_required 元数据
- [ ] Completion report 模板增加 Knowledge Assessment + Evidence 清单节
- [ ] pre-gate-check.sh 升级为综合检查（evidence、Ralph Loop 状态、Git commit、条件 E2E）
- [ ] post-write-sync.sh 增加 domain pack 研究文件检测
- [ ] 所有现有 Hook 功能不受影响（无回归）

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Template 层 — 元数据 + 结构 | ✅ Done | [HANDOFF](../../archive/handoffs/HANDOFF-20260403-quality-chain-phase1-templates.md) | handoff 模板 + completion report 模板更新 |
| 2 | Blake Prompt 层 — 执行规则恢复 | ✅ Done | [HANDOFF](../../archive/handoffs/HANDOFF-20260403-quality-chain-phase2-blake-prompt.md) | Blake SKILL.md Mandatory Rules + Execution Checklist + 任务类型分支 |
| 3 | Alex Prompt 层 — 设计端 + 验收端强化 | ✅ Done | [HANDOFF](../../archive/handoffs/HANDOFF-20260403-quality-chain-phase3-alex-prompt.md) | Alex SKILL.md 必填字段 + Gate 4 验收清单 + MQ 集成 |
| 4 | Hook 层 — 验证产出阻塞 | ✅ Done | [HANDOFF](../../archive/handoffs/HANDOFF-20260403-quality-chain-phase4-hooks.md) | pre-gate-check.sh 综合检查 + post-write-sync.sh 增强 |

### Phase Dependencies
- Phase 1 无依赖（模板定义字段，后续 Phase 引用）
- Phase 2 依赖 Phase 1（Blake 规则需要引用模板新字段）
- Phase 3 依赖 Phase 1（Alex 必填字段需要知道模板结构）
- Phase 4 依赖 Phase 1+2+3（Hook 验证需要知道 Prompt 要求产出什么文件）
- Phase 2 和 Phase 3 之间无依赖（可并行）

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Context for Next Phase

### Completed Work Summary
- Phase 1: handoff-a-to-b.md 加 YAML frontmatter（task_type/e2e_required/research_required）；completion-report.md Gate 3 v2 结构 + Knowledge Assessment + Evidence Checklist（commit 679d1fa）
- Phase 2: Blake SKILL.md 新增 EXECUTION CHECKLIST（4 阶段 + task_type 分支 + 7 条 anti-rationalization）+ frontmatter_compliance + context refresh 补充（commit db54386）
- Phase 3: Alex SKILL.md step1b frontmatter 验证 + step4 逐条 AC 对照 + step4b Evidence 检查 + Knowledge Assessment 强化 + step0b safety net（commit faebb49）

### Decisions Made So Far
- Prompt 管"必须做什么"（过程性规则、anti-rationalization），Hook 管"做了没有"（产出验证、检查点阻塞）
- 不怕 Prompt 长 — 质量规则的 token 成本远低于质量失效成本
- 设计时决策、执行时不判断 — e2e_required / research_required 由 Alex 在 handoff 里标注，Blake 无权跳过
- 一个大 Epic 分 4 Phase，不拆成独立 Handoff

### Known Issues / Carry-forward
- 旧 handoff HANDOFF-20260403-quality-chain-repair.md 范围过窄（只修 E2E 和研究），被本 Epic 替代
- config-quality.yaml 定义了完善规则但 60%+ 未被任何执行机制引用

### Next Phase Scope
Phase 1: 更新 handoff-a-to-b.md 模板（加 task_type 等元数据字段）和 completion report 模板（加 Knowledge Assessment + Evidence 清单节）

---

## Notes
- 源自 *discuss 分析：v2.7 错误地将约束性规则归类为机械性指令并删除
- 审计报告：9 环节全链扫描，发现 Hook 仅覆盖 3 条规则（全是 COMPLETION 存在性检查）
