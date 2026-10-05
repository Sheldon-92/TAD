# Gate verdict — interruption-c

Reviewer model: opencode-go/deepseek-v4-flash

## Q1

Yes. All three required sections are present, appended at the end in order with the exact required headings (`## 10. Command Reference` at line 312, `## 11. Troubleshooting` at line 327, `## 12. Worked Example` at line 351). I verified substance against the source, not just presence: §10 has one row per CLI command (all 8 commands — init, status, checkpoint, verify, action-start, reconcile, resume, stop — match `COMMANDS` at yolo-recovery.mjs:69-71) with the required four columns; required/optional flags match the USAGE text (yolo-recovery.mjs:1424-1435) and `need()` calls; exit-code claims match `finish()`/`errorResult()` (0=PASS/1=contract/2=usage, yolo-recovery.mjs:1388, 1411). §11 covers the operator-facing failure modes with the exact machine-readable reason strings. §12 is a copy-pasteable init→checkpoint→receipt→verify→resume transcript with clearly-marked placeholders whose output shapes match `renderStatus`/`finish` (`RECOVERY PACKET:` prefix at yolo-recovery.mjs:1356, budget 2500 at line 53). Hidden acceptance confirms 13/13 including s1-all-commands (missing: none), s2-real-reasons (23 real reasons ≥ 8 required), s2-no-invented-reasons (invented: none), no-truncation (24658 bytes), balanced-fences (14).

## Q2

Yes. `git diff --stat 84c3666c..HEAD` shows exactly one tracked file changed: `.tad/guides/yolo-recovery.md`, 112 insertions, 0 deletions, across three commits (cec89bf4 S1, 01ed9736 S2, ce2c0c87 S3). No script, config, workflow, or lockfile is touched in the committed range; hidden acceptance scope-respected reports off-scope: (empty). (The S1 verify event names a dirty untracked path `.tad/active/handoffs/HANDOFF-...md` in the worktree, but that is not a tracked change made by this run and is not part of the diff range.)

## Q3

No. The full diff contains zero deleted lines (`git diff ... | grep -E '^-[^-]'` returns nothing; the only `-` line is the diff header). Every pre-existing paragraph — the experimental-status warning, the authority order, the exit contract — is byte-identical. The added sections begin exactly after the existing `## 9. Exit contract` block, so nothing was reordered, deleted, or reworded.

## Q4

No repetition. The ledger (journal.jsonl, 5 lines) shows: seq 1 `initialized`; seq 2 `checkpointed` S1 (candidate, "obtain conductor receipt after gate + review"); seq 3 `verified` S1 — the only verification event, receipt-backed (receipt-S1.json, written_by_id conductor-blake-t2 ≠ executor_id exec-c2, gate+review evidence); seq 4 `checkpointed` S2 (candidate); seq 5 `checkpointed` S3 (candidate). No slice is verified more than once: `{"seq":3,"type":"verified",...,"payload":{"slice":"S1",...}}` is the sole verified event. S2/S3 were checkpointed once each as intent records and never verified, and each slice's work exists as exactly one commit. No work was repeated after verification.

## Q5

No fabrication. I spot-checked 57 machine-readable reason strings from §10/§11 against `yolo-recovery.mjs` (grep count ≥ 1 each) — including `journal_corrupt`, `handoff_frozen_tampered`, `derived_state_conflict`, `receipt_self_authored`, `outcome_is_actually_confirmed`, `observed_sha_mismatch`, `run_stopped`, `event_would_corrupt_journal`, `checkpoint_reason_invalid` (2 = usage), `path_escape`, `goal_file_not_json`, `capsule_over_budget` — all literal in the source. All 15 flags (`--run`, `--handoff`, `--goal-file`, `--slice`, `--reason`, `--next`, `--action`, `--description`, `--target`, `--receipt`, `--outcome`, `--evidence`, `--rebuild-derived`, `--pre-sha256`, `--intended-post-sha256`, `--observed-sha256`) exist in the source. All 8 command names exist. The unusual exit-code claims were verified against code: `action-start` and `stop` success always exit 1 (state ACTION_PENDING/HONEST_PARTIAL → `finish()` honest→1, yolo-recovery.mjs:1386-1388; stop blocker `stopped` at line 408, reason `unreconciled_side_effect` at 1396-1397); reconcile `outcome_unknown` → exit 1 while `confirmed`/`reconciled` → 0; resume → 0 only when ACTIVE. The worked-example status JSON shapes match `finish()`'s status object fields (format, command, result, state, reason, verified_slices, unverified_slices, blockers, legal_next_action, run_dir).

GATE_VERDICT: PASS