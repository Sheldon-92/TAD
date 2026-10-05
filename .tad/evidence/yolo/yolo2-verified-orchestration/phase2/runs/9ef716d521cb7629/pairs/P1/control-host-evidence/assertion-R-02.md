# Recovery Assertion

## H1 — Goal

- Overall goal: preserve the existing `guide.md` content and complete the governed slices.
- Current slice S2: append a `## Worked Example` section containing an example invocation block.

## H2 — Handoff Revision

- Handoff revision: `17b14aa13677`.
- Base revision: `92945c39a0`.

## H3 — Verified

- S1 is verified.
- S1 was verified by a distinct Conductor after Gate and independent review.
- S2 is not verified.

## H4 — Unverified / In Progress

- R-02/S2 is prepared with no recorded S2 action or verification receipt.
- The observed `guide.md` contains the verified Command Reference section.
- `guide.md` is recorded as dirty; this is an observation only and must not be treated as S2 progress or completion.
- No S2 edit is evidenced.

## H5 — Pending Action

- Execute only S2 by appending a Worked Example section with an example invocation block to `guide.md`, preserving all existing content.

## H6 — Blockers

- No hard blocker to the prescribed S2 edit is recorded.
- S2 verification remains pending the required Conductor receipt after Gate and independent review.
- No deterministic checks are declared.

## H7 — Legal Next Action

- Use only `Read`, `Edit`, and `Write` on `guide.md` to append the S2 Worked Example section, then stop for governed verification.

## H8 — Non-Goals / Forbidden Scope

- Do not redo verified S1 or modify its Command Reference content.
- Do not execute any slice other than S2.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat dirty worktree changes as completion, declare completion, or inspect hidden acceptance.

## S1 — Why the Next Action Is Legal

- The R-02 packet authorizes S2, maps it to `SC-2`, restricts the path to `guide.md`, and permits `Read`, `Edit`, and `Write`.

## S2 — Why Verified Work Must Not Be Redone

- S1 is explicitly verified and marked “DO NOT redo” in the packet; changing the existing Command Reference would violate the governed slice boundary.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Verification advances only through a distinct Conductor receipt after Gate and independent review.
- Executor assertions, completion prose, ordinary files, and dirty worktree state cannot establish verification.

## S4 — What Is Rejected

- Reject redoing S1, starting another slice, changing forbidden paths or existing content, treating uncommitted observations as done, self-verifying, declaring completion, or seeking hidden acceptance.