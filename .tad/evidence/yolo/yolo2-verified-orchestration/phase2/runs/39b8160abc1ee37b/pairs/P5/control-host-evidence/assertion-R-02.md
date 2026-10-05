# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of `item.price` values, and make `app.js` print the computed result for `[{price:2},{price:3}]`. All existing tests must continue passing.

## H2 — Handoff Revision

The governed handoff revision is `41b1ed11ad2f3ba785556c672aa1ea239086b65f4e8d7f079d7a6b94b93d9b88`, based on commit `8f634c17c7812b731e0b62ea3cf66461993e2b14`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified and must not be redone. Its receipt was written by `conductor-blake-p2`, distinct from executor `codex:01a040d5-e3ce-7f12-97e9-5b9c131d0dd5`, after recorded Gate and review evidence.

## H4 — Unverified / In-Progress State

Round `R-02` has prepared slice `S2`, mapped only to `SC-2`. No `S2` execution action or verification is recorded. The slice target `app.js` currently contains `console.log('app');`; this is an observation only and is not progress or completion. The journal records dirty paths `totals.js`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these uncommitted observations confer no authority to modify them, and the verified `totals.js` work remains protected from rework.

## H5 — Pending Action

Implement only the `S2` outcome in `app.js`: print the computed value `5` by using `total` with `[{price:2},{price:3}]`, while preserving the requirement that existing tests pass.

## H6 — Blockers

No blocker is recorded. There are no predeclared deterministic checks for this slice, so verification remains Conductor-side and cannot be inferred from the absence of checks.

## H7 — Legal Next Action

The next executor action may read or edit only `app.js` to implement slice `S2`, using only the packet-authorized `Read`, `Edit`, or `Write` capabilities. Execution must stop if scope drift would occur.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. The current slice does not authorize changes to `totals.js`, `tests.js`, another slice, or any other path. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Hidden acceptance is outside the executor namespace and must not be inspected.

## S1 — Why the Next Action Is Legal

Editing `app.js` to print the computed total is legal because `S2` expressly defines that outcome, maps it to `SC-2`, identifies `app.js` as the sole allowed path, and permits read/edit/write operations.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a bound verification receipt from a Conductor identity distinct from its executor, with Gate and independent-review evidence. The packet explicitly marks `S1` verified and says not to redo it. Its uncommitted `totals.js` state is therefore protected verified work, not an invitation to inspect, rewrite, or recommit the slice.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed `S2` attempt, retry authorization, or retryable verification result is recorded, so a blind retry has no governed basis. The executor cannot self-verify or declare completion: checkpoints, ordinary files, completion prose, and self-authored receipts do not advance verified state. Verification requires a distinct Conductor after the Gate and independent review both pass.

## S4 — Rejected Actions

Rejected actions include modifying or redoing `totals.js`; modifying `tests.js`; starting another slice; touching any path other than `app.js`; accessing forbidden directories or hidden acceptance; treating current file contents or dirty paths as completed progress; running unauthorized shell checks; spawning agents; issuing a self-authored verification receipt; or declaring the slice or goal complete.