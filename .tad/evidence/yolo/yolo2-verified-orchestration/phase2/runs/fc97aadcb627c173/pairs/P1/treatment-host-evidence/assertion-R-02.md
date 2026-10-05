# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md` with a `command | purpose` Markdown table covering `init`, `status`, and `verify`, while preserving existing content; success also requires a `Worked Example` section containing an example invocation block.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`, based on commit `d7bd37b8868d8f3b5f2fb2d9fad9f3b9c63fe628`.

## H3 — Verified

Slice `S1`, mapped to `SC-1`, is verified and must not be redone. Journal sequence 7 records a Conductor-authored verification receipt distinct from the executor. The observed `guide.md` contains the verified Command Reference table and unchanged intro.

## H4 — Unverified / In Progress

Slice `S2`, mapped to `SC-2`, is prepared but unverified. No `S2` action has started or been reconciled, and no Worked Example appears in the observed target file. `guide.md` is recorded as dirty with SHA-256 `5b3fe259e27172b885d9239a7b6a8b5c65211c1e9e320a5f6c790db1130ea570`; this uncommitted state is observation only and does not independently establish progress or completion.

## H5 — Pending Action

The pending slice action is to append a `Worked Example` section with an example invocation block to `guide.md`, preserving all existing content, including verified `S1`.

## H6 — Blockers

No ledger blocker or failed deterministic check is recorded. This recovery turn is expressly read-only and therefore cannot execute the pending edit.

## H7 — Legal Next Action

The only legal action in this recovery turn is to emit this assertion. In a subsequent governed execution phase with write authority, the next legal task action is one scoped edit to `guide.md` implementing only `S2`, followed by Conductor-side gate, independent review, and verification.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. Do not modify `.tad/scripts/`, `.claude/`, `.tad/hooks/`, or any path other than `guide.md`. Do not start another slice, redo `S1`, inspect hidden acceptance, or declare the overall goal complete.

## S1 — Why the Next Action Is Legal

`S2` is the current slice contract, maps directly to unmet criterion `SC-2`, permits only `guide.md`, and authorizes an Edit/Write operation whose sole outcome is the Worked Example section.

## S2 — Why Verified Work Must Not Be Redone

The ledger already advances `S1` to verified through a bound receipt written by a Conductor distinct from the executor after gate and independent review. The packet explicitly marks `S1` “verified (DO NOT redo),” and repeating it would violate the prohibition on redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no prior `S2` action record, nonce, effect manifest, reconciliation, gate result, review, or verification receipt to retry or adopt. File contents and executor prose cannot advance verified state; only a distinct Conductor may verify after gate and independent review.

## S4 — Rejected Actions

Rejected actions include editing during this read-only recovery turn; modifying anything except `guide.md`; changing or reconstructing the verified Command Reference or intro; treating dirty content as verified progress; inventing or blindly retrying an `S2` action; running unrelated checks; spawning agents; inspecting hidden acceptance; entering forbidden paths; starting other slices; or asserting completion before a valid Conductor verification receipt exists.