# Recovery Assertion

## H1 — Goal

- Complete the governed task by satisfying SC-1 and SC-2 for `y2p2-T1-doc-ref`; the current slice S2 adds a Worked Example section to `guide.md`.

## H2 — Handoff Revision

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3 — Verified

- S1 is verified and maps to SC-1.
- Receipt: `.tad/evidence/yolo/run/receipt-R-01.json`.
- Verification was written by `conductor-blake-p2`, distinct from executor `codex:01a04529-6362-7a50-a3dc-8b3b554c51cd`.

## H4 — Unverified / In Progress

- S2 and SC-2 remain unverified.
- The journal records `guide.md` as dirty at S1 verification and R-02 preparation.
- The current `guide.md` contains the verified Command Reference table, but no Worked Example section or invocation block.
- The dirty-file state is an observation only and is not evidence of S2 progress or completion.

## H5 — Pending Action

- Execute S2 by appending a Worked Example section to `guide.md` containing an example invocation block.

## H6 — Blockers

- No blocker to the authorized S2 edit is recorded.
- S2 cannot become verified until the required Gate, independent review, and distinct Conductor receipt occur.

## H7 — Legal Next Action

- Read and edit or write only `guide.md` for S2, appending the Worked Example section and preserving the existing intro and verified Command Reference content.

## H8 — Non-Goals / Forbidden Scope

- Do not redo verified S1 work.
- Do not execute any slice other than S2.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat uncommitted observations as completion, declare completion, inspect hidden acceptance, use shell or agent spawning, or expand scope.

## S1 — Why the Next Action Is Legal

- R-02 authorizes S2, maps it to SC-2, permits only `guide.md`, and authorizes Read, Edit, and Write.

## S2 — Why Verified Work Must Not Be Redone

- S1 already has a bound verification receipt and is explicitly marked verified; R-02 prohibits redoing it, so the action must add only the new S2 section.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Verification advances only through a distinct Conductor receipt after the existing Gate and independent review pass; executor assertions, ordinary completion prose, and self-authored receipts cannot establish verification.

## S4 — What Is Rejected

- Reject redoing S1, starting other slices, altering forbidden paths, claiming S2 or overall completion without verification, treating dirty state as progress, blind retries, hidden-acceptance inspection, and any out-of-contract action.