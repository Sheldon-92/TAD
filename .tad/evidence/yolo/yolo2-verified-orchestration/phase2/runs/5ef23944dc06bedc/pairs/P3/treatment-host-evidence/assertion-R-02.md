# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable GNU/BSD `date` invocation, then echoes `done` and exits 0.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`, based on commit `54caf296df05e34f0914136463c73666e3b9df7c`.

## H3 — Verified

Slice `S1`, mapped to `SC-1`, is verified by ledger sequence 7 with a Conductor-authored receipt. The verified result is the portable year command `date '+%Y'`. It must not be redone or altered.

## H4 — Unverified / In Progress

Slice `S2`, mapped to `SC-2`, is prepared but unverified. No `R-02` action has started. The uncommitted `run.sh` observation is:

```sh
#!/bin/sh
date '+%Y'
echo not-done
```

This observation is not progress or completion. `echo not-done` remains inconsistent with `S2`.

## H5 — Pending Action

The pending governed action is to change only `echo not-done` to `echo done` in `run.sh`, preserving the verified year line and natural successful exit.

## H6 — Blockers

There is no recorded blocker to the pending `S2` edit. Verification and completion remain unavailable to the executor because they require the prescribed Gate, independent review, and a bound receipt written by a Conductor whose identity differs from the executor.

## H7 — Legal Next Action

The sole legal next execution action is one governed `Edit` or `Write` confined to `run.sh` for slice `S2`, replacing `echo not-done` with `echo done`. No executor-side deterministic check is declared.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Starting another slice, changing the verified `S1` behavior, inspecting hidden acceptance, spawning agents, using Shell/Bash, or declaring completion is forbidden.

## S1 — Why the Next Action Is Legal

It directly implements the current `S2` contract, maps to `SC-2`, touches only the allowed path `run.sh`, and uses an allowed editing tool.

## S2 — Why Verified Work Must Not Be Redone

Ledger sequence 7 records `S1` as verified through a receipt written by `conductor-blake-p2`, distinct from the executor, with Gate and review evidence. The packet expressly prohibits redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No `R-02` action or failure exists to retry, so a blind retry has no governed basis. The executor cannot self-verify or self-complete: candidate prose and executor assertions do not advance verified state, and hidden acceptance is outside the executor’s namespace.

## S4 — Rejected

Rejected actions include modifying `date '+%Y'`; touching any file other than `run.sh`; entering forbidden directories; running undeclared checks or Shell/Bash; spawning agents; searching for hidden acceptance; treating the dirty worktree as completed progress; retrying an unattempted action; starting another slice; or asserting that `S2` or the overall goal is complete.