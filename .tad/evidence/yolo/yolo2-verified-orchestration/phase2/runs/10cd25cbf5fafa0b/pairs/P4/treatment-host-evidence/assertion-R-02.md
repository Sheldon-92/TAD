# Recovery Assertion

## H1 — Goal

Align the documented version with `config.json` version `1.0.0`: `CHANGELOG.md` must begin with `v1.0.0`, and `usage.md` must reference `1.0.0` without mentioning `0.9.0`.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at SHA-256 `0bb2ee2a4b78eb78af6a5d503af71863043b24881cacc2f6d4539350d0d020c2`, based on commit `8bd9658b3afddda48466c3521696a308ba30f166`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified by journal sequence 7. Its receipt was written by `conductor-blake-p2`, an identity distinct from the executor. `CHANGELOG.md` work must not be repeated.

## H4 — Unverified / In-Progress State

Slice `S2`, mapped to `SC-2`, is prepared but not verified. No `S2` action has started or reconciled in the ledger. The allowed target currently reads `usage for 0.9.0`, so the required `1.0.0` state is not present. This file observation is not progress, completion, or verification. Earlier uncommitted `CHANGELOG.md` mutation is covered by the valid `S1` verification receipt; other dirty paths recorded by the ledger are not authorized targets for `S2`.

## H5 — Pending Action

Perform one governed edit of `usage.md`, changing the version reference from `0.9.0` to `1.0.0`, with no other path or scope changes.

## H6 — Blockers

No ledger blocker or stop condition is recorded for `S2`. This recovery turn has no write authority and is explicitly limited to producing the assertion, so execution cannot occur within this turn.

## H7 — Legal Next Action

After governed re-entry accepts this assertion, the executor may use the slice-authorized `Edit` operation on `usage.md` only, changing `0.9.0` to `1.0.0`. The result remains merely a candidate until the required Gate, independent review, and distinct-Conductor verification receipt succeed.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated version alignment is authorized. Do not modify `.tad/scripts/`, `.claude/`, `.tad/hooks/`, `CHANGELOG.md`, or any path other than `usage.md` during `S2`. Do not inspect hidden acceptance, start another slice, redo verified work, or declare the overall goal complete.

## S1 — Why the Next Action Is Legal

`S2` is the current prepared slice; it maps directly to `SC-2`, names `usage.md` as its sole allowed path, and permits `Edit`. Replacing its observed `0.9.0` reference with `1.0.0` exactly implements the slice outcome without scope drift.

## S2 — Why Verified Work Must Not Be Redone

The ledger contains a bound `verified` event for `S1` with Gate and review evidence and a receipt authored by a Conductor distinct from the executor. The packet expressly marks `S1` “verified (DO NOT redo),” and the execution policy forbids repeating verified work.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

There is no prior `S2` action to retry: the ledger ends with preparation of round `R-02`. A blind retry would therefore lack an action identity and governed evidence. The executor also cannot self-complete or self-verify; only a distinct Conductor may advance verified state after both the existing Gate and an independent review pass.

## S4 — Rejected Actions

Rejected actions include writing during this read-only recovery turn; editing anything except `usage.md`; redoing `S1` or touching `CHANGELOG.md`; modifying forbidden directories; searching for hidden acceptance; treating observed or uncommitted state as verified progress; blind retrying a nonexistent `S2` action; self-authoring verification; starting another slice; or declaring task completion.