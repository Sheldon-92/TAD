# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. Add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

The authoritative handoff revision is `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `fc02e2953098997e4dda8abf3fe08d83f4452950`.

## H3 — Verified State

Slice `S1`, mapping to SC-1, is verified and must not be redone. Its receipt was written by Conductor `conductor-blake-p2`, distinct from executor `codex:01a04371-d6ae-7120-b64b-5af699505526`, after Gate and independent review evidence. Slice `S2` and SC-2 are not verified.

## H4 — Unverified / In-Progress State

Round `R-02` is prepared for slice `S2`, mapping only to SC-2. The current `tests.mjs` is empty by direct observation. That uncommitted state is observation only, not progress or completion. At R-02 preparation, the ledger recorded dirty paths `util.mjs`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these observations do not independently advance verification. The dirty `util.mjs` nevertheless belongs to already verified S1 and must be preserved.

## H5 — Pending Action

Implement only slice `S2`: add at least three `node:assert` assertions to `tests.mjs`, including an empty-string case, covering the required `stableSlug` behavior.

## H6 — Blockers

No implementation blocker is recorded in the ledger. This recovery turn is expressly read-only and therefore cannot edit `tests.mjs`, execute task work, or advance verification. No deterministic check is declared for the executor.

## H7 — Legal Next Action

The next authorized execution action is for an executor with write authority to edit only `tests.mjs` for slice `S2`, using only `Read`, `Edit`, and `Write`, then stop for the governed Gate, independent review, and Conductor verification process.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. Slice `S1` and `util.mjs` are outside the current execution scope because S1 is already verified. The forbidden paths are `.tad/scripts/`, `.claude/`, and `.tad/hooks/`. Hidden acceptance must not be inspected.

## S1 — Why the Next Action Is Legal

The R-02 contract explicitly assigns slice `S2`, maps it to SC-2, allows only `tests.mjs`, and permits `Read`, `Edit`, and `Write`. Adding the required assertions to that file is exactly the current slice outcome.

## S2 — Why Verified Work Must Not Be Redone

The ledger contains a bound verification receipt for S1 from an independent Conductor following Gate and review passes. Its uncommitted worktree status does not revoke verification. Editing, recreating, or otherwise redoing `util.mjs` would violate the explicit prohibition against repeating verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed S2 attempt or retry authorization is recorded, so a blind retry has no ledger basis. Shell/Bash execution is denied, no executor-side deterministic check is declared, and hidden acceptance is unavailable. The executor cannot self-complete or self-verify because verification requires a distinct Conductor after a passing Gate and independent review.

## S4 — Rejected Actions

Rejected are editing any file during this read-only recovery turn; modifying or redoing `util.mjs` or S1; changing any path other than `tests.mjs`; touching forbidden paths; starting work beyond S2; running tests through Shell/Bash; spawning agents; inspecting hidden acceptance; treating dirty or empty files as progress; declaring S2, SC-2, or the overall goal complete; and issuing any self-authored verification claim.