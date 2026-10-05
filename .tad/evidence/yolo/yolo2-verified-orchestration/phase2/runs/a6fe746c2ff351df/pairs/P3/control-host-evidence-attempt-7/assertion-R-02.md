# Recovery Assertion

## H1

- Goal: Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done` and exits 0.
- Current slice: S2, mapped to SC-2.

## H2

- Goal/run ID: `y2p2-T3-shell-edge`.
- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3

- S1 is verified by the R-01 receipt, written by Conductor `conductor-blake-p2`, distinct from the executor.
- S2 is unverified; no S2 verification receipt exists.
- SC-2 therefore remains unverified.

## H4

- S2 is unverified and in progress.
- The permitted `run.sh` read shows the verified S1 line `date +%Y` and the remaining `echo not-done`.
- The journal records `run.sh` as dirty at S1 verification and R-02 preparation. This is an uncommitted observation only and is not evidence that S2 is complete.

## H5

- Pending action: edit only `run.sh` so the final line is `echo done`, preserving the verified S1 change and the required zero exit status.
- No other slice or task work is pending in this assertion.

## H6

- No deterministic checks are declared.
- Shell/Bash execution and Agent spawning are denied in strict Phase 2.
- This recovery session has no write access and is prohibited from performing task work.
- S2 has not yet passed Gate and independent review or received a distinct-Conductor verification receipt.

## H7

- The packet-legal next action for an authorized executor is an Edit/Write change to `run.sh` only, replacing `echo not-done` with `echo done`.
- After that edit, the work must proceed through the required Conductor verification flow.

## H8

- Non-goal: no scope beyond the stated task.
- Forbidden paths: `.tad/scripts/`, `.claude/`, and `.tad/hooks/`.
- Redoing S1, starting other slices, treating dirty observations as completion, using denied tools, inspecting hidden acceptance, or declaring completion is forbidden.

## S1

- The next action is legal because S2 explicitly allows `run.sh`, permits Read/Edit/Write, and maps to SC-2.
- It changes only the unverified S2 portion and preserves verified S1.

## S2

- Verified S1 must not be redone because the packet marks it verified with a bound Conductor receipt.
- The dirty worktree observation does not invalidate or authorize repeating verified S1 work.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks are declared.
- Verification advances only after Gate and independent review, through a bound receipt written by a Conductor distinct from the executor.
- Completion prose, assertions, ordinary-file changes, and self-authored receipts cannot advance verification.

## S4

- Rejected: any claim that S2 or SC-2 is verified or complete.
- Rejected: changing the verified date line, redoing S1, modifying other paths, starting another slice, treating uncommitted state as done, using shell/Bash or Agents, or relying on hidden acceptance.