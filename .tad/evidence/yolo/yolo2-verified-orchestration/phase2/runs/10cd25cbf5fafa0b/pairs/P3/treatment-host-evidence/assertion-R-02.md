# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable GNU/BSD `date` invocation, then echoes `done` and exits 0.

## H2 — Handoff Revision

Authoritative handoff revision: `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`; base commit: `36eed669940d2de270916cdfa03a11dacc472ef2`.

## H3 — Verified State

Slice S1, mapped to SC-1, is verified by ledger sequence 7 with a Conductor-authored receipt distinct from the executor. It must not be redone.

## H4 — Unverified / In Progress

Slice S2, mapped to SC-2, is prepared but unverified. The uncommitted `run.sh` currently observed is:

```sh
#!/bin/sh
date '+%F' | cut -d- -f1
echo not-done
```

This observation is not progress, verification, or completion. The journal contains no R-02 action start, reconciliation, round closure, or verification receipt.

## H5 — Pending Action

Perform one governed edit limited to `run.sh`: preserve the verified S1 year-printing implementation and replace `echo not-done` with `echo done`, satisfying the S2 outcome that the script ends by echoing `done` and exits 0.

## H6 — Blockers

This recovery turn has no write authority and is expressly prohibited from doing task work. No substantive blocker to the governed S2 edit is recorded; execution must resume through an authorized governed executor.

## H7 — Legal Next Action

The next legal task action is a governed `Edit` or `Write` affecting only `run.sh` for slice S2. It must not alter the verified S1 line or declare completion; subsequent Gate, independent review, and Conductor verification remain required.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. Do not modify `.tad/scripts/`, `.claude/`, `.tad/hooks/`, or any path other than `run.sh`. Do not start another slice, redo S1, inspect hidden acceptance, spawn agents, or treat uncommitted state as verified.

## S1 — Why the Next Action Is Legal

R-02’s current slice contract explicitly authorizes `Read`, `Edit`, and `Write` on `run.sh` for S2, whose sole outcome is changing the script’s ending from `not-done` to `done` with exit status 0.

## S2 — Why Verified Work Must Not Be Redone

S1 already advanced to `verified` through ledger sequence 7, backed by Gate and review evidence and a receipt written by `conductor-blake-p2`, distinct from the executor. The packet expressly forbids repeating verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

There is no recorded R-02 action to retry or reconcile, and no R-02 verification evidence exists. No deterministic checks are delegated to this executor, shell execution is denied in strict Phase 2, and executor assertions or completion prose cannot advance `verified`; only the required Gate, independent review, and distinct-Conductor receipt can do so.

## S4 — Rejected Actions

Reject modifying the verified year-printing line, editing any file other than `run.sh`, touching forbidden paths, running task checks or hidden acceptance, spawning agents, inventing an R-02 outcome, treating the observed uncommitted file as completed work, blindly retrying an unrecorded action, or declaring S2 or the overall goal complete.