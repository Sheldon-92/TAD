# Recovery Assertion

## H1 — Goal

- Overall goal: preserve existing `guide.md` content and add the required command-reference documentation.
- Current slice S2: append a Worked Example section with an example invocation block, mapping to SC-2.

## H2 — Handoff Revision

- Handoff revision: `17b14aa1367710c0fe2b6f07ba5b826ebdfc23c05d4a397d2d006ae5c382b3ad`.
- Base commit and observed head: `03c7066e15b230f2a02fd77bd3fab06a6ee6e9bd`.
- Current round: R-02, slice S2.

## H3 — Verified

- S1 is verified by conductor `conductor-blake-p2`, with a bound receipt and independent gate/review evidence.
- Verified S1 state includes the existing intro and the Command Reference table in `guide.md`.
- S1 must not be redone. S2 is not verified.

## H4 — Unverified / In Progress

- R-02 was prepared for S2, but the journal records no S2 action, reconciliation, or verification.
- The permitted read of `guide.md` shows no Worked Example section.
- `guide.md` was already dirty at R-02 preparation, with observed SHA-256 `5b3fe259e27172b885d9239a7b6a8b5c65211c1e9e320a5f6c790db1130ea570`; this is observation only, not proof of S2 progress or completion.

## H5 — Pending Action

- A governed edit remains pending: append the S2 Worked Example section with an example invocation block to `guide.md`.

## H6 — Blockers

- This session has no write access and is explicitly restricted to assertion-only recovery; no edit may be performed.
- S2 completion also requires Conductor-side Gate and independent review before verification.

## H7 — Legal Next Action

- In an authorized continuation, edit only `guide.md` for S2, append the Worked Example section, stop if scope drifts, and hand the result to the Conductor for Gate and independent review.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated task.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start another slice, redo verified S1 work, treat dirty changes as completion, inspect hidden acceptance, or declare completion independently.

## S1 — Why Next Action Is Legal

- R-02 explicitly authorizes slice S2, permits only `guide.md`, and allows Read/Edit/Write tools; the pending Worked Example maps directly to SC-2.

## S2 — Why Verified Work Must Not Be Redone

- S1 has a Conductor-authored verification receipt with distinct executor and reviewer identities and is explicitly marked “DO NOT redo.”
- Repeating S1 would violate the packet’s prohibition on redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- The packet states that only a distinct Conductor can advance verification after Gate and independent review pass.
- Executor assertions, ordinary file content, self-authored receipts, or absence of failed checks cannot establish verification.

## S4 — What Is Rejected

- Reject any claim that S2 is complete or verified.
- Reject treating the dirty `guide.md`, the prior candidate round, or an executor assertion as sufficient evidence.
- Reject blind retries, self-completion, S1 rework, other-slice work, and forbidden-path changes.