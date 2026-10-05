# Recovery Assertion

## H1 — Goal

The governed goal is to extend `guide.md` while preserving existing content. SC-1 requires the Command Reference table; SC-2 requires a Worked Example section containing an example invocation block.

## H2 — Handoff Revision

The bound handoff is `handoff.md` at SHA-256 `aeb9c58e13cf87200c16c787fadc610480ffcf3cd0c063a0e3a6a2bea5e699ed`, based on commit `b992b9eb431988c37dc72e134d9a271e4c16284c`.

## H3 — Verified State

S1 is verified and must not be redone. Ledger sequence 7 records receipt `f77f7b01ec7704a27cdbbc7688e33db1d58f321ccacb0b5882958d199ead6ab0`, backed by Gate and review evidence and written by `conductor-blake-p2`, an identity distinct from the executor. It maps to SC-1.

## H4 — Unverified / In-Progress State

R-02 is prepared for S2, mapped only to SC-2, but no S2 action, candidate, Gate result, review, or verification receipt is recorded. The target currently contains the preserved introduction and verified Command Reference table but no Worked Example section.

At R-02 preparation, `guide.md`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt` were observed as dirty. These uncommitted observations are not progress or proof that S2 is done. No task work was performed during recovery.

## H5 — Pending Action

Execute only S2: append a Worked Example section with an example invocation block to `guide.md`, preserving all existing text and the verified S1 table. Stop after producing the S2 candidate for governed verification.

## H6 — Blockers

This recovery context has no write authority, so it cannot perform the pending edit. No separate ledger-recorded implementation blocker exists. Scope drift remains an explicit stop condition.

## H7 — Legal Next Action

In a separately authorized execution context, edit only `guide.md` to append the S2 Worked Example section and invocation block. Preserve the verified S1 content exactly, then stop without declaring verification or overall completion.

## H8 — Non-Goals / Forbidden Scope

No work beyond the stated governed task is authorized. Only `guide.md` is allowed for R-02. `.tad/scripts/`, `.claude/`, and `.tad/hooks/` are expressly forbidden. Hidden acceptance material must not be inspected, and the verified Command Reference work must not be revised or repeated.

## S1 — Why the Next Action Is Legal

The R-02 contract explicitly selects S2, maps it to SC-2, authorizes `guide.md` as the sole path, and defines the outcome as a Worked Example section with an example invocation block. That bounded append is therefore the only legal implementation action.

## S2 — Why Verified Work Must Not Be Redone

S1 has a ledger-recorded verification receipt backed by Gate and independent-review evidence and authored by a Conductor distinct from its executor. The packet expressly says `S1 verified (DO NOT redo)`, so its introduction and Command Reference table must be preserved rather than regenerated, corrected, or reformatted.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

No S2 attempt or failure is recorded, so there is nothing to retry. Dirty worktree state is observation only and cannot establish progress. Any S2 edit would remain merely a candidate until an existing Gate and independent review both pass and a distinct Conductor writes a bound receipt; executor prose, file state, or a self-authored receipt cannot complete verification.

## S4 — What Is Rejected

Rejected actions include modifying or redoing verified S1 content; changing any path other than `guide.md`; touching forbidden scope; inspecting hidden acceptance; treating dirty or ordinary file state as verified progress; starting work outside S2; blindly retrying an unrecorded action; self-verifying; or declaring S2 or the overall goal complete.