# Recovery Assertion

## H1

- Goal `y2p2-T4-cross-file`: update `CHANGELOG.md` to `v1.0.0` and update `usage.md` from `0.9.0` to `1.0.0`.
- Success criteria: SC-1 for `CHANGELOG.md`; SC-2 for `usage.md`.

## H2

- Handoff: `handoff.md` at revision `b7b9a0c63444f7a8e3125f2114e1cf4e4dcad65133c9b86c37ddf087985c0b99`.
- Base commit: `ba0325db8cb944d712c075a20be62ef4a7416a77`.

## H3

- S1 is verified and maps to SC-1.
- Verification was written by `conductor-blake-p2`, distinct from executor `codex:01a04c7e-561d-7d01-ac61-fdeda80ac468`.
- S1 must not be redone.

## H4

- S2 is unverified and not started; R-02 has only a `round_prepared` journal entry.
- `usage.md` currently reads `usage for 0.9.0`; SC-2 is therefore unmet.
- No S2 mutation is recorded. The R-02 dirty observations include the verified S1 `CHANGELOG.md` change and pre-existing governance files; these are not S2 progress.

## H5

- Pending action: perform the governed S2 edit in `usage.md`, changing the version from `0.9.0` to `1.0.0` and removing every remaining `0.9.0` reference.

## H6

- No hard blocker is recorded.
- S2 verification remains dependent on the Conductor-side Gate, independent review, and bound verification receipt.

## H7

- The legal next action is limited to `usage.md` using the authorized Read/Edit/Write tools, followed by Conductor-side verification.
- Stop immediately on scope drift.

## H8

- Non-goal: any scope beyond the stated version updates.
- Forbidden: other slices, redoing verified S1, hidden acceptance, shell/Bash or agent spawning, and changes to `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.

## S1

- The next action is legal because R-02 explicitly authorizes slice S2, maps it to SC-2, permits only `usage.md`, and allows Read/Edit/Write.

## S2

- Verified S1 must not be redone because the journal contains a Conductor-authored verification receipt and explicitly marks S1 verified; the packet prohibits repeating verified work.

## S3

- Blind retry is unavailable because no S2 action has failed or been reconciled, and self-completion cannot advance verification.
- The verification model requires a distinct Conductor receipt after Gate and independent review; assertions, ordinary files, and executor-authored receipts do not count.

## S4

- Rejected: claiming completion now, treating the `usage.md` observation or uncommitted state as progress, editing any path other than `usage.md`, touching forbidden directories, starting another slice, or redoing S1.