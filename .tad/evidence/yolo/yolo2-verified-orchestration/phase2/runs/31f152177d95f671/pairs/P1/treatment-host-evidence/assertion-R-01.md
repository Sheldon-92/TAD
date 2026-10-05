# Recovery Assertion

## H1

- Goal: append `## Command Reference` to `guide.md` with a `command | purpose` table for `init`, `status`, and `verify`, without changing existing content.
- Current authorized slice: `S1`, mapping to `SC-1`.

## H2

- Handoff revision: `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`.
- Base: `c9c45a9d01a298e2d239f0b9740682ca1ae2b5dd`.

## H3

- Verified state: none.
- No valid Conductor verification receipt exists.

## H4

- `guide.md` still contains only its title and existing intro paragraph.
- No Command Reference table or Worked Example is present.
- The journal records zero actions.
- Pre-existing dirty paths at preparation were `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; they are observations only and are not task progress.

## H5

- Pending action: perform only `S1` by adding the Command Reference table to `guide.md` while preserving the intro.
- `S2` remains pending and is outside the current slice.

## H6

- No execution blocker for the permitted `S1` edit is recorded.
- Verification cannot advance until the existing Gate and an independent review both pass and a distinct Conductor writes a bound receipt.
- No deterministic checks are defined.

## H7

- The next legal action is limited to reading/editing/writing `guide.md` for `S1` only.
- No shell, agent spawning, forbidden-path access, verification claim, or completion declaration is legal.

## H8

- Non-goals: any scope beyond the stated task.
- Forbidden: `.tad/scripts/`, `.claude/`, `.tad/hooks/`, starting `S2`, redoing verified work, treating uncommitted changes as completion, and inspecting hidden acceptance.

## S1

- The next action is legal because the packet identifies `S1` as the current slice, permits only `guide.md`, and allows `Read`, `Edit`, and `Write`.

## S2

- Verified work must not be redone because the packet expressly prohibits repeating verified work; currently, no work is verified.

## S3

- Blind retry or self-completion is unavailable because only a distinct Conductor receipt after Gate and independent-review passes can advance verification. Executor assertions and self-authored receipts are invalid.

## S4

- Rejected: claims that the task is complete or verified, claims that the existing file satisfies `SC-1` or `SC-2`, treating setup dirt as progress, executing `S2`, or expanding beyond the permitted `S1` scope.