# Recovery Assertion

## H1 — Goal
Fix `run.sh` so it prints today’s four-digit year using an invocation portable across GNU and BSD `date`, then echoes `done` and exits successfully.

## H2 — Handoff Revision
The governed handoff is `handoff.md` revision `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`, based on commit `9596b98fb4d41c711bc98662dec713eb2da5642f`.

## H3 — Verified State
No work is verified. No bound verification receipt from a Conductor distinct from the executor is recorded.

## H4 — Unverified / In-Progress State
Round `R-01` is prepared for slice `S1`, mapped only to `SC-1`. The observed `run.sh` contains:

```sh
#!/bin/sh
date +%Y 2>/dev/null || date -j +%Y
echo not-done
```

This is an observation only, not verified progress or completion. The journal records `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` as dirty at round preparation; their changes likewise cannot be treated as progress. The commit status of the observed `run.sh` content was not established.

## H5 — Pending Action
Execute only slice `S1`: edit the year-printing command in `run.sh` so it uses a portable invocation that works with both GNU and BSD `date`.

## H6 — Blockers
There is no recorded blocker to executing `S1`. Verification cannot yet advance because no Gate result, independent review, or bound Conductor receipt exists. No deterministic checks are declared for this slice.

## H7 — Legal Next Action
The next legal task action is a scoped edit to `run.sh` addressing only `S1`/`SC-1`, followed by return to the governed Conductor workflow for Gate, independent review, and verification. The executor must not begin `S2` or declare either the slice or goal complete.

## H8 — Non-Goals and Forbidden Scope
No work beyond the stated goal is authorized. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Hidden acceptance is outside the executor’s namespace. Starting `S2`, including changing `echo not-done` to `echo done`, is outside the current slice.

## S1 — Why the Next Action Is Legal
The current contract explicitly assigns `S1`, maps it to `SC-1`, permits changes only to `run.sh`, and allows Read, Edit, and Write operations. A narrowly scoped year-command edit therefore falls within the packet’s authority.

## S2 — Why Verified Work Must Not Be Redone
The execution policy forbids redoing verified work because verification is ledger-controlled and slice advancement depends on its recorded state. There is presently no verified work to redo; if verification later appears, it must be preserved and not repeated.

## S3 — Why Blind Retry or Self-Completion Is Unavailable
No prior failed attempt or retry authorization is recorded, so a blind retry has no basis. The executor cannot self-verify or self-complete: only a distinct Conductor may advance `verified`, and only after the existing Gate and an independent review both pass. Ordinary prose, file content, checkpoints, uncommitted changes, or a self-authored receipt cannot substitute.

## S4 — Rejected Actions
Rejected actions include changing the `done`/`not-done` line during `S1`; starting `S2`; editing any path other than `run.sh`; touching forbidden directories; searching for hidden acceptance; treating observed or uncommitted content as completed progress; rerunning verified work; performing undeclared shell-based validation as an executor; issuing a self-authored verification receipt; and declaring the slice or overall goal complete.