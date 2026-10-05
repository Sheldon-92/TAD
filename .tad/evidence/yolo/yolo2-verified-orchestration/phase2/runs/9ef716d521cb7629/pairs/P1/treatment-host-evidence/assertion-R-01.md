# Recovery Assertion

## H1

- Goal: append `## Command Reference` to `guide.md` with a `command | purpose` table for `init`, `status`, and `verify`, without changing existing content.
- Active slice: `S1`, mapping to `SC-1`.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base commit: `92945c39a0f22bea5903c4351f94968437d1ce99`.

## H3

- Verified state: none yet.
- No verification receipt exists.

## H4

- `guide.md` currently contains only the title and existing intro paragraph.
- The Command Reference table is not present.
- No executor actions or verification actions are recorded in `journal.jsonl`.
- No uncommitted change is observed in the slice target file.

## H5

- S1 implementation remains pending.
- After implementation, the result must undergo the required Gate, independent review, and distinct-Conductor verification.

## H6

- No execution blocker is recorded.
- Verification cannot be claimed until the required distinct-Conductor receipt exists.
- There are no deterministic checks declared for this slice.

## H7

- On governed continuation, execute only S1 using the allowed tools and modify only `guide.md`; then stop for Gate, independent review, and distinct-Conductor verification.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start S2, inspect hidden acceptance, declare completion, or treat observations as verified progress.
- Shell/Bash and agent spawning are denied in strict Phase 2.

## S1

- The next action is legal because S1 is the current slice, `guide.md` is its sole allowed path, and `Read`, `Edit`, and `Write` are explicitly allowed tools.

## S2

- No work is currently verified, so there is nothing verified to redo.
- Any future verified work must not be repeated because the packet prohibits redoing verified work.

## S3

- Blind retry or self-completion is unavailable because verification requires a distinct Conductor after the Gate and independent review.
- Executor assertions, completion prose, or self-authored receipts cannot advance verification.

## S4

- Reject claims that S1 or the overall goal is complete or verified.
- Reject treating the current file observation as task completion.
- Reject any S2 implementation, forbidden-scope change, self-authored verification, or hidden-acceptance claim.