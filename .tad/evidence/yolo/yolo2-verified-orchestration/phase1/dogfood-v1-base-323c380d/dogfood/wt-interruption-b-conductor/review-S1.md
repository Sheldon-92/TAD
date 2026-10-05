# Independent slice review — interruption-b — S1

Reviewer model: claude-opus-5 (harness=claude-code, route=host)

Scope: slice S1 only — the section `## 10. Command Reference` in
`.tad/guides/yolo-recovery.md`, judged against `.tad/scripts/yolo-recovery.mjs`.
I did not write this section and I modified no file other than this report.

## Q1 — Is every CLI command present with its REAL required flags?

Yes. The table has exactly the 8 commands in `COMMANDS` (yolo-recovery.mjs:69-72):
`init`, `status`, `checkpoint`, `verify`, `action-start`, `reconcile`, `resume`,
`stop` — no more, no fewer. I checked each row's "required flags" cell against the
`need(flags, …)` calls in the corresponding `cmd*` function:
`init` → `--run/--handoff/--goal-file` (L798-800) ✓;
`status` → `--run` only, via `withRun` (L858) ✓;
`checkpoint` → `--run/--slice/--reason/--next` (L887-889) ✓ with the reason enum
`before-compact|before-stop|candidate` matching `CHECKPOINT_REASONS` (L49) ✓;
`verify` → `--run/--slice/--receipt` (L909-910) ✓;
`action-start` → `--run/--action/--description/--target/--pre-sha256/--intended-post-sha256`
(L932, L940-943) ✓;
`reconcile` → `--run/--action/--outcome` always (L971-972), plus `--evidence` **and**
`--observed-sha256` exactly when the outcome is `reconciled` — both the
unknown-resolving branch (L991, L996) and the plain-reconciled branch (L1035, L1039)
call `need()` on both, which is precisely what the row says; the "optional flags"
cell correctly captures that `--observed-sha256` is optional for
`confirmed`/`outcome_unknown` but cross-checked against disk when supplied (L1013-1015) ✓;
`resume` → `--run` required, `--rebuild-derived` optional (L1060) ✓;
`stop` → `--run/--reason`, free text (L1086, no enum check) ✓.
The `*(none)*` optional-flag cells are right: no other flag is consumed anywhere.

## Q2 — Are the exit codes stated correctly against the source's exit contract?

Yes. The contract is `finish()` → `honest ? 1 : 0` (L1108-1110) and `errorResult()` →
`usage ? 2 : 1` (L1128), i.e. `UsageError`→2, `ContractError`→1. I classified every
reason string cited in the table by which error class throws it: all the codes placed
under `2` are `UsageError` throws (`missing_flag`, `path_escape` via `assertInside`
L145, `goal_file_not_json` L812, `goal_file_field_missing` L815,
`checkpoint_reason_invalid` L891, `reconcile_outcome_invalid` L974), and all the codes
placed under `1` are `ContractError` throws. The two non-obvious claims are both
correct and I verified them by executing the exported reducer: `stop` can **never**
exit 0 — a `stopped` event forces `state = HONEST_PARTIAL` (L380), so even a
successful stop returns 1 (probe: `stop -> HONEST_PARTIAL`); and
`reconcile --outcome outcome_unknown` exits 1 because recording it *is* the
honest-partial state (probe: `unk -> HONEST_PARTIAL`), while `confirmed` returns to
`ACTIVE` and `action-start` leaves `ACTION_PENDING` (exit 0) — matching the rows for
`reconcile` and `action-start`. I also executed the usage paths: no command → exit 2
`reason: no_command`; `bogus` → exit 2 `unknown_command` with the allowed set;
`status` without `--run` → exit 2 `missing_flag` — all exactly as the notes claim.
The trailing notes on `parseArgs` boolean-vs-value semantics (L771-779 + `need()`
rejecting `true`, L789) and on `--run` being fenced inside
`<worktree>/.tad/evidence/yolo` (L174-179) are also accurate.

## Q3 — Is anything fabricated?

Nothing. Every flag named in the section (`--run --handoff --goal-file --slice
--reason --next --receipt --action --description --target --pre-sha256
--intended-post-sha256 --outcome --evidence --observed-sha256 --rebuild-derived`)
appears in the source. I grepped all 39 reason strings cited in the table and notes
against `yolo-recovery.mjs` and every one has ≥1 literal occurrence — none invented.
Only exit codes 0/1/2 are claimed, matching the header contract (L21-22). The rows are
non-exhaustive in places (e.g. `git_unavailable` and the ledger-validation failures can
also surface on commands other than the ones they are listed under), but the section
states the shared §9 contract up front and nothing asserted is false; incompleteness of
that kind is not fabrication.

## Q4 — Was any pre-existing guide content deleted or reworded?

No. `git show --stat 9982a621` ("S1: command reference") is `1 file changed, 40
insertions(+)` — zero deletions, and the only file touched is
`.tad/guides/yolo-recovery.md`. `git show -U0` produces no `-` lines at all. The
working tree is clean apart from an unrelated untracked handoff; `.tad/scripts/**` and
all config/workflow paths are untouched. The section is appended after §9 as required,
heading text is exactly `## 10. Command Reference`, and its fences/table markup are
balanced.

independent: true
verdict: PASS
