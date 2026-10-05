# Recovery Assertion

## H1 — Goal

- Create `util.mjs` exporting `stableSlug(s)` with ASCII lowercase conversion, trimming, non-alphanumeric run replacement by `-`, and edge-dash trimming.
- Overall goal also requires `tests.mjs`, but the current slice is only S1.

## H2 — Handoff Revision

- `handoff.md` at `aa4ec6b14d64`; base `36cec5f1c1`.
- Current round: R-01, slice S1.

## H3 — Verified

- None. No verified state or Conductor verification receipt exists.

## H4 — Unverified / In Progress

- `util.mjs` was read and is empty; S1 is unimplemented.
- No uncommitted `util.mjs` work is recorded.
- The journal records pre-existing dirty paths at preparation, but these are observations only and must not be counted as progress or completion.

## H5 — Pending Action

- Implement S1 in `util.mjs` only, then submit the result for the required Gate, independent review, and Conductor verification.

## H6 — Blockers

- No hard external blocker is recorded.
- Advancement is pending because S1 has not been implemented or verified.

## H7 — Legal Next Action

- Edit `util.mjs` to implement the stated `stableSlug` behavior, within the S1 contract and allowed path.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated goal.
- Do not start S2 or modify `tests.mjs` in this slice.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not search for hidden acceptance or treat uncommitted changes as completion.

## S1 — Why Next Action Is Legal

- S1 explicitly maps to SC-1, permits editing `util.mjs`, and authorizes Read/Edit/Write tools.
- The requested implementation directly satisfies the current slice outcome.

## S2 — Why Verified Work Must Not Be Redone

- No work is currently verified, so there is nothing verified to redo.
- If verification is later recorded, redoing that verified work is expressly prohibited.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- No deterministic checks are defined for this slice.
- Executor assertions, completion prose, or a self-authored receipt cannot advance verification.
- Verification requires an existing Gate pass, independent review, and a distinct Conductor receipt.

## S4 — What Is Rejected

- Reject any claim that S1 is verified, complete, or already in progress.
- Reject blind retries, self-completion, executor-authored verification, scope drift, work on other slices, forbidden-path changes, hidden-acceptance inspection, and treating uncommitted observations as done.