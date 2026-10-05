# Independent Slice Review — interruption-a S1

Reviewer model: opencode-go/deepseek-v4-flash

Reviewed against the frozen task spec (`.tad/evidence/yolo/yolo2-verified-orchestration/phase1/dogfood/task.md`, S1 definition lines 10-18), the finished section `## 10. Command Reference` in `.tad/guides/yolo-recovery.md` (lines 314-332), and the CLI source `.tad/scripts/yolo-recovery.mjs` (1481 lines, read in full). Also checked `git show c35dc975` (the S1 commit) and working-tree status for the append-only claim.

## Q1 — Section presence and full command coverage

PASS. The section is present with the exact heading `## 10. Command Reference` (guide line 314, verified against the task requirement "headed exactly `## 10. Command Reference`"). The table has exactly one row per CLI command and all eight commands are covered: `init` (line 325), `status` (326), `checkpoint` (327), `verify` (328), `action-start` (329), `reconcile` (330), `resume` (331), `stop` (332) — matching `COMMANDS` in the source (yolo-recovery.mjs lines 69-72: `'init', 'status', 'checkpoint', 'verify', 'action-start', 'reconcile', 'resume', 'stop'`). No command missing, none invented.

## Q2 — Flag and exit-code correctness against the source (spot-checked all 8 rows)

PASS. I traced every row against the argument parsing (`need()` at source lines 989-993, `parseArgs` 968-987), the per-command handlers, and the `finish()`/`errorResult()` exit-code logic (lines 1373-1422, 1448-1450). Details:

- **init** (guide 325): required `--run/--handoff/--goal-file` match `need(flags, 'run'|'handoff'|'goal-file')` (source 1000-1002). Cited exit-1 reasons all exist: `run_already_initialized` (1005), `handoff_missing` (1007), `goal_file_missing` (1008), `base_commit_mismatch` (1022), `oracle_missing` (1025), `capsule_over_budget` (1060); exit-2 `missing_flag` (991), `goal_file_not_json` (1014), `goal_file_field_missing` (1018), `path_escape` (145). Success exits 0 (state ACTIVE → `finish` line 1386-1388).
- **status** (326): `--run` required (1106); `goal_missing` (232), `journal_missing` (264), `goal_mutated` (733) all real.
- **checkpoint** (327): required flags and reason enum match `CHECKPOINT_REASONS` (49) and `need` calls (1141-1143); `checkpoint_reason_invalid` is a UsageError (1145) → exit 2, correct; `pending_action_blocks_checkpoint` (1139), `slice_already_verified` (1148), `run_locked` (692) all real.
- **verify** (328): `receipt_missing` (864), `receipt_not_json` (873), `receipt_format_unknown` (877), `receipt_self_authored` (925), `receipt_evidence_missing` (944), `receipt_no_independent_review` (957) — all real ContractErrors → exit 1.
- **action-start** (329): all six required flags match `need` calls (1191, 1199-1202). (a-variant) Success-exits-1 claim verified: after `action_started` the reducer always sets `pendingAction` (358) and state `ACTION_PENDING` (415), so `finish()` computes `honest = HONEST_PARTIAL || ACTION_PENDING` → `exitCode: 1` with reason `unreconciled_side_effect` (1386-1398). It can never exit 0. The guide's "never `0`" is exactly right.
- **reconcile** (330): (a) `--evidence` and `--observed-sha256` are indeed additionally **required** for `--outcome reconciled`: `need(flags,'evidence')` + `need(flags,'observed-sha256')` in the unknown-resolution path (1266, 1271) and in the pending-action `reconciled` branch (1310, 1314); `unknown_outcome_needs_reconciled` when outcome ≠ `reconciled` on an unknown action (1263-1265) — matches the parenthetical. For `confirmed`/`outcome_unknown` on a pending action they are optional-but-validated: `--observed-sha256` is only checked `if (flags['observed-sha256'] && ...)` against the real file (1288-1290), evidence is never read (1291-1308) — matches "ignored … but a supplied `--observed-sha256` is always validated". All cited exit-1 reasons real: `run_stopped` (1234), `unknown_action_reconcile` (1254, 1257), `observed_sha_mismatch` (1274, 1289), `confirmed_requires_intended_post` (1293), `outcome_is_actually_confirmed` (1300), `outcome_is_actually_untouched` (1303), `reconcile_evidence_missing` (1268, 1312); `reconcile_outcome_invalid` is a UsageError (1249) → exit 2, correct. Exit 0 after a clean reconcile (pendingAction cleared, 393).
- **resume** (331): `--rebuild-derived` is the only optional flag, handled at 1335; `checkpoint_corrupt` (1342) and `derived_state_conflict` (1348) real; the optional-flag description ("rebuild `checkpoint.json` / `recovery.md` from the journal") matches `writeDerived` (830-839).
- **stop** (332): (c) success-exits-1 verified: `stopped` event always sets `stopped` (398) → blocker code `stopped` (408) → state `HONEST_PARTIAL` (414) → `finish()` exits 1 with reason `stopped` (1386-1398). Never 0. `already_stopped` (1363) real.
- Preamble (316-321): exit contract matches source header comment (20-22) and `errorResult` (1408-1422: usage → 2, contract → 1); repo-root anchoring matches `anchorAtRepo` (190-192); no-command/`--help`/`-h`/`help` → exit 2, reason `no_command` (1448-1450).

No invented or wrong flag, exit code, or reason string found in any row.

## Q3 — Table shape and append-only

PASS. The header row is exactly `command | required flags | optional flags | exit codes it can produce` (guide line 323) with the required four columns and one row per command. Append-only confirmed at the git level: the S1 commit `c35dc975` ("S1: add §10 Command Reference") shows `.tad/guides/yolo-recovery.md` with **22 insertions, 0 deletions**, all appended after the final line of §9 (old line 310); the §9 exit-contract table and all earlier sections are untouched. No existing text reworded, reordered, or deleted. (The unstaged working-tree addition — `## 11. Troubleshooting` — belongs to slice S2 and does not affect S1.)

## Q4 — Fabrication

PASS. Every flag, exit code, and reason string in the section is emitted by the source: all required/optional flags come from `need()`/handler code; all exit-code claims trace to `finish()`/`errorResult()`/`runCli`; all 30+ cited reason strings (e.g. `unreconciled_side_effect` 1397, `no_command` 1450, `checkpoint_reason_invalid` 1145, `receipt_no_independent_review` 957, `outcome_is_actually_untouched` 1303, `already_stopped` 1363, `derived_state_conflict` 1348) exist verbatim as thrown reasons. No behavior is described that the source does not emit.

verdict: PASS

Weakest spot checked: the `reconcile` row's "ignored for `confirmed`/`outcome_unknown` … but a supplied `--observed-sha256` is always validated" wording — loose (the flag is optional-not-required rather than literally discarded; the observed hash is still computed internally), but the validation sentence pins the exact source semantics (1288-1290), so it is accurate, not a defect.