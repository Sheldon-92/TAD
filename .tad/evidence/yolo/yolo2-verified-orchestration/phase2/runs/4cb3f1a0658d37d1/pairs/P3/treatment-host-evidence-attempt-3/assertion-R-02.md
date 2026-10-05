# Recovery Assertion

## H1

- Goal: fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`.
- Current slice: `S2`, mapped to `SC-2`.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.
- Round: `R-02`.

## H3

- `S1` / `SC-1` is verified.
- Journal sequence 7 records a Conductor-written receipt by `conductor-blake-p2`, distinct from the executor.
- `S1` must not be redone.

## H4

- `S2` / `SC-2` is unverified and remains in progress.
- The journal ends at `round_prepared` for `R-02`; no `S2` action, reconciliation, closure, or verification is recorded.
- The dirty `run.sh` observation currently contains a year-printing pipeline followed by `echo done`; this uncommitted observation is not verification, progress, or completion.
- No deterministic checks are defined.

## H5

- Pending action: handle only `S2` for `run.sh`, then stop for the required Gate, independent review, and Conductor verification receipt.
- No task work is performed in this recovery turn.

## H6

- `S2` lacks a bound Conductor verification receipt.
- Hidden acceptance is outside the permitted namespace.
- The current turn has no write access and is instructed not to perform task work.
- Self-authored assertions cannot advance `verified`.

## H7

- The legal next action is limited to the `S2` contract: use only `Read`, `Edit`, or `Write` on `run.sh`, with scope drift as the stop condition.
- Afterward, verification must be performed by the governed Gate/review/Conductor process.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo verified `S1`, start another slice, treat dirty changes as done, run hidden acceptance, spawn agents, use shell/Bash checks, or declare completion.

## S1

- The next action is legal because the packet names `S2` as the current slice, maps it to `SC-2`, permits only `run.sh`, and allows `Read`, `Edit`, and `Write`.

## S2

- `S1` is already verified by the distinct Conductor identity recorded in journal sequence 7, and the packet explicitly says “DO NOT redo”; repeating it would violate the prohibition on repeated verified work.

## S3

- Blind retry and self-completion are unavailable because verification requires the existing Gate, an independent review, and a bound receipt written by a distinct Conductor.
- Completion prose, an ordinary file state, or a self-authored receipt cannot advance `verified`.

## S4

- Rejected: any claim that `S2` is verified or the goal is complete; any treatment of the dirty `run.sh` observation as progress; any redo of `S1`; any action outside `run.sh`; any touch of forbidden paths; and any blind retry or self-authored completion.