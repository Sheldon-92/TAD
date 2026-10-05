# Recovery Assertion

## H1

- Goal: Create `util.mjs` exporting `stableSlug(s)` and add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2

- Handoff revision: `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`.
- Base commit: `e44e28d7ea666f8805e611f91783d7e4e1573a5f`.

## H3

- S1 is verified and maps to SC-1.
- Verification was written by Conductor `conductor-blake-p2`, distinct from the executor.

## H4

- S2 is unverified and pending.
- The permitted read of `tests.mjs` shows it is empty.
- The journal records `tests.mjs` as the S2 target and records uncommitted observations including `util.mjs`; these observations are not completion or verification.

## H5

- Pending action: create `tests.mjs` with at least three `node:assert` cases, including the empty string, then await verification.

## H6

- No explicit blocker to the S2 edit is recorded.
- S2 cannot become verified without the required Gate, independent review, and distinct Conductor receipt.

## H7

- The legal next action is limited to reading/editing/writing `tests.mjs` for S2.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Redoing verified S1, editing `util.mjs`, running undeclared checks, declaring completion, treating uncommitted observations as done, shell/Agent spawning, and hidden acceptance are rejected.

## S1

- The next action is legal because the R-02 contract is S2, maps to SC-2, allows only `tests.mjs`, and permits Read/Edit/Write.

## S2

- S1 has a bound verified receipt, so its verified work must not be redone or modified.

## S3

- Blind retry or self-completion is unavailable because no deterministic checks are declared and verification requires a distinct Conductor receipt after Gate and independent review.

## S4

- Rejected: any edit to `util.mjs`, execution of S1, work outside `tests.mjs`, self-authored verification or completion claims, treating dirty state as progress, forbidden-path changes, shell or Agent spawning, and hidden-acceptance access.