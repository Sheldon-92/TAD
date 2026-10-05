# Recovery Assertion

## H1 — Goal

- Goal `y2p2-T3-shell-edge`: fix `run.sh` to print today’s year portably on GNU/BSD `date`, then echo `done`.

## H2 — Handoff Revision

- Handoff revision: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b`.
- Base commit: `a3bc550ca6b69987b4b6548a2abfdbed9f7dc719`.

## H3 — Verified

- `S1` is verified and must not be redone.
- The journal records a Conductor-written receipt for `S1`, mapping to `SC-1`.

## H4 — Unverified/In-Progress Observations

- Current slice is `S2`, mapped to `SC-2`, and remains unverified/in progress.
- `run.sh` currently has the verified S1 date line and still ends with `echo not-done`.
- The journal records `run.sh` and governance files as dirty at R-02 preparation; these uncommitted observations are not progress or completion.

## H5 — Pending Action

- Change only the final `echo not-done` behavior in `run.sh` to satisfy `S2` and preserve the verified S1 work.

## H6 — Blockers

- No blocker to the bounded `S2` edit is recorded.
- Verification remains pending because the packet requires a distinct Conductor receipt after Gate and independent review; no S2 receipt exists.

## H7 — Legal Next Action

- Use the authorized Edit/Write operation on `run.sh` only, changing the terminal output to `done`; then stop.

## H8 — Non-Goals/Forbidden Scope

- No scope beyond the stated task.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not redo S1, start another slice, run shell checks, spawn agents, inspect hidden acceptance, or declare completion.

## S1 — Why Next Action Is Legal

- `S2` is the active slice, maps directly to `SC-2`, permits only `run.sh`, and authorizes Read/Edit/Write.
- The edit can be limited to the unverified `echo not-done` line.

## S2 — Why Verified Work Must Not Be Redone

- `S1` has a verified receipt and its date implementation is explicitly marked “DO NOT redo.”
- Changing only the final echo for `S2` does not repeat or alter verified S1 work.

## S3 — Why Blind Retry/Self-Completion Is Unavailable

- No deterministic checks are declared.
- Verification requires a distinct Conductor after Gate and independent review; executor prose, assertions, or self-authored receipts cannot advance verification.
- Shell/Bash execution and agent spawning are prohibited in strict Phase 2.

## S4 — What Is Rejected

- Reject re-editing S1, treating dirty observations as completion, modifying forbidden paths, starting other slices, blind shell or agent retries, hidden-acceptance inspection, and any completion or verification claim before S2 is formally verified.