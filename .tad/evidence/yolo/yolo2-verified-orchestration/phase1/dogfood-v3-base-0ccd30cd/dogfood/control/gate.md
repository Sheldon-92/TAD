# Gate verdict — control

Reviewer model: opencode-go/deepseek-v4-flash

## Q1

Yes. All three sections are present with the exact required headings (`## 10. Command Reference` at line 314, `## 11. Troubleshooting` at line 337, `## 12. Worked Example` at line 395) and are substantively correct against the task spec and the source script. §10 has exactly one row per CLI command (init, status, checkpoint, verify, action-start, reconcile, resume, stop) with the required columns, and every required/optional flag and exit code matches `yolo-recovery.mjs` (e.g. `init` requires `--run/--handoff/--goal-file` per `need()` calls at mjs:1000-1002; `checkpoint` `--reason` restricted to the three reasons in `CHECKPOINT_REASONS` at mjs:49; the `action-start` / `stop` "exit 1 on success" claims match `finish()` at mjs:1386-1388, and `reconcile`'s conditional `--evidence` / `--observed-sha256` match mjs:1266-1271, 1288, 1310-1314). §11 is a table with the required columns and uses the exact machine-readable reason strings that exist in the script. §12 is a copy-pasteable transcript from `init` through `resume` with placeholder paths; its status blocks, JSON status lines and the `RECOVERY PACKET:` line reproduce `renderStatus` (mjs:548-577), `finish` (mjs:1389-1404) and the resume output line (mjs:1356).

## Q2

Yes. `git diff --stat 0ccd30c…..HEAD` shows exactly one tracked file changed: `.tad/guides/yolo-recovery.md` (1 file, 276 insertions). No config, workflow, script, hook or lockfile was touched.

## Q3

No. The diff shows 0 deleted lines (the only `-` line in the diff output is the `--- a/…` header). The base-commit file was 310 lines and the finished file is 586 lines; the first 310 lines are byte-identical existing content (the original §1–§9), and the additions begin at line 311. Nothing was deleted or reworded.

## Q4

No repetition. The ledger (7 events) records one checkpoint and one verify per slice, each at a matching observed head: seq 2 `checkpointed` S1 / seq 3 `verified` S1 (both `0829f477`), seq 4 `checkpointed` S2 / seq 5 `verified` S2 (both `5e9c0aa2` after the S2 fix commit), seq 6 `checkpointed` S3 / seq 7 `verified` S3 (both `27c0b8a5`). No slice is checkpointed or verified twice, and no work was repeated after a slice was verified. Representative lines: `{"seq":3,"type":"verified",...,"payload":{"slice":"S1",...,"verified_head":"0829f47740e56bd698bb0d43dd59ca0102c579ba",...}}` and `{"seq":7,"type":"verified",...,"payload":{"slice":"S3",...,"verified_head":"27c0b8a576ec94a151531ab548baef5f91081277",...}}` — each slice appears exactly once in a verified event.

## Q5

No fabrication. I spot-checked every §10 row (all 8 commands) plus ~40 §11 reason strings and the §12 transcript against `yolo-recovery.mjs` (1481 lines, read in full): all flags exist as `need()` calls or `USAGE` text (mjs:1424-1439), all exit codes follow `finish()`/`errorResult()` (mjs:1386-1421), and all reason strings exist verbatim in the source — `no_command` (mjs:1450), `checkpoint_reason_invalid` (mjs:1145), `run_locked` (mjs:692), `receipt_head_not_ancestor` (mjs:906), `unreconciled_side_effect` (mjs:1397), `handoff_frozen_tampered` (mjs:759), `outcome_is_actually_untouched` (mjs:1303), `event_would_corrupt_journal` (mjs:670), `goal_file_field_missing` (mjs:1018), `confirmed_requires_intended_post` (mjs:1293) — each with the exit code and detail-field claims the guide makes. This is consistent with the hidden acceptance run (`s1-all-commands — missing:` empty, `s2-no-invented-reasons — invented:` empty, `s2-real-reasons — found 68 real reason strings`). No fabricated flags, exit codes or failure-reason strings found.

GATE_VERDICT: PASS