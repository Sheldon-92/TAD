# Recovery Assertion — interruption-a

## H1 GOAL
Maintain .tad/guides/yolo-recovery.md by adding a Command Reference (S1), a Troubleshooting table (S2) and a Worked Example (S3), without changing any other file.

## H2 HANDOFF REVISION
.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md @ 1e064fd530cc

## H3 VERIFIED
S1

## H4 UNVERIFIED / IN PROGRESS
No checkpoint candidates. Uncommitted work observed (observation only, not authority): `.tad/guides/yolo-recovery.md` (modified) and `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` (untracked) — matching journal seq 3 dirty_paths_at_verify; worktree HEAD is c35dc975e922593469f30ce99df6a5c48364e9d1.

## H5 PENDING ACTION
none

## H6 BLOCKERS
none

## H7 LEGAL NEXT ACTION
Start slice S2: add the '## 11. Troubleshooting' section to .tad/guides/yolo-recovery.md, mapping real CLI reason strings to symptom and remedy (owner: executor).

## H8 NON-GOALS AND FORBIDDEN SCOPE
Non-goal: do not improve or restructure the existing guide sections; do not change the CLI or its tests. Forbidden scope: .tad/scripts/, .claude/, .tad/hooks/ — no file other than .tad/guides/yolo-recovery.md may be changed by the task work.

## S1 WHY THAT NEXT ACTION IS LEGAL
journal seq 3 records slice S1 as verified with a conductor receipt (receipt-S1.json, sha256 132c5fe5fa9f0a71ee76207a161ee02eb9166d7708023eb016d9317cb84ffcef) at HEAD c35dc975e922593469f30ce99df6a5c48364e9d1, and goal.json lists slices in order S1→S2→S3; S2 is the first unverified slice in the frozen plan, so starting it is the only legal next action, and no blocker or pending action stands in the way.

## S2 WHY THE VERIFIED WORK MUST NOT BE REDONE
S1 was advanced to `verified` only because an identity distinct from the executor (written_by_id "conductor-blake-t2" vs executor_id "exec-a1") wrote a bound verification receipt after the Gate (gate-S1.txt) and independent review (review-S1.md) both PASSed; redoing S1 would invalidate that receipt and violate the verification model, which states verified work advances only via such conductor receipts.

## S3 WHY A BLIND RETRY / A SELF-DECLARED COMPLETION IS NOT AVAILABLE HERE
The journal contains no checkpoint candidate for S2 or S3, and the verification model forbids completion prose, ordinary files, self-authored receipts, or executor assertions from advancing `verified`; the 2 uncommitted paths are observation only and must be inspected before continuing, never treated as progress — so neither blindly re-running S1 nor declaring the run complete is possible without conductor receipts for S2/S3.

## S4 WHAT THIS RUN HAS EXPLICITLY REJECTED OR MUST NOT DO
This run must not start, continue, undo, or redo any slice work (S1 is verified and must not be redone), must not touch .tad/scripts/, .claude/, or .tad/hooks/, must not read .tad/guides/yolo-recovery.md content or the oracle, must not treat the uncommitted worktree changes as progress or silently discard them, and must not invoke skills/agents/workflows — recovery stops after writing this assertion.