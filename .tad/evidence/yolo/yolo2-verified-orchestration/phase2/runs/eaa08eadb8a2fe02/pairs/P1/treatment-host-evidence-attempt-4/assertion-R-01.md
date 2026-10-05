# Recovery Assertion

## H1

- Goal: append `## Command Reference` to `guide.md` with a markdown table for `init`, `status`, and `verify`, preserving the existing intro.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- Verified state: none. No Conductor-bound verification receipt exists.

## H4

- S1 is unverified and no executor progress is recorded.
- `guide.md` currently contains only `# Guide` and the existing intro paragraph; no Command Reference section is present.
- The journal’s preparation observation recorded the base head and listed pre-existing dirty paths, with `guide.md` absent. These observations are not progress or completion evidence.

## H5

- Pending action: an authorized executor must perform S1 by appending the required Command Reference table to `guide.md`, leaving existing content unchanged, then stop for verification.

## H6

- This turn is forbidden from performing task work and has no write access.
- Completion remains pending authorized execution, the existing Gate, independent review, and a distinct Conductor receipt.
- No deterministic checks are declared.

## H7

- The legal next action is limited to S1, using only the permitted Read/Edit/Write tools and only `guide.md`; scope drift requires stopping.
- Afterward, verification must be Conductor-side and receipt-based.

## H8

- Non-goals and forbidden scope: no work beyond the stated task; do not start S2; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not inspect hidden acceptance; do not declare completion or verification from an assertion or ordinary file.

## S1

- The next action is legal because the S1 contract allows only `guide.md` and Read/Edit/Write, and maps directly to SC-1.

## S2

- Verified work must not be redone because the packet explicitly prohibits redoing verified work, and the quality policy rejects repeated verified actions. None is currently verified.

## S3

- Blind retry and self-completion are unavailable because checkpoints are only candidates; verification requires the Gate, independent review, and a distinct Conductor receipt. Shell/Agent execution and hidden acceptance are also unavailable.

## S4

- Rejected: any claim that S1 or the overall goal is complete, any self-authored verification, treating uncommitted observations as progress, executing S2 in this round, or modifying forbidden paths.