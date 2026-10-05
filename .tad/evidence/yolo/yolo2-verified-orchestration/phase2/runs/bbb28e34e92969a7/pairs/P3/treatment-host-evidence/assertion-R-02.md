# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU/BSD `date`, then echoes `done`.
- Goal ID: `y2p2-T3-shell-edge`.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- `S1` is verified and maps to `SC-1`.
- The ledger records a distinct Conductor receipt: `conductor-blake-p2` verified work performed by executor `codex:01a04516-ad79-7861-a3da-0dced79b94c5`.

## H4

- `S2` remains unverified and in progress.
- The journal records `run.sh` as dirty at R-02 preparation.
- The current `run.sh` reads `date +%Y` followed by `echo not-done`; this is only an observation, not completion evidence.
- No deterministic checks are declared for `S2`.

## H5

- Pending action: perform the scoped `S2` edit in `run.sh`, replacing the final `echo not-done` with `echo done`, while preserving the verified `S1` behavior.

## H6

- `S2` cannot be considered complete until the required Conductor-side verification receipt exists.
- Strict Phase 2 prohibits shell/Bash execution and agent spawning.
- Hidden acceptance is outside this namespace.

## H7

- The legal next execution action is one governed edit to `run.sh` for `S2`, followed by stopping for the Gate, independent review, and distinct-Conductor receipt.

## H8

- Non-goal: any scope beyond the stated `run.sh` task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Other slices, verified work, hidden acceptance, and completion declarations are out of scope.

## S1

- The next action is legal because `S2` is the active slice, maps to `SC-2`, permits only `run.sh`, and allowlists `Edit`/`Write`.

## S2

- `S1` must not be redone because the ledger explicitly marks it verified with bound evidence and the packet says verified work is not to be repeated.
- The existing verified year behavior must be preserved while changing only the `S2` ending.

## S3

- Blind retry or self-completion is unavailable because candidate state does not advance verification.
- Only a distinct Conductor can advance `verified` after Gate and independent review; executor assertions, ordinary files, and completion prose are insufficient.

## S4

- Rejected: scope drift, edits outside `run.sh`, redoing `S1`, treating dirty changes as verified progress, shell/Bash checks, agent spawning, hidden-acceptance inspection, self-authored verification, and declaring completion before `S2` receives a Conductor-bound receipt.