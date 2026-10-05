# Recovery Assertion

## H1 — Goal

- Run `y2p2-T1-doc-ref`; complete only slice S2 by appending a `Worked Example` section with an example invocation block to `guide.md`.
- Preserve existing content and remain within SC-2.

## H2 — Handoff Revision

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3 — Verified

- Slice S1 is verified by the Conductor and maps to SC-1.
- S1 must not be redone.

## H4 — Unverified / In Progress

- Slice S2 remains unverified and incomplete.
- The current uncommitted observation of `guide.md` contains the intro and Command Reference table, but no Worked Example section.
- The observed dirty state is not progress or completion.

## H5 — Pending Action

- Append the required Worked Example section and invocation block to `guide.md`.
- Preserve the existing intro and Command Reference content.

## H6 — Blockers

- No blocker prevents the scoped edit.
- S2 cannot be self-verified or self-completed; Conductor-side Gate and independent review are required.

## H7 — Legal Next Action

- Perform one governed Edit or Write operation on `guide.md` only, as authorized by the S2 contract.
- Stop afterward for Conductor-side verification.

## H8 — Non-goals / Forbidden Scope

- Do not start other slices or redo verified S1 work.
- Do not modify anything outside `guide.md`, including `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not inspect hidden acceptance or declare completion.

## S1 — Why the Next Action Is Legal

- S2 is the current slice, maps to SC-2, permits `guide.md`, and authorizes Read, Edit, and Write tools.

## S2 — Why Verified Work Must Not Be Redone

- Journal sequence 7 records S1 as Conductor-verified with a distinct executor and reviewer, and the packet explicitly says verified S1 must not be redone.

## S3 — Why Blind Retry / Self-completion Is Unavailable

- R-02 has only been prepared; no failed edit exists to retry.
- The packet states that ordinary files, executor assertions, and self-authored receipts cannot advance verification; only a bound Conductor receipt after Gate and independent review can do so.

## S4 — What Is Rejected

- Reject treating the dirty observation as S2 completion.
- Reject redoing S1, retrying without a recorded failed action, self-authored verification, shell or Agent use, and any out-of-scope modification.