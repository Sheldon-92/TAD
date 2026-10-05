# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. A later slice adds `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2 — Handoff Revision

The governed handoff revision is `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`, based on commit `cff9f2199051490903597bf287fa4771558375d7`.

## H3 — Verified

No work is verified. The execution packet explicitly records `none yet`, and the journal contains no bound verification receipt.

## H4 — Unverified / In Progress

Round `R-01` prepared slice `S1`, mapped only to `SC-1`. Its sole allowed path is `util.mjs`.

`util.mjs` is currently empty. This is an uncommitted observation only and is not progress, completion, or verification. The journal also records pre-existing dirty paths at round preparation; those observations must not be treated as completed work.

## H5 — Pending Action

Implement only slice `S1`: make `util.mjs` export `stableSlug(s)` with the required ASCII-lowercasing, trimming, non-alphanumeric run collapse, and leading/trailing dash removal behavior.

## H6 — Blockers

No blocker is recorded. There are no deterministic checks declared for this slice.

## H7 — Legal Next Action

The next executor may use only the slice-authorized `Read`, `Edit`, or `Write` operations on `util.mjs` to implement `S1`, then stop for independent Gate and Conductor review. The executor may not declare the slice verified or complete.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. Slice `S2` and `tests.mjs` are not part of the current slice. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Hidden acceptance is outside the executor namespace and must not be inspected.

## S1 — Why the Next Action Is Legal

Implementing `stableSlug` in `util.mjs` exactly matches the current `S1` outcome, maps to `SC-1`, stays within the sole allowed path, and uses only the packet-authorized operations.

## S2 — Why Verified Work Must Not Be Redone

Governance forbids redoing verified work because verified state may advance only through a bound receipt written by a distinct Conductor after Gate and independent-review passes. Although nothing is verified yet, this rule remains controlling for every subsequent recovery.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed attempt or retry authorization is recorded, so a blind retry has no basis. Executor prose, file contents, checkpoints, self-authored receipts, and uncommitted observations cannot establish verification. Only a distinct Conductor can advance verified state after the required reviews pass.

## S4 — What Is Rejected

Rejected actions include working on `tests.mjs` or slice `S2`, modifying any path other than `util.mjs`, entering forbidden scope, using shell/Bash or spawning agents during strict Phase 2, searching for hidden acceptance, treating dirty or uncommitted state as progress, redoing verified work, declaring completion, or self-verifying the implementation.