# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then eventually echoes `done`.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base commit `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- Verified state: none. No Conductor verification receipt is recorded.

## H4

- S1 is unverified and in progress.
- The observed `run.sh` contains the existing date command and `echo not-done`; this is an uncommitted observation only, not verified progress.
- The journal records pre-existing dirty paths at preparation: `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`.

## H5

- Pending action: perform only the S1 edit to `run.sh` so its year output is portable across GNU and BSD `date`.
- S2 remains pending and must not be started in this slice.

## H6

- This turn is read-only by instruction, so the pending edit cannot be performed here.
- No deterministic checks are declared, and no bound verification receipt exists.

## H7

- The next legal action is an S1-scoped Edit/Write of `run.sh` only, using the permitted tools, followed by stopping at the slice boundary.

## H8

- Non-goal: anything beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Do not start S2, inspect hidden acceptance, declare completion, or treat uncommitted observations as verified.

## S1

- The next action is legal because S1 is the current slice, maps to SC-1, permits only `run.sh`, and explicitly allows Read, Edit, and Write.

## S2

- There is no verified work to redo. The packet states verified state is none, and candidate or uncommitted observations cannot be treated as verified.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared, shell/agent execution is prohibited, and verification requires a distinct Conductor receipt after Gate and independent review.

## S4

- Rejected: any completion or verification claim, execution of S2, edits outside `run.sh`, blind retries, self-authored verification, hidden-acceptance inspection, and scope drift.