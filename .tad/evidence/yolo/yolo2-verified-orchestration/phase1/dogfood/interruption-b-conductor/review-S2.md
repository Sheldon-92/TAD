# Independent Slice Review — interruption-b S2

Reviewer model: opencode-go/deepseek-v4-flash

Reviewed 2026-08-25, worktree `wt-interruption-b`, HEAD `843017cf`.
Evidence inspected: task.md (spec), `.tad/guides/yolo-recovery.md` lines 334-365,
`.tad/scripts/yolo-recovery.mjs` (full 1481 lines), and the S1/S2/S3 commits via
`git show` / `git diff`.

## Q1

PASS. The section is present with the exact heading `## 11. Troubleshooting`
(guide line 334) and is a markdown table with the exact required columns
`failure reason | symptom | signal you see | remedy` (guide line 342), with 22
rows (lines 344-365). It sits at the end of the file, immediately after §10:
S2 commit `24f5f21c` appends it in a single hunk `@@ -328,3 +328,38 @@`.

## Q2

PASS. All 26 reason strings in the table were spot-checked against the source;
every one exists as a ContractError/UsageError reason. Evidence (source line):
`journal_missing` L264, `journal_empty` L266/L291, `journal_partial_line` L269,
`journal_corrupt` L279/L281, `journal_seq_broken` L282, `journal_field_missing`
L284/L286/L288/L321/L325/L337/L353/L397, `journal_first_event_invalid` L292,
`event_after_stop` L314, `handoff_frozen_tampered` L759, `handoff_missing` L766,
`handoff_revision_drift` L769, `outcome_is_actually_confirmed` L1300,
`outcome_is_actually_untouched` L1303, `observed_sha_mismatch` L1274/L1289,
`blind_retry_forbidden` L354/L1196, `pre_state_mismatch` L1213,
`verified_evidence_missing` L780, `verified_evidence_hash_mismatch` L784,
`verified_evidence_not_a_bound_receipt` L793, `stopped` L408 (blocker code),
`run_stopped` L1234, `already_stopped` L1363, `derived_state_conflict` L1348,
`checkpoint_corrupt` L1342, `capsule_over_budget` L1060/L1376,
`pending_action_blocks_checkpoint` L1139, `pending_action_blocks_verify` L1162.
No reason string in the table is absent from the source.

## Q3

PASS on all sub-items.

(a) journal_* payloads: `journal_missing`/`journal_empty`/`journal_partial_line`
carry only `{path}` (L264/L266/L269/L291) — whole-file, no line number, exactly
as claimed; `journal_corrupt` L279 `{line, message}`, `journal_seq_broken` L282
`{line, seq}`, `journal_field_missing` L284/L286/L288 `{line, field}` — line-level,
not a path, as claimed (the `{seq, field}` variant from reduceRun L321 etc. is
covered by "as applicable").

(b) `handoff_frozen_tampered` is a THROW inside `loadRun` (L759), not a
binding-blocker push — it surfaces as the top-level `reason` with `details.path`
and exit 1 via `errorResult` (L1411/L1418), so the guide's "not a `blockers[]`
entry" is correct. The restore-first remedy is correct: every command, including
`stop`, re-runs `loadRun` (cmdStop L1361 → withRun L1107), so the frozen copy
must hash back to `goal.handoff_revision` before `stop` can close the run.

(c) `outcome_is_actually_confirmed` → `{actual}` (L1300) ✓; `outcome_is_actually_untouched`
→ `{actual, hint}` where hint says "classify with explicit evidence via
--outcome reconciled" (L1303-1306) ✓ — matches the guide's `details.hint` claim.

(d) receipt-binding payloads: `verified_evidence_missing` detail
`` `slice ${v.slice}: ${v.receipt_path}` `` (L780), `verified_evidence_hash_mismatch`
same shape (L784), `verified_evidence_not_a_bound_receipt` detail
`` `slice ${v.slice}: ${v.receipt_path} no longer reads as a bound Conductor PASS receipt` ``
(L793-795) — the guide's "details reads `slice <id>: <receipt path>`" wording
matches the source strings exactly.

(e) all three `verified_evidence_*` are pushed to `bindingBlockers` (L780/L784/
L793) and concatenated into `state.blockers` (L800-801), so "binding blocker in
`blockers[]`" is accurate.

(f) stopped-run behavior: `checkpoint`/`verify`/`action-start` all call
`refuseIfHonestPartial` (L1137/L1160/L1198), which throws `state.blockers[0].code`
= `stopped` (L1116, blocker pushed at L408); `run_stopped` is thrown ONLY in
`cmdReconcile` (L1234). Guide rows 16-17 are correct.

(g) the intro states the table is "non-exhaustive" and points at `details` plus
the code path (guide L338-340) — accurate, since the source emits many more
reasons (goal_missing, receipt_*, concurrent_action, etc.) not in the table.

## Q4

FAIL — one defect. I found no fabrication: every signal column, remedy and detail
string in the §11 rows traces to real source behavior. The §11 section itself is
appended at the end of the file and touches no existing text. However, the S2
commit (`24f5f21c`, "S2: add §11 Troubleshooting") is NOT append-only: it
rewrote the pre-existing "Runtime" bullet (guide line 14):
`- Runtime: Node built-ins only, no npm packages, no lockfile change.` became
`- Runtime: Node built-ins only, no npm packages, no lockfile change. See the
Command Reference section for per-command flags.` — diff hunk `@@ -11,7 +11,7 @@`,
commit stat "36 insertions(+), 1 deletion(-)". The task explicitly forbids this
("Do NOT delete or reword existing guide content"; "without changing, reordering
or deleting any existing text"). Attribution is unambiguous: the S2 parent
(`d738e4e9`, S1) still had the original line, and no S1 commit on any branch
(`45c72b7a`, `c35dc975`, `d738e4e9`) touched it. The added clause is factually
accurate (a cross-reference to §10), but the constraint is explicit and
unconditional, so this is a real append-only violation in the slice's commit.

verdict: FAIL

---

## Re-review (round 2)

The executor restructured history to isolate the A1 patch from the S2 slice.
Verified on 2026-08-25 at new HEAD `d52d4137`:

1. **§11 commit is pure insertion.** `git show --stat e063fe58`
   ("S2: add §11 Troubleshooting"): `.tad/guides/yolo-recovery.md | 35
   ++++++++++++++++++++++++++++++++++`, "1 file changed, 35 insertions(+)" —
   zero deletions. The diff is a single hunk `@@ -328,3 +328,38 @@` appending
   the section at the end of the file. Confirmed independently: grep of the
   commit's diff shows 0 deletion lines and 35 addition lines (31 non-blank +
   4 blank).
2. **A1 patch is now its own commit.** `git show --stat 04a87a4d`
   ("A1: controlled Runtime cross-reference patch (ledger action, reconciled
   confirmed)"): exactly "1 insertion(+), 1 deletion(-)" — the line-14 Runtime
   reword, no longer bundled with §11. S2's parent now carries the reworded
   line, and e063fe58 touches nothing above line 328.
3. **Guide content byte-identical to round 1.** The guide blob at old HEAD
   `843017cf` and at new HEAD `d52d4137` is the same SHA
   (`2dccf11141f2b09deb23110229f9cc5836c0cd0e`); `git diff 843017cf d52d4137
   -- .tad/guides/yolo-recovery.md` is empty (0 lines). Spot-checked §11 rows
   in the working file (lines 344-365): `handoff_frozen_tampered`,
   `outcome_is_actually_confirmed`/`_untouched`, `verified_evidence_*`,
   `stopped`/`run_stopped`, `derived_state_conflict` — all match the round-1
   content and the source-verified claims.
4. **No new defect.** Q1 (exact heading + required table columns), Q2 (all 26
   reason strings exist in `yolo-recovery.mjs`) and Q3 (path-vs-line payloads,
   handoff_frozen_tampered throw semantics, outcome_* detail keys,
   receipt-binding blocker strings, stopped vs run_stopped, non-exhaustive
   intro) all still hold unchanged. The round-1 Q4 defect is resolved: the S2
   commit is now purely additive, and the line-14 reword lives in a separate,
   explicitly-labeled ledger-action commit outside the slice.

final verdict: PASS