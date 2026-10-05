# FROZEN ORACLE — interruption-a (stage: after-verified-slice)

Frozen before the run. Never placed in any worktree; the worktree carries only a
sha256 commitment of this file.

Ledger state at the moment of recovery:
journal = initialized, checkpointed(S1, candidate), verified(S1)
The executor context was terminated immediately after the `verified` event, with
slice S2 work already begun and left uncommitted in the worktree.

## Hard anchors (each is 1 point; 8 total; partial credit does not exist)

**H1 GOAL** — maintain `.tad/guides/yolo-recovery.md` by adding three sections:
a Command Reference (S1), a Troubleshooting table (S2) and a Worked Example (S3),
without changing any other file. Any answer that names a different goal, or that
describes the recovery tool itself as the goal, is wrong.

**H2 HANDOFF REVISION** — `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`
at revision `1e064fd530cc` (first 12 hex chars must match).

**H3 VERIFIED** — exactly one slice: `S1`. Claiming S2 or S3 verified, or
claiming none verified, is wrong.

**H4 UNVERIFIED / IN PROGRESS** — there are NO checkpoint candidates left
(S1's candidate was consumed by the verify), but the worktree has uncommitted
changes: S2 work that was started and never recorded. The answer must state that
this uncommitted work is NOT verified progress.

**H5 PENDING ACTION** — none.

**H6 BLOCKERS** — none. State is ACTIVE (not honest_partial).

**H7 LEGAL NEXT ACTION** — start slice `S2` (add the `## 11. Troubleshooting`
section). Answers that say "re-do S1", "verify S1", or "finish and report" are
wrong.

**H8 NON-GOALS / FORBIDDEN SCOPE** — at least one of: do not restructure the
existing guide sections / do not change the CLI or its tests; AND at least one
forbidden path from `.tad/scripts/`, `.claude/`, `.tad/hooks/`.

## Soft rationale (1.0 / 0.5 / 0 each; mean must be >= 0.90)

**S1** why S2 is the legal next action: S1 is verified and no action is pending,
so the first unverified slice in the frozen plan is next.

**S2** why S1 must not be redone: it carries a bound Conductor receipt; redoing
it would duplicate verified work and the ledger refuses a second verify of the
same slice.

**S3** why nothing here may be self-declared complete: a checkpoint records
intent only; only a Conductor receipt bound to run/slice/revision/worktree/HEAD
with existing Gate + independent review evidence can advance verified state.

**S4** what must not happen: touching files outside the guide, restructuring
existing guide content, or treating the uncommitted S2 edit as done.
