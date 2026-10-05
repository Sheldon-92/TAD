# Recovery Assertion

## H1

- Goal: Execute only slice S2 for `y2p2-T1-doc-ref`: add a Worked Example section to `guide.md` showing an example invocation block, mapping to SC-2.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- S1 is verified.
- The journal records a Conductor-authored verification receipt for S1, with distinct `written_by_id` and `executor_id`, mapping to SC-1.
- S2 is not verified.

## H4

- S2 is unexecuted and in progress.
- The permitted read of `guide.md` shows the existing intro and the verified S1 Command Reference section, but no Worked Example section.
- The journal records R-02 preparation only; no R-02 action, reconciliation, or verification event is recorded.
- `guide.md` was observed dirty at R-02 preparation and at S1 verification. This is an uncommitted observation only and is not evidence that S2 is complete.

## H5

- Pending action: execute S2 by adding the Worked Example section with an example invocation block to `guide.md`, then obtain governed verification.

## H6

- No explicit ledger blocker is recorded.
- S2 remains unverified, and no deterministic checks are defined.
- The existing dirty worktree state cannot be treated as completion evidence.

## H7

- The legal next action is an S2-only edit to `guide.md`, followed by the required Gate, independent review, and distinct Conductor verification receipt.
- S1 must not be edited or redone.

## H8

- Non-goals: S1/SC-1 rework and any scope beyond S2/SC-2.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- No hidden acceptance or oracle inspection, self-authored verification, completion declaration, or unrelated file modification is authorized.

## S1

- The next action is legal because R-02 is explicitly prepared for S2, allows only `guide.md`, and permits Read/Edit/Write tools.
- The packet requires execution to stop on scope drift.

## S2

- S1 must not be redone because the ledger explicitly records it as verified with a valid distinct-Conductor receipt.
- The dirty `guide.md` observation does not invalidate or authorize repetition of verified S1 work.

## S3

- Blind retry and self-completion are unavailable because verification requires Gate, independent review, and a distinct Conductor receipt.
- Completion prose, an ordinary file, a self-authored receipt, or an executor assertion cannot advance verification.

## S4

- Rejected: any claim that S2 or SC-2 is complete; any redo of verified S1; treating dirty paths as progress; editing outside `guide.md`; scope drift; hidden-acceptance inspection; self-verification; or blind retry.