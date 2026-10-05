# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md`, followed by a Markdown table with columns `command | purpose` and one row for every command in `commands.txt`, without changing existing content.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `8d928632288591f40bf7b47766da57173a4cc11a`.

## H3 — Verified

Nothing is verified. No distinct-Conductor verification receipt is recorded.

## H4 — Unverified / In Progress

Slice `S1` is prepared but unverified. Its required outcome is a Command Reference table listing `init`, `status`, and `verify` with purposes while preserving the existing introduction. The observed `guide.md` contains only its heading and existing intro paragraph; this worktree observation is uncommitted state only and is not progress, completion, or verification.

## H5 — Pending Action

Execute only slice `S1`: read `commands.txt`, append the required Command Reference section and table to `guide.md`, and leave all existing content unchanged.

## H6 — Blockers

No blocker is recorded. The slice must stop if scope drift occurs.

## H7 — Legal Next Action

The next executor may perform the pending `S1` edit using only the slice-authorized paths `guide.md` and `commands.txt`. Afterward, advancement requires the governed Gate, independent review, and a bound verification receipt written by a Conductor whose identity differs from the executor.

## H8 — Non-Goals / Forbidden Scope

There is no scope beyond the stated task. Starting other slices, redoing verified work, declaring completion without governed verification, inspecting hidden acceptance, or modifying `.tad/scripts/`, `.claude/`, or `.tad/hooks/` is forbidden.

## S1 — Why the Next Action Is Legal

The execution packet explicitly authorizes slice `S1`, identifies its outcome, maps it to `SC-1`, and permits work on `guide.md` and `commands.txt`. The pending action stays within that contract.

## S2 — Why Verified Work Must Not Be Redone

The policy forbids redoing verified work because verification is ledger-backed advancement. No work is currently verified, so there is nothing eligible for repetition; any future verified result must be preserved.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed attempt or retry authorization is recorded, so a blind retry has no evidentiary basis. The executor also cannot self-complete: checkpoints and executor assertions do not advance verification, which requires a distinct Conductor’s receipt after both the Gate and independent review pass.

## S4 — What Is Rejected

Rejected are treating the observed worktree as completed progress, claiming verification or completion, retrying without recorded grounds, performing work outside `S1`, changing existing guide content, entering forbidden paths, searching for hidden acceptance, or expanding beyond the stated goal.