# Independent slice review — control — S1 (`## 10. Command Reference`)
Reviewer model: claude-opus-5

## Q1 — Does the section meet its slice spec in substance?

Yes. `.tad/guides/yolo-recovery.md:314-350` contains a markdown table with exactly the four
required columns (command | required flags | optional flags | exit codes it can produce) and one
row per CLI command. Coverage is complete against the source: `COMMANDS` in
`.tad/scripts/yolo-recovery.mjs:68-71` lists exactly eight subcommands (`init`, `status`,
`checkpoint`, `verify`, `action-start`, `reconcile`, `resume`, `stop`) and all eight have a row,
plus a ninth row for the `help` / `--help` / `-h` / no-command path handled at
`yolo-recovery.mjs:1167-1170`. The section goes beyond a bare table with two substantive notes
that are genuinely derived rather than padded: a `reconcile` conditional-flag note (which flag is
mandatory per `--outcome`) and a path-resolution note. Nothing in the section is boilerplate.

## Q2 — Is every technical claim actually true against the CLI source?

Yes; I spot-checked far more than five items, by source read and by executing the CLI in an
isolated clone (never in this worktree). (1) Required/optional flags per command are byte-identical
in substance to the `USAGE` block at `yolo-recovery.mjs:1142-1158` — `resume`'s only optional flag
`--rebuild-derived` is read at `:1057`. (2) The parser claim ("a flag whose next token starts with
`--` is read as boolean `true`, which is why a value-less flag fails as `missing_flag`") is exactly
`parseArgs` `:766-784` plus `need()` `:786-790`; executed: `checkpoint --reason --next x` returned
`"reason":"missing_flag","details":{"flag":"--reason"}` at exit 2. (3) Exit-code layering is correct:
`UsageError`→2 / `ContractError`→1 / `HONEST_PARTIAL`→1 (`errorResult` `:1126-1141`, `finish`
`:1097-1124`). (4) The `stop` row's claim that it *never* exits 0 is right — `stopped` forces
`state='HONEST_PARTIAL'` at `:380`, and an executed `stop` returned exit 1. (5) The `reconcile` row's
"0 for confirmed/reconciled; 1 for outcome_unknown" is right: `outcome_unknown` pushes an unknown
action (`:347-354`) which flips state to HONEST_PARTIAL, while `reconciled` splices it out
(`:355-358`). (6) The conditional-flag note matches `cmdReconcile` `:967-1050`: `--observed-sha256`
is an optional cross-check for `confirmed`/`outcome_unknown` (`:1013`), and the `reconciled` branch
calls `need(flags,'evidence')` and `need(flags,'observed-sha256')` (`:1035,:1041`) — so both are
`missing_flag`/exit 2 when absent. (7) The `help` row's `reason: no_command` at exit 2 was executed
and confirmed. (8) The path note matches `resolveRunDir`/`resolveInRepo`/`assertInside`
`:174-186,:141-148` and `realpathDeepest` `:128-139`; executed `status --run /tmp` returned
`path_escape` with `details.label/path/base` at exit 2.

## Q3 — Is anything fabricated?

No. Every flag name, exit code and command in the table appears in the source. I diffed the table's
flag set against `USAGE` and against each `cmd*` function's `need()` calls and found no invented
flag, no invented command, and no exit code outside {0,1,2}. The `help` row is not an invented
command — `runCli` `:1167` accepts the literal `help` alongside `--help`/`-h`/no argument.

## Q4 — Was any pre-existing guide content deleted or reworded?

No. `git diff 323c380..HEAD` over the worktree reports `1 file changed, 373 insertions(+)` with a
single hunk `@@ -308,3 +308,376 @@` — a pure append to `.tad/guides/yolo-recovery.md`, zero deleted
lines, and no other file touched (in particular `.tad/scripts/**`, `.claude/**`, `.tad/hooks/**` are
untouched). Existing section numbering runs 1-9, so §10-12 append without renumbering anything.

independent: true
verdict: PASS
