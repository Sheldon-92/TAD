# Gate Canonical Checklist (SSOT)
> THE authoritative definition of Gate 1-4 checklist items.
> All other files MUST reference this file, not duplicate items.
> Edit here FIRST, then propagate to gate/SKILL.md inline copy and other references.
> Last reconciled: 2026-06-23

## Gate 1: Requirements Clarity
**Owner:** Alex | **When:** After Socratic Inquiry, before *design

Checklist items:
- [ ] Problem defined — 问题定义清晰（Socratic Q2 输出）
- [ ] User identified — ICP 或目标用户已定义（Socratic Q1）
- [ ] Scope bounded — 范围和排除项明确（Socratic Q3a/Q3b）
- [ ] Acceptance criteria defined — AC 可验证

Reconciliation source: alex/SKILL.md (3 items merged) + gate/SKILL.md (3 items merged) + quality-gate-checklist.md (6 items, 4 dropped). See HANDOFF-20260623-gate-ssot-p1.md §4.4 for per-item rationale.

## Gate 2: Design Completeness
**Owner:** Alex | **When:** Before handoff to Blake

Checklist items:
- [ ] Expert review complete — min 2 experts
- [ ] All P0 resolved — blocking issues fixed
- [ ] Architecture complete — 组件、数据流、API 都有
- [ ] Components specified
- [ ] Functions verified — 引用的函数/文件存在
- [ ] Data flow mapped

Reconciliation source: alex/SKILL.md (2 kept, 1 dropped) + gate/SKILL.md (4 kept). See §4.4.

## Gate 3: Implementation Quality
**Owner:** Blake | **When:** After implementation (Ralph Loop complete)

Checklist items:
- [ ] Code/deliverable complete — all handoff tasks done
- [ ] §9.1 Spec Compliance — every row verified
- [ ] Evidence files exist — per handoff manifest
- [ ] Git commit done — hash recorded (or NONE for doc-only)
- [ ] Knowledge Assessment complete — journal or "no discovery"

Reconciliation source: all sources consistent, gate/SKILL.md 5 items as baseline. See §4.4.

## Gate 4: Business Acceptance
**Owner:** Alex | **When:** After Gate 3 passes

Checklist items:
- [ ] Business acceptance — §9 AC met
- [ ] Ready for user — no known blockers
- [ ] Security review evidence exists (task_type code/mixed — structural, BLOCKING)
- [ ] Performance review evidence exists (task_type code/mixed — structural, BLOCKING)
- [ ] All subagent feedback addressed
- [ ] Knowledge Assessment complete — distillation or "no discovery"

Reconciliation source: gate/SKILL.md 6 items as baseline, no merge/reduction (MECE optimization deferred). See §4.4.
