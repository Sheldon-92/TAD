# Recovery Assertion

## H1

- Goal `y2p2-T3-shell-edge`: fix `run.sh` so it prints today’s 4-digit year portably on GNU and BSD `date`, then echoes `done`.
- Current scope is round `R-01`, slice `S1`, mapped to `SC-1`.

## H2

- Handoff: `handoff.md` at revision `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- Verified state: none.
- No Conductor verification receipt is recorded.

## H4

- `S1` is unverified and in progress.
- Observed `run.sh` currently contains a year command followed by `echo not-done`.
- The journal records only initialization and round preparation; no implementation or verification event exists.
- At preparation, recorded dirty paths were `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; `run.sh` was not listed as dirty. This is only a recorded observation, not current verification.

## H5

- Pending action: implement only `S1` in `run.sh`, then stop for the required Gate, independent review, and Conductor verification.
- `S2` remains pending and is not part of this round’s action.

## H6

- No terminal blocker is recorded.
- Verification is governance-gated: the executor cannot establish verified status.
- No deterministic checks are declared for this slice.
- Hidden acceptance is outside the executor namespace.

## H7

- The legal next executor action is an edit limited to `run.sh` that satisfies `S1`, using only the allowed `Read`, `Edit`, and `Write` tools, followed by handoff for verification.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Other slices, hidden acceptance, self-authored verification, and declaring completion are outside scope.

## S1

- The next action is legal because the packet designates `S1` as the current slice, maps it to `SC-1`, allows only `run.sh`, and permits `Read`, `Edit`, and `Write`.

## S2

- No work is currently verified, so there is nothing verified to redo.
- Any later verified work must not be repeated because the packet expressly forbids redoing verified work.

## S3

- Self-completion is unavailable because verified status requires a distinct Conductor to write a bound receipt after Gate and independent review both pass.
- Executor assertions, completion prose, ordinary files, and self-authored receipts cannot advance verification.
- Shell/Bash execution and agent spawning are denied in strict Phase 2.

## S4

- Reject claims that `run.sh` is fixed, verified, or complete.
- Reject changes for `S2` during this `S1` slice.
- Reject edits to forbidden paths, hidden-acceptance inspection, blind retries, and any unsupported completion assertion.