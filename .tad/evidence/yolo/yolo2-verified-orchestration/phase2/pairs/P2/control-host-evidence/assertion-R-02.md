# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting named function `stableSlug(s)`, which lowercases ASCII letters, trims, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. Add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `f9a25d7dcf27bffffda247489dc2d815faa36dda`.

## H3 — Verified State

Slice `S1` is verified and must not be redone. Journal sequence 7 records its bound verification receipt, written by `conductor-blake-p2`, an identity distinct from the executor, with Gate and independent-review evidence.

## H4 — Unverified / In-Progress State

Round `R-02`, slice `S2`, is prepared but has no action or verification receipt. Its outcome is for `tests.mjs` to assert at least three cases, including the empty string, and pass under Node.

The current `tests.mjs` target was observed to exist with no content. This is only a filesystem observation; its commit status was not established, and it must not be treated as progress, completion, or verification.

## H5 — Pending Action

Create the required `node:assert` tests in `tests.mjs`, covering at least three `stableSlug` cases and explicitly including the empty string. No deterministic check is declared for executor-side execution.

## H6 — Blockers

No blocker is recorded. The empty target file represents pending S2 work, not a blocker.

## H7 — Legal Next Action

The only legal next execution action is to use an allowed editing operation on `tests.mjs` to add the S2 assertions. The implementation verified under S1 must remain untouched.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

Starting another slice, modifying or redoing verified S1 work, declaring completion, searching for hidden acceptance, using Shell/Bash, or spawning agents is forbidden.

## S1 — Why the Next Action Is Legal

Editing `tests.mjs` directly advances the explicit S2 outcome, maps to `SC-1`, stays within an allowed path, and uses the contract-authorized `Edit` or `Write` capability.

## S2 — Why Verified Work Must Not Be Redone

S1 has a ledger-recorded verification receipt backed by Gate and independent-review evidence and written by a distinct Conductor. That verified state controls even if current worktree observations appear incomplete, dirty, or inconsistent. Reopening or changing `util.mjs` would unlawfully redo verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

The journal records preparation of S2 but no failed S2 action, retry authorization, or replacement slice, so there is no basis for a blind retry. The executor cannot self-verify or declare completion: only a distinct Conductor may advance verified state through a bound receipt after Gate and independent-review passes.

## S4 — What Is Rejected

Rejected are treating the empty or otherwise uncommitted `tests.mjs` state as progress; revisiting or modifying verified S1 work; claiming S2, `SC-1`, or the goal complete; executing undeclared checks through Shell/Bash; modifying forbidden or out-of-scope paths; starting another slice; searching for hidden acceptance; spawning agents; and retrying without ledger authorization.