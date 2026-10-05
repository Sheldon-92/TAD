# Recovery Assertion

## H1 — Goal

Append `## Command Reference` to `guide.md`, followed by a Markdown table with `command` and `purpose` columns and one row each for `init`, `status`, and `verify`, while preserving all existing content.

## H2 — Handoff Revision

The governed handoff revision is `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `b7dc7dd83fc92807310928cdf4adc2fb425b10f5`.

## H3 — Verified

No work is verified. No distinct-Conductor verification receipt exists in the ledger.

## H4 — Unverified / In Progress

Slice `S1` is prepared but has no recorded execution progress. The observed `guide.md` contains only its existing heading and intro paragraph; it does not contain the requested Command Reference section.

The ledger reports uncommitted prepare-time changes to `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These are observations only, lie outside the slice’s allowed path, and must not be treated as task progress or completion.

## H5 — Pending Action

Implement only slice `S1`: append the Command Reference section and table to `guide.md`, preserving the existing introduction exactly.

## H6 — Blockers

There is no recorded implementation failure or technical blocker. This recovery turn is restricted to assertion production and has no authority to perform the pending edit. Exact purpose wording is not supplied by the packet, although the required commands and table structure are supplied.

## H7 — Legal Next Action

In a properly authorized execution turn, make one scoped edit to `guide.md` implementing slice `S1`. Afterward, stop for independent Gate and Conductor review; do not declare the work verified or complete.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated Command Reference task is authorized. Do not start slice `S2` or add a Worked Example section. Do not modify any path other than `guide.md`, including `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. Do not inspect hidden acceptance, spawn agents, run shell-based task work, treat uncommitted changes as progress, or self-verify completion.

## S1 — Why the Next Action Is Legal

The current packet expressly selects slice `S1`, maps it to `SC-1`, permits `guide.md` as the sole allowed path, and defines the required outcome as the Command Reference table with `init`, `status`, and `verify`.

## S2 — Why Verified Work Must Not Be Redone

The packet forbids redoing verified work because verification is ledger-bound and can advance only through a receipt written by a distinct Conductor after Gate and independent-review passes. No work is currently verified, so there is nothing eligible for repetition.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The ledger records no prior execution attempt, failure, checkpoint, or rejection to retry. Uncommitted observations cannot establish progress. There are no deterministic checks declared, and executor prose or self-authored evidence cannot advance verification. Completion therefore requires an authorized initial edit followed by independent Conductor verification, not a blind retry or self-completion claim.

## S4 — What Is Rejected

Rejected actions include performing task work during this recovery assertion, editing anything outside `guide.md`, starting `S2`, altering the existing intro, touching forbidden directories, inspecting hidden acceptance, treating prepare-time dirty files as completed work, inventing verification, declaring success, or expanding scope beyond the current slice.