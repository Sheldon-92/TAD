# Recovery Assertion

## H1

- Goal: Create `util.mjs` exporting `stableSlug(s)` and `tests.mjs` using `node:assert` with at least three cases, including the empty string. The current slice is S2: add and validate `tests.mjs`.

## H2

- Handoff revision: `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`; base commit: `36cec5f1c15045c986c233f7c7caa1592c203a56`.

## H3

- Verified state: S1 is verified and maps to SC-1. S2 is not verified.

## H4

- S2 is unverified and in progress. `tests.mjs` was inspected and had no content, so no test assertions are observed.
- The journal records `util.mjs`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` as dirty at S2 preparation. These are observations only and do not authorize redoing S1.

## H5

- Pending action: create `tests.mjs` with at least three `node:assert` cases, including the empty string, for S2.

## H6

- No packet-level blocker prevents the S2 edit. Verification and completion remain pending the required Conductor-side checks, independent review, and bound receipt.

## H7

- Legal next action: edit `tests.mjs` only using the allowed Read/Edit/Write tools, then stop at S2.

## H8

- Non-goals and forbidden scope: do not edit or redo verified S1 in `util.mjs`; do not access `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not run shell or spawn agents; do not inspect hidden acceptance; do not declare completion or expand scope.

## S1

- The next action is legal because the active slice is S2, its only allowed path is `tests.mjs`, its allowed tools are Read/Edit/Write, and it maps directly to SC-2.

## S2

- Verified S1 must not be redone because the ledger contains a Conductor-written verification receipt for S1. The dirty `util.mjs` observation does not invalidate that verification or authorize repeated work.

## S3

- Blind retry and self-completion are unavailable because verification advances only through a distinct Conductor identity after Gate and independent review. Executor prose, ordinary files, self-authored receipts, and assertions cannot advance verification; deterministic checks are not available in this slice.

## S4

- Reject any `util.mjs` edit, S1 redo, out-of-slice change, forbidden-path access, shell or agent execution, blind retry, self-authored verification, or completion claim without the required Conductor receipt.