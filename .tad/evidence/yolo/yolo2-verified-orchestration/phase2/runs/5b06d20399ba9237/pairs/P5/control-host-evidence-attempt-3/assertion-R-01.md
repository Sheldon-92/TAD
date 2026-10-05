# Recovery Assertion

## H1

- Goal: Add `total(items)` to `totals.js`, make `app.js` print `5` for the specified items, and keep existing tests passing.

## H2

- Handoff: `handoff.md` at revision `9b0b469283e1`; base `4ba004a489`.

## H3

- Verified state: none. No Conductor verification receipt is recorded.

## H4

- R-01/S1 is unverified and in progress.
- The journal records only initialization and round preparation; the permitted read of `totals.js` yielded no source text.
- Prepare-time dirty paths were observations only: `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. They are not progress or completion evidence.

## H5

- Pending action: execute S1 by implementing and exporting `total(items)` in `totals.js`, summing numeric `item.price` values and returning `0` for an empty array.

## H6

- No explicit blocker is recorded. Completion and verification remain unavailable until S1 is executed and the required governed verification process produces a receipt.

## H7

- Legal next action: use only the permitted `Read`, `Edit`, or `Write` operations on `totals.js` for S1. Do not begin S2 or modify any other path.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden scope: `.tad/scripts/`, `.claude/`, `.tad/hooks/`; also forbidden in this round are S2/app.js work, redoing verified work, declaring completion, or seeking hidden acceptance.

## S1

- The next action is legal because the current slice is S1, maps to SC-1, permits `totals.js`, and explicitly allows `Read`, `Edit`, and `Write`.

## S2

- No work is currently verified, so there is nothing to redo. Any later Conductor-verified work must not be repeated because the packet expressly prohibits redoing verified work.

## S3

- Blind retry and self-completion cannot advance state: verification requires a distinct Conductor to write a bound receipt after the Gate and independent review pass. Executor assertions, ordinary files, completion prose, or self-authored receipts never establish verification.

## S4

- Rejected: treating the empty/uncommitted observation as progress or completion; self-asserting verification; blind retry; starting S2; modifying paths outside `totals.js`; touching forbidden directories; or inspecting hidden acceptance.