# Recovery Assertion

## H1 — Goal

- Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2 — Handoff Revision

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- No work is verified.
- No Conductor verification receipt exists in the authorized evidence.

## H4 — Unverified / In Progress

- Round `R-01`, slice `S1`, is prepared but unexecuted.
- The journal records initialization and round preparation only.
- The authorized read of `run.sh` shows the current script still echoes `not-done`.
- Commit status is not established by the permitted evidence; any uncommitted changes are observations only.

## H5 — Pending Action

- Complete only slice `S1`, satisfying `SC-1` within `run.sh`.
- Do not begin `S2` or declare overall completion.

## H6 — Blockers

- Verification cannot advance without the existing Gate, an independent review, and a bound receipt written by a distinct Conductor.
- No deterministic checks are declared.
- Shell/Bash execution and Agent spawning are prohibited in strict Phase 2.

## H7 — Legal Next Action

- For a future governed executor, read/edit/write only `run.sh` for `S1`, then stop for the required Gate, independent review, and Conductor verification.

## H8 — Non-Goals / Forbidden Scope

- No scope beyond the stated task.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not execute other slices, redo verified work, inspect hidden acceptance, or self-declare completion.

## S1 — Why Next Action Is Legal

- `S1` is the current slice, maps to `SC-1`, permits only `run.sh`, and allows `Read`, `Edit`, and `Write`.

## S2 — Why Verified Work Must Not Be Redone

- The packet explicitly forbids redoing verified work and repeated verified actions.
- No verified work exists in this run, so no verified action is being repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- No deterministic checks are available.
- Executor assertions, completion prose, ordinary files, and self-authored receipts cannot advance verification.
- Only a distinct Conductor receipt after Gate and independent review can establish verification.

## S4 — What Is Rejected

- Reject work on `S2`, forbidden paths, hidden acceptance, shell/Bash execution, Agent spawning, blind retries, uncommitted-change claims, and self-authored completion or verification.