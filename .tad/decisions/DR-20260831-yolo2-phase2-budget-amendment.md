# DR-20260831 — YOLO2 Phase-2 Budget Amendment

**Date**: 2026-08-31
**Decider**: Sheldon (human, Value Guardian)
**Applies to**: TASK-20260827-YOLO2-P2-COMPLETION, HANDOFF-20260825-yolo2-phase2-bounded-quality-loop.md §4.1
**Supersedes**: The frozen budget values `max_tokens=240000 / audit_reserve=48000 / max_executor_per_round=24000` for Phase-2 dogfood only.

## Decision

The Phase-2 paired dogfood is authorized to run under:

```
max_tokens: 3000000
audit_reserve_tokens: 600000
max_executor_tokens_per_round: 600000
```

This is 12.5× / 12.5× / 25× the original §4.1 values. The human explicitly accepts:

- The observed cost: largest arm 232090, largest round 149654, total 1.6M across 5 pairs
- That the original 24000 per-round ceiling would have made the observed 149654 round `HONEST_PARTIAL` (budget_exhausted) and would have invalidated the already-passed 5/5 dogfood
- That this larger budget is **Phase-2 only** and does not carry to Phase-3 without a new decision

## Rationale

- The original 240k total budget was set before any real Codex dogfood had been measured. The first real 5-pair run (mechanism a6fe746c2ff351df) demonstrated that a single execution round can legitimately need ~150k tokens (assertion + reviewer + execution with full packet and tool traces).
- The larger budget does not change the bounded-loop semantics: the driver still enforces a finite pre-reserved per-round ceiling, audit-reserve isolation, and honest HONEST_PARTIAL on exhaustion. It only moves the ceiling to where the real harness can succeed.
- Rerunning the entire 5-pair campaign under the smaller budget would be pure cost with a predictable HONEST_PARTIAL outcome and no new learning, as the token profile is already measured.

## Provenance

- Human approval: 2026-08-31, explicit "同意以上预算修正案" in session after Blake's budget-escalation pause
- Prior measurement: runs/a6fe746c2ff351df, pair-results.json, native turn records
- This DR is the only authority for the 3000000 budget; the original handoff remains design authority for all other semantics.

## Consequences

- The existing dogfood run `a6fe746c2ff351df` (5/5 control + 5/5 treatment, safety 0/0, mechanism 13a3.../56ac.../a095...) remains valid and may be reused via dogfood-input-manifest
- No new dogfood namespace is required for this budget reason alone
- Phase-3 must re-freeze its own budget explicitly; this amendment does not auto-carry
