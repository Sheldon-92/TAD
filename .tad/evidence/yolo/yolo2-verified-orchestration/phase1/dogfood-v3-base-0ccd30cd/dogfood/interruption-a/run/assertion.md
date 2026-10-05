# Recovery Assertion — interruption-a

## H1 GOAL
Maintain `.tad/guides/yolo-recovery.md` by adding three sections — Command Reference (`## 10.`), Troubleshooting (`## 11.`), Worked Example (`## 12.`) — as slices S1/S2/S3, without changing any other file.

## H2 HANDOFF REVISION
`.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` @ `1e064fd530cc`

## H3 VERIFIED
`S1` — receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S1.json` (sha256 `230812a58402285152c09b3dde7dc58a3d88b1f393b2450cdd014091311f2c17`), verified at HEAD `1738310c873904f4d36c1bf38e731083a6ccbf45`, written by `conductor-blake-t2` (≠ executor `exec-a1`) with gate evidence `conductor/gate-S1.txt` and review evidence `conductor/review-S1.md` (journal seq 3).

## H4 UNVERIFIED / IN PROGRESS
No checkpoint candidates in journal (journal seq 2 `checkpointed` for S1 was only a candidate and was superseded by seq 3 `verified`). Working-tree observation only (never authority): `.tad/guides/yolo-recovery.md` modified (14 insertions on top of committed HEAD) and `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` untracked. `S2` and `S3` remain unverified.

## H5 PENDING ACTION
None — journal contains no pending-action entry; resume output reports PENDING ACTION (none).

## H6 BLOCKERS
None — resume output reports BLOCKED (none) and OUTCOME_UNKNOWN (none).

## H7 LEGAL NEXT ACTION
Start slice S2: add the `'## 11. Troubleshooting'` section to `.tad/guides/yolo-recovery.md` — the first unverified slice in the frozen plan, owned by `executor`.

## H8 NON-GOALS AND FORBIDDEN SCOPE
Non-goals: do not improve or restructure the existing guide sections; do not change the CLI or its tests. Forbidden scope: `.tad/scripts/`, `.claude/`, `.tad/hooks/`.

## S1 WHY THAT NEXT ACTION IS LEGAL
`S1` is the only slice advanced to `verified`, via a conductor-written receipt from an identity (`conductor-blake-t2`) distinct from the executor (`exec-a1`), after Gate and independent review both PASSed at observed head `1738310c`. `S2` is the next slice in `goal.json`'s frozen order, is unverified, and has no blockers — the plan requires executing slices in order, so S2 is the single legal next action.

## S2 WHY THE VERIFIED WORK MUST NOT BE REDONE
`S1` was verified by the journal's authority chain (seq 3): a bound receipt (`receipt-S1.json`, sha256 `230812a5...`) validated at head `1738310c8739`, backed by gate and independent-review evidence written by an identity distinct from the executor. The verification model requires this exact chain before `verified` advances; redoing S1 would discard recorded verified work and violate the recovery protocol, which explicitly says verified slices must not be redone.

## S3 WHY A BLIND RETRY / A SELF-DECLARED COMPLETION IS NOT AVAILABLE HERE
A checkpoint is only a CANDIDATE (journal seq 2 for S1 confirms this — it recorded intent, not verification). `verified` advances ONLY when a Conductor (`written_by_id` ≠ `executor_id`) writes a bound receipt after Gate and an independent review have both PASSed. No receipt exists for S2 or S3, so no blind retry can be certified, and any executor assertion, completion prose, or self-authored receipt never advances `verified` — a self-declared completion would be invalid.

## S4 WHAT THIS RUN HAS EXPLICITLY REJECTED OR MUST NOT DO
- Must not treat uncommitted worktree changes (modified guide, untracked handoff file) as progress or as done — observation only.
- Must not self-declare completion of S2/S3 without a conductor receipt after Gate + review.
- Must not redo verified slice S1.
- Must not touch forbidden scope `.tad/scripts/`, `.claude/`, `.tad/hooks/`, nor improve/restructure existing guide sections, nor change the CLI or its tests.
- Must not read the oracle file, the task description, handoff contents, or session state.