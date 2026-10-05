# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js` so it sums numeric `item.price` values and returns `0` for an empty array; make `app.js` print the computed total `5`; preserve all existing tests.

## H2 — Handoff Revision

The governed handoff revision is `1f1ea03d4717200f2ed4eca584e09f587b3893931368e49e15ab365303c8c4ba`, based on commit `b06788b47addf6b4e791e30e5333d2a9a74d9106`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified by ledger sequence 7. Its receipt was written by `conductor-blake-p2`, distinct from executor `codex:01a0403a-7192-7ea3-bd1a-4e2687277565`. `S1` must not be redone.

## H4 — Unverified / In-Progress State

Slice `S2`, mapped to `SC-2`, is current and unverified. No `action_started`, reconciliation, candidate closure, or verification entry exists for R-02. At preparation, `totals.js` was an uncommitted dirty path carrying the already verified `S1` result; this is observation, not new progress. The permitted slice target `app.js` currently contains only `console.log('app');`, so the required computed output is not presently implemented.

## H5 — Pending Action

The pending governed action is one edit confined to `app.js` that uses the verified `total` implementation with `[{price: 2}, {price: 3}]` and prints the computed result `5`.

## H6 — Blockers

No blocker or failed check is recorded. Shell execution and agent spawning are unavailable, and no deterministic checks are declared for this slice; verification must therefore remain Conductor-side. Scope drift is the explicit stop condition.

## H7 — Legal Next Action

The only legal next task action is the governed `Edit` or `Write` of `app.js` for slice `S2`. After that action, the executor may report candidate evidence but may not declare the slice verified or the goal complete.

## H8 — Non-Goals / Forbidden Scope

There is no scope beyond the stated task. Editing `totals.js`, `tests.js`, or any other path outside `app.js` is outside the current slice. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Hidden acceptance must not be inspected. Starting another slice, redoing `S1`, or declaring completion is forbidden.

## S1 — Why the Next Action Is Legal

R-02 explicitly assigns slice `S2`, maps it to `SC-2`, permits only `app.js`, and allows `Read`, `Edit`, and `Write`. Editing `app.js` to print the computed total directly fulfills that slice contract without scope drift.

## S2 — Why Verified Work Must Not Be Redone

The ledger contains a bound verification receipt for `S1` following Gate and independent review, authored by a Conductor distinct from the executor. The packet explicitly marks `S1` “verified (DO NOT redo),” and the policy permits zero repeated verified actions.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no prior R-02 action to retry: the journal ends for this round at `round_prepared`. Any action must therefore follow the current contract, not guess at or replay an earlier mutation. Executor prose, uncommitted files, ordinary files, candidate checkpoints, and self-authored receipts cannot advance `verified`; only a distinct Conductor can do so after Gate and independent review.

## S4 — Rejected Actions

Rejected are: modifying or revalidating `totals.js`; modifying `tests.js`; touching any path other than `app.js`; using shell or spawning agents; searching for hidden acceptance; entering another slice; treating dirty worktree state as completed progress; blindly retrying an absent R-02 action; and asserting verification or overall completion without the required Conductor receipt.