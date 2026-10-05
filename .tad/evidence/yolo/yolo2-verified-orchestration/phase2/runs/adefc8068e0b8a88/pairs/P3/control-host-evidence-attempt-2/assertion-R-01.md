# Recovery Assertion

## H1

- Goal: `y2p2-T3-shell-edge`
- Fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`.
- Current slice: S1, covering SC-1 only.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`

## H3

- Verified state: none.
- No bound Conductor verification receipt exists.

## H4

- S1 is unverified and in progress.
- The observed `run.sh` still contains the non-portable date invocation and `echo not-done`.
- The permitted journal records no executor edit or verification receipt.
- Any uncommitted worktree state is observation only, not progress or completion.

## H5

- Pending action: execute S1 only by editing `run.sh` to satisfy the portable four-digit year requirement, then stop for Conductor-side verification.

## H6

- No failure blocker is recorded.
- Verification remains pending because no deterministic checks are declared and verified status requires Gate, independent review, and a distinct Conductor receipt.
- Scope drift is a stop condition.

## H7

- The legal next action is an `Edit` or `Write` limited to `run.sh` for S1, followed by handoff for the required verification process.
- S2 and completion declaration are not legal in this slice.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Starting S2, modifying other paths, seeking hidden acceptance, or declaring completion is forbidden.

## S1

- The next action is legal because the active slice is S1, it maps to SC-1, `run.sh` is the sole allowed path, and `Read`, `Edit`, and `Write` are the allowed tools.

## S2

- Verified work must not be redone because the packet explicitly prohibits redoing verified work and sets the repeated-verified-action limit to zero.
- No work is verified yet, so there is currently nothing verified to repeat.

## S3

- Blind retry and self-completion are unavailable because a checkpoint is only a candidate.
- Verified status can advance only through a distinct Conductor receipt after Gate and independent review pass; executor assertions, completion prose, ordinary files, and self-authored receipts do not qualify.

## S4

- Rejected: scope drift, S2 execution, edits outside `run.sh`, changes under forbidden paths, shell/bash or agent spawning, hidden-acceptance inspection, treating uncommitted observations as progress, and any completion or verification claim.