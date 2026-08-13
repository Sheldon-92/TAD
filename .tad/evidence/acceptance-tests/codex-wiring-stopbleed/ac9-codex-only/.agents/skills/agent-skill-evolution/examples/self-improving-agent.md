---
discriminative_pattern: "held.out.*gate|strictly.greater.than|bounded.edit.*LR|EXECUTION_LAPSE|SKILL_DEFECT|cosine.*schedule|protected.region.*marker|\.prev\.md|recall_k|contrastive.*reflect|dream.rollout|staging.*adopt"
min_discriminative: 6
---

## Scenario

You are designing an AI coding assistant that should get better at your recurring tasks over time. It currently runs on Claude Code with a SKILL.md file. You want it to learn from your past sessions and automatically improve its instructions — but you need it to never get worse at things it already does well. Design the self-improvement system.

## Expected Discrimination

**WITH-PACK** answers should include specific mechanisms:
- Validation gate with held-out set (strictly-greater-than acceptance)
- Bounded edit mode with cosine learning rate schedule
- EXECUTION_LAPSE vs SKILL_DEFECT classification
- Protected region markers for safety-critical instructions
- Staging directory with .prev.md backup + explicit adopt
- Experience replay with recall_k for associative recall
- Contrastive reflection across K rollouts

**CONTROL** answers typically suggest:
- "Add a feedback loop" (no gate mechanism)
- "Fine-tune the model" (conflates prompt optimization with model training)
- "Log failures and iterate" (no formal training pipeline)
- "Use reinforcement learning" (wrong abstraction for text-space skill optimization)
