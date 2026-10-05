# Recovery Assertion

## H1 — Goal
Append `## Command Reference` to `guide.md` with a Markdown table whose columns are `command` and `purpose`, containing rows for `init`, `status`, and `verify`, without changing the existing introduction. The overall goal also includes SC-2, but it is outside the current slice.

## H2 — Handoff Revision
The governed handoff revision is `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `2b60f23cbb126a682516aecb2db83e39a459d926`.

## H3 — Verified
No work is verified. The packet explicitly records “none yet,” and the journal contains no bound verification receipt.

## H4 — Unverified / In Progress
Current slice S1 maps only to SC-1. The observed `guide.md` contains only:

```markdown
# Guide

Existing intro paragraph.
```

It has no Command Reference section. At round preparation, `guide.md` was not listed among the dirty paths; the listed dirty paths were `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These are observations only and do not constitute progress or verification.

## H5 — Pending Action
S1 remains pending: append the Command Reference table to `guide.md`, preserving all existing content. No deterministic checks are declared for this slice.

## H6 — Blockers
The packet identifies no recorded execution failure or rejection. However, it does not supply the purpose text for the three commands, and the present recovery authority forbids reading `commands.txt`; therefore the purposes cannot be safely reconstructed during this recovery assertion.

## H7 — Legal Next Action
The next legal task action, under a subsequent authorized execution step with sufficient command-purpose evidence, is to execute S1 only by modifying `guide.md` to append the required Command Reference table. The current legal action is limited to reporting this recovery assertion; no task edit, verification claim, or completion declaration is authorized here.

## H8 — Non-Goals / Forbidden Scope
Do not begin S2 or add the Worked Example section during S1. Do not change the existing introduction, modify any path other than `guide.md`, inspect hidden acceptance, or touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. No scope beyond the stated task is permitted.

## S1 — Why the Next Action Is Legal
S1 is the prepared current slice, maps to SC-1, and names `guide.md` as its sole allowed path. Appending only the required table is therefore the uniquely authorized task action once adequate execution authority and purpose evidence are available.

## S2 — Why Verified Work Must Not Be Redone
The governance model forbids redoing verified work because verification advances only through a bound receipt written by a distinct Conductor after Gate and independent-review passes. There is currently no verified work to repeat, so execution must address only the still-pending S1 once.

## S3 — Why Blind Retry / Self-Completion Is Unavailable
There is no recorded failed attempt to retry, and the missing purpose text cannot be guessed safely. The executor also cannot self-verify or declare completion: checkpoints, prose, ordinary files, self-authored receipts, and executor assertions do not advance verified state.

## S4 — What Is Rejected
Rejected actions include guessing command purposes, treating observed or uncommitted changes as completed work, starting S2, adding a Worked Example, altering existing content, modifying paths outside `guide.md`, touching forbidden directories, seeking hidden acceptance, redoing verified work, self-authoring verification, or declaring the goal complete.