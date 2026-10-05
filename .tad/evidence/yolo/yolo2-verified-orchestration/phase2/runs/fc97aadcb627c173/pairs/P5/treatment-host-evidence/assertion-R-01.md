# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of numeric `item.price` values and `0` for an empty array. Subsequently, `app.js` must print the computed total `5` for `[{price:2},{price:3}]`, while all existing tests continue passing.

## H2 — Handoff Revision

The governed handoff revision is `1f1ea03d4717200f2ed4eca584e09f587b3893931368e49e15ab365303c8c4ba`, based on commit `b06788b47addf6b4e791e30e5333d2a9a74d9106`.

## H3 — Verified State

No work is verified. Neither SC-1 nor SC-2 has a bound verification receipt from a Conductor distinct from the executor.

## H4 — Unverified / In-Progress State

Round `R-01` prepared slice `S1`, which maps only to SC-1. The slice target `totals.js` is currently empty. This is an uncommitted observation only and is not progress, completion, or verification. The journal records no execution attempt, candidate checkpoint, gate result, independent review, or verification receipt.

## H5 — Pending Action

Implement only slice `S1`: make `totals.js` export `total(items)`, summing numeric `price` fields and returning `0` for an empty array.

## H6 — Blockers

No blocker is recorded. There are no deterministic checks declared for this slice, but verification still requires the governed Gate, independent review, and a bound receipt written by a distinct Conductor.

## H7 — Legal Next Action

The next executor action may edit or write only `totals.js` to implement the `S1` contract. The executor must stop if that action would require scope drift. It may not start `S2`, edit `app.js`, run shell commands, spawn agents, inspect hidden acceptance, or declare the goal complete.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated goal is authorized. The forbidden paths are:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

## S1 — Why the Next Action Is Legal

The prepared `R-01` contract explicitly assigns slice `S1`, maps it to SC-1, allows only `totals.js`, and permits Read, Edit, and Write operations. Implementing the specified export in that file is therefore the sole authorized execution action.

## S2 — Why Verified Work Must Not Be Redone

Governance forbids redoing verified work because verification is ledger-backed and advances only through a distinct Conductor’s bound receipt after Gate and independent-review passes. Although nothing is verified in the current ledger, any later recovery must preserve verified slices rather than repeat them.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

There is no recorded failed execution attempt or diagnostic evidence to justify a retry. The empty target file is only an observation, so it cannot be treated as completed or previously attempted work. The executor also cannot self-verify or self-complete: implementation creates at most a candidate, while verified status requires a distinct Conductor, Gate passage, independent review, and a bound verification receipt.

## S4 — Rejected Actions

Rejected actions include starting slice `S2`; modifying or validating `app.js`; running tests or undeclared checks; using shell/Bash or spawning agents; reading hidden acceptance or files outside the permitted recovery set; touching forbidden paths; treating dirty or uncommitted state as progress; redoing any verified slice; declaring SC-1, SC-2, or the overall goal complete; and performing any work beyond the `totals.js` slice contract.