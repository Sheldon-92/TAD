# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T3-shell-edge`: fix `run.sh` to print today’s year using a portable GNU/BSD `date` invocation, then echo `done`.
- Current round slice `S1` covers only `SC-1`.

## H2 — Handoff Revision

- `handoff.md` revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- Verified state is `none`.
- No Gate pass, independent review pass, or distinct-Conductor verification receipt is recorded.
- Neither `SC-1` nor `SC-2` may be claimed verified.

## H4 — Unverified / In Progress

- `R-01/S1` is unverified and in progress; its sole allowed target is `run.sh`.
- Observed `run.sh` currently contains `date +%Y 2>/dev/null || date -j +%Y` followed by `echo not-done`.
- No edit or verification was performed in this recovery.
- The journal records pre-existing dirty paths at preparation: `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`. Any uncommitted worktree changes are observations only and are not progress or completion.

## H5 — Pending Action

- Apply the scoped `S1` edit to `run.sh` so it satisfies the portable-year requirement.
- Then stop for Conductor-side verification; `S2` remains pending.

## H6 — Blockers

- There is no blocker to the scoped `S1` edit.
- Verification and completion are blocked pending the required Gate, independent review, and distinct-Conductor receipt.
- No deterministic checks are declared for this slice; hidden acceptance is outside the executor namespace.

## H7 — Legal Next Action

- Use only `Read`, `Edit`, or `Write` on `run.sh` for `S1`, then hand off without declaring completion.
- Do not run shell/Bash checks or spawn agents; Conductor-side checks must remain Conductor-side.

## H8 — Non-Goals / Forbidden Scope

- Do not expand beyond the stated task.
- Do not start or implement `S2` in this slice.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat uncommitted changes, ordinary prose, or executor assertions as verification.

## S1 — Why the Next Action Is Legal

- `S1` explicitly maps to `SC-1`, permits only `run.sh`, and allows `Read`, `Edit`, and `Write`.
- The proposed action stays within that contract and does not start another slice.

## S2 — Why Verified Work Must Not Be Redone

- The packet prohibits redoing verified work.
- Nothing is currently verified, but any future Conductor-verified work must be preserved rather than repeated.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- No deterministic checks are declared, and shell/Bash execution plus agent spawning are denied.
- A checkpoint, completion statement, ordinary file, or self-authored receipt cannot advance verification.
- Therefore blind retry and self-completion are unavailable; the Conductor verification path is required.

## S4 — What Is Rejected

- Reject claims that `S1`, `SC-1`, or the overall goal is verified or complete.
- Reject treating the observed or uncommitted worktree state as progress.
- Reject unauthorized edits, `S2` work, forbidden-path access, hidden-acceptance attempts, shell/Bash checks, agent spawning, and self-authored verification.