# DR-20260901 — YOLO2 Phase 4 Remains Opt-In

**Status:** Accepted
**Date:** 2026-09-01
**Human selection:** option 1 — complete Phase 4 without a new evaluation campaign;
keep YOLO2 opt-in and close the Epic.

## Context

The original Phase-4 plan proposed 50–100 paired trajectories to justify a possible
default-on rollout. The maintainer explicitly prefers not to spend time and provider
budget proving speculative platform-wide parity before real use creates demand.
Phases 1–3 already established a recovery vertical slice, bounded quality loop,
deterministic safety foundation, and a real Codex native fresh/resume proof.

## Decision

1. YOLO2 remains opt-in. No default-on proposal is made.
2. The 50–100 trajectory campaign is not executed and is not a completion blocker.
3. Phase 4 completes as a product rollout decision, not an evaluation run.
4. Future real use supplies incremental evidence. A failure triggers a focused repair
   for that path; it does not reopen the entire Epic.
5. Default-on may be reconsidered only through a new human-authorized task with its
   own value case and budget. This Epic grants no such authority.

## Claim boundary

Closing the Epic means the opt-in product direction is complete. It does not claim
statistical non-regression, universal harness parity, or readiness for default-on.

## Cost and risk disposition

- New provider calls: 0
- New test matrix: 0
- Runtime/default behavior change: 0
- Accepted risk: defects in deferred/experimental adapters may be discovered during
  first use; recovery is local fallback or focused repair.
