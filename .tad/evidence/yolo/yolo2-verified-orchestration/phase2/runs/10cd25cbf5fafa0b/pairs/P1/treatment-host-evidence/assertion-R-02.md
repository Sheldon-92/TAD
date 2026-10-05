# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a `command | purpose` table covering `init`, `status`, and `verify`, while preserving existing content. Success also requires a Worked Example section containing an example invocation block.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`, based on commit `080e7eb0a8e858d89b646c0c27abaf0aa85ccb7f`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified by ledger sequence 7. Its Command Reference table must not be redone, replaced, or treated as pending.

## H4 — Unverified / In-Progress State

Slice `S2`, mapped to `SC-2`, is prepared but unverified. No `action_started`, reconciliation, closed-round candidate, Gate, independent review, or verification receipt for R-02 appears in the ledger.

The observed `guide.md` contains the intro and verified S1 Command Reference table but no Worked Example section. `guide.md` is recorded as dirty and all current worktree content is observation only; it does not establish additional progress or completion.

## H5 — Pending Action

The pending governed action is to execute only S2: append a Worked Example section with an example invocation block to `guide.md`, preserving all existing content, including verified S1 work.

## H6 — Blockers

This recovery session has no write authority and is expressly prohibited from doing task work. S2 therefore remains pending for an authorized executor. No technical failure or failed deterministic check is recorded.

## H7 — Legal Next Action

The next legal task action is one governed edit limited to `guide.md` that implements S2 only, followed by Conductor-side reconciliation, Gate evaluation, independent review, and—only after both pass—a verification receipt written by an identity distinct from the executor.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. Changes to `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Redoing S1, starting another slice, inspecting hidden acceptance, or declaring the overall goal complete is forbidden.

## S1 — Why the Next Action Is Legal

R-02’s current slice contract explicitly authorizes S2, maps it to `SC-2`, limits effects to `guide.md`, and allows an Edit-class action. Appending only the Worked Example section satisfies that contract without crossing its stop condition of scope drift.

## S2 — Why Verified Work Must Not Be Redone

The ledger contains a bound verification receipt for S1 written by `conductor-blake-p2`, distinct from the executor, after Gate and independent-review evidence. The packet explicitly marks S1 “verified (DO NOT redo),” and the quality policy permits zero repeated verified actions.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no prior R-02 action to retry: the ledger ends with `round_prepared` for S2 and records no action nonce, intended effect, failure, or interrupted execution for this round. Completion cannot be self-asserted because executor prose, observed file contents, uncommitted changes, and self-authored receipts cannot advance `verified`; only a distinct Conductor may do so after Gate and independent review pass.

## S4 — What Is Rejected

Rejected actions include treating the observed missing Worked Example as authority to edit in this read-only recovery session; treating dirty or uncommitted content as verified progress; retrying or modifying S1; editing any path other than `guide.md`; inspecting hidden acceptance; starting out-of-scope work; or declaring S2 or the overall goal complete without the required Conductor receipt.