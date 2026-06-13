# Phase 2 Behavioral Discriminative Eval — ml-training Pack

**Date**: 2026-06-13
**Pack**: ml-training (v0.1.0)
**Fixture**: `.claude/skills/ml-training/examples/lora-config-decision.md`
**Method**: WITH-PACK vs CONTROL answer, discriminative-pattern grep count

---

## Fixture parameters

- `discriminative_pattern`: `alpha ?= ?2?r|2e-4|5e-6|5e-7|use_gradient_checkpointing|unsloth|all-linear|beta ?= ?0\.1|22\.4|12-hr|0\.2 ?.*overfit|train(ing)? loss.*0\.2|v0\.17\.0|v0\.9\.4|\$0\.34|A100 80GB|500 clean`
- `min_discriminative`: 4
- Scenario: "Fine-tune Qwen-8B to mimic my writing style. ~350 real chat messages, an 8GB
  MacBook, ~$20 budget. Might want preference tuning later. What config, platform, tool?"

---

## WITH-PACK answer

Applied `SKILL.md` Step 2 decision entry + `lora-finetune.md`, `platform-selection.md`,
`data-preparation.md` rules. Covered: 8GB Mac → cloud mandatory; QLoRA 4-bit ~6GB fits T4;
Colab Free 22.4 hr/week + 12-hr cap; RTX 4090 $0.34/hr; Unsloth
`use_gradient_checkpointing="unsloth"`; r=16 / all-linear / alpha=r vs alpha=2r; SFT 2e-4 vs
DPO 5e-6 / GRPO 5e-7 / beta=0.1; train-loss-below-0.2 overfit tripwire; 350<500 → AI bootstrap,
500 clean > 5000 noisy; Axolotl v0.17.0 / LlamaFactory v0.9.4 routing.

## CONTROL answer (generalist, no pack)

Generic: "use a cloud GPU (Colab/RunPod/Lambda)", "use LoRA/QLoRA", "pick a reasonable rank
like 8 or 16", "learning rate in the usual range", "HF PEFT/transformers", "clean your data,
remove duplicates", "look into DPO later". No alpha rule, no LR split, no Unsloth flag, no Colab
quota numbers, no tool versions, no price anchors.

---

## Discriminative count (grep -oE PATTERN | sort -u | wc -l)

| Answer | Unique markers | Markers matched |
|---|---|---|
| **WITH-PACK** | **16** | $0.34, 12-hr, 22.4, 2e-4, 500 clean, 5e-6, 5e-7, all-linear, alpha = 2r, alpha = r, beta = 0.1, training loss drops below 0.2, unsloth, use_gradient_checkpointing, v0.17.0, v0.9.4 |
| **CONTROL** | **0** | (none) |

---

## Verdict

| Check | Threshold | Result | Pass |
|---|---|---|---|
| with-pack disc ≥ min_discriminative | ≥ 4 | 16 | ✅ |
| control disc < min_discriminative | < 4 | 0 | ✅ |

**discriminative_pass = TRUE**

The pack produces 16 pack-specific, research-grounded markers a generalist does not emit
(alpha=2r scaling rule, 40x SFT/DPO LR split, Unsloth flag string, Colab 22.4 hr/week + 12-hr
cap, $0.34/hr 4090, version-pinned tool routing). The control, despite being a competent
generalist answer, scored 0 on the discriminative pattern — confirming the markers are
attributable to the pack, not to general knowledge. Strong separation (16 vs 0, gap of 12).
