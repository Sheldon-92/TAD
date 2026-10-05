# Independent Slice Review — control S1

Reviewer model: opencode-go/deepseek-v4-flash

Reviewed against task.md (S1 spec), the finished `## 10. Command Reference`
section in `.tad/guides/yolo-recovery.md` (lines 314-330), and the CLI source
`.tad/scripts/yolo-recovery.mjs` (1481 lines, read in full), plus the worktree
git history (commit `45c72b7a` "S1: add §10 Command Reference") to check
append-only.

## Q1

Yes. The heading at guide line 314 is exactly `## 10. Command Reference`,
matching the task spec verbatim. The section documents all eight commands in
the source's `COMMANDS` list (source lines 69-72: `init, status, checkpoint,
verify, action-start, reconcile, resume, stop`) — one table row each, in the
same order.

## Q2

Yes. Spot-checked all eight rows against the source's arg parsing (`need()` at
source 989-993, `parseArgs` 968-987) and exit logic (`finish()` 1373-1406,
`errorResult()` 1408-1422).

- **init** — required `--run/--handoff/--goal-file` match `need()` calls at
  source 1000-1002; exit-1 reasons (`base_commit_mismatch` 1022,
  `run_already_initialized` 1005, `handoff_missing` 1007, `goal_file_missing`
  1008, `oracle_missing` 1025, `capsule_over_budget` 1060,
  `atomic_write_failed` 530) and exit-2 reasons (`goal_file_not_json` 1014,
  `goal_file_field_missing` 1019) all real. Success state is ACTIVE → exit 0.
- **status / checkpoint / verify** — flags match `need()` at 1106/1141-1143/
  1164-1165; reasons `pending_action_blocks_checkpoint` 1139,
  `slice_already_verified` 1148, `run_locked` 692, `event_would_corrupt_journal`
  670, `checkpoint_reason_invalid` 1145, `receipt_self_authored` 925,
  `receipt_no_independent_review` 957, `receipt_evidence_*` 933-952,
  `duplicate_verified_slice` 928, `pending_action_blocks_verify` 1162 all real;
  exit-2 `path_escape` 145 and `missing_flag` 991. Verify success: after the
  `verified` event state is ACTIVE → 0.
- **(a) reconcile** — exactly as claimed. `--observed-sha256` is required for
  `--outcome reconciled` via `need()` at source 1271 (unknown-resolution path)
  and 1314 (pending-action path); `--evidence` likewise required (1266, 1310).
  For `confirmed`/`outcome_unknown` it is validated only when supplied:
  `if (flags['observed-sha256'] && ...)` at source 1288 — optional-but-validated,
  with `observed_sha_mismatch` (1289) the mismatch error. All listed reasons
  real (`run_stopped` 1234, `unknown_action_reconcile` 1254/1257,
  `unknown_outcome_needs_reconciled` 1264, `confirmed_requires_intended_post`
  1293, `outcome_is_actually_confirmed` 1300, `outcome_is_actually_untouched`
  1303, `reconcile_evidence_missing` 1268/1312). Exit 0 only for `confirmed`
  (pending cleared) or `reconciled` (unknown cleared) → ACTIVE; exit 1 for
  `outcome_unknown` → HONEST_PARTIAL.
- **(b) action-start** — success never 0: after `action_started`, state is
  `ACTION_PENDING` (source 415); `finish()` maps `ACTION_PENDING` to exit 1
  with reason `unreconciled_side_effect` (1386-1398, comment 1383-1385). The
  row's "never 0" is exactly right; exit 0 is unreachable for this command.
  Five mandatory flags (1191, 1199-1202); `blind_retry_forbidden` 1196,
  `concurrent_action` 1205, `action_target_missing` 1209, `pre_state_mismatch`
  1213 all real.
- **(c) stop** — success never 0: after `stopped`, state is `HONEST_PARTIAL`
  (414) with blocker code `stopped` (408); `finish()` → exit 1, reason
  `stopped` (1395-1396). `already_stopped` 1363 real; `--reason` via `need()`
  1362.
- **resume** — `--rebuild-derived` real (1335); success on ACTIVE → 0;
  HONEST_PARTIAL/ACTION_PENDING reported not refused (no
  `refuseIfHonestPartial` call in `cmdResume`, exit 1 via `finish()`);
  `derived_state_conflict` 1348, `checkpoint_corrupt` 1342, `goal_mutated` 733,
  `handoff_frozen_tampered` 759 all real.

No invented or wrong flag or exit code found.

## Q3

Yes. Table header is exactly `command | required flags | optional flags | exit
codes it can produce` (guide line 321), matching the task spec; one row per
command; the table and its intro sit at the end of the file. Git diff of commit
`45c72b7a` against its parent shows only pure additions after the existing §9
block — no existing line deleted or reworded, no other file modified by the S1
commit.

## Q4

No fabrication. Every named reason string, flag, and exit code in the section
was located in the source (each listed in Q2 with its line). Flags
`--run/--handoff/--goal-file/--slice/--reason/--next/--receipt/--action/
--description/--target/--pre-sha256/--intended-post-sha256/--outcome/
--evidence/--observed-sha256/--rebuild-derived` all appear in the source's
usage text (1426-1435) and `need()` calls. Wildcards like `journal_*`,
`handoff_*`, `verified_evidence_*`, `receipt_*` map to real families of reason
strings (264-292, 766-771, 780-795, 864-957). The two success-path exceptions
(`action-start`, `stop` exiting 1) are precisely what `finish()` emits.

One minor imprecision, not a fabrication: the `stop` row's exit-1 parenthetical
"binding blockers" — `cmdStop` (1360-1369) never throws on binding blockers
(unlike `reconcile`, which checks them at 1239-1245); with blockers present,
stop still appends `stopped` and exits 1 with reason `stopped` (blocker order:
`stopped` is pushed first at 408, binding blockers appended after at 801).
The claimed exit code (1) is correct in that scenario, so the row over-labels
the cause rather than inventing a reason string. The reason lists are otherwise
examples ("e.g." used explicitly in the verify row), and codes are right in
every row.

verdict: PASS