# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.
- Current slice: `S1`, mapped to `SC-1`.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base revision: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- Verified state: none.
- No Conductor verification receipt exists.

## H4

- `S1` remains unverified and in progress.
- The permitted `run.sh` currently hashes to the round-prepared hash and contains the existing non-portable invocation followed by `echo not-done`.
- No uncommitted slice-target edit is recorded; the journal’s prepared dirty paths exclude `run.sh`.

## H5

- Pending action: edit only `run.sh` to satisfy the `S1` portable-year outcome, then stop for governed verification.

## H6

- Verification and completion are blocked until the existing Gate and independent review both pass and a distinct Conductor writes a bound receipt.
- No deterministic checks are declared.
- Scope drift is a stop condition.

## H7

- The next legal action is a bounded `Read`/`Edit`/`Write` operation on `run.sh` for `S1` only, followed by handoff to the Conductor process.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- `S2`, hidden acceptance, shell execution, agent spawning, self-authored receipts, and completion declarations are outside scope or prohibited.

## S1

- The next action is legal because the packet assigns `S1`, permits only `run.sh`, and allows `Read`, `Edit`, and `Write` for the stated `SC-1` outcome.

## S2

- Verified work must not be redone because the packet explicitly prohibits repeating verified work; no verified work currently exists to redo.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared, executor assertions cannot advance verification, and only a distinct Conductor may verify after Gate and independent review pass.

## S4

- Rejected: any claim that the task is complete or verified, treating uncommitted observations as progress, editing `S2`, touching forbidden paths, seeking hidden acceptance, spawning agents, or issuing a blind retry.