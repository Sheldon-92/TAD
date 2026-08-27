# DR-20260827-yolo2-phase2-amended-acceptance — Phase-2 修正案验收契约

**Date**: 2026-08-27
**Decider**: Sheldon (human, Value Guardian)
**Decision provenance**: opencode session 2026-08-27 — presented three completion
definitions (amendment path / strict-text path / minimal evidence package); human
explicitly selected **修正案路径（推荐）**.
**Supersedes for Phase-2 acceptance only**: the strict-only clauses of
`HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md` §7/§4.4 listed below.
The original handoff remains the design authority for all other semantics.

## Amended clauses (human-accepted as evidence-grade for TASK-20260825-YOLO2-P2)

1. **Capability 9 (executor↔host hidden-acceptance namespace isolation)** is
   accepted as `DEGRADED_WITH_APPROVAL`. Basis: existing approval
   `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/harness-degradation-approval.md`
   (2026-08-26) plus this record (2026-08-27). Condition: isolation relies on
   host-side storage + packet non-disclosure, and every assertion turn carrying
   native shell reads MUST bind `degraded_approval_sha256` (already enforced by
   commit `6eaef1fb`).
2. **Session continuity via resume chain** is accepted in place of exact native
   session ID equality: an execution turn is bound to the pinned assertion
   session when `resumed_from_session === pinned` (runner-owned `codex exec
   resume` invocation), even though codex assigns a new native thread id per
   call. Already enforced since `09e643c5`.
3. **Independent re-entry reviewer** may run on the SAME harness (codex) as the
   executor, provided it is a FRESH native session (never resumed from the
   executor thread), produces its own runner-owned record with
   `role=reviewer`, has native usage charged, and its session id differs from
   the executor's. The deterministic same-process rubric is NOT acceptable as
   the final reviewer.
4. **Gate 3 PASS** becomes achievable for Phase 2 when Group 0 returns
   `NOT_SATISFIED=0, PARTIALLY_SATISFIED<=3` against the handoff + this
   amendment, followed by the standard Layer 2 groups.

## Explicitly NOT waived

- Native event inventory binding, dual-carrier equality, no-op consumption
  rules, receipt/success-mapping binding, phase-candidate closure guards —
  all engine enforcement stands.
- Blind retry remains forbidden.
- The deterministic rubric remains valid only as a dogfood-side scorer, never
  as the independent reviewer.

## Scope of this amendment

Phase 2 of EPIC-20260824-yolo2-verified-orchestration only. Phase 3+ must
re-negotiate harness capability separately; no auto-carry.
