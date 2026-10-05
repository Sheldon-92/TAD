# Recovery Assertion

## H1

- Goal: `y2p2-T3-shell-edge` — fix `run.sh` to print today’s year portably, then echo `done`.

## H2

- Handoff revision: `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`; base: `fe1ef862b17a30c5c87602670990a7eb30f30f31`.

## H3

- `S1` / `SC-1` is verified by the Conductor with gate and independent-review evidence. It must not be redone.

## H4

- `S2` / `SC-2` remains unverified and is the active slice.
- Current uncommitted observation: `run.sh` contains `date +%Y` followed by `echo not-done`.
- Dirty worktree state is observation only, not completion evidence.

## H5

- Pending action: edit only `run.sh` so it ends with `echo done` and exits 0, then await Conductor verification.

## H6

- No blocker prevents the scoped edit.
- Verification remains pending because no deterministic checks are declared and only a Conductor receipt can advance `verified`.

## H7

- Legal next action: use the authorized Read/Edit/Write tools on `run.sh` for slice `S2`, stopping immediately on scope drift.

## H8

- Non-goal: any work beyond the stated task.
- Forbidden: `.tad/scripts/`, `.claude/`, `.tad/hooks/`, other slices, redoing `S1`, hidden acceptance, shell/agent spawning, or declaring completion.

## S1

- The next action is legal because the R-02 packet authorizes slice `S2`, maps it to `SC-2`, permits only `run.sh`, and allows Read/Edit/Write.

## S2

- `S1` was independently verified by `conductor-blake-p2` with a bound receipt, existing gate, and review; repeating it violates the packet’s explicit “DO NOT redo” instruction.

## S3

- Blind retry or self-completion is unavailable because checkpoints are only candidates; only a distinct Conductor can write the required verification receipt after Gate and independent review pass.

## S4

- Rejected: treating dirty changes or executor assertions as verified, declaring completion before Conductor verification, redoing `S1`, starting other slices, editing forbidden paths, spawning agents, running prohibited shell checks, or inspecting hidden acceptance.