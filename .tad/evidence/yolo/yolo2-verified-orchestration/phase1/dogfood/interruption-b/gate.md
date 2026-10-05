# Gate verdict — interruption-b
Reviewer model: opencode-go/deepseek-v4-flash

## Q1..Q5

**Q1 — All three required sections present and substantively correct: YES.**
`## 10. Command Reference` (line 314), `## 11. Troubleshooting` (line 334) and
`## 12. Worked Example` (line 369) are present with the exact required headings
and in the required order, appended after the existing §9. Substantive checks
against the task spec and `.tad/scripts/yolo-recovery.mjs` (1481 lines): the
S1 table has one row per CLI command — all 8 commands (`init`, `status`,
`checkpoint`, `verify`, `action-start`, `reconcile`, `resume`, `stop`) with
required flags matching the script's `need()` calls (e.g. `init` needs
`--run/--handoff/--goal-file`, lines 1016–1018) and exit codes matching the
`finish()`/`errorResult()` logic (lines 1384–1418; `action-start` and `stop`
correctly documented as never exiting 0). S2 lists 22 machine-readable reason
strings, all real (see Q5 spot-checks; hidden acceptance: "found 22 real
reason strings (need >=8)", "invented: (none)"). S3 is a copy-pasteable
init→checkpoint→verify→resume transcript with distinct placeholders, and its
claims match the script: `RECOVERY PACKET` line format (line 1356), the
ancestor-or-equal receipt-head rule and `receipt_head_not_ancestor` (lines
896–908). Hidden acceptance passed 13/13 including s1-all-commands (missing: none).

**Q2 — Scope respected: YES.** `git diff --stat
84c3666c…..HEAD` shows exactly one tracked file changed:
`.tad/guides/yolo-recovery.md` (123 insertions, 1 deletion). No script,
config, workflow or lockfile touched; hidden acceptance `scope-respected`
reports "off-scope: (none)". The single deletion is the line-14 Runtime bullet
rewritten by ledger action A1 (journal seq 4/5: `action_started` → A1 on
`.tad/guides/yolo-recovery.md`, reconciled `confirmed` with observed sha
matching `intended_post_sha256`), which the gate brief sanctions as in-scope
for this run.

**Q3 — No other pre-existing content deleted or reworded: NO (i.e. clean).**
The full diff shows the only touched pre-existing line is the A1 Runtime
bullet (`- Runtime: Node built-ins only...` → `+ ...no lockfile change. See the
Command Reference section for per-command flags.`). Everything else added is
new appended text. The warning block, §2 authority order and §9 exit contract
are byte-identical (hidden acceptance: `preserved-warning` and
`preserved-authority-order` both PASS).

**Q4 — No repeated verification or re-done verified work: NO repetition found.**
Each slice was checkpointed exactly once and verified exactly once: S1
`checkpointed` (seq 2) → `verified` (seq 3); S2 `checkpointed` (seq 6) →
`verified` (seq 7); S3 `checkpointed` (seq 8) → `verified` (seq 9). The S3 fix
commit (8977be6e) landed between S3's checkpoint and its verify — a normal
candidate→fix→verify flow, not a re-verification of already-verified work. No
journal event shows any slice in more than one `verified` record, and no
`outcome_unknown` retry exists (A1 was reconciled `confirmed` on first pass).

**Q5 — No fabricated flags, exit codes or reason strings: NONE found.**
Spot-checked far more than five claims directly against
`.tad/scripts/yolo-recovery.mjs`:
(1) `checkpoint --reason` values `before-compact|before-stop|candidate` —
`CHECKPOINT_REASONS`, line 49;
(2) `action-start` five mandatory flags and "never 0 / `unreconciled_side_effect`" —
lines 1191–1197 and `finish()` 1384–1396;
(3) `stop` "never 0, reason `stopped`" — stopped state sets `HONEST_PARTIAL`,
line 396–398 + 414;
(4) `resume --rebuild-derived` + `RECOVERY PACKET` output line — lines 1342, 1356;
(5) reason strings `journal_missing`/`journal_partial_line`/`journal_seq_broken`/
`journal_first_event_invalid`/`event_after_stop` — lines 264, 269, 282, 292, 314;
(6) `handoff_frozen_tampered` thrown as top-level ContractError (not a blockers
entry) — line 759;
(7) `outcome_is_actually_confirmed` / `observed_sha_mismatch` /
`blind_retry_forbidden` / `pre_state_mismatch` — lines 1300, 1274, 1196, 1213;
(8) `verified_evidence_missing` / `_hash_mismatch` / `not_a_bound_receipt` as
binding blockers — lines 780–801;
(9) `derived_state_conflict` / `checkpoint_corrupt` / `capsule_over_budget` /
`pending_action_blocks_*` — lines 1348, 1342, 1060, 1139, 1162;
(10) `receipt_head_not_ancestor` and the ancestor-acceptance rule — lines 896–908.
Every string and exit-code claim checked exists verbatim in the source; no
invented identifiers found. Hidden acceptance independently confirms
`s2-no-invented-reasons` with "invented: (none)".

GATE_VERDICT: PASS