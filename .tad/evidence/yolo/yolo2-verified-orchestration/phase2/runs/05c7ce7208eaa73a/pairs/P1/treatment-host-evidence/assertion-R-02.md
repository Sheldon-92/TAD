# Recovery Assertion

## H1

- Goal: complete run `y2p2-T1-doc-ref` by preserving existing `guide.md` content, retaining the verified Command Reference, and adding the S2 Worked Example section.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base commit `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- S1 is verified and must not be redone. It maps to SC-1 and has a Conductor-written verification receipt.

## H4

- S2 is unverified and in progress.
- The journal records R-02 prepared but no S2 action, receipt, or verification.
- The current uncommitted observation of `guide.md` contains the Command Reference table and no Worked Example. Per the packet, this observation is not progress or completion.

## H5

- Pending action: execute S2 only by appending a Worked Example section with an example invocation block to `guide.md`, then obtain Conductor-side verification.

## H6

- This recovery turn is read-only and explicitly forbids task work, so S2 cannot be executed here.
- No additional packet-level blocker is recorded.

## H7

- The legal next action in this turn is to stop and hand off the pending S2 action.
- In an authorized execution context, perform only the permitted edit to `guide.md`, followed by the required Gate, independent review, and Conductor receipt.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo S1, start another slice, treat dirty changes as completion, self-verify, declare completion, or inspect hidden acceptance.

## S1

- The next governed action is legal because R-02 explicitly authorizes slice S2, maps it to SC-2, permits only `guide.md`, and allows Read, Edit, and Write.

## S2

- S1 must not be redone because the ledger marks it verified, explicitly says “DO NOT redo,” and records distinct executor and Conductor identities plus the verification receipt.

## S3

- Blind retry and self-completion are unavailable because verification requires a Conductor receipt after the existing Gate and independent review. Executor assertions, ordinary file content, or self-authored receipts cannot advance verification; strict Phase 2 also denies shell/Bash and Agent spawning.

## S4

- Rejected: writing in this read-only turn; editing outside `guide.md`; redoing S1; executing other slices; treating uncommitted observations as done; self-authored verification; blind retry; hidden-acceptance lookup; and any forbidden-scope changes.