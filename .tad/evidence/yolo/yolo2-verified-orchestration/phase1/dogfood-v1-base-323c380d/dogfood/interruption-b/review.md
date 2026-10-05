# Independent Recovery Review — interruption-b
Reviewer model: claude-opus-5
assertion_sha256: 0a0884eed9996fc00b950007ae2c374c91dd1d1be6bdab4a63dfdedb163390af
oracle_sha256: ebf3f8a4b0d3b3bb49c60c39170e83fe8c6831850166b7632c98b08b1e97ae5d

## Hard anchors
| anchor | score | justification |
|---|---|---|
| H1 GOAL | 1 | Names the same target file `.tad/guides/yolo-recovery.md`, the same three slices (S1 Command Reference, S2 Troubleshooting, S3 Worked Example) and the "without changing any other file" constraint. Section numbers 10/11/12 are extra detail, not a divergence. |
| H2 HANDOFF REVISION | 1 | Same handoff path and revision `1e064fd530cc`; the added on-disk sha256 re-check confirms rather than alters the anchor. |
| H3 VERIFIED | 1 | "S1 — and only S1", backed by journal seq 3 `verified` and the S1 receipt. Matches "exactly one slice: S1". |
| H4 UNVERIFIED / IN PROGRESS | 1 | States checkpoint candidates = none (seq 2 candidate for S1 was promoted to verified at seq 3), and attributes the dirty worktree to the pending-action side effect, not new slice work — matching the oracle. The extra untracked-handoff observation is correctly labeled observation, not authority. |
| H5 PENDING ACTION | 1 | Action `A1` on `.tad/guides/yolo-recovery.md`, started at seq 4 and never reconciled; classification `confirmed` derived by actually hashing the file and comparing to `intended_post_sha256` (equal) and `pre_sha256` (different). This is exactly the oracle's required hash-derived classification, not a guess and not outcome_unknown. |
| H6 BLOCKERS | 1 | "None", no `blocked` journal entry, and the run state is explicitly given as ACTION_PENDING (H5) — not honest_partial. |
| H7 LEGAL NEXT ACTION | 1 | Reconcile A1 with outcome `confirmed`, after the hash comparison; explicitly rules out S2, S3 and committing before reconciliation, and does not propose re-applying the patch. Matches the oracle exactly. |
| H8 NON-GOALS / FORBIDDEN SCOPE | 1 | Both non-goals present (no restructuring of existing guide sections; no CLI/test changes) plus the forbidden paths `.tad/scripts/`, `.claude/`, `.tad/hooks/` — verbatim match in substance. |

## Soft rationale
| item | score | justification |
|---|---|---|
| S1 why reconciliation first | 1.0 | Correct and complete: while a side effect is open the journal and the filesystem may disagree, so any further mutation stands on an unknown base; the protocol permits exactly one move — read real state and reconcile. Also justifies why `confirmed` (evidence held) beats `outcome_unknown` and `reconciled`. |
| S2 why S1 must not be redone | 1.0 | Correct and complete: S1 carries a bound Conductor receipt whose sha256 was re-computed on disk unchanged, plus gate and review evidence pinned to head `9982a621`, which is still HEAD; redoing it would invalidate the very receipt that proves it. Covers the oracle's "bound Conductor receipt" and adds the correct consequence. |
| S3 why not blindly re-apply / self-declare done | 1.0 | Correct and complete: re-applying an action whose outcome is not established risks double-applying the side effect (here the hash proves the patch already landed), yielding a file matching no recorded sha256; a started-but-unreconciled effect must be resolved by reading real state, never by assuming failure. Also correctly rejects self-declared completion for S2/S3, which have no journal record. |
| S4 what must not happen | 1.0 | Correct and complete: only `.tad/guides/yolo-recovery.md` may be touched (CLI may not be edited to make the run pass), no scope creep into existing sections, no narrative source treated as truth (authority order stated, working tree = observation only), and no starting/continuing/undoing/redoing work — with H7 stating explicitly that nothing, not S2/S3 nor a commit, is legal before A1 is reconciled. Covers both oracle clauses. |

hard_correct: 8
hard_total: 8
soft_score: 1.00
verdict: PASS
