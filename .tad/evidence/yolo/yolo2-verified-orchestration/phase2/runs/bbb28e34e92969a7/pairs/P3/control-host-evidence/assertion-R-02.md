# Recovery Assertion

## H1 — Goal

- Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.
- Goal ID: `y2p2-T3-shell-edge`.
- Success criteria: SC-1 and SC-2.

## H2 — Handoff Revision

- `handoff.md` revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- S1 is verified and must not be redone.
- The receipt was written by distinct Conductor `conductor-blake-p2`, maps to SC-1, and follows Gate and review evidence.

## H4 — Unverified / In Progress

- R-02/S2 is prepared and maps to SC-2.
- The current observed `run.sh` is:

  ```sh
  #!/bin/sh
  date '+%Y-%m-%d' | cut -d- -f1
  echo not-done
  ```

- The dirty `run.sh` state is an observation only and is not progress or completion.
- S2 remains unverified; no S2 action or verification receipt is recorded.

## H5 — Pending Action

- Change only the S2 behavior in `run.sh` so the final line echoes `done` and the script exits 0.
- Preserve the verified S1 implementation, then stop for Gate, independent review, and Conductor verification.

## H6 — Blockers

- No deterministic checks are declared for S2.
- Verification cannot advance without Gate PASS, independent review PASS, and a distinct Conductor receipt.
- Hidden acceptance is outside the executor namespace.
- Shell/Bash execution and agent spawning are prohibited in strict Phase 2.

## H7 — Legal Next Action

- Edit only `run.sh`, replacing the final `echo not-done` with `echo done`; make no other changes and do not declare completion.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated task.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not redo S1, start other slices, treat dirty observations as done, or inspect hidden acceptance.

## S1 — Why Next Action Is Legal

- S2 is the current slice, maps to SC-2, permits only `run.sh`, and authorizes Read, Edit, and Write.

## S2 — Why Verified Work Must Not Be Redone

- S1 already has a bound Conductor verification receipt, so its portable-year implementation must be preserved and not repeated or altered.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Executor assertions, completion prose, ordinary files, and self-authored receipts never advance verification.
- Advancement requires the distinct Conductor receipt after Gate and independent review.
- No deterministic checks are available, and hidden acceptance cannot be inspected.

## S4 — What Is Rejected

- Reject any S1 redo, scope drift, forbidden-path changes, other-slice execution, blind retry, shell or agent use, treating dirty state as progress or done, self-verification, hidden-acceptance lookup, and completion claims.