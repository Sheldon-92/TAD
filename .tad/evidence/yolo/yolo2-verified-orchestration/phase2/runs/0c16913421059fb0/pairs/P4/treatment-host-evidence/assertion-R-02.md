# Recovery Assertion

## H1 — Goal

- Complete `y2p2-T4-cross-file`:
  - `CHANGELOG.md` first line must be `v1.0.0`.
  - `usage.md` must reference `1.0.0` and no longer mention `0.9.0`.

## H2 — Handoff Revision

- Handoff: `b7b9a0c63444f7a8e3125f2114e1cf4e4dcad65133c9b86c37ddf087985c0b99`.
- Base commit: `ba0325db8cb944d712c075a20be62ef4a7416a77`.

## H3 — Verified

- Slice `S1` / `SC-1` is verified by the ledger.
- Verification was written by Conductor `conductor-blake-p2`, distinct from executor `codex:01a0455d-80d7-71c3-9b7e-717c19afd769`.
- `S1` must not be redone.

## H4 — Unverified / In Progress

- Slice `S2` / `SC-2` is unverified and has no recorded R-02 action, reconciliation, closure, or receipt.
- `usage.md` currently contains `usage for 0.9.0`.
- R-02 preparation recorded uncommitted observations for `CHANGELOG.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these observations are not evidence that `S2` is complete.

## H5 — Pending Action

- Perform the bounded `S2` edit: update the version in `usage.md` from `0.9.0` to `1.0.0`.

## H6 — Blockers

- No blocker to the scoped edit is recorded.
- Executor-side verification is unavailable; advancement requires Conductor-side Gate, independent review, and a bound verification receipt.

## H7 — Legal Next Action

- Edit only `usage.md` using an allowed `Edit` or `Write` action, then stop for Conductor-side verification.

## H8 — Non-Goals / Forbidden Scope

- Do not redo `S1` or edit `CHANGELOG.md`.
- Do not start another slice.
- Do not modify anything beyond `usage.md`.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat uncommitted changes, hidden acceptance, or executor assertions as completion evidence.

## S1 — Why the Next Action Is Legal

- R-02 explicitly authorizes slice `S2`, maps it to `SC-2`, allows only `usage.md`, and permits `Read`, `Edit`, and `Write`.
- The requested edit directly satisfies the stated `usage.md` outcome without scope drift.

## S2 — Why Verified Work Must Not Be Redone

- The ledger records `S1` as verified with Conductor-authored receipt, Gate evidence, independent review evidence, and mapping to `SC-1`.
- The execution packet explicitly marks `S1` verified and prohibits redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- R-02 has no recorded failed action requiring retry.
- Verification advances only through a distinct Conductor receipt after Gate and independent review.
- Executor assertions, ordinary file state, and completion prose cannot self-complete the run; Shell/Bash and Agent spawning are also denied in strict Phase 2.

## S4 — What Is Rejected

- Reject the claim that `S2`, `SC-2`, or the overall goal is complete.
- Reject treating R-02 preparation or the current file observation as completed work.
- Reject blind retries, self-authored verification, redoing `S1`, and all out-of-scope edits.