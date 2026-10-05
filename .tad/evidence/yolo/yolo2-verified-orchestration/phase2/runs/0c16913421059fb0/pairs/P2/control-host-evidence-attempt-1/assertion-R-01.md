# Recovery Assertion

## H1

- Goal: create `util.mjs` exporting `stableSlug(s)` and add `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2

- Handoff revision: `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`; base: `36cec5f1c15045c986c233f7c7caa1592c203a56`.

## H3

- Verified state is none. No Conductor verification receipt exists.

## H4

- Slice `S1` is unverified and incomplete.
- The permitted target `util.mjs` is empty.
- The journal records only initialization and round preparation; dirty-at-prepare paths are observations only, not progress or completion.
- Slice `S2` has not been executed and is outside this round’s current slice contract.

## H5

- Pending action: an authorized executor may implement `stableSlug` in `util.mjs` only, then stop for Gate, independent review, and Conductor verification.

## H6

- This recovery actor is read-only and was instructed not to perform task work.
- No deterministic checks are declared for `S1`; verification remains unavailable without the required distinct Conductor receipt.

## H7

- The legal next action is to use only `Edit` or `Write` on `util.mjs` for `S1`, with no scope drift, followed by the required verification workflow.

## H8

- Non-goals and forbidden scope: no `S2`, no tests work in this round, no other slices, no changes beyond the stated task, and no access to `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Hidden acceptance, shell or agent execution, self-authored verification, and treating uncommitted observations as completion are excluded.

## S1

- The next action is legal because `S1` is the current slice, maps to `SC-1`, permits only `util.mjs`, and explicitly allows `Edit` and `Write`.

## S2

- Verified work must not be redone because the packet prohibits repeated verified action; here, verified state is none, so there is no verified work to redo. Dirty-at-prepare observations are not verified work.

## S3

- Blind retry and self-completion are unavailable because checkpoints are only candidates, no deterministic checks are declared, hidden acceptance is outside the namespace, and only a distinct Conductor receipt after Gate and independent review can advance verification.

## S4

- Rejected: any claim of completion or verification, any work on `S2` or forbidden paths, any shell or agent execution, any hidden-acceptance inspection, any blind retry, and any treatment of uncommitted observations as progress.