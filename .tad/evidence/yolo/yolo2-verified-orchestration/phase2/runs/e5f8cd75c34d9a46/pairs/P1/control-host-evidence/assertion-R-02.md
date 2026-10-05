# Recovery Assertion

## H1

- Goal: complete slice S2 for `y2p2-T1-doc-ref` by adding a Worked Example section to `guide.md` showing an example invocation block.
- The overall goal also includes the already-verified S1 Command Reference and SC-1.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base: `92945c39a0f22bea5903c4351f94968437d1ce99`.

## H3

- S1 is verified by a Conductor receipt with distinct `written_by_id` and `executor_id`.
- S2 is not verified.

## H4

- `guide.md` contains the existing intro and the verified S1 Command Reference table.
- No Worked Example section or S2 edit is evidenced.
- Journal observations show `guide.md` and other paths dirty at S2 preparation and S1 verification; these are uncommitted observations only and must not be treated as completion.
- S2 remains unverified and incomplete.

## H5

- Pending action: execute only S2 by appending a Worked Example section with an example invocation block to `guide.md`, preserving all existing content and the verified S1 section.

## H6

- No deterministic checks are declared.
- Executor self-assertion cannot establish verification.
- Verification requires Gate and independent review followed by a distinct Conductor receipt.

## H7

- The legal next action is a scoped edit to `guide.md` for S2 only, followed by handoff for the required verification process.

## H8

- Non-goals and forbidden scope: do not redo S1; do not modify content outside the S2 addition; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not treat dirty worktree state as progress or done; do not inspect hidden acceptance or declare completion.

## S1

- The next action is legal because the R-02 packet authorizes slice S2, path `guide.md`, and the Read/Edit/Write tools.

## S2

- Verified S1 work must not be redone because the ledger marks S1 verified and the packet explicitly prohibits redoing verified work. The S1 section must remain unchanged.

## S3

- Blind retry and self-completion are unavailable because only a distinct Conductor can advance verification after Gate and independent review; ordinary edits and executor assertions do not qualify.

## S4

- Rejected: re-editing the Command Reference, claiming S2 is already complete or verified, treating uncommitted observations as done, starting another slice, touching forbidden paths, or self-authoring verification.