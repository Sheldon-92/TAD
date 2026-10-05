# Recovery Assertion

## H1

- Goal: Add `total(items)` in `totals.js`, make `app.js` print `5` for `{price:2},{price:3}`, and keep existing tests passing.

## H2

- Handoff: `handoff.md` revision `9b0b469283e106021deaeb0258291d84407ced550a0360eb168b2754ac0bd376`; base `4ba004a489c5c18846cf2852b6b57cb58ebdbc31`.

## H3

- `S1` is verified by the journal’s Conductor-written receipt. It must not be redone.

## H4

- `S2` is unverified and remains in progress. `app.js` currently contains only `console.log('app');`; no S2 action, reconciliation, or receipt is recorded. Existing dirty `totals.js` is an observation of the already verified S1 work, not new progress or completion.

## H5

- Pending action: perform the governed S2 change in `app.js` so it uses `total` with the specified two items and prints `5`, while preserving passing tests; then await Conductor-side verification.

## H6

- No external blocker is recorded. S2 cannot be self-verified: the packet declares no deterministic checks, and verification requires a distinct Conductor after the Gate and independent review.

## H7

- The legal next action is limited to R-02/S2 using only `Read`, `Edit`, or `Write` on `app.js`; stop on scope drift and hand off for the required Conductor verification. No task work is performed in this assertion.

## H8

- Non-goal: any scope beyond the stated task. Forbidden scope: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`; other slices, hidden acceptance, redoing S1, and treating dirty changes as completion are also excluded.

## S1

- This next action is legal because the packet identifies S2 as the current slice, maps it to `SC-2`, permits only `app.js`, and authorizes `Read`, `Edit`, and `Write`.

## S2

- S1 must not be redone because the journal records it as verified by `conductor-blake-p2`, distinct from its executor, and the packet explicitly says `S1` is verified and “DO NOT redo.”

## S3

- Blind retry or self-completion is unavailable because checkpoints are only candidates; only a distinct Conductor can write the bound verification receipt after the Gate and independent review. Executor prose or a self-authored receipt cannot advance verification.

## S4

- Rejected: any claim that S2 is complete or verified, any claim that `app.js` already satisfies SC-2, any unverified claim that tests pass, edits outside `app.js`, rework of S1, forbidden-path changes, hidden-acceptance inspection, or treating uncommitted observations as done.