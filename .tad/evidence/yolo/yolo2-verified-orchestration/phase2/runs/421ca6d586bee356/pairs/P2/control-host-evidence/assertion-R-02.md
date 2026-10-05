# Recovery Assertion

## H1

- Goal: Create `util.mjs` exporting `stableSlug(s)` and add `tests.mjs` using `node:assert` with at least three cases including the empty string.

## H2

- Handoff revision: `c2500f027b2e`; base revision: `240b80b61b`.

## H3

- `S1` is verified and maps to `SC-1`. It must not be redone.

## H4

- `S2` and `SC-2` remain unverified.
- `tests.mjs` is currently empty.
- The existing `util.mjs` change is a verified, dirty-worktree observation; it must not be modified.

## H5

- Pending action: add the required assertions to `tests.mjs` for `S2`, including at least three cases and the empty string case.

## H6

- No implementation blocker is recorded.
- Verification and the required Node check must be performed Conductor-side; the executor cannot self-verify.

## H7

- Legal next action: edit only `tests.mjs` using an allowed `Edit` or `Write` action, then stop.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Redoing `S1`, editing `util.mjs`, running denied shell or agent actions, inspecting hidden acceptance, and declaring completion are forbidden.

## S1

- The next action is legal because the packet authorizes slice `S2`, maps it to `SC-2`, allows only `tests.mjs`, and permits `Read`, `Edit`, and `Write`.

## S2

- `S1` has a bound verification receipt from a distinct Conductor identity, so repeating or modifying its verified work would violate the packet’s prohibition on redoing verified work.

## S3

- Blind retry and self-completion are unavailable because verification requires the Gate, independent review, and a distinct-identity Conductor receipt; executor assertions or self-authored receipts do not advance verification.

## S4

- Rejected: treating the empty `tests.mjs` or any uncommitted observation as completion.
- Rejected: redoing `S1`, touching `util.mjs`, using shell or agents, accessing hidden acceptance, or declaring completion.