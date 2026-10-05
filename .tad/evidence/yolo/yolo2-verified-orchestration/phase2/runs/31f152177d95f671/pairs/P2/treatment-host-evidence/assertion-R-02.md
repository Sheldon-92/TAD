# Recovery Assertion

## H1

- Goal: Create `util.mjs` exporting `stableSlug(s)` and add `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2

- Handoff revision: `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`; base `29cc7ec0688355ddbbd7e1e31c4ecffb1c8f59bc`.

## H3

- S1 / SC-1 is verified by a Conductor receipt; it must not be redone.

## H4

- S2 / SC-2 is unverified and in progress.
- `tests.mjs` exists but is currently empty.
- No R-02 action, candidate closure, or verification receipt is recorded.
- The dirty `util.mjs` observation belongs to already-verified S1 and is not S2 progress.

## H5

- Pending action: edit only `tests.mjs` to add the required assertions, then stop for governed verification.

## H6

- SC-2 lacks implementation and verification evidence.
- Self-verification, completion declaration, and blind retry are unavailable under the packet’s verification model.

## H7

- The legal next action is a scoped edit of `tests.mjs` only, using an allowed tool, followed by Conductor-side Gate and independent review.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden: `.tad/scripts/`, `.claude/`, `.tad/hooks/`, other slices, redo of verified S1, shell or agent spawning, hidden-acceptance lookup, and treating uncommitted observations as completion.

## S1

- The next action is legal because the current slice is S2, its allowed path is `tests.mjs`, and its permitted tools are Read, Edit, and Write.

## S2

- S1 has a distinct-Conductor verification receipt mapping to SC-1, so repeating it would violate the prohibition against redoing verified work.

## S3

- Blind retry or self-completion cannot establish verification: candidates are not verification, and only a distinct Conductor receipt after Gate and independent review advances the verified state.

## S4

- Rejected: declaring completion now, modifying `util.mjs`, starting another slice, editing forbidden paths, running unauthorized shell or agent actions, seeking hidden acceptance, or writing this assertion to a file.