# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js` to sum numeric `item.price` values, returning `0` for an empty array; later, make `app.js` print `5` for `[{price:2},{price:3}]` while preserving existing tests.

## H2 — Handoff Revision

Handoff revision: `1f1ea03d4717200f2ed4eca584e09f587b3893931368e49e15ab365303c8c4ba`  
Base commit: `c4ddc2eb9c3ec68c0fd32bbf06c393a96e144167`

## H3 — Verified

Nothing is verified. No independent Conductor verification receipt is recorded.

## H4 — Unverified / In Progress

Round `R-01`, slice `S1`, mapping only to `SC-1`, is prepared but unverified. Its outcome is for `totals.js` to export `total(items)`, sum numeric price fields, and return `0` for an empty array.

The permitted read observed `totals.js` empty. This is an observation, not progress or verified work.

At round preparation, the journal recorded uncommitted paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These are observations only and must not be treated as completed work.

## H5 — Pending Action

Implement only slice `S1` by changing only `totals.js`, then stop for the governed Gate, independent review, and Conductor verification process.

## H6 — Blockers

This recovery session has no write access and is expressly prohibited from performing task work. No deterministic checks are declared for `S1`, and no bound verification receipt exists.

## H7 — Legal Next Action

The next authorized executor with write access may edit only `totals.js` to implement the `S1` contract. It must then submit the result as a candidate and stop; it may not declare the slice verified or the overall goal complete.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. During `S1`, `app.js`, `tests.js`, and all other paths are outside the allowed path set.

Forbidden scope:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Starting `S2`, inspecting hidden acceptance, redoing verified work, or declaring completion is forbidden.

## S1 — Why the Next Action Is Legal

Editing `totals.js` is legal because the current slice contract explicitly limits `R-01` to `S1`, maps it to `SC-1`, and lists `totals.js` as the sole allowed path.

## S2 — Why Verified Work Must Not Be Redone

The execution policy forbids redoing verified work because verification is ledger-backed and final for recovery routing. No work is currently verified, so there is nothing to redo; any future verified slice must be preserved and skipped.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

There is no recorded failed attempt to retry, no deterministic check to run, and uncommitted observations cannot establish progress. An executor cannot self-verify: verification requires an existing Gate PASS, an independent review PASS, and a bound receipt written by a distinct Conductor. Hidden acceptance is outside the executor namespace.

## S4 — Rejected Actions

Rejected actions include:

- Editing `app.js`, `tests.js`, or any path other than `totals.js`
- Starting `S2`
- Modifying forbidden-scope paths
- Treating the empty target or recorded dirty paths as completed progress
- Searching for hidden acceptance
- Blindly retrying work without ledger authority
- Self-authoring verification or declaring `S1` verified
- Declaring the overall goal complete
- Performing any task edit in this read-only recovery session