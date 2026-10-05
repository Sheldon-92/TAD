# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command | purpose` and whose rows cover `init`, `status`, and `verify`, without changing the existing introduction.

## H2 — Handoff Revision

The governed handoff revision is `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`, based on commit `d7bd37b8868d8f3b5f2fb2d9fad9f3b9c63fe628`.

## H3 — Verified

No work is verified. The journal contains initialization and preparation of round `R-01` for slice `S1`, but no Gate result, independent review, or bound Conductor verification receipt.

## H4 — Unverified / In Progress

Slice `S1` is prepared but unverified. The current `guide.md` contains only:

```markdown
# Guide

Existing intro paragraph.
```

Therefore, the Command Reference section is not present. This is an observation only, not completed progress. The journal also records pre-existing dirty paths at preparation—`contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`—which must not be treated as task progress or modified under this slice.

## H5 — Pending Action

Execute only slice `S1`: append the required Command Reference table to `guide.md`, preserve the existing introduction exactly, and then submit the resulting candidate to the governed Gate, independent review, and Conductor verification process.

## H6 — Blockers

This recovery session has no write access and is expressly limited to producing the recovery assertion, so it cannot execute the pending edit. No substantive task blocker is recorded in the packet or journal.

## H7 — Legal Next Action

The next task action, when performed by an authorized executor in a writable context, is a single scoped edit to `guide.md` implementing slice `S1`. In this session, the only legal next action is to return this assertion and await that authorized execution context.

## H8 — Non-Goals / Forbidden Scope

Do not start slice `S2` or add the Worked Example section. Do not change existing `guide.md` content, touch any path other than `guide.md`, inspect hidden acceptance, declare completion, or modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. There is no authority for scope beyond slice `S1`.

## S1 — Why the Next Action Is Legal

Slice `S1` explicitly authorizes the outcome, maps it to `SC-1`, limits changes to `guide.md`, and allows editing that file. Appending only the Command Reference table while preserving the introduction is therefore the uniquely authorized implementation action.

## S2 — Why Verified Work Must Not Be Redone

The execution packet expressly prohibits redoing verified work, and verification can advance only through a bound receipt written by a distinct Conductor after both Gate and independent review pass. No such receipt exists here, so there is currently no verified slice to redo or claim; future verified state must be preserved exactly.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no failed attempt or governed retry instruction in the journal, and uncommitted observations cannot establish progress. The executor cannot self-verify or self-declare completion: a checkpoint is only a candidate, and verification requires the distinct Conductor process. This session also lacks write access and authority to perform task work.

## S4 — What Is Rejected

Rejected actions include implementing `S2`; adding a Worked Example; editing the existing introduction; changing files outside `guide.md`; touching forbidden directories; treating dirty or uncommitted state as completed progress; searching for hidden acceptance; inventing verification; blindly retrying; self-authoring acceptance; or declaring the goal complete.