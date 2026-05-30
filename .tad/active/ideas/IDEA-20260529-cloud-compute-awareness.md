---
Title: Cloud Compute Resource Awareness (Cross-Cutting)
Date: 2026-05-29
Status: promoted
Scope: small
---

# IDEA: Cloud Compute Resource Awareness

## Summary & Problem
TAD and its agent ecosystem implicitly assume "compute = local hardware". When a task requires GPU training or heavy inference, the agent tells the user "your machine can't handle this" and stops — instead of suggesting cloud GPU alternatives (Colab/Kaggle free, RunPod/Vast.ai paid).

This is a cognitive gap, not a tooling gap. The fix is embedding "cloud compute awareness" as a cross-cutting judgment rule into existing flows, similar to how Cognitive Firewall embeds research-before-decide into Alex's design phase.

## Origin
Colin voice project: user assumed voice training was impossible on 8GB Mac. Discovered Colab free GPU could do it. Realized many stalled ideas (voice cloning, LLM fine-tune, custom assistant training) were blocked by this false assumption.

## Proposed Approach
NOT a standalone pack. Instead, embed into existing mechanisms:
1. Alex Socratic inquiry: when user says "my machine can't run X", follow up with "have you considered cloud GPU?"
2. ai-voice-production pack: add rule "when local GPU insufficient for training, recommend Colab/Kaggle with specific notebook"
3. Future ML-related packs: default to cloud training, local for inference only
4. General judgment rule in project-knowledge or config: "hardware limitation is not a stop signal — cloud alternatives exist"

## Open Questions
- Where exactly to embed the rule (project-knowledge vs config-cognitive vs pack-level)?
- Should this be a single entry in architecture.md or a reference file?

## Potential Scope
Small — cross-cutting rule insertion, not new pack creation

## Promoted To
Promoted To: Handoff (via *analyze — 2026-05-29)
