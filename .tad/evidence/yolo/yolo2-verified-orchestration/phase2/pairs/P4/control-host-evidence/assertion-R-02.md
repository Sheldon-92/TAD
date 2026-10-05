# Recovery Assertion

## H1 — Goal

Synchronize documentation with version `1.0.0`: `CHANGELOG.md` must begin with exactly `v1.0.0`, and the version reference in `usage.md` must change from `0.9.0` to `1.0.0`.

## H2 — Handoff Revision

Governed handoff: `handoff.md` at revision `8ee8d7e9531bbc77fe74dc490d252fba745427a99be2ae3eb2df228ea0d59e13`, based on commit `90f7bfa22c9133838d90104e5925ca560cb2323e`.

## H3 — Verified State

Slice `S1` is verified by a distinct-Conductor receipt and must not be redone. Its verified outcome is that the first line of `CHANGELOG.md` equals `v1.0.0`.

## H4 — Unverified / In-Progress State

Round `R-02`, slice `S2`, is prepared but has no recorded action or verified progress. The observed slice target currently contains `usage for 0.9.0`; this uncommitted worktree observation is not progress and must not be treated as done.

## H5 — Pending Action

Update the version reference in `usage.md` from `0.9.0` to `1.0.0` so the file references `1.0.0` and no longer mentions `0.9.0`.

## H6 — Blockers

No blocker is recorded. Execution must stop if completing the slice would require scope drift.

## H7 — Legal Next Action

The legal next action is an in-scope edit to `usage.md` that replaces its `0.9.0` version reference with `1.0.0`. No other slice or file change may be started.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated version synchronization is authorized. The paths `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Redoing verified slice `S1`, starting another slice, declaring completion, seeking hidden acceptance, or treating uncommitted observations as progress is forbidden.

## S1 — Why the Next Action Is Legal

Slice `S2` explicitly requires that `usage.md` reference `1.0.0` and no longer mention `0.9.0`, maps that outcome to `SC-1`, and includes `usage.md` among its allowed paths.

## S2 — Why Verified Work Must Not Be Redone

The ledger records slice `S1` as verified through a receipt written by `conductor-blake-p2`, an identity distinct from its executor, with Gate and independent-review evidence. The packet expressly says “DO NOT redo,” so the `CHANGELOG.md` outcome is outside the pending work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed or attempted action is recorded for slice `S2`, so there is nothing to retry. The executor cannot self-verify or declare completion: only a distinct Conductor may advance verified state after the required Gate and independent review pass.

## S4 — What Is Rejected

Rejected actions include changing or rechecking `CHANGELOG.md` as task work; changing `config.json`; editing any file other than `usage.md`; touching forbidden directories; starting another slice; searching for hidden acceptance; spawning agents or using unauthorized execution mechanisms; blindly retrying; treating the observed target content as progress; or asserting that the slice or goal is complete.