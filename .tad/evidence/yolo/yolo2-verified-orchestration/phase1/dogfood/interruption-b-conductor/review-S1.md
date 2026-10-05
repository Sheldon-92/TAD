# Independent Slice Review — interruption-b S1

Reviewer model: opencode-go/deepseek-v4-flash

Reviewed (read-only): `task.md` (frozen spec), `yolo-recovery.md` §10, `yolo-recovery.mjs` (full 1481 lines), plus `git diff HEAD~1 HEAD` to confirm append-only.

## Q1 — Section present, exact heading, every command documented

PASS. The guide contains the exact heading `## 10. Command Reference` (yolo-recovery.md:314), matching task.md:12. The table has one row per CLI command and all eight commands declared in the source are covered. Source `COMMANDS = ['init', 'status', 'checkpoint', 'verify', 'action-start', 'reconcile', 'resume', 'stop']` (yolo-recovery.mjs:69-72) ↔ table rows at yolo-recovery.md:323-330. No command missing, none invented.

## Q2 — Flags and exit codes correct against the source (all 8 commands spot-checked)

PASS.

- `init`: `need(flags,'run')` L1000, `need(flags,'handoff')` L1001, `need(flags,'goal-file')` L1002 — row matches; no optional flags (none exist); success → `finish` with ACTIVE state → 0 (L1386-1388), UsageError→2 / ContractError→1 via `errorResult` (L1408-1421).
- `status`: only `--run` (via `withRun` L1106); finish returns 0 on ACTIVE, 1 on HONEST_PARTIAL. Row correct.
- `checkpoint`: `--slice` L1141, `--reason` L1142 (validated against `CHECKPOINT_REASONS = ['before-compact','before-stop','candidate']` L49, L1144-1146), `--next` L1143. Row's reason enum is exact.
- `verify`: `--slice` L1164, `--receipt` L1165. Row correct.
- `action-start`: all five flags via `need` L1191/L1199-1202; none optional. Success always exits 1: reducer sets `state = 'ACTION_PENDING'` when `pendingAction` (L415), `finish` maps both `HONEST_PARTIAL` and `ACTION_PENDING` to `exitCode 1` (L1386-1388), `reason` falls through to `'unreconciled_side_effect'` (L1395-1397). Never 0 — confirmed by the single success path (L1225). Row's "(ACTION_PENDING, reason unreconciled_side_effect); never 0" is exact.
- `reconcile` (the subtle row): (a) `--outcome reconciled` requires `--evidence` and `--observed-sha256` in BOTH branches — pending branch L1310/L1314, resolving-unknown branch L1266/L1271; (b) for `confirmed`/`outcome_unknown`, `--evidence` is never required and `--observed-sha256` is optional but validated when present: `if (flags['observed-sha256'] && ... !== observedActual) throw ContractError('observed_sha_mismatch')` L1288; (c) exit codes: `confirmed` → ACTIVE → 0, `outcome_unknown` → HONEST_PARTIAL → 1 (reducer L381-388, L414; finish L1386-1388). All claims in the row trace to source.
- `resume`: only `--run` required; `--rebuild-derived` optional (L1335). Exit 0/1 by state (L1357 → finish). Row correct.
- `stop`: `--reason` required (L1362). Success always exits 1: reducer sets HONEST_PARTIAL on `stopped` (L414), blocker code `'stopped'` (L408), finish exit 1 with `reason` = `'stopped'` (L1396). Never 0. Row's "(HONEST_PARTIAL, reason stopped); never 0" is exact.

## Q3 — Required columns kept, append-only

PASS. Columns are exactly `command | required flags | optional flags | exit codes it can produce` (yolo-recovery.md:321), matching task.md:14-15. `git diff HEAD~1 HEAD -- .tad/guides/yolo-recovery.md` shows only 20 pure insertions at EOF (after §9, task.md requires append at END); no deletions, no rewording of existing content; only `.tad/guides/yolo-recovery.md` changed in the S1 commit (d738e4e9).

## Q4 — Fabrication

NONE FOUND. Every flag name, enum value, and exit code in the table was traced to source lines (cited above). No flag, exit code, or behavior is claimed that the source does not emit. The two shorthand parentheticals ("reason unreconciled_side_effect", "reason stopped") are accurate — they name `status.reason` while `status.state`/`status.result` are ACTION_PENDING/HONEST_PARTIAL and HONEST_PARTIAL respectively, which the rows convey correctly. The §10 intro ("every command takes --run explicitly, no global active run", exit contract 0/1/2) matches `resolveRunDir` (L204-209), the `--run` requirement of every command, and the header contract L20-22/L1437.

verdict: PASS