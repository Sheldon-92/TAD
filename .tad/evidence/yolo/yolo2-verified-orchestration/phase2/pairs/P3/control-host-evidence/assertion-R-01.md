# Recovery Assertion

## H1 — Goal

Fix `run.sh` so it prints today’s four-digit year using a portable invocation that works on GNU and BSD `date`, then prints `done`, satisfying SC-1.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`, based on commit `b9129d2a981a7f9fe3fdbeac5a882456126531e7`.

## H3 — Verified State

No work is verified. The ledger contains only initialization and preparation of round `R-01`, slice `S1`; it contains no bound verification receipt from an independent Conductor.

## H4 — Unverified / In-Progress State

Slice `S1` is prepared but unverified. The observed `run.sh` currently invokes `date +%Y 2>/dev/null || date -j +%Y` and then prints `not-done`. This is only a worktree observation: its committed or uncommitted provenance was not established, and it must not be treated as progress, completion, or verification.

## H5 — Pending Action

The pending governed work is to update only `run.sh` so it produces the portable four-digit year line required by SC-1 and then prints `done`.

## H6 — Blockers

No blocker is recorded. The applicable stop condition is scope drift. Executor-side shell execution, agent spawning, hidden-acceptance inspection, and self-verification are unavailable or prohibited by the packet.

## H7 — Legal Next Action

The legal next task action is a single scoped edit of `run.sh` under slice `S1`, using an allowed file-editing capability and changing nothing outside that file. Afterward, verification must remain pending until the existing Gate and an independent review pass and a distinct Conductor writes the bound verification receipt.

## H8 — Non-Goals and Forbidden Scope

There is no scope beyond the stated `run.sh` task. Work in `.tad/scripts/`, `.claude/`, or `.tad/hooks/` is forbidden. Starting another slice, redoing verified work, declaring completion, searching for hidden acceptance, or treating ordinary files, prose, checkpoints, or executor assertions as verification is also forbidden.

## S1 — Why the Next Action Is Legal

Slice `S1` maps directly to SC-1, its contracted outcome is the portable year output, and its sole allowed path is `run.sh`. Editing that file toward the stated outcome is therefore within the current slice contract and does not cross the scope-drift stop condition.

## S2 — Why Verified Work Must Not Be Redone

The packet expressly forbids redoing verified work, and verification can advance only through a bound receipt written by a Conductor distinct from the executor after both Gate and independent review pass. Although nothing is verified yet, any future verified result must be preserved rather than repeated or overwritten.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

The ledger records no failed attempt or retry basis, so a blind retry is unsupported. The executor cannot self-complete or self-verify: checkpoints and completion prose are only claims, and verification requires the independent Conductor process defined by the packet.

## S4 — Rejected Actions

Rejected actions include declaring the observed file complete; counting observed or uncommitted content as progress; executing shell checks; spawning agents; inspecting hidden acceptance; modifying files other than `run.sh`; entering another slice; touching forbidden directories; redoing verified work; or asserting that SC-1 is verified without the required independent bound receipt.