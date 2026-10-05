# Recovery Assertion

## H1 — Goal

- Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.
- Goal ID: `y2p2-T3-shell-edge`.
- Success criteria: SC-1 and SC-2.

## H2 — Handoff Revision

- `handoff.md` revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- Nothing is verified.
- No Conductor verification receipt exists.

## H4 — Unverified / In Progress

- Round `R-01`, slice `S1`, is prepared and maps only to SC-1.
- The observed `run.sh` content is:

  ```sh
  #!/bin/sh
  date +%Y 2>/dev/null || date -j +%Y
  echo not-done
  ```

- This observation is not verification or completion.
- Pre-existing dirty paths recorded at preparation are `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; `run.sh` was not listed as dirty.
- SC-2 remains unverified and is outside the current S1 slice.

## H5 — Pending Action

- Make the S1-only change to `run.sh` required for SC-1, then stop for Gate, independent review, and Conductor verification.
- Do not execute S2 or declare completion.

## H6 — Blockers

- No deterministic checks are declared for this slice.
- Verification cannot advance without a passing Gate, independent review, and a distinct Conductor receipt.
- Hidden acceptance is outside the executor namespace.
- Shell/Bash execution and agent spawning are prohibited in strict Phase 2.

## H7 — Legal Next Action

- Edit only `run.sh` for S1 using the authorized Read/Edit/Write tools, with no scope drift; then hand off for the required verification process.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated task.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start S2, redo verified work, treat uncommitted observations as progress, or declare completion.

## S1 — Why Next Action Is Legal

- S1 is the current slice, maps to SC-1, permits only `run.sh`, and explicitly allows Read, Edit, and Write.

## S2 — Why Verified Work Must Not Be Redone

- The packet forbids redoing verified work; although none is currently verified, any later Conductor-verified work must not be repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Executor assertions, completion prose, ordinary files, and self-authored receipts never advance verification.
- Advancement requires the distinct Conductor receipt after Gate and independent review.
- No deterministic checks are available, and hidden acceptance cannot be inspected.

## S4 — What Is Rejected

- Reject scope drift, forbidden-path changes, S2 execution, blind retries, shell or agent use, treating dirty observations as progress or done, self-verification, hidden-acceptance lookup, and completion claims.