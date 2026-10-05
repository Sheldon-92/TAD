# Recovery Assertion

## H1 — Goal

Append the required documentation to `guide.md` without changing existing content. Success requires both the Command Reference table in SC-1 and the Worked Example invocation block in SC-2.

## H2 — Handoff Revision

The governing handoff revision is `ccb7c18b8e182b508393fbfc4cb509e77c5f3a8a262d6bb35823437840d516b2`, based on commit `d488e5bfa1b61708ca4a2bf19200dbb0e1d1ab7c`.

## H3 — Verified State

Slice S1, mapped to SC-1, is verified and must not be redone. Journal sequence 7 records a Conductor-authored verification receipt distinct from the executor, with Gate and review evidence.

## H4 — Unverified / In-Progress State

Slice S2, mapped to SC-2, is not verified and has no recorded started action. The uncommitted `guide.md` currently contains the verified S1 Command Reference table and does not contain a Worked Example section. These worktree observations do not independently establish progress or completion.

## H5 — Pending Action

The pending governed action is S2: append a Worked Example section containing an example invocation block to `guide.md`, while preserving all existing content.

## H6 — Blockers

No blocker is recorded. The round must stop if completing S2 would require scope drift.

## H7 — Legal Next Action

The only legal next task action is the governed S2 edit of `guide.md` under round R-02, using an allowed Read, Edit, or Write operation. Afterward, verification must remain Conductor-side under the stated Gate and independent-review model.

## H8 — Non-Goals and Forbidden Scope

No work beyond the stated task is authorized. Changes to `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are forbidden. Starting another slice, redoing S1, inspecting hidden acceptance, or declaring the overall goal complete is also forbidden.

## S1 — Why the Next Action Is Legal

R-02 explicitly assigns S2, maps it to SC-2, permits changes only to `guide.md`, and authorizes the necessary file-operation classes. Appending the Worked Example invocation block directly satisfies that slice contract without expanding scope.

## S2 — Why Verified Work Must Not Be Redone

S1 already has a bound verification receipt written by `conductor-blake-p2`, whose identity differs from the executor. The packet explicitly marks S1 “verified (DO NOT redo),” and the prohibitions disallow repeating verified work.

## S3 — Why Blind Retry or Self-Completion Is Unavailable

There is no recorded R-02 action to retry, so retrying an assumed edit would be blind. Uncommitted file contents are observation only. The executor cannot self-verify or self-complete: verified state advances only through a distinct Conductor’s receipt after Gate and independent review pass.

## S4 — Rejected Actions

Rejected actions include modifying anything other than `guide.md`; altering existing content; rebuilding or editing the verified Command Reference table; starting any slice other than S2; touching forbidden paths; searching for hidden acceptance; treating current uncommitted contents as proof that S2 is done; retrying an unrecorded action; or declaring verification or goal completion.