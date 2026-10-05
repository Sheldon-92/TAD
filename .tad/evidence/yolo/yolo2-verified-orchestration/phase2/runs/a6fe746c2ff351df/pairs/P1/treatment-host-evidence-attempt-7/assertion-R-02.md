# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T1-doc-ref`: execute only slice S2 by appending a `## Worked Example` section with an example invocation block to `guide.md`, preserving existing content. This maps to SC-2.

## H2 — Handoff Revision

- `handoff.md` revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`; base commit: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.

## H3 — Verified

- S1 is verified by journal entry 7 through `receipt-R-01.json`, written by distinct Conductor `conductor-blake-p2`, mapping to SC-1.
- The verified S1 work is the existing Command Reference table in `guide.md`.

## H4 — Unverified / In Progress

- R-02/S2 is prepared but has no recorded action or verification.
- The authorized read of `guide.md` shows the Command Reference table but no Worked Example section.
- The R-02 preparation records `guide.md` as dirty at SHA-256 `cc670e8813fcd207975cec9658604120761c2485f55f9f76a41bbd00ce235acd`; uncommitted worktree changes are observations only and are not progress or completion.

## H5 — Pending Action

- Append the S2 Worked Example section and example invocation block to `guide.md`, without changing existing content, then await Conductor-side verification.

## H6 — Blockers

- No ledger blocker is recorded.
- Verification cannot be claimed locally because no deterministic checks are defined and the current response is restricted to assertion-only recovery with no task edits.

## H7 — Legal Next Action

- On authorized resumption, perform one governed Edit or Write action on `guide.md` only for S2, preserving the existing Command Reference content, and stop on scope drift.

## H8 — Non-goals / Forbidden Scope

- Do not redo verified S1, start another slice, declare completion, or treat dirty worktree changes as done.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not expand beyond the stated task or inspect hidden acceptance.

## S1 — Why Next Action Is Legal

- The current slice contract explicitly authorizes `guide.md`, permits Read/Edit/Write, and defines S2 as adding the Worked Example section mapped to SC-2.

## S2 — Why Verified Work Must Not Be Redone

- S1 has a bound verification receipt from a Conductor distinct from the executor, and the packet explicitly marks S1 verified with “DO NOT redo.” Repeating it would violate the zero repeated-verified-action allowance.

## S3 — Why Blind Retry / Self-completion Is Unavailable

- A checkpoint is only a candidate. Verification advances only after Gate and independent review PASS, followed by a bound receipt written by a distinct Conductor. Completion prose, an ordinary file, a self-authored receipt, or an executor assertion cannot establish verification.

## S4 — What Is Rejected

- Reject claims that S2, SC-2, or the overall goal is complete or verified.
- Reject treating the uncommitted `guide.md` state as completion, redoing S1, modifying forbidden paths, exceeding S2 scope, using hidden acceptance, or self-authoring verification.