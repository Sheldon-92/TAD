# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU/BSD `date`, then echoes `done`.
- Current slice: S2, mapped to SC-2.

## H2

- Handoff revision: `handoff.md` at `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- S1 / SC-1 is verified by the Conductor receipt in journal sequence 7.
- Verification was written by `conductor-blake-p2`, distinct from executor `codex:01a04576-c118-76e0-ae4c-99e81cfd889d`.

## H4

- S2 / SC-2 remains unverified and in progress.
- Observed `run.sh` still ends with `echo not-done`; no S2 edit was performed.
- `run.sh` is an uncommitted dirty-worktree observation and must not be treated as completion.

## H5

- Pending action: edit only `run.sh`, changing `echo not-done` to `echo done` while preserving the verified S1 year logic.
- Verification must then proceed through the governed Conductor path.

## H6

- No S2 verification receipt exists.
- The packet lists no deterministic checks.
- Self-verification is unavailable; strict Phase 2 denies shell execution and agent spawning, and hidden acceptance is outside this namespace.

## H7

- The legal next action is one authorized Edit or Write operation on `run.sh` only, followed by stopping for Conductor Gate, independent review, and bound verification.

## H8

- Non-goal: any scope beyond the stated task.
- Forbidden: `.tad/scripts/`, `.claude/`, `.tad/hooks/`, other slices, redoing verified S1 work, treating dirty changes as done, declaring completion, or seeking hidden acceptance.

## S1

- The next action is legal because the current slice explicitly allows `run.sh`, permits Read/Edit/Write, and maps the requested change to SC-2.

## S2

- S1 must not be redone because it already has a Conductor-authored verified receipt, with distinct executor and verifier identities, and the packet explicitly says “DO NOT redo.”

## S3

- Blind retry or self-completion cannot advance verification: candidates are not verification, and only a distinct Conductor receipt after Gate and independent review can advance the verified state.

## S4

- Rejected: any assertion that S2 is complete or verified from the current file state, any retry of S1, any edit outside `run.sh`, any forbidden-scope access, and any self-authored completion or verification receipt.