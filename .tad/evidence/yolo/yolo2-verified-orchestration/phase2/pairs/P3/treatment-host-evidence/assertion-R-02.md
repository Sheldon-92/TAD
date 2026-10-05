# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s year using a portable GNU/BSD `date` invocation, then echoes `done`, satisfying SC-1.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`, based on commit `1d59790001d58734759e0755fd0d087c2b51ba30`.

## H3 — Verified State

Slice S1 is verified by journal sequence 7 with a Conductor-authored receipt whose `written_by_id` differs from its `executor_id`. S1 must not be repeated. Its portable year-printing work is immutable for this recovery.

## H4 — Unverified / In-Progress State

Round R-02 has prepared slice S2, but no S2 verification receipt exists. The permitted slice target currently reads:

```sh
#!/bin/sh
date '+%Y'
echo done
```

The observed `echo done` is an uncommitted worktree observation only. It is not verified progress, proof of completion, or authority to declare S2 complete.

## H5 — Pending Action

The pending work is exclusively S2: govern and reconcile the `run.sh` state so it ends by echoing `done` and exits successfully, then stop for the independent Gate, review, and Conductor verification process.

## H6 — Blockers

There is no stated blocker to the bounded S2 action. There are no deterministic executor-side checks. Shell execution and agent spawning are denied, hidden acceptance is unavailable, and the executor cannot independently advance `verified`.

## H7 — Legal Next Action

The only legal next action is a governed S2 action limited to `run.sh`, using an allowed `Read`, `Edit`, or `Write` operation and respecting the observed pre-state. If the intended S2 bytes are already present, they must be reconciled through governance rather than blindly rewritten or treated as verified.

## H8 — Non-Goals / Forbidden Scope

No work beyond S2 or the stated goal is authorized. Redoing S1, starting another slice, modifying any path other than `run.sh`, inspecting hidden acceptance, or declaring overall completion is forbidden. The explicitly forbidden paths are `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.

## S1 — Why the Next Action Is Legal

It directly implements the current S2 contract, maps to SC-1, affects only the sole allowed path `run.sh`, and uses only the packet-authorized operation classes.

## S2 — Why Verified Work Must Not Be Redone

S1 already has a bound verification receipt written by an identity distinct from its executor after Gate and independent review evidence. The packet expressly marks S1 “verified (DO NOT redo),” and repeating it would violate the zero-tolerance repeated-verified-action policy.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The current worktree content is observation only, and the ledger contains no S2 verification receipt. A blind retry could overwrite or duplicate uncommitted state, while executor prose, a candidate checkpoint, an ordinary file, or a self-authored receipt cannot advance `verified`. Only an independent Conductor receipt after Gate and review can verify S2.

## S4 — Rejected Actions

Rejected actions include re-editing the portable `date` line as S1 work; blindly rewriting `echo done`; treating current bytes as verified; running shell checks; spawning agents; seeking hidden acceptance; touching files outside `run.sh` or any forbidden path; starting another slice; creating a self-verification receipt; and declaring S2 or the overall goal complete.