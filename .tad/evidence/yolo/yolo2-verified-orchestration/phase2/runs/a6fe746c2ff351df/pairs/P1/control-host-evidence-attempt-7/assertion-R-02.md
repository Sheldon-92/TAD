# Recovery Assertion

## H1

Overall goal: complete the documentation task without changing existing text. The current slice is S2: append a `## Worked Example` section to `guide.md` containing an example invocation block, mapping to SC-2. S1/SC-1 is already verified.

## H2

Handoff revision: `handoff.md` at `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base commit `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

S1 is verified. Journal seq. 7 records a bound receipt at `.tad/evidence/yolo/run/receipt-R-01.json`, written by `conductor-blake-p2`, distinct from the executor. S2 is not verified.

## H4

Unverified/in progress:

- R-02/S2 is prepared, but no S2 action, reconciliation, candidate closure, or verification is recorded.
- `guide.md` currently contains the verified Command Reference section but no Worked Example section.
- The journal records dirty paths at R-02 preparation: `guide.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These are uncommitted observations only and do not establish S2 progress or completion.

## H5

Pending action: append a `## Worked Example` section with an example invocation block to the end of `guide.md`, preserving all existing text and the verified S1 section. Then submit S2 for governed verification.

## H6

No blocker to the S2 edit is recorded. Verification remains gated by the existing Gate, independent review, and a distinct Conductor receipt; deterministic checks are none, and scope drift is a stop condition.

## H7

The legal next action for an authorized executor is to edit only `guide.md` for S2, append the Worked Example section, preserve S1 unchanged, and stop for governed verification.

## H8

Non-goals and forbidden scope: do not redo S1 or alter its Command Reference; do not execute other slices; do not modify files outside `guide.md`; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not inspect hidden acceptance; do not declare completion from an ordinary assertion.

## S1

The next action is legal because the R-02 packet authorizes slice S2, maps it to SC-2, allows only `guide.md`, and permits Read/Edit/Write. The additive Worked Example is within that contract and does not repeat S1.

## S2

S1 must not be redone because the ledger records it as verified by a distinct Conductor after governed review. Repeating or modifying that verified work violates the packet’s prohibition on redoing verified work and the zero repeated-verified-action limit.

## S3

Blind retry is unavailable because no S2 attempt has been recorded to retry. Self-completion is unavailable because checkpoints and executor assertions do not advance verification; only a distinct Conductor receipt after Gate and independent review can do so. No deterministic checks are declared.

## S4

Rejected: treating the dirty worktree or existing S1 content as evidence that S2 is complete; treating this assertion or an edit as verified; redoing S1; claiming SC-2 without a receipt; inspecting hidden acceptance; touching forbidden paths; or declaring completion.