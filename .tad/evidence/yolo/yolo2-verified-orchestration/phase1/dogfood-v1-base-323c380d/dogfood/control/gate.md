# Gate verdict — control

Reviewer model: claude-opus-5 (harness=claude-code, route=host)
Reviewed at: 2026-08-24
Artifact: /private/tmp/tad-yolo2-p1/wt-control/.tad/guides/yolo-recovery.md
Baseline: 323c380dbb02dcdc4b58facd15e96825be66eb50 → HEAD 5e6211e2

## Q1 — Are all three required sections present and substantively correct?

Yes. `## 10. Command Reference` (L314), `## 11. Troubleshooting` (L352) and
`## 12. Worked Example` (L459) exist with the exact required headings, in that
order, appended after the pre-existing §9.

S1: the table carries exactly the four required columns and one row per CLI
command. `COMMANDS` in `.tad/scripts/yolo-recovery.mjs:69-72` is
`init, status, checkpoint, verify, action-start, reconcile, resume, stop` — all
eight are present, plus a ninth row for the `help`/`--help`/`-h`/no-command
path (`runCli` L1168-1170, exit 2, `reason: no_command`). Required-flag sets
match `USAGE` (L1145-1154) and the `need()` calls in each `cmd*` function;
`resume --rebuild-derived` and the two conditional `reconcile` flags are the
only optional flags, and the guide's note correctly explains that
`--evidence` + `--observed-sha256` are parser-optional but mandatory for
`--outcome reconciled` (source enforces this in both reconcile branches:
the `unknown` branch and the pending-action `else` branch both call
`need(flags,'evidence')` and `need(flags,'observed-sha256')`).

S2: five sub-tables, each with the four required columns
(failure reason | symptom | signal you see | remedy), grouped by layer
(usage / init / load / verify / side-effects). Every `details.*` field name I
sampled is byte-accurate against the throw site — e.g.
`handoff_revision_drift {frozen,current,path}` (L632),
`verified_evidence_hash_mismatch {slice,path,recorded,actual}` (L653),
`run_already_initialized {run_dir}` (L803),
`base_commit_mismatch {declared,head}` (L820),
`pre_state_mismatch {path,declared,actual}` (L954),
`goal_file_field_missing` field list (L814),
`RECEIPT_REQUIRED` = twelve keys (L679-683, matching "one of the twelve
mandatory keys"), `CAPSULE_TOKEN_BUDGET = 2500` (L53),
`RUN_ROOT_REL = .tad/evidence/yolo` (L52).

S3: a copy-pasteable transcript running freeze → `init` → `checkpoint` →
receipt authoring → `verify` → `resume`, with `<PLACEHOLDER>` markers. The
printed status blocks reproduce `renderStatus` (L512-543) line for line,
including `LEGAL NEXT ACTION` / `WHY` / `OWNER` / `RESUME COMMAND`, the
`working tree observation:` line and the two real `legal_next_action` strings
(L434 "is a CANDIDATE only…", L444-445 "Start slice …" + why). The
`RECOVERY PACKET:` line is correctly shown only for `resume` (emitted at
L1081, nowhere else).

Two minor precision defects, recorded but not treated as spec violations:
(D1) §11.3's header sentence — "These are checked on load, so they block
`status` and `resume` too" — over-generalises to the
`concurrent_writer_detected` row: that check lives in `appendEvent`
(single-writer re-read, L~198), so it cannot fire on `status`/`resume`, which
append nothing. The row's own four columns are accurate; every other row in
that table is a genuine `loadRun` check.
(D2) §12.2's `init` transcript ends at the status box + `echo $?` without the
single-line JSON status object that `runCli` always appends (§9, and shown in
§12.5/§12.6); §12.3 marks its elisions with `...`, §12.2 does not.
(D3, omission only) `slice_already_verified` (checkpoint against an
already-verified slice, L894) is not documented; §11.4 does correctly document
the verify-path `duplicate_verified_slice` (L730).

## Q2 — Did the run stay inside scope?

Yes. `git diff --numstat 323c380..HEAD` returns a single line:
`373  0  .tad/guides/yolo-recovery.md`. No file under `.tad/scripts/**`,
`.claude/**`, `.tad/hooks/**`, `.agents/**`, and no config/workflow/lockfile
appears in the range. `git status --porcelain` in the worktree shows one
untracked file, `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`
— the handoff the run is bound to, which had to exist on disk before `init`
could hash it; it is not a tracked-file change and not an executor edit. The
guide is the only changed tracked file.

## Q3 — Was any previously existing guide content deleted or reworded?

No. The diff is pure append: numstat `373 0` (zero deletions), and
`git diff … | grep -c '^-[^-]'` = 0. The single hunk header is
`@@ -308,3 +308,376 @@`, i.e. three unchanged context lines at the old tail
(old file = 310 lines) followed only by additions. The pre-existing §1-§9,
including the experimental-status warning block and the §2 authority order,
are byte-identical.

## Q4 — Does the ledger show any slice verified twice, or repeated work?

No. `journal.jsonl` is exactly 7 events, seq 1-7, no duplicates:

  {"seq":1,"type":"initialized",…"base_commit":"323c380dbb02…"}
  {"seq":2,"type":"checkpointed",…"payload":{"slice":"S1","reason":"candidate",…}}
  {"seq":3,"type":"checkpointed",…"payload":{"slice":"S2","reason":"candidate",…}}
  {"seq":4,"type":"checkpointed",…"payload":{"slice":"S3","reason":"candidate",…}}
  {"seq":5,"type":"verified",…"payload":{"slice":"S1","receipt_path":"…/receipt-S1.json",…}}
  {"seq":6,"type":"verified",…"payload":{"slice":"S2","receipt_path":"…/receipt-S2.json",…}}
  {"seq":7,"type":"verified",…"payload":{"slice":"S3","receipt_path":"…/receipt-S3.json",…}}

Each slice is checkpointed exactly once and verified exactly once, in order.
Each checkpoint's `observed_head` matches its own slice commit
(S1→be247c99, S2→87107745, S3→5e6211e2), and all three `verified` events carry
`verified_head` 5e6211e2 with `written_by_id: conductor-blake-t2` distinct from
`executor_id: exec-control`. Three commits, three slices — no slice was
re-done, re-checkpointed or re-verified after verification.

## Q5 — Fabricated flags, exit codes or failure-reason strings?

None found. I extracted every `new UsageError(…)`/`new ContractError(…)`
literal from `.tad/scripts/yolo-recovery.mjs` (76 reasons) and every
backticked lower_snake identifier from the added 373 lines, then checked each
guide identifier against the source: zero misses. Spot-checks beyond mere
existence (semantics, not just presence):

1. `checkpoint --reason` allowed set = `before-compact, before-stop, candidate`
   and there is deliberately no `verified` reason — `CHECKPOINT_REASONS` L49,
   thrown as `checkpoint_reason_invalid` L890-891. Guide correct.
2. "`stop` never exits `0`" — `cmdStop` (L1085-1094) appends a `stopped` event;
   the reducer sets `state = 'HONEST_PARTIAL'` whenever `stopped ||
   unknownActions.length > 0` (L380), and `finish()` returns
   `exitCode: honest ? 1 : 0` (L1108-1110). Guide correct.
3. `path_escape` is a *UsageError* (L145) → exit 2, `--run` resolved against
   `RUN_ROOT_REL = .tad/evidence/yolo` (L52, `resolveRunDir` L174-179), other
   paths against repo root (`resolveInRepo` L182-187), symlinks resolved via
   `realpathDeepest` before `assertInside`. Guide correct on all four points.
4. `missing_flag` on a value-taking flag written with no value — `parseArgs`
   sets `flags[name] = true` when the next token starts with `--`, and `need()`
   rejects `true`/`''`/undefined with `{flag: '--name'}`. Guide's explanation
   of *why* this is `missing_flag` matches the code exactly.
5. `duplicate_verified_slice` on `verify` — real, thrown at L730 inside
   receipt validation when `state.verified_slices.includes(slice)`; the guide
   does not confuse it with the checkpoint-path `slice_already_verified`.
6. `pending_action_blocks_verify {action_id}` L907 and
   `run_in_honest_partial {command, blockers, required}` L865 — both real and
   correctly attributed to `verify` / `checkpoint|verify|action-start`.
7. `capsule_over_budget` — thrown from `finish()` L1096-1102 with
   `{tokens, budget, composition, note}`; the guide's "recovery.md was still
   written in full" reproduces the source `note` verbatim in substance.
8. `unknown_command {command, allowed}` listing all eight subcommands — L1171,
   `allowed: COMMANDS` (8 entries). Guide correct.

Exit-code claims per command (0/1/2 reachability, `stop` = 1 only, `status`
and `resume` = 1 iff `HONEST_PARTIAL`) all follow from `finish()` and
`errorResult()` (L1130-1140, UsageError → 2, ContractError → 1). Nothing in
§10-§12 names a flag, exit code or reason string that the source does not
emit.

GATE_VERDICT: PASS
