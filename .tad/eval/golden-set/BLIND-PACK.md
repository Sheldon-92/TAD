# Blind Evaluation Pack

> Gate 4 protocol: Human evaluator scores these 3 trajectories INDEPENDENTLY
> using .tad/eval/rubric.md BEFORE seeing Blake's draft scores.
> Per-dimension divergence ≥2 → discuss and potentially revise rubric anchors.
> human_modifications: 0 in INDEX.md after this process = anchoring warning signal (DA P0-2).

---

## Trajectory A: sep-phase2

**Slug**: sep-phase2
**Date**: 2026-06-10
**task_type**: mixed
**Epic**: Self-Evolution Pruning Phase 2/3

### Artifact Inventory
- **Handoff**: `.tad/archive/handoffs/HANDOFF-20260610-sep-phase2.md` (13,872 bytes)
- **Completion**: `.tad/archive/handoffs/COMPLETION-20260610-sep-phase2.md` (6,342 bytes)
- **Acceptance tests**: `.tad/evidence/acceptance-tests/sep-phase2/gate4-report.md`
- **Reviews**: `.tad/evidence/reviews/blake/sep-phase2/` — 3 files: code-review.md, spec-compliance.md, sync-safety-analysis.md
- **Traces**: 3 events (handoff_created, task_completed, gate_result)

### Key Context Excerpts
- Handoff §1: "T1 in-session ceremony, harvest-scan.sh, release-verify FR7 (local-skill = INFO)"
- Completion AC table: 19/19 ACs listed
- Gate 4 history: PARTIAL on first round (rider noted); PASS on second round
- KA section: "No — T1 ceremony is a design execution, not a new discovery"

---

## Trajectory B: universal-gate-ac-driven

**Slug**: universal-gate-ac-driven
**Date**: 2026-06-07
**task_type**: code
**Epic**: N/A (standalone)

### Artifact Inventory
- **Handoff**: `.tad/archive/handoffs/HANDOFF-20260607-universal-gate-ac-driven.md` (15,234 bytes)
- **Completion**: `.tad/archive/handoffs/COMPLETION-20260607-universal-gate-ac-driven.md`
- **Acceptance tests**: None in `.tad/evidence/acceptance-tests/universal-gate-ac-driven/`
- **Reviews**: `.tad/evidence/reviews/blake/universal-gate-ac-driven/` — 4 files: cr-review.md, arch-review.md, gate3-verdict.md, acceptance-verification-report.md
- **Traces**: 7 events (4 decision_point, 1 handoff_created, 1 task_completed, 1 gate_result)

### Key Context Excerpts
- Handoff §1: "Convert Gate 3 from hardcoded dev checks to executing §9.1 row-by-row"
- Completion: 16/16 ACs PASS, gate3_verdict: pass
- AC10 (SAFETY count): spec-compliance reviewer judgment — "GENUINE, not padding" with arithmetic proof
- KA: "Yes — AC-Driven Universal Gate pattern" → written to patterns/gate-design.md
- Deviations: 3 noted (AC10 exact count, scope growth from Layer 2, no dogfood run)

---

## Trajectory C: codex-spike-phase0

**Slug**: codex-spike-phase0
**Date**: 2026-05-01
**task_type**: research
**Epic**: N/A (feasibility spike)

### Artifact Inventory
- **Handoff**: `.tad/archive/handoffs/HANDOFF-20260501-codex-spike-phase0.md`
- **Completion**: `.tad/archive/handoffs/COMPLETION-20260501-codex-spike-phase0.md`
- **Acceptance tests**: None
- **Reviews**: `.tad/evidence/reviews/blake/codex-spike-phase0/` — 2 files: code-reviewer.md, self-review.md
- **Traces**: None (pre-trace era)

### Key Context Excerpts
- Handoff §1: "Codex CLI feasibility spike — can Codex serve as independent reviewer for TAD?"
- Completion: AC self-verification table present
- Code-reviewer verdict: FAIL (3 P0) — pivot decision rule mismatch (P0-1), missing evidence files (P0-2), missing COMPLETION file at review time (P0-3)
- Self-review: 5 specific quality concerns flagged proactively (AC2 grep, time-box, P0.5 annotation, P0.3 FAIL honesty, pivot wording)
- KA: "Yes — multiple architecture discoveries" (Codex capabilities, sandbox constraints)

---

## Evaluation Instructions

1. Read `.tad/eval/rubric.md` for dimension definitions and anchor descriptions.
2. For each trajectory above, read the artifacts listed in the inventory.
3. Score each dimension D1-D5 independently (1-5, or UNRECOVERABLE if data insufficient).
4. Record scores and per-dimension rationale BEFORE seeing Blake's draft in `.tad/eval/golden-set/GS-*.md`.
5. Compare with Blake's draft. For any dimension with divergence ≥2:
   - Discuss: was the anchoring unclear, or did Blake/human weight different evidence?
   - If anchoring unclear: revise rubric anchor wording.
   - Record divergences in INDEX.md `blind_label_divergences` field.
6. Record `human_modifications` count in INDEX.md.
