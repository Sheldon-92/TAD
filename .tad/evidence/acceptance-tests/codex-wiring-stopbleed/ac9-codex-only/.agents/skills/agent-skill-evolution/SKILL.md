---
name: agent-skill-evolution
description: "Agent skill evolution capability pack. Gives AI agents the judgment rules for building self-improving agents — architecture decisions (fixed vs evolvable instruction), training loop design (rollout→reflect→edit→gate), edit safety (bounded edit, LR schedule, protected regions), validation gates, offline consolidation (sleep cycles), and multi-timescale memory. Research-grounded rules from SkillOpt (Microsoft, arXiv 2605.23904), SkillOpt-Sleep, and EmbodiSkill. Use for any self-evolving agent design, skill optimization pipeline, or agent self-improvement task."
keywords: ["self-evolving agent", "自演化", "skill optimization", "prompt optimization", "self-improvement", "自我改进", "validation gate", "验证门", "bounded edit", "protected regions", "sleep cycle", "离线学习", "offline learning", "offline consolidation", "training loop", "训练循环", "SkillOpt", "text-space optimization", "experience replay", "multi-timescale memory", "agent learning"]
type: reference-based
---

**CONSUMES**: Agent description + self-improvement requirements + optional existing skill/memory docs + evaluation setup (held-out set, success metric)
**PRODUCES**: Applied self-evolution judgment rules + architecture decision + training loop design + safety mechanism review + gate configuration guidance

# Agent Skill Evolution Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code / Codex / Copilot / OpenClaw (via SkillOpt-Sleep adapters)
**License**: Apache 2.0

---

## What This Pack Does

AI agents asked to "learn from experience" or "improve over time" default to vague suggestions: "add a feedback loop," "fine-tune the model," or "log failures and iterate." These miss the engineering reality: an agent modifying its own instructions without a validation gate, edit budget, and protected regions is not learning — it is drifting. SkillOpt's empirical evidence: ungated self-modification collapsed accuracy from **0.554 to 0.026 (−52.8 percentage points)** over 5 nights.

This pack embeds the judgment rules from SkillOpt (Microsoft, arXiv 2605.23904) — the first production-grade framework for text-space skill optimization, proven across 6 benchmarks, 7 models, and 3 harnesses (all 52 cells best/tied-best, with improvements of **+23.5, +24.8, +19.1 pts** on key benchmarks). The rules cover architecture decisions, training loop design, edit safety, validation gates, offline consolidation (sleep cycles), and multi-timescale memory.

**Pack = self-evolution judgment. Your orchestration system = process constraints. No overlap.**

---

## Cross-Cutting Rule: No Gate = No Evolution

> **An agent modifying its own instructions without a held-out validation gate is not learning — it is drifting.** SkillOpt evidence: ungated self-modification collapsed accuracy from 0.554 to 0.026 (−52.8 pts) over 5 nights. The gate uses strictly-greater-than acceptance (VG1) — a tie means reject. Without this, every self-modification risks catastrophic forgetting that accumulates silently until the agent is unusable.

This rule overrides all others. If you cannot implement a validation gate (no held-out set, no checkable metric), do NOT build a self-evolving agent — maintain the skill manually instead.

---

## Quick Rule Index

| ID | Rule | Reference |
|----|------|-----------|
| AD1 | Checkable correctness signal required | `references/architecture-decisions.md` |
| AD2 | Fixed vs Evolvable instruction (gate+budget+regions+staging) | `references/architecture-decisions.md` |
| AD3 | Online vs Offline consolidation (offline+gate safer) | `references/architecture-decisions.md` |
| AD4 | Single-model vs Dual-model architecture | `references/architecture-decisions.md` |
| TL1 | Six-stage pipeline contract (rollout→reflect→aggregate→select→update→gate) | `references/training-loop.md` |
| TL2 | Reflect modes — shallow (per-trajectory) vs deep (cross-trajectory) | `references/training-loop.md` |
| TL3 | Hierarchical aggregate — failure patches priority | `references/training-loop.md` |
| TL4 | Contrastive reflection — K≥3 rollouts, spread-based selection, cache key includes rollout index | `references/training-loop.md` |
| ES1 | Edit mode selection — patch > rewrite_from_suggestions > full_rewrite | `references/edit-safety.md` |
| ES2 | LR schedule — cosine > constant; 2-4 epochs sufficient | `references/edit-safety.md` |
| ES3 | Protected regions — marker-based write isolation, 4-layer enforcement | `references/edit-safety.md` |
| ES4 | Lapse vs Defect classification (EXECUTION_LAPSE vs SKILL_DEFECT) | `references/edit-safety.md` |
| VG1 | Strictly-greater-than acceptance (tie = reject) | `references/validation-gate.md` |
| VG2 | Metric selection — hard/soft/mixed; mixed most stable for small validation sets | `references/validation-gate.md` |
| VG3 | Selection cache by SHA content hash — skip redundant validation rollouts | `references/validation-gate.md` |
| VG4 | Longitudinal 4-quadrant comparison (improved/regressed/persistent_fail/stable_success) | `references/validation-gate.md` |
| OC1 | Six-stage Sleep pipeline (harvest→mine→replay→consolidate→stage→adopt) | `references/offline-consolidation.md` |
| OC2 | Harvest is read-only — never modify source transcripts | `references/offline-consolidation.md` |
| OC3 | Heuristic miner (free, deterministic) vs LLM miner (accurate, costs API) | `references/offline-consolidation.md` |
| OC4 | Experience replay — associative recall via token Jaccard, recall_k=10/20 | `references/offline-consolidation.md` |
| OC5 | Dream augmentation — synthetic variants expand training only, never validation | `references/offline-consolidation.md` |
| OC6 | "Nothing live changes" — staging dir + backup + explicit adopt | `references/offline-consolidation.md` |
| OC7 | Task guardrail — inject target's output contract into reflect prompt | `references/offline-consolidation.md` |
| MT1 | Three memory tiers — step buffer / slow update / meta skill | `references/multi-timescale-memory.md` |
| MT2 | Write isolation — step-level edits cannot modify epoch-level guidance | `references/multi-timescale-memory.md` |
| MT3 | Appendix consolidation — accumulate lapse notes, LLM-compact at threshold (15-20 notes) | `references/multi-timescale-memory.md` |
| SI1 | Claude Code plugin — install, configure, schedule (3:17 AM cron), mock backend for testing | `references/skillopt-sleep-integration.md` |
| SI2 | Cross-platform plugin shells — one engine, thin per-platform adapters | `references/skillopt-sleep-integration.md` |
| SI3 | Safety contract — harvest read-only, nothing live changes, staging + adopt | `references/skillopt-sleep-integration.md` |

---

## Step 0: Context Detection

When the user mentions self-improvement for an agent, detect the context and load the relevant reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "should this agent learn", "self-evolving", "自演化", "自我改进", "improve over time", "learn from experience" | `references/architecture-decisions.md` |
| "training loop", "训练循环", "rollout", "reflect", "pipeline", "epoch", "step" | `references/training-loop.md` |
| "edit safety", "bounded edit", "learning rate", "LR schedule", "protected region", "lapse", "defect", "EXECUTION_LAPSE", "SKILL_DEFECT" | `references/edit-safety.md` |
| "validation gate", "验证门", "held-out", "accept", "reject", "gate metric", "mixed metric" | `references/validation-gate.md` |
| "sleep cycle", "离线学习", "offline", "consolidation", "harvest", "dream", "replay", "staging", "adopt" | `references/offline-consolidation.md` |
| "memory tier", "multi-timescale", "appendix", "step buffer", "meta skill", "slow update" | `references/multi-timescale-memory.md` |
| "install SkillOpt", "plugin", "cron", "schedule", "Claude Code plugin", "Codex plugin", "mock backend" | `references/skillopt-sleep-integration.md` |

---

## Step 1: Apply Rules

1. **Read the referenced file(s)** — each reference contains rules with IDs (AD1, TL1, etc.), source citations, and SkillOpt evidence data.
2. **Apply rules to the user's specific scenario** — adapt the general principles to their agent, evaluation setup, and platform constraints.
3. **Cite specific numbers** when they're relevant — the pack's value is in the research-grounded specifics, not the general principles. A rule without its number is a generic suggestion.

---

## Step 2: Output

Structure your response around the user's needs:
- **Architecture decision**: Use AD1-AD4. End with a clear recommendation (build self-evolving / keep fixed / hybrid).
- **Pipeline design**: Use TL1-TL4. Show the six-stage flow with their specific choices.
- **Safety review**: Use ES1-ES4 + VG1-VG4. Verify all four safety mechanisms are present (use `scripts/gate-check.sh` as a checklist).
- **Integration guide**: Use SI1-SI3. Platform-specific setup steps.

---

## Anti-Skip Table

| Agent might think... | Why it's wrong |
|---------------------|---------------|
| "The feedback loop is obvious — just log failures and iterate" | A feedback loop without a validation gate is unguarded drift. SkillOpt evidence: −52.8 pts over 5 nights without the gate (AD2). |
| "We can fine-tune the model instead of editing the prompt" | Text-space skill optimization (editing the prompt/SKILL.md) has zero inference-time overhead and works across models. Fine-tuning requires training infrastructure, model access, and redeployment. Different problems. |
| "Protected regions are overkill — the gate catches regressions" | The gate's held-out set may not cover every protected behavior. 4-layer defense (ES3) catches what the gate misses. One layer is not enough (~5% failure rate per layer). |
| "We don't need staging — the gate already validates" | The gate validates on the held-out set. Staging + human review catches qualitative issues the gate can't measure (confusing wording, style drift, off-brand tone). OC6. |

---

## Tool Quick Reference

### SkillOpt (recommended reference implementation)

```bash
pip install skillopt
# Key commands:
skillopt train --config config.yaml     # run the 6-stage training loop
skillopt evaluate --skill SKILL.md      # run validation gate on held-out set
skillopt sleep --config sleep.yaml      # run overnight consolidation cycle
skillopt adopt                          # promote staged skill to live
# Mock test (zero API cost):
python -m skillopt_sleep run --backend mock
```

- **Repository**: github.com/microsoft/SkillOpt (7,761 stars)
- **Paper**: arXiv 2605.23904
- **When to use**: As the training engine for agents with checkable metrics. The pack teaches the judgment rules; SkillOpt is one production implementation.
- **When NOT to use**: For agents without a checkable correctness signal (AD1). For subjective quality tasks, consider LLM-as-judge with calibrated agreement (ICC > 0.80) as a proxy metric.
