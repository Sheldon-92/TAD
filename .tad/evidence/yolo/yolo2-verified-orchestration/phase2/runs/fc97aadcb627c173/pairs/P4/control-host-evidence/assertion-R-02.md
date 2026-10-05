# Recovery Assertion

## H1 — Goal

Make the documented versions match `config.json` version `1.0.0`:

- SC-1: `CHANGELOG.md` first line must equal `v1.0.0`.
- SC-2: `usage.md` must reference `1.0.0` and no longer mention `0.9.0`.

## H2 — Handoff Revision

- Handoff: `handoff.md`
- Revision: `8ee8d7e9531bbc77fe74dc490d252fba745427a99be2ae3eb2df228ea0d59e13`
- Base commit: `6a2bb76d411b2a6ef92d77dd8ff7d9532dcf69fc`

## H3 — Verified State

Slice `S1`, mapped to SC-1, is verified and must not be redone. Its bound receipt was written by `conductor-blake-p2`, distinct from the executor, after Gate and review evidence were recorded.

## H4 — Unverified / In Progress

Current slice `S2` maps only to SC-2 and is not verified. The observed `usage.md` content is `usage for 0.9.0`, so the required outcome is not present.

At R-02 preparation, the journal recorded these dirty paths: `CHANGELOG.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Dirty or uncommitted state is observation only. In particular, the dirty status of `CHANGELOG.md` does not invalidate or authorize redoing verified slice `S1`.

## H5 — Pending Action

Within `usage.md`, replace the `0.9.0` version reference with `1.0.0` so the file references `1.0.0` and no longer mentions `0.9.0`.

## H6 — Blockers

No blocker is recorded. Scope drift is the declared stop condition.

## H7 — Legal Next Action

The sole legal task action is an allowed `Read`, `Edit`, or `Write` operation on `usage.md` that produces the current `S2` outcome. Verification and completion remain responsibilities of the governed Conductor process.

## H8 — Non-Goals and Forbidden Scope

There is no scope beyond the stated cross-file version task. Slice `S1` and `CHANGELOG.md` are outside the current execution contract because S1 is already verified.

Forbidden scope:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

## S1 — Why the Next Action Is Legal

It directly implements the current `S2` outcome, maps to SC-2, uses the only allowed path (`usage.md`), and stays within the packet’s `Read`, `Edit`, and `Write` tool allowlist.

## S2 — Why Verified Work Must Not Be Redone

The ledger records a bound verification receipt for `S1`, written by a Conductor distinct from the executor and supported by Gate and independent review evidence. The packet expressly says `S1` is verified and must not be redone, even though `CHANGELOG.md` remains an observed dirty path.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

No failed S2 attempt or authorized retry is recorded. Uncommitted content cannot be treated as progress, and an executor assertion or ordinary file cannot establish verification. S2 can advance only through a bound receipt written by a distinct Conductor after the existing Gate and an independent review both pass.

## S4 — Rejected Actions

Rejected actions include:

- Reopening or modifying verified slice `S1`.
- Editing `CHANGELOG.md`, `config.json`, or any path other than `usage.md`.
- Touching any forbidden-scope path.
- Looking for hidden acceptance material.
- Using shell/Bash or spawning agents for Phase-2 execution.
- Treating dirty or uncommitted files as completed progress.
- Blindly retrying unspecified work.
- Declaring the slice or overall goal complete.
- Self-verifying or authoring a verification receipt as the executor.