# Independent slice review — control — S2 (`## 11. Troubleshooting`)
Reviewer model: claude-opus-5

## Q1 — Does the section meet its slice spec in substance?

Yes, with two coverage defects recorded below. `.tad/guides/yolo-recovery.md:352-457` delivers the
four required columns (failure reason | symptom | signal you see | remedy) across six sub-tables
grouped by layer (usage/exit 2, `init` refusals, load-time ledger checks, receipt rejection, side
effects, and a "it exited 1 but nothing is wrong" note). ~60 distinct reason strings are documented,
and the "signal you see" column names the actual `details.*` keys rather than restating the reason —
that is real derived content, not filler. Defect A (coverage): the wrong-`--run`-directory case, one
of the likeliest operator errors, is attributed to `journal_missing`, but `loadRun` calls `readGoal`
*before* `readJournal` (`yolo-recovery.mjs:617-618,636`), so that case actually emits `goal_missing`
— a string the section never lists. Executed: `status --run <empty-dir>` returned
`"reason":"goal_missing"`. Defect B (coverage): §11.4 documents 19 receipt rejections but omits
`receipt_missing` (`:692`), which is what a typo'd `--receipt` path produces — executed and
confirmed. Neither defect is fabrication, and the slice spec asks for likely failure modes rather
than exhaustiveness, so this is a substantive PASS with two must-fix follow-ups.

## Q2 — Is every technical claim actually true against the CLI source?

Every reason string, exit code, `details` field and allowed-value list I checked is true; the single
false statement I found is a prose remedy, not a flag/exit-code/reason-string/syntax claim. I
extracted all 76 `UsageError|ContractError` literals from the source and confirmed every one of the
~60 strings in §11.1-11.5 is in that set, none invented. Spot checks (source + executed in an
isolated clone): (1) the banner claim `!! USAGE_ERROR: <reason>` / `!! HONEST_PARTIAL: <reason>`
followed by pretty-printed details matches `runCli`'s catch at `:1185-1186` and `errorResult`
`:1126-1141`. (2) `checkpoint_reason_invalid` — executed `--reason verified` returned
`allowed:["before-compact","before-stop","candidate"]`, confirming the guide's remedy note that
there is deliberately no `verified` reason. (3) `receipt_head_mismatch` is documented as
`details.got` vs `details.current_head` — the source really does use the asymmetric key
`current_head` there (`:721-723`) while its siblings use `want`; the guide got this right.
(4) `verified_evidence_hash_mismatch` is documented as `recorded` vs `actual` — again asymmetric in
source (`:653-655`) and correctly reported. (5) `run_in_honest_partial` — executed after a `stop`;
returned `details.command`/`blockers`/`required` exactly as documented (`:863-869`). (6) §11.6's
claim that the status `reason` is the first blocker code (`stopped` or `outcome_unknown`) matches
`finish` `:1117` and blocker construction `:374-376`; executed `status` after `stop` returned
`"reason":"stopped"` at exit 1. (7) `already_stopped` returns `details.reason` = the *first* stop
reason (`:1088`) — executed and confirmed. (8) `path_escape`, `run_already_initialized`,
`unknown_command` (with all eight allowed commands) all executed and matched. The one untrue claim:
the `journal_missing` remedy "you are pointing at the wrong `--run` directory, or the run was never
initialised" — both of those scenarios emit `goal_missing` instead (Defect A). `journal_missing` in
practice means goal.json exists but journal.jsonl was removed.

## Q3 — Is anything fabricated?

No. I diffed the section's reason-string set against the complete set of error literals in
`yolo-recovery.mjs` (`grep -oE "(UsageError|ContractError)\('[a-z_]+'"`, 76 unique). Every string in
§11 is a member; the difference is one-directional (source has ~16 strings the guide omits, mostly
journal/goal replay-integrity variants plus `receipt_missing` and `slice_already_verified`). No
invented `details` key was found either — I checked each documented key against its throw site.

## Q4 — Was any pre-existing guide content deleted or reworded?

No. Same evidence as S1: `git diff 323c380..HEAD` = `1 file changed, 373 insertions(+)`, single
append hunk `@@ -308,3 +308,376 @@`, zero deletions, no other file modified. Forbidden scope
(`.tad/scripts/**`, `.claude/**`, `.tad/hooks/**`) is byte-identical to base.

independent: true
verdict: PASS
