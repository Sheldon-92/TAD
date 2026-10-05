# Recovery Assertion

## H1

- Goal: Complete the governed task by preserving the verified Command Reference in `guide.md` and adding a Worked Example section with an example invocation block.
- Current slice: `S2`, mapping to `SC-2`.

## H2

- Handoff: `handoff.md` at revision `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- `S1` is verified by the ledger through receipt `.tad/evidence/yolo/run/receipt-R-01.json`.
- Verification was written by distinct Conductor `conductor-blake-p2` for executor `codex:01a04b2d-5007-7bd1-bc5a-8d87fa3ea90b`, mapping to `SC-1`.

## H4

- `S2` remains unverified and in progress.
- The permitted observation of `guide.md` shows the verified Command Reference table, but no Worked Example section.
- R-02 preparation recorded `guide.md` and other paths as dirty; under the packet, these are observations only and must not be treated as progress or completion.
- No S2 action, Gate pass, independent review, or Conductor receipt is recorded.

## H5

- Pending action: execute `S2` only by appending a Worked Example section with an example invocation block to `guide.md`, preserving all existing text.

## H6

- This recovery agent is explicitly denied write access, so it cannot perform the pending edit.
- No deterministic checks are defined, and S2 has no verification evidence yet.

## H7

- Legal next action: an authorized executor may use the allowlisted `Read`, `Edit`, and `Write` tools on `guide.md` only to complete S2, then stop for governed verification.

## H8

- Non-goals and forbidden scope: no scope beyond the stated task; do not redo verified S1; do not execute other slices; do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not inspect hidden acceptance; do not declare completion.

## S1

- The next action is legal because the packet designates S2 as the current slice, maps it to SC-2, permits only `guide.md`, and allowlists `Read`, `Edit`, and `Write`.

## S2

- Verified S1 work must not be redone because the packet expressly forbids redoing verified work and the ledger contains a bound Conductor receipt for it. The existing Command Reference must remain unchanged.

## S3

- Blind retry and self-completion are unavailable because verification requires a distinct Conductor receipt after Gate and independent review both pass. Executor assertions, ordinary file content, completion prose, or self-authored receipts cannot establish verification.

## S4

- Rejected: modifying or redoing S1, executing other slices, changing paths outside `guide.md`, touching forbidden directories, treating dirty observations as completion, self-verifying, declaring completion, or seeking hidden acceptance.