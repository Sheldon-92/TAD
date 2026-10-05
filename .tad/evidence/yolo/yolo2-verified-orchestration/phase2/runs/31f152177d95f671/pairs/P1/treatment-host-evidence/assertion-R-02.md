# Recovery Assertion

## H1

- Goal: append `## Command Reference` to `guide.md` with a table for `init`, `status`, and `verify`, without changing existing content; success also requires a Worked Example section.

## H2

- Handoff revision: `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`; base `c9c45a9d01a298e2d239f0b9740682ca1ae2b5dd`.

## H3

- Slice S1 is verified and maps to SC-1, with Conductor-written receipt evidence.
- Current slice is S2, mapping to SC-2.

## H4

- S2 is unverified and no R-02 action has started.
- The permitted read of `guide.md` shows the verified Command Reference content but no Worked Example section.
- The journal records `guide.md` as dirty at R-02 preparation; this is an uncommitted observation only, not completion evidence.

## H5

- Pending action: append the Worked Example section with an example invocation block to `guide.md`, then submit it for Conductor-side verification.

## H6

- No scope blocker is recorded.
- Verification remains procedurally unavailable to the executor until the Gate, independent review, and distinct Conductor receipt are completed.

## H7

- The legal next action is to execute only S2 in `guide.md`, using only Read, Edit, or Write, and stop on scope drift.
- Afterward, the Conductor must perform the required verification.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start other slices, redo verified S1 work, declare completion, inspect hidden acceptance, or treat uncommitted changes as done.

## S1

- The next action is legal because R-02 explicitly contracts slice S2, permits only `guide.md`, allows Read/Edit/Write, and maps the work to SC-2.

## S2

- Verified S1 work must not be redone because the journal records S1 as verified by a distinct Conductor and the packet explicitly says “DO NOT redo.”

## S3

- Blind retry and self-completion are unavailable because no R-02 action is recorded to retry, uncommitted state is observation-only, and only a distinct Conductor can advance verification after Gate and independent review.

## S4

- Rejected: treating the existing Command Reference or dirty worktree state as S2 completion; redoing S1; editing outside `guide.md`; starting another slice; self-authoring verification; or declaring completion.