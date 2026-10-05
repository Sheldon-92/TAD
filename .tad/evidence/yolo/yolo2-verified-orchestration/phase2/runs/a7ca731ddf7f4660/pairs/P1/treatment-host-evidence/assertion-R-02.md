# Recovery Assertion

## H1

- Goal: execute slice S2 only by appending a `## Worked Example` section with an example invocation block to `guide.md`, satisfying SC-2. The overall goal also includes the already-verified Command Reference work.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- S1 is verified and must remain untouched.
- S2 is not verified.
- Verification requires a distinct Conductor to write a bound receipt after Gate and independent review both pass.

## H4

- S2 remains unexecuted and unverified.
- The permitted observation of `guide.md` shows the existing intro and Command Reference section, but no Worked Example section.
- `guide.md` is an uncommitted dirty-path observation associated with the verified S1 work; it is not evidence of S2 progress or completion.

## H5

- Pending action: perform the governed S2 edit by appending the Worked Example section to `guide.md`, then stop for Conductor-side Gate, independent review, and verification.

## H6

- No execution failure is recorded for S2.
- Verification remains pending because no Conductor receipt for S2 exists.
- No deterministic checks are declared.

## H7

- The legal next action is limited to S2, using only Read/Edit/Write on `guide.md`, with no changes to any other path.
- After the edit, hand off for the required Conductor verification; do not declare completion independently.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start another slice, redo verified S1 work, use shell/Bash or agent spawning, inspect hidden acceptance, or treat uncommitted changes or prose assertions as completion.

## S1

- The next action is legal because the packet assigns the current slice as S2, maps it to SC-2, permits `guide.md` as the only path, and permits Read/Edit/Write as the tools.

## S2

- S1 must not be redone because the packet explicitly marks it verified, and its Command Reference result is already present in `guide.md`.
- The dirty worktree state is observation only and does not invalidate the verified slice.

## S3

- Blind retry and self-completion are unavailable because a candidate checkpoint is not verification.
- Only a distinct Conductor’s bound receipt, following Gate and independent review, can advance verification; an ordinary file, self-authored receipt, or executor assertion cannot.

## S4

- Rejected: declaring the run complete, claiming S2 is done from the current file, treating S1’s uncommitted observation as S2 progress, redoing S1, acting outside `guide.md`, or self-authorizing verification.