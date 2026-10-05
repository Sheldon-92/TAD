# Recovery Assertion

## H1

Goal: Execute only slice S1 by appending a `## Command Reference` section to `guide.md` with a `command | purpose` table for `init`, `status`, and `verify`, while preserving the existing intro. SC-2/S2 is out of scope.

## H2

Handoff revision: `handoff.md` at `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

Verified state: none. No bound Conductor verification receipt exists.

## H4

Unverified/in progress:

- `guide.md` currently contains only `# Guide` and `Existing intro paragraph.`; no Command Reference has been added.
- The journal records only initialization and round preparation for R-01/S1.
- Pre-existing dirty paths recorded at preparation were `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these are observations only, not progress or completion.

## H5

Pending action: A later authorized executor may perform the single S1 edit in `guide.md`, preserving existing content, then submit it for the required Gate, independent review, and distinct-Conductor verification.

## H6

No blocker to the S1 edit is recorded. Verification remains gated by the required Gate, independent review, and distinct Conductor receipt; scope drift is a stop condition.

## H7

The legal next action is to edit only `guide.md` using an allowed Edit/Write operation for S1, then stop and hand off for governed verification. No task work is performed in this assertion.

## H8

Non-goals and forbidden scope: do not execute S2 or add the Worked Example; do not modify existing intro content; do not touch paths outside `guide.md`, especially `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not inspect hidden acceptance; do not declare completion.

## S1

The next action is legal because the packet authorizes slice S1, names `guide.md` as the only allowed path, permits Read/Edit/Write, and maps the requested change to SC-1.

## S2

Verified work must not be redone because the governance policy forbids repeated verified actions. No S1 work is verified yet, so the pending edit is not a rework of verified work.

## S3

Blind retry and self-completion are unavailable because the journal records no completed attempt, deterministic checks are absent, and only a distinct Conductor’s receipt after Gate and independent review can advance verification. Executor assertions and self-authored receipts do not count.

## S4

Rejected: treating the current file state, dirty-path observations, a checkpoint, or this assertion as verified; claiming SC-2; retrying blindly; inspecting hidden acceptance; changing forbidden paths; or declaring completion.