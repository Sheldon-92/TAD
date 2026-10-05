# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command` and `purpose`, listing `init`, `status`, and `verify`, while leaving the existing introduction unchanged. The active contract is slice `S1`, mapped only to `SC-1`.

## H2 — Handoff Revision

- Handoff: `handoff.md`
- Revision: `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`
- Base commit: `ba7499fc2e25482b67f6fef6fa0361d38bae8096`
- Round: `R-01`

## H3 — Verified

Nothing is verified. No Gate result, independent review, or Conductor-authored bound verification receipt exists in the ledger.

## H4 — Unverified / In Progress

Round `R-01` was prepared for `S1`, but no execution progress is recorded. The observed `guide.md` contains only:

```markdown
# Guide

Existing intro paragraph.
```

It does not yet contain the Command Reference section. At round preparation, `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` were reported dirty. Those uncommitted paths and the current target-file contents are observations only; they are not verified progress or completed work.

## H5 — Pending Action

Execute only slice `S1`: append the Command Reference section and its `command | purpose` table to `guide.md`, include rows for `init`, `status`, and `verify`, and preserve all existing content exactly.

## H6 — Blockers

The present recovery session has no write authority, so it cannot perform the pending edit. No task-execution blocker is recorded in the ledger; execution must occur under a properly authorized executor context.

## H7 — Legal Next Action

The next authorized executor may make one scoped edit to `guide.md` implementing `S1`, using only the packet-authorized `Read`, `Edit`, or `Write` capabilities. It must then stop and leave verification to the Gate, independent reviewer, and distinct Conductor.

## H8 — Non-Goals / Forbidden Scope

Do not execute `S2` or add the Worked Example section during this slice. Do not alter the existing introduction, edit any path other than `guide.md`, inspect hidden acceptance material, declare completion, or treat uncommitted observations as progress. The following paths are expressly forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

## S1 — Why the Next Action Is Legal

The packet identifies `S1` as the current slice, maps it to `SC-1`, permits only `guide.md`, and defines the exact Command Reference outcome. A narrowly scoped edit implementing that outcome is therefore authorized.

## S2 — Why Verified Work Must Not Be Redone

The execution model forbids redoing verified work because verification is ledger-bound and authoritative. Here, the verified set is empty, so there is no verified implementation to repeat; the existing target contents are merely observed state.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

No failed attempt or retry authorization is recorded, so there is nothing to retry blindly. An executor cannot self-verify or declare completion: verified state advances only after the Gate and independent review pass and a distinct Conductor writes a bound verification receipt.

## S4 — Rejected Actions

Rejected actions include performing `S2`, adding a Worked Example, modifying the introduction, editing outside `guide.md`, touching forbidden paths, using shell or spawning agents for Phase-2 execution, searching for hidden acceptance, treating dirty files as completed work, redoing future verified work, self-authoring verification, or declaring the goal complete.