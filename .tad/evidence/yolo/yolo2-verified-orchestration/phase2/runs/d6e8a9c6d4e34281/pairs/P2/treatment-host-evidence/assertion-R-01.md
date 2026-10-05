# Recovery Assertion

## H1 — Goal

- Create `util.mjs` exporting `stableSlug(s)` and `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2 — Handoff Revision

- `handoff.md` revision: `aa4ec6b14d64af64ab69ed45408a99822e1fce1dd0c29f5504b84a02f22411b8`.
- Base commit: `36cec5f1c15045c986c233f7c7caa1592c203a56`.

## H3 — Verified

- Nothing is verified. The packet explicitly states verified state is none, and no Conductor verification receipt exists in the journal.

## H4 — Unverified / In Progress

- Current slice is S1, limited to `util.mjs`; it remains unverified.
- `util.mjs` is empty on inspection.
- The journal records pre-existing dirty paths—`contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`—which are observations only and must not be treated as progress or completion.

## H5 — Pending Action

- An authorized executor must implement S1 in `util.mjs` only, then stop for governed verification.
- S2 (`tests.mjs`) is not part of this round’s current slice.

## H6 — Blockers

- No verification receipt, Gate result, or independent-review result is present.
- The current response is explicitly prohibited from editing files or performing task work.
- No deterministic checks are declared for S1.

## H7 — Legal Next Action

- The next task action is limited to an authorized `Read`, `Edit`, or `Write` operation on `util.mjs` implementing S1, followed by Conductor-side Gate, independent review, and receipt.

## H8 — Non-Goals / Forbidden Scope

- No work beyond the stated goal.
- Do not start S2, redo verified work, declare completion, or inspect hidden acceptance.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.

## S1 — Why the Next Action Is Legal

- The packet names S1 as the current slice, maps it to SC-1, and explicitly allows only `util.mjs` with `Read`, `Edit`, and `Write`.

## S2 — Why Verified Work Must Not Be Redone

- No work is currently verified, but any future Conductor-verified work must not be repeated because the packet expressly forbids redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- Executor assertions, completion prose, ordinary files, and self-authored receipts cannot advance verification.
- Verification requires an existing Gate and independent review followed by a bound Conductor receipt; none is present.

## S4 — What Is Rejected

- Reject any claim that S1 is verified or complete.
- Reject treating pre-existing dirty paths as progress.
- Reject starting S2, scope drift, forbidden-path changes, blind retries, self-completion, or hidden-acceptance inspection.