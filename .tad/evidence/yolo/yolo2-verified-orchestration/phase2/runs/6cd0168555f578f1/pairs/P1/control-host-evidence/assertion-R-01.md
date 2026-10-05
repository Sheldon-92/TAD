# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md`, followed by a Markdown table with columns `command | purpose` and one row each for `init`, `status`, and `verify`. Preserve all existing content unchanged. This is slice `S1`, mapped to `SC-1`.

## H2 — Handoff Revision

- Handoff revision: `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`
- Base commit: `d01c80cc1926cb0a1c8361fc606b63b97cef5a6f`
- Round: `R-01`
- Current slice: `S1`

## H3 — Verified State

No work is verified. The ledger contains no bound verification receipt, Gate PASS, or independent-review PASS.

## H4 — Unverified / In-Progress State

`guide.md` was observed with only:

```markdown
# Guide

Existing intro paragraph.
```

The required Command Reference section is absent. This observation is uncommitted and must not be treated as progress or completion.

At round preparation, the journal recorded uncommitted paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Those are observations only, are outside the slice’s allowed path, and must not be modified or credited as completed work.

## H5 — Pending Action

An authorized executor must append the `## Command Reference` section and the required two-column table to `guide.md`, with rows for `init`, `status`, and `verify`, while leaving the existing heading and intro paragraph untouched. After that single-slice edit, execution must stop for Conductor-side Gate and independent review.

## H6 — Blockers

No execution blocker is recorded in the packet or journal. This recovery turn itself has read-only authority and expressly forbids performing task work, so the pending edit cannot legally be made during this turn.

## H7 — Legal Next Action

Hand off `S1` unchanged to an executor authorized to edit only `guide.md`. The executor may read and edit that file, append the contracted section, and then stop without declaring the goal complete.

## H8 — Non-Goals / Forbidden Scope

The following are outside authority and rejected:

- Any work beyond `S1`.
- Slice `S2`, including adding a Worked Example section.
- Any change outside `guide.md`.
- Any modification under `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Changing or replacing the existing `guide.md` content.
- Inspecting hidden acceptance material.
- Treating an ordinary file change, checkpoint, uncommitted observation, or executor statement as verification.
- Declaring completion without a distinct Conductor’s bound verification receipt following Gate PASS and independent-review PASS.

## S1 — Why the Next Action Is Legal

The execution packet designates `S1` as the current slice, maps it to `SC-1`, allows only `guide.md`, and permits Read, Edit, and Write operations. Appending the specified section to that file while preserving its existing content is therefore the only in-scope implementation action.

## S2 — Why Verified Work Must Not Be Redone

The packet explicitly forbids redoing verified work, and only a bound receipt written by a Conductor distinct from the executor can advance verified state. No such verified work currently exists; if one is later recorded, the executor must accept that ledger state and must not repeat it.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded failed attempt authorizing a retry, and uncommitted observations cannot establish completed or failed progress. Self-completion is unavailable because executor assertions and self-authored receipts never advance verification; completion requires a distinct Conductor after both the Gate and independent review pass.

## S4 — What Is Rejected

Rejected actions include performing the edit during this read-only recovery turn, starting `S2`, modifying any non-allowed path, touching forbidden directories, searching for hidden acceptance, retrying work without ledger authority, crediting observed dirty files as progress, redoing future verified work, or asserting that the task is complete.