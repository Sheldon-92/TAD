# Recovery Assertion

## H1

- Goal: append `## Command Reference` to `guide.md` with a `command | purpose` table for `init`, `status`, and `verify`, without changing existing content.
- Active slice: `S1`, mapped to `SC-1`.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- Verified state: none.
- No Conductor verification receipt exists.

## H4

- The permitted read of `guide.md` shows only `# Guide` and `Existing intro paragraph.`
- No Command Reference table is present.
- No journal entry records execution, checkpoint, review, or verification.
- The journal records pre-existing dirty paths at preparation; these do not constitute progress.
- No post-preparation uncommitted change to `guide.md` is evidenced.

## H5

- Pending action: an authorized executor may perform only slice `S1` in `guide.md`, then the governed Gate, independent review, and Conductor verification process must occur.

## H6

- This assertion cannot advance verification.
- The current request forbids task execution and file writes.
- Verification is blocked pending authorized execution and a distinct Conductor receipt.

## H7

- The legal next action is limited to executing `S1` against `guide.md`, using only the packet’s permitted tools and path, followed by the required independent review and Conductor receipt.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start `S2`, redo verified work, inspect hidden acceptance, treat uncommitted changes as completion, or declare completion.

## S1

- The next action is legal because the packet authorizes slice `S1`, restricts the path to `guide.md`, and maps it to `SC-1`.

## S2

- No work is currently verified and therefore none must be redone; any future Conductor-verified work must be preserved because the packet expressly prohibits redoing verified work.

## S3

- Blind retry and self-completion are unavailable because verification requires a distinct Conductor identity, an existing Gate pass, an independent review pass, and a bound verification receipt. An ordinary assertion or self-authored receipt cannot advance verification.

## S4

- Rejected: any claim that the goal is complete or verified, any self-authored verification, any work outside `S1`, any forbidden-path access, any hidden-acceptance lookup, and any attempt to perform task work during this assertion.