# Cost Estimation — Cloud GPU Training Costs

> Judgment rules for estimating end-to-end training costs. Covers VRAM-to-platform mapping, time estimates, and hidden costs beyond GPU hours.

---

## "Can I Do It Free?" Decision Tree

**Step 1: Check VRAM requirement**
- 4-bit QLoRA 7B → 6GB → Free tiers work (T4 16GB, P100 16GB)
- 8-bit QLoRA 7B → 10GB → Free tiers work
- 16-bit LoRA 7B → 16GB → Free tiers tight, Pro recommended
- VoxCPM2 → ~22GB → Free tier OOM, need A100 or RTX 4090

> Source: Round 1 + Colin dogfood 2026-05-29, deep-ask-findings.md

**Step 2: Check job duration**
- <12h → Colab Free session limit OK
- <30h/week → Kaggle quota OK
- >12h single session → Need paid (RunPod/Vast.ai) or Colab Pro

> Source: Rounds 5, 8, deep-ask-findings.md

**Step 3: Check .edu status**
- Have .edu email → Colab Pro free, A100 access
- No .edu → Free tier (T4/P100) or paid

> Source: Colin dogfood 2026-05-29, deep-ask-findings.md

---

## VRAM-to-Cost Mapping

Reference `platform-selection.md` for raw platform pricing. This section provides cost estimation RULES, not a duplicate pricing table.

### Total Cost Formula

```
Total cost = GPU hours × hourly rate
           + storage fees (RunPod: $0.20/GB/month even when stopped)
           + egress fees (hyperscalers: $0.08-0.12/GB outbound)
           + minimum billing (Lambda: 1h minimum)
```

> Source: Round 2, deep-ask-findings.md

### LLM Training Estimates (7B QLoRA 4-bit, 1K samples, 3 epochs)

| Platform | Est. Time | Cost | Free? |
|----------|-----------|------|-------|
| Colab Free (T4) | 4-8h | $0 | Yes |
| Colab Pro (A100) | 1-4h (1-2h w/ Unsloth) | $10-50/mo (.edu free) | .edu yes |
| Kaggle (P100) | 4-8h | $0 | Yes (30h/week) |
| RunPod (RTX 4090) | 1-4h (1-2h w/ Unsloth) | $0.34-1.76 | No |
| Vast.ai (RTX 4090) | 1-4h (1-2h w/ Unsloth) | $0.15-2.20 | No |

> Source: Round 8, deep-ask-findings.md

### Voice Training Estimates (full LoRA)

| Platform | GPU | VRAM | Est. Time | Cost | Free? |
|----------|-----|------|-----------|------|-------|
| Colab Free | T4 | 16GB | 4-8h | $0 | Yes |
| Colab Pro | A100 | 40-80GB | 2-4h (1-2h w/ Unsloth) | $10-50/mo (.edu free) | .edu yes |
| Kaggle | P100 | 16GB | 4-8h | $0 | Yes |
| RunPod | RTX 4090 | 24GB | 1-2h (w/ Unsloth) | $0.68-1.76 | No |
| Vast.ai | RTX 4090 | 24GB | 1-2h (w/ Unsloth) | $0.30-2.20 | No |

> Source: Round 5, deep-ask-findings.md

---

## Hidden Costs

### Storage Fees
- **RunPod**: $0.20/GB/month persistent storage, charged even when pod is stopped. Delete volumes after training.
- **Hyperscalers**: persistent volume charges vary by provider — verify with provider.

> Source: Round 2, deep-ask-findings.md

### Egress Fees
- **AWS/GCP/Azure**: $0.08-0.12/GB outbound. Syncing a 100GB model = $8-12. Free-tier platforms (Colab/Kaggle) have no egress fees.
- **Mitigation**: download only the LoRA adapter (~70MB for VoxCPM2), not the full base model.

> Source: Round 2 + Colin dogfood 2026-05-29, deep-ask-findings.md

### Minimum Billing
- **Lambda Labs**: 1-hour minimum — a 5-minute test costs 1 full hour. Verify current hourly rate at lambda.com.

> Source: Round 2 (billing structure), deep-ask-findings.md

### Quota Burn
- **Kaggle**: idle sessions burn quota. 60-min idle timeout, but quota still consumed.
- **Colab Free**: session disconnects are common — save checkpoints frequently.

> Source: Round 2, deep-ask-findings.md

---

## Cost Optimization Rules

**Rule 1**: Use Unsloth on free tiers — claimed 70% VRAM reduction means higher batch size = faster training.

> Source: Round 1, deep-ask-findings.md

**Rule 2**: Download only LoRA weights, not the full model. VoxCPM2 LoRA weights are ~70MB vs multi-GB base model.

> Source: Colin dogfood 2026-05-29, deep-ask-findings.md

**Rule 3**: For paid platforms, estimate total cost BEFORE starting. Formula: `(estimated hours × hourly rate) + storage for job duration`. Example: a 2h RunPod RTX 4090 job costs $0.68-0.88 GPU + storage fees.

> Source: Round 5 + Round 8, deep-ask-findings.md (pricing data)

**Rule 4**: Check .edu email first — Colab Pro free for students is the highest-value option if available.

> Source: Colin dogfood 2026-05-29, deep-ask-findings.md
