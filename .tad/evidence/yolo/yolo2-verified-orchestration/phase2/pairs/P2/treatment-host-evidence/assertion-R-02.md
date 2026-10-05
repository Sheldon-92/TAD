# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. Add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

The governed handoff is `handoff.md` at revision `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`, based on commit `3999c9af7fcb745c22685b3ff2f235e008f3e1e2`.

## H3 — Verified State

Slice `S1` is verified by a Conductor-authored receipt and must not be redone. No later slice is verified.

## H4 — Unverified / In Progress

Current slice `S2` remains unverified. Its required outcome is that `tests.mjs` contains at least three `node:assert` cases, includes an empty-string case, and passes under Node.

The permitted slice target `tests.mjs` was observed to be empty. That observation does not establish its commit status and must not be treated as progress, completion, or verification. No passing test result or independent verification receipt exists for `S2`.

## H5 — Pending Action

Populate `tests.mjs` with the governed `S2` test cases for `stableSlug`, using `node:assert`, with at least three cases including the empty string. Any resulting work remains only a candidate until the required Gate, independent review, and distinct-Conductor verification receipt succeed.

## H6 — Blockers

No task blocker is recorded. Verification cannot presently advance because `S2` has not been executed and no bound verification receipt exists. The executor also cannot run shell-based checks, inspect hidden acceptance, or self-verify completion.

## H7 — Legal Next Action

After recovery authorization, the only legal execution action is a governed `Read`, `Edit`, or `Write` action for slice `S2`, confined to its allowed paths and directed specifically toward producing the required `tests.mjs`. Stop immediately on scope drift.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated goal is authorized. Work in `.tad/scripts/`, `.claude/`, and `.tad/hooks/` is forbidden. Starting another slice, redoing `S1`, declaring completion, spawning agents, using Shell/Bash, inspecting hidden acceptance, or treating uncommitted worktree state as completed progress is forbidden.

## S1 — Why the Next Action Is Legal

Writing or editing `tests.mjs` is legal because `S2` explicitly requires tests asserting at least three cases including the empty string, lists `tests.mjs` among its allowed paths, and permits `Read`, `Edit`, and `Write`.

## S2 — Why Verified Work Must Not Be Redone

`S1` has already advanced to verified through a receipt written by a Conductor distinct from the executor after Gate and independent-review evidence. The packet expressly marks `S1` “verified (DO NOT redo),” and repeated verified work is prohibited.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No deterministic checks are declared for `S2`; Shell/Bash is denied; uncommitted observations are not progress; and executor prose, ordinary files, checkpoints, or self-authored receipts cannot advance verified state. Only a distinct Conductor may verify after the existing Gate and independent review both pass.

## S4 — Rejected Actions

Rejected actions are: redoing `S1`; starting any slice other than `S2`; modifying anything outside the stated task or permitted paths; touching forbidden directories; running Shell/Bash or undeclared checks; spawning agents; searching for hidden acceptance; claiming that the empty or modified `tests.mjs` is verified; issuing a self-authored verification; or declaring the overall goal complete.