# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2 — Handoff Revision

Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`. Base: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

S1 / SC-1 is verified by the conductor. S2 / SC-2 is not verified.

## H4 — Unverified or In Progress

S2 is the current unverified slice. No R-02 action has started. The observed `run.sh` contains the portable year command but currently ends with `echo not-done`. Its uncommitted worktree state is observation only and is not progress or completion evidence.

## H5 — Pending Action

The pending action is the bounded S2 edit: change the final output from `not-done` to `done` while preserving the existing year behavior.

## H6 — Blockers

There is no scope blocker for the edit. Verification remains pending because only a distinct conductor may advance `verified` after the required Gate and independent review.

## H7 — Legal Next Action

Edit or write only `run.sh` for S2, changing `echo not-done` to `echo done`; stop on scope drift. Do not execute other slices, shell/Bash commands, agents, or completion declarations.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated goal is authorized. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. S1 must not be redone, and hidden acceptance must not be inspected.

## S1 — Why the Next Action Is Legal

R-02 explicitly selects slice S2, maps it to SC-2, permits only `run.sh`, and allows `Read`, `Edit`, and `Write`. The proposed edit is exactly the stated S2 outcome.

## S2 — Why Verified Work Must Not Be Redone

The journal records S1 as verified by `conductor-blake-p2`, distinct from the executor, and the packet says `S1 verified (DO NOT redo)`. Therefore the portable year change must be preserved.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

A checkpoint is only a candidate. `verified` advances only through a conductor-written receipt after Gate and independent review pass. An executor assertion, ordinary file, self-authored receipt, blind retry, or completion prose cannot establish verification.

## S4 — What Is Rejected

Reject any claim that S2 is already complete, any redo of S1, any action outside `run.sh`, any forbidden-path change, any shell/Bash or agent execution, hidden-acceptance inspection, or self-authored completion or verification.