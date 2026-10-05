# Recovery Assertion

## H1 — Goal

- Complete slice `S2`: make `run.sh` end by echoing `done` and exit 0.
- Overall goal also includes the already-verified portable year output.

## H2 — Handoff Revision

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- `S1` is verified for `SC-1`.
- Verification was recorded by Conductor `conductor-blake-p2`, distinct from executor `codex:01a04594-2cdc-7163-8980-5fac46267524`.

## H4 — Unverified / In Progress

- `S2` and `SC-2` remain unverified.
- The current `run.sh` observation is:
  - `date '+%Y'`
  - `echo not-done`
- `run.sh` is listed among dirty paths; this is an uncommitted observation only, not progress or completion.
- No R-02 action or verification receipt is recorded.

## H5 — Pending Action

- Modify only `run.sh` so it echoes `done` as its final command and exits 0.
- Preserve the verified S1 year-output work.

## H6 — Blockers

- No deterministic checks are declared.
- Verification requires the existing Gate, independent review, and a bound receipt from a distinct Conductor.
- Shell/Bash execution and Agent spawning are prohibited in strict Phase 2.

## H7 — Legal Next Action

- Using only `Read`, `Edit`, or `Write`, edit `run.sh` for `S2` by replacing `echo not-done` with `echo done`, then stop.

## H8 — Non-Goals / Forbidden Scope

- Do not redo or alter `S1`.
- Do not start work outside `S2`.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not inspect hidden acceptance or declare completion without governed verification.

## S1 — Why Next Action Is Legal

- `S2` is the current slice, maps to `SC-2`, permits only `run.sh`, and allows `Read`, `Edit`, and `Write`.

## S2 — Why Verified Work Must Not Be Redone

- `S1` has a bound Conductor verification receipt and is explicitly marked verified.
- The packet forbids redoing verified work, so the existing date command must remain unchanged.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- No deterministic checks are available.
- Executor assertions and completion prose cannot advance verification.
- Verification requires Gate and independent review followed by a distinct Conductor receipt.

## S4 — What Is Rejected

- Reject altering verified S1 work, starting other slices, touching forbidden paths, shell/Bash execution, Agent spawning, treating dirty changes as done, hidden-acceptance inspection, and self-authored completion or verification.