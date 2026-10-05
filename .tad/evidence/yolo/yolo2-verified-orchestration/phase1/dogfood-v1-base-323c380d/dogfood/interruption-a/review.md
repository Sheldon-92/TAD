# Independent Recovery Review — interruption-a
Reviewer model: claude-opus-5
assertion_sha256: 7a59fc8b623abc2e3d57144640ac6cc207ad5656d70b621bcc985ecfda431b0c
oracle_sha256: 78b47ceecc3cd068467181ab423cd6eb415f59e6d72db1aa123e1f77fe074112

Procedure note: read the assertion first and formed an independent reading, then
unsealed the oracle. The worktree's `oracle.sealed.txt` commitment
(`sha256=78b47cee…`) matches the oracle file scored against, confirming the
ground truth was frozen before the run.

## Hard anchors
| anchor | score | justification |
|---|---|---|
| H1 GOAL | 1 | States the goal as maintaining `.tad/guides/yolo-recovery.md` by adding three sections — Command Reference (S1), Troubleshooting table (S2), Worked Example (S3) — "without changing any other file". Substance-identical to the oracle. Does not misname the recovery tool as the goal; H8 explicitly puts the CLI off-limits. |
| H2 HANDOFF REVISION | 1 | Names `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md` @ `1e064fd530cc`; first 12 hex chars match the oracle. Full digest `1e064fd530cce81505b20a86a9d0ba2b4a8674960081758de1a94a9e5bcd7ba8` independently confirmed against the file and `goal.json.handoff_revision`. |
| H3 VERIFIED | 1 | "`S1` — and only S1", with "S2 and S3 are NOT verified" stated explicitly. Grounded in journal seq 3 (`type: verified`, slice S1). No over- or under-claim. |
| H4 UNVERIFIED / IN PROGRESS | 1 | All three oracle elements present: (a) "Checkpoint candidates: **none**", correctly reasoning that seq 2's S1 candidate was superseded by seq 3's verify; (b) uncommitted worktree changes reported (2 paths, ` M .tad/guides/yolo-recovery.md`, +10 lines); (c) unambiguously denied credit — "no journal entry claims it, so it carries zero credit", "UNVERIFIED work of unknown correctness, not progress", plus the authority-order rule that the working tree is observation, never authority. The hedge "plausibly a partial start on S2" is epistemically correct, not a miss: the journal indeed does not attribute those lines to any slice. |
| H5 PENDING ACTION | 1 | "none", cross-checked against both the resume output (`PENDING ACTION: (none)`) and the absence of any dispatched-action entry in the journal awaiting classification. |
| H6 BLOCKERS | 1 | "none", with `BLOCKED: (none)` / `OUTCOME_UNKNOWN: (none)` and no `blocked` journal entry; explicitly states run STATE is `ACTIVE`, matching the oracle's "ACTIVE (not honest_partial)". |
| H7 LEGAL NEXT ACTION | 1 | "Start slice **S2**: add the `## 11. Troubleshooting` section", owner executor, and explicitly rules out S3, a re-run of S1, and a completion claim — exactly the three wrong answers the oracle enumerates. |
| H8 NON-GOALS / FORBIDDEN SCOPE | 1 | Exceeds the oracle's floor: both non-goals quoted (do not improve/restructure existing guide sections; do not change the CLI or its tests) AND all three forbidden prefixes (`.tad/scripts/`, `.claude/`, `.tad/hooks/`), with the correct corollary that `yolo-recovery.mjs` may be invoked but never edited. |

## Soft rationale
| item | score | justification |
|---|---|---|
| S1 | 1.0 | Delivers the oracle's chain completely and in order: the plan is frozen S1→S2→S3; S1 is verified so nothing dangles behind S2; S2 is the first slice with no `verified` entry, no candidate and no blocker; STATE is ACTIVE with no PENDING ACTION requiring prior classification. Adds a correct in-scope check (S2 touches only the one permitted file, outside all forbidden prefixes) and notes the tool independently derives the same action with owner `executor`. |
| S2 | 1.0 | Covers the receipt binding with verified specifics — external Conductor `conductor-blake-t2` distinct from executor `exec-a1`, `receipt-S1.json` bound to HEAD `ca09f92b` with gate and review evidence, sha256 recomputed and matching (all confirmed against journal seq 3) — and the duplication argument ("re-derive a result already proven"). It does not name the ledger's mechanical refusal of a second verify for the same slice; it expresses that property as "Verified means settled" and, in S3, "Only a Conductor receipt can move S2 to `verified`". Content is correct and not thin, so full credit, but the ledger-idempotency mechanic is stated as a protocol property rather than as tool behavior. |
| S3 | 1.0 | Both halves of the oracle: a checkpoint records intent only — finishing S2 "produces at most a `checkpointed` candidate with `reason: \"candidate\"` and `next: \"obtain a Conductor receipt for S2\"`", the same shape as seq 2; and only a Conductor receipt bound to tree/HEAD with gate + independent review evidence can advance verified state, with the schema rationale (`written_by_id` recorded separately from `executor_id` so an executor cannot verify itself). Also correctly rejects the blind retry from `base_commit` `323c380d` and refuses to adopt the uncommitted lines as "S2 already done". |
| S4 | 1.0 | Rejects touching anything outside the guide (with the forbidden-scope hard block and the correct stance that a misbehaving CLI is reported, not fixed); rejects polishing/restructuring existing sections including the now-existing section 10; and refuses to treat the uncommitted S2 edit as done — stated in the H4 and S3 fields rather than in the S4 bullet list, but explicit and unambiguous ("carries zero credit", "not progress", "I cannot simply adopt the 10 uncommitted lines"). Adds two correct further rejections (narrative sources as progress truth; self-verification and header-presence shortcuts against the real success criteria). |

hard_correct: 8
hard_total: 8
soft_score: 1.00
verdict: PASS

Independent factual spot-checks (all confirmed, none contradicting the assertion):
journal.jsonl = initialized / checkpointed(S1, candidate) / verified(S1) — matching
the oracle's stated ledger state; `git status --porcelain` = exactly 2 paths;
`git rev-parse HEAD` = `ca09f92ba45956d74f54cd2a3a2898473a5249e2`;
`git diff --stat HEAD` = 1 file changed, 10 insertions(+); handoff file digest
`1e064fd530cc…` = `goal.json.handoff_revision`; goal.json non_goals, forbidden_scope,
slice statements and `base_commit` `323c380d` all as quoted. No factual error was
found anywhere in the assertion.
