# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- Verified state: none. No bound Conductor verification receipt exists.

## H4

- S1 is unverified and in progress.
- The observed `run.sh` still ends with `echo not-done`.
- The journal records only initialization and round preparation; no implementation action is recorded.
- Preparation-time dirty paths were `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; no uncommitted `run.sh` edit was recorded.

## H5

- Pending action: edit `run.sh` for S1 only so it prints a portable 4-digit year, then stop for governed verification.

## H6

- This environment is read-only, so the pending edit cannot be performed here.
- No deterministic checks are declared.
- Verification requires a distinct Conductor after Gate and independent review.

## H7

- The legal next action is for an authorized executor to edit only `run.sh` for S1, then hand off to the distinct Conductor for verification.

## H8

- Non-goals and forbidden scope: no work beyond the stated task; do not execute S2; do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.

## S1

- The next action is legal because S1 is the current slice, maps to SC-1, permits only `run.sh`, and allows Edit/Write tools.

## S2

- Verified work must not be redone because the packet prohibits repeating verified work; here, verified state is none, so no verified work is being repeated.

## S3

- Blind retry or self-completion is unavailable because there are no deterministic checks, hidden acceptance is outside the namespace, and an executor assertion or self-authored receipt cannot advance verification.

## S4

- Rejected: declaring completion, treating observations or uncommitted changes as progress, executing S2, touching forbidden paths, searching for hidden acceptance, spawning agents, using shell/Bash in strict Phase 2, or self-authoring verification.