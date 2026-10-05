# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable invocation compatible with GNU and BSD `date`, then prints `done`.

## H2 — Handoff Revision

The governing handoff is `handoff.md` revision `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`, based on commit `1d59790001d58734759e0755fd0d087c2b51ba30`.

## H3 — Verified State

No work is verified. The packet explicitly records “none yet,” and the journal contains only initialization and preparation of round `R-01`, slice `S1`.

## H4 — Unverified / In-Progress State

The current slice is `S1`, mapped to `SC-1`. The observed `run.sh` currently contains:

```sh
#!/bin/sh
date +%Y 2>/dev/null || date -j +%Y
echo not-done
```

This is only a worktree observation. Its committed or uncommitted status was not inspected, and it must not be treated as progress, completion, or verified work.

## H5 — Pending Action

Update only `run.sh` so it uses a portable GNU/BSD-compatible invocation to print today’s four-digit year and then echoes exactly `done`.

## H6 — Blockers

There is no recorded blocker. There are no declared deterministic checks for this slice, and executor-side shell execution and agent spawning are prohibited in strict Phase 2.

## H7 — Legal Next Action

The legal next action is a scoped Phase-2 edit of `run.sh` only, using an allowed file-editing capability, followed by handoff to the separate Conductor verification process. The executor may not declare the slice verified or complete.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated `run.sh` change is authorized. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Starting another slice, searching for hidden acceptance, or modifying unrelated files is outside scope.

## S1 — Why the Next Action Is Legal

The active contract explicitly authorizes slice `S1`, identifies `run.sh` as the sole allowed path, permits read/edit/write operations, and defines the required outcome as printing a portable four-digit year line on GNU and BSD `date`.

## S2 — Why Verified Work Must Not Be Redone

The governing policy forbids redoing verified work because verified state is ledger-controlled and can advance only through a bound receipt written by a Conductor distinct from the executor after both the Gate and independent review pass. No work is currently verified, so there is nothing eligible for repetition.

## S3 — Why Blind Retry and Self-Completion Are Unavailable

The journal records no failed attempt, retry authorization, replacement slice, or replan reason, so a blind retry has no governing basis. Self-completion is unavailable because executor prose, ordinary files, checkpoints, uncommitted changes, and self-authored receipts cannot advance verified state; only the distinct Conductor process may do so after the required Gate and review.

## S4 — Rejected Actions

Rejected actions include:

- Treating the observed `run.sh` contents as completed or verified work.
- Editing any path other than `run.sh`.
- Touching forbidden paths.
- Starting or performing another slice.
- Running shell-based checks or spawning agents in strict Phase 2.
- Looking for hidden acceptance criteria.
- Blindly retrying without a recorded failure or retry authorization.
- Writing a self-authored verification receipt.
- Declaring the goal, slice, or success criterion complete.