# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2

- Handoff revision: `handoff.md` at `7b5d312021c3`; base `a3bc550ca6`.

## H3

- `S1` is verified by a Conductor receipt.
- `S2` is not verified.

## H4

- `S2` is the current in-progress slice.
- The permitted target currently contains `date '+%Y'` followed by `echo done`.
- The journal records no R-02 action; `run.sh` is listed as dirty at R-02 preparation. This is an uncommitted observation only and must not be treated as progress or completion.

## H5

- Pending action: Preserve the existing `run.sh` state and obtain Conductor-side Gate and independent-review verification for S2.

## H6

- Blockers: No deterministic checks are declared, and S2 has no bound Conductor verification receipt. Hidden acceptance is outside this namespace.

## H7

- Legal next action: Allow Conductor-side verification of the existing S2 state; any executor edit, if required, may target only `run.sh` and S2.

## H8

- Non-goals and forbidden scope: no work beyond the stated task; do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not redo S1, declare completion, or treat uncommitted observations as done.

## S1

- The next action is legal because S2 is the current slice, maps to SC-2, permits only `run.sh`, and authorizes Read/Edit/Write within that slice.

## S2

- Verified work must not be redone because S1 has a valid Conductor receipt and the packet explicitly says `S1` is verified and must not be redone.

## S3

- Blind retry or self-completion is unavailable because verification requires a distinct Conductor after Gate and independent review; executor prose, self-authored receipts, and uncommitted state cannot advance verification.

## S4

- Rejected: redoing S1, treating the current `run.sh` observation as verified, blind edits or retries, completion claims, forbidden-path changes, other-slice work, and hidden-acceptance inspection.