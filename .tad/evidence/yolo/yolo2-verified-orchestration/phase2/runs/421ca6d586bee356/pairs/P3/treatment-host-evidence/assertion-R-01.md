# Recovery Assertion

## H1 — Goal

- Fix `run.sh` so it prints today’s year portably on GNU and BSD `date`, then echoes `done`.

## H2 — Handoff Revision

- Handoff revision: `aded72058dfbc62127c64d80ecb07afff6dd83c9992f13dd47e1ae0efcddb236`.
- Base commit: `fe1ef862b17a30c5c87602670990a7eb30f30f31`.

## H3 — Verified

- Nothing is verified yet.
- No verification receipt exists.

## H4 — Unverified / In Progress

- Slice `S1` is the active slice and maps to `SC-1`.
- `run.sh` currently contains the non-portable implementation and ends with `echo not-done`.
- No `run.sh` edit or other progress is recorded.
- Pre-existing dirty paths observed at preparation are `contract-S1.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`; they are observations only and not progress or completion.

## H5 — Pending Action

- Make only the authorized `S1` change to `run.sh`.
- Afterwards, obtain the required Gate, independent review, and Conductor-bound verification receipt.

## H6 — Blockers

- No blocker prevents the authorized `S1` edit.
- Verification cannot advance without the required distinct Conductor receipt.
- No deterministic checks are declared in this packet.

## H7 — Legal Next Action

- An authorized executor may use only Read/Edit/Write on `run.sh` to satisfy `S1`, then stop for governed verification.

## H8 — Non-Goals / Forbidden Scope

- No scope beyond the stated task.
- Do not execute other slices, including `S2`.
- Do not touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not treat uncommitted changes as progress or completion.
- Do not declare completion or seek hidden acceptance.

## S1 — Why the Next Action Is Legal

- `S1` is the current slice, maps to `SC-1`, permits only `run.sh`, and allows Read, Edit, and Write.

## S2 — Why Verified Work Must Not Be Redone

- The packet prohibits redoing verified work; no work is currently verified, so there is nothing to redo.
- The active scope remains limited to `S1`; `S2` must not be started.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- A checkpoint is only a candidate.
- Verification advances only when a distinct Conductor writes a bound receipt after the Gate and independent review pass.
- Completion prose, an ordinary file, or a self-authored receipt cannot establish verification.
- Shell/Bash execution and agent spawning are denied in strict Phase 2.

## S4 — What Is Rejected

- Reject any out-of-slice edit, forbidden-path access, blind retry, self-authored completion claim, or treatment of uncommitted observations as verified progress.