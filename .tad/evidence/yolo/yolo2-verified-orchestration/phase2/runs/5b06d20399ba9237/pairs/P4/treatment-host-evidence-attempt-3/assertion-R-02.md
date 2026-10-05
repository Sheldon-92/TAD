# Recovery Assertion

## H1

- Goal `y2p2-T4-cross-file`: update `usage.md` from `0.9.0` to `1.0.0`; success criterion SC-2 requires no remaining `0.9.0`.

## H2

- Handoff revision: `b7b9a0c63444f7a8e3125f2114e1cf4e4dcad65133c9b86c37ddf087985c0b99`.
- Base: `ba0325db8cb944d712c075a20be62ef4a7416a77`.

## H3

- S1 / SC-1 is verified by the Conductor; it must not be redone.

## H4

- S2 / SC-2 is unverified and remains in progress.
- The permitted read of `usage.md` observed `usage for 0.9.0`.
- No uncommitted change to `usage.md` is recorded or observed.

## H5

- Pending action: edit only `usage.md` so it references `1.0.0` and no longer mentions `0.9.0`, then submit it for governed verification.

## H6

- No packet-level dependency blocker is recorded.
- S2 has no verification receipt, and this turn explicitly forbids performing the task work.

## H7

- The legal next action is one bounded Read/Edit/Write operation on `usage.md` only, followed by Conductor-side Gate, independent review, and bound verification receipt.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden: redoing S1, touching `CHANGELOG.md` or unrelated files, accessing `.tad/scripts/`, `.claude/`, `.tad/hooks/`, seeking hidden acceptance, or declaring completion.

## S1

- The next action is legal because the R-02 S2 contract maps to SC-2, allows only `usage.md`, and permits Read, Edit, and Write.

## S2

- S1 has a Conductor-written verification event with a distinct executor identity and is explicitly marked verified; repeating it violates the packet’s prohibition on redoing verified work.

## S3

- Blind retry and self-completion are unavailable because checkpoints and executor assertions do not verify work; only a Conductor receipt after Gate and independent review can advance `verified`.

## S4

- Rejected: treating the observed old value as progress or completion, self-authored verification, any unbounded or unauthorized edit, retrying S1, and any action outside the S2 slice.