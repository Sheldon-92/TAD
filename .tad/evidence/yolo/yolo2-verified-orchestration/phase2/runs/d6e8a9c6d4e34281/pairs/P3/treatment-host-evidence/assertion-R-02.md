# Recovery Assertion

## H1

- Goal: Fix `run.sh` to print today’s year portably on GNU/BSD `date`, then echo `done`.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- `S1` is verified and maps to `SC-1`, by a Conductor-authored receipt.
- `S2` is not verified.

## H4

- `S2` is prepared but has no recorded action, reconciliation, or verification.
- The observed `run.sh` contains the verified year line followed by `echo not-done`.
- The journal records `run.sh` as dirty; this is an uncommitted observation only and is not completion.

## H5

- Pending action: update only `run.sh` so its final command is `echo done`, preserving the verified year line and successful exit behavior.

## H6

- No S2 edit failure or other blocker is recorded.
- Executor verification is unavailable; deterministic checks are unspecified, and verification requires Conductor processing.

## H7

- The next legal action is the governed S2 edit to `run.sh` using an allowed Edit/Write operation, stopping immediately on scope drift.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Other slices, verified work, hidden acceptance, and completion declaration are outside scope.

## S1

- The next action is legal because round `R-02` explicitly selects slice `S2`, maps it to `SC-2`, permits only `run.sh`, and allows Edit/Write tools.

## S2

- `S1` must not be redone because journal sequence 7 records it as verified by a distinct Conductor, with its verification receipt and effect fingerprint.

## S3

- Blind retry and self-completion are unavailable because checkpoints are only candidates, executor assertions cannot advance verification, and a Conductor receipt requires the existing Gate plus independent review.
- No S2 action has yet been recorded, so there is no failed action to blindly retry.

## S4

- Rejected: redoing `S1`, starting another slice, treating dirty changes as done, modifying forbidden or unallowed paths, using shell/bash or agent spawning, inspecting hidden acceptance, or declaring completion without Conductor verification.