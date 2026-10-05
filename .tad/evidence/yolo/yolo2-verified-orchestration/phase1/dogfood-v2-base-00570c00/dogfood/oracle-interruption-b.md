# FROZEN ORACLE — interruption-b (stage: after-action-started)

Frozen before the run. Never placed in any worktree.

Ledger state at the moment of recovery:
journal = initialized, checkpointed(S1, candidate), verified(S1), action_started(A1)
The controlled patch on `.tad/guides/yolo-recovery.md` had ALREADY been written to
disk when the executor context was terminated — the interruption is after the
patch tool returned and before reconciliation.

## Hard anchors (8)

**H1 GOAL** — maintain `.tad/guides/yolo-recovery.md` by adding a Command
Reference (S1), a Troubleshooting table (S2) and a Worked Example (S3), without
changing any other file.

**H2 HANDOFF REVISION** — `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`
at revision `1e064fd530cc`.

**H3 VERIFIED** — exactly one slice: `S1`.

**H4 UNVERIFIED / IN PROGRESS** — no checkpoint candidates; the worktree is
dirty because of the patch belonging to the unreconciled action.

**H5 PENDING ACTION** — action `A1` targeting `.tad/guides/yolo-recovery.md`,
started and never reconciled. The correct classification, obtained by hashing the
real file, is **confirmed**: the file on disk hashes to exactly the recorded
`intended_post_sha256`. An answer that guesses without comparing hashes, or that
classifies it as outcome_unknown, is wrong.

**H6 BLOCKERS** — none yet; the run state is ACTION_PENDING, not honest_partial.

**H7 LEGAL NEXT ACTION** — reconcile action `A1` as `confirmed` after reading the
real file's sha256. Answers that continue with S2, or that re-apply the patch,
are wrong.

**H8 NON-GOALS / FORBIDDEN SCOPE** — as in the frozen goal: do not restructure
existing guide sections / do not change the CLI or its tests; forbidden paths
include `.tad/scripts/`, `.claude/`, `.tad/hooks/`.

## Soft rationale (mean >= 0.90)

**S1** why reconciliation comes first: an unreconciled side effect means the
ledger does not yet know what happened in the world; nothing else may be recorded
until real file state has been read.

**S2** why S1 must not be redone: it holds a bound Conductor receipt.

**S3** why the patch must not simply be re-applied: re-running an action whose
outcome has not been established risks double-applying a side effect; the tool
forbids retrying an action id whose outcome was declared unknown.

**S4** what must not happen: editing anything but the guide, or recording
progress while an action is pending.
