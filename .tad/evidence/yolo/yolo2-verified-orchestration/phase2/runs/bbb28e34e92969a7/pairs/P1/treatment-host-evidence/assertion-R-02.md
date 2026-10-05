# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T1-doc-ref`: append the S2 Worked Example section to `guide.md`, while preserving existing content.
- S2 maps to SC-2: show an example invocation block.

## H2 — Handoff Revision

- Handoff revision: `17b14aa13677`.
- Base commit: `03c7066e15`.

## H3 — Verified

- S1 is verified in journal entry 7 by distinct Conductor `conductor-blake-p2`.
- S1 maps to SC-1 and must remain untouched.
- The current `guide.md` read shows the existing intro and Command Reference table.

## H4 — Unverified / In Progress

- S2 is unverified and pending.
- R-02 was prepared, but no S2 action, reconciliation, or verification receipt is recorded.
- Current `guide.md` contains no observed Worked Example section.
- Uncommitted observations include dirty `guide.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these observations are not evidence that S2 is complete.

## H5 — Pending Action

- The pending work is limited to appending the S2 Worked Example section with an example invocation block to `guide.md`.
- No task work is performed by this assertion.

## H6 — Blockers

- No blocker to the authorized S2 edit is recorded.
- S2 cannot be treated as verified until the required governed Conductor verification occurs.

## H7 — Legal Next Action

- Perform one governed `Edit` or `Write` operation on `guide.md` only, implementing S2, then stop for Gate, independent review, and Conductor verification.

## H8 — Non-Goals and Forbidden Scope

- No scope beyond the stated task.
- Do not redo verified S1 or start another slice.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not inspect hidden acceptance, treat dirty observations as completion, or declare completion from executor prose.
- Shell/Bash execution and Agent spawning are outside the permitted strict Phase-2 scope.

## S1 — Why the Next Action Is Legal

- R-02 explicitly authorizes slice S2, permits only `guide.md`, and allows `Read`, `Edit`, and `Write`.
- The proposed action directly implements the packet’s S2 outcome without scope drift.

## S2 — Why Verified Work Must Not Be Redone

- Journal entry 7 records S1 as verified with a bound Conductor receipt.
- The packet explicitly states “S1 verified (DO NOT redo)” and prohibits repeating verified work.

## S3 — Why Blind Retry/Self-Completion Is Unavailable

- No S2 action has yet been recorded, so blind retry has no governed action to reconcile.
- Verification advances only through a distinct Conductor receipt after Gate and independent review pass.
- Executor assertions, ordinary file content, completion prose, or self-authored receipts cannot establish verification.

## S4 — What Is Rejected

- Reject any claim that S2 or SC-2 is already complete or verified.
- Reject redo of S1, edits outside `guide.md`, other slices, forbidden paths, hidden-acceptance inspection, and treating uncommitted observations as done.
