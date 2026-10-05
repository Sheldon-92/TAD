# Recovery Assertion

## H1 — Goal

Align documented versions with `config.json` version `1.0.0`: `CHANGELOG.md` must begin with `v1.0.0`, and `usage.md` must reference `1.0.0` without mentioning `0.9.0`.

## H2 — Handoff Revision

The governed handoff is `handoff.md` revision `0bb2ee2a4b78eb78af6a5d503af71863043b24881cacc2f6d4539350d0d020c2`, based on commit `73f456f70fa62ee38285d56e4230f84b81361fe5`.

## H3 — Verified State

Slice `S1`, mapped to `SC-1`, is verified by the ledger. Its Conductor-authored receipt records independent Gate and review evidence. The `CHANGELOG.md` work must not be repeated.

## H4 — Unverified / In-Progress State

Slice `S2`, mapped to `SC-2`, is prepared but unverified. No `S2` action has started or been reconciled. The authorized read-only observation of `usage.md` is `usage for 0.9.0`, so its required outcome is not currently observed.

The journal recorded uncommitted dirty paths when `R-02` was prepared: `CHANGELOG.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These are observations only, not new progress. In particular, the uncommitted status of `CHANGELOG.md` does not negate its ledger verification.

## H5 — Pending Action

The pending governed action is to change the version reference inside `usage.md` from `0.9.0` to `1.0.0`, producing a file that references `1.0.0` and no longer mentions `0.9.0`.

## H6 — Blockers

There is no recorded blocker to the pending `S2` edit. This recovery turn has no write authority, so it may assert the next legal action but may not execute it.

## H7 — Legal Next Action

In an authorized execution turn, perform one governed `Edit` or `Write` action on `usage.md` only, changing `0.9.0` to `1.0.0`. Then stop and leave verification to the Conductor workflow.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated version-alignment task is authorized. Do not modify `.tad/scripts/`, `.claude/`, `.tad/hooks/`, or any path other than `usage.md` during slice `S2`. Do not redo `S1`, begin another slice, inspect hidden acceptance, spawn agents, use Shell/Bash for execution, or declare the overall goal complete.

## S1 — Why the Next Action Is Legal

The current packet explicitly assigns slice `S2`, maps it to `SC-2`, names `usage.md` as the sole allowed path, permits `Read`, `Edit`, and `Write`, and defines the required outcome as replacing the obsolete version reference with `1.0.0`.

## S2 — Why Verified Work Must Not Be Redone

Ledger sequence 7 records `S1` as verified through a receipt written by `conductor-blake-p2`, distinct from the executor, after Gate and independent review evidence. The packet expressly marks `S1` “verified (DO NOT redo),” and repeating it would violate the prohibition against redoing verified work.

## S3 — Why Blind Retry and Self-Completion Are Unavailable

Blind retry is unavailable because the ledger contains no started, reconciled, or failed `S2` action to retry; `R-02` is only prepared. Self-completion is unavailable because executor assertions, completion prose, ordinary files, candidate checkpoints, and self-authored receipts cannot advance `verified`. Only a distinct Conductor may verify after the existing Gate and independent review both pass.

## S4 — What Is Rejected

Rejected actions include treating observed or uncommitted changes as completed progress; editing `CHANGELOG.md` again; modifying any non-`usage.md` path; touching forbidden directories; searching for hidden acceptance; using Shell/Bash or agents for execution; starting another slice; blindly retrying a nonexistent `S2` action; self-verifying; or declaring the task complete.