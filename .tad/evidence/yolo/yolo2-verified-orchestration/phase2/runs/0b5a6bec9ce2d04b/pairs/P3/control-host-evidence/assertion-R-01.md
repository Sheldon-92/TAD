# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2

- Handoff revision: `handoff.md` at `7b5d312021c3`; base `a3bc550ca6`.

## H3

- Verified state: None. No valid Conductor verification receipt exists.

## H4

- S1 is in progress and unverified.
- `run.sh` currently prints the year using `date +%Y 2>/dev/null || date -j +%Y`, then echoes `not-done`.
- The journal records initial/prepared state only. No uncommitted `run.sh` change is recorded; any uncommitted changes remain observations only.

## H5

- Pending action: Perform only slice S1 by editing `run.sh` for portable GNU/BSD year output.

## H6

- Blockers: Verification requires a distinct Conductor to run the Gate and independent review, then write a bound receipt. No deterministic checks are declared for this slice.

## H7

- Legal next action: Edit only `run.sh` using an allowed `Edit` or `Write` action, then stop if scope drift occurs.

## H8

- Non-goals and forbidden scope: no work beyond this task; do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not start S2, declare completion, treat uncommitted changes as progress, or inspect hidden acceptance.

## S1

- The next action is legal because the current slice is S1, maps to SC-1, permits only `run.sh`, and allows Read/Edit/Write.

## S2

- Verified work must not be redone because the packet prohibits redoing verified work, while the verified state currently contains none.

## S3

- Blind retry or self-completion is unavailable because there are no declared deterministic checks, hidden acceptance is outside the namespace, and executor assertions or self-authored receipts cannot advance verification.

## S4

- Rejected: scope drift, forbidden-path changes, starting another slice, blind retries, completion claims, treating uncommitted observations as progress, and any self-authored verification.