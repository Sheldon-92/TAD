# Independent slice review — interruption-a — S1

Reviewer model: claude-opus-5 (harness=claude-code, route=host)

Scope: slice S1 only (`## 10. Command Reference` in `.tad/guides/yolo-recovery.md`),
judged against `.tad/scripts/yolo-recovery.mjs` (1200 lines) in this worktree.
I did not write the section and I modified nothing but this report.

## Q1 — Is every CLI command present with its REAL required flags?

Yes. The section has 9 table rows: the 8 members of `COMMANDS`
(`init, status, checkpoint, verify, action-start, reconcile, resume, stop`,
source L67-70) plus a row for the no-command / `help` / `--help` / `-h` branch
(L1167-1170). Spot-checking each row's "required flags" against the `need(flags, …)`
calls in its handler:

- `init` (cmdInit L795-798): `need` run / handoff / goal-file — matches.
- `status` (cmdStatus L873, via `withRun` L855): `need` run only — matches.
- `checkpoint` (cmdCheckpoint L886-888): run / slice / reason / next, and the
  guide reproduces the three legal `--reason` values from `CHECKPOINT_REASONS` (L48) — matches.
- `verify` (cmdVerify L908-909): run / slice / receipt — matches.
- `action-start` (cmdActionStart L932, L938-941): run / action / description / target /
  pre-sha256 / intended-post-sha256, all six mandatory — matches.
- `reconcile` (cmdReconcile L971-972): run / action / outcome required; the guide's
  conditional treatment of the two optional flags is exactly right and non-obvious —
  `--evidence` + `--observed-sha256` are both `need()`-ed in the unknown-resolution
  branch (L983, L991) and in the plain `reconciled` branch (L1034, L1039), while
  `--observed-sha256` is merely cross-checked against disk when supplied for
  `confirmed`/`outcome_unknown` (L1013-1015).
- `resume` (cmdResume L1058-1059): run required; `--rebuild-derived` optional, and the
  guide correctly states it is accepted bare **or** as the literal string `true`,
  which is precisely `flags['rebuild-derived'] === true || === 'true'`.
- `stop` (cmdStop L1086-1087): run / reason — matches.

I also cross-checked the whole flag universe mechanically: the set of flag names
reachable in the source (`need(flags,…)` ∪ `flags['…']`) is exactly the 16 names
used in the section, no more and no fewer.

## Q2 — Are the exit codes stated correctly against the source's exit contract?

Yes. `finish()` (L1106-1127) returns 1 iff state is `HONEST_PARTIAL`, else 0;
`errorResult()` (L1130-1141) returns 2 for `UsageError` and 1 for `ContractError`.
The reducer (L379-381) admits exactly three states — `ACTIVE`, `ACTION_PENDING`,
`HONEST_PARTIAL` — so the `status` row's "0 while ACTIVE / ACTION_PENDING" is exact,
not a guess. Row-level checks I confirmed:

- `init`: `goal_file_not_json` and `goal_file_field_missing` are `UsageError` (L807, L813)
  → 2, while `run_already_initialized` / `handoff_missing` / `goal_file_missing` /
  `base_commit_mismatch` / `oracle_missing` are `ContractError` → 1. The guide splits
  them on exactly that line — this is the easiest row to get wrong and it is right.
- `checkpoint`: `checkpoint_reason_invalid` is a `UsageError` → 2. Verified live on a
  real initialised run: exit **2**, `reason: checkpoint_reason_invalid`.
- `action-start`: exit 0 with state `ACTION_PENDING` is correct because `finish()` only
  demotes on `HONEST_PARTIAL`.
- `reconcile`: `outcome_unknown` pushes into `unknownActions` (L347-354) → state
  `HONEST_PARTIAL` → exit 1, as stated; and `reconciled` splices the entry out
  (L355-358), so the guide's "0 … with nothing else outstanding" is the accurate
  qualifier rather than an unconditional 0.
- `stop`: the claim "never exits 0" is right — `stopped` unconditionally forces
  `HONEST_PARTIAL` (L380), so success is exit 1. This is a genuine trap for readers
  and the guide calls it out explicitly.
- no-command / help row: verified live — exit **2**, trailing JSON `reason: no_command`,
  matching L1169 byte for byte.

Live spot-checks also confirmed: unknown command → exit 2 with `reason: unknown_command`
and an `allowed` list of exactly eight commands (the section's note says "eight"),
missing `--run` → exit 2 `missing_flag`, and `status` on the live run dir → exit 0.

## Q3 — Is anything fabricated?

No. Every flag in the section exists in the source (16/16 exact set match, plus
`--help`, which is a real branch at L1167). Every command named exists in `COMMANDS`.
Only exit codes 0/1/2 appear, which is the full contract. Every machine-readable
token quoted in the notes — `no_command`, `unknown_command`, `missing_flag`,
`derived_state_conflict`, `HONEST_PARTIAL`, `ACTION_PENDING` — appears verbatim in
the source. The `parseArgs`/`need()` note (a `--`-prefixed next token becomes boolean
`true`, and `need()` rejects booleans) is a correct reading of L770-790.

Two non-blocking accuracy nits, neither a fabrication nor a wrong exit code:
(a) the per-row "2 on a missing flag …" enumerations do not mention `path_escape`
(`assertInside`, L145, a `UsageError`) as a further cause of exit 2 — exit 2 is listed
in every row and §9 already documents path escape, so nothing stated is false, but the
enumerations read as exhaustive when they are not;
(b) the preamble says path flags "are resolved against the worktree root" — true for
`resolveInRepo`, but `--run` is additionally confined to `.tad/evidence/yolo`
(`RUN_ROOT_REL`, L52; `resolveRunDir`, L174-180), a stricter base than stated.

## Q4 — Was any pre-existing guide content deleted or reworded?

No. The slice landed as commit `ca09f92b` ("S1: command reference"); `git show --stat`
reports `1 file changed, 32 insertions(+)` touching only `.tad/guides/yolo-recovery.md`,
and `git diff 323c380d ca09f92b -- .tad/guides/yolo-recovery.md | grep '^-'` (excluding
the `---` file header) returns zero removed lines. The `^## ` heading list at
`323c380d` is a strict prefix of the current one, with `## 10. Command Reference`
appended at the end. No other file in the worktree was modified. Code fences and the
markdown table are balanced (9 rows, 4 columns, `\|` correctly escaped inside cells).

independent: true
verdict: PASS
