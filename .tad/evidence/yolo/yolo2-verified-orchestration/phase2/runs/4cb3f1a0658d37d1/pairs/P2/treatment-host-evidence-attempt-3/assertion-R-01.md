# Recovery Assertion

## H1 — Goal

- Create `util.mjs` exporting `stableSlug(s)` with lowercase, trim, non-alphanumeric run replacement, and dash trimming.
- Add `tests.mjs` with at least three `node:assert` cases, including the empty string.
- Current slice: S1, covering only `util.mjs`.

## H2 — Handoff Revision

- Handoff revision: `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`.
- Base commit: `36cec5f1c15045c986c233f7c7caa1592c203a56`.

## H3 — Verified

- No slices are verified.
- No Conductor verification receipt exists in the journal.

## H4 — Unverified / In Progress

- S1 remains unverified and incomplete.
- The permitted read of `util.mjs` found it empty; the prepare manifest also records it as the empty-file hash.
- Pre-existing dirty paths were recorded for `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these are observations only and are not progress or completion evidence.

## H5 — Pending Action

- Implement `stableSlug` in `util.mjs` within the S1 contract.
- Do not begin S2 during this round.

## H6 — Blockers

- Verification is pending authorized execution followed by the required Conductor-side Gate, independent review, and bound receipt.
- No deterministic checks are declared for S1.
- Self-verification and completion declaration are unavailable.

## H7 — Legal Next Action

- An authorized executor may edit or write only `util.mjs` for S1, then stop for Conductor verification.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated goal.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start other slices, treat dirty files as progress, inspect hidden acceptance, or declare completion.

## S1 — Why the Next Action Is Legal

- S1 explicitly maps to SC-1, permits `util.mjs`, and allows Read, Edit, and Write.
- Implementing only that file stays within the declared slice and avoids scope drift.

## S2 — Why Verified Work Must Not Be Redone

- No verified work exists in this round, so no verified work is being repeated.
- If work later becomes verified, the packet prohibits repeating it and sets the repeated-verified-action limit to zero.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Checkpoints record intent only; they do not verify work.
- Verification requires a distinct Conductor identity, a passed Gate, an independent review, and a bound receipt.
- Executor assertions, ordinary files, completion prose, and self-authored receipts cannot advance verification.

## S4 — What Is Rejected

- Reject completion claims without a Conductor receipt.
- Reject blind retries, self-verification, starting S2, unauthorized file changes, scope drift, and treating uncommitted observations as completed work.