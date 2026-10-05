# Recovery Assertion

## H1

- Goal: complete `guide.md` with the required command-reference table and Worked Example.
- Current slice: `S2`, adding a Worked Example with an example invocation block.

## H2

- Handoff revision: `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`.
- Base commit: `5e713afe6c3420abdd76722f022160ee6e36f546`.

## H3

- `S1` is verified and maps to `SC-1`.
- The journal records a distinct Conductor verification receipt for `S1`.

## H4

- `S2` is unverified and remains in progress.
- `guide.md` currently contains the intro and Command Reference table, but no Worked Example.
- The journal records `guide.md` as dirty/uncommitted; this is observation only and is not completion evidence.

## H5

- Pending action: add the `## Worked Example` section and an example invocation block to `guide.md`.

## H6

- No content or scope blocker to the permitted `S2` edit is recorded.
- `S2` verification remains pending until Conductor-side Gate, independent review, and a bound verification receipt occur.

## H7

- The legal next action is one edit to `guide.md` only, within the `S2` contract.
- Stop immediately on scope drift.

## H8

- Non-goal: any work beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo `S1`, modify unrelated content, declare completion, or inspect hidden acceptance.

## S1

- The next action is legal because the `S2` contract explicitly permits `guide.md`, specifies the Worked Example outcome, and maps it to `SC-2`.

## S2

- Verified `S1` must not be redone because the journal contains a Conductor-authored verification receipt mapping it to `SC-1`.
- The existing intro and Command Reference are therefore preserved.

## S3

- Blind retry or self-completion cannot advance verification.
- The packet requires a distinct Conductor identity, existing Gate, independent review, and a bound receipt; ordinary completion prose or a self-authored receipt is insufficient.

## S4

- Rejected: redoing verified work, treating dirty changes as completion, modifying forbidden or unrelated paths, starting another slice, using hidden acceptance, or declaring the run complete without Conductor verification.