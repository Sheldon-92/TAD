# Recovery Assertion

## H1

- Goal: Append `## Command Reference` to `guide.md` with a `command | purpose` table listing `init`, `status`, and `verify`, without changing existing content.
- Current slice: `S1`, mapping to `SC-1`.

## H2

- Handoff: `handoff.md` at revision `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- Verified state: none.
- The journal contains initialization and round preparation only; no Conductor verification receipt exists.

## H4

- `S1` remains unverified and in progress.
- The permitted observation of `guide.md` shows only the existing `# Guide` heading and intro paragraph; no Command Reference table is present.
- The preparation ledger recorded dirty paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these are observations only and must not count as progress or completion.
- `S2`/`SC-2` is not part of the current slice.

## H5

- Pending action: execute `S1` only by appending the required Command Reference table to `guide.md`, preserving the intro, then stop for governed verification.

## H6

- This recovery agent is explicitly denied write access, so it cannot perform the pending edit.
- No deterministic checks are defined, and no Gate, independent-review, or bound Conductor receipt is recorded.

## H7

- Legal next action: an authorized executor may use the allowlisted `Read`, `Edit`, and `Write` tools on `guide.md` only to complete `S1`, with no completion claim.

## H8

- Non-goals and forbidden scope: no work beyond the stated task; do not execute other slices or `S2`; do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not redo verified work; do not inspect hidden acceptance; do not declare completion.

## S1

- The next action is legal because the packet designates `S1` as the current slice, maps it to `SC-1`, permits only `guide.md`, and allowlists `Read`, `Edit`, and `Write`.

## S2

- Verified work must not be redone because the packet expressly forbids redoing verified work. No verified work exists here, so there is currently nothing verified to repeat; any later verified result must remain untouched.

## S3

- Blind retry and self-completion are unavailable because the packet requires a distinct Conductor to write a bound receipt after Gate and independent review both pass. Executor assertions, ordinary file content, completion prose, or self-authored receipts cannot establish verification.

## S4

- Rejected: executing `S2` or any other slice, changing paths outside `guide.md`, touching forbidden directories, treating dirty observations as progress or completion, self-verifying, declaring completion, or seeking hidden acceptance.