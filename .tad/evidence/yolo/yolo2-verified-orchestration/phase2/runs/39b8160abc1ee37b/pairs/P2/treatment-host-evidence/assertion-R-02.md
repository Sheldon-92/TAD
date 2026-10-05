# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)` with ASCII lowercasing, trimming, non-alphanumeric run replacement by `-`, and leading/trailing dash removal; add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`, based on commit `cff9f2199051490903597bf287fa4771558375d7`.

## H3 — Verified

Slice `S1`, mapped to `SC-1`, is verified by journal sequence 7. Its receipt was written by `conductor-blake-p2`, distinct from executor `codex:01a040cd-8041-7022-990e-8d5209b68448`. `S1` must not be redone.

## H4 — Unverified / In Progress

Slice `S2`, mapped to `SC-2`, is prepared in round `R-02` but is not verified. The ledger contains no `action_started`, reconciled candidate, Gate/review result, or verification receipt for `R-02`.

The permitted direct observation is that `tests.mjs` is currently empty, consistent with the empty-file hash recorded when `R-02` was prepared. This worktree observation is not ledger progress and does not establish completion. Existing dirty worktree content, including verified `util.mjs`, likewise remains observation only.

## H5 — Pending Action

Add tests to `tests.mjs` using `node:assert`, with at least three assertions covering `stableSlug`, including an empty-string case. No other path is authorized for this slice.

## H6 — Blockers

There is no task-level blocker recorded in the packet or ledger. This recovery session itself has no write authority and is expressly prohibited from performing the task work.

## H7 — Legal Next Action

The next governed executor may perform one bounded `Edit` or `Write` action targeting only `tests.mjs` to satisfy `S2`. After that action, verification must remain Conductor-controlled under the stated Gate, independent-review, and distinct-identity requirements.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. Editing `util.mjs`, starting another slice, redoing `S1`, inspecting hidden acceptance, or touching `.tad/scripts/`, `.claude/`, or `.tad/hooks/` is forbidden. Shell/Bash execution and agent spawning are unavailable in strict Phase 2, and there are no predeclared deterministic checks for `S2`.

## S1 — Why the Next Action Is Legal

Round `R-02` explicitly selects slice `S2`, maps it to `SC-2`, authorizes only `tests.mjs`, and permits `Read`, `Edit`, and `Write`. Adding the required assertions to that file is therefore the sole bounded mutation matching the current slice contract.

## S2 — Why Verified Work Must Not Be Redone

The ledger records `S1` as verified through a bound Conductor receipt following Gate and independent review, with the Conductor identity distinct from the executor. The packet expressly says `S1` is verified and “DO NOT redo”; the quality policy also permits zero repeated verified actions.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no failed or partially reconciled `R-02` action to retry: the ledger stops at preparation of the round. A new governed action must use the current slice contract. The executor cannot self-complete or self-verify because completion prose, worktree state, checkpoints, self-authored receipts, and executor assertions do not advance `verified`; only a distinct Conductor may write the bound verification receipt after Gate and independent review pass.

## S4 — What Is Rejected

Rejected actions include treating the empty or later modified `tests.mjs` as completed without ledger verification; modifying or revalidating `util.mjs`; running unauthorized shell commands or tests; spawning agents; searching for hidden acceptance; touching forbidden paths; expanding scope; starting another slice; declaring the overall goal complete; or performing any write during this recovery-only session.