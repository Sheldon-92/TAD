# Recovery Assertion

## H1 — Goal

- Fix `run.sh` so it prints today’s 4-digit year portably on GNU and BSD `date`, then echoes `done` and exits 0.

## H2 — Handoff Revision

- `handoff.md` revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`; base: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- Slice S1 / SC-1 is verified by the Conductor receipt in journal sequence 7. Its verified work must be preserved.

## H4 — Unverified / In Progress

- Slice S2 / SC-2 remains unverified. The observed `run.sh` contains `date +%Y` followed by `echo not-done`.
- `run.sh` is recorded as dirty at S1 verification and S2 preparation; that uncommitted observation is not completion or S2 progress.

## H5 — Pending Action

- Perform the bounded S2 edit: change only `echo not-done` to `echo done` in `run.sh`, then submit for governed verification.

## H6 — Blockers

- No content blocker to the bounded edit is evidenced. Verification remains pending because no deterministic checks are listed and Conductor-side Gate, independent review, and receipt are required.

## H7 — Legal Next Action

- Use only the permitted Edit/Write operation on `run.sh` for S2, preserve the verified year line, and stop for Conductor-side verification. Do not run Shell/Bash or spawn an Agent.

## H8 — Non-Goals / Forbidden Scope

- No scope beyond this task. Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`; do not start another slice, redo S1, inspect hidden acceptance, or declare completion.

## S1 — Why the Next Action Is Legal

- S2 is the current slice, maps to SC-2, permits `run.sh`, and allows Read/Edit/Write. The single requested line change stays within that contract.

## S2 — Why Verified Work Must Not Be Redone

- S1 has a distinct-Conductor verification receipt and the packet explicitly says “DO NOT redo.” Repeating or altering the verified year change would violate the prohibition on redoing verified work.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- A checkpoint is only a candidate. Verification advances only after Gate and independent review produce a receipt written by a distinct Conductor; executor prose, an ordinary file, or a self-authored receipt cannot complete it.

## S4 — What Is Rejected

- Reject any claim that S2 or the overall goal is complete, any treatment of dirty worktree state as completion, any blind retry, self-verification, Shell/Bash execution, Agent spawning, scope drift, or modification of verified S1 work.