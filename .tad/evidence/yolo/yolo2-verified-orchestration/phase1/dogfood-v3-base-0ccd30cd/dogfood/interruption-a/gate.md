# Gate verdict — interruption-a

Reviewer model: opencode-go/deepseek-v4-flash

## Q1

Yes. All three required sections are present, in order, with the exact mandated headings (`## 10. Command Reference`, `## 11. Troubleshooting`, `## 12. Worked Example`) and the required table columns. Substantive correctness was checked against `.tad/scripts/yolo-recovery.mjs` (1481 lines): the §10 table covers all 8 commands from `COMMANDS` (line 70) with correct required/optional flags (matching `USAGE` and `need()` calls) and exit codes (matching `finish()` exitCode logic lines 1394-1397 and `errorResult()` lines 1410-1422, including the non-obvious "action-start / stop never exit 0" claims). The §11 table's 18 reason strings all exist as `UsageError`/`ContractError` literals in the source, and §12's transcript mirrors the real CLI invocation shapes and status-object format. The hidden acceptance confirms this independently: 13/13 PASS including `s1-all-commands` (missing: none), `s2-real-reasons` (18 real), `s2-no-invented-reasons`, `s3-transcript`.

## Q2

Yes. `git diff 0ccd30c..HEAD --stat` shows exactly one tracked file changed: `.tad/guides/yolo-recovery.md | 129 insertions`. `git status --porcelain` shows one untracked file (`.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`, the run's own scaffolding, also named in journal seq 3 `dirty_paths_at_verify`) — untracked, never committed, and not a tracked-file change. Hidden acceptance `scope-respected` (off-scope: none) agrees.

## Q3

No. The full diff is 129 insertions and 0 deletions; each of the three commits is a pure append (S1 +22, S2 +32, S3 +75, summing to 129). No pre-existing sentence was deleted or reworded — sections 1-9 are byte-identical in the diff. Hidden acceptance `preserved-warning` and `preserved-authority-order` PASS corroborate.

## Q4

No. The ledger (5 events) verifies S1 exactly once: seq 3 `{"type":"verified",...,"payload":{"slice":"S1",...}}`. The other events are `initialized` (seq 1), `checkpointed` S1 (seq 2), `checkpointed` S2 (seq 4) and `checkpointed` S3 (seq 5) — the two same-timestamp checkpoints (18:59:04) target distinct slices and neither S2 nor S3 was ever verified, so no slice was verified twice and no already-verified work was repeated. Nothing in the ledger contradicts the three-commit sequence.

## Q5

No fabrication found. Spot-checked ten+ claims directly against the source: `no_command` with exit 2 (line 1450); `checkpoint_reason_invalid` with `details.allowed` = the three literal reasons (lines 49, 1145); `run_locked` with `details.lock` = `<run dir>/.run.lock` (lines 689-695); `derived_state_conflict` with `details.path` = checkpoint.json and the `--rebuild-derived` remedy (line 1348); `receipt_head_not_ancestor` with `details.gated_head`/`current_head` (line 906); `capsule_over_budget` with `details.tokens`/`budget`/`composition`/`note` (lines 1060, 1376-1382); `observed_sha_mismatch` with `declared`/`actual` (line 1274); `goal_mutated` with `frozen`/`current` (line 733); `pre_state_mismatch` (line 1213); `journal_partial_line` (line 269); `unreconciled_side_effect` for action-start (line 1397); `stopped` for stop (lines 408, 1363); reconcile's evidence-mandatory-for-`reconciled` and always-validated `--observed-sha256` (lines 1268, 1289, 1312); and the `!! <RESULT>: <reason>` banner before the JSON status line (line 1467). Every checked string exists verbatim with the described details fields.

GATE_VERDICT: PASS