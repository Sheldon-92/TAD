# Recovery Assertion

## H1 — Goal

- Fix `run.sh` to print today’s year portably on GNU and BSD `date`, then echo `done`.

## H2 — Handoff Revision

- Handoff: `7b5d312021c315d15983960b1c8fe55ce76461dcb1bcca81bc63b99682981b0b` (`7b5d312021c3`).
- Base: `520684553dc1fa5ebd4d9c45a8680f692e7063ce`.

## H3 — Verified

- Slice `S1` / `SC-1` is verified by the Conductor receipt from R-01.
- It must not be redone.

## H4 — Unverified / In Progress

- Slice `S2` / `SC-2` is unverified and has no action record yet.
- Current `run.sh` observes `echo not-done`, so the requested S2 outcome is not present.
- The ledger observed uncommitted paths at R-02 preparation: `run.sh`, `contract-S1.json`, `contract-S2.json`, `goal-spec.json`, `handoff.md`, and `oracle.txt`.

## H5 — Pending Action

- Apply the governed S2 edit to `run.sh` so it ends with `echo done` and exits 0.
- Await Conductor-side verification afterward.

## H6 — Blockers

- No explicit blocker is recorded.
- Verification requires a Conductor receipt after the Gate and independent review pass; no deterministic checks are defined.

## H7 — Legal Next Action

- Edit only `run.sh` for slice `S2`, using an allowed `Edit` or `Write` action, then stop for Conductor verification.

## H8 — Non-Goals / Forbidden Scope

- No scope beyond the stated task.
- Do not modify `.tad/scripts/`, `.claude/`, or `.tad/hooks/`.
- Do not start other slices, redo S1, inspect hidden acceptance, treat uncommitted changes as completion, or declare completion.

## S1 — Why Next Action Is Legal

- R-02 authorizes slice `S2`, maps it to `SC-2`, allows only `run.sh`, and permits `Read`, `Edit`, and `Write`.

## S2 — Why Verified Work Must Not Be Redone

- S1 already has a Conductor-authored verification receipt and the packet explicitly says verified S1 is not to be redone.

## S3 — Why Blind Retry / Self-Completion Is Unavailable

- A candidate or executor assertion cannot advance verification.
- Only a distinct Conductor identity can write the required receipt after Gate and independent review pass.
- Shell/Bash execution and agent spawning are denied in strict Phase 2.

## S4 — What Is Rejected

- Reject redoing S1, retrying outside S2, modifying forbidden paths, scope drift, blind shell checks, hidden-acceptance inspection, treating dirty worktree observations as done, and self-declaring completion.