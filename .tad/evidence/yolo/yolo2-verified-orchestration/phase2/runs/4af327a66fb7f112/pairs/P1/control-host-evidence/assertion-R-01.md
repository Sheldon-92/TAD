# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command | purpose` and whose rows cover `init`, `status`, and `verify`, without changing the existing content.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at SHA-256 `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `8a89fa40e5e7aac0b845cb49d8a8c0741a886547`.

## H3 — Verified State

No work is verified. The ledger contains no Gate result, independent review, or bound Conductor verification receipt.

## H4 — Unverified / In-Progress State

Round `R-01` has prepared slice `S1`, mapped only to `SC-1`. The observed `guide.md` contains only:

```markdown
# Guide

Existing intro paragraph.
```

The journal recorded `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` as dirty when the round was prepared. Those uncommitted observations are not progress and must not be treated as completed or verified work. No execution attempt or candidate checkpoint is recorded.

## H5 — Pending Action

Execute only slice `S1`: preserve the existing introduction and append the `## Command Reference` table to `guide.md`, with rows for `init`, `status`, and `verify` and a purpose entry for each command.

## H6 — Blockers

The packet supplies no deterministic checks and does not state the three purpose values. No blocker permits guessing those values, expanding scope, or claiming completion. This recovery turn also explicitly withholds write and task-execution authority.

## H7 — Legal Next Action

After recovery, the next governed executor action is to perform slice `S1` against `guide.md` only, using the permitted `Read`, `Edit`, or `Write` capabilities while preserving all existing content. Any required command-purpose information must be obtained through authority consistent with the slice contract before editing; it must not be invented.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. Slice `S2` and its Worked Example are not part of the current slice. Changes under `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Hidden acceptance must not be inspected. Starting another slice, redoing verified work, declaring completion, using shell/Bash, or spawning agents is prohibited.

## S1 — Why the Next Action Is Legal

The ledger prepared `R-01` for current slice `S1`; its outcome maps directly to `SC-1`, its only allowed path is `guide.md`, and its allowlist includes `Read`, `Edit`, and `Write`. Appending the Command Reference table while leaving the introduction untouched is therefore the sole legal execution action.

## S2 — Why Verified Work Must Not Be Redone

The policy expressly forbids redoing verified work, and verification can advance only through a bound receipt written by a Conductor distinct from the executor after both Gate and independent review pass. Although no work is presently verified, any later verified slice must be preserved rather than repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded execution attempt, failure, checkpoint, or verification result to retry. A blind retry would therefore have no governed basis. The executor also cannot self-complete: executor prose, ordinary files, checkpoints, self-authored receipts, and uncommitted changes never advance `verified`; only the required distinct-Conductor verification process can do so.

## S4 — What Is Rejected

Rejected actions include performing `S2`; adding the Worked Example; modifying the existing introduction; changing any path other than `guide.md`; touching forbidden directories; treating dirty or uncommitted files as progress; inventing command purposes; searching for hidden acceptance; using shell/Bash or agents; asserting that `S1`, `SC-1`, or the overall goal is complete; and substituting executor judgment for Gate, independent review, or a bound Conductor receipt.