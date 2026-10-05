# Recovery Assertion

## H1

- Goal: create `util.mjs` exporting `stableSlug(s)` and add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2

- Handoff revision: `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`; base: `36cec5f1c15045c986c233f7c7caa1592c203a56`.

## H3

- `S1` is verified and must not be redone.
- `S2` is not verified.

## H4

- `S2` is the only current slice and remains unverified and incomplete.
- The permitted target `tests.mjs` is empty.
- The journal records `tests.mjs` as dirty at R-02 preparation; this is an uncommitted observation only and must not be treated as progress or completion.
- No R-02 action or verification receipt is recorded.

## H5

- Pending action: an authorized executor may create the required assertions in `tests.mjs` only, then stop for the required verification workflow.

## H6

- This recovery actor has no write access and was instructed not to perform task work.
- No deterministic checks are declared for `S2`; verification requires the separate Gate, independent review, and distinct Conductor receipt.

## H7

- The legal next action is to use only `Edit` or `Write` on `tests.mjs` for `S2`, without touching `util.mjs` or any other path.

## H8

- Non-goals and forbidden scope: no redo of `S1`, no work beyond `S2`, no other slices, no changes to `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Hidden acceptance, shell or agent execution, self-authored verification, and treating uncommitted observations as completion are excluded.

## S1

- The next action is legal because `S2` is the current slice, maps to `SC-2`, allows only `tests.mjs`, and explicitly permits `Edit` and `Write`.

## S2

- Verified work must not be redone because the packet explicitly marks `S1` verified and prohibits redoing verified work. The current work concerns only unverified `S2`.

## S3

- Blind retry and self-completion are unavailable because checkpoints are only candidates, no deterministic checks are declared, hidden acceptance is outside the namespace, and only a distinct Conductor receipt after Gate and independent review can advance verification.

## S4

- Rejected: any edit to `util.mjs`, any redo of `S1`, any work outside `tests.mjs`, any shell or agent execution, any hidden-acceptance inspection, any blind retry, and any claim of completion or verification without the required receipt.