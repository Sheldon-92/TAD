# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)` that lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. Separately, `tests.mjs` must use `node:assert` for at least three cases, including the empty string.

## H2 — Handoff Revision

- Goal ID: `y2p2-T2-node-behavior`
- Handoff revision: `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`
- Base commit: `d81a4d7a767ad04a55d3442447fa73c46097d38f`
- Current round/slice: `R-01` / `S1`

## H3 — Verified

Nothing is verified. The ledger contains no bound verification receipt, Gate PASS, or independent-review PASS.

## H4 — Unverified / In Progress

- `S1` is prepared but not completed or verified.
- Direct inspection shows the current slice target, `util.mjs`, is empty.
- The preparation ledger recorded `util.mjs` with the empty-file SHA-256 and did not list it among dirty paths.
- The preparation ledger recorded uncommitted observations for `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These observations are not progress and were not inspected.
- No executor attempt, candidate checkpoint, or failure is recorded.
- `S2` remains outside the current slice and is not in progress.

## H5 — Pending Action

Implement only `S1`: edit `util.mjs` so it exports `stableSlug` with the required lowercase, trim, non-alphanumeric run replacement, and leading/trailing dash removal behavior. Then stop for Conductor-side Gate and independent review.

## H6 — Blockers

No task blocker is recorded. This recovery session has read-only authority and therefore cannot execute the pending implementation.

## H7 — Legal Next Action

The next authorized executor action is a single scoped edit to `util.mjs` implementing `stableSlug`. No other file may be changed in this slice.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated goal.
- Do not begin `S2` or edit `tests.mjs` during `S1`.
- Do not access hidden acceptance.
- Do not declare completion or verification.
- Do not treat uncommitted worktree state as completed progress.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.

## S1 — Why the Next Action Is Legal

The execution packet explicitly assigns `S1`, maps it to `SC-1`, permits `util.mjs` as the sole allowed path, and defines the required implementation outcome. Editing only that file is therefore within the current slice contract.

## S2 — Why Verified Work Must Not Be Redone

The policy forbids redoing verified work because verification is ledger-bound and authoritative. Although nothing is verified yet, any future recovery must preserve verified slices and advance only the pending slice identified by the ledger.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded failed attempt to retry, no deterministic check authorized for the executor, and no evidence that implementation occurred. An executor cannot self-verify or declare completion: verification requires a distinct Conductor identity, an existing Gate PASS, an independent-review PASS, and a bound verification receipt.

## S4 — Rejected Actions

Rejected actions include implementing or testing `S2`, editing any path other than `util.mjs`, inspecting hidden acceptance, modifying forbidden directories, treating dirty or uncommitted observations as progress, inventing a retry, issuing a self-authored verification, declaring the goal complete, or performing task work during this read-only recovery assertion.