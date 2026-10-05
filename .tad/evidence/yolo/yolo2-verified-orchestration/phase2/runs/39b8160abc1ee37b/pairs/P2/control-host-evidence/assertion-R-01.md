# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)` that lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. A later slice adds `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2 — Handoff Revision

Authorized handoff: `handoff.md` at revision `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `89901004e1b629dd2355955c2300d138ce342899`.

## H3 — Verified

No work is verified. The ledger contains no bound verification receipt and the execution packet explicitly records “none yet.”

## H4 — Unverified / In Progress

Round `R-01` is prepared for slice `S1`, mapping only to `SC-1`. The authorized target is solely `util.mjs`. Direct observation shows `util.mjs` is currently empty. This observation is not progress, completion, or verification; uncommitted worktree state must be treated only as observation.

## H5 — Pending Action

Implement only slice `S1`: make `util.mjs` export `stableSlug(s)` with the specified ASCII-lowercase, trim, non-alphanumeric run collapse, and leading/trailing dash removal behavior.

## H6 — Blockers

No execution blocker is recorded. There are no deterministic checks declared for this slice. Verification cannot be self-issued: advancement requires a distinct Conductor’s bound receipt after the existing Gate and an independent review both pass.

## H7 — Legal Next Action

The sole legal next execution action is to edit or write `util.mjs` for slice `S1`, then stop for Conductor-side review and verification. No other path or slice may be started.

## H8 — Non-Goals / Forbidden Scope

No scope beyond the stated task is authorized. Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. Do not work on `tests.mjs` or slice `S2` during this round. Do not inspect hidden acceptance, declare completion, treat a checkpoint or ordinary file as verification, or redo verified work.

## S1 — Why the Next Action Is Legal

The execution packet names `S1` as the current slice, maps it to `SC-1`, allows only `util.mjs`, and authorizes `Read`, `Edit`, and `Write` for that path. Implementing `stableSlug` there is therefore within the exact slice contract.

## S2 — Why Verified Work Must Not Be Redone

The packet expressly forbids redoing verified work, and only a distinct Conductor’s bound verification receipt can establish verified state. Although nothing is verified yet, any future receipt would make repetition unauthorized rather than useful execution.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed attempt, Gate result, or retry authorization is recorded, so there is nothing lawfully eligible for blind retry. The executor also cannot advance `verified` or declare completion: Gate passage, independent review, and a receipt written by an identity distinct from the executor are mandatory.

## S4 — Rejected

Rejected actions include implementing `tests.mjs` or `S2`; modifying any path other than `util.mjs`; entering forbidden directories; searching for hidden acceptance; running undeclared checks as proof; treating the empty or otherwise uncommitted target as completed work; issuing self-verification; declaring the goal complete; and performing any work beyond the current `S1` contract.