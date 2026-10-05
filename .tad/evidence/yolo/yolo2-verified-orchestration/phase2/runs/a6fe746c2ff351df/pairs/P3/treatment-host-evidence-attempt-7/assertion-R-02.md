# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T3-shell-edge`: fix `run.sh` so it prints today’s year portably, then echoes `done`.
- Current slice: `S2`, covering `SC-2`.

## H2 — Handoff Revision

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- `S1` / `SC-1` is verified by Conductor receipt `receipt-R-01.json`.
- The verification was written by `conductor-blake-p2`, distinct from the executor.
- `S1` must not be redone.

## H4 — Unverified and In Progress

- `S2` / `SC-2` remains unverified.
- The observed `run.sh` contains `echo not-done`.
- `run.sh` is an uncommitted dirty-path observation; it is not evidence of completion.
- No R-02 action, reconciliation, or verification is recorded.

## H5 — Pending Action

- Pending work is the governed `S2` edit to `run.sh`: change the final output from `not-done` to `done`, preserving successful exit status.

## H6 — Blockers

- No external blocker to the authorized `S2` edit is recorded.
- Completion remains blocked from executor assertion until Conductor-side verification requirements are satisfied.

## H7 — Legal Next Action

- Edit only `run.sh` using an allowed `Edit` or `Write` action for `S2`.
- Afterward, stop for the required Conductor Gate, independent review, and bound verification receipt.

## H8 — Non-Goals and Forbidden Scope

- No work beyond the stated task.
- Only `run.sh` is allowed for this slice.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start another slice, redo `S1`, inspect hidden acceptance, or declare completion.

## S1 — Why the Next Action Is Legal

- R-02 explicitly selects `S2`, maps it to `SC-2`, permits `run.sh`, and allows `Read`, `Edit`, and `Write`.
- Changing the final echo directly matches the slice outcome and stays within scope.

## S2 — Why Verified Work Must Not Be Redone

- Journal sequence 7 records `S1` as verified with Conductor receipt, Gate evidence, independent review evidence, and a distinct writer identity.
- The packet explicitly says `S1` is verified and must not be redone; repeated verified action is prohibited.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

- The packet says checkpoints are only candidates.
- Verified status advances only through a Conductor-written bound receipt after Gate and independent review pass.
- No deterministic checks are declared, and executor prose, self-authored receipts, or ordinary file state cannot establish verification.

## S4 — What Is Rejected

- Reject any claim that `S2`, `SC-2`, or the full goal is already verified.
- Reject treating uncommitted observations as progress or completion.
- Reject redoing verified `S1`, blind retries, out-of-scope edits, hidden-acceptance inspection, and self-completion.