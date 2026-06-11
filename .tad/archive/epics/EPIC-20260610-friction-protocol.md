# Epic: TAD Friction Protocol

**Epic ID**: EPIC-20260610-friction-protocol
**Created**: 2026-06-10
**Owner**: Alex

---

## Objective
Prevent Alex and Blake from treating dependency, permission, approval, reviewer, or environment friction as a reason to skip TAD process steps. When a required step cannot run cleanly, the system must request the missing prerequisite, use an equivalent substitute with evidence, or mark the work BLOCKED instead of converting friction into PASS.

## Success Criteria
- [x] Alex Gate 2, Blake Gate 3, and Alex Gate 4 all have explicit friction handling rules.
- [x] Completion reports expose friction status using a fixed enum, so BLOCKED cannot be disguised as PASS.
- [x] Codex and Claude Code usage both follow the same protocol, with platform-specific approval/auth friction documented.
- [x] A later advisory checker can scan reports for missing or malformed friction evidence.

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Core protocol and templates | ✅ Done | HANDOFF-20260610-friction-protocol-phase1.md | Friction Protocol in SKILL body + handoff/completion/Gate templates |
| 2 | Advisory checker | ✅ Done | HANDOFF-20260610-friction-protocol-phase2.md | Script that detects blocked-as-pass and missing friction status evidence |

### Phase Dependencies
All phases are sequential. Phase 2 depends on Phase 1's final table names, enum values, and report locations.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: Complete
- **Progress**: 2 / 2 phases complete

---

## Phase Details

### Phase 1: Core protocol and templates

**Status:** ✅ Done
**Execution:** accepted 2026-06-10; implementation commit `0b1b9e5`; Gate 4 PASS

#### Scope
Add TAD Friction Protocol rules to the load-bearing body text and templates that Alex/Blake/Gate already use. This phase defines the enum, default escalation behavior, Gate 2/3/4 obligations, equivalent-substitute rule, and human override evidence requirements.

This phase does NOT build the advisory checker. It may add checker-ready table structures and ACs, but any new script under `.tad/hooks/lib/` belongs to Phase 2.

#### Input
User decisions from 2026-06-10:
- Strict blocking is the default.
- Dependency/approval/auth friction must first request the missing prerequisite.
- Allowed exceptions: explicit human override, or equivalent substitute with evidence.
- Fixed enum: `READY / BLOCKED / DEGRADED_WITH_APPROVAL / EQUIVALENT_SUBSTITUTE / NOT_APPLICABLE_WITH_REASON`.
- Primary placement: Alex/Blake SKILL body + templates; checker later.

#### Output
Updated protocol text and templates that force friction to be recorded before Gate PASS:
- Alex must design friction preflight in Gate 2.
- Blake must run friction handling before and during Ralph Loop / Gate 3.
- Gate 3 cannot PASS with unresolved `BLOCKED` friction.
- Alex Gate 4 must review Blake's friction table before acceptance.

#### Acceptance Criteria
- [x] Alex SKILL body contains a TAD Friction Protocol with fixed enum and Gate 2 obligations.
- [x] Blake SKILL body contains the same fixed enum and execution rules for dependencies, approval/auth, reviewer availability, and equivalent substitutes.
- [x] Gate SKILL contains Gate 3 and Gate 4 friction checks that block unresolved `BLOCKED` rows.
- [x] Handoff template contains a Gate 2 Friction Preflight section.
- [x] Completion report template contains a Friction Status table and declares unresolved `BLOCKED` rows Gate 3 blocking.
- [x] Verification commands prove all enum/status anchors exist in the intended files.

#### Files Likely Affected
- `.agents/skills/alex/SKILL.md` (MODIFY)
- `.agents/skills/blake/SKILL.md` (MODIFY)
- `.agents/skills/gate/SKILL.md` (MODIFY)
- `.tad/templates/handoff-a-to-b.md` (MODIFY)
- `.tad/templates/completion-report.md` (MODIFY)
- `NEXT.md` (MODIFY)

