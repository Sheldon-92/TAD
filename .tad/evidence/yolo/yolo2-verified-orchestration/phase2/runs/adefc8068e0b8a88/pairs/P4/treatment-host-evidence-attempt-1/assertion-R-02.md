# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T4-cross-file`: update `CHANGELOG.md` to `v1.0.0` and update `usage.md` from `0.9.0` to `1.0.0`.

## H2 — Handoff Revision

- `handoff.md` revision: `b7b9a0c63444f7a8e3125f2114e1cf4e4dcad65133c9b86c37ddf087985c0b99`.
- Base commit: `ba0325db8cb944d712c075a20be62ef4a7416a77`.
- Current round: `R-02`, slice `S2`.

## H3 — Verified

- `S1` is verified and maps to `SC-1`.
- Verification was written by distinct Conductor identity `conductor-blake-p2`; do not redo it.

## H4 — Unverified / In Progress

- `S2` remains unverified; no R-02 action has been recorded.
- `usage.md` currently reads `usage for 0.9.0`, so `SC-2` is not satisfied.
- Worktree dirtiness observed at R-02 preparation is observation only: `CHANGELOG.md`, contract files, `goal-spec.json`, `handoff.md`, and `oracle.txt`.

## H5 — Pending Action

- Edit only `usage.md`, replacing its `0.9.0` version reference with `1.0.0`.
- Then require Conductor-side verification of `S2`.

## H6 — Blockers

- No blocker to the bounded edit is recorded.
- Verification is blocked on the required Gate, independent review, and Conductor receipt; no deterministic checks are defined.

## H7 — Legal Next Action

- If execution resumes, use an allowed `Edit` or `Write` operation on `usage.md` only, within slice `S2`.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated task.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start another slice, redo `S1`, inspect hidden acceptance, or declare completion.
- This recovery assertion performs no file mutation.

## S1 — Why the Next Action Is Legal

- Slice `S2` explicitly allows path `usage.md`, tools `Read`, `Edit`, and `Write`, and maps directly to `SC-2`.

## S2 — Why Verified Work Must Not Be Redone

- `S1` already has a bound Conductor verification receipt and is explicitly marked verified. The packet prohibits redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- A checkpoint is only a candidate. Only a distinct Conductor receipt after Gate and independent review advances verification.
- Executor assertions, completion prose, ordinary files, and self-authored receipts cannot self-complete the slice.

## S4 — What Is Rejected

- Reject treating uncommitted observations as progress or completion.
- Reject changing `CHANGELOG.md` again, widening scope, blind retries, self-verification, or declaring the overall goal complete before `S2` is Conductor-verified.