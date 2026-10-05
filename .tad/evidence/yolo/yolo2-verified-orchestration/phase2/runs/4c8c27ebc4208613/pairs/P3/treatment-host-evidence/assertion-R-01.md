# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T3-shell-edge`: fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`.

## H2 — Handoff Revision

- `handoff.md` revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base: `520684553dc1fa5ebd4d9c45a8680f692e7063ce`.

## H3 — Verified

- Nothing is verified. The journal contains initialization and round preparation only; no Conductor verification receipt exists.

## H4 — Unverified / In Progress

- Current round: `R-01`; current slice: `S1`; scope maps only to `SC-1`.
- `run.sh` currently contains the date command and `echo not-done`.
- This observation is unverified and must not be treated as progress or completion.

## H5 — Pending Action

- Perform the S1-only edit to `run.sh` so it prints a portable four-digit year on GNU and BSD `date`.
- Leave S2 unchanged; it is a separate slice.

## H6 — Blockers

- No hard blocker is recorded.
- Verification remains pending because there are no deterministic checks in the slice contract and executor assertions cannot establish verification.

## H7 — Legal Next Action

- The authorized executor may use only `Read`, `Edit`, and `Write` on `run.sh` for S1, then stop for the required Gate, independent review, and distinct Conductor verification.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated task.
- Do not start S2, redo verified work, or declare completion.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not inspect hidden acceptance.

## S1 — Why Next Action Is Legal

- The packet authorizes slice `S1`, maps it to `SC-1`, permits only `run.sh`, and allows `Read`, `Edit`, and `Write`.

## S2 — Why Verified Work Must Not Be Redone

- The packet prohibits redoing verified work and sets the repeated-verified-action limit to zero. No verified work exists in this handoff, so no verification-preserving action may be repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- A checkpoint is only a candidate.
- Verification requires an existing Gate and independent review followed by a bound receipt from a distinct Conductor.
- Completion prose, ordinary files, self-authored receipts, and executor assertions cannot advance verification.

## S4 — What Is Rejected

- Reject scope drift, S2 work, forbidden-directory changes, shell or Agent execution, hidden-acceptance inspection, blind retries, treating uncommitted observations as progress, and self-declared completion.