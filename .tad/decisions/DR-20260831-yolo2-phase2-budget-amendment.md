# DR-20260831 — YOLO2 Phase-2 Dogfood Budget Amendment

**Date:** 2026-08-31
**Decider:** Sheldon (human, Value Guardian)
**Decision provenance:** Human replied “同意以上预算修正案” after Alex independently
recomputed the existing dogfood usage and explained the cost and reuse consequences.
**Applies to:** `TASK-20260827-YOLO2-P2-COMPLETION`, mechanism/run namespace
`a6fe746c2ff351dff3c99e1fff584a171f5ee3d37b58417f131fb24a55a82f35`.
**Supersedes only:** The Phase-2 dogfood values in
`HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md` §4.1 for this acceptance run.
All other budget semantics, scope rules, ACs, Gate thresholds, and signed amendments remain
unchanged.

## 1. Decision

For the named Phase-2 dogfood mechanism and its Gate 3/4 acceptance, the frozen policy is:

```json
{
  "max_tokens": 3000000,
  "audit_reserve_tokens": 600000,
  "max_executor_tokens_per_round": 600000
}
```

The human explicitly accepts the material expansion from the original
`240000 / 48000 / 24000` limits, including the observed cost of a
`149654`-token executor round.

## 2. Evidence behind the decision

The existing five-pair dogfood is not compatible with the original budget:

- Maximum executor round: `149654` tokens (`P5/control/R-02`), including
  `141312` cached input tokens.
- Maximum executor-only arm total: `232090` tokens (`P5/control`).
- Maximum all-role arm total recomputed from assertion, reviewer, and executor usage:
  `518704` tokens (`P1/control`).

Therefore, a new run under `240000 / 48000 / 24000` is already known to stop as
`HONEST_PARTIAL`. Spending another full five-pair campaign would not test an uncertain
hypothesis; it would reproduce a known budget failure.

## 3. Reuse authorization and integrity conditions

Blake may reuse the existing `a6fe746c…` dogfood only if the corrected, read-only verifier
recomputes a canonical dogfood-input manifest and proves exact equality for every input,
including:

- the three mechanism files and their Git blob hashes;
- the exact budget policy above;
- dataset index and every task input via committed Git blobs or immutable
  content-addressed carriers;
- approval/policy carriers;
- generator, judge, harness, CLI/model/family/version, settings, and canonicalization version;
- the final raw run namespace and durable evidence tree.

Restoring the driver policy to the exact values used by `a6fe746c…` is authorized. Relabeling,
editing, rehashing, or mutating the old run is forbidden. If any canonical dogfood input differs,
or the old inputs cannot be reconstructed without a mutable-filesystem fallback, reuse is invalid
and a new namespace/full run is required.

Reuse still requires the durable checker to run again against the corrected candidate and return
PASS. This amendment does not waive the Gate-4 findings about read-only verification, immutable
evidence, exact Gate-3 carrier binding, self-contained replay, or internally consistent reports.

## 4. Scope limits

This decision is **not**:

- a TAD/YOLO default runtime budget;
- a Phase 3 or Phase 4 budget baseline;
- evidence that cost efficiency is acceptable;
- authorization for future runs to inherit these limits;
- authorization to make YOLO default-on.

Phase 3 is blocked from inheriting this policy. Before Phase 3 execution, Alex must design a
separate budget-calibration acceptance criterion using full-role native usage, cached-input
visibility, observed distribution, and an explicit safety margin. That calibration requires a
new human decision and new evidence; this DR cannot satisfy it.

## 5. Consequences and recovery

- **Accepted consequence:** Phase 2 retains a loose but finite safety ceiling so the already-paid
  dogfood can be assessed honestly without falsifying its policy.
- **Remaining risk:** The ceiling is materially above observed usage and does not demonstrate
  production cost discipline.
- **Recovery:** If reuse equality fails, stop and report the mismatching input. Do not silently
  rerun under a different budget or broaden this authorization.
- **Gate consequence:** Blake must generate a new candidate/main tuple, rebind Group-0 and Layer 2,
  and stop at Gate 3 PASS for Alex. Gate 4 and archive remain Alex-owned.
