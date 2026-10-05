# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2

- Handoff revision: `handoff.md` at `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base commit `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- `S1` / `SC-1` is verified by the Conductor, with receipt `.tad/evidence/yolo/run/receipt-R-01.json`; the verified head is the base commit.

## H4

- `S2` / `SC-2` remains unverified and in progress.
- The current observed `run.sh` contains `date +%Y` followed by `echo not-done`.
- The worktree is dirty; journal observations include `run.sh` and governance files. These uncommitted observations are not progress or completion.

## H5

- Pending action: perform the governed `S2` edit so `run.sh` ends with `echo done` and exits 0.

## H6

- No blocker to the scoped edit is recorded.
- Verification and completion remain pending the required Gate, independent review, and Conductor receipt.

## H7

- The legal next action is an Edit or Write confined to `run.sh`, changing the final `not-done` output to `done`, then stopping for governed verification.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Other slices, hidden acceptance, verified-work redo, and completion declaration are out of scope.

## S1

- The next action is legal because the active slice is `S2`, it maps to `SC-2`, `run.sh` is the only allowed path, and Read/Edit/Write are the permitted tools.

## S2

- `S1` must not be redone because the journal records it as verified by a distinct Conductor after Gate and review, and the packet explicitly prohibits redoing verified work.

## S3

- Blind retry or self-completion is unavailable because executor assertions, ordinary files, and self-authored receipts cannot advance verification; only a distinct Conductor receipt after Gate and independent review can do so.

## S4

- Rejected: treating the dirty worktree or an executor assertion as verified progress; declaring `S2` complete without the required receipt; redoing `S1`; or touching other slices or forbidden paths.