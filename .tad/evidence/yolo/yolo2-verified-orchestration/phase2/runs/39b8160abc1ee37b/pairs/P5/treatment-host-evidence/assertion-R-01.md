# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of numeric `item.price` values and `0` for an empty array. A later slice must make `app.js` print `5` for `[{price:2},{price:3}]` while existing tests continue to pass.

## H2 — Handoff Revision

The governed handoff revision is `1f1ea03d4717200f2ed4eca584e09f587b3893931368e49e15ab365303c8c4ba`, based on commit `56206f57ac0a103b4de62d0c9b739506ec6c018f`.

## H3 — Verified State

No work is verified. The ledger contains no bound verification receipt from a Conductor distinct from the executor.

## H4 — Unverified / In-Progress State

Round `R-01` is prepared for slice `S1`, mapped only to `SC-1`. `totals.js` is currently empty. This is an uncommitted observation only and is not progress or evidence of completion. The journal also records pre-existing dirty paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; those observations confer no execution authority.

## H5 — Pending Action

Implement only slice `S1`: update `totals.js` so it exports `total(items)`, sums numeric `price` fields, and returns `0` for an empty array.

## H6 — Blockers

This recovery session has no write access, so it cannot perform the pending edit. No deterministic checks are declared for this slice. Verification additionally requires the existing Gate and an independent review to pass, followed by a bound receipt written by a distinct Conductor.

## H7 — Legal Next Action

In an authorized execution phase, edit only `totals.js` to satisfy the `S1` contract, then stop for Conductor-side gate and independent verification. Do not start `S2` or declare the overall goal complete.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. The paths `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. `app.js`, `tests.js`, and all other paths are outside the current slice. Hidden acceptance is outside the executor namespace and must not be inspected.

## S1 — Why the Next Action Is Legal

The ledger-prepared `S1` contract maps directly to `SC-1`, explicitly allows only `totals.js`, and identifies Read/Edit/Write as the slice tools. Implementing the required export in that file is therefore the sole contract-bound next action.

## S2 — Why Verified Work Must Not Be Redone

There is currently no verified work to redo. If verification later advances, the packet expressly prohibits repeating verified actions; only a distinct Conductor’s bound receipt after Gate and independent-review passes can establish that state.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The ledger records no failed attempt or authorized retry basis, and an empty target file does not establish an attempt history. Uncommitted observations cannot be promoted to progress. The executor cannot self-verify or declare completion because candidate checkpoints and executor assertions do not advance `verified`; hidden acceptance, Gate execution, independent review, and the Conductor receipt remain outside executor authority.

## S4 — What Is Rejected

Rejected actions include modifying `app.js` or `tests.js`, starting `S2`, touching any non-allowed or forbidden path, searching for hidden acceptance, spawning agents, performing undeclared checks, treating dirty or uncommitted state as completed work, blindly retrying presumed work, redoing future verified work, self-authoring verification, or declaring slice or goal completion.