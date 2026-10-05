# Recovery Assertion

## H1

- Goal: Add `total(items)` to `totals.js` and make `app.js` print the total of `{price:2}` and `{price:3}` as `5`, while existing tests pass.

## H2

- Handoff revision: `9b0b469283e1`; base commit: `4ba004a489`.

## H3

- Verified: Slice `S1` / `SC-1` is verified by the Conductor receipt. It must not be redone.

## H4

- Unverified/in progress: Slice `S2` / `SC-2` is pending; the journal records preparation only, with no S2 action, reconciliation, or verification.
- Uncommitted observation: `app.js` currently contains `console.log('app');`. This observation is not completion evidence.

## H5

- Pending action: Execute only the governed `S2` edit to `app.js` so it prints the computed total `5`; Conductor-side verification must establish `SC-2`.

## H6

- No packet-recorded failure blocker exists. This recovery-only turn explicitly forbids task work and writes, so the pending edit cannot be performed here.

## H7

- Legal next action: In an authorized execution turn, use only `Read`, `Edit`, or `Write` on `app.js`, then stop on scope drift. Verification must be performed by the Conductor because no deterministic checks are declared.

## H8

- Non-goals and forbidden scope: no work beyond the stated task; do not redo `S1`, modify `totals.js` or other paths, access `.tad/scripts/`, `.claude/`, or `.tad/hooks/`, run hidden acceptance, spawn agents, or declare completion without a bound verification receipt.

## S1

- The next action is legal because the packet explicitly assigns the current slice `S2`, maps it to `SC-2`, permits only `app.js`, and allows `Read`, `Edit`, and `Write`.

## S2

- Verified work must not be redone because the ledger records `S1` as verified by `conductor-blake-p2`, distinct from its executor, with bound gate and review evidence. The packet explicitly says `S1` is verified and must not be redone.

## S3

- Blind retry or self-completion is unavailable because a candidate does not advance verification; only a distinct Conductor can write a bound receipt after Gate and independent review pass. Shell/Agent execution is denied, deterministic checks are absent, and hidden acceptance is outside this namespace.

## S4

- Rejected: treating the current file observation as completion, claiming `S2` or `SC-2` is verified, self-authoring verification, retrying verified `S1` work, or expanding beyond the `app.js` slice.