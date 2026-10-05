# Recovery Assertion

## H1 — Goal

- Run `y2p2-T1-doc-ref` slice S2: append a `## Worked Example` section with an example invocation block to `guide.md`.
- Do not change existing content. S2 maps to SC-2.

## H2 — Handoff Revision

- Handoff: `handoff.md` at revision `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `92945c39a0f22bea5903c4351f94968437d1ce99`.

## H3 — Verified

- S1 is verified and must not be redone.
- The verified work maps to SC-1 and has receipt `.tad/evidence/yolo/run/receipt-R-01.json`, written by distinct Conductor `conductor-blake-p2`.

## H4 — Unverified / In Progress

- S2 remains unverified and no R-02 action is recorded.
- The permitted read of `guide.md` shows the existing intro and verified Command Reference table, but no Worked Example section.
- The R-02 preparation ledger observed `guide.md` as dirty at SHA `c167f436e7b8d9e42e1f3888158e0ab445f48defa871b997877860d22c8c9a68`.
- Uncommitted changes are observations only and are not treated as progress or completion.

## H5 — Pending Action

- Perform the governed S2 edit by appending the Worked Example section to `guide.md`.

## H6 — Blockers

- S2 has not yet been executed or independently verified.
- This recovery turn is observation-only: the user prohibits task work and the environment provides no write access.
- Verification remains unavailable to the executor until the Conductor-side Gate and independent review pass.

## H7 — Legal Next Action

- A governed executor may use only Read, Edit, and Write on `guide.md` to complete S2, then stop.
- The Conductor may subsequently perform the required Gate and independent review and write the bound verification receipt.

## H8 — Non-Goals / Forbidden Scope

- No scope beyond the stated task.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start other slices, redo verified S1 work, inspect hidden acceptance, use Shell/Bash or Agent spawning, or declare completion without verification.

## S1 — Why the Next Action Is Legal

- S2 is the current slice explicitly authorized by the execution packet, maps to SC-2, allows only `guide.md`, and permits Read, Edit, and Write.

## S2 — Why Verified Work Must Not Be Redone

- S1 already has a Conductor-written verification receipt with a distinct `written_by_id` from the executor and is explicitly marked verified.
- The packet prohibits redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- No R-02 action has failed or produced a retryable outcome.
- A candidate checkpoint, completion prose, ordinary file, or self-authored receipt cannot advance verification.
- Only a distinct Conductor can verify S2 after the Gate and independent review pass.

## S4 — What Is Rejected

- Reject claims that S2 or the overall goal is complete.
- Reject treating the dirty `guide.md` state as verified S2 progress.
- Reject any redo of S1, any out-of-scope modification, any other slice, any hidden-acceptance lookup, and any executor-authored completion or verification claim.