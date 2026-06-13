---
name: lora-config-decision
description: "Tests LoRA/QLoRA config decisions — VRAM-fit on a budget card, rank+alpha rule, SFT vs DPO learning rate, dataset-size threshold, version-pinned tool routing"
pack: ml-training
tests_rules:
  - "lora-finetune.md: rank table + alpha rule (alpha=r stable / alpha=2r aggressive)"
  - "lora-finetune.md: SFT LR 2e-4 vs DPO/GRPO LR 5e-6 (~40x lower)"
  - "lora-finetune.md: Unsloth use_gradient_checkpointing='unsloth' (~30% extra VRAM cut)"
  - "data-preparation.md / lora-finetune.md: 500-example sweet spot, clean>noisy"
  - "platform-selection.md: Colab Free 22 hr/week median + 12-hr session cap"
  - "lora-finetune.md: version-pinned tool routing (Axolotl v0.17.0 / LlamaFactory v0.9.4)"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY ml-training-specific markers. A no-pack agent says "use LoRA,
# pick a reasonable rank, watch VRAM" — it does NOT produce alpha=2r, LR 5e-6 for DPO,
# use_gradient_checkpointing="unsloth", the 22 hr/week Colab quota, or version-pinned tool
# names. Excludes generic "fine-tune the model"/"use a GPU"/"clean your data".
discriminative_pattern: "alpha ?= ?2?r|2e-4|5e-6|5e-7|use_gradient_checkpointing|unsloth|all-linear|beta ?= ?0\\.1|22\\.4|12-hr|0\\.2 ?.*overfit|train(ing)? loss.*0\\.2|v0\\.17\\.0|v0\\.9\\.4|\\$0\\.34|A100 80GB|500 clean"
min_discriminative: 4
---

# Fixture: LoRA/QLoRA Config Decision on a Budget

## Input Scenario

"I want to fine-tune Qwen-8B to mimic my writing style. I have about 350 real chat
messages, an 8GB MacBook, and roughly $20 to spend. I might also want to do preference
tuning later. What config, what platform, and which tool should I use?"

## Expected Markers

When an AI agent processes the Input Scenario with the ml-training pack loaded, the
output MUST contain pack-specific markers such as:

1. **VRAM / platform routing** [pack-specific]: 8GB Mac can't do 8B LoRA 16-bit → cloud;
   QLoRA 4-bit ~6GB fits a T4; Colab Free viable but **~22.4 hr/week** quota + **12-hr**
   session cap; a 4090 is **$0.34/hr**.
   grep: `T4|Colab Free|22\.4|12-hr|\$0\.34|RTX 4090|6 ?GB`
2. **Rank + alpha rule**: r=16 default for style; **alpha = r** (stable) or **alpha = 2r**
   (aggressive); target_modules **all-linear**.
   grep: `r ?= ?16|alpha ?= ?2?r|all-linear`
3. **Learning rate split**: SFT **2e-4**; if doing DPO later, **5e-6** (~40× lower),
   beta 0.1.
   grep: `2e-4|5e-6|beta ?= ?0\.1`
4. **Unsloth VRAM trick**: `use_gradient_checkpointing="unsloth"` for ~30% extra cut.
   grep: `use_gradient_checkpointing|unsloth`
5. **Dataset-size threshold**: 350 < 500 sweet spot → AI-bootstrap synthetic pairs to reach
   ~500; **500 clean > 5,000 noisy**; dedup.
   grep: `500 clean|bootstrap|dedup|practical floor|100 example`
6. **Version-pinned tool routing**: minimal/notebook → Unsloth; RL/post-training → Axolotl
   **v0.17.0**; GUI/broad → LlamaFactory **v0.9.4**.
   grep: `v0\.17\.0|v0\.9\.4|Axolotl|LlamaFactory|Unsloth`

## Verification Command

```bash
grep -oE 'alpha ?= ?2?r|2e-4|5e-6|5e-7|use_gradient_checkpointing|unsloth|all-linear|beta ?= ?0\.1|22\.4|12-hr|v0\.17\.0|v0\.9\.4|\$0\.34|A100 80GB|500 clean' lora-config-decision-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

Pack-specific markers (would NOT appear without the pack):
- ✅ `alpha = 2r` aggressive scaling rule (Unsloth hyperparameter guide)
- ✅ DPO LR `5e-6` vs SFT `2e-4` (~40× split)
- ✅ `use_gradient_checkpointing="unsloth"` exact flag
- ✅ Colab Free `22.4 hr/week` measured median + `12-hr` session cap
- ✅ tool versions `v0.17.0` / `v0.9.4`
- ✅ `$0.34/hr` 4090 price anchor
- ❌ "use LoRA to fine-tune" (restates input, non-discriminative)
- ❌ "pick a reasonable rank" (generic, no alpha rule)
- ❌ "use a cloud GPU" (no platform/quota specifics)
- ❌ "clean your data" (generic without the 500-clean>5000-noisy threshold)
