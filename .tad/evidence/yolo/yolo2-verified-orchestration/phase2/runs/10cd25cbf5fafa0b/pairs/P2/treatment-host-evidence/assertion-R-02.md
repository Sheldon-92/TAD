# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)` with the specified lowercase/trim/dash-collapse behavior, and add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

The governed handoff revision is `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`, based on commit `7cddb257c6caf8242cf3b6e3f453984114553893`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified by journal sequence 7 with Conductor receipt `receipt-R-01.json`. It must not be redone. The overall goal is not yet verified because `S2` remains pending.

## H4 — Unverified / In-Progress State

Round `R-02` has been prepared for slice `S2`, mapped to `SC-2`, but no `action_started`, reconciliation, round closure, or verification entry exists for it. The authorized slice target `tests.mjs` is currently empty. That worktree observation is not progress and must not be treated as completed or verified work.

## H5 — Pending Action

Implement only `tests.mjs` so it uses `node:assert`, contains at least three assertions for `stableSlug`, includes an empty-string case, and passes under Node. No deterministic executor-side check is declared in the packet.

## H6 — Blockers

This recovery turn has no write access and is expressly limited to producing the recovery assertion, so it cannot execute the pending edit. No ledger-recorded implementation blocker or failed `S2` action exists.

## H7 — Legal Next Action

The next governed executor may perform one scoped `Edit` or `Write` action targeting only `tests.mjs` for slice `S2`, then stop for Conductor-side reconciliation, Gate, independent review, and verification. It may not declare the slice or goal complete itself.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated goal is authorized. The paths `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Editing `util.mjs`, starting another slice, inspecting hidden acceptance, spawning agents, or using shell execution for task work is outside the current slice contract.

## S1 — Why the Next Action Is Legal

`R-02` is ledger-prepared for `S2`; its outcome is exactly the required `tests.mjs` test coverage, its sole allowed path is `tests.mjs`, and its allowed mutation tools are `Edit` and `Write`.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a bound verification receipt written by `conductor-blake-p2`, an identity distinct from the executor, with recorded Gate and review evidence. The packet explicitly says verified work must not be redone, and the quality policy permits zero repeated verified actions.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

There is no prior `S2` action or failure to retry: the journal ends with `round_prepared` for `R-02`. Blind retry therefore has no governed action basis. Executor self-completion is unavailable because only a distinct Conductor may advance `verified` after both the existing Gate and an independent review pass; executor prose, file contents, or a self-authored receipt cannot do so.

## S4 — Rejected Actions

Rejected: reimplementing or modifying verified `S1`; treating the empty or otherwise uncommitted `tests.mjs` state as progress; editing any path other than `tests.mjs`; running undeclared task checks; inspecting hidden acceptance; entering forbidden paths; starting another slice; blindly retrying a nonexistent action; or asserting completion or verification without the required Conductor receipt.