# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done` and exits 0.
- Current slice: S2, mapped to SC-2.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- S1 is verified by `.tad/evidence/yolo/run/receipt-R-01.json`, written by distinct Conductor `conductor-blake-p2`; it maps to SC-1.
- S2 is not verified.

## H4

- R-02/S2 is prepared but has no action, reconciliation, closure, or verification entry yet.
- `run.sh` currently contains `date '+%Y'` followed by `echo not-done`; SC-2 is therefore still pending.
- `run.sh` is an uncommitted observation carried from verified S1, with prepared R-02 SHA-256 `513956e4536df416b9784ae269a5787bde110dd5b898307aa72570898f5973d`; it is not new progress for S2.

## H5

- Pending action: change only the final `echo not-done` in `run.sh` to `echo done`, preserving the POSIX shell and verified S1 year line.

## H6

- No technical blocker is recorded.
- Verification remains pending and must be performed through the governed Conductor process.

## H7

- Legal next action: edit only `run.sh` for S2 using the authorized Read/Edit/Write tools, then stop for Gate, independent review, and Conductor verification.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo S1, alter the verified year implementation, start other slices, inspect hidden acceptance, or declare completion.

## S1

- The next action is legal because R-02 explicitly authorizes S2, permits `run.sh`, allows Read/Edit/Write, and maps the work to SC-2.

## S2

- S1 must not be redone because it already has a bound Conductor verification receipt and the packet explicitly marks it verified.

## S3

- Blind retry and self-completion are unavailable because only a distinct Conductor receipt after Gate and independent review advances `verified`; executor assertions and completion prose do not.

## S4

- Rejected: any change to the verified S1 year line, any edit outside `run.sh`, any self-authored verification or completion claim, any hidden-acceptance lookup, and any shell/Bash or agent-spawning action.