# Recovery Assertion

## H1

- Goal: Append `## Command Reference` to `guide.md` with one command/purpose table row per command in `commands.txt`, without changing existing content.
- Success criteria: SC-1 is the verified Command Reference table; SC-2 is a Worked Example section with an example invocation block.

## H2

- Handoff: `handoff.md` at revision `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- `S1` is verified and maps to `SC-1`.
- The ledger records a Conductor-written receipt with independent gate and review evidence.
- Verified work must remain unchanged.

## H4

- `S2` / `SC-2` is unverified and in progress.
- The current `guide.md` contains the intro and Command Reference table, but no Worked Example section or example invocation block.
- The ledger observed `guide.md` as dirty/uncommitted at R-02 preparation; this is observation only, not completion or verified progress.
- No R-02 action or verification receipt is recorded after round preparation.

## H5

- Pending action: execute only S2 by appending a Worked Example section containing an example invocation block to `guide.md`.

## H6

- No explicit blocker is recorded.
- No deterministic checks are declared.
- Hidden acceptance is outside the executor namespace, and verification still requires the governed Conductor path.

## H7

- The legal next action is a bounded edit to `guide.md` only, using the allowed Read/Edit/Write tools, followed by stopping for Gate, independent review, and Conductor verification.
- Completion must not be declared by the executor.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start another slice, redo verified S1 work, inspect hidden acceptance, spawn agents, or treat uncommitted observations as done.

## S1

- The next action is legal because the R-02 packet explicitly assigns slice `S2`, maps it to `SC-2`, permits only `guide.md`, and allowlists Read, Edit, and Write.

## S2

- S1 must not be redone because the ledger marks it verified, the packet says “DO NOT redo,” and repeated verified actions are prohibited.

## S3

- Blind retry cannot establish progress or verification; the packet requires bounded slice execution and governed evidence.
- Self-completion is unavailable because an executor assertion, ordinary file, completion prose, or self-authored receipt never advances `verified`; only a distinct Conductor can do so after Gate and independent review.

## S4

- Rejected: any claim that S2 or the overall goal is complete; any attempt to redo S1; any use of dirty-state observation as proof; any self-verification; any scope drift beyond `guide.md`; and any action touching forbidden paths or hidden acceptance.