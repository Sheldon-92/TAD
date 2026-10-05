# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting named function `stableSlug(s)` with the required ASCII lowercase, trim, dash-collapse, and boundary-dash behavior. Add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `f938a0773dfe594a4ca91fddeb9e889825e1b0f1`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified by the distinct Conductor receipt recorded at journal sequence 7. It must not be redone or modified.

## H4 — Unverified / In Progress

Round `R-02` has prepared slice `S2`, mapped only to `SC-2`, with `tests.mjs` as its sole allowed path. No `R-02` executor action or result is recorded. Direct observation shows `tests.mjs` is empty; this uncommitted state is observation only and is not progress, completion, failure, or verification.

## H5 — Pending Action

Implement only slice `S2`: populate `tests.mjs` with `node:assert` assertions covering at least three `stableSlug` cases, including the empty string, so the file is intended to pass under Node.

## H6 — Blockers

No task blocker is recorded in the packet or journal. This recovery interaction is assertion-only and has no write authority, so it cannot execute the pending action.

## H7 — Legal Next Action

In an authorized executor round, edit or write only `tests.mjs` to add the required assertions, then stop and return control for Conductor-side checking and independent verification. No deterministic check is declared for this slice.

## H8 — Non-Goals / Forbidden Scope

Do not modify `util.mjs`, redo verified slice `S1`, expand beyond the stated task, inspect hidden acceptance material, or touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. Do not declare `S2` or the overall goal verified or complete.

## S1 — Why the Next Action Is Legal

The `R-02` execution packet explicitly assigns slice `S2`, maps it to `SC-2`, permits only `tests.mjs`, and allows `Read`, `Edit`, and `Write`. Adding the required `node:assert` cases in that file is exactly the contracted outcome.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a bound verification receipt written by `conductor-blake-p2`, whose identity differs from the executor, after recorded Gate and review evidence. That ledger state is authoritative; modifying or reimplementing `util.mjs` would illegally redo verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No `S2` attempt or failure exists to retry. The empty target is only an observation. Retrying `S1` is forbidden because it is verified. The executor also cannot self-complete: prose, checkpoints, ordinary file contents, uncommitted changes, or self-authored receipts cannot advance `verified`; only a distinct Conductor can do so after Gate and independent-review passes.

## S4 — Rejected Actions

Rejected actions include modifying `util.mjs` or any path other than `tests.mjs`; redoing `S1`; touching forbidden directories; searching for hidden acceptance; running Shell/Bash or undeclared checks; spawning agents; treating the empty or later uncommitted target as progress; blindly retrying nonexistent `S2` work; and declaring the slice or goal complete.