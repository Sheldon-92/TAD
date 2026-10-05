# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable GNU/BSD `date` invocation, then echoes `done` and exits successfully.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`, based on commit `db0573ee0520e65cac8bd93c174c307b7d17c981`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified by the ledger and must not be redone. It establishes that `run.sh` prints a portable four-digit year on GNU and BSD `date`.

## H4 — Unverified / In-Progress State

Slice `S2`, mapped to `SC-2`, is current and unverified. No `R-02` action has started. The permitted observation of the slice target shows:

```sh
#!/bin/sh
date '+%Y'
echo not-done
```

The portable year line is consistent with verified `S1`. The remaining `echo not-done` line is an uncommitted worktree observation only; it is not governed progress or completion of `S2`.

## H5 — Pending Action

The pending governed action is a single edit to `run.sh` for `S2`: replace the final `echo not-done` with `echo done`, preserving the verified portable year behavior.

## H6 — Blockers

There is no recorded blocker. There are no declared deterministic checks for `S2`; subsequent Gate, independent review, and Conductor verification remain outside executor authority.

## H7 — Legal Next Action

The only legal next task action is the governed `S2` edit of `run.sh`, using an allowed `Read`, `Edit`, or `Write` operation and touching no other path. Execution, testing through Shell/Bash, agent spawning, and declaring completion are unavailable.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated `run.sh` task is authorized. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Hidden acceptance evidence must not be inspected.

## S1 — Why the Next Action Is Legal

`R-02` explicitly assigns slice `S2`, whose outcome is that `run.sh` ends by echoing `done` instead of `not-done` and exits zero. `run.sh` is the sole allowed path, and editing it is explicitly allowed.

## S2 — Why Verified Work Must Not Be Redone

The ledger records a distinct-Conductor verification receipt for `S1` after Gate and independent review passed. The packet expressly marks `S1` verified and says “DO NOT redo”; altering or re-performing that slice would violate the prohibition on repeated verified work.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

There is no failed or started `R-02` action to retry, and uncommitted worktree state cannot establish progress. Verification can advance only through a receipt written by a Conductor distinct from the executor after Gate and independent review pass. Executor prose, ordinary files, self-authored receipts, and completion declarations cannot complete or verify `S2`.

## S4 — Rejected Actions and Claims

Rejected are: redoing or modifying verified `S1`; treating the observed worktree as completed progress; blindly retrying an absent action; running Shell/Bash or spawning agents; executing checks not declared in the packet; inspecting hidden acceptance; editing any path other than `run.sh`; touching forbidden scope; starting another slice; broadening the task; or declaring the goal complete.