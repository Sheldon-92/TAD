# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)` and `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2 — Handoff Revision

Handoff revision: `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`; base: `36cec5f1c15045c986c233f7c7caa1592c203a56`.

## H3 — Verified

Slice S1 is verified and maps to SC-1. Its conductor receipt was written by `conductor-blake-p2`, distinct from the executor. S1 must not be redone.

## H4 — Unverified/In Progress

Slice S2 is prepared but unverified; no R-02 action has started. `tests.mjs` is currently empty. Existing dirty worktree changes, including verified `util.mjs`, are observations only and must not be treated as S2 progress or completion.

## H5 — Pending Action

Complete only S2 by adding the required assertions to `tests.mjs`, then await conductor-side verification.

## H6 — Blockers

S2 has no verification receipt. Self-verification, completion declaration, hidden acceptance, shell execution, and agent spawning are unavailable or prohibited.

## H7 — Legal Next Action

Use only Read/Edit/Write on `tests.mjs` to implement S2, stopping immediately on scope drift.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated goal. Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not start other slices or redo S1.

## S1 — Why the Next Action Is Legal

The R-02 S2 contract allows only `tests.mjs` and permits Read, Edit, and Write. S2 maps directly to SC-2 and is independent of verified S1.

## S2 — Why Verified Work Must Not Be Redone

The ledger records S1 as verified with conductor receipt, gate evidence, independent review evidence, and a distinct writer identity. Repeating S1 would violate the packet prohibition against redoing verified work.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

A checkpoint is only a candidate. Verification advances only through a conductor-written bound receipt after Gate and independent review pass; executor assertions, ordinary completion prose, and self-authored receipts cannot advance verification.

## S4 — What Is Rejected

Reject declaring completion, treating dirty or candidate changes as verified, retrying S1, executing another slice, modifying forbidden paths, using hidden acceptance, or using shell/agent actions outside the contract.