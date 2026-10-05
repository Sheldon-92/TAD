# Recovery Assertion

## H1

- Goal: append `## Command Reference` to `guide.md` with a `command | purpose` table listing every command in `commands.txt`, without changing existing content.
- Current slice: S2, adding a `Worked Example` section with an example invocation block.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `a0edcd1d56c909c4947339ea49796a11915c0b1f`.

## H3

- S1 / SC-1 is verified by the Conductor receipt `receipt-R-01.json`.
- The receipt records distinct `written_by_id` and `executor_id`, mapping the verified work to SC-1.

## H4

- S2 / SC-2 is unverified and has not started; the journal contains only `round_prepared` for R-02.
- `guide.md` is an uncommitted observation containing the verified S1 Command Reference table; it is not S2 progress or completion.

## H5

- Pending action: append the S2 Worked Example section to `guide.md`, then stop on scope drift.

## H6

- No packet-recorded blocker exists.
- This turn is explicitly read-only and must not perform the pending edit.

## H7

- The packet-authorized next execution action is an Edit/Write affecting only `guide.md`, producing the Worked Example required by SC-2.
- No such action is taken in this assertion.

## H8

- Do not redo verified S1 work, start another slice, change existing content, declare completion, or self-author verification.
- Do not touch `.tad/scripts/`, `.claude/`, `.tad/hooks/`, or any scope beyond the stated task.

## S1

- The next action is legal because R-02 explicitly authorizes slice S2, maps it to SC-2, restricts the path to `guide.md`, and permits Read/Edit/Write tools.

## S2

- S1 must not be redone because the ledger records a Conductor-bound `verified` event for S1 with an independent executor and receipt.

## S3

- Blind retry or self-completion is unavailable because the packet requires a Conductor verification receipt after Gate and independent review PASS; executor assertions, completion prose, ordinary files, and self-authored receipts cannot advance verification.

## S4

- Rejected: redoing S1, treating the dirty worktree as completion, performing work outside S2, editing forbidden paths, self-verifying, declaring completion, shell/agent execution, or inspecting hidden acceptance.