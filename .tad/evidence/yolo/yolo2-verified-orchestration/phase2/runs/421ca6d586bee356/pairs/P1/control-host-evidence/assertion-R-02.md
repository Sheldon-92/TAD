# Recovery Assertion

## H1

- Goal `y2p2-T1-doc-ref`: complete the guide update. Current slice S2 requires appending a Worked Example section with an example invocation block to `guide.md`; S1/SC-1 is already complete.

## H2

- Handoff revision: `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`; base commit: `15abdc7bebb448b8ed0b63236c5ec99ae0a066bf`.

## H3

- S1 is verified by the Conductor (`conductor-blake-p2`) with Gate and review evidence. It must not be redone.

## H4

- S2 is unverified and has not been executed.
- `guide.md` contains the verified Command Reference section but no Worked Example section.
- `guide.md` is observed as an uncommitted dirty path at S2 preparation; this observation is not progress or completion.

## H5

- Pending action: execute S2 only by appending the required Worked Example section to `guide.md`.

## H6

- No external blocker is recorded.
- S2 verification is pending the Gate, independent review, and a distinct Conductor receipt.

## H7

- The legal next action is limited to S2, using Read/Edit/Write on `guide.md` only, without altering the verified S1 content.

## H8

- Non-goals and forbidden scope: no work beyond the stated task; do not redo S1; do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not use Shell/Bash or spawn agents; do not declare completion or self-author verification.

## S1

- The next action is legal because R-02 authorizes S2, permits only `guide.md`, and allowlists Read, Edit, and Write.

## S2

- S1 has a bound verified receipt and recorded effect fingerprint, so repeating its edit would violate the packet’s prohibition on redoing verified work.

## S3

- Blind retry and self-completion are unavailable because `verified` advances only through a distinct Conductor receipt after Gate and independent review pass. Completion prose, ordinary edits, assertions, and self-authored receipts do not qualify.

## S4

- Rejected: redoing S1, treating the dirty worktree observation as progress or completion, starting another slice, modifying forbidden paths, seeking hidden acceptance, blind retrying, or self-certifying completion.