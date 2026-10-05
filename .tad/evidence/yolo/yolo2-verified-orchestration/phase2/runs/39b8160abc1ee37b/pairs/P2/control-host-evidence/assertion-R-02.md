# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting named function `stableSlug(s)` with ASCII lowercasing, trimming, non-alphanumeric run replacement by `-`, and leading/trailing dash removal. Add `tests.mjs` using `node:assert` with at least three cases, including the empty string.

## H2 — Handoff Revision

Authorized handoff: `handoff.md` at revision `c2500f027b2e1923b60d99ab3619171e6cf4d69c36109657f4dd60fc7b5a3613`, based on commit `89901004e1b629dd2355955c2300d138ce342899`.

## H3 — Verified

Slice `S1`, mapping to `SC-1`, is verified and must not be redone. Ledger sequence 7 records a bound receipt written by `conductor-blake-p2`, distinct from the executor, with Gate and independent-review evidence.

## H4 — Unverified / In Progress

Round `R-02` is prepared for slice `S2`, mapping only to `SC-2`. The sole authorized target is `tests.mjs`, which direct observation shows is currently empty. Its empty or subsequently uncommitted state is observation only, not progress or completion. The journal also records verified `util.mjs` as an uncommitted dirty path; that does not invalidate its bound `S1` verification or authorize rework.

## H5 — Pending Action

Implement only slice `S2`: populate `tests.mjs` with at least three `node:assert` assertions covering `stableSlug`, including an empty-string case, such that the file passes under Node.

## H6 — Blockers

No execution blocker is recorded. No deterministic checks are declared for this slice. Verification remains unavailable to the executor and requires a distinct Conductor’s bound receipt after the existing Gate and independent review both pass.

## H7 — Legal Next Action

The sole legal next execution action is to edit or write `tests.mjs` to satisfy the `S2` contract, then stop for Conductor-side review and verification. `util.mjs` and every other path are outside this slice’s allowed paths.

## H8 — Non-Goals / Forbidden Scope

No scope beyond the stated task is authorized. Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`. Do not redo `S1` or alter `util.mjs`. Do not inspect hidden acceptance, begin another slice, declare completion, or treat a checkpoint, ordinary file, executor assertion, or uncommitted observation as verification.

## S1 — Why the Next Action Is Legal

The R-02 packet explicitly designates `S2`, maps it to `SC-2`, permits `Read`, `Edit`, and `Write`, and restricts allowed paths to `tests.mjs`. Adding the required assertions there is exactly the contracted action.

## S2 — Why Verified Work Must Not Be Redone

`S1` has a ledger-recorded verification receipt backed by Gate and independent-review evidence and written by an identity distinct from the executor. The packet explicitly says “DO NOT redo”; its uncommitted worktree presence is captured by the receipt and does not reopen the slice.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No failed `S2` attempt, Gate failure, or retry authorization is recorded, so blind retry has no lawful basis. The executor cannot self-verify or declare completion because verified state advances only through the required distinct-Conductor receipt after Gate and independent-review passage.

## S4 — Rejected

Rejected actions include editing `util.mjs`; redoing `S1`; modifying any path other than `tests.mjs`; entering forbidden directories; starting another slice; searching for hidden acceptance; running undeclared shell checks as proof; treating uncommitted changes as done; issuing self-verification; declaring the goal complete; and performing work beyond the `S2` contract.