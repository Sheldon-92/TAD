# Recovery Assertion — interruption-c

## H1 GOAL
Maintain .tad/guides/yolo-recovery.md by adding a Command Reference (S1: '## 10. Command Reference'), a Troubleshooting table (S2: '## 11. Troubleshooting') and a Worked Example (S3: '## 12. Worked Example'), without changing any other file.

## H2 HANDOFF REVISION
.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md @ 1e064fd530cc

## H3 VERIFIED
none

## H4 UNVERIFIED / IN PROGRESS
Checkpoint candidates: none recorded (journal.jsonl contains only seq 1 "initialized" at 2026-08-25T19:17:50.772Z). Observed uncommitted work in the frozen worktree (observation only, never authority): `.tad/guides/yolo-recovery.md` is modified (+7 lines) with a partial start of S1 — a "## 10. Command Reference" table containing only `init` and `status` rows (incomplete; success criteria require every CLI command); `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` is untracked (content not read, per prohibition). HEAD is unchanged at base commit 84c3666c4b8d658ecfd737c5305728f0e2152aea.

## H5 PENDING ACTION
none

## H6 BLOCKERS
none

## H7 LEGAL NEXT ACTION
Start slice S1: add the '## 10. Command Reference' section to .tad/guides/yolo-recovery.md — it is the first unverified slice in the frozen plan, and all slices before it are verified (vacuously, none exist). Owner: executor.

## H8 NON-GOALS AND FORBIDDEN SCOPE
Non-goals: do not improve or restructure the existing guide sections; do not change the CLI or its tests. Forbidden scope: .tad/scripts/, .claude/, .tad/hooks/. Also forbidden by this run's protocol: reading .tad/active/session-state.md, handoff contents, the oracle file, or chat-derived files.

## S1 WHY THAT NEXT ACTION IS LEGAL
The journal records only the "initialized" event; verified_slices, unverified_slices, blockers and pending action are all empty, so there is no in-flight action and no gate that blocks S1. The frozen plan's slice order is S1 → S2 → S3, and S1 targets exactly the goal file (.tad/guides/yolo-recovery.md) within allowed scope. Starting S1 is therefore the single legal next action.

## S2 WHY THE VERIFIED WORK MUST NOT BE REDONE
There is no verified work — the verified list is empty, and the recovery packet states nothing may be treated as done without a Conductor-written bound verification receipt (written_by_id != executor_id) after Gate + independent review PASS. The partial Command Reference table in the working tree is executor-authored, unverified in-progress work, and per PROHIBITIONS it must be inspected and continued or consciously discarded — never silently redone from scratch or silently trusted.

## S3 WHY A BLIND RETRY / A SELF-DECLARED COMPLETION IS NOT AVAILABLE HERE
The verification model forbids completion prose, ordinary files, self-authored receipts, or executor assertions from advancing `verified`; only a Conductor receipt can. A blind retry of S1 could clobber the existing partial table (the +7 line diff), and the run's success criteria (documenting every command with flags and exit codes) are not yet met, so completion cannot be self-declared. The run state is ACTIVE and must be driven by journaled, verified checkpoints.

## S4 WHAT THIS RUN HAS EXPLICITLY REJECTED OR MUST NOT DO
Must not modify anything outside .tad/guides/yolo-recovery.md (forbidden scope: .tad/scripts/, .claude/, .tad/hooks/); must not change the CLI or its tests; must not restructure existing guide sections; must not read the handoff content, session-state, compact summaries, or oracle file; must not treat the uncommitted working-tree changes as progress or discard them without inspection; must not self-verify or self-complete any slice.