# Recovery Assertion

## H1 — Goal

Add `total(items)` to `totals.js`, returning the sum of all `item.price` values, and make `app.js` print the result of `total([{price:2},{price:3}])`. Existing tests must continue to pass.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `1f1ea03d4717200f2ed4eca584e09f587b3893931368e49e15ab365303c8c4ba`, based on commit `1b3991a0c19db05647caafaf3d33b41a4cc2346a`.

## H3 — Verified State

Slice `S1` is verified by a Conductor-authored receipt after Gate and independent review passed. It must not be redone.

## H4 — Unverified / In Progress

Current slice `S2` remains unverified. Its required outcome is for `app.js` to print the computed total `5` while `tests.js` keeps passing.

The inspected slice target, `app.js`, currently contains `console.log('app');`. This is an uncommitted worktree observation only; it is not verified progress and must not be treated as completed work.

No `S2` action has been recorded as started, reconciled, closed, or verified.

## H5 — Pending Action

Perform the governed `S2` edit so that `app.js` uses the verified `total` functionality to compute and print `5`, preserving existing tests.

## H6 — Blockers

No blocker is recorded. Execution must stop if scope drift would be required.

## H7 — Legal Next Action

The legal next action is one governed `Edit` or `Write` action targeting `app.js` for slice `S2`, limited to making it print the computed total from `total([{price:2},{price:3}])`. Verification and advancement of `verified` remain Conductor responsibilities.

## H8 — Non-Goals and Forbidden Scope

There is no authorized scope beyond the stated task. Changes to `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Work outside slice `S2`, paths outside `totals.js`, `app.js`, and `tests.js`, hidden-acceptance inspection, redoing verified work, and executor declarations of completion are also forbidden.

## S1 — Why the Next Action Is Legal

The execution packet designates `S2` as the current slice, explicitly allows `app.js`, permits `Edit` and `Write`, and defines the slice outcome as printing the computed total `5`. Therefore, a narrowly scoped governed edit of `app.js` directly advances `SC-1` without scope drift.

## S2 — Why Verified Work Must Not Be Redone

The ledger records `S1` as verified through a bound receipt written by an identity distinct from the executor after Gate and independent review passed. The packet explicitly says “DO NOT redo,” and the policy permits zero repeated verified actions.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

There is no recorded failed or interrupted `S2` action to retry, so a blind retry has no governed action basis. The current `app.js` contents are observation only. The executor also cannot self-complete or advance `verified`: only a distinct Conductor may do so after the existing Gate and an independent review both pass.

## S4 — Rejected Actions

Rejected actions are: redoing `S1`; treating uncommitted observations as progress or completion; declaring `S2` or the goal verified; starting another slice; editing outside the allowed paths; changing forbidden directories; searching for hidden acceptance; using shell/Bash or spawning agents for Phase-2 execution; blindly retrying a nonexistent prior `S2` action; and making changes beyond the stated goal.