#### Dependencies
None.

#### Notes
Relevant knowledge:
- `principles.md`: Execution discipline content must stay in SKILL body; express handoff is not review exemption; mechanical enforcement rejected on single-user CLI.
- `patterns/handoff-design.md`: circular trigger content must stay in body.
- `patterns/gate-design.md`: embed cross-cutting concerns into existing flows; Gate 3 owns technical checks and Gate 4 owns business acceptance.
- `patterns/ac-verification.md`: ACs are operational contracts; dry-run commands.

### Phase 2: Advisory checker

**Status:** ✅ Done
**Execution:** accepted 2026-06-10; implementation commit `b30d1ef`; Gate 4 PASS

#### Scope
Create an advisory script that scans active/completed handoffs for missing or malformed friction evidence. This phase is a smoke alarm, not a hard hook, matching the single-user CLI principle.

This phase does NOT rewrite the protocol semantics unless Phase 1 acceptance discovers a gap.

#### Input
Accepted Phase 1 table names, enum values, and report structure.

#### Output
An advisory checker plus documentation for when Alex/Blake should run it.

**Handoff**: `.tad/archive/handoffs/HANDOFF-20260610-friction-protocol-phase2.md`

#### Acceptance Criteria
- [x] Checker exits nonzero or emits WARN when a completion report has Gate 3 PASS but unresolved `BLOCKED` friction rows.
- [x] Checker catches missing Friction Status section in new-format completion reports.
- [x] Checker avoids hard-block hooks/settings modifications.
- [x] Checker has positive and negative fixtures.

#### Files Likely Affected
- `.tad/hooks/lib/friction-status-check.sh` (CREATE)
- `.agents/skills/alex/SKILL.md` (MODIFY, advisory invocation only if needed)
- `.agents/skills/blake/SKILL.md` (MODIFY, advisory invocation only if needed)
- `.agents/skills/gate/SKILL.md` (MODIFY, advisory invocation only if needed)

#### Dependencies
Phase 1 accepted.

#### Notes
Use advisory smoke-alarm behavior. Do not register hooks, do not modify settings, and do not fail-closed in normal CLI flows.

---

## Context for Next Phase

### Completed Work Summary
- Phase 1 accepted 2026-06-10: added body-level TAD Friction Protocol to Alex/Blake, Gate 3/4 friction checks to Gate, `§8.4 Friction Preflight` to handoff template, and Friction Status reporting to completion template.
- Gate 4 acceptance report: `.tad/evidence/acceptance-tests/friction-protocol-phase1/gate4-acceptance-report.md`.
- Phase 2 accepted 2026-06-10: added `.tad/hooks/lib/friction-status-check.sh`, 4 fixtures + harness, and optional Gate 3/4 advisory invocation text. Gate 4 acceptance report: `.tad/evidence/acceptance-tests/friction-protocol-phase2/gate4-acceptance-report.md`.

### Decisions Made So Far
- Default friction handling is strict blocking, not silent downgrade.
- Equivalent substitute is allowed only when duties are equivalent and evidence is recorded.
- Human override is allowed only with explicit risk/rationale evidence.
- Checker was implemented in Phase 2 as a manual advisory smoke alarm.

### Known Issues / Carry-forward
- Optional future checker expansion: validate `DEGRADED_WITH_APPROVAL` and `EQUIVALENT_SUBSTITUTE` evidence cells for approval source/date/risk or equivalence reasoning.
- Backend-architect noted template section-ordering disorder around `## 8.4 Friction Preflight` / `### 8.5 Test Evidence Required`; accepted for Phase 1, clean up on the next template touch.

### Next Phase Scope
Epic complete. No next phase planned.

---

## Notes
This epic was created from a Codex TAD demo failure pattern: agents avoided expert review, dependency installation, approval requests, or setup work when those steps created friction.
