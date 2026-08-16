---
Title: ML Training Capability Pack (Cloud GPU Focus)
Date: 2026-05-29
Status: promoted
Scope: large
---

# IDEA: ML Training Capability Pack

## Summary & Problem
Users want to fine-tune LLMs (Qwen/LLaMA/Mistral) and train voice/audio models but lack judgment rules for: which cloud GPU platform to use, LoRA vs full fine-tune, data preparation, cost estimation, and model export. Current TAD packs cover inference and tool usage, not training workflows.

## Origin
Colin voice project discussion. User discovered cloud GPU unlocks many previously-stalled ideas: voice cloning training, LLM fine-tuning for personalized assistants, custom model training. Refined from original "Cloud GPU + LLM Fine-Tune" idea after *discuss — split deployment out, narrowed to training focus.

## Proposed Capabilities
1. **Cloud GPU Platform Selection** — free (Colab/Kaggle/Lightning) vs paid (RunPod/Vast.ai/Lambda/Modal), decision rules based on task type x data size x budget. Anti-slop value: specific platform limits and pricing that change frequently.
2. **LLM Fine-Tune Workflow** — LoRA/QLoRA judgment (when to use, parameter selection), base model selection by language/task, training data preparation, hyperparameter guidance tied to GPU memory.
3. **Cost & Resource Estimation** — GPU memory requirements by model size (7B/13B/70B), training time estimates, cost comparison tables.

## Explicitly NOT in scope
- Model deployment/serving (separate concern, partially covered by web-deployment pack)
- Voice/audio model training (stays in ai-voice-production pack)
- Image model training (future separate pack if needed)

## CONSUMES / PRODUCES
- CONSUMES: user requirements (model type, data size, budget, hardware constraints)
- PRODUCES: platform recommendation, training configuration, cost estimate, runnable notebook

## Open Questions
- Need deep research phase (research-methodology) to fill anti-slop data (platform limits, pricing, GPU specs)
- Relationship with ai-voice-production: cloud training rules in voice pack reference this pack's platform selection?
- Include Colab/Kaggle notebook templates as reference files?

## Potential Scope
Large — needs research phase + 3 capabilities + reference files with frequently-changing data

## Promoted To
Promoted To: Epic (via *analyze — 2026-05-29)
