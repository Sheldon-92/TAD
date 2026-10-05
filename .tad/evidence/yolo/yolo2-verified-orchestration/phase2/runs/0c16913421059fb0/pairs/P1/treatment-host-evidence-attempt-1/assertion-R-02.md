# Recovery Assertion

## H1

- Goal: Append `## Command Reference` to `guide.md` with a command/purpose table for `init`, `status`, and `verify`, without changing existing content; also satisfy SC-2 by adding a Worked Example section with an invocation block.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- S1 / SC-1 is ledger-verified by Conductor receipt `receipt-R-01.json`.
- The current `guide.md` observation contains the intro and Command Reference table.

## H4

- S2 / SC-2 is unverified and incomplete.
- No Worked Example section or example invocation block is present in the observed `guide.md`.
- `guide.md` is an uncommitted observation carried from the S1 worktree mutation; it must not be treated as completion of S2.

## H5

- Pending action: perform only the S2 edit, adding the Worked Example section and invocation block to `guide.md`, then stop for governed verification.

## H6

- No ledger-recorded workflow blocker exists.
- This response is additionally constrained by the instruction not to write files or perform task work, so the S2 edit remains pending.

## H7

- Legal next action: edit only `guide.md` for S2 using an allowed `Edit` or `Write` action, with no other slice or path changes, followed by Conductor-side Gate and independent review.

## H8

- Non-goals and forbidden scope: no work beyond the stated task; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not change existing content or operate outside `guide.md`.

## S1

- The next action is legal because the R-02 packet authorizes slice S2, maps it to SC-2, allows only `guide.md`, and permits `Read`, `Edit`, and `Write`.

## S2

- S1 must not be redone because the ledger records it as verified by a distinct Conductor identity after Gate and independent review, and the packet explicitly says verified work is not to be redone.

## S3

- Blind retry or self-completion is unavailable because verification requires a distinct Conductor-written receipt after Gate and independent review; executor assertions, completion prose, ordinary files, or self-authored receipts cannot advance verification.

## S4

- Rejected: treating the existing uncommitted S1 observation as S2 completion; redoing S1; starting another slice; modifying forbidden paths; changing the intro; relying on hidden acceptance; or declaring completion without the required Conductor verification.