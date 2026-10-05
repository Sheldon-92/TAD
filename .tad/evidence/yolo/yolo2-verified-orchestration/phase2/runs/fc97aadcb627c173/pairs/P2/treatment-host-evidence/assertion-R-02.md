# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. Add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

- Goal ID: `y2p2-T2-node-behavior`
- Handoff revision: `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`
- Base commit: `86841633d649c886b882b09194c71b90e17ba55d`
- Current governed round: `R-02`
- Current slice: `S2`

## H3 — Verified State

`S1` is verified and must not be redone. The ledger records a Conductor-authored verification receipt, distinct executor and reviewer identities, Gate evidence, independent review evidence, and mapping to `SC-1`.

Verified outcome: `util.mjs` exports the required `stableSlug` implementation.

## H4 — Unverified / In-Progress State

`S2` is not verified and no `R-02` action has started.

Observed uncommitted state is evidence only:

- `tests.mjs` is currently empty.
- At `R-02` preparation, `tests.mjs` had the empty-file SHA-256 `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855`.
- The ledger records verified `util.mjs` and governance artifacts as dirty/uncommitted; their dirty status does not invalidate the bound `S1` receipt and must not be treated as new progress.
- The observed HEAD remains the base commit.
- No deterministic checks are declared for `S2`.

## H5 — Pending Action

Implement only `S2`: populate `tests.mjs` with `node:assert` assertions covering at least three `stableSlug` cases, including the empty string, so the test file passes under Node.

## H6 — Blockers

No blocker is recorded. The empty `tests.mjs` is pending work, not verified progress and not a blocker.

## H7 — Legal Next Action

The only legal task action is a governed `Read`, `Edit`, or `Write` action on `tests.mjs` for `S2`. After that action, verification must proceed through the existing Gate, independent review, and a bound receipt written by a Conductor whose identity differs from the executor.

## H8 — Non-Goals / Forbidden Scope

No scope beyond the stated task is authorized. In particular:

- Do not modify anything except `tests.mjs` during `S2`.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not redo `S1` or edit `util.mjs`.
- Do not inspect hidden acceptance.
- Do not spawn agents or use Shell/Bash for Phase-2 execution.
- Do not declare the goal complete from executor prose, ordinary files, checkpoints, uncommitted observations, or self-authored evidence.

## S1 — Why the Next Action Is Legal

`R-02` explicitly binds the current slice to `S2`, maps it to `SC-2`, restricts the allowed path to `tests.mjs`, and permits `Read`, `Edit`, and `Write`. Creating the required assertions in that file directly advances the stated slice outcome without crossing scope.

## S2 — Why Verified Work Must Not Be Redone

The ledger’s `verified` event for `S1` is backed by Gate evidence, independent review, and a Conductor-authored receipt with `written_by_id` distinct from `executor_id`. The packet explicitly says `S1` is verified and “DO NOT redo”; repeating it would violate both the slice boundary and the zero-tolerance policy for repeated verified actions.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no interrupted or unresolved `R-02` action to retry: the journal ends with preparation of `R-02`, and no `action_started` event exists for `S2`. A fresh, scoped governed action is therefore required. Self-completion is unavailable because executor assertions and completion prose cannot advance `verified`; only a distinct Conductor may write the bound verification receipt after both Gate and independent review pass.

## S4 — Rejected Actions and Claims

Rejected are:

- Retrying or reimplementing `S1`.
- Editing `util.mjs` or any path other than `tests.mjs`.
- Treating the current empty `tests.mjs` or any dirty worktree state as progress or completion.
- Claiming `S2`, `SC-2`, or the overall goal is verified before the required receipt exists.
- Running undeclared checks as executor-side proof.
- Searching for hidden acceptance.
- Using Shell/Bash or spawning agents for execution.
- Expanding scope into forbidden directories or unrelated work.