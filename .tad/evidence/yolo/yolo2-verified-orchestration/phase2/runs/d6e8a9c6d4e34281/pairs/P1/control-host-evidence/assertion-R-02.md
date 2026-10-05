# Recovery Assertion

## H1

- Goal: Execute only slice S2 by adding a `Worked Example` section to `guide.md` showing an example invocation block, satisfying SC-2.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c3823b3`; base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- Verified work: S1 is verified by the Conductor with a distinct executor identity and receipt `receipt-R-01.json`. S1 must not be redone.

## H4

- Unverified/in-progress: R-02 is prepared for S2. `guide.md` contains the verified Command Reference section, and the journal records it as dirty at R-02 preparation. No Worked Example section or S2 action is recorded. The dirty state is observation only, not completion evidence.

## H5

- Pending action: Add the Worked Example section with an example invocation block to `guide.md` for S2, then stop for required verification.

## H6

- Blockers: S2 is not verified. Verification requires Gate and independent review to pass, followed by a bound receipt written by a distinct Conductor. No deterministic checks are declared.

## H7

- Legal next action: Use only Read/Edit/Write on `guide.md` to perform S2, preserving existing content and the verified S1 section; stop on scope drift.

## H8

- Non-goals and forbidden scope: Do not redo S1, execute other slices, alter files outside `guide.md`, touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`, treat uncommitted observations as progress or completion, declare completion, or inspect hidden acceptance.

## S1

- The next action is legal because R-02 explicitly authorizes S2, maps it to SC-2, permits only `guide.md`, and allows Read/Edit/Write.

## S2

- Verified work must not be redone because S1 has a Conductor-authored verification receipt and the packet expressly forbids redoing verified work; only the unverified S2 work remains.

## S3

- Blind retry or self-completion is unavailable because verification is Conductor-gated, requires a distinct identity and independent review, and has no declared deterministic checks; executor assertions cannot advance verification.

## S4

- Rejected: re-editing S1, executing S1 or any other slice, changing forbidden paths, treating the dirty guide as completion, self-authoring verification, blind retry, declaring completion, and seeking hidden acceptance.