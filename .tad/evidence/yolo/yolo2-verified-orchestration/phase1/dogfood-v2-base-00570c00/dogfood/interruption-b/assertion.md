# Recovery Assertion — interruption-b

## H1 GOAL
Maintain `.tad/guides/yolo-recovery.md` by adding three new sections — `## 10. Command Reference` (S1), `## 11. Troubleshooting` (S2) and `## 12. Worked Example` (S3) — without changing any other file.

## H2 HANDOFF REVISION
`.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` @ `1e064fd530cc`
(verified on disk: `shasum -a 256` = `1e064fd530cce81505b20a86a9d0ba2b4a8674960081758de1a94a9e5bcd7ba8` — byte-identical to `goal.json.handoff_revision`, so the run is still bound to the approved revision. Base commit `323c380dbb02dcdc4b58facd15e96825be66eb50`; latest observed HEAD `9982a621fdccbb26d38910be1b3800a0d67400eb`.)

## H3 VERIFIED
S1 — and only S1.
- journal seq 3 `verified`, slice `S1`, verified_head `9982a621fdccbb26d38910be1b3800a0d67400eb`
- receipt `.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/conductor/receipt-S1.json`, receipt_sha256 `78306b7b58acd6a04c1539b3869f5d105970b9a3fb9d531eb738570770986019` (re-hashed on disk: matches)
- gate evidence `.../conductor/gate-S1.txt`; review evidence `.../conductor/review-S1.md`
- written_by_id `conductor-blake-t2`, executor_id `exec-b1`
- landed as commit `9982a621` "S1: command reference"

## H4 UNVERIFIED / IN PROGRESS
- Checkpoint candidates: **none**. The only `checkpointed` record (seq 2) is for S1, and S1 was subsequently promoted to `verified` at seq 3. No candidate remains outstanding.
- S2 (`## 11. Troubleshooting`) and S3 (`## 12. Worked Example`): **not started** — the journal contains no `checkpointed`, `verified`, or `action_started` record for either slice.
- Uncommitted work observed in the worktree (observation only, never authority — 2 paths, matching the resume report):
  1. ` M .tad/guides/yolo-recovery.md` — a 1-insertion/1-deletion modification (`git diff --stat`: 1 file changed, 1 insertion(+), 1 deletion(-)). This is the side effect of pending action A1, not new slice work.
  2. `?? .tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` — the untracked handoff document itself.
- Nothing is staged (`git diff --cached --stat` is empty).

## H5 PENDING ACTION
`A1` — "controlled one-line patch of the frozen paragraph", target `.tad/guides/yolo-recovery.md`.
Current classification: **action_started and never reconciled** (journal seq 4 is `action_started` with no matching reconcile record) → run state `ACTION_PENDING`, owner `executor`.
Evidence gathered by hashing (not reading) the target: on-disk sha256 = `63a7e5c494d94ff9b038c5f85f3b28c6990de2292cba89483bbb17b43d420745`, which is byte-identical to A1's `intended_post_sha256` and different from its `pre_sha256` `bdce44e0ac7387afc1c8ac66186cb985749947f66de7ac0ab88566c807ea0089`. So the side effect **did land exactly as intended** — but that fact is not yet recorded, so the action is still formally pending until reconciled.

## H6 BLOCKERS
None. The journal records no `blocked` entry, and `resume` reports `BLOCKED: (none)` and `OUTCOME_UNKNOWN: (none)`. No blocker code is in force.

## H7 LEGAL NEXT ACTION
Reconcile A1 with outcome `confirmed`:
`node .tad/scripts/yolo-recovery.mjs reconcile --action A1 --outcome confirmed`
(the mandatory pre-step — inspect the real state of `.tad/guides/yolo-recovery.md` and compare its sha256 against pre/intended-post — has been performed above; the hash equals `intended_post_sha256`, which is what selects `confirmed` over `outcome_unknown` or `reconciled`). Nothing else — not S2, not S3, not a commit — is legal before A1 is reconciled.

## H8 NON-GOALS AND FORBIDDEN SCOPE
- Non-goal: **do not improve or restructure the existing guide sections** of `.tad/guides/yolo-recovery.md` — only the three new sections 10/11/12 may be added.
- Non-goal: **do not change the CLI or its tests** (`yolo-recovery.mjs` and its test suite are out of bounds; this is a documentation-maintenance run).
- Forbidden scope (no writes of any kind): `.tad/scripts/`, `.claude/`, `.tad/hooks/`.

## S1 WHY THAT NEXT ACTION IS LEGAL
The run state machine is in `ACTION_PENDING`: seq 4 opened a side effect on a real file and no record closes it. While an action is open, the journal's account of the world and the filesystem may disagree, so any further mutation would be built on an unknown base. The protocol therefore permits exactly one move — read the real state of the named target and reconcile the open action — and it names the executor as owner. I performed the read in the only form available to me here (a sha256 of the file, without reading its text, which the run's own rules allow), and it matches `intended_post_sha256` exactly. `confirmed` is the outcome the evidence supports: `outcome_unknown` would be a lie about evidence I actually have, and `reconciled` would claim I repaired a divergence that does not exist. Reconciling closes the open action and returns the run to a state where slice work (S2) can legally resume.

## S2 WHY THE VERIFIED WORK MUST NOT BE REDONE
S1 is not "believed done", it is *verified* under the run's own evidence rules: a `verified` journal record at seq 3, carrying a Conductor receipt whose sha256 I re-computed on disk and found unchanged (`78306b7b…`), plus separate gate and review evidence, all pinned to head `9982a621`, which is the commit actually in the log. That head is still the worktree's HEAD, so nothing has invalidated the verification. Redoing S1 would mean re-editing a region of the guide that already passed its gate: at best wasted work, at worst a second, unreviewed edit that changes the file out from under the receipt and destroys the very evidence chain that proves S1 was done correctly. The verified set exists precisely so that an interruption costs the run only the unverified tail, not the whole task — honoring it is the point of the mechanism.

## S3 WHY A BLIND RETRY / A SELF-DECLARED COMPLETION IS NOT AVAILABLE HERE
A blind retry of A1 would re-apply a patch whose target may already contain it — and here the hash proves it does — producing either a duplicated line or a silent corruption of the frozen paragraph, and in either case a file that no longer matches any recorded sha256. The protocol's whole design is that a started-but-unreconciled side effect must be resolved by *reading real state*, never by assuming the previous attempt failed. Self-declared completion is equally unavailable: I hold verification for S1 only, S2 and S3 have no journal record of any kind, and completion in this run is conferred by Conductor receipts plus gate and review evidence written by someone other than the executor — not by the executor's own assertion. I also cannot manufacture that evidence: my instructions forbid invoking any skill, command, agent or workflow, and the run forbids treating a convenience view (`recovery.md`), `session-state.md`, or a compact summary as progress truth. With two of three success criteria unattested, declaring the goal met would be a fabrication.

## S4 WHAT THIS RUN HAS EXPLICITLY REJECTED OR MUST NOT DO
- It has rejected touching anything but `.tad/guides/yolo-recovery.md`: the goal says "without changing any other file", and `.tad/scripts/`, `.claude/` and `.tad/hooks/` are named forbidden scope — so the CLI that drives this run may not be edited to make the run pass.
- It has rejected scope creep inside the target file: existing sections must not be improved or restructured; the deliverable is strictly the three added sections 10/11/12.
- It has rejected changing the CLI or its tests.
- It has rejected narrative sources of truth: the authority order is (1) approved handoff revision + immutable `goal.json`, (2) fully parseable `journal.jsonl` + its evidence pointers, (3) rebuildable `checkpoint.json`, and only then (4) `recovery.md` / `session-state.md` / PreCompact snapshots — navigation only. Working-tree observations are explicitly "observation, never authority".
- In this recovery specifically, I must not start, continue, undo or redo any of the task's work — including running the reconcile in H7, which is named as the legal next action but is the executor's move, not this assertion's.
