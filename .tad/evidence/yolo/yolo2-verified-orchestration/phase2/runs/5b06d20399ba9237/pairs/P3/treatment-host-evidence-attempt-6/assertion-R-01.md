# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T3-shell-edge`: fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`.
- `SC-1`: portable four-digit year output.
- `SC-2`: end with `echo done` and exit 0.

## H2 — Handoff Revision

- Handoff: `handoff.md` at revision `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b` (`7b5d312021c3`).
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719` (`a3bc550ca6`).
- Current round and slice: `R-01`, `S1`.

## H3 — Verified

- No work is verified.
- No bound Conductor verification receipt is recorded.

## H4 — Unverified / In Progress

- `S1` is pending and maps only to `SC-1`; its allowed path is `run.sh`.
- The journal records initialization and round preparation only; no edit or verification receipt is recorded.
- The uncommitted observation of `run.sh` is:
  - `date +%Y 2>/dev/null || date -j +%Y`
  - `echo not-done`
- This observation is not progress, verification, or completion.

## H5 — Pending Action

- An authorized executor must edit only `run.sh` to satisfy the `S1` portable-year requirement.
- `S2` remains outside the current slice and must not be started during `R-01`.

## H6 — Blockers

- This response is read-only and is prohibited from doing task work.
- Verification cannot advance without the required distinct-identity Conductor receipt after Gate and independent review both pass.
- No deterministic checks are declared, and hidden acceptance is outside the executor namespace.

## H7 — Legal Next Action

- After this recovery assertion, an authorized executor may make the bounded `S1` edit in `run.sh` only, then stop for Conductor-side Gate, independent review, and bound verification.
- This response performs no file edit and makes no completion claim.

## H8 — Non-Goals / Forbidden Scope

- No scope beyond the stated goal.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start `S2`, redo verified work, inspect hidden acceptance, use denied shell/agent actions, create a self-authored receipt, or declare completion.

## S1 — Why the Next Action Is Legal

- The packet explicitly defines `S1`, maps it to `SC-1`, permits `run.sh`, and allows only `Read`, `Edit`, and `Write`.
- The bounded edit stays within the declared slice and does not touch forbidden paths or begin `S2`.

## S2 — Why Verified Work Must Not Be Redone

- There is currently no verified work to redo.
- Any work that later receives the required bound Conductor verification must not be repeated because the packet expressly prohibits redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- A checkpoint is only a candidate; verification requires a distinct Conductor identity, a passing Gate, independent review, and a bound receipt.
- Completion prose, an ordinary file, a self-authored receipt, or an executor assertion cannot advance verification.
- No deterministic checks are available for a blind retry, and hidden acceptance is outside the namespace.

## S4 — What Is Rejected

- Reject any claim that the task or `S1` is complete or verified.
- Reject treating the observed `run.sh` contents as progress.
- Reject changing `echo not-done` during `S1`, starting `S2`, retrying blindly, touching forbidden paths, seeking hidden acceptance, or authoring a self-verification receipt.