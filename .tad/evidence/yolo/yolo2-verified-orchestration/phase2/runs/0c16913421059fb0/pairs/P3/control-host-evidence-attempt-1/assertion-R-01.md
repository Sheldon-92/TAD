# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T3-shell-edge`: fix `run.sh` to print today’s year portably on GNU/BSD `date`, then echo `done`.

## H2 — Handoff Revision

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- Nothing is verified.
- No bound Conductor verification receipt exists.

## H4 — Unverified/In-Progress Observations

- Current slice is `S1`, mapped to `SC-1`, and remains unverified/in progress.
- Observed `run.sh` prints `date +%Y 2>/dev/null || date -j +%Y` and then `echo not-done`.
- The journal’s preparation record lists pre-existing dirty paths, but no recorded change to `run.sh`; any uncommitted state is observation only.

## H5 — Pending Action

- Edit only `run.sh` to satisfy `S1`; do not begin `S2` or declare completion.

## H6 — Blockers

- No blocker to the bounded `S1` edit is recorded.
- Verification cannot be claimed until the required Gate, independent review, and distinct Conductor receipt occur.

## H7 — Legal Next Action

- Use the authorized Edit/Write operation on `run.sh` only, implement the portable year output for `S1`, then stop.

## H8 — Non-Goals/Forbidden Scope

- No scope beyond the stated task.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not execute other slices, redo verified work, run shell checks, spawn agents, inspect hidden acceptance, or declare completion.

## S1 — Why Next Action Is Legal

- `S1` is the active slice, `run.sh` is its only allowed path, and Edit/Write are authorized tools; the action maps directly to `SC-1`.

## S2 — Why Verified Work Must Not Be Redone

- No work is currently verified, so there is nothing to redo. Future verified work must not be repeated because verification is receipt-bound and repeated verified action is prohibited.

## S3 — Why Blind Retry/Self-Completion Is Unavailable

- The slice declares no deterministic checks, and verification requires a distinct Conductor after Gate and independent review.
- Executor prose or a self-authored receipt cannot advance verification; shell execution and agent spawning are prohibited in strict Phase 2.

## S4 — What Is Rejected

- Reject any verified or completed claim, any start of `S2`, any forbidden-scope modification, any shell/agent-based retry, any hidden-acceptance inspection, and any treatment of uncommitted observations as progress or completion.