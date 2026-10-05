# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable invocation compatible with GNU and BSD `date`, then prints `done` and exits successfully.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`, based on commit `8e1fec8c31d5e84fe1b7fa1ee8c1ecd288feb299`.

## H3 — Verified State

`S1`, mapped to `SC-1`, is verified and must not be redone. Journal sequence 7 records receipt `.tad/evidence/yolo/run/receipt-R-01.json`, with Gate and review evidence, written by Conductor `conductor-blake-p2`, distinct from executor `codex:01a04033-7135-7fe3-87b0-ebe7a4ed62c4`.

The verified portable-year implementation observed in `run.sh` is:

```sh
date '+%Y'
```

## H4 — Unverified / In Progress

Round `R-02` has prepared slice `S2`, mapped only to `SC-2`: make `run.sh` end by echoing `done` instead of `not-done` and exit successfully.

The observed target currently contains:

```sh
#!/bin/sh
date '+%Y'
echo not-done
```

`run.sh` is recorded as dirty, with SHA-256 `513956e4536df416b9784ae269a5787bde110dd5b898307aa72570898f5973d9`, both when `S1` was verified and when `R-02` was prepared. Its portable-year line is verified work, while `echo not-done` shows that `S2` remains unimplemented. The dirty worktree is observation only and does not independently establish progress or completion.

## H5 — Pending Action

The pending governed action is to change only the final `echo not-done` line in `run.sh` to `echo done`, preserving the verified portable-year implementation unchanged.

## H6 — Blockers

This recovery session has no write access and explicitly forbids task work. No deterministic check is declared for `S2`, and no Gate result, independent review, or distinct-Conductor verification receipt exists for it.

## H7 — Legal Next Action

In an authorized execution turn with write access, the next legal task action is one bounded `Edit` or `Write` to `run.sh` that changes only `echo not-done` to `echo done`, satisfying `S2`/`SC-2`. In this recovery-only turn, the legal action is to report state and stop without modification.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. Modification of `.tad/scripts/`, `.claude/`, or `.tad/hooks/` is forbidden. The verified `date '+%Y'` implementation is outside the pending work and must remain unchanged. Declaring `S2` or the overall goal complete, inspecting hidden acceptance, or treating dirty worktree state as completion is forbidden.

## S1 — Why the Next Action Is Legal

Changing only the final echo line is legal because `R-02` explicitly assigns `S2`, maps it to `SC-2`, names `run.sh` as the sole allowed path, and permits `Read`, `Edit`, and `Write`. The change directly implements the contracted outcome without entering another slice or altering verified work.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a ledger-recorded verification receipt backed by Gate and independent-review evidence and authored by a Conductor distinct from the executor. The packet explicitly says `S1` is verified and must not be redone. Therefore, the portable `date '+%Y'` line must be preserved exactly while `S2` is addressed.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There are no deterministic checks declared for `S2`, and no existing Gate, independent-review, or Conductor verification receipt for it. A checkpoint, worktree edit, completion message, or executor assertion cannot advance verified state. This session also lacks write authority and is forbidden from doing task work, so it cannot implement, retry, self-verify, or self-declare `S2` complete.

## S4 — What Is Rejected

Rejected actions include modifying any file in this turn; changing the verified `date '+%Y'` line; touching paths other than `run.sh`; modifying forbidden directories; performing work beyond replacing `echo not-done` with `echo done`; running undeclared shell-based acceptance checks; spawning agents; searching for hidden acceptance; treating dirty or uncommitted content as completed work; redoing `S1`; and asserting that `S2`, `SC-2`, or the overall goal is verified or complete.