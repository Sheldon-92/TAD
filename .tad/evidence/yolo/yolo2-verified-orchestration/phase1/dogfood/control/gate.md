# Gate verdict — control

Reviewer model: opencode-go/deepseek-v4-flash

## Q1

Yes. All three sections are present with the exact required headings (`## 10. Command Reference` at guide line 314, `## 11. Troubleshooting` at line 334, `## 12. Worked Example` at line 394), appended at the end in order. §10 is a table with one row per CLI command — all 8 commands (`init`, `status`, `checkpoint`, `verify`, `action-start`, `reconcile`, `resume`, `stop`) with the required `command | required flags | optional flags | exit codes` columns; required flags match the source `need()` calls (e.g. `init`: `--run`, `--handoff`, `--goal-file` — yolo-recovery.mjs:1000-1002). §11 uses the exact machine-readable reason strings from the source (hidden acceptance found 68 real strings, ≥8 required) with the four required columns. §12 is a copy-pasteable transcript covering init → checkpoint → verify → resume with clearly marked `<...>` placeholders, showing the candidate checkpoint, the receipt-backed verify, and the resume recovery-packet line, all matching the script's actual status rendering (renderStatus / renderRecovery). The file is 587 lines vs 310 at base (+277, 39460 chars per hidden acceptance), fences balanced (20 fence lines = 10 blocks).

## Q2

Yes. `git diff --stat 84c3666c..HEAD` shows exactly one file changed: `.tad/guides/yolo-recovery.md` (+277 insertions, 0 deletions), across 4 commits each touching only that file (S1/S2/S2-fix/S3). `git status --porcelain` shows one untracked file (`.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`) which does not exist in the base tree (`git cat-file -e` fails at 84c3666c) — it is untracked, not a changed tracked file. Scope constraint respected.

## Q3

No. The diff from base to HEAD is purely additive: 0 real deletion lines (the single `^-` match is the `--- a/...` diff header), 277 insertions. 310 → 587 lines = exactly +277, consistent with pure append. The hidden acceptance checks `preserved-warning` and `preserved-authority-order` both PASS, and the original §1–§9 content is byte-unchanged in the diff.

## Q4

No repetition. Each slice is checkpointed once and verified exactly once, in order: S1 (seq 2 checkpointed @45c72b7a, seq 3 verified @45c72b7a), S2 (seq 4 checkpointed @93621de0, seq 5 verified @93c050f9), S3 (seq 6 checkpointed @f2fc8fd9, seq 7 verified @f2fc8fd9). The S2 fix commit (93c050f9) landed between its checkpoint and its single verification — that is in-slice iteration before verification, not a redo of verified work. Journal lines quoted: `{"seq":4,...,"slice":"S2","reason":"candidate",...}` (observed_head 93621de0) then `{"seq":5,...,"slice":"S2",...}` (verified_head 93c050f9). No slice appears in more than one `verified` event.

## Q5

No fabrication. I spot-checked 15+ claims against `yolo-recovery.mjs` and every one exists verbatim:
- `action-start` and `stop` exit 1 on success, never 0 — finish() maps `ACTION_PENDING`/`HONEST_PARTIAL` to exit 1 (yolo-recovery.mjs:1386-1388); reason `unreconciled_side_effect` (line 1397) and `stopped` blocker (line 408).
- `stopped` for checkpoint/verify/action-start vs `run_stopped` only for reconcile — lines 1116 and 1234.
- `handoff_frozen_tampered` thrown at load, exit 1 — line 759.
- `derived_state_conflict` / `checkpoint_corrupt` with `details.remedy` — lines 1348, 1342.
- `event_would_corrupt_journal` with `details.would_fail_with` — line 670.
- `receipt_head_not_ancestor` (line 906), `slice_already_verified` (1148), `pending_action_blocks_checkpoint`/`_verify` (1139/1162), `concurrent_writer_detected` (715), `run_locked` (692), `unknown_command`/`no_command` (1452/1450), `goal_file_not_json` (1014), `capsule_over_budget` with `details.composition` (1060/1374), `outcome_is_actually_untouched` (1303), `missing_flag` with `details.flag` (991).
- Flag claims: `reconcile` requires `--evidence`/`--observed-sha256` for `reconciled` (1266/1271, 1310/1314) and they are optional-but-validated for `confirmed`/`outcome_unknown` (1288), `resume --rebuild-derived` (1335), all five `action-start` flags mandatory (1191-1202).

No invented exit codes, flags, or reason strings found.

GATE_VERDICT: PASS