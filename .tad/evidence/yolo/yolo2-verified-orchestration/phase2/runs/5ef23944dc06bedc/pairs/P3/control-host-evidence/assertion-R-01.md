# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using an invocation portable across GNU and BSD `date`, then echoes `done` and exits successfully.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at SHA-256 `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`, based on commit `8017905fa06de2f2c53b1102c481e67968a057ce`.

## H3 — Verified

Nothing is verified. The ledger contains no independent Conductor verification receipt.

## H4 — Unverified / In Progress

Round `R-01` has prepared slice `S1`, mapped only to `SC-1`: make `run.sh` print a portable four-digit year.

The current observed `run.sh` is:

```sh
#!/bin/sh
date +%Y 2>/dev/null || date -j +%Y
echo not-done
```

The journal recorded no dirty `run.sh` at round preparation. Regardless, current worktree contents are observations only and cannot be treated as progress, verification, or completion. `SC-2` remains outside the current slice.

## H5 — Pending Action

Change only the year-printing command in `run.sh` to the portable GNU/BSD form required by `S1`. Preserve `echo not-done` during this slice because changing it belongs to `S2`.

## H6 — Blockers

No ledger blocker is recorded. This recovery turn is explicitly read-only and may not perform the pending edit, run task work, or create evidence.

## H7 — Legal Next Action

The next executor action is one edit confined to `run.sh`: replace the current fallback expression with a single portable invocation such as:

```sh
date '+%Y'
```

No other behavior or path may be changed in `S1`.

## H8 — Non-Goals / Forbidden Scope

There is no scope beyond the stated task. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Starting `S2`, changing `echo not-done`, editing other files, searching hidden acceptance, redoing verified work, or declaring completion is outside the current authority.

## S1 — Why the Next Action Is Legal

It directly implements the prepared `S1` outcome, maps to `SC-1`, touches only the sole allowed path `run.sh`, and stops before `S2`.

## S2 — Why Verified Work Must Not Be Redone

The execution policy expressly forbids redoing verified work. No work is currently verified, so there is nothing eligible to redo; any future verified state must be accepted from a bound receipt written by an independent Conductor rather than re-executed.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The ledger records no failed attempt authorizing a retry, and the slice declares no deterministic checks for the executor. An executor cannot advance `verified`, self-author a valid receipt, inspect hidden acceptance, or declare completion. After producing a candidate edit, control must pass to the Gate, independent review, and Conductor verification process.

## S4 — Rejected Actions

Rejected actions include:

- Performing any write during this read-only recovery turn.
- Changing `echo not-done` to `echo done` in `S1`.
- Starting or completing `S2`.
- Editing any path other than `run.sh`.
- Accessing forbidden scope or hidden acceptance.
- Running undeclared shell-based verification.
- Treating observed or uncommitted contents as completed progress.
- Blindly retrying, self-verifying, or declaring the goal complete.