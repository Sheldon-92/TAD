# Recovery Assertion

## H1

- Goal: update `CHANGELOG.md` to `v1.0.0` and update `usage.md` from `0.9.0` to `1.0.0`.

## H2

- Handoff revision: `b7b9a0c63444f7a8e3125f2114e1cf4e4dcad65133c9b86c37ddf087985c0b99`.
- Base commit: `ba0325db8cb944d712c075a20be62ef4a7416a77`.

## H3

- `S1` is verified.
- Verification was written by `conductor-blake-p2` with executor `codex:01a04c7b-aff7-73e0-9e76-9e5f4e022055`.

## H4

- `S2` is unverified and in progress.
- `usage.md` currently reads `usage for 0.9.0`.
- The journal records `S1` as verified and `R-02` as prepared for `S2`.
- Uncommitted observations at R-02 preparation include `CHANGELOG.md`, contract files, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these are observations only.

## H5

- Pending action: update the version in `usage.md` to `1.0.0` so it no longer mentions `0.9.0`.

## H6

- This session is read-only and explicitly prohibits writes.
- Verification cannot advance until the Gate, independent review, and distinct Conductor receipt requirements are satisfied.

## H7

- If an authorized writable executor resumes, the legal next action is to edit only `usage.md` for `S2`, then stop for governed verification.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo verified `S1`, edit `CHANGELOG.md`, execute other slices, inspect hidden acceptance, or treat uncommitted observations as completion.

## S1

- The next action is legal because `S2` maps to `SC-2`, allows only `usage.md`, and permits Read/Edit/Write operations on that path.

## S2

- `S1` has a Conductor verification receipt and is explicitly marked verified; its dirty worktree observation is not grounds for repeating it.

## S3

- Blind retry or self-completion is unavailable because verification requires a distinct Conductor receipt after Gate and independent review pass. Executor assertions and self-authored receipts cannot advance verification.

## S4

- Rejected: redoing `S1`, editing any path other than `usage.md`, touching forbidden paths, treating uncommitted changes as progress or done, self-verification, blind retries, and completion claims.