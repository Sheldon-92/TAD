# Recovery Assertion

## H1

- Goal: Fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`. Current slice: S2 only.

## H2

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base: `520684553dc1fa5ebd4d9c45a8680f692e7063ce`.

## H3

- Verified: S1 is verified by the Conductor and maps to SC-1. S2 is not verified.

## H4

- S2 is unverified and pending. The journal records `run.sh` dirty at R-02 preparation, with observed hash `3d921ff3cc7bc4d3fa20d11a45ad970af82d07020b2a04ea5e1191b929871b8d`; the current file has the verified S1 date line but still contains `echo not-done`. Other recorded dirty paths are `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. These observations are not progress or completion.

## H5

- Pending action: edit only `run.sh` so it ends with `echo done` and exits 0, then stop for verification.

## H6

- No deterministic checks are declared. S2 cannot be considered verified until the Gate and independent review pass and a distinct Conductor writes the bound receipt.

## H7

- Legal next action: in an authorized execution turn, edit only `run.sh` for S2/SC-2; preserve verified S1 and do not run other slices or claim completion.

## H8

- Non-goal: any scope beyond the stated task. Forbidden: `.tad/scripts/`, `.claude/`, `.tad/hooks/`, redoing S1, modifying other files, hidden acceptance, shell/agent spawning, self-authored verification, and treating uncommitted changes as done.

## S1

- The next action is legal because S2 is the active slice, maps to SC-2, permits only `run.sh`, and allows Read/Edit/Write tools.

## S2

- S1 is already verified with a Conductor receipt and must not be redone; its portable date implementation must be preserved.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared and only a distinct Conductor, after Gate and independent review, can advance verification.

## S4

- Rejected: re-editing verified S1, changing the date line, modifying forbidden paths, treating dirty observations as completion, and declaring S2 verified without the required receipt.