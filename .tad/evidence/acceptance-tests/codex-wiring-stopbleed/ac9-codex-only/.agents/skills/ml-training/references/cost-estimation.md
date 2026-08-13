# GPU-Hour Cost Estimation Rules

> Loaded on signal: cost, 成本, pricing, 多少钱, budget, GPU hours.
> 2026 price anchors + estimation formula. Compute with `scripts/cost-estimate.sh`.

---

## Cost Formula

```
cost = gpu_hourly_rate × estimated_hours
estimated_hours = (steps × seconds_per_step) / 3600
steps ≈ (num_examples × epochs) / effective_batch_size
```

Use `effective_batch_size` and `epochs` from `lora-finetune.md` (batch 4–16, epochs 1–3).
`scripts/cost-estimate.sh` does this arithmetic deterministically — do NOT eyeball it.

---

## Cloud GPU Price Anchors (2026)

| Provider / card | Price | Tier |
|---|---|---|
| RunPod Community **RTX 4090** | from **$0.34/hr** | spot/community |
| RunPod Community **A100 80GB** | from **$0.89/hr** | spot/community |
| RunPod **H100 PCIe** | from **$2.89/hr** | on-demand |
| **H100 SXM5** spot | ~**$1.19/hr** | spot |
| RunPod **Secure A100 80GB** | from **$1.89/hr** | secure (no preempt) |
| **Vast.ai A100 80GB** | ~**$0.67/hr** | marketplace (reliability variable) |
| Broad market **H100** | from **$1.03/hr** | 15+ providers |
| Broad market **B200** | from **$2.12/hr** | 15+ providers |

Sources: https://www.spheron.network/blog/gpu-cloud-pricing-comparison-2026/ ,
https://www.spheron.network/blog/axolotl-vs-unsloth-vs-torchtune/ (retrieved 2026-06-13)

---

## "Can I Do It Free?" Decision Tree

1. VRAM ≤ 16GB (QLoRA 4-bit, 7-8B)? → **Yes**: Colab Free / Kaggle viable.
2. Total wall-clock ≤ 12 hr AND ≤ weekly quota (Colab ~22 hr/wk, Kaggle 30 hr/wk)? →
   **Yes**: free tier works. **No**: checkpoint+resume or go paid.
3. Need >16GB VRAM OR uptime-critical? → **Paid** (RunPod / Lambda).

The ~$300-budget rule: **~500 curated examples on a ~$300 GPU budget** specializes a
frontier model (sitepoint 2026) — most domain tasks land well under $50 on a 4090.

---

## Worked Example

500 examples × 2 epochs / batch 8 = 125 steps. At ~3 s/step ≈ 375 s ≈ 0.1 hr on a 4090.
RTX 4090 @ $0.34/hr → **~$0.04**. Even a 70B QLoRA on H100 ($2.89/hr) for 6 hr = **~$17**.
Conclusion: data prep + dedup time dominates; raw GPU cost is rarely the constraint below 10K examples.

---

## Cross-references
- VRAM → card mapping → `platform-selection.md`
- Config knobs (epochs, batch) → `lora-finetune.md`
- Deterministic calculator → `scripts/cost-estimate.sh`
