# Recovery Assertion

## H1 — Goal

- Fix `run.sh` so it prints today’s four-digit year portably on GNU and BSD `date`, then echoes `done`.

## H2 — Handoff Revision

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- Nothing is verified.
- No Conductor verification receipt exists.

## H4 — Unverified / In Progress

- Slice `S1` is unverified and maps to `SC-1`.
- The observed `run.sh` contains a date fallback and currently ends with `echo not-done`.
- The journal records initialization and round preparation only; no edit, review, gate, or verification receipt is recorded.
- No uncommitted `run.sh` change is recorded in the preparation dirty-path list.

## H5 — Pending Action

- Execute only `S1`: make the permitted `run.sh` edit for portable year output.
- Then stop for Gate, independent review, and Conductor verification.

## H6 — Blockers

- No blocker to the scoped `S1` edit is recorded.
- Executor-side verification is unavailable until the required distinct Conductor receipt exists.

## H7 — Legal Next Action

- Edit only `run.sh`, using the permitted Read/Edit/Write tools, to satisfy `S1`; do not execute another slice or claim completion.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated task.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start `S2`, perform hidden acceptance, spawn agents, or treat uncommitted changes as completion.

## S1 — Why Next Action Is Legal

- The current slice contract explicitly allows only `run.sh`, permits Read/Edit/Write, and maps the action to `SC-1`.

## S2 — Why Verified Work Must Not Be Redone

- The packet explicitly prohibits redoing verified work; verification is ledger-bound and requires a distinct Conductor receipt.
- The current record has no verified work, so no verified action should be repeated or invented.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- There are no deterministic checks in this slice.
- A candidate, ordinary file, completion statement, or executor assertion cannot advance verification.
- Only a distinct Conductor may write the required receipt after Gate and independent review pass.

## S4 — What Is Rejected

- Reject any claim that the task is complete or verified.
- Reject treating the observed file contents or uncommitted observations as progress or done.
- Reject work on `S2`, forbidden paths, hidden acceptance, shell/agent spawning, or any scope outside `S1`.