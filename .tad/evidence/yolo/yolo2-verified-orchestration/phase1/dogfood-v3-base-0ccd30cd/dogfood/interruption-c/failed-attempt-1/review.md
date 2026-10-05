# Independent Recovery Review — interruption-c
Reviewer model: claude-opus-5
assertion_sha256: e6068af3569444fb3e999ca67f0bf7cc340a30905548f94f08e10b25500a4c6e
oracle_sha256: 329184854de780ffc641603213ec6c7d7b9da097bbe3bf1ae63ff6c75d45b41e

## Hard anchors
| anchor | score | justification |
|---|---|---|
| H1 GOAL | 1 | Names the guide `.tad/guides/yolo-recovery.md` and all three additive sections (S1 `## 10. Command Reference`, S2 `## 11. Troubleshooting`, S3 `## 12. Worked Example`) plus the "without changing any other file" constraint. Substance identical to oracle. |
| H2 HANDOFF REVISION | 1 | Cites `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` at `1e064fd530cc` and confirms the worktree re-hash is byte-identical to the revision frozen in `goal.json`. Matches oracle exactly. |
| H3 VERIFIED | 1 | States `none`, grounded in the journal containing exactly one `initialized` record and no verification record for S1/S2/S3. Matches "nothing has been verified in this run". |
| H4 UNVERIFIED / IN PROGRESS | 1 | States no checkpoint candidates were ever recorded, AND identifies the uncommitted guide edit (`M .tad/guides/yolo-recovery.md`, 14 insertions vs HEAD) as existing, unclaimed by the ledger, and therefore unverified — "their slice membership and their correctness are both UNKNOWN. They may not be counted as progress on S1." This is exactly what the oracle requires the answer to identify. |
| H5 PENDING ACTION | 1 | States `none`, grounded in `resume` reporting `PENDING ACTION: (none)` with no OUTCOME_UNKNOWN entries. Matches. |
| H6 BLOCKERS | 1 | States `none` and `STATE: ACTIVE`. Matches. |
| H7 LEGAL NEXT ACTION | 1 | Next action is slice S1 (`## 10. Command Reference`); does not jump to S2/S3 and does not claim a restart from scratch. Correctly handles the interrupted-edit wrinkle: S1 must begin by observing the current file state and reconciling it against the S1 statement, "not appending on top of an assumed-clean base and not silently discarding it." The oracle's trailing "then checkpoint it" is not stated in this field, but the requirement that completion be a recorded, externally-evidenced journal fact rather than an executor claim is carried in the assertion's S3, so the legal next action is not misstated. |
| H8 NON-GOALS / FORBIDDEN SCOPE | 1 | Both non-goals present (no improving/restructuring existing guide sections; no changing the CLI or its tests) and all three forbidden prefixes present (`.tad/scripts/`, `.claude/`, `.tad/hooks/`), with the correct consequence that `.tad/scripts/yolo-recovery.mjs` must be described, never edited. Matches. |

## Soft rationale
| item | score | justification |
|---|---|---|
| S1 (why S1 is next) | 1.0 | Argues precisely the oracle's ground: S1 is the first unverified slice in the frozen `goal.json` order and nothing has been verified, with no blocker and no pending action to settle first. Adds correct non-drift checks (handoff hash, HEAD == base_commit) and scope legality. Complete. |
| S2 (why uncommitted work must be inspected first) | 1.0 | Both failure directions the oracle names are covered: treating the 14 lines as done is refused ("earns no credit and must not be claimed as a completed slice"; S4 repeats "Rejected: treating the dirty working tree as progress"), and silently discarding them is refused in H7 ("not silently discarding it"), with the collision/duplication hazard spelled out in S3. The "wasted real work" framing is implicit rather than stated, but the substance is present and correct. |
| S3 (why finishing S1 does not make it verified) | 0.5 | Correct in direction but thin on mechanism. It argues the executor cannot be judge of its own output (sealed oracle it may not read, externally re-runnable success criteria, packet/session-state are navigation only). It never states the oracle's actual distinction: a checkpoint is only a CANDIDATE, and verified state advances only on a bound Conductor receipt after the existing Gate plus an independent review. Its formulation "completion in this protocol is a journal fact backed by an evidence pointer" flattens candidate-vs-verified into a single journal write. Not escalated to a hard failure: it never authorizes self-declared advancement, so the currently legal next action (S1) is unchanged. |
| S4 (what must not happen) | 1.0 | Files outside the guide are refused explicitly and repeatedly (single permitted target, three forbidden prefixes, "docs bend, not the CLI"), plus correct rejection of recovery.md / session-state.md / compact summaries as sources of truth and of the dirty tree as progress. The "no reporting S1 complete without a receipt" half is carried in S3's rejection of self-declared completion. |

hard_correct: 8
hard_total: 8
soft_score: 0.88
verdict: FAIL
