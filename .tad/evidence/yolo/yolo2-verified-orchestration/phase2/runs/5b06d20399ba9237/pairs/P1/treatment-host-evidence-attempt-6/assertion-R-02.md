# Recovery Assertion

## H1 — Goal

- Complete R-02/S2 by appending a `## Worked Example` section with an example invocation block to `guide.md`, satisfying SC-2.
- Overall goal also includes the already-verified Command Reference table for `init`, `status`, and `verify`.

## H2 — Handoff Revision

- Handoff: `handoff.md` at revision `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3 — Verified

- S1/SC-1 is verified by the ledger through a Conductor-written receipt.
- `guide.md` contains the intro and the verified Command Reference table.
- S1 must not be redone.

## H4 — Unverified / In Progress

- S2/SC-2 remains unverified and incomplete.
- The current `guide.md` has no `## Worked Example` section or example invocation block.
- Journal evidence shows R-02 was prepared, but no R-02 action, reconciliation, closure, or verification occurred.
- `guide.md` is listed among uncommitted dirty paths; that observation is not evidence of S2 progress or completion.

## H5 — Pending Action

- Append only the required `## Worked Example` section and invocation block to `guide.md`.
- After the scoped edit, stop for Conductor-side gate, independent review, and verification receipt.

## H6 — Blockers

- The executor cannot advance S2 to verified status.
- Verification requires a distinct Conductor identity, a passing Gate, an independent review, and a bound receipt.
- No deterministic checks are declared; shell/Bash and Agent spawning are denied in strict Phase 2.

## H7 — Legal Next Action

- The next legal action is a single scoped Edit or Write to `guide.md` for S2, with no other file changes.
- Stop immediately on scope drift and do not declare completion.

## H8 — Non-goals / Forbidden Scope

- No work beyond the stated task.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start other slices, redo verified S1 work, treat dirty changes as done, search for hidden acceptance, or self-author verification.

## S1 — Why Next Action Is Legal

- The R-02/S2 contract explicitly authorizes `guide.md`, permits Read/Edit/Write, and defines the required Worked Example outcome mapped to SC-2.
- Appending that section stays within the allowed path and current slice.

## S2 — Why Verified Work Must Not Be Redone

- The packet explicitly marks S1 verified and says “DO NOT redo.”
- The journal records Conductor verification with a distinct executor and receipt, so the existing Command Reference is ledger-verified even though `guide.md` remains uncommitted.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- A checkpoint is only a candidate; verified status advances only through the required Conductor process.
- Executor prose, an ordinary file, a self-authored receipt, or a completion assertion cannot verify S2.
- R-02 has no failed or reconciled action to retry, and deterministic checks are absent.

## S4 — What Is Rejected

- Reject the claim that S2 or the full goal is complete: the Worked Example is absent.
- Reject treating the dirty `guide.md` state as S2 completion.
- Reject redoing S1, starting another slice, changing forbidden paths, blind retries, or self-authored verification.