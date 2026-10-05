# Recovery Assertion

## H1 — Goal

- Append `## Command Reference` to `guide.md` with a `command | purpose` table for `init`, `status`, and `verify`, preserving existing content.
- Current slice: `S1`, mapping to `SC-1`.

## H2 — Handoff Revision

- Handoff revision: `17b14aa13677`.
- Base commit: `03c7066e15`.

## H3 — Verified

- Nothing is verified. No Conductor verification receipt is recorded.

## H4 — Unverified/In-Progress

- `S1` remains unverified and incomplete.
- `guide.md` currently contains only `# Guide` and `Existing intro paragraph.`
- No uncommitted `guide.md` change is evidenced; the journal’s prepared dirty paths exclude `guide.md`.

## H5 — Pending Action

- Perform only the bounded `S1` edit to `guide.md`, then obtain the required Gate, independent review, and Conductor verification receipt.

## H6 — Blockers

- Verification is blocked pending the required Gate, independent review, and distinct Conductor receipt.
- No deterministic checks are listed.
- Hidden acceptance is outside the permitted namespace.

## H7 — Legal Next Action

- After this assertion, use only `Read`, `Edit`, or `Write` on `guide.md` to implement `S1`, preserving the intro and stopping on scope drift.
- This assertion does not perform that task work.

## H8 — Non-Goals/Forbidden Scope

- Do not start slice `S2` or add the Worked Example.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not declare completion or verification.
- Do not treat uncommitted observations as progress or completion.

## S1 — Why Next Action Is Legal

- The packet authorizes only slice `S1`, allows only `guide.md`, and lists `Read`, `Edit`, and `Write` as permitted tools.

## S2 — Why Verified Work Must Not Be Redone

- No work is currently verified, so there is nothing verified to redo.
- If verification is later established by the required Conductor receipt, redoing that work is prohibited.

## S3 — Why Blind Retry/Self-Completion Is Unavailable

- Completion prose, an executor assertion, an ordinary file, or a self-authored receipt cannot advance verification.
- Verification requires a distinct Conductor receipt after both the existing Gate and independent review pass.

## S4 — What Is Rejected

- Reject any claim that `S1`, `SC-1`, or the overall goal is complete or verified.
- Reject blind retries, self-completion, treating pre-existing dirty paths as progress, starting other slices, touching forbidden paths, or inspecting hidden acceptance.