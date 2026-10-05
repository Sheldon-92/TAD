# Recovery Assertion

## H1

- Goal: Append `## Command Reference` and a command table to `guide.md`, plus the S2 Worked Example section, without changing existing content.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base `92945c39a0f22bea5903c4351f94968437d1ce99`.

## H3

- S1 is verified by the Conductor and maps to SC-1. S2 is not verified.

## H4

- S2 has no recorded action, reconciliation, candidate, or verification event.
- `guide.md` was already dirty when R-02 was prepared. Its current Command Reference content and absence of a Worked Example are observations only, not progress or completion.

## H5

- Pending action: Execute S2 by appending a Worked Example section with an example invocation block to `guide.md`.

## H6

- This recovery turn explicitly forbids task work and writes.
- S2 also cannot be considered verified until the Conductor runs the required Gate and independent review and writes a bound receipt.

## H7

- When write-authorized execution resumes, the legal next action is to modify only `guide.md` for S2 using the permitted Read/Edit/Write tools, then stop for Conductor-side verification.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo verified S1, start other slices, treat dirty changes as completion, self-author a receipt, or inspect hidden acceptance.

## S1

- The next action is legal because R-02 explicitly assigns slice S2, permits only `guide.md`, allows Read/Edit/Write, and defines the Worked Example outcome mapped to SC-2.

## S2

- S1 must not be redone because the ledger records it as verified by a distinct Conductor identity, with a bound receipt mapping it to SC-1. The packet explicitly says verified work is not to be redone.

## S3

- Blind retry and self-completion are unavailable because no S2 attempt is recorded, no deterministic checks are defined, and verification advances only through a distinct Conductor’s Gate, independent review, and bound receipt. Executor assertions or self-authored receipts do not verify work.

## S4

- Rejected: declaring S2 complete or verified from the current file contents; treating uncommitted observations as progress; retrying without a recorded action; modifying forbidden paths; starting another slice; or claiming overall completion.