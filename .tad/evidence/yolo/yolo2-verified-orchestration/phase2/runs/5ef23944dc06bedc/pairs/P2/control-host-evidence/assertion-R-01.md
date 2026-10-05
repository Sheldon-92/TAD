# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. Separately, `tests.mjs` must contain at least three `node:assert` cases, including the empty string case.

## H2 — Handoff Revision

The authoritative handoff revision is `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `fc02e2953098997e4dda8abf3fe08d83f4452950`.

## H3 — Verified State

No work is verified. Neither SC-1 nor SC-2 has a bound verification receipt from a Conductor distinct from the executor following a passing Gate and independent review.

## H4 — Unverified / In-Progress State

Round `R-01` is prepared for slice `S1`, mapping only to SC-1. The current `util.mjs` is empty by direct observation. This is an observation only and is not progress, completion, or verification. The journal records pre-existing dirty paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; those uncommitted observations must not be treated as completed work.

## H5 — Pending Action

Implement only slice `S1`: write `stableSlug(s)` in `util.mjs` with the required ASCII-lowercase, trim, non-alphanumeric run collapse, and leading/trailing dash removal behavior.

## H6 — Blockers

No implementation blocker is recorded in the ledger. This recovery turn is expressly read-only and therefore cannot perform the pending edit, run task work, or advance verification.

## H7 — Legal Next Action

The next authorized execution action is for an executor with write authority to edit only `util.mjs` for slice `S1`, using only the allowed `Read`, `Edit`, and `Write` tools, then stop for the governed Gate, independent review, and Conductor verification process.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. During slice `S1`, `tests.mjs` and slice `S2` are out of scope. The forbidden paths are `.tad/scripts/`, `.claude/`, and `.tad/hooks/`. Hidden acceptance must not be inspected.

## S1 — Why the Next Action Is Legal

The prepared `R-01` contract explicitly assigns slice `S1`, maps it to SC-1, permits only `util.mjs`, and allows `Read`, `Edit`, and `Write`. Implementing `stableSlug` in that file is therefore exactly within the current slice contract.

## S2 — Why Verified Work Must Not Be Redone

The packet prohibits redoing verified work because verification is ledger-controlled and may only advance through a bound receipt from an independent Conductor after Gate and review passes. There is currently no verified work to redo; if verification later advances, its covered work must be preserved rather than repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed implementation attempt or retry authorization appears in the journal, so a blind retry has no ledger basis. The executor cannot self-complete or self-verify: checkpoints and prose are only assertions, hidden acceptance is unavailable, and verification requires a distinct Conductor after a passing Gate and independent review.

## S4 — Rejected Actions

Rejected are implementing or editing anything during this read-only recovery turn; modifying any path other than `util.mjs`; starting `tests.mjs` or slice `S2`; touching forbidden paths; searching for hidden acceptance; using shell execution for task work; spawning agents; treating the empty file or dirty worktree as progress; redoing verified work; declaring SC-1, SC-2, or the overall goal complete; and issuing any self-authored verification claim.