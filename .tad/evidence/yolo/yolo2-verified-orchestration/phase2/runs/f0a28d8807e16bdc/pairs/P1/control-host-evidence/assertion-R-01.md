# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md`, followed by a Markdown table with columns `command | purpose` and one row each for `init`, `status`, and `verify`, while preserving all existing content unchanged.

## H2 — Handoff Revision

The governed handoff revision is `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `95b42348391fe86b934f1128ade524013293b0b4`.

## H3 — Verified State

No work is verified. The execution packet explicitly records `none yet`, and the journal contains no independent Conductor verification receipt.

## H4 — Unverified / In-Progress State

No candidate or in-progress implementation is recorded. The current `guide.md` observation contains only its existing heading and intro paragraph; it does not contain the requested section or table. This observation is not progress or verification.

At round preparation, the journal recorded unrelated uncommitted paths: `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Those changes are observations only and must not be treated as completed work. `guide.md` was not listed as dirty at preparation.

## H5 — Pending Action

Slice `S1` remains pending in full: append the Command Reference section and its three-row command/purpose table to `guide.md`, preserving the existing introduction exactly.

## H6 — Blockers

The ledger reports no task-state blocker. This recovery turn cannot perform the pending edit because it is explicitly read-only and task execution is forbidden by the governing request.

## H7 — Legal Next Action

After this recovery assertion, the legal governed action is for an authorized writable executor to execute only slice `S1` by editing only `guide.md` within the packet contract. The resulting candidate must subsequently pass the Gate, independent review, and a bound verification receipt written by a distinct Conductor before `verified` may advance.

## H8 — Non-Goals / Forbidden Scope

There is no authority beyond slice `S1`. Do not execute slice `S2`, add a Worked Example, change existing `guide.md` content, modify any path other than `guide.md`, inspect hidden acceptance material, or touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. Do not declare completion without independent verification.

## S1 — Why the Next Action Is Legal

The packet expressly assigns current slice `S1`, maps it to `SC-1`, permits `guide.md` as the sole allowed path, and defines the exact required outcome: a Command Reference table listing `init`, `status`, and `verify` with purposes while leaving the existing intro untouched.

## S2 — Why Verified Work Must Not Be Redone

Governance forbids redoing verified work because verification is ledger-controlled and represents independently accepted state. Here, nothing is verified, so there is no verified implementation to repeat; the still-pending `S1` must be executed once under its current contract.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded failed attempt or retry authorization to replay blindly. Uncommitted observations cannot establish progress, and an executor cannot verify its own work or declare completion. Verification requires a later Gate pass, independent review, and a bound receipt from a Conductor whose identity differs from the executor.

## S4 — What Is Rejected

Rejected actions include performing task work during this read-only recovery turn; treating current or uncommitted file state as verified; blindly retrying an unrecorded attempt; self-verifying or declaring completion; executing `S2`; adding a Worked Example; reading hidden acceptance material; changing existing introductory content; modifying files outside `guide.md`; and entering any forbidden scope.