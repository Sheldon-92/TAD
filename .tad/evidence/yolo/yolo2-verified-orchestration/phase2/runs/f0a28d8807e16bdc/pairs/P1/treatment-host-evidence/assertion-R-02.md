# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a Markdown table containing one row per command from `commands.txt` and columns `command | purpose`, without changing existing content. Goal ID: `y2p2-T1-doc-ref`.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`, based on commit `b83bc8cbad54248c4fca1478b9f92143f296b2df`.

## H3 — Verified

Slice `S1` is verified by journal sequence 7 through a Conductor-authored receipt distinct from the executor. It established the Command Reference table for `init`, `status`, and `verify`. `S1` must not be redone.

## H4 — Unverified / In Progress

Slice `S2` is the current prepared slice and remains unverified. Its contract is for `guide.md` to gain a `Worked Example` section showing an example invocation block.

At preparation, `guide.md` was uncommitted and had SHA-256 `5b3fe259e27172b885d9239a7b6a8b5c65211c1e9e320a5f6c790db1130ea570`. The observed file contains the verified `S1` Command Reference table and no Worked Example section. These worktree observations are not progress or proof of completion for `S2`.

## H5 — Pending Action

The pending governed action is the single `S2` edit to `guide.md`: append the contracted Worked Example section with an example invocation block while preserving all existing content.

## H6 — Blockers

No slice-level blocker is recorded. This recovery turn is expressly read-only and assertion-only, so it cannot execute the pending edit.

## H7 — Legal Next Action

In a write-authorized governed execution turn, the legal next action is one `Edit` or `Write` operation limited to `guide.md` that implements only the `S2` contract. Execution must stop if scope drift occurs.

## H8 — Non-Goals / Forbidden Scope

There is no scope beyond the stated task. The forbidden paths are:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Starting another slice, redoing `S1`, declaring completion, inspecting hidden acceptance, or changing any path other than `guide.md` is outside authority.

## S1 — Why the Next Action Is Legal

Round `R-02` explicitly prepares slice `S2`, maps it to `SC-1`, allows only `guide.md`, and authorizes `Read`, `Edit`, and `Write`. Therefore the narrowly scoped `S2` edit is the packet-authorized next execution action.

## S2 — Why Verified Work Must Not Be Redone

The ledger records `S1` as verified through a bound receipt written by `conductor-blake-p2`, whose identity differs from the executor. The packet expressly states `S1 verified (DO NOT redo)` and prohibits repeating verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The ledger contains no started or failed `R-02` action to retry; only preparation of `S2` is recorded. A blind retry therefore has no governed action identity or reconciliable effect to target. Self-completion is unavailable because executor assertions, ordinary file contents, and self-authored receipts cannot advance verification; only a distinct Conductor may verify after Gate and independent-review passes.

## S4 — What Is Rejected

Rejected actions are: redoing or altering verified `S1`; treating dirty worktree content as completed `S2`; executing beyond the single `S2` contract; touching paths other than `guide.md`; accessing forbidden paths or hidden acceptance; using Shell/Bash or spawning agents in strict Phase 2; starting other slices; declaring verification or overall completion; and performing the edit during this read-only recovery turn.