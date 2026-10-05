# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. The overall goal also requires `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `f9a25d7dcf27bffffda247489dc2d815faa36dda`.

## H3 — Verified State

No work is verified. The ledger contains only initialization and preparation of round `R-01`, slice `S1`; it contains no bound verification receipt.

## H4 — Unverified / In-Progress State

Slice `S1` is prepared but unverified. Its required outcome is that `util.mjs` exports `stableSlug` with the specified lowercase, trim, and dash-collapse behavior, accepted by direct inspection.

The current `util.mjs` target was observed to exist with no content. This is only a filesystem observation; its commit status was not established, and it must not be treated as progress, completion, or verified work.

## H5 — Pending Action

Implement the `S1` contract in `util.mjs` so that it exports the required `stableSlug` function. No deterministic check is declared for this slice.

## H6 — Blockers

No blocker is recorded. The empty target file is pending implementation, not a blocker.

## H7 — Legal Next Action

The only legal next execution action is to use an allowed editing operation on `util.mjs` to implement the current `S1` outcome, remaining within the allowed paths and stopping if scope drift occurs.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Starting another slice, redoing verified work, declaring completion, searching for hidden acceptance, using Shell/Bash, or spawning agents is forbidden. Work on broader goal elements not required by the current `S1` outcome must wait for an authorized slice.

## S1 — Why the Next Action Is Legal

Editing `util.mjs` directly advances the explicit `S1` outcome, maps to `SC-1`, stays within the declared allowed paths, and uses the slice-authorized `Edit` or `Write` capability.

## S2 — Why Verified Work Must Not Be Redone

The execution policy forbids redoing verified work because verification is ledger-controlled and advances only through a bound receipt written by a distinct Conductor after Gate and independent-review passes. There is currently no verified work to redo; none may be invented from the target file or completion prose.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The journal records no failed attempt or authorized retry, only initialization and preparation of `R-01/S1`. Therefore no retry basis exists. The executor also cannot self-verify or self-complete: checkpoints and assertions are only candidates, while verified status requires the distinct-Conductor receipt process.

## S4 — What Is Rejected

Rejected are treating the empty or otherwise uncommitted target state as progress; claiming `S1`, `SC-1`, or the goal complete; performing tests or other future-slice work without a governing contract; using Shell/Bash or agents for execution; modifying forbidden or out-of-scope paths; searching for hidden acceptance; and repeating work based on an unsupported blind retry.