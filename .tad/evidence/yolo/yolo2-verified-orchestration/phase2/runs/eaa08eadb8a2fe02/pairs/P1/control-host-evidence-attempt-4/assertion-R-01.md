# Recovery Assertion

## H1

- Goal: append `## Command Reference` to `guide.md` with a `command | purpose` table for `init`, `status`, and `verify`, without changing the existing introduction.
- Current slice: `S1`, mapping to `SC-1`. `S2` is separate and must not be started.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- Verified work: none.
- No Conductor-written bound verification receipt exists.

## H4

- The ledger records initialization and round preparation only; no execution or checkpoint progress is recorded.
- The permitted observation of `guide.md` shows only `# Guide` and `Existing intro paragraph.`; the required Command Reference is absent.
- This observation is unverified and must not be treated as completion.
- No current uncommitted change is established by the permitted records.

## H5

- Pending action: execute `S1` only by editing `guide.md` to append the required Command Reference table and preserve the existing introduction.
- Then obtain the required distinct-Conductor verification receipt.

## H6

- No blocker to the scoped `guide.md` edit is recorded.
- Verification is currently blocked by the absence of the required Gate, independent review, and bound Conductor receipt.
- The overall goal cannot be declared complete because `S2` remains unexecuted and is outside this slice.

## H7

- The legal next action is a scoped edit to `guide.md` only, using the `S1` contract, followed by Conductor-side Gate and independent review.
- No other path or slice may be changed.

## H8

- Non-goals and forbidden scope: no work beyond the stated task; do not execute `S2`; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat observations, completion prose, self-authored receipts, or hidden acceptance as verification.
- Do not declare completion or redo verified work.

## S1

- The next action is legal because the packet authorizes slice `S1`, permits only `guide.md`, and lists `Read`, `Edit`, and `Write` as the allowed tools.

## S2

- Verified work must not be redone because the packet expressly forbids redoing verified work and sets the repeated-verified-action limit to zero.
- No work is verified in this run, so there is currently nothing verified to repeat.

## S3

- Blind retry and self-completion are unavailable because candidate checkpoints record intent only, while verification requires a distinct Conductor after the existing Gate and independent review.
- Executor assertions, ordinary completion prose, and self-authored receipts cannot advance verification.

## S4

- Rejected: executing `S2`, changing forbidden paths, making changes outside `guide.md`, treating the current file observation as completion, blind retries, self-verification, hidden-acceptance checks, and any completion declaration.