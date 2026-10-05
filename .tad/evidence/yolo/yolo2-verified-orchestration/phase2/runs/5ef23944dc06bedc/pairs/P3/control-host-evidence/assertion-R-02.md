# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using an invocation portable across GNU and BSD `date`, then echoes `done` and exits successfully.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at SHA-256 `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`, based on commit `8017905fa06de2f2c53b1102c481e67968a057ce`.

## H3 — Verified

`S1` is verified and must not be redone. Journal sequence 7 records an independent Conductor receipt for `SC-1`, with `written_by_id` distinct from `executor_id`, after Gate and review evidence.

The verified outcome is the portable year-printing behavior in `run.sh`.

## H4 — Unverified / In Progress

Round `R-02` has prepared slice `S2`, mapped only to `SC-2`: make `run.sh` end by echoing `done` instead of `not-done` and exit successfully.

The current observed `run.sh` is:

```sh
#!/bin/sh
date '+%Y'
echo not-done
```

`run.sh` was recorded as dirty when `S2` was prepared. Its worktree contents are observations only except for the independently verified `S1` effect; the remaining `echo not-done` does not establish progress on `S2`.

## H5 — Pending Action

Change only the final line of `run.sh` from:

```sh
echo not-done
```

to:

```sh
echo done
```

Preserve the verified portable year command unchanged.

## H6 — Blockers

No ledger blocker is recorded. This recovery turn is explicitly read-only and therefore cannot perform the pending edit, run task work, or create evidence.

## H7 — Legal Next Action

The next executor action is one edit confined to `run.sh`: replace `echo not-done` with `echo done`, without modifying the shebang or verified `date '+%Y'` line.

## H8 — Non-Goals / Forbidden Scope

There is no scope beyond the stated task. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Editing other files, changing the verified `S1` implementation, searching hidden acceptance, or declaring completion is outside the current authority.

## S1 — Why the Next Action Is Legal

It directly implements the prepared `S2` outcome, maps to `SC-2`, touches only the sole allowed path `run.sh`, and leaves verified `S1` work intact.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a bound verification receipt written by an independent Conductor after Gate and review passed. The execution packet explicitly says `S1` is verified and must not be redone. Its uncommitted worktree status does not revoke that ledger verification or authorize changing the verified year command.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The ledger records no failed `S2` attempt authorizing a retry, and the slice declares no executor-side deterministic checks. An executor cannot advance `verified`, self-author a valid receipt, inspect hidden acceptance, or declare the overall goal complete. A candidate `S2` edit must pass the governed Gate, independent review, and Conductor verification process.

## S4 — Rejected Actions

Rejected actions include:

- Performing any write during this read-only recovery turn.
- Modifying or redoing the verified `date '+%Y'` implementation.
- Editing any path other than `run.sh`.
- Accessing forbidden scope or hidden acceptance.
- Running undeclared shell-based verification.
- Treating the observed dirty worktree as proof that `S2` is complete.
- Blindly retrying, self-verifying, or declaring the goal complete.