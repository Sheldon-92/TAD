# Independent Slice Review — interruption-c S1

Reviewer model: opencode-go/deepseek-v4-flash

## Q1 — Section present, exact heading, all 8 commands

PASS. `.tad/guides/yolo-recovery.md:312` reads exactly `## 10. Command Reference`, matching the task's required heading verbatim. The table (lines 314–323) has one row per command and covers all eight commands in the CLI's `COMMANDS` array (`.tad/scripts/yolo-recovery.mjs:69-72`: `init, status, checkpoint, verify, action-start, reconcile, resume, stop`) — all eight appear, no extras, none missing.

## Q2 — Flags and exit codes correct against source

PASS, spot-checked all eight rows against the argument parsing (`parseArgs`/`need`, lines 968–993, and `USAGE` lines 1424–1439) and exit-code logic (`finish()` lines 1373–1406, `errorResult()` lines 1408–1422). Every required flag per row matches a `need(flags, ...)` call in the corresponding `cmd*` function; every listed reason string exists verbatim in the source; every row's exit codes are consistent with the contract `0 = PASS, 1 = contract failure, 2 = usage` (source lines 21, 1386–1388, 1411).

- (a) **reconcile `--observed-sha256`** — confirmed. In the unknown-action branch (outcome must be `reconciled`), `need(flags, 'observed-sha256')` at line 1271 makes it mandatory; in the pending branch it is optional-but-validated for all outcomes at line 1288 (`if (flags['observed-sha256'] && ...)`), and required via `need(flags, 'observed-sha256')` at line 1314 only for `reconciled`. `--evidence` likewise required only for `reconciled` (lines 1266, 1310). The row's "**required** when `--outcome reconciled`; otherwise optional-but-validated" is accurate for both branches.
- (b) **action-start success exits 1** — confirmed. After appending `action_started`, `pendingAction` is set, `reduceRun` yields `state = 'ACTION_PENDING'` (line 415), and `finish()` returns `exitCode: honest ? 1 : 0` with `honest` true for `ACTION_PENDING` (lines 1386–1388) and `reason` = `unreconciled_side_effect` (line 1397). There is no path to exit 0 — the row's "never `0`" is correct.
- (c) **stop success exits 1** — confirmed. `cmdStop` (lines 1360–1369) always ends with a `stopped` event; the reducer sets `stopped` → state `HONEST_PARTIAL` with blocker `{code: 'stopped'}` (lines 408, 414); `finish()` then returns exit 1 with reason `stopped` (line 1396). "Never `0`" is correct.
- Other spot-checks: `init` exit-2 reasons `goal_file_not_json` (line 1014, UsageError) and `goal_file_field_missing` (line 1018) vs exit-1 `base_commit_mismatch` (1022), `oracle_missing` (1025), `capsule_over_budget` (1060) — all correctly classified. `checkpoint` `checkpoint_reason_invalid` is a UsageError → 2 (1144–1146); `slice_already_verified` (1148), `run_locked` (692), `event_would_corrupt_journal` (670) are contract → 1. `verify` reasons `receipt_missing` (864), `receipt_not_json` (873), `receipt_run_mismatch` (885), `receipt_self_authored` (925), `receipt_no_independent_review` (957), `receipt_evidence_hash_mismatch` (952), `pending_action_blocks_verify` (1162) all exist and are contract errors → 1. `status`/`resume` binding blockers (`handoff_revision_drift` 769, `worktree_identity_mismatch` 750, `handoff_frozen_tampered` 759 as a *thrown* contract error, `derived_state_conflict` 1348, `checkpoint_corrupt` 1342) all match. `resume --rebuild-derived` is genuinely optional (line 1335, USAGE 1434). No invented or wrong flag, reason, or exit code found.

## Q3 — Table shape and append-only

PASS. Header (line 314) is exactly `command | required flags | optional flags | exit codes it can produce`, matching the task's required columns; all eight rows conform. Append-only verified via git: commit `cec89bf4 "S1: add §10 Command Reference"` shows `.tad/guides/yolo-recovery.md | 13 +++++++++++++` — 13 insertions, 0 deletions, added after §9's final line (old line 310 → new 311 `---`, section 10 starts at 312). No existing guide text was deleted or reworded.

## Q4 — Fabrication

PASS. Every reason string in the S1 table was checked against the source and exists verbatim, including the less common ones: `run_already_initialized` (1005), `journal_seq_broken` (282), `journal_blank_line` (274), `journal_partial_line` (269), `goal_mutated` (733), `outcome_is_actually_confirmed` (1300), `outcome_is_actually_untouched` (1303), `confirmed_requires_intended_post` (1293), `observed_sha_mismatch` (1274/1289), `unknown_outcome_needs_reconciled` (1264), `reconcile_evidence_missing` (1268/1312), `unknown_action_reconcile` (1254), `run_stopped` (1234), `blind_retry_forbidden` (1196), `pre_state_mismatch` (1213), `concurrent_action` (1205), `already_stopped` (1363), `unreconciled_side_effect` (1397). All flag names match the `--flag` strings passed to `need()` and the `USAGE` block. No flag, exit code, or behavior is claimed that the source does not emit. (The table omits a few possible-but-rare reasons such as `atomic_write_failed`, `concurrent_writer_detected`, `goal_format_unknown` — omission of non-exhaustive detail, not fabrication; the exit codes 0/1/2 themselves are fully correct.)

## Verdict

PASS

Weakest spot checked: the `reconcile` row — the `--observed-sha256`/`--evidence` required-vs-optional claim is branch-dependent (unknown-action resolution vs pending-action), and I verified both branches (lines 1266–1271, 1288, 1310–1314); it is accurate in both.