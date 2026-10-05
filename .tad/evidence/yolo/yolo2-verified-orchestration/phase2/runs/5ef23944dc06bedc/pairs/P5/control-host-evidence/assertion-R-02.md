# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of numeric `item.price` values, and make `app.js` print the result of `total([{price:2},{price:3}])`, which must be `5`. Existing tests must continue passing.

## H2 — Handoff Revision

- Handoff: `handoff.md`
- Revision: `41b1ed11ad2f3ba785556c672aa1ea239086b65f4e8d7f079d7a6b94b93d9b88`
- Base commit: `155251ac6a64eac5958ff2d9724e228b611cdc96`
- Active round/slice: `R-02` / `S2`

## H3 — Verified

Slice `S1`, mapped to `SC-1`, is verified and must not be redone. The journal records a bound receipt written by `conductor-blake-p2`, distinct from the executor, after Gate and review evidence.

## H4 — Unverified / In Progress

Slice `S2`, mapped to `SC-2`, is prepared but has no recorded execution attempt, candidate, or verification receipt. The permitted target `app.js` was observed containing only:

```js
console.log('app');
```

This observation is not progress or completion.

At `R-02` preparation, the ledger recorded uncommitted paths `totals.js`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These are observations only. In particular, `totals.js` remains verified `S1` work despite being uncommitted and must not be modified.

## H5 — Pending Action

An authorized executor must modify only `app.js` so it uses the verified `total` export and prints the computed value `5` for `[{price:2},{price:3}]`.

## H6 — Blockers

This recovery session has no write authority and cannot perform the pending edit. No deterministic checks are declared for `S2`; any governed verification must be performed Conductor-side. Completion still requires Gate passage, independent review, and a bound receipt from a Conductor distinct from the executor.

## H7 — Legal Next Action

The sole legal execution action is to edit only `app.js` under slice `S2` so it prints the computed total `5`, then stop and submit the resulting candidate to the governed verification process.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. During `S2`, modifying `totals.js`, modifying `tests.js`, redoing `S1`, searching for hidden acceptance, or changing any path other than `app.js` is out of scope. The following paths are explicitly forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

## S1 — Why the Next Action Is Legal

The active `S2` contract maps directly to `SC-2`, permits only `app.js`, and allows Read/Edit/Write operations. Updating that file to print the computed total is therefore the only contract-authorized execution action.

## S2 — Why Verified Work Must Not Be Redone

`S1` has an authoritative verification receipt binding its effect to `SC-1`, with distinct executor and Conductor identities plus Gate and review evidence. Its uncommitted status does not invalidate verification. Governance expressly forbids redoing verified work, so `totals.js` must remain untouched.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

`S2` has no recorded failed attempt, so no retry is justified. Uncommitted observations, executor prose, ordinary files, and self-authored receipts cannot advance verification. The executor cannot self-complete because verification requires Gate passage, independent review, and a distinct Conductor’s bound receipt; hidden acceptance is outside the executor’s namespace.

## S4 — What Is Rejected

Rejected actions include editing `totals.js` or `tests.js`, redoing verified `S1`, touching forbidden paths, modifying anything except `app.js`, running undeclared checks, searching for hidden acceptance, treating uncommitted observations as progress, declaring completion, blindly retrying nonexistent work, or attempting any write in this read-only recovery session.