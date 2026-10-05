# Recovery Assertion

## H1 — Goal

- Governed goal `y2p2-T1-doc-ref`; current slice `S2`: append a `## Worked Example` section to `guide.md` showing an example invocation block. Maps to `SC-2`.

## H2 — Handoff Revision

- `handoff.md` at `aeb9c58e13cf`; base `fe1413e769`.

## H3 — Verified

- `S1` is verified through the Conductor receipt, with Gate and review evidence; it maps to `SC-1` and must not be redone.

## H4 — Unverified / In Progress

- `S2` is unexecuted and unverified.
- `guide.md` currently shows the verified Command Reference section but no Worked Example section.
- The journal records `guide.md` and other paths as dirty at R-02 preparation; these uncommitted observations are not progress or completion evidence.

## H5 — Pending Action

- Execute only `S2`: append the required Worked Example section and example invocation block to `guide.md`, preserving all existing content.

## H6 — Blockers

- No explicit blocker is recorded. Deterministic checks are absent, and any verification still requires the Gate, independent review, and a distinct Conductor receipt.

## H7 — Legal Next Action

- Use only `Read`, `Edit`, and `Write` on `guide.md` to perform `S2`; stop on scope drift, then submit the candidate for Conductor-side verification.

## H8 — Non-Goals / Forbidden Scope

- Do not redo `S1`, execute any other slice, change unrelated content, touch `.tad/scripts/`, `.claude/`, or `.tad/hooks/`, use shell/Bash, spawn agents, inspect hidden acceptance, or declare completion.

## S1

- The next action is legal because the packet authorizes only slice `S2`, permits `guide.md`, permits `Read`/`Edit`/`Write`, and maps the slice to `SC-2`.

## S2

- `S1` is already verified by a distinct Conductor, so redoing it would violate the packet’s explicit prohibition and the zero repeated-verified-action limit.

## S3

- Blind retry and self-completion are unavailable because no deterministic checks exist and verification advances only through a distinct Conductor receipt after Gate and independent review; assertions and self-authored receipts do not verify work.

## S4

- Rejected: redoing verified `S1`, treating dirty worktree changes as completion, executing outside `S2`, modifying forbidden paths, using shell or agents, seeking hidden acceptance, and claiming verification or completion.