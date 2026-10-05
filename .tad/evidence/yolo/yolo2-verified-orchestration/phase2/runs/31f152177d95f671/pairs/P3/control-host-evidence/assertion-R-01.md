# Recovery Assertion

## H1

- Goal `y2p2-T3-shell-edge`: fix `run.sh` so it prints today’s 4-digit year portably on GNU and BSD `date`, then echoes `done`.
- Success criteria: SC-1 and SC-2.

## H2

- Handoff: `handoff.md` at revision `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`.
- Base commit: `f6c3226139e17896445f5294ebc6b85fccecf850`.

## H3

- Verified state is none.
- No Conductor verification receipt exists.

## H4

- Round R-01 is prepared for slice S1, mapped to SC-1.
- `run.sh` currently contains the non-portable year logic and ends with `echo not-done`.
- No task work is recorded. Dirty paths observed at preparation are observation-only and are not progress or completion.

## H5

- Pending action: execute only S1 by editing `run.sh` to satisfy the portable year-output requirement.
- S2 remains pending.

## H6

- No blocker to the authorized S1 edit is recorded.
- Verification remains unavailable until the required Gate, independent review, and distinct-Conductor receipt occur.

## H7

- The legal next action is to use only Read/Edit/Write on `run.sh` for S1, then stop.
- No completion or verification claim may be made by the executor.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Starting S2, inspecting hidden acceptance, treating dirty changes as progress, and self-authored completion or verification are forbidden.

## S1

- The next action is legal because the current slice is S1, its allowed path is `run.sh`, and its tool allowlist is Read, Edit, and Write.

## S2

- No verified work exists, so there is nothing to redo.
- Any future verified work must not be repeated; verified-action repetition is prohibited.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared.
- A checkpoint is only a candidate; verification requires a distinct Conductor receipt after Gate and independent review.
- Hidden acceptance is outside the executor namespace.

## S4

- Reject scope drift, S2 execution during this round, edits outside `run.sh`, hidden-acceptance inspection, blind retries, and any executor declaration of completion or verification.