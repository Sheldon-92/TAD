# Knowledge Assessment — yolo2-phase1 (Gate 3)

**Date:** 2026-08-25
**Task:** TASK-20260824-YOLO2-P1 — YOLO 2.0 Phase 1 真实恢复纵向切片

## A. Blake Gate 3 knowledge verified?

✅ The knowledge file `patterns/memory-and-learning.md` and the new entries
below are written to `.tad/project-knowledge/`. See
`gate3-verdict.md` for the Gate 3 checks.

## B. New discoveries during implementation? YES

Three mechanism gaps were discovered by the real dogfood (each bought its own
fix — "机制必须由观测到的失败购买"):

### B1. Recovery packet did not carry the verification model (interruption-c)
- **Observation:** two independent fresh-context recoveries at the
  `before-recovery-packet` stage both scored soft 0.88 (< 0.90 floor), missing
  the same S3 anchor: "checkpoint is a candidate; only a bound Conductor
  receipt after the existing Gate and an independent review advances verified".
  The fact was unknowable from the allowed reading material (goal.json /
  journal.jsonl / recovery.md).
- **Fix:** `renderRecovery()` now emits a `VERIFICATION MODEL` section
  (commit `00570c00`).
- **Result:** the next recovery at that stage scored soft 1.00.

### B2. Recovery packet did not carry state-derived prohibitions (interruption-a)
- **Observation:** a fresh context scored soft 0.88 missing S4's
  "treating the uncommitted edit as done" — the packet said "observation, not
  authority" but never stated the prohibition.
- **Fix:** `renderRecovery()` now derives a `PROHIBITIONS` section from the
  run state (uncommitted work, pending action, outcome_unknown actions)
  (commit `0ccd30cd`).
- **Result:** interruption-a scored soft 1.00 on the next attempt.

### B3. Side-effect classification rule and re-apply rationale absent (interruption-b)
- **Observation:** two fresh contexts at `after-action-started` both missed
  S3's double-application rationale; one also hedged H5's outcome
  classification (said "candidate" instead of the hash-proven `confirmed`).
- **Fix:** the PENDING ACTION section now states the FR6 classification rule
  (hash == intended_post → confirmed; == pre → reconciled; else
  outcome_unknown); PROHIBITIONS states the double-application risk and the
  uncommitted-inspect-not-discard rule (commit `84c3666c`).
- **Result:** interruption-b scored hard 8/8, soft 1.00 on the next attempt.

### B4. General pattern worth distilling
The recovery capsule must carry not just facts but the run's *decision rules*
and *prohibitions* — a fresh context can re-derive facts from the journal, but
cannot re-derive rules the protocol owns (verification model, side-effect
classification, must-nots). Future YOLO phases should treat "which rules must
be in the packet" as a first-class design question, and the dogfood stages
should be designed to exercise each rule at least once.

## C. Where the entries live

- Written directly to `.tad/project-knowledge/` — see
  `patterns/memory-and-learning.md` for the four-layer context and the
  `principles.md` entry `Mechanism Is Bought by Observed Failure` (proposed via
  this assessment; Alex/Gate 4 to confirm the distillation).