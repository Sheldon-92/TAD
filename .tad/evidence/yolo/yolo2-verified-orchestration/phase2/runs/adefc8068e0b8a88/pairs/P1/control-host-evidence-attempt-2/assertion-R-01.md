# Recovery Assertion

## H1

- Goal: Append `## Command Reference` to `guide.md` with a markdown table containing one row for each command (`init`, `status`, `verify`) and a `purpose` column, without changing existing content.

## H2

- Handoff revision: `17b14aa13677`; base commit: `03c7066e15`.

## H3

- Verified state: none. No Conductor verification receipt exists.

## H4

- `guide.md` currently contains only the existing title and intro paragraph; no Command Reference table is present.
- The journal records initialization and round preparation only.
- No uncommitted target-file work is observed; any uncommitted observation would remain observation only, not progress or completion.

## H5

- Pending action: execute slice `S1` only by appending the required Command Reference table to `guide.md`, preserving the intro.

## H6

- No blocker is recorded for the bounded `S1` edit.
- Verification cannot be claimed until the Gate, independent review, and a bound receipt from a distinct Conductor are complete.

## H7

- Legal next action: use an allowed `Edit` or `Write` operation on `guide.md` only, limited to the `S1` outcome.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden scope: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start slice `S2`, redo verified work, inspect hidden acceptance, or declare completion.

## S1

- The next action is legal because the current slice is `S1`, `guide.md` is its sole allowed path, `Edit` and `Write` are allowed tools, and the action maps directly to `SC-1`.

## S2

- Verified work must not be redone because the packet expressly prohibits redoing verified work. No verified work exists here, and observations must not be treated as a basis for repeated execution.

## S3

- Blind retry and self-completion are unavailable because there are no deterministic checks, hidden acceptance is outside the namespace, and executor prose, ordinary-file edits, self-authored receipts, or executor assertions cannot advance verification. Only a distinct Conductor can do so after the required Gate and independent review.

## S4

- Rejected: treating the current file as complete, treating uncommitted observations as progress or done, claiming verification without a Conductor receipt, retrying blindly, starting `S2`, changing forbidden paths, or expanding scope.