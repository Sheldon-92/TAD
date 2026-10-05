# Recovery Assertion

## H1 — Goal

- Execute slice S1: append `## Command Reference` to `guide.md` with rows for `init`, `status`, and `verify`, including a `purpose` column, without changing the existing introduction.

## H2 — Handoff Revision

- Handoff revision: `17b14aa13677`.
- Base revision: `92945c39a0`.

## H3 — Verified

- Nothing is verified yet.
- Verification requires a distinct Conductor receipt after Gate and independent review pass.

## H4 — Unverified / In Progress

- R-01/S1 is prepared but has no recorded execution action, checkpoint, or verification receipt.
- The observed `guide.md` contains only the existing title and intro; no Command Reference section is present.
- No uncommitted S1 change is evidenced in the allowed records or target content.
- S2 and `SC-2` have not been started.

## H5 — Pending Action

- An authorized executor must perform only the S1 edit in `guide.md`, preserving the existing intro, then hand off for governed verification.

## H6 — Blockers

- No blocker to the prescribed S1 edit is recorded.
- Verification remains pending the required distinct Conductor receipt and independent review.

## H7 — Legal Next Action

- Use only the permitted `Read`, `Edit`, and `Write` operations on `guide.md` to implement S1, then stop for Conductor-side verification.

## H8 — Non-Goals / Forbidden Scope

- Do not execute S2 or any scope beyond the stated task.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat uncommitted changes as progress or completion.
- Do not inspect hidden acceptance, declare completion, or self-author a verification receipt.

## S1 — Why the Next Action Is Legal

- The execution packet defines S1, allows only `guide.md`, permits `Read`, `Edit`, and `Write`, and maps the slice to `SC-1`.

## S2 — Why Verified Work Must Not Be Redone

- The packet forbids redoing verified work. No work is currently verified, and the existing intro must remain untouched.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Executor assertions, completion prose, ordinary files, and self-authored receipts cannot advance verification.
- Verification requires a distinct Conductor after Gate and independent review; therefore blind retry or self-completion is invalid.

## S4 — What Is Rejected

- Reject starting S2, changing forbidden paths, altering existing content, treating uncommitted work as done, declaring completion, self-verifying, or seeking hidden acceptance.