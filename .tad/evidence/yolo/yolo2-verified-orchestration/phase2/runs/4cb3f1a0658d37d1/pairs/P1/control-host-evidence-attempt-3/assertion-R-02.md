# Recovery Assertion

## H1

- Goal: Execute current slice S2 by adding a Worked Example section with an example invocation block to `guide.md`.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c3823b3ad`; base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- S1 is verified and maps to SC-1.
- Verification receipt: `.tad/evidence/yolo/run/receipt-R-01.json`, written by `conductor-blake-p2`, distinct from the executor.

## H4

- S2 is unexecuted and unverified; the R-02 journal contains preparation only.
- `guide.md` currently contains the verified Command Reference section for S1 and no Worked Example section.
- `guide.md` is recorded among R-02 prepare-time dirty paths; this is an observation only and is not evidence that S2 is complete.

## H5

- Pending action: Execute S2 by appending the Worked Example section and invocation block to `guide.md`, then await Gate, independent review, and Conductor verification.

## H6

- No blocker to the scoped S2 edit is recorded.
- Verification and completion remain blocked until the required distinct-identity Conductor receipt exists.

## H7

- Legal next action: use only Read/Edit/Write on `guide.md` to append the S2 Worked Example section, preserving the verified S1 content, and stop.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not redo S1, start another slice, inspect hidden acceptance, or declare completion.

## S1

- The next action is legal because R-02 identifies S2 as the current slice, maps it to SC-2, permits only `guide.md`, and allows Read/Edit/Write.

## S2

- S1 is already Conductor-verified, so it must not be redone. The dirty-path observation does not invalidate that receipt or authorize repeating the S1 edit.

## S3

- Blind retry and self-completion are unavailable because verification requires a distinct Conductor receipt after Gate and independent review; ordinary file changes and executor assertions cannot advance `verified`.

## S4

- Reject redoing the Command Reference, treating the existing guide as proof that S2 is complete, self-verifying, claiming completion without the receipt, blind retries, other slices, and forbidden-scope changes.