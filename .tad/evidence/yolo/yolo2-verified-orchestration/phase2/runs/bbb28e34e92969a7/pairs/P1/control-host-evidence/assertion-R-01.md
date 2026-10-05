# Recovery Assertion

## H1

The goal is to append a `## Command Reference` section to `guide.md` with a markdown table listing `init`, `status`, and `verify`, with `command` and `purpose` columns, without changing existing content. The active slice is S1; S2 is out of scope.

## H2

The handoff is `handoff.md` at revision `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`, based on commit `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3

Nothing is verified. No Conductor verification receipt, Gate PASS, or independent-review PASS is recorded.

## H4

S1 remains unexecuted and unverified. The permitted read of `guide.md` shows only `# Guide` and `Existing intro paragraph.`; no Command Reference section or table is present. The journal records no `guide.md` change among the prepared dirty paths, and any uncommitted worktree state is observation only, not progress or completion.

## H5

The pending action is an authorized S1-only change to `guide.md`, followed by the required Conductor-side verification process. No edit is performed in this assertion.

## H6

This turn is blocked from mutation by the explicit instruction not to do task work. Verification is also blocked pending Gate and independent review followed by a distinct Conductor receipt. No packet-recorded execution failure exists.

## H7

The legal next action in this turn is to stop and hand off the assertion. If execution is later authorized, operate only on `guide.md` for S1, preserve the intro, avoid S2, and then stop for governed verification.

## H8

Non-goals and forbidden scope are all work beyond the stated task, including S2, `.tad/scripts/`, `.claude/`, and `.tad/hooks/`. Hidden acceptance, declaring completion, treating uncommitted changes as done, and self-authored verification are also forbidden.

## S1

The next execution action is legal because the packet identifies S1 as current, permits only `guide.md`, and allowlists Read, Edit, and Write. The current turn’s no-task-work instruction means that authorization is not exercised now.

## S2

Verified work must not be redone because the packet expressly prohibits redoing verified work and sets the repeated-verified-action limit to zero. No verified work currently exists.

## S3

Blind retry and self-completion are unavailable because verification requires a distinct Conductor receipt after Gate and independent review PASS; ordinary completion prose or executor assertions cannot advance verification. The journal contains no failure or verification evidence justifying a retry.

## S4

Rejected are claims that S1, SC-1, or SC-2 is complete; that `guide.md` was changed; that any work is verified; that uncommitted observations constitute progress; or that other slices, forbidden paths, hidden acceptance, or self-authored completion may be pursued.