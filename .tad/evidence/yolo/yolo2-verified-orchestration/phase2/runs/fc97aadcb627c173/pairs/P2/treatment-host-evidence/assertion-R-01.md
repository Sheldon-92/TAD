# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. A later slice adds `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2 — Handoff Revision

The governed handoff revision is `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`, based on commit `86841633d649c886b882b09194c71b90e17ba55d`.

## H3 — Verified State

Nothing is verified. No Conductor-authored verification receipt exists for either success criterion.

## H4 — Unverified / In-Progress State

Round `R-01` is prepared for slice `S1`, mapping only to `SC-1`. No execution action or checkpoint is recorded. The permitted slice target, `util.mjs`, is currently empty; this observation is not progress or completion.

At round preparation, the journal recorded uncommitted paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Those observations are outside the slice’s allowed path and confer no authority to alter or treat them as completed work.

## H5 — Pending Action

Implement the `S1` contract in `util.mjs` only. Do not begin `S2`, add tests, or declare the overall goal complete.

## H6 — Blockers

No blocker is recorded. The current slice has an explicit outcome, one allowed path, and permitted `Read`, `Edit`, and `Write` operations.

## H7 — Legal Next Action

The legal next action is to write or edit only `util.mjs` so that it exports `stableSlug(s)` with the required lowercase, trim, non-alphanumeric run collapse, and leading/trailing dash removal behavior. Execution must stop if scope drift would occur.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated goal is authorized. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Starting slice `S2`, modifying `tests.mjs`, inspecting hidden acceptance, spawning agents, using shell execution for task work, redoing verified work, or declaring completion is outside the current slice authority.

## S1 — Why the Next Action Is Legal

The round packet designates `S1` as the current slice, maps it to `SC-1`, names `util.mjs` as its sole allowed path, and permits `Read`, `Edit`, and `Write`. Implementing the specified export in that file is therefore the only contract-aligned next action.

## S2 — Why Verified Work Must Not Be Redone

The governance model forbids redoing verified work because verification is ledger-bound and may advance only through a distinct Conductor after Gate and independent-review passes. No work is verified here, so there is presently nothing eligible to redo or preserve as a completed slice.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

Blind retry is unavailable because the journal records no prior execution attempt, failure, or checkpoint to retry. Self-completion is unavailable because executor prose, file contents, checkpoints, and self-authored receipts cannot advance verification; only a distinct Conductor can record a valid verification receipt after the required passes.

## S4 — Rejected Actions

Rejected are any proposal to treat the empty or uncommitted worktree state as progress, begin or complete `S2`, modify any path other than `util.mjs`, inspect hidden acceptance, enter forbidden directories, retry nonexistent prior work, self-verify, or declare either the slice or overall goal complete.