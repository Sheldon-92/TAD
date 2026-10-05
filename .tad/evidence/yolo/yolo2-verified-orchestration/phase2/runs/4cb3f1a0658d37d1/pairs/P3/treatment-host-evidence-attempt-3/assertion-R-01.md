# Recovery Assertion

## H1 — Goal

- Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2 — Handoff Revision

- Handoff: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- Nothing is verified. No Conductor verification receipt exists.

## H4 — Unverified / In Progress

- Slice `S1` remains unverified and maps to `SC-1`.
- Observed `run.sh` currently contains:
  - `date +%Y 2>/dev/null || date -j +%Y`
  - `echo not-done`
- The journal records no edit or verification event for `run.sh`.
- Pre-existing dirty paths at round preparation were `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these observations are not progress or completion.

## H5 — Pending Action

- Perform only `S1` by editing `run.sh` to satisfy the portable year-line criterion, then stop for the required governance verification.

## H6 — Blockers

- No deterministic checks are declared.
- Verification is blocked until the existing Gate and independent review pass and a distinct Conductor writes a bound verification receipt.

## H7 — Legal Next Action

- If work resumes, use only Read/Edit/Write on `run.sh` for `S1`; do not execute other slices or claim completion.

## H8 — Non-Goals / Forbidden Scope

- No scope beyond the stated task.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start `S2`, inspect hidden acceptance, spawn agents, or treat uncommitted changes as done.

## S1 — Why Next Action Is Legal

- `S1` is the active slice, maps to `SC-1`, permits only `run.sh`, and explicitly allows Read, Edit, and Write.

## S2 — Why Verified Work Must Not Be Redone

- No work is verified, but the packet’s prohibition remains binding: only a distinct Conductor receipt can establish verification, and verified work must not be repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- The packet declares no deterministic checks, denies shell and agent execution in strict Phase 2, and rejects executor assertions, ordinary files, completion prose, and self-authored receipts as verification.

## S4 — What Is Rejected

- Reject completion claims, blind retries, self-verification, scope drift, work on `S2`, forbidden-path changes, hidden-acceptance inspection, and treating uncommitted observations as progress or done.