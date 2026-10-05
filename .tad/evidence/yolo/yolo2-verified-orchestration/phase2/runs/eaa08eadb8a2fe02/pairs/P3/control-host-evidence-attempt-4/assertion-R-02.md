# Recovery Assertion

## H1

- Goal `y2p2-T3-shell-edge`: fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`.
- Current scope is round `R-02`, slice `S2`, mapped to `SC-2`.

## H2

- Handoff: `handoff.md` at revision `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- `S1` is verified by the ledger.
- Verification was written by Conductor `conductor-blake-p2`, distinct from the executor, and maps to `SC-1`.

## H4

- `S2` is unverified and in progress.
- `run.sh` currently has the verified portable year line, but still ends with `echo not-done`.
- The ledger records `run.sh` as dirty at S1 verification and at R-02 preparation; this is an uncommitted observation only and is not proof of completion.

## H5

- Pending action: change only the final `echo not-done` in `run.sh` to `echo done`, preserving the verified S1 year line.
- Then stop for the required Gate, independent review, and Conductor verification.

## H6

- No terminal blocker is recorded.
- Verification remains governance-gated and cannot be self-established.
- No deterministic checks are declared for this slice.
- Hidden acceptance is outside the executor namespace.

## H7

- The legal next executor action is an edit limited to `run.sh` for `S2`, using only the allowed `Read`, `Edit`, and `Write` tools, without altering the verified S1 implementation.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Other slices, redoing S1, hidden-acceptance inspection, self-authored verification, and declaring completion are outside scope.

## S1

- The next action is legal because R-02 designates `S2` as the current slice, maps it to `SC-2`, permits only `run.sh`, and allows `Read`, `Edit`, and `Write`.

## S2

- S1 is already verified and must not be redone.
- The S2 edit must preserve the verified portable year line and change only the unfinished final echo.

## S3

- Blind retry and self-completion are unavailable because verified status requires a distinct Conductor receipt after Gate and independent review both pass.
- Executor assertions, completion prose, ordinary files, and self-authored receipts cannot advance verification.
- Shell/Bash execution and agent spawning are denied in strict Phase 2.

## S4

- Reject any change to the verified S1 year implementation.
- Reject treating dirty worktree state as progress or completion.
- Reject edits outside `run.sh`, forbidden-path changes, hidden-acceptance inspection, blind retries, and claims that S2 or the whole goal is verified or complete.