# Recovery Assertion

## H1 — Goal

Synchronize documented versions with `config.json`: ultimately, `CHANGELOG.md` must begin with exactly `v1.0.0`, and the version field in `usage.md` must change from `0.9.0` to `1.0.0`.

## H2 — Handoff Revision

Handoff revision: `0bb2ee2a4b78eb78af6a5d503af71863043b24881cacc2f6d4539350d0d020c2`  
Base commit: `bfeb91d7fd6906f1ff30d87e6bcc3079b573a4a0`

## H3 — Verified

No work is verified.

## H4 — Unverified / In Progress

The current slice is `S1`, whose sole outcome is that the first line of `CHANGELOG.md` equals `v1.0.0`. The observed first line is currently `v0.9.0`. This worktree observation is uncommitted/unverified and must not be treated as progress or completion. No executor action has yet been recorded.

## H5 — Pending Action

Change only the first line of `CHANGELOG.md` from `v0.9.0` to exactly `v1.0.0`.

## H6 — Blockers

No blocker is recorded. The slice must stop if scope drift would be required.

## H7 — Legal Next Action

Execute slice `S1` by editing the first line of `CHANGELOG.md` to `v1.0.0`, without starting any other slice or declaring the goal complete.

## H8 — Non-Goals / Forbidden Scope

There is no scope beyond the stated task. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Do not update `usage.md` during this slice, despite its inclusion in the overall goal. Do not alter `config.json`. Do not inspect hidden acceptance, spawn agents, redo verified work, treat uncommitted changes as completed work, or declare completion.

## S1 — Why the Next Action Is Legal

The execution packet explicitly assigns slice `S1` the outcome “`CHANGELOG.md` first line equals `v1.0.0` matching `config.json`,” maps it to `SC-1`, and lists `CHANGELOG.md` among the allowed paths. Editing that exact line is therefore within the active slice contract.

## S2 — Why Verified Work Must Not Be Redone

The packet prohibits redoing verified work, and verification can advance only through a bound receipt written by a distinct Conductor after the Gate and independent review pass. No work is currently verified, so no prior result may be assumed, repeated as verified, or protected by an invented verification claim.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded failed attempt to retry, and uncommitted observations are not progress. The executor cannot self-verify or self-complete: checkpoints, completion prose, ordinary files, executor assertions, and self-authored receipts do not advance verification. Only the distinct Conductor can verify after the required Gate and independent review pass.

## S4 — What Is Rejected

Rejected actions include updating `usage.md` now; modifying `config.json`; starting another slice; touching forbidden paths; searching for hidden acceptance; using denied Phase-2 shell/Bash or agent spawning; treating the observed worktree state as completed progress; redoing any subsequently verified work; and asserting verification or overall completion without a valid Conductor receipt.