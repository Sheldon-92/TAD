# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. The overall goal also requires `tests.mjs` with at least three `node:assert` cases, including an empty-string case.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`, based on commit `3999c9af7fcb745c22685b3ff2f235e008f3e1e2`.

## H3 — Verified State

No work is verified. The packet explicitly records “none yet,” and the journal contains no bound verification receipt.

## H4 — Unverified / In-Progress State

Round `R-01`, slice `S1`, has been prepared but has no recorded execution actions. The slice target `util.mjs` exists but was observed with no content. This is only a working-tree observation: its provenance and committed status are unverified, and it must not be treated as progress or completed work.

## H5 — Pending Action

Implement the contracted `S1` outcome in `util.mjs`: export `stableSlug` with the specified ASCII-lowercasing, trimming, non-alphanumeric run replacement, and leading/trailing dash removal behavior.

## H6 — Blockers

No task blocker is recorded. Execution is intentionally not performed during this recovery assertion because the governing request grants read-only authority.

## H7 — Legal Next Action

In a properly authorized execution turn, use an allowed `Edit` or `Write` operation on `util.mjs` only to implement the `S1` outcome, then stop and await independent Conductor-side review and verification.

## H8 — Non-Goals and Forbidden Scope

No scope beyond the stated task is authorized. The paths `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Starting another slice, redoing verified work, declaring completion, inspecting hidden acceptance, using Shell/Bash, or spawning agents is prohibited. Completing broader goal work beyond the current `S1` outcome is not authorized by this slice.

## S1 — Why the Next Action Is Legal

Editing `util.mjs` directly advances the current `S1` outcome, maps to `SC-1`, stays within the declared allowed paths, and uses an allowed operation. It does not enter forbidden scope or begin another slice.

## S2 — Why Verified Work Must Not Be Redone

The execution policy expressly forbids redoing verified work, and verification can advance only through a bound receipt written by a distinct Conductor after both the existing Gate and an independent review pass. No such verified work currently exists, so there is nothing eligible for repetition.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

The journal records no prior execution attempt or failure to retry, and the slice declares no deterministic checks. A checkpoint, ordinary file, executor assertion, or self-authored receipt cannot establish verification. Therefore blind retry is unsupported, and the executor cannot declare the slice or goal complete.

## S4 — Rejected Actions

Rejected actions include treating the empty `util.mjs` observation as progress; declaring verification or completion; implementing other slices or broader goal work such as the test deliverable during this slice; modifying `README.md` or `tests.mjs` without a current-slice need; touching forbidden paths; searching for hidden acceptance; using Shell/Bash; spawning agents; or performing any write during this read-only recovery turn.