# Recovery Assertion

## H1

- Goal: Fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done` and exit 0.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- Verified state: none. No Gate, independent-review, or Conductor verification receipt exists.

## H4

- R-01/S1 is unverified and maps only to SC-1.
- The journal records only initialization and slice preparation.
- `run.sh` matches the prepared manifest and currently contains `date +%Y 2>/dev/null || date -j +%Y` followed by `echo not-done`.
- Pre-existing dirty paths were recorded as `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; these are observations only, not progress.

## H5

- Pending action: perform only the S1 change to `run.sh` so its year output satisfies SC-1, then stop for governed verification.

## H6

- No technical blocker is recorded.
- Verification remains gated on a distinct Conductor after the existing Gate and independent review pass.

## H7

- Legal next action: edit only `run.sh`, using the authorized Read/Edit/Write tools, and remain within the S1 contract.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start S2, redo verified work, inspect hidden acceptance, or declare completion.

## S1

- The next action is legal because the S1 contract explicitly allows `run.sh`, authorizes Read/Edit/Write, and maps the slice to SC-1.

## S2

- There is no verified work to redo. Any future verified work must be preserved because the packet expressly forbids redoing verified work.

## S3

- Blind retry and self-completion are unavailable because candidate state does not constitute verification; only a distinct Conductor receipt after Gate and independent review advances `verified`. No deterministic checks are declared.

## S4

- Rejected: any claim that the run is complete or verified based on the current file, an executor assertion, ordinary completion prose, or a self-authored receipt.