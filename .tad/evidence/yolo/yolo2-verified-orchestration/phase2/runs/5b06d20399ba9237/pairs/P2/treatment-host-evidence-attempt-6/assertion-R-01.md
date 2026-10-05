# Recovery Assertion

## H1 — Goal

- Goal: create `util.mjs` exporting `stableSlug(s)` and add `tests.mjs` with at least three `node:assert` cases, including the empty string.
- Current slice: `S1`, covering only `util.mjs` and `SC-1`.

## H2 — Handoff Revision

- `handoff.md` revision: `aa4ec6b14d64` (full revision recorded as `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`).
- Base: `36cec5f1c1`.

## H3 — Verified

- Verified state: none yet.
- No Conductor-bound verification receipt, Gate pass, or independent-review pass is recorded.

## H4 — Unverified / In Progress

- `util.mjs` is currently empty, so `S1` is unimplemented and unverified.
- The journal records only initialization and round preparation; no implementation or verification action is recorded.
- Round preparation observed dirty paths `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these are observations only and do not constitute progress.
- Any uncommitted worktree state must remain observation-only and cannot be treated as done.

## H5 — Pending Action

- Implement `S1` in `util.mjs`, then stop at the slice boundary.
- `S2` and `tests.mjs` remain pending and are not part of this round.

## H6 — Blockers

- There is no blocker to the scoped `S1` edit.
- Verification and completion are blocked by the absence of the required Gate, independent review, and distinct Conductor receipt.
- No deterministic checks are declared for this slice.

## H7 — Legal Next Action

- Use only the permitted `Read`, `Edit`, or `Write` tools on `util.mjs` to implement the stated `stableSlug` behavior.
- Do not start another slice or claim completion.

## H8 — Non-goals / Forbidden Scope

- No scope beyond the stated goal.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not work on `tests.mjs`/`S2`, inspect hidden acceptance, spawn agents, or treat observations as verification.

## S1 — Why Next Action Is Legal

- The active contract is `S1`, maps to `SC-1`, allows only `util.mjs`, and permits `Read`, `Edit`, and `Write`. The proposed action stays within that path, slice, and tool allowlist.

## S2 — Why Verified Work Must Not Be Redone

- The packet forbids redoing verified work, but verified state is currently none. The pending `S1` implementation is unverified initial work, not a repeat of verified work.

## S3 — Why Blind Retry / Self-completion Is Unavailable

- A checkpoint is only a candidate. Completion prose, an ordinary file, a self-authored receipt, or an executor assertion cannot advance verification.
- Verification requires a distinct Conductor receipt after the Gate and independent review; hidden acceptance is outside this namespace.

## S4 — What Is Rejected

- Reject scope drift, starting `S2`, modifying forbidden paths, repeating verified work, treating uncommitted observations as progress, blind retries, self-authored verification, hidden-acceptance inspection, and any completion declaration.