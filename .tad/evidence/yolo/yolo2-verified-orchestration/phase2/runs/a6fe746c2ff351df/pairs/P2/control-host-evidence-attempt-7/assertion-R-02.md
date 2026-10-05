# Recovery Assertion

## H1

- Goal: create `util.mjs` exporting `stableSlug(s)` and `tests.mjs` using `node:assert` with at least three cases, including the empty string.
- Current slice: `S2`, mapped to `SC-2`.

## H2

- Handoff revision: `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`.
- Base commit: `36cec5f1c15045c986c233f7c7caa1592c203a56`.

## H3

- `S1` is verified and must not be redone.
- `S2` is not verified.

## H4

- `S2` is unverified and currently only prepared.
- `tests.mjs` was observed to be empty.
- The journal records no `S2` action or verification.
- `util.mjs` is an existing uncommitted observation from verified `S1`; it is not permission to modify or redo `S1`.

## H5

- Pending action: create or edit only `tests.mjs` so it asserts at least three cases, including the empty string, for the existing `stableSlug`.

## H6

- No blocker to the scoped `tests.mjs` edit is recorded.
- `S2` still lacks its required Conductor verification receipt.
- No deterministic checks are declared for this slice; verification remains Conductor-side.

## H7

- The legal next action is to use Read, Edit, or Write on `tests.mjs` only for `S2`.
- After the test file is prepared, stop for the Gate, independent review, and distinct-Conductor verification receipt.

## H8

- Non-goals: no work beyond the stated task and no changes to `util.mjs`.
- Do not redo verified `S1` or start another slice.
- Forbidden scope: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Hidden acceptance, shell or agent spawning, and treating uncommitted observations as progress or completion are forbidden.

## S1

- The next action is legal because the active slice is `S2`, its only allowed path is `tests.mjs`, and its permitted tools are Read, Edit, and Write.

## S2

- `S1` has a bound receipt recorded as verified, with `written_by_id` distinct from `executor_id`.
- Therefore its verified work must be preserved and must not be redone.

## S3

- Blind retry and self-completion are unavailable because checkpoints are only candidates and verification requires Gate, independent review, and a distinct Conductor receipt.
- Completion prose, an ordinary file, or an executor assertion cannot verify `S2`.

## S4

- Rejected: modifying `util.mjs`, redoing `S1`, declaring `S2` complete or verified without a receipt, treating empty `tests.mjs` as passing, running unauthorized checks, touching forbidden paths, or inspecting hidden acceptance.