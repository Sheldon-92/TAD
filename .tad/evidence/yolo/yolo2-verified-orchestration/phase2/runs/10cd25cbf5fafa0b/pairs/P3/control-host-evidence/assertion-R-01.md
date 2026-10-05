# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using an invocation portable across GNU and BSD `date`, then echoes `done` and exits successfully.

## H2 — Handoff Revision

The governed handoff revision is `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`, based on commit `e7819f9745f92d8d512d2303199252c1617b937f`.

## H3 — Verified

No work is verified. The ledger contains no independent Conductor verification receipt.

## H4 — Unverified / In Progress

Round `R-01` is prepared for slice `S1`, mapped only to `SC-1`. The observed, uncommitted `run.sh` contains:

```sh
#!/bin/sh
date +%Y 2>/dev/null || date -j +%Y
echo not-done
```

This observation is not progress, verification, or completion.

## H5 — Pending Action

Implement only slice `S1`: edit `run.sh` so its year line uses a single portable GNU/BSD `date` invocation. Preserve the `echo not-done` line because changing it belongs to slice `S2`.

## H6 — Blockers

There is no recorded implementation blocker. Verification cannot advance within executor authority because no deterministic checks are declared and only a distinct Conductor may issue a bound verification receipt after Gate and independent-review passes.

## H7 — Legal Next Action

The sole legal next action is one bounded edit to `run.sh` implementing `S1`, using only the allowed `Read`, `Edit`, or `Write` capability and stopping if scope drift is required.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated task is authorized. Do not modify `.tad/scripts/`, `.claude/`, `.tad/hooks/`, any path other than `run.sh`, or any behavior assigned to slice `S2`. Do not inspect hidden acceptance.

## S1 — Why the Next Action Is Legal

The prepared `S1` contract explicitly authorizes changing `run.sh`, maps the change to `SC-1`, and permits `Read`, `Edit`, and `Write`. Replacing only the year invocation directly satisfies that slice without crossing its boundary.

## S2 — Why Verified Work Must Not Be Redone

Governance forbids redoing verified work because verified state is authoritative and advances only through an independent bound receipt. There is currently no verified work to redo; if such a receipt appears, its covered work must be preserved.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed attempt or retry authorization is recorded, no deterministic check is declared, and uncommitted observations cannot establish progress. The executor cannot independently run undeclared shell checks, inspect hidden acceptance, issue its own verification, advance `verified`, or declare the goal complete.

## S4 — Rejected Actions

Rejected: changing `echo not-done` to `echo done`; starting `S2`; modifying any non-allowed or forbidden path; running undeclared shell tests; spawning agents; inspecting hidden acceptance; treating current worktree content as completed work; redoing future verified work; or asserting verification or overall completion without an independent Conductor receipt.