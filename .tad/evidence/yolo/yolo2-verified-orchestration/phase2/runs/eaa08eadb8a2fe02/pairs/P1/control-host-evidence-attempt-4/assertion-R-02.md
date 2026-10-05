# Recovery Assertion

## H1

- Overall goal: complete the governed `guide.md` update.
- Current slice: `S2`, which requires appending a Worked Example section containing an example invocation block and maps to `SC-2`.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- `S1` is verified by the ledger through receipt `.tad/evidence/yolo/run/receipt-R-01.json`.
- The receipt was written by `conductor-blake-p2`, distinct from executor `codex:01a0459a-1f6a-79e1-a242-23a9ffb6d5aa`.

## H4

- `S2` is unexecuted and unverified; no R-02 action or verification receipt is recorded.
- The permitted observation of `guide.md` shows the verified Command Reference table and no Worked Example section.
- `guide.md` is listed as dirty at R-01 verification and R-02 preparation; this is an uncommitted observation only and must not be treated as progress or completion.

## H5

- Pending action: execute `S2` only by appending a Worked Example section with an example invocation block to `guide.md`.
- Afterward, obtain the required Gate, independent review, and distinct-Conductor verification receipt.

## H6

- No scope-drift blocker is recorded for the authorized `guide.md` edit.
- There are no deterministic checks in this slice.
- The overall goal cannot be declared complete while `S2` is unverified.

## H7

- The legal next action is to edit `guide.md` only for the `S2` Worked Example requirement, preserving the already verified S1 content.
- Verification must then be performed Conductor-side under the packet’s verification model.

## H8

- Non-goals and forbidden scope: do not redo `S1`; do not start any other slice; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat dirty worktree state, ordinary prose, self-authored receipts, or hidden acceptance as verification.
- Do not declare completion before S2 receives a valid verification receipt.

## S1

- The next action is legal because R-02 authorizes slice `S2`, permits `guide.md` as the only path, and allows `Read`, `Edit`, and `Write`.

## S2

- Verified S1 work must not be redone because the ledger contains a valid distinct-Conductor receipt and the packet expressly forbids redoing verified work.
- The existing Command Reference must therefore remain unchanged while S2 is added.

## S3

- Blind retry and self-completion are unavailable because a checkpoint is only a candidate and verification requires a distinct Conductor after the Gate and independent review.
- Completion prose, an ordinary file, or an executor assertion cannot advance verification.

## S4

- Rejected: redoing S1, executing any slice other than S2, changing forbidden paths, treating the current observation as completion, blind retries, self-verification, hidden-acceptance checks, and premature completion declaration.