# Recovery Assertion

## H1 — Goal

Goal `y2p2-T1-doc-ref`: preserve the existing `guide.md` content while satisfying:

- `SC-1`: add a `## Command Reference` table for `init`, `status`, and `verify`, with `command` and `purpose` columns.
- `SC-2`: add a Worked Example section containing an example invocation block.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`, based on commit `7cf6dbfefd21f4e6950047ebd2609d5c8f9beafa`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified by ledger event sequence 7. Its receipt was written by Conductor identity `conductor-blake-p2`, distinct from executor `codex:01a040ca-245d-7fd3-a36d-9354b0fd3913`. `S1` must not be redone.

## H4 — Unverified / In-Progress State

Slice `S2`, mapped to `SC-2`, is prepared in round `R-02` but has no recorded action, candidate result, or verification receipt.

The current uncommitted `guide.md` observation contains the verified Command Reference content and does not contain a Worked Example section. This worktree observation is not evidence of progress or completion for `S2`.

## H5 — Pending Action

Append only the `S2` outcome to `guide.md`: a Worked Example section showing an example invocation block, while preserving all existing content.

## H6 — Blockers

No task-level blocker is recorded. This recovery session has no write authority and is expressly prohibited from performing task work, so the pending edit cannot be executed during this assertion turn.

## H7 — Legal Next Action

In a governed execution turn with write authority, perform one scoped `Edit` or `Write` action against `guide.md` only, adding the Worked Example section required by `S2`. Stop if satisfying it would require scope drift.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. Changes to `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Starting another slice, redoing `S1`, declaring completion, using shell or spawning agents in strict Phase 2, or inspecting hidden acceptance is outside authority.

## S1 — Why the Next Action Is Legal

Round `R-02` assigns `S2` the exact outcome of adding a Worked Example invocation block, maps it to `SC-2`, permits only `guide.md`, and allows `Read`, `Edit`, and `Write`. The stated append-only edit therefore matches the current slice contract without expanding scope.

## S2 — Why Verified Work Must Not Be Redone

The ledger has a bound `verified` event for `S1`, backed by Gate and independent review evidence and written by a Conductor distinct from the executor. The packet explicitly prohibits redoing verified work, and the quality policy permits zero repeated verified actions.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded `S2` action to retry or reconcile; round `R-02` has only been prepared. Any future action must be a fresh, contract-bound edit based on the observed target state. The executor cannot self-verify or declare completion: verification advances only through a bound receipt written by a distinct Conductor after Gate and independent review both pass.

## S4 — What Is Rejected

Rejected actions include treating the dirty worktree as verified `S2` progress, repeating or modifying the Command Reference work, altering existing content unnecessarily, editing any path other than `guide.md`, entering forbidden directories, inspecting hidden acceptance, using prohibited shell or agent-spawning mechanisms, performing the edit in this read-only recovery turn, or asserting that the overall goal is complete.