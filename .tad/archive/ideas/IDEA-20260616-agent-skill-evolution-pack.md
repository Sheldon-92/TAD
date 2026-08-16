# Idea: New Capability Pack — agent-skill-evolution

**ID:** IDEA-20260616-agent-skill-evolution-pack
**Date:** 2026-06-16
**Status:** promoted
**Scope:** large
**Source:** Deep research of microsoft/SkillOpt (7,761 stars, arXiv 2605.23904)

---

## Summary & Problem

"Self-evolving agent" is a coherent engineering paradigm that cuts across memory,
evaluation, safety, and prompt design — but none of our 7 agent-related packs cover it.
SkillOpt (Microsoft, 2026) provides the first production-quality, experimentally-validated
reference implementation, proving +19~24 points improvement across 6 benchmarks and 7 models
with zero inference-time overhead.

This paradigm deserves its own capability pack, not scattered rules across existing packs.
Analogy: RAG is its own pack (`rag-retrieval`), not rules spread across data-engineering
and knowledge-graph. Self-evolving agent skills is the same — the pieces (training loop,
gate, edit modes, protected regions, multi-timescale memory, sleep cycle) form an
interdependent system that loses coherence when scattered.

## Relationship to Existing Packs

The new pack is parallel to the other agent capability packs, not a parent or child:

| Pack | Teaches |
|------|---------|
| agent-memory | How to give an agent memory (of user data) |
| agent-orchestration | How to coordinate multiple agents |
| ai-guardrails | How to make an agent safe |
| ai-evaluation | How to evaluate an agent's output quality |
| ai-tool-integration | How to connect an agent to tools |
| ai-prompt-engineering | How to write an agent's prompts |
| **agent-skill-evolution** | **How to make an agent improve its own instructions** |

No cross-references needed. No changes to existing packs. The packs address different
capabilities. When concepts share a name (e.g., "validation" in ai-evaluation vs in the
new pack), they answer different questions:
- ai-evaluation: "How does a HUMAN evaluate an agent's output?"
- agent-skill-evolution: "How does an AGENT evaluate its own instruction modifications?"

## Pack Structure

```
agent-skill-evolution/
  SKILL.md
  references/
    architecture-decisions.md    — AD1-AD4: should you build a self-evolving agent?
    training-loop.md             — TL1-TL4: rollout→reflect→aggregate→select→update→gate
    edit-safety.md               — ES1-ES4: bounded edit, LR schedule, protected regions, lapse vs defect
    validation-gate.md           — VG1-VG4: gate design, metric choice, cache, longitudinal 4-quadrant
    offline-consolidation.md     — OC1-OC7: Sleep cycle, harvest, mine, replay, staging, guardrails
    multi-timescale-memory.md    — MT1-MT3: step buffer / slow update / meta skill, write isolation
  scripts/
    gate-check.sh                — verify user's gate config completeness
```

## Cross-Cutting Rule (in SKILL.md body)

"No validation gate = no self-evolution. An agent modifying its own instructions without a
held-out validation gate is not learning — it is drifting. SkillOpt empirical evidence:
ungated self-modification collapsed accuracy from 0.554 to 0.026 (−52.8 pts) over 5 nights.
The gate is not an optimization — it is the safety mechanism."

## Rule Summary (22 rules across 6 references)

### architecture-decisions.md (4 rules)
- AD1: Checkable correctness signal required — no signal, no self-evolution
- AD2: Fixed vs Evolvable instruction — evolvable needs gate+budget+regions+staging
- AD3: Online vs Offline consolidation — offline+gate is safer (−52.8 disaster data)
- AD4: Single-model vs Dual-model — strong optimizer offline, weak target online

### training-loop.md (4 rules)
- TL1: Six-stage pipeline contract (rollout→reflect→aggregate→select→update→gate)
- TL2: Reflect modes — shallow (per-trajectory) vs deep (cross-trajectory systemic)
- TL3: Hierarchical aggregate — failure patches priority > success patches
- TL4: Contrastive reflection — K rollouts, spread-based selection, cache key must include rollout index

### edit-safety.md (4 rules)
- ES1: Edit mode selection — patch > rewrite_from_suggestions > full_rewrite (safety order)
- ES2: LR schedule — cosine > constant; 2-4 epochs sufficient for prompt convergence
- ES3: Protected regions — marker-based write isolation, 4-layer enforcement
- ES4: Lapse vs Defect classification before any skill modification

### validation-gate.md (4 rules)
- VG1: Strictly-greater-than acceptance (tie = reject)
- VG2: Metric selection — hard/soft/mixed; mixed most stable for small validation sets
- VG3: Selection cache by content hash — skip redundant validation rollouts
- VG4: Longitudinal 4-quadrant comparison (improved/regressed/persistent_fail/stable_success)

### offline-consolidation.md (7 rules)
- OC1: Six-stage Sleep pipeline (harvest→mine→replay→consolidate→stage→adopt)
- OC2: Harvest is read-only — never modify source transcripts
- OC3: Heuristic miner (deterministic, no API) vs LLM miner (accurate, costs API)
- OC4: Experience replay — associative recall via token Jaccard, not full-history replay
- OC5: Dream augmentation — synthetic variants expand train only, never val/test (anti-overfit)
- OC6: "Nothing live changes" contract — staging dir + backup + explicit adopt
- OC7: Task guardrail — inject target's output contract into reflect prompt

### multi-timescale-memory.md (3 rules)
- MT1: Three independent memory tiers — step buffer / slow update / meta skill
- MT2: Write isolation — step-level edits cannot modify epoch-level guidance regions
- MT3: Appendix consolidation — accumulate lapse notes, LLM-compact at threshold, fail-safe preserves original

## Evidence Sources

- SkillOpt paper: arXiv 2605.23904 (6 benchmarks, 7 models, 3 harnesses, all 52 cells best/tied-best)
- SkillOpt-Sleep: docs/sleep/RESULTS.md (gate stress test, experience replay scaling, dream diversity fix)
- SkillOpt source: skillopt/engine/trainer.py (~1,300 lines), skillopt/optimizer/*, skillopt/evaluation/gate.py
- SkillOpt-Sleep source: skillopt_sleep/ (4,239 lines), plugins/ (4 platform integrations)
- Trained skill artifacts: ckpt/ (6 benchmarks × GPT-5.5, 300-2000 tokens each)
- EmbodiSkill paper: arXiv 2605.10332 (EXECUTION_LAPSE vs SKILL_DEFECT classification)
- Full repo cloned at /tmp/SkillOpt

## Open Questions

- Should the pack reference SkillOpt as a recommended tool (like rag-retrieval references
  LlamaIndex), or only as evidence source for the rules?
- How to build the behavioral eval for this pack? Unlike web-backend (clear correct/wrong),
  self-evolution rules are harder to test discriminatively.
- Should the training-loop rules be prescriptive ("use this pipeline") or descriptive
  ("these are the proven patterns, adapt to your context")?

---
**Promoted To:** Handoff (via *analyze — 2026-06-17)
