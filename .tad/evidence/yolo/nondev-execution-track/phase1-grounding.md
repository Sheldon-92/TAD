# Phase 1 Grounding — Non-Dev Execution Track

> Conductor (Alex) read these real files before designing the contract. Per TAD file-as-source-of-truth.

## Read at 2026-05-31

### gate/SKILL.md Gate 3 (lines 94-233) — the code-shaped gate to augment
Gate 3 hard-wires, all BLOCKING:
- **Prerequisite**: COMPLETION-*.md must exist (gate/SKILL.md:100-120). → KEEP for deliverable (still need completion report).
- **Required_Subagent: test-runner** (124-141), output to `.tad/evidence/reviews/{date}-testing-review-{task}.md`. → REPLACE for deliverable: spawn a **judge sub-agent** that scores the deliverable against the pack rubric, output to `.tad/evidence/reviews/{date}-rubric-eval-{task}.md`.
- **Acceptance_Verification** (143-166): acceptance-verification-report.md, FAIL count = 0, AC count matches. → KEEP (ACs still apply; deliverable ACs are about the artifact).
- **Risk_Translation** (168-198): cognitive firewall. → KEEP (orthogonal).
- **Git_Commit_Verification** (200-219): commit hash must be real OR doc-only. → KEEP (deliverable artifacts get committed too).
- **Critical Check (5 items)** (222-227): "Code complete / Tests pass / Standards met / Evidence file exists / KA complete". → for deliverable: "Deliverable complete / **Rubric score ≥ threshold** / Artifact present / Rubric-eval evidence exists / KA complete".

**Key insight**: the only items that are genuinely code-specific are the `test-runner` subagent and the "Tests pass / Standards met (lint)" critical-check lines. EVERYTHING ELSE (completion report, acceptance verification, git commit, risk translation, KA) applies unchanged to deliverables. So the branch is SMALL and surgical: swap test-runner→judge, swap tests-pass→rubric-score. This confirms D1 (augment-not-replace) is the right shape and the blast radius is contained.

### academic-research/SKILL.md:145-146 — informal contract already exists
> | **Gate 3** | Verifies citation integrity (zero-hallucination 4-point check) + ScholarEval score ≥ 0.75 for Accept |
> | **Gate 4** | Verifies research completeness per tier (did Blake reach minimum phase + tool-call threshold?) |

This is the EXACT contract to formalize. The pack already "knows" its gate semantics; the central machinery just can't route to them. Phase 1 makes this routable.

### scholar-eval.md — the concrete rubric (the dogfood judge will use this in Phase 3)
8 weighted dimensions (Rigor 25% / Impact 20% / Novelty 15% / Reproducibility 15% / Clarity 10% / Coherence 10% / Limitations 3% / Ethics 2%), each scored 0-1, weighted average → verdict. Thresholds: ≥0.75 Accept, ≥0.60 Minor Revision, ≥0.40 Major Revision, <0.40 Reject. → deliverable Gate 3 pass_threshold for academic-research = 0.75; 0.60-0.75 = PARTIAL.

### experiment_path_protocol (alex/SKILL.md) — the augment precedent
`*experiment` AUGMENTS Gate 3/4 with experiment-validity checks; "Original Gate 3 v2 STILL APPLIES". Same pattern for deliverable: the deliverable branch REPLACES the code-specific checks (test-runner, tests/lint) but the rest of Gate 3 still applies. (Note: experiment AUGMENTS; deliverable REPLACES the code-specific subset + KEEPS the rest. Subtle but the precedent for "task_type drives gate behavior" holds.)

### handoff/completion frontmatter
`task_type: code | yaml | research | e2e | mixed`. Add `deliverable`. Note `research` already exists but its Gate 3 never branched — so `research` work was ALSO shoe-horned. Decision for Phase 1 to settle: does `research` fold into `deliverable`, or stay separate? (Lean: `deliverable` is the new lane; `research` stays for "research that feeds a code handoff"; academic-research deliverables use `deliverable`.)

## Files Phase 2 will edit (no edits in Phase 1)
- CREATE `.tad/templates/deliverable-handoff.md`, `.tad/templates/deliverable-completion.md`
- MODIFY `.claude/skills/gate/SKILL.md` (Gate 3 + Gate 4 deliverable branch)
- MODIFY `.claude/skills/blake/SKILL.md` (deliverable execution lane)

## Open decisions for the contract author to resolve
1. Where does the pack→rubric map LIVE? (new `.tad/capability-packs/deliverable-rubrics.yaml` registry vs each pack's frontmatter). Lean: a small registry, name-keyed, mirroring behavioral-eval-status.yaml side-file pattern (so scan-packs regen doesn't clobber it).
2. How is the judge sub-agent guaranteed ≠ producer? (Conductor/gate spawns judge fresh, prompt references artifact path + rubric path only; producer identity not reused.)
3. `research` vs `deliverable` task_type relationship (see above).
