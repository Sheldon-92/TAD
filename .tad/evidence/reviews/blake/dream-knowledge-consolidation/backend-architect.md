# Architecture Review: *dream Knowledge Consolidation

**Reviewer:** backend-architect (sub-agent)
**Date:** 2026-05-14
**Scope:** 4-phase pipeline design, validator, rollback, scalability

## P0 Issues (Resolved)

1. **`grep -coE` platform divergence** — same as code-reviewer P0-1. Fixed.
2. **Step3 "70% topic overlap" contradicts handoff Decision #8** — deterministic rules mandated. Fixed: replaced with 3 merge rules (AMENDED pair, identical title prefix, same handoff Context).
3. **`<!-- FULL: -->` mechanism not implemented** — handoff §4.4 specified inline rollback. Design decision: dropped in favor of snapshot backup (inline comments defeat compression purpose). Accepted.

## P1 Issues (Resolved)

1. **ALL Grounded-in paths stripped** — over-correction. Provenance via Supersedes notes + snapshot provides alternative audit trail.
2. **`ls -td` fragile for rollback** — fixed: lexicographic sort on ISO date dirs.
3. **Revalidated dates stripped** — breaks stale-knowledge-check.sh alarm quieting. Fixed: step3 now says "Preserve Revalidated dates."
4. **Promote non-atomic** — noted; protocol specifies backup-then-replace order.

## P2 Observations

1. Date regex needs both em-dash and hyphen — fixed.
2. Small files (security.md: 50 lines) will show 0% reduction — expected.
3. Re-run behavior with existing candidates not specified — noted for future.

## Verdict: PASS (after fixes)

## Positive Notes
- Candidate file approach correctly follows Dreams API pattern
- Safety keyword invariant holds (19→24 occurrences)
- 76% line reduction exceeds target while preserving all safety entries
- Validator as advisory matches "Mechanical Enforcement Rejected" lesson
