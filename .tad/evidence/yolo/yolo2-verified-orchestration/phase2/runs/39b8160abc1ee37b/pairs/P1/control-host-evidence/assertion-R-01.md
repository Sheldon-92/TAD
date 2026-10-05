# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command | purpose` and whose rows cover `init`, `status`, and `verify`, without changing the existing introduction. The governed goal also defines SC-2, but it is outside the current slice.

## H2 — Handoff Revision

The bound handoff is `handoff.md` at SHA-256 `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `b992b9eb431988c37dc72e134d9a271e4c16284c`.

## H3 — Verified State

Nothing is verified. No Gate result, independent review, or Conductor-authored bound verification receipt appears in the ledger.

## H4 — Unverified / In-Progress State

Round R-01 has been prepared for slice S1, mapped only to SC-1. `guide.md` currently contains only:

```markdown
# Guide

Existing intro paragraph.
```

Therefore S1 is neither implemented nor verified. The ledger records `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` as dirty when the round was prepared; these uncommitted paths are observations only and are not progress or completed work. No task work was performed during recovery.

## H5 — Pending Action

Execute only S1: preserve the existing `guide.md` content and append the `## Command Reference` table with `command` and `purpose` columns and rows for `init`, `status`, and `verify`. Stop after the S1 candidate is produced for governed verification.

## H6 — Blockers

This recovery context has no write authority, so it cannot execute the pending edit. No additional ledger-recorded implementation blocker is present. Scope drift remains an explicit stop condition.

## H7 — Legal Next Action

In a separately authorized execution context, edit only `guide.md` to implement the current S1 contract. Do not begin S2 or declare any work verified or complete; verification must proceed through the required Gate, independent review, and distinct-Conductor receipt.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated governed task is authorized. The current round excludes S2’s Worked Example section. Changes outside `guide.md` are unauthorized, and `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are expressly forbidden. Hidden acceptance material must not be inspected.

## S1 — Why the Next Action Is Legal

The prepared R-01 contract explicitly selects S1, maps it to SC-1, authorizes `guide.md` as the sole path, and specifies the exact table outcome. Appending that table while preserving the introduction is therefore the only contract-bound implementation action.

## S2 — Why Verified Work Must Not Be Redone

The packet prohibits redoing verified work, and verification can advance only through a bound receipt written by a Conductor distinct from the executor after both Gate and independent-review PASS results. No work is presently verified, so there is nothing legal to redo; any later verified slice must remain untouched.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The ledger contains only initialization and round preparation, with no recorded attempt, checkpoint, Gate result, independent review, or verification receipt. Uncommitted observations cannot be treated as progress. An executor assertion, ordinary file state, self-authored receipt, or completion prose cannot establish verification, so neither blind retry nor self-completion is available.

## S4 — What Is Rejected

Rejected actions include declaring S1 or the overall goal complete; treating current or uncommitted file state as verified progress; implementing S2’s Worked Example; modifying any path other than `guide.md`; touching forbidden scope; inspecting hidden acceptance; redoing future verified work; or bypassing the distinct-Conductor verification process.