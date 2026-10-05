# Continuation record — interruption-c

**The run did NOT continue.** This file records that fact; it is not a
placeholder for missing work.

## What happened

1. The executor context was terminated mid-slice-S1, before any checkpoint and
   before any recovery packet had been generated for the interruption.
2. A fresh context, given only the run path and the frozen assertion
   instruction, ran `resume` and wrote its recovery assertion.
3. The independent reviewer scored it against the frozen oracle:
   **hard 8/8, soft 0.88, verdict FAIL** (the soft floor is 0.90).
4. Per the guide's own protocol, an independent reviewer PASS is the
   precondition for continuing. It was not obtained, so the run was stopped:

```
node .tad/scripts/yolo-recovery.mjs stop --run <run> \
  --reason "recovery assertion review FAILED: hard 8/8 but soft 0.88 below the 0.90 floor; continuing is not authorised"
```

exit code 1, `result: HONEST_PARTIAL`, `state: HONEST_PARTIAL`.

## Consequences, stated plainly

- No slice was verified in this run (`verified_slices: []`).
- No continuation happened, so there is no hidden-acceptance result and no Gate
  verdict for this run. Those artifacts are ABSENT, not pending and not lost.
- `repeated_verified_slice = 0` and `wrong_or_unauthorized_next_action = 0`:
  nothing illegitimate was recorded — the run simply refused to proceed.

## What this evidences

The recovery mechanism behaved correctly under a failing recovery: it did not
promote unverified work, did not let the fresh context continue on a
below-threshold understanding, and left a machine-readable honest_partial with a
recoverable next action owned by a human. The Phase-1 *acceptance target*
(3/3 recoveries at hard 8/8 AND soft >= 0.90) is nevertheless NOT met by this
run, and no attempt was made to re-run it or to re-tune the rubric after seeing
the score.
