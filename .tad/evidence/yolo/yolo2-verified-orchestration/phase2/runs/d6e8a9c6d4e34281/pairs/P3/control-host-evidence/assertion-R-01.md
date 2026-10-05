# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- Verified state: none.
- No Conductor verification receipt exists.

## H4

- R-01 is prepared for slice S1 only, mapping to SC-1.
- SC-1 and SC-2 remain unverified and incomplete.
- `run.sh` currently contains the non-portable year command and `echo not-done`.
- The journal records no uncommitted `run.sh` change; any worktree changes remain observations only.

## H5

- Pending action: edit only `run.sh` to satisfy S1, then stop for Gate, independent review, and Conductor verification.

## H6

- Completion is blocked pending the scoped edit and required Conductor-side verification.
- No deterministic checks are declared.
- Hidden acceptance is outside the executor namespace.

## H7

- The next legal action is an in-scope Edit or Write of `run.sh` for S1 only, followed by handoff for verification.

## H8

- Non-goal: anything beyond the stated task.
- Forbidden: `.tad/scripts/`, `.claude/`, `.tad/hooks/`, other slices, hidden acceptance, and declaring completion.

## S1

- The next action is legal because S1 is the active slice, `run.sh` is its only allowed path, and Edit/Write are allowed tools.

## S2

- Verified work must not be redone because the packet explicitly prohibits repeating verified work; currently none is verified, so no verified work is being repeated.

## S3

- Blind retry and self-completion are unavailable because verification requires a distinct Conductor receipt after Gate and independent review. Executor assertions, completion prose, and self-authored receipts cannot advance verification.

## S4

- Rejected: any claim that SC-1 or SC-2 is verified, that the goal is complete, that uncommitted observations are progress, or that work may extend beyond S1 and `run.sh`.