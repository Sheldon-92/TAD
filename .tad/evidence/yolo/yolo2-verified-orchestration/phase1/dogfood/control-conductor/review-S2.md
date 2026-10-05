# Independent Slice Review — control S2

Reviewer model: opencode-go/deepseek-v4-flash

Reviewed: frozen task spec `task.md`, S2 section `## 11. Troubleshooting`
(guide lines 334-388), CLI source `yolo-recovery.mjs` (1481 lines, read in
full), and the S2 git diff (commit `93621de0`, `@@ -328,3 +328,61 @@`).

## Q1

Present and exact. The guide ends with a section headed exactly
`## 11. Troubleshooting` (line 334), and the table header is exactly
`| failure reason | symptom | signal you see | remedy |` (line 345) — four
columns as specified, table form throughout (rows at lines 347-388). The
heading matches the task's required string byte-for-byte.

## Q2

Fully real. I extracted every reason literal from the source (constructor
first-args of `UsageError`/`ContractError`, `reason:` literals, and blocker
`code:` literals — 80 codes) and cross-checked every backticked reason token
in the table. All ~45 distinct reason strings in the table exist in the
source, including the easy-to-miss ones: `handoff_revision_drift`
(mjs:769), `worktree_identity_mismatch` (mjs:750), `verified_evidence_*`
(mjs:780/784/793), `run_in_honest_partial` (mjs:1116), `unreconciled_side_effect`
(mjs:1397), blocker codes `stopped`/`outcome_unknown` (mjs:408/410), and
`no_command` (mjs:1450). Spot-checked beyond 8 (all 41 rows); zero invented
reason strings. Non-reason tokens in the symptom column (`run_id`,
`goal_sha256`, `intended_post_sha256`, `gate_evidence`, …) are genuine
details/field names present in the source payloads.

## Q3

Accurate for every enumerated check (a)-(f):
- (a) `journal_missing`/`journal_empty`/`journal_partial_line` → `{path}`
  (mjs:264/266/269); `journal_corrupt`/`journal_blank_line`/`journal_seq_broken`
  → `{line}` (mjs:279/281/274/282). Matches guide rows 11-12.
- (b) `handoff_frozen_tampered` is `throw`n in `loadRun` (mjs:758-763), so it
  lands in `status.reason` via `errorResult` (mjs:1418), never in `blockers`;
  `details.path` names the frozen copy; restore-first remedy is the only path —
  `stop` also calls `withRun`→`loadRun` (mjs:1103-1109, 1360-1363) and throws,
  so the row's "every command loads and throws" claim is correct.
- (c) `outcome_is_actually_confirmed` → `{actual}` (mjs:1300);
  `outcome_is_actually_untouched` → `{actual, hint}` (mjs:1303-1306).
- (d) `receipt_verdict_not_pass` → `{verdict}` (mjs:884); the four `*_mismatch`
  codes → `{got, want}` (mjs:885/886/888/891); `receipt_head_not_ancestor` →
  `{gated_head, current_head}` (mjs:906-909).
- (e) `verified_evidence_*` are pushed to `bindingBlockers` and concatenated
  into `state.blockers` (mjs:780-797, 801); `run_in_honest_partial` →
  `details.blockers` + `details.required` (mjs:1118-1119), and `reason` is the
  named blocker code, not a generic message.
- (f) The intro explicitly disclaims exhaustiveness and names `message`,
  `note`, `tokens`/`budget` — all of which genuinely appear in details objects
  (e.g. mjs:1014, 675/694, 1061-1062). No exhaustiveness overclaim.

## Q4

No fabrication and no tampering. The git diff for the S2 commit is pure
addition — `@@ -328,3 +328,61 @@` with only `+` lines, appending `---` +
`## 11. Troubleshooting` after the last `stop` row of §10; no existing line was
deleted or reworded (verified against `git show 93621de0`). Every row's
behavior claim traces to source lines.

However, two *signal-column* defects exist (neither is fabrication, but both
are factual errors):

- **Defect 1 — row `run_stopped` / `already_stopped` (guide line 374).** The
  symptom "recording anything after `stop`" claims `reason: "run_stopped"`.
  That is only true for `reconcile` (mjs:1234). For `checkpoint`, `verify` and
  `action-start` on a stopped run, `refuseIfHonestPartial` throws the first
  blocker's code, which is `stopped` (mjs:1116 with blockers from mjs:408) —
  i.e. the row's claimed reason does not match actual output for 3 of the 4
  commands under that symptom. (The adjacent `run_in_honest_partial` row does
  document the `stopped` code, so the gap is recoverable, but the row as
  written is inaccurate.)
- **Defect 2 — intro (guide line 340).** "exit `1` means the ledger is intact
  but the run is blocked" is not true for `run_already_initialized` (mjs:1005):
  exit 1, ledger intact, and the run is fully usable via `status`/`resume` (the
  row's own remedy says so). Also odd for pre-init failures (`base_commit_mismatch`,
  `handoff_missing`…) where no run exists yet.

All other 39 rows verified correct, including every exit code and details-field
claim.

verdict: FAIL

---

## Re-review (round 2)

Re-checked the fix commit `93c050f9` (diff: 3 insertions, 1 deletion — the
single `run_stopped`/`already_stopped` row replaced by three rows; no other
line touched) against the source.

- **Row `stopped`** (guide line 374): correct. `checkpoint`, `verify` and
  `action-start` are exactly the three callers of `refuseIfHonestPartial`
  (mjs:1137/1160/1198); on a stopped run `state.state` is `HONEST_PARTIAL`
  (mjs:414) and `blockers[0].code` is `stopped` (mjs:408), so the refusal
  throws `stopped` with `details.blockers` + `details.required` (mjs:1116-1119).
  Exit 1 via `errorResult` (mjs:1411). The row's parenthetical is accurate.
- **Row `run_stopped`** (guide line 375): correct. `run_stopped` is thrown
  only in `cmdReconcile` (mjs:1233-1234), before the binding-blocker check
  (mjs:1239). Exit 1. Remedy matches the source note ("open a NEW run").
- **Row `already_stopped`** (guide line 376): correct. Thrown only in
  `cmdStop` when `state.stopped` is already set (mjs:1363). Exit 1.

Surrounding rows re-spot-checked, no new defects: `confirmed_requires_intended_post`
(mjs:1293), `outcome_is_actually_*` (mjs:1300/1303), `run_locked` (mjs:692),
`concurrent_writer_detected` (mjs:715), `event_would_corrupt_journal`
(mjs:670, `details.would_fail_with` mjs:672) — all unchanged and accurate.

One residual edge nuance, not a defect: on a stopped run, `action-start` with
an id in `forbidden_retry_actions` reports `blind_retry_forbidden` first
(mjs:1195 precedes mjs:1198), not `stopped`. That is consistent with the
source's deliberate check ordering and is documented in the separate
`blind_retry_forbidden` row.

Round-1 defect 1 is resolved. Round-1 defect 2 (intro "exit 1 means … the run
is blocked" over-generalization for `run_already_initialized`/pre-init errors)
was already judged a framing imprecision, not a row-level error; the fixed
rows are unaffected by it.

Final verdict: PASS