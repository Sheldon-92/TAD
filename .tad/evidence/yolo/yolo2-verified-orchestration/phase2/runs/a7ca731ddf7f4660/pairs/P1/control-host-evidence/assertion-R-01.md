# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T1-doc-ref`: append `## Command Reference` to `guide.md` with a `command | purpose` table for `init`, `status`, and `verify`, preserving existing content.

## H2 — Handoff Revision

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3 — Verified

- Nothing is verified.
- No Conductor verification receipt, Gate PASS, or independent-review PASS is recorded.

## H4 — Unverified / In Progress

- S1 is uncompleted and unverified.
- The permitted target observation shows only `# Guide` and `Existing intro paragraph.`; no Command Reference section is present.
- No uncommitted `guide.md` change is recorded in the journal.

## H5 — Pending Action

- Execute S1 only by appending the specified Command Reference table to `guide.md` while leaving the existing intro untouched.

## H6 — Blockers

- No blocker to the authorized S1 edit is recorded.
- Verified status remains unavailable until the required distinct Conductor receipt follows the Gate and independent review.

## H7 — Legal Next Action

- Read and edit or write only `guide.md`, using the packet-authorized tools, to perform S1; stop immediately on scope drift.

## H8 — Non-Goals / Forbidden Scope

- Do not execute S2 or any other slice.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat uncommitted observations as progress or completion.
- Do not declare completion or verification, inspect hidden acceptance, use shell/agent spawning, or expand scope.

## S1 — Why the Next Action Is Legal

- S1 is the current slice, `guide.md` is its only allowed path, and Read/Edit/Write are the only authorized tools.

## S2 — Why Verified Work Must Not Be Redone

- No work is verified in this round, and the policy expressly prohibits redoing any work that later receives verified status.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Verification requires a distinct Conductor identity, an existing Gate PASS, an independent-review PASS, and a bound receipt; executor assertions or self-authored receipts cannot establish verification.

## S4 — What Is Rejected

- Reject starting other slices, changing forbidden paths, blind retries, self-completion claims, treating observations as completion, and any action outside the S1 contract.