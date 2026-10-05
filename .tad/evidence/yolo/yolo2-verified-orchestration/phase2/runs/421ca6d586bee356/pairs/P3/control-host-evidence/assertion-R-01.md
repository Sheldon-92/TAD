# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2

- Handoff: `handoff.md` at revision `b276f08f98bd968edbbf9f31db4d0a5fb12f1f11ed9700b1fe8a231761697914`; base `0869a6fd1b98e16b193414201c5bdb0e59820a07`.

## H3

- Verified state: none. No verification receipt is recorded.

## H4

- S1 is unverified and in progress.
- Observed `run.sh` currently uses `date +%Y 2>/dev/null || date -j +%Y` and ends with `echo not-done`.
- This observation is not progress or completion evidence.

## H5

- Pending action: complete only slice S1, then obtain the required Gate, independent review, and distinct-Conductor verification receipt.

## H6

- No explicit environment blocker is recorded.
- S1 cannot be claimed complete without the required verification chain; no deterministic checks are declared.

## H7

- The legal next action is to edit only `run.sh` for S1 using an allowed tool, stopping immediately on scope drift.
- No task work is performed in this assertion-only turn.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- S2, completion declaration, hidden-acceptance inspection, and treating observations as done are out of scope.

## S1

- The next action is legal because S1 explicitly allows only `run.sh`, maps to SC-1, and permits Read/Edit/Write.

## S2

- No verified work exists to redo. Any future verified work must not be repeated because verification advances only through the required distinct-Conductor receipt.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared, hidden acceptance is outside the namespace, and executor assertions or self-authored receipts never advance verification.

## S4

- Rejected: starting S2, editing forbidden or unlisted paths, declaring completion without verification, retrying blindly, inspecting hidden acceptance, or treating uncommitted observations as progress.