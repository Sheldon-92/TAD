# Cloud GPU Platform Selection Rules

> Loaded on signal: Colab, Kaggle, RunPod, Vast.ai, cloud GPU, 云GPU, 云训练.
> Routes a VRAM/budget requirement to a concrete platform + warns of the hidden limits.

---

## Budget Decision Tree

| Budget | Route | Caveat |
|---|---|---|
| **$0** | Colab Free / Kaggle | Read §Hidden Limitations FIRST — hard quotas will kill long runs |
| **$10–50/mo** | Colab Pro (free w/ .edu student) / RunPod Community | Spot interruptions on RunPod Community |
| **>$50/mo** | RunPod Secure / Lambda | Pick Secure when uptime is critical (no preemption) |

---

## Free Tier Hard Limits (replaces vague "gotcha awareness")

| Platform | GPU | Quota | Session cap | Other |
|---|---|---|---|---|
| **Colab Free** | T4 (16GB GDDR6, 2560 CUDA cores) | **~15–30 hr/week** (median **22.4 hr/week** measured across 120+ accounts Mar–Apr 2026) | **12-hr max single session** | dynamic unpublished quota + idle disconnect |
| **Kaggle** | often P100 | **30 hr/week** | — | weekly reset |

Source: https://www.hivenet.com/post/google-colaboratory-gpu-complete-guide-to-free-cloud-gpu-access-and-limitations (retrieved 2026-06-13)

**Implication**: a run needing >12 wall-clock hours CANNOT complete on Colab Free in one
session — checkpoint to Drive and resume, or move to paid. A 22 hr/week median means a
multi-epoch 8B QLoRA can exhaust a week's quota in 2–3 sessions.

---

## Hidden Limitations (the 5 gotchas)

1. **Colab anti-abuse**: SSH / remote-desktop / crypto-mining patterns trigger account
   termination. Drive I/O errors appear after **~10K files** in one folder — shard outputs.
2. **Kaggle idle timeout**: notebook disconnects when idle; long unattended runs die.
3. **RunPod storage**: container disk is ephemeral — mount a **network volume** or lose
   checkpoints on pod stop.
4. **Vast.ai security**: marketplace hosts are untrusted — never put secrets/keys on a
   Vast.ai pod; host reliability is variable.
5. **Hyperscaler egress**: AWS/GCP/Azure charge per-GB egress — downloading a 30GB merged
   model out of the cloud can cost more than the GPU time.

---

## Platform Comparison Table (paid, 2026 anchors)

See `cost-estimation.md` for full hourly price anchors. Quick map:

| Need | Platform | Entry price |
|---|---|---|
| Cheapest 24GB consumer | RunPod Community RTX 4090 | from **$0.34/hr** |
| 80GB for 13B+ LoRA 16-bit | RunPod Community A100 80GB | from **$0.89/hr** |
| Cheapest A100 (reliability variable) | Vast.ai A100 80GB | ~**$0.67/hr** |
| Uptime-critical A100 | RunPod Secure A100 80GB | from **$1.89/hr** |
| H100 throughput | H100 PCIe | from **$2.89/hr** on-demand |

---

## VRAM → Platform mapping

| Your config (from lora-finetune.md) | Minimum card |
|---|---|
| QLoRA 4-bit 7-8B (~6GB) | T4 16GB (Colab Free OK) |
| LoRA 16-bit 7-8B (~16GB) | RTX 4090 24GB |
| 13B+ LoRA 16-bit / 20B | A100 80GB |
| Long-context / 70B | H100 80GB |

---

## Cross-references
- VRAM you actually need → `lora-finetune.md` §VRAM Requirements
- Dollar cost of a chosen card × hours → `cost-estimation.md`
- Driving Colab via browser → `mcp-collaboration.md`
