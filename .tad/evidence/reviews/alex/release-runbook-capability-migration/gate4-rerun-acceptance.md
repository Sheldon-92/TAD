# Gate 4 Rerun Acceptance — Release-runbook Capability Migration

**Date**: 2026-08-10  
**Task**: `FULL-RETIRE-P3A-RELEASE-OPS`  
**Initial implementation commit**: `f8907a341a1986d090102e8b1b60504e93e68756`  
**Repair commit**: `cabe28755c581c1bddfdfe1a490471888d9f26df`  
**Gate 3**: PASS  
**Gate 4 rerun**: **PASS**

The initial Gate 4 FAIL report remains immutable historical evidence for `f8907a3`.
This report supersedes its verdict only for the repaired revision `cabe287`.

## Prerequisites and Functional Acceptance

| Check | Result | Evidence |
|---|---|---|
| Completion report and Gate 3 marker | PASS | `gate3_verdict: pass` |
| Repair commit and parent | PASS | `cabe287` parent is `f8907a3` |
| AC1–AC11 mechanical rerun | PASS | all eleven commands exited 0 and printed PASS |
| Semantic coverage | PASS | 27 behavior IDs |
| Forward evidence | PASS | 6/6 cases; live mutation count 0 |
| Negative evidence | PASS | 10/10 groups |
| Managed surface | PASS | 14 targets sealed; 12 reachable, 2 missing |
| Mirror parity | PASS | canonical and generated trees byte-identical |
| Scope preservation | PASS | no full carrier, hook, runtime, installer, or registered-target change |

## Returned Findings

| Finding from first Gate 4 | Closure | Result |
|---|---|---|
| Source guard could run after read-only routing/state access | Guard precedes reference loading and every read-only or mutation route; executed wrong-origin fixtures cover all four operations | CLOSED |
| Literal or symlink-resolved source could be its own sync target | Physical identity comparison rejects both forms before approval, state, or write; fixtures cover `sync` and `sync-add` | CLOSED |

## Independent Quality Evidence

| Review | Verdict | Severity count |
|---|---|---|
| Gate 4 code quality rerun | PASS | P0=0, P1=0, P2=0 |
| Gate 4 security/release-safety rerun | PASS | P0=0, P1=0, P2=0 |
| Gate 4 performance rerun | PASS | P0=0, P1=0, P2=0 |
| Blake spec, implementation, and test reruns | PASS | P0=0, P1=0, P2=0 |

## Knowledge Assessment

- Blake's implementation journal was verified. It preserves the reusable findings that a
  safety predicate includes invocation order and that target identity must be compared
  physically, with separate literal and symlink fixtures.
- No duplicate project-knowledge entry is created during this acceptance. Phase 3b will
  rewrite the release authority contract under Authority Model v2; that is the correct
  point to distill these guard lessons without accidentally promoting Phase 3a's
  soon-to-be-superseded per-action approval model.
- The memory ingress scan found two items: Alex no-code separation is already enforced by
  the role contract, and the cross-project tracking boundary is unrelated to this
  repository-local task. Neither requires a new knowledge entry here.
- `gate4_delta` remains empty. Both defects were deviations from an already-correct
  handoff requirement, not missing Alex design predictions.

## Archive Decision

**AUTHORIZED AND PASS-BOUND.** The human explicitly requested archive on PASS. With all
blocking checks green, the handoff/completion pair is accepted for archival; no second
technical approval is required.

## Final Verdict

**GATE 4 PASS — ACCEPTED.** Phase 3a is complete. Phase 3b Lite Authority Model v2 may
start after the active pair is archived.
