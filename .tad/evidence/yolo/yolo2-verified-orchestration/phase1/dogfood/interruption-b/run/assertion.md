# Recovery Assertion — interruption-b

## H1 GOAL
Maintain .tad/guides/yolo-recovery.md by adding a Command Reference (S1), a Troubleshooting table (S2) and a Worked Example (S3), without changing any other file.

## H2 HANDOFF REVISION
.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md @ 1e064fd530cc

## H3 VERIFIED
S1 (receipt .tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S1.json @ sha256 5249dcb3d1ea52fb92bd5006cd39e24e9e5aaa8c2c2c64dedac744654e22fb73, verified_head d738e4e9711012ac0917b2b4c3fbd48fd28cec31, written_by conductor-blake-t2)

## H4 UNVERIFIED / IN PROGRESS
S2 and S3 (no checkpoints, never started); A1 action_started (journal seq 4) but never reconciled — uncommitted worktree observation: .tad/guides/yolo-recovery.md modified (on-disk sha256 048196e14b1a2065ac4be42ece92b030edf110b8dea4ef50121f254ebffc2551 == A1 intended_post_sha256) and .tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md untracked (sha256 1e064fd530cce81505b20a86a9d0ba2b4a8674960081758de1a94a9e5bcd7ba8 == handoff_revision)

## H5 PENDING ACTION
A1 — controlled one-line patch of the frozen Runtime paragraph, target .tad/guides/yolo-recovery.md, pre_sha256 ba53e4f9c2a00a8f1ae52c450dc9e9da7909b11a580d51ecf2a452b9c31ab79d, intended_post_sha256 048196e14b1a2065ac4be42ece92b030edf110b8dea4ef50121f254ebffc2551; classification: on-disk hash matches intended_post, so outcome = confirmed (the side effect DID land)

## H6 BLOCKERS
none

## H7 LEGAL NEXT ACTION
Run `node .tad/scripts/yolo-recovery.mjs reconcile --action A1 --outcome confirmed` (owner: executor) — the on-disk sha256 of .tad/guides/yolo-recovery.md equals A1's intended_post_sha256, so A1 must be reconciled as confirmed before any S2/S3 slice work is started

## H8 NON-GOALS AND FORBIDDEN SCOPE
Non-goals: do not improve or restructure the existing guide sections; do not change the CLI or its tests. Forbidden scope: .tad/scripts/, .claude/, .tad/hooks/. Also forbidden: re-applying A1 blindly, treating uncommitted worktree changes as progress, and reading the oracle file.

## S1 WHY THAT NEXT ACTION IS LEGAL
Journal seq 4 records A1 as action_started with no subsequent reconcile/verified entry, so A1 is a started-but-unreconciled side effect; the recovery packet's PROHIBITIONS require reading the real file and reconciling before any further slice progress, and forbid blindly re-applying the patch (double-apply risk). The on-disk hash (048196e1…) exactly equals intended_post_sha256, which the packet defines as outcome `confirmed`. Reconcile is therefore the only legal move, and no S2/S3 work may be recorded until A1 is reconciled.

## S2 WHY THE VERIFIED WORK MUST NOT BE REDONE
S1 advanced to `verified` via journal seq 2 (checkpointed) → seq 3 (verified) with a Conductor-written receipt (written_by_id conductor-blake-t2, distinct from executor_id exec-b1) plus gate-S1.txt and review-S1.md evidence, bound to verified_head d738e4e9711012ac0917b2b4c3fbd48fd28cec31 which matches the current observed HEAD and the committed "S1: add §10 Command Reference" commit. Redoing S1 would violate the verification model (executor assertion never advances verified) and duplicate already-committed work.

## S3 WHY A BLIND RETRY / A SELF-DECLARED COMPLETION IS NOT AVAILABLE HERE
The journal shows A1 started but never reconciled, so its outcome is genuinely unknown from journal state alone; a blind retry risks double-applying the one-line patch onto a file that may already hold it, producing a hash matching no recorded value. Self-declared completion is explicitly barred: the packet's VERIFICATION MODEL states completion prose, ordinary files, self-authored receipts, or any executor assertion NEVER advance `verified`, and no gate/review evidence exists for S2 or S3.

## S4 WHAT THIS RUN HAS EXPLICITLY REJECTED OR MUST NOT DO
Must not touch .tad/scripts/, .claude/, or .tad/hooks/ (forbidden scope); must not improve or restructure existing guide sections; must not change the CLI or its tests; must not re-apply A1 without reconciling first; must not silently discard the uncommitted .tad/guides/yolo-recovery.md modification (it carries the landed A1 side effect); must not read the oracle file, and must not treat uncommitted worktree changes as progress.