# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done` and exits 0.
- Current slice: S1, mapped to SC-1.

## H2

- Goal/run ID: `y2p2-T3-shell-edge`.
- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- Verified state: none.
- No bound Conductor verification receipt exists for SC-1 or SC-2.

## H4

- S1 remains unverified and in progress.
- The permitted read of `run.sh` shows `date +%Y 2>/dev/null || date -j +%Y` followed by `echo not-done`.
- The journal records only initialization and round preparation. No uncommitted `run.sh` change is recorded in the preparation snapshot; any uncommitted change remains observation only, not progress or completion.

## H5

- Pending action: an authorized executor must complete only S1 by editing `run.sh` to satisfy SC-1, then stop for Gate, independent review, and Conductor-bound verification.
- S2 must not be started in this slice.

## H6

- No deterministic checks are declared.
- This recovery session has no write access and is prohibited from doing task work.
- Gate, independent review, and a distinct Conductor verification receipt are absent.

## H7

- The packet-legal next action for an authorized executor is an S1-only edit to `run.sh` using the permitted Edit/Write tools, followed by the required verification flow.
- For this session, the legal action is assertion and handoff only; no edit, test, or completion declaration.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Other slices, hidden acceptance, shell/Bash execution, Agent spawning, and declaring completion are out of scope.

## S1

- The next action is legal because S1 explicitly allows `run.sh`, permits Read/Edit/Write, and maps to SC-1 only.
- It does not authorize changes to other slices or paths.

## S2

- Verified work must not be redone because the packet expressly forbids redoing verified work.
- No work is currently verified, so no verified change is available to redo.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared.
- Verification advances only through Gate plus independent review and a bound receipt written by a Conductor distinct from the executor.
- Assertions, completion prose, and self-authored receipts cannot advance verification.

## S4

- Rejected: any claim that SC-1 or SC-2 is verified or complete.
- Rejected: treating uncommitted observations as progress or done.
- Rejected: starting S2, changing forbidden paths, running denied tools, inspecting hidden acceptance, or redoing verified work.