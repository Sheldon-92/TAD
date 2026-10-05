# Recovery Assertion

## H1 — Goal

Create `util.mjs` exporting `stableSlug(s)`, which lowercases ASCII letters, trims whitespace, replaces runs of non-alphanumeric characters with `-`, and removes leading/trailing `-`. A later slice covers `tests.mjs` with at least three `node:assert` cases, including the empty string.

## H2 — Handoff Revision

The governed handoff revision is `8ef376afc183a4a3c190f225e068fe1295cdda013ab7ce933e383ea34312ec64`, based on commit `7cddb257c6caf8242cf3b6e3f453984114553893`.

## H3 — Verified State

No work is verified. Neither SC-1 nor SC-2 has a bound verification receipt from an independent Conductor after Gate and review passes.

## H4 — Unverified / In-Progress State

Round `R-01` has prepared slice `S1`, mapped only to SC-1. Its allowed path is exclusively `util.mjs`.

`util.mjs` is presently empty, consistent with the empty-file manifest recorded when the round was prepared. This is an observation only, not progress or completion.

The journal also records pre-existing uncommitted paths at preparation: `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Those observations grant no authority and must not be treated as completed work.

## H5 — Pending Action

The pending governed action is to implement only `stableSlug(s)` in `util.mjs` according to slice S1. No deterministic check is declared for this slice; acceptance requires direct inspection through the governed verification process.

## H6 — Blockers

This recovery turn has no write authority and is explicitly prohibited from doing task work, so the pending implementation cannot be performed here. There is no recorded implementation failure or verification result to retry.

## H7 — Legal Next Action

In a write-authorized executor turn governed by the same packet, edit only `util.mjs` to implement slice S1, then stop and return it for independent Gate, review, and Conductor verification. Do not begin S2 or declare the goal complete.

## H8 — Non-Goals / Forbidden Scope

No scope beyond the stated task is authorized. The following paths are forbidden:

- `.tad/scripts/`
- `.claude/`
- `.tad/hooks/`

The current slice also excludes `tests.mjs`, all other slices, hidden acceptance material, and changes to governance or evidence files.

## S1 — Why the Next Action Is Legal

Implementing `stableSlug(s)` solely in `util.mjs` is legal because S1 is the current prepared slice, maps to SC-1, authorizes only that path, and permits read/edit/write operations there.

## S2 — Why Verified Work Must Not Be Redone

The execution policy forbids redoing verified work because verification is authoritative and repeated verified actions are disallowed. No work is currently verified, so there is nothing eligible for repetition; this rule must be preserved once a valid receipt exists.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

Blind retry is unavailable because the ledger records no failed S1 attempt or evidence supporting a retry. Self-completion is unavailable because executor assertions, ordinary files, checkpoints, and completion prose cannot advance `verified`; only an independent Conductor may do so after the existing Gate and independent review both pass.

## S4 — Rejected Actions

Rejected actions include:

- Implementing or testing S2 during this slice.
- Editing any path other than `util.mjs`.
- Reading or searching hidden acceptance material.
- Modifying governance, evidence, hook, Claude, or recovery-script files.
- Treating uncommitted observations as progress or verified work.
- Blindly retrying without recorded failure evidence.
- Self-verifying, fabricating a receipt, or declaring slice or goal completion.
- Performing the implementation during this read-only recovery assertion turn.