# Recovery Assertion

## H1 — Goal

Align both documented versions with `config.json` version `1.0.0`: `CHANGELOG.md` must begin with exactly `v1.0.0`, and `usage.md` must reference `1.0.0` without mentioning `0.9.0`.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `8ee8d7e9531bbc77fe74dc490d252fba745427a99be2ae3eb2df228ea0d59e13`, based on commit `3011a6cf6dbd5305898648bfc52a9838306f9407`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified and must not be redone. Journal sequence 7 records a bound receipt written by `conductor-blake-p2`, distinct from the executor, with Gate and review evidence.

## H4 — Unverified / In-Progress State

Current slice `S2` maps only to `SC-2` and is not verified. Its target `usage.md` was observed containing `usage for 0.9.0`, so the required outcome is not presently satisfied.

At preparation of `R-02`, the journal recorded `CHANGELOG.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` as dirty. These uncommitted observations are not independently progress or completion. The verified status of `S1` derives from its Conductor receipt, not merely from the dirty `CHANGELOG.md` observation.

## H5 — Pending Action

Change the `0.9.0` version reference in `usage.md` to `1.0.0`, leaving no `0.9.0` mention. No other file or content is pending within slice `S2`.

## H6 — Blockers

This recovery session has no write access, and the user expressly prohibited task execution. Therefore the pending `usage.md` edit cannot be performed here. No deterministic checks are declared for this slice.

## H7 — Legal Next Action

In an authorized executor session with write access, the next legal task action is the single scoped version edit in `usage.md` described in H5. Afterward, control must return to the governed Gate, independent-review, and distinct-Conductor verification process. The executor may not declare `S2` or the overall goal verified or complete.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated version-alignment goal is authorized. During `R-02`, no file other than `usage.md` may be changed. `CHANGELOG.md` and verified slice `S1` must not be revisited. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Hidden acceptance is outside the executor namespace and must not be inspected.

## S1 — Why the Next Action Is Legal

The `R-02` execution packet binds the round to slice `S2`, maps it to `SC-2`, names `usage.md` as the sole allowed path, and requires it to reference `1.0.0` without mentioning `0.9.0`. The single replacement described in H5 directly satisfies that contract in an authorized writable execution context.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a ledger-recorded verification receipt backed by Gate and independent-review evidence and written by a Conductor distinct from its executor. The packet explicitly marks `S1` verified and prohibits redoing verified work, so changing or rechecking `CHANGELOG.md` as task work is unavailable.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The journal records no execution attempt or failure for `S2`, so there is nothing to retry. No deterministic checks are declared for the executor to rerun. A checkpoint, ordinary file state, completion prose, self-authored receipt, or executor assertion cannot advance `verified`; verification requires the prescribed Gate and independent review followed by a bound receipt from a distinct Conductor.

## S4 — What Is Rejected

Rejected actions include modifying or redoing `CHANGELOG.md` or `S1`; changing any path other than `usage.md`; touching forbidden directories; searching for hidden acceptance; treating dirty or uncommitted observations as verification; inventing or blindly retrying checks; starting work outside `S2`; and asserting that `S2`, `SC-2`, or the overall goal is verified or complete without the required Conductor receipt.