# Recovery Assertion

## H1 — Goal

- Update `usage.md` from `0.9.0` to `1.0.0`; SC-1 is already verified.

## H2 — Handoff Revision

- Handoff: `b7b9a0c63444f7a8e3125f2114e1cf4e4dcad65133c9b86c37ddf087985c0b99`; base: `ba0325db8cb944d712c075a20be62ef4a7416a77`.

## H3 — Verified

- Slice S1 / SC-1 is verified by Conductor `conductor-blake-p2` with receipt `.tad/evidence/yolo/run/receipt-R-01.json`.

## H4 — Unverified / In Progress

- Slice S2 / SC-2 is unverified.
- The permitted target currently reads `usage for 0.9.0`.
- No S2 edit or reconciliation is recorded.
- The journal records `CHANGELOG.md` as dirty, but its S1 result is verified.

## H5 — Pending Action

- Change only `usage.md` so it references `1.0.0` and no longer mentions `0.9.0`, then await Conductor-side verification.

## H6 — Blockers

- This session has no write authority and is instructed not to perform task work.
- Verification cannot be self-completed; it requires the Gate, independent review, and a bound Conductor receipt.

## H7 — Legal Next Action

- Preserve the current state and hand off. On an authorized continuation, perform the single permitted S2 edit to `usage.md`, then stop for governed verification.

## H8 — Non-Goals / Forbidden Scope

- No scope beyond the stated version updates.
- Do not modify `.tad/scripts/`, `.claude/`, `.tad/hooks/`, or any path other than the authorized slice target.

## S1 — Why Next Action Is Legal

- The R-02 contract authorizes slice S2, maps it to SC-2, permits only `usage.md`, and allows Read/Edit/Write.

## S2 — Why Verified Work Must Not Be Redone

- S1 has a valid Conductor receipt with a distinct verifier identity and is explicitly marked verified; the packet prohibits redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Checkpoints are only candidates. Verification advances only after Gate and independent review followed by a bound Conductor receipt; prose, ordinary files, self-authored receipts, and executor assertions do not qualify.

## S4 — What Is Rejected

- Reject re-editing `CHANGELOG.md`, blind retries, completion claims, self-authored verification, hidden-acceptance inspection, shell or agent spawning, and all out-of-scope modifications.