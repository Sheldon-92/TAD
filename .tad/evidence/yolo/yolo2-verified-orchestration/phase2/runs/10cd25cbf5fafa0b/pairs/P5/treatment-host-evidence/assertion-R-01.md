# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of numeric `item.price` values and `0` for an empty array; subsequently make `app.js` print `5` for `total([{price:2},{price:3}])` while preserving existing tests.

## H2 — Handoff Revision

The governed handoff revision is `1f1ea03d4717200f2ed4eca584e09f587b3893931368e49e15ab365303c8c4ba`, based on commit `0f8c41680aaa5157980093618ec8c7655cb83e6b`.

## H3 — Verified

No work is verified. The ledger contains only initialization and preparation of round `R-01`; it contains no independent verification receipt.

## H4 — Unverified / In Progress

Slice `S1` is prepared but unverified. Its target is for `totals.js` to export `total(items)` with the behavior required by `SC-1`.

The permitted target file `totals.js` was observed to be empty. This is an uncommitted observation only and is not progress, completion, or verification. At round preparation, `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` were recorded as dirty; those observations likewise do not establish progress.

## H5 — Pending Action

Implement only slice `S1` in `totals.js`, subject to the execution environment granting write authority in a later execution turn. After implementation, the resulting candidate must undergo the prescribed Gate, independent review, and Conductor-authored bound verification.

## H6 — Blockers

This recovery turn has no write authority and explicitly forbids performing task work. No deterministic checks are declared for `S1`. Verification also cannot be produced by the executor and requires a distinct Conductor after the Gate and independent review pass.

## H7 — Legal Next Action

The only legal task action after recovery is authorization-bound execution of slice `S1`: edit only `totals.js` to export `total(items)` that sums numeric `price` fields and returns `0` for an empty array. Until write authority is granted, the legal action is to stop after this assertion.

## H8 — Non-Goals / Forbidden Scope

No scope beyond the stated goal is authorized. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Slice `S2`, including changes to `app.js` or work on `tests.js`, must not begin during `S1`. Hidden acceptance must not be inspected.

## S1 — Why the Next Action Is Legal

Editing only `totals.js` for the stated `SC-1` behavior exactly matches the current `S1` contract, its sole allowed path, and the prepared round `R-01`. It becomes executable only when the environment supplies write authority.

## S2 — Why Verified Work Must Not Be Redone

The governance model forbids redoing verified work because verification is ledger-backed and slice advancement is authoritative. There is currently no verified work to redo; if verification later appears, that receipt must be honored rather than repeating the slice.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed attempt or retry authorization exists in the ledger, so a blind retry has no basis. An executor assertion, checkpoint, ordinary file, uncommitted change, or completion prose cannot establish verification. Only a distinct Conductor may advance verified state through a bound receipt after both the Gate and independent review pass; hidden acceptance is outside the executor’s namespace.

## S4 — What Is Rejected

Rejected actions include writing files during this recovery turn; treating the empty or dirty worktree observations as progress; declaring `S1` or the overall goal complete; starting `S2`; editing `app.js`, `tests.js`, or any path other than `totals.js`; inspecting hidden acceptance; modifying forbidden paths; running undeclared checks as proof of completion; spawning agents; blind retrying; or self-authoring verification.