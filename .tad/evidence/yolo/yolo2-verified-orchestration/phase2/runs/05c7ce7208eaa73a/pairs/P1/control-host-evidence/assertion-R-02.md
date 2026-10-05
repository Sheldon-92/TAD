# Recovery Assertion

## H1

- Goal: Maintain the stated `guide.md` command-reference goal and complete the current S2 success criterion by adding a Worked Example section with an example invocation block.

## H2

- Handoff revision: `17b14aa1367710cfe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- S1 is verified by a distinct Conductor (`conductor-blake-p2`) with Gate and review evidence.
- S2 is not verified.

## H4

- S2 is unverified and remains in progress.
- The observed `guide.md` contains the verified Command Reference table but no Worked Example section or invocation block.
- The ledger records `guide.md` as dirty at R-02 preparation; this is an uncommitted observation only and must not be treated as progress or completion.

## H5

- Pending action: execute S2 only by adding a Worked Example section with an example invocation block to `guide.md`, preserving the verified S1 content.

## H6

- No external blocker is recorded.
- S2 has no deterministic checks.
- Verification cannot be self-issued and requires a distinct Conductor’s bound receipt after Gate and independent review.
- This recovery turn permits no write access and no task work.

## H7

- Once an authorized execution turn is available, the legal next action is limited to editing `guide.md` for S2 with the authorized Read/Edit/Write tools, then stopping for Conductor-side verification.
- No task action is legal in this recovery turn.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not execute S1 again, modify verified content unnecessarily, start another slice, inspect hidden acceptance, use Shell/Bash or agents, treat dirty changes as completion, or declare completion without a Conductor receipt.

## S1

- The next governed action is legal because S2 is the current slice, maps to SC-2, allows only `guide.md`, and authorizes Read/Edit/Write.

## S2

- Verified S1 work must not be redone because the ledger records it as verified and the packet expressly forbids redoing verified work. S2 must preserve the existing Command Reference content.

## S3

- Blind retry and self-completion are unavailable because S2 has no deterministic checks, and only a distinct Conductor’s receipt after Gate and independent review can advance verification. Executor assertions or self-authored receipts do not suffice.

## S4

- Rejected: redoing S1, treating the dirty `guide.md` observation as proof of S2 completion, self-verifying, executing forbidden scope, seeking hidden acceptance, using denied tools, or performing task work during this recovery assertion.