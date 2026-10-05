# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of numeric `item.price` values and `0` for an empty array. A later slice will make `app.js` print `5` for `[{price:2},{price:3}]` while preserving existing tests.

## H2 — Handoff Revision

The governed handoff revision is `41b1ed11ad2f3ba785556c672aa1ea239086b65f4e8d7f079d7a6b94b93d9b88`, based on commit `060dc368bdcdc83fee6801c489efbe0c4b2def21`.

## H3 — Verified State

No work is verified. No Conductor verification receipt appears in the ledger.

## H4 — Unverified / In-Progress State

Round `R-01` has prepared slice `S1`, mapped only to `SC-1`. Its allowed path is only `totals.js`.

`totals.js` is currently empty, matching its empty-file hash recorded when the round was prepared. This is an uncommitted observation only and is not progress, completion, or verification. The ledger records no execution attempt, checkpoint, failure, retry, Gate result, independent review, or verification receipt.

## H5 — Pending Action

An authorized executor may implement only slice `S1`: edit `totals.js` so it exports `total(items)`, sums numeric `price` fields, and returns `0` for an empty array. After that bounded edit, execution must stop for Conductor-controlled evaluation.

## H6 — Blockers

There is no recorded task blocker. This recovery session has no write authority and therefore cannot perform the pending edit. No deterministic checks are declared for this slice.

## H7 — Legal Next Action

The sole legal task action is to edit or write `totals.js` for the `S1` outcome, using only the allowed `Read`, `Edit`, and `Write` tools, then yield control without declaring the slice verified or complete.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. In this round, `app.js`, `tests.js`, slice `S2`, and all other paths are outside the active slice. The following paths are explicitly forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Shell execution, agent spawning, hidden-acceptance inspection, starting another slice, treating uncommitted state as completed work, and executor-declared verification or completion are forbidden.

## S1 — Why the Next Action Is Legal

Editing `totals.js` directly implements the active `S1` contract, maps to `SC-1`, stays within the sole allowed path, and uses only the packet’s permitted tools.

## S2 — Why Verified Work Must Not Be Redone

The policy forbids redoing verified work because verified slices are settled only by a bound receipt from a distinct Conductor after Gate and independent-review passes. No work is currently verified, so there is nothing eligible to redo.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

Blind retry is unavailable because the ledger records no prior execution attempt or failure to retry. Self-completion is unavailable because an executor assertion, checkpoint, ordinary file, or self-authored receipt cannot advance `verified`; only a distinct Conductor can do so after the required Gate and independent review pass.

## S4 — Rejected Actions

Rejected actions include modifying `app.js` or `tests.js`, beginning `S2`, touching any forbidden path, running undeclared tests or shell commands, spawning agents, searching for hidden acceptance, claiming the observed empty file is progress, repeating future verified work, issuing a blind retry, or declaring the goal, slice, or verification complete.