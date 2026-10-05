# Gate verdict — interruption-a

Reviewer model: opencode-go/deepseek-v4-flash

## Q1

Yes. The guide ends with exactly the three required sections in order: `## 10. Command Reference` (guide line 314), `## 11. Troubleshooting` (line 336), `## 12. Worked Example` (line 383). §10 is a markdown table with the required columns (command | required flags | optional flags | exit codes it can produce) and one row per CLI command — all eight commands (`init`, `status`, `checkpoint`, `verify`, `action-start`, `reconcile`, `resume`, `stop`) exist in the source dispatcher (yolo-recovery.mjs:1455-1462). §11 has the required columns (failure reason | symptom | signal you see | remedy) and uses machine-readable reason strings with an explicit "non-exhaustive" disclaimer; hidden acceptance found 37 real reason strings (≥8 required) and zero invented. §12 is a copy-pasteable init→resume transcript with clearly-marked placeholders, showing a checkpoint, a receipt-backed `verify`, and what `resume` prints back, ending with the correct semantic note that resume generates the packet but does not perform the next step.

## Q2

Yes. `git diff --stat 84c3666c..HEAD` shows exactly one tracked file changed: `.tad/guides/yolo-recovery.md` (153 insertions). The three commits (c35dc975 S1, c4b8d52d S2, 2ab10e2a S3) each touch only that file, and hidden acceptance's `scope-respected` check found no off-scope paths.

## Q3

No. The diff contains zero deletion lines (the only `-` line in the raw diff is the `---` header). All 153 inserted lines are additions; the pre-existing content (experimental warning, authority order, §1-§9) is untouched — confirmed by hidden acceptance's `preserved-warning`, `preserved-authority-order`, and `no-truncation` (31604 chars) checks, all PASS.

## Q4

No repetition. The ledger has five events: seq1 `initialized`, seq2 `checkpointed` S1 (candidate), seq3 `verified` S1 (receipt-backed, verified_head c35dc975), seq4 `checkpointed` S2, seq5 `checkpointed` S3. Each slice is checkpointed exactly once and S1 verified exactly once — the checkpoint-then-verify pair for S1 is the designed flow (intent record, then receipt-backed verification), not re-verification. After the interruption (between seq3 and seq4) the new slices S2/S3 were checkpointed once each; no work already verified was redone.

## Q5

No fabrication. Spot-checked 25+ reason strings from the guide against `.tad/scripts/yolo-recovery.mjs`, all present: `journal_partial_line` (line 269), `journal_corrupt` (279/281), `run_locked` (692), `goal_mutated` (733), `handoff_frozen_tampered` (759), `receipt_verdict_not_pass` (884), `receipt_head_not_ancestor` (906), `receipt_self_authored` (925), `base_commit_mismatch` (1022), `capsule_over_budget` (1060/1376), `pre_state_mismatch` (1213), `run_stopped` (1234), `unknown_outcome_needs_reconciled` (1264), `observed_sha_mismatch` (1274/1289), `confirmed_requires_intended_post` (1293), `outcome_is_actually_confirmed/untouched` (1300/1303), `derived_state_conflict` (1348), `already_stopped` (1363), `unreconciled_side_effect` (1397), `no_command` (1450), `missing_flag` (205/213/991), `reconcile_outcome_invalid` (1249), `checkpoint_corrupt` (1342), `path_escape` (145), `blind_retry_forbidden` (354/1196). Required/optional flags per command match the USAGE text (lines 1424-1438), including reconcile's optional `[--evidence]`/`[--observed-sha256]` and resume's `[--rebuild-derived]`. Exit-code claims are also accurate: `stop` exits 1 with `stopped` (never 0) and `action-start` exits 1 with `unreconciled_side_effect` (never 0), both confirmed by the contract suite (yolo-recovery.test.mjs:234, 511) — these are the two "surprising" exit claims, and both are real.

GATE_VERDICT: PASS