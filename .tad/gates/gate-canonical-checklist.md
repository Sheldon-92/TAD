# Gate Canonical Checklist (SSOT)
> THE authoritative definition of Gate 1-4 checklist items.
> All other files MUST reference this file, not duplicate items.
> Edit here FIRST, then propagate to gate/SKILL.md inline copy and other references.
> Last reconciled: 2026-06-23 (MECE pass)

## Gate 1: Requirements Clarity
**Owner:** Alex | **When:** After Socratic Inquiry, before *design

Checklist items:
- [ ] Problem defined — 问题定义清晰（Socratic Q2）. Why ME: 只检查"问题是什么"
- [ ] User identified — ICP 或目标用户已定义（Socratic Q1）. Why ME: 只检查"给谁用"
- [ ] Scope bounded (including edge cases) — 范围、排除项、边界条件明确（Socratic Q3a/Q3b）. Why ME: 只检查"做什么/不做什么/边界在哪"
- [ ] Acceptance criteria verifiable — 每个 AC 有可运行的验证方法. Why ME: 只检查"怎么验收"

Why CE: What / Who / Boundary / How-to-verify — 四个独立需求维度。

## Gate 2: Design Completeness
**Owner:** Alex | **When:** Before handoff to Blake

Checklist items:
- [ ] Expert review complete (min 2). Why ME: 流程检查（审查是否发生）
- [ ] All P0 resolved. Why ME: 质量检查（问题是否修复）
- [ ] Architecture complete. Why ME: 高层设计存在性
- [ ] Components specified. Why ME: 组件级规格存在性
- [ ] Functions verified. Why ME: 代码级引用正确性（grep 可验证）
- [ ] Data flow mapped. Why ME: 数据流图存在性

Why CE: 流程 + 质量 + 4 层设计检查。已 MECE ✅。

## Gate 3: Implementation Quality
**Owner:** Blake | **When:** After implementation (Ralph Loop complete)
# MECE: verified 2026-06-23 — 5 items check 5 distinct artifacts

Checklist items:
- [ ] Code/deliverable complete — all handoff tasks done. Why ME: 产出物完整性
- [ ] §9.1 Spec Compliance — every row verified. Why ME: AC 逐条验证
- [ ] Evidence files exist — per handoff manifest. Why ME: 证据存在性
- [ ] Git commit done — hash recorded (or NONE for doc-only). Why ME: 版本控制
- [ ] Knowledge Assessment complete — journal or "no discovery". Why ME: 知识捕获

Why CE: 产出 + 规格 + 证据 + 版本 + 知识 — 五个独立 artifact。

## Gate 4: Business Acceptance
**Owner:** Alex | **When:** After Gate 3 passes

Checklist items:
- [ ] Functional acceptance — §9 AC met AND no open post-implementation blockers (list any). Why ME: 只检查"功能达标+可交付"
- [ ] Quality evidence complete (BLOCKING per Structural_Subagent_Conditionality) — 以下 evidence 逐项确认; FAIL must enumerate which are missing:
  - [ ] Code review evidence exists
  - [ ] Security review evidence exists (code/mixed only)
  - [ ] Performance review evidence exists (code/mixed only)
  - [ ] UX review evidence exists (if UI involved)
  Why ME: 只检查 evidence 存在性
- [ ] Subagent issues resolved — 所有 subagent 反馈中的 P0/P1 已处理. Why ME: 只检查问题修复状态
- [ ] Knowledge Assessment complete — distillation loop 或 "no new discovery". Why ME: 只检查知识记录

Why CE: 功能 + 证据 + 修复 + 知识 — 四个独立维度。无遗漏。
