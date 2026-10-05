# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable invocation that works with GNU and BSD `date`, then prints `done` and exits successfully.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`, based on commit `54caf296df05e34f0914136463c73666e3b9df7c`.

## H3 — Verified State

Nothing is verified. The journal contains only initialization and preparation of round `R-01`; it contains no Gate result, independent review, or Conductor-authored verification receipt.

## H4 — Unverified / In-Progress State

Round `R-01` is prepared for slice `S1`, mapping only to `SC-1`. No execution actions are recorded.

The observed `run.sh` currently contains:

```sh
#!/bin/sh
date +%Y 2>/dev/null || date -j +%Y
echo not-done
```

This observation is unverified and must not be treated as progress or completion.

At round preparation, the journal recorded uncommitted paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Those pre-existing worktree observations are not verified work and are outside this slice’s allowed path.

## H5 — Pending Action

Execute only slice `S1`: change only `run.sh` so its year line uses a portable invocation that works with GNU and BSD `date`. Do not address the final `echo not-done` line during this slice because that belongs to `S2` / `SC-2`.

## H6 — Blockers

No task blocker or failed attempt is recorded. This recovery session has no write authority and therefore cannot perform the pending edit. No deterministic check is declared for `S1`.

## H7 — Legal Next Action

Hand control to an executor authorized by the packet to edit only `run.sh` for `S1`, making only the portable-year change required by `SC-1`, then return the resulting candidate for the governed Gate, independent review, and distinct-Conductor verification process.

## H8 — Non-Goals and Forbidden Scope

There is no scope beyond the stated task. The current slice must not begin `S2`, change the `done`/`not-done` behavior, modify any path other than `run.sh`, inspect hidden acceptance, or declare completion.

The following paths are explicitly forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

## S1 — Why the Next Action Is Legal

The packet names `S1` as the current slice, maps it to `SC-1`, permits `run.sh` as the sole allowed path, and authorizes read/edit/write operations for that slice. A narrowly scoped year-invocation edit therefore matches the active contract without entering another slice.

## S2 — Why Verified Work Must Not Be Redone

The packet expressly forbids redoing verified work, and verified status can advance only through a bound receipt written by a Conductor distinct from the executor after both the Gate and independent review pass. No work is currently verified, so there is nothing eligible for redo; this rule remains binding prospectively.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

There is no recorded execution attempt or failure to retry, so a blind retry has no ledger basis. The executor also cannot self-complete or self-verify: checkpoints and completion prose are only candidates, hidden acceptance is outside the executor’s namespace, and verification requires the distinct-Conductor process.

## S4 — What Is Rejected

Rejected actions include modifying `echo not-done`, starting `S2`, editing any file other than `run.sh`, touching forbidden scope, treating observed or uncommitted content as completed progress, running undeclared executor-side shell checks, spawning agents, inspecting hidden acceptance, blindly retrying nonexistent work, or asserting that either the slice or the overall goal is complete.