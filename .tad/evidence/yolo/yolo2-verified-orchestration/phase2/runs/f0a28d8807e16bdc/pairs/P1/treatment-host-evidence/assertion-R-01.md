# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command` and `purpose`, containing one row each for `init`, `status`, and `verify`, while preserving all existing content.

## H2 — Handoff Revision

- Handoff revision: `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`
- Base commit: `b83bc8cbad54248c4fca1478b9f92143f296b2df`
- Current round/slice: `R-01` / `S1`

## H3 — Verified

No work is verified. The packet records “none yet,” and the journal contains no independent verification receipt.

## H4 — Unverified / In Progress

No executor actions have been recorded. The observed `guide.md` contains only:

```markdown
# Guide

Existing intro paragraph.
```

Thus the required Command Reference section is not present in the observed slice target. This is an observation only, not verified progress.

At round preparation, the journal recorded these pre-existing dirty paths:

- `contract-S1.json`
- `goal-spec.json`
- `handoff.md`
- `oracle.txt`

Those uncommitted paths are observations only and must not be treated as completed work. No current dirty-state claim beyond the journal record is asserted.

## H5 — Pending Action

Execute only slice `S1`: append the specified Command Reference table to `guide.md`, preserving the existing heading and intro paragraph unchanged.

## H6 — Blockers

There is no recorded execution blocker. Verification and completion remain unavailable until an executor performs the authorized slice and a distinct Conductor records a bound verification receipt after the Gate and independent review both pass.

## H7 — Legal Next Action

The legal next action is a single scoped edit to `guide.md` implementing slice `S1`. No other file or slice may be changed, and completion may not be declared by the executor.

## H8 — Non-Goals / Forbidden Scope

No scope beyond `S1` is authorized. In particular:

- Do not start `S2` or add the Worked Example section.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not modify any path other than `guide.md`.
- Do not inspect hidden acceptance.
- Do not treat a checkpoint, ordinary file, uncommitted change, or executor assertion as verification.
- Do not redo verified work or declare completion.

## S1 — Why the Next Action Is Legal

The current slice contract expressly maps `S1` to `SC-1`, names `guide.md` as the sole allowed path, and defines the required outcome as adding the Command Reference table while leaving the existing intro untouched.

## S2 — Why Verified Work Must Not Be Redone

The packet explicitly prohibits redoing verified work. Verification can advance only through a bound receipt written by a Conductor distinct from the executor after Gate and independent-review passes. No such verified work currently exists, so `S1` remains pending rather than eligible for repetition.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

This is the initial prepared round with zero recorded actions, not a failed attempt carrying evidence that justifies a retry. Blind retry therefore has no basis. Self-completion is unavailable because executor prose or self-authored evidence cannot advance verified state; only the distinct-Conductor process can do so.

## S4 — Rejected

Rejected actions include performing `S2`, adding a Worked Example, changing existing `guide.md` content, editing any non-allowed path, entering forbidden directories, searching for hidden acceptance, treating observed or uncommitted state as done, redoing verified work, or asserting task completion without the required independent verification receipt.