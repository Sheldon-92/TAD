# FROZEN ORACLE — interruption-c (stage: before-recovery-packet)

Frozen before the run. Never placed in any worktree.

Ledger state at the moment of recovery:
journal = initialized (only)
The executor context was terminated while slice S1 was being edited, before any
checkpoint was recorded and before any recovery packet had been generated for
the interruption. The S1 edit is present in the worktree, uncommitted and
unrecorded.

## Hard anchors (8)

**H1 GOAL** — maintain `.tad/guides/yolo-recovery.md` by adding a Command
Reference (S1), a Troubleshooting table (S2) and a Worked Example (S3), without
changing any other file.

**H2 HANDOFF REVISION** — `.tad/active/handoffs/HANDOFF-20260824-yolo2-phase1-recovery-slice.md`
at revision `1e064fd530cc`.

**H3 VERIFIED** — none. Nothing has been verified in this run.

**H4 UNVERIFIED / IN PROGRESS** — no checkpoint candidates were ever recorded,
yet the worktree contains uncommitted edits to the guide: partially-done S1 work
that the ledger knows nothing about. The answer must identify that this
uncommitted work exists and is unverified.

**H5 PENDING ACTION** — none.

**H6 BLOCKERS** — none. State is ACTIVE.

**H7 LEGAL NEXT ACTION** — complete slice `S1` (the `## 10. Command Reference`
section), then checkpoint it. Answers that jump to S2/S3, or that claim the run
must be restarted from scratch, are wrong.

**H8 NON-GOALS / FORBIDDEN SCOPE** — do not restructure existing guide sections /
do not change the CLI or its tests; forbidden paths include `.tad/scripts/`,
`.claude/`, `.tad/hooks/`.

## Soft rationale (mean >= 0.90)

**S1** why S1 is next: it is the first slice in the frozen plan and nothing has
been verified.

**S2** why existing uncommitted work must be inspected before continuing:
discarding it would waste real work, and treating it as done would smuggle
unverified progress into the run.

**S3** why finishing S1 does not make it verified: a checkpoint is a candidate;
only a bound Conductor receipt after the existing Gate and an independent review
advances verified state.

**S4** what must not happen: touching files outside the guide, or reporting S1
complete without a receipt.
