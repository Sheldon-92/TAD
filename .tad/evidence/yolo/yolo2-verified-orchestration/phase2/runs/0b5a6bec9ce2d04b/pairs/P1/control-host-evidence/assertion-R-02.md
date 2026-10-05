# Recovery Assertion

## H1

- Goal `y2p2-T1-doc-ref`: complete the current governed task by satisfying S2/SC-2, adding a Worked Example section to `guide.md` with an example invocation block.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- S1 is verified by receipt `receipt-R-01.json`, written by Conductor `conductor-blake-p2`, distinct from executor `codex:01a044f8-c8fd-7803-88a2-6d7b3353a45e`.

## H4

- S2/SC-2 is unverified and in progress.
- `guide.md` contains the verified Command Reference section but no Worked Example section.
- The ledger records `guide.md` as dirty at R-02 preparation; this uncommitted state is observation only and is not evidence that S2 is complete.

## H5

- Pending action: execute only S2 by adding a Worked Example section with an example invocation block to `guide.md`.

## H6

- No blocker to the authorized S2 edit is recorded.
- S2 verification remains pending the required Gate, independent review, and Conductor receipt.

## H7

- The legal next action is to edit only `guide.md` for S2, then stop for governed verification.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo verified S1, execute another slice, treat uncommitted work as done, inspect hidden acceptance, or declare completion.

## S1

- S2 is the current prepared slice, maps to SC-2, allows only `guide.md`, and permits the declared Read/Edit/Write tools.

## S2

- S1 must not be redone because the ledger records it as verified with a distinct-Conductor receipt; the packet expressly forbids redoing verified work.

## S3

- Blind retry and self-completion are unavailable because verification requires a distinct Conductor receipt after Gate and independent review; executor assertions and self-authored receipts do not advance verification.

## S4

- Rejected: any S1 rewrite, any claim that S2 or the overall goal is complete or verified, any other-slice work, any forbidden-path change, and any treatment of uncommitted observations as completion.