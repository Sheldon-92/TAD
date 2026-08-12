# Gate 4 Acceptance Report — Release-runbook Capability Migration

**Date**: 2026-08-10  
**Task**: `FULL-RETIRE-P3A-RELEASE-OPS`  
**Implementation commit**: `f8907a3`  
**Gate 3**: PASS  
**Gate 4**: **FAIL — RETURN TO BLAKE**

## Prerequisite

| Check | Status | Evidence |
|---|---|---|
| Completion report exists | PASS | `.tad/active/handoffs/COMPLETION-20260809-release-runbook-capability-migration.md` |
| Gate 3 marker | PASS | `gate3_verdict: pass` |
| Commit exists | PASS | `f8907a341a1986d090102e8b1b60504e93e68756` |
| Layer 2 artifacts | PASS with naming warning | 4 artifacts; `DISTINCT_COUNT=2/2` |

## Business and AC Alignment

Gate 3 evidence remains strong: AC1–AC11 report PASS; 27 coverage IDs, six forward cases and ten
negative groups are present; stable-window evidence supports zero live mutation. Gate 4 nevertheless
found two product behaviors that the existing fixtures do not discriminate, so functional acceptance
cannot pass yet.

| Finding | Severity | Gate 4 result |
|---|---|---|
| Source identity guard can run after read-only sync routing/registry access | P1 | FAIL |
| Source repo can be selected as its own sync/sync-add target | P1 | FAIL |

## Quality Evidence

| Evidence | Required | Result | Path |
|---|---|---|---|
| Code-quality review | Yes | FAIL — P1=1 | `gate4-code-review.md` |
| Security/release-safety review | Yes | FAIL — P1=1 | `gate4-security-review.md` |
| Performance-impact review | Yes | PASS — P0/P1/P2=0 | `gate4-performance-review.md` |
| UX review | No UI | N/A | — |

## Repair Contract

Blake repairs the existing handoff; no new handoff is created.

1. Run the canonical source guard before routing/reading any publish, sync, sync-add, or sync-list operation.
2. Reject literal and symlink-resolved self-sync targets before any state claim or write.
3. Add behavioral/negative fixtures that fail on both defects; update semantic coverage assertions.
4. Regenerate exact `.agents` mirrors.
5. Rerun AC1–AC11 and independent implementation/safety review; refresh the stable window if forward
   sessions are regenerated.
6. Commit the repair separately and update the Completion report with the new hash and Gate 3 result.

## Knowledge Assessment

Blake journal exists at
`.tad/evidence/journal/release-runbook-capability-migration-2026-08-09.md`. Final distillation is deferred
until Gate 4 passes; the per-action approval-claim lesson is superseded by Authority Model v2 and must not
be promoted as the future Lite permission model.

## Archive Decision

**NOT ARCHIVED.** The handoff/completion pair remains active because Gate 4 has two unresolved P1s.
