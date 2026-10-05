# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- S1 is verified and maps to SC-1.
- Verification was recorded by a distinct Conductor with Gate and review evidence.

## H4

- S2 and SC-2 are unverified and in progress.
- `run.sh` currently has the verified S1 year line and still contains `echo not-done`.
- The journal records `run.sh` as dirty; this uncommitted observation is not progress or completion.

## H5

- Pending action: change only `echo not-done` to `echo done` in `run.sh`, then hand off for verification.

## H6

- Completion is pending the S2 edit and a distinct Conductor verification receipt.
- No deterministic checks are declared.
- Strict Phase 2 prohibits shell/Bash execution and Agent spawning; hidden acceptance is outside the namespace.

## H7

- The next legal action is an Edit or Write to `run.sh` changing only the final echo for S2.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden: redoing S1, modifying other paths or slices, `.tad/scripts/`, `.claude/`, `.tad/hooks/`, hidden acceptance, and declaring completion without verification.

## S1

- The next action is legal because S2 is the active slice, `run.sh` is its allowed path, Edit and Write are allowed tools, and the change maps to SC-2.

## S2

- S1 must not be redone because it already has a bound Conductor verification receipt; the verified year line will remain untouched.

## S3

- Blind retry and self-completion are unavailable because only a distinct Conductor receipt after Gate and independent review advances verification. Assertions, prose, and self-authored receipts do not suffice.

## S4

- Rejected: any claim that SC-2 or the whole goal is verified, any treatment of the dirty worktree as completion, and any edit beyond the single S2 change in `run.sh`.