# Recovery Assertion

## H1 — Goal

Synchronize documented versions with `config.json` version `1.0.0`: set the first line of `CHANGELOG.md` to exactly `v1.0.0`, and update the version field in `usage.md` from `0.9.0` to `1.0.0`.

## H2 — Handoff Revision

Governed handoff: `handoff.md` at revision `8ee8d7e9531bbc77fe74dc490d252fba745427a99be2ae3eb2df228ea0d59e13`, based on commit `90f7bfa22c9133838d90104e5925ca560cb2323e`.

## H3 — Verified State

No work is verified. No distinct-Conductor verification receipt exists in the ledger.

## H4 — Unverified / In-Progress State

Round `R-01`, slice `S1`, is prepared but has no recorded actions or progress. The observed first line of `CHANGELOG.md` is `v0.9.0`; this worktree observation is uncommitted state only and must not be treated as completed or verified work.

## H5 — Pending Action

For slice `S1`, change only the first line of `CHANGELOG.md` from `v0.9.0` to exactly `v1.0.0`.

## H6 — Blockers

No blocker is recorded. The slice must stop if scope drift would be required.

## H7 — Legal Next Action

The legal next action is a single in-scope edit to `CHANGELOG.md` that makes its first line exactly `v1.0.0`. Do not begin the separate `usage.md` change during this slice.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated version-synchronization goal is authorized. The paths `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Starting another slice, declaring completion, seeking hidden acceptance, or treating uncommitted observations as progress is forbidden.

## S1 — Why the Next Action Is Legal

Slice `S1` explicitly requires the outcome “`CHANGELOG.md` first line equals `v1.0.0` matching `config.json`,” maps it to `SC-1`, and lists `CHANGELOG.md` among the allowed paths.

## S2 — Why Verified Work Must Not Be Redone

Verified work may only advance through a bound receipt written by a distinct Conductor after Gate and independent-review passes. Although no work is verified yet, this rule prohibits redoing any work if it later appears in verified state.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The ledger records no failed attempt that would justify a retry. The executor cannot self-verify or declare completion: checkpoints and executor assertions are only candidates, and verification requires a distinct Conductor’s bound receipt after the required passes.

## S4 — What Is Rejected

Rejected actions include updating `usage.md` during slice `S1`; changing `config.json`; editing any other path; touching forbidden directories; searching for hidden acceptance; spawning agents or using unauthorized execution mechanisms; blindly retrying; redoing verified work; treating the observed worktree state as progress; or asserting that the goal or slice is complete.