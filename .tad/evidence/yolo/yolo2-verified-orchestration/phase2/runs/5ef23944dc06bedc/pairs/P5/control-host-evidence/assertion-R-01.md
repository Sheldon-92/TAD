# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of numeric `item.price` values and `0` for an empty array. A later slice must make `app.js` print `5` for `total([{price:2},{price:3}])` while preserving existing tests.

## H2 — Handoff Revision

- Handoff: `handoff.md`
- Revision: `41b1ed11ad2f3ba785556c672aa1ea239086b65f4e8d7f079d7a6b94b93d9b88`
- Base commit: `155251ac6a64eac5958ff2d9724e228b611cdc96`
- Active round/slice: `R-01` / `S1`

## H3 — Verified

Nothing is verified. No bound verification receipt exists in the journal.

## H4 — Unverified / In Progress

Slice `S1` is prepared but not completed or verified. The permitted target, `totals.js`, was observed empty; this is an observation only, not progress.

At round preparation, the ledger recorded uncommitted paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Those observations must not be treated as completed work.

## H5 — Pending Action

An authorized executor must modify only `totals.js` so it exports `total(items)`, sums numeric `price` fields, and returns `0` for an empty array.

## H6 — Blockers

This recovery session has no write authority and therefore cannot perform the pending edit. No deterministic checks are declared for `S1`. Verification still requires a distinct Conductor’s bound receipt after the Gate and independent review both pass.

## H7 — Legal Next Action

The next legal execution action is to edit only `totals.js` under slice `S1` to satisfy `SC-1`, then stop and submit the candidate to the governed verification process.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. During `S1`, `app.js`, `tests.js`, slice `S2`, hidden acceptance, and every path except `totals.js` are out of scope. The following paths are explicitly forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

## S1 — Why the Next Action Is Legal

The active slice contract maps `S1` to `SC-1`, permits only `totals.js`, and allows Read/Edit/Write operations. Implementing the required export in that file is therefore the sole legal execution action.

## S2 — Why Verified Work Must Not Be Redone

Governance forbids redoing verified work because verification is authoritative and advances only through a bound receipt from a Conductor distinct from the executor. There is currently no verified work to redo.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded failed attempt that would justify a retry. Uncommitted observations and executor assertions cannot establish progress or completion. The executor cannot self-verify: Gate passage, independent review, and a distinct Conductor’s bound receipt are required, while hidden acceptance is outside the executor’s namespace.

## S4 — What Is Rejected

Rejected actions include modifying `app.js` or `tests.js`, starting `S2`, touching forbidden paths, searching for hidden acceptance, treating the empty or dirty worktree observations as completed work, rerunning or redoing verified work, declaring success, or attempting any write in this read-only recovery session.