# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. A later slice adds `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `b2728eaf0d3132df4b158085be37269c2cf0942c`.

## H3 — Verified

No work is verified. The packet’s verified state is explicitly `none yet`.

## H4 — Unverified / In Progress

Round `R-01` has prepared slice `S1`, mapped only to `SC-1`. The observed `util.mjs` is empty, so the required export and behavior are not present. The ledger also records pre-existing dirty paths at preparation; those and all other uncommitted worktree observations are evidence only, not progress or completion.

## H5 — Pending Action

Implement only slice `S1`: update `util.mjs` so it exports `stableSlug(s)` with the specified lowercase, trim, non-alphanumeric dash-collapse, and leading/trailing-dash removal behavior.

## H6 — Blockers

This recovery session has no write access and is expressly prohibited from doing task work. No governed implementation action can be performed in this session.

## H7 — Legal Next Action

In a write-enabled governed execution context, use an allowed `Edit` or `Write` action solely on `util.mjs` to implement slice `S1`, then stop for the independent Gate and Conductor verification process. Do not begin `S2` or declare the goal complete.

## H8 — Non-Goals / Forbidden Scope

No scope beyond the stated task is authorized. Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. During `S1`, do not modify `tests.mjs` or any path other than `util.mjs`; do not inspect hidden acceptance, spawn agents, run shell work, begin another slice, redo verified work, or self-declare verification or completion.

## S1 — Why the Next Action Is Legal

The current slice contract names `S1`, maps it to `SC-1`, permits only `util.mjs`, and allowlists `Read`, `Edit`, and `Write`. Implementing the required export in that file is therefore the sole in-scope execution action.

## S2 — Why Verified Work Must Not Be Redone

The policy expressly forbids redoing verified work, and verification can advance only through a bound receipt written by a Conductor distinct from the executor after both the Gate and independent review pass. Although nothing is verified yet, any future verified slice must be preserved rather than repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no verified receipt, no recorded failed attempt authorizing a retry, and no deterministic check assigned to the executor. Uncommitted observations cannot be promoted to progress, and executor prose or a self-authored receipt cannot establish verification. Completion therefore requires the governed independent verification path, not a blind retry or self-completion claim.

## S4 — What Is Rejected

Rejected actions include implementing or testing `S2`, modifying any file except `util.mjs`, touching forbidden directories, inspecting hidden acceptance, using shell or agents for execution, treating dirty or uncommitted files as completed work, repeating verified work, and asserting that `S1` or the overall goal is verified or complete without the required independent Conductor receipt.