# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of numeric `item.price` values and `0` for an empty array. A later slice must make `app.js` print `5` for `[{price:2},{price:3}]` while preserving existing tests.

## H2 — Handoff Revision

The governed handoff revision is `41b1ed11ad2f3ba785556c672aa1ea239086b65f4e8d7f079d7a6b94b93d9b88`, based on commit `8f634c17c7812b731e0b62ea3cf66461993e2b14`.

## H3 — Verified State

Nothing is verified. No distinct Conductor has issued a bound verification receipt after both the Gate and independent review passed.

## H4 — Unverified / In-Progress State

Round `R-01` prepared slice `S1`, mapped only to `SC-1`. No execution actions or charged tokens are recorded. `totals.js` is currently empty; this is an observation only, not progress or completion. The journal also records pre-existing dirty paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; those observations are outside the slice’s allowed path and confer no authority to modify them.

## H5 — Pending Action

Implement only the `S1` outcome: make `totals.js` export `total(items)` so it sums numeric `price` fields and returns `0` for an empty array.

## H6 — Blockers

No blocker is recorded. The absence of deterministic checks does not verify the slice and does not authorize broader work.

## H7 — Legal Next Action

The next executor action may read or edit only `totals.js` to implement slice `S1`, using only the packet-authorized `Read`, `Edit`, or `Write` capabilities. Execution must stop if scope drift would occur.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. The current slice does not authorize changes to `app.js`, `tests.js`, another slice, or any other path. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Hidden acceptance must not be inspected.

## S1 — Why the Next Action Is Legal

Editing `totals.js` to implement `total(items)` is legal because `S1` expressly defines that outcome, maps it to `SC-1`, names `totals.js` as the sole allowed path, and permits read/edit/write operations.

## S2 — Why Verified Work Must Not Be Redone

The execution policy forbids redoing verified work because verification is ledger-controlled and advances only through a distinct Conductor’s bound receipt. There is currently no verified work to redo; if such a receipt later appears, its covered work must be preserved rather than repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed attempt, retry authorization, or retryable verification result is recorded, so a blind retry has no governed basis. The executor also cannot self-verify or declare completion: checkpoints and prose are only candidate evidence, and verification requires a distinct Conductor after the Gate and independent review both pass.

## S4 — Rejected Actions

Rejected actions include modifying `app.js` or `tests.js`; starting `S2`; touching any path other than `totals.js`; accessing forbidden directories or hidden acceptance; treating the empty target or dirty worktree observations as completed progress; running unauthorized shell checks; spawning agents; issuing a self-authored verification receipt; or declaring the goal complete.