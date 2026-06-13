# LoRA / QLoRA Fine-Tuning Rules

> Loaded on signal: fine-tune, 微调, LoRA, QLoRA, train model, 训练模型, personality clone.
> Concrete decision parameters. Numbers are research-grounded — sources cited per section.

---

## When to Fine-Tune (dataset-size → task threshold)

Replaces "more is better" intuition. Research-grounded thresholds (sitepoint 2026,
retrieved 2026-06-13):

| Examples | Verdict |
|---|---|
| < 100 | **Do NOT fine-tune.** Use few-shot prompting or RAG. Below the practical floor. |
| 100 (practical floor) | Minimum viable for narrow classification/format tasks. |
| ~500 curated | Specializes a frontier model on a **~$300 GPU budget**. Sweet spot for most domain/style tasks. |
| 500–10,000 | Recommended working range. Format = ChatML / ShareGPT / Alpaca, with dedup + length filtering. |
| > 10,000 | Diminishing returns unless complex domain shift / multi-task. |

**Quality-over-quantity rule**: 500 clean examples outperform 5,000 noisy ones.
Always dedup + length-filter before counting (see `data-preparation.md`).
Source: https://www.sitepoint.com/fine-tune-local-llms-2026/ (retrieved 2026-06-13)

---

## VRAM Requirements (method × precision)

| Method | 7-8B model VRAM | Notes |
|---|---|---|
| QLoRA 4-bit | ~6 GB | base quantized to 4-bit; ~75% VRAM cut vs LoRA 16-bit |
| LoRA 8-bit | ~10 GB | |
| LoRA 16-bit | ~16 GB | full-precision adapters on bf16 base |

**Unsloth selective gradient checkpointing** cuts VRAM a further **~30% at +1.9% time cost**
and enables **4× longer context**; **~70% VRAM reduction overall** vs vanilla HF:
- 20B model fits in **14 GB**.
- 8B fine-tunes in **<10 GB** at seqlen ≤512 / batch 1.
- **2–5× speedup** vs vanilla HF Trainer.

Enable with the exact flag:
```python
use_gradient_checkpointing = "unsloth"   # NOT True — the string enables selective recompute
```
Source: https://unsloth.ai/blog/long-context (retrieved 2026-06-13)

Map VRAM → hardware in `platform-selection.md`; VRAM → dollars in `cost-estimation.md`.

---

## LoRA vs QLoRA Quality/VRAM Tradeoff

| Method | Trains | VRAM | Quality recovered (vs full-FT) |
|---|---|---|---|
| LoRA | 0.1–1% of params | baseline | **90–95%** |
| QLoRA | 0.1–1% of params + 4-bit base | ~75% less | **80–90%** |

**2026 default starting config**: `r=16 + DoRA + target_modules="all-linear"` (the 7 linear
modules: `q_proj, k_proj, v_proj, o_proj, gate_proj, up_proj, down_proj`).
Source: https://dev.to/jangwook_kim_e31e7291ad98/fine-tune-llms-with-lora-and-qlora-2026-guide-33lf (retrieved 2026-06-13)

---

## Rank Selection (r) + alpha rule

| Rank r | Use case |
|---|---|
| 8 | Simple style / format adaptation |
| 16 | **Default** — instruction tuning, style, most domain tasks |
| 32–64 | Complex domain shift / multi-task / **10,000+ examples** |
| 128 | Rare; heavy domain rewrite only |

Suggested r set: **{8, 16, 32, 64, 128}**.

**Alpha rule** (do not skip — controls update magnitude):
- `alpha = r` → 1.0 scaling, **stable** (recommended default).
- `alpha = 2r` → aggressive scaling, faster adaptation, higher overfit risk.

Source: https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide (retrieved 2026-06-13)

---

## Learning Rate (SFT vs preference tuning differ ~40×)

| Objective | Learning rate | Notes |
|---|---|---|
| LoRA / QLoRA SFT | **2e-4** | default |
| DPO / GRPO (preference) | **5e-6** | ~40× lower; extremely LR-sensitive |
| DPO search range | **1e-6 → 8e-6** | sweep if unstable |

Do NOT reuse the 2e-4 SFT LR for preference tuning — it will diverge.
Source: https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide (retrieved 2026-06-13)

---

## Overfitting Tripwires & Training Budget

| Knob | Value | Rationale |
|---|---|---|
| Train loss floor | **< 0.2 → likely overfitting** | stop / reduce epochs |
| Epochs | **1–3** | >3 = diminishing returns + overfit risk |
| Effective batch size | **4–16** (e.g. batch 2 × grad-accum 8 = 16) | |
| Weight decay | **0.01–0.1** | |
| Warmup | **5–10% of total steps** | |
| LoRA dropout | **0** default (range 0–0.1) | |

Source: https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide (retrieved 2026-06-13)

Validate your config against VRAM budget with `scripts/vram-fit.sh`.

---

## Preference Tuning (DPO / GRPO) — was entirely absent before

Use after SFT, when you have preference pairs (chosen/rejected) — see `data-preparation.md`.

**DPO config:**
- `beta = 0.1` default (range **0.05–0.5**) — controls deviation from the reference model.
- Learning rate **5e-6** (range 1e-6 → 8e-6).

**GRPO reference config** (RL post-training):
- LR **5e-7**, batch **16**, **~2k steps**, `beta = 0`, `epsilon = 0.2`,
  single epoch per batch.

Source: https://www.together.ai/blog/direct-preference-optimization (retrieved 2026-06-13)

---

## Tool Comparison (version-pinned — B2 timeliness)

| Tool | Version (date) | Pick when |
|---|---|---|
| **Unsloth** | current | Minimal setup / Colab notebook; 70% less VRAM; single-GPU |
| **Axolotl** | **v0.17.0 (2026-06-03)** | RL / post-training pipeline; single YAML; FSDP1/2 + DeepSpeed; Sequence Parallelism; multipack/sample-packing; GRPO/GDPO/DPO/IPO/KTO/ORPO; Flash Attention 2/3/4; Liger Kernel; Cut Cross Entropy |
| **LlamaFactory** | **v0.9.4 (2025-12-31)** | GUI + broadest models (68.4K stars); uv migration; OFT + Megatron-LM + KTransformers; unique DoRA / LoRA+ / PiSSA / KTO / ORPO; LlamaBoard no-code UI |

Routing: minimal/notebook → **Unsloth**; RL/post-training → **Axolotl**; GUI + broadest models → **LlamaFactory**.
Sources: https://github.com/axolotl-ai-cloud/axolotl ,
https://www.jenova.ai/en/resources/llama-factory-complete-guide-to-llm-fine-tuning (retrieved 2026-06-13)

---

## Cross-references
- Hardware/platform for the VRAM you need → `platform-selection.md`
- Dataset format + dedup → `data-preparation.md`
- GPU-hour cost of your config → `cost-estimation.md`
