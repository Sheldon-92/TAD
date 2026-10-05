# Recovery Assertion

## H1

- Goal: Execute slice S1 by appending a Command Reference table to `guide.md` for `init`, `status`, and `verify`, preserving the existing intro.

## H2

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

- Verified state: none. No Conductor verification receipt exists.

## H4

- S1 remains unexecuted and unverified.
- `guide.md` currently contains only `# Guide` and `Existing intro paragraph.`; no Command Reference addition is observed.
- The journal records only initialization and round preparation. Prepare-time dirty paths were `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these are observations only.

## H5

- Pending action: Execute S1 in `guide.md` only, then await Gate, independent review, and a bound Conductor verification receipt.

## H6

- No blocker to the scoped edit is recorded.
- Verification and completion are blocked until the required distinct-identity Conductor receipt exists.

## H7

- Legal next action: use only Read/Edit/Write on `guide.md` to append the S1 Command Reference table, preserve existing content, and stop.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start slice S2, add the Worked Example, redo verified work, inspect hidden acceptance, or declare completion.

## S1

- The next action is legal because the packet identifies S1 as the current slice, maps it to SC-1, allows only `guide.md`, and permits Read/Edit/Write.

## S2

- No verified work exists to redo. Any later Conductor-verified work must not be repeated because the packet expressly prohibits redoing verified work.

## S3

- Blind retry and self-completion are unavailable because `verified` advances only through a distinct-identity Conductor receipt after Gate and independent review; ordinary prose, file changes, self-authored receipts, and executor assertions do not qualify.

## S4

- Reject treating the existing intro as task completion, treating an unverified edit or assertion as verified, claiming completion without the required receipt, executing S2, expanding scope, or touching forbidden paths.