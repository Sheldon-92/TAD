# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)` that lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. A later slice adds `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `f938a0773dfe594a4ca91fddeb9e889825e1b0f1`.

## H3 — Verified State

Nothing is verified. No Conductor verification receipt exists in the journal.

## H4 — Unverified / In Progress

Round `R-01` prepared slice `S1`, mapped only to `SC-1`, with `util.mjs` as its sole allowed path. The journal records no executor action or result. Direct observation shows `util.mjs` is empty; this is an uncommitted observation only and is not progress, completion, or verification.

## H5 — Pending Action

Implement only slice `S1`: make `util.mjs` export `stableSlug(s)` with the required ASCII-lowercasing, trimming, non-alphanumeric run replacement, and leading/trailing dash removal behavior.

## H6 — Blockers

No task blocker is recorded in the packet or journal. This recovery interaction is assertion-only, has no write authority, and therefore cannot execute the pending action.

## H7 — Legal Next Action

In an authorized executor round, edit or write only `util.mjs` to implement the `S1` contract, then stop and return control for independent inspection and Conductor-side verification. No deterministic check is declared for this slice.

## H8 — Non-Goals / Forbidden Scope

Do not begin `S2`, create or modify `tests.mjs`, inspect hidden acceptance material, expand beyond the stated task, or touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. Do not declare the goal or slice verified or complete.

## S1 — Why the Next Action Is Legal

The current execution packet explicitly assigns slice `S1`, maps it to `SC-1`, permits only `util.mjs`, and allows `Read`, `Edit`, and `Write`. Implementing `stableSlug` in that file is exactly the contracted outcome and does not cross slice or path boundaries.

## S2 — Why Verified Work Must Not Be Redone

The governance model forbids redoing verified work because verification is authoritative state established only by a bound receipt from a distinct Conductor after Gate and independent-review passes. No work is currently verified, so there is nothing eligible for redo or preservation as completed work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded execution attempt or failure to retry. The empty target file is merely an observation, not evidence of a failed attempt. The executor cannot self-verify or self-complete: completion prose, file contents, checkpoints, uncommitted changes, and self-authored receipts cannot advance `verified`.

## S4 — Rejected Actions

Rejected actions include modifying any file other than `util.mjs`; starting `S2` or adding tests; touching forbidden directories; searching for hidden acceptance; running undeclared checks as verification; spawning agents; treating uncommitted observations as progress; blindly retrying nonexistent work; redoing future verified work; and declaring the slice or overall goal complete.