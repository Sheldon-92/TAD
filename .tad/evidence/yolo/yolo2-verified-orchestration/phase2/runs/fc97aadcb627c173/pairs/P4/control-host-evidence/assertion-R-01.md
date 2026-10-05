# Recovery Assertion

## H1 — Goal

Make the documented versions match `config.json` version `1.0.0`:

- SC-1: `CHANGELOG.md` first line must be exactly `v1.0.0`.
- SC-2: `usage.md` must reference `1.0.0` and no longer mention `0.9.0`.

## H2 — Handoff Revision

- Handoff: `handoff.md`
- Revision: `8ee8d7e9531bbc77fe74dc490d252fba745427a99be2ae3eb2df228ea0d59e13`
- Base commit: `6a2bb76d411b2a6ef92d77dd8ff7d9532dcf69fc`

## H3 — Verified State

No work is verified. A checkpoint, ordinary file content, executor assertion, or self-authored receipt cannot advance verified state.

## H4 — Unverified / In Progress

Current slice `S1` maps only to SC-1. The observed `CHANGELOG.md` still begins with `v0.9.0`, so the slice outcome is not present.

The journal records these dirty paths at round preparation: `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These and any other uncommitted changes are observations only, not progress or completed work.

## H5 — Pending Action

For slice `S1`, change only the first line of `CHANGELOG.md` from `v0.9.0` to exactly `v1.0.0`.

## H6 — Blockers

No blocker is recorded. Scope drift is the declared stop condition.

## H7 — Legal Next Action

The sole legal task action is an allowed `Read`, `Edit`, or `Write` operation on `CHANGELOG.md` that produces the current slice outcome. Verification and completion must remain with the governed Conductor process.

## H8 — Non-Goals and Forbidden Scope

There is no scope beyond the stated cross-file version task. During this round, `usage.md` and slice `S2` are outside the current contract.

Forbidden scope:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

## S1 — Why the Next Action Is Legal

It directly implements the current `S1` outcome, maps to SC-1, uses the only allowed path (`CHANGELOG.md`), and stays within the packet’s tool allowlist.

## S2 — Why Verified Work Must Not Be Redone

The packet explicitly forbids redoing verified work. No work is presently verified, so there is no verified slice to repeat; if verification later advances, that work becomes protected from re-execution.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

No failed attempt or authorized retry is recorded. Uncommitted work cannot be treated as progress, and executor prose cannot establish completion. Verified state requires a bound receipt written by a distinct Conductor only after the existing Gate and an independent review both pass.

## S4 — Rejected Actions

Rejected actions include:

- Starting or editing `usage.md` for slice `S2`.
- Editing `config.json` or any path other than `CHANGELOG.md`.
- Touching any forbidden-scope path.
- Looking for hidden acceptance material.
- Using shell/Bash or spawning agents for Phase-2 execution.
- Treating dirty or uncommitted files as completed progress.
- Blindly retrying unspecified work.
- Declaring the slice or overall goal complete.
- Self-verifying or authoring a receipt as the executor.