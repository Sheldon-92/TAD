# Platform Selection — Cloud GPU for ML Training

> Judgment rules for choosing a cloud GPU platform. Covers free tiers, paid options, and hidden limitations that marketing pages don't tell you.

---

## Budget Decision Tree

**IF budget = $0 AND job duration < 12h:**
→ Colab Free (T4 16GB) or Kaggle (P100 16GB)
BECAUSE both offer enough VRAM for 7B QLoRA 4-bit (needs only 6GB), but have session limits and gotchas.

> Source: Round 4 Q2, deep-ask-findings.md

**IF budget = $0 AND student with .edu email:**
→ Colab Pro (free with .edu verification, A100 40-80GB)
BECAUSE .edu students get Colab Pro at no cost, unlocking A100 which handles LoRA 16-bit and larger models.

> Source: Colin dogfood 2026-05-29

**IF budget = $10-50/mo AND need reliability:**
→ RunPod (RTX 4090, $0.34-0.44/hr)
BECAUSE RunPod has persistent storage, no anti-abuse termination, and predictable pricing.

> Source: Round 4 Q2, Round 5, deep-ask-findings.md

**IF budget = $10-50/mo AND can tolerate interruptions:**
→ Vast.ai spot instances ($0.15-0.55/hr RTX 4090)
BECAUSE cheapest GPU hours, but P2P marketplace with reliability risks — checkpoint every 30 min.

> Source: Round 4 Q2, deep-ask-findings.md

**IF budget > $50/mo AND uptime critical:**
→ RunPod or Lambda Labs
BECAUSE dedicated hardware, no spot interruptions. Verify current SLA terms with provider.

> Source: Round 2, deep-ask-findings.md

---

## Platform Comparison Table

| Platform | GPU | VRAM | Time Limit | Cost | Free? | Best For | last_verified |
|----------|-----|------|-----------|------|-------|----------|---------------|
| Colab Free | T4 | 16GB | ~12h session | $0 | Yes | Quick experiments, <12h jobs | 2026-05-29 |
| Colab Pro | A100 | 40-80GB | Extended | $10-50/mo (.edu free) | .edu yes | LoRA 16-bit, large models | 2026-05-29 |
| Kaggle | P100 | 16GB | 30h/week | $0 | Yes | QLoRA, batch jobs | 2026-05-29 |
| RunPod | RTX 4090 | 24GB | None | $0.34-0.44/hr | No | Reliable paid training | 2026-05-29 |
| Vast.ai | RTX 4090 | 24GB | None | $0.15-0.55/hr | No | Cheapest GPU hours | 2026-05-29 |
| Lambda Labs | A100/H100 | 40-80GB | 1h min billing | data not available from research — verify current pricing | No | Enterprise, uptime | 2026-05-29 |

> Source: Rounds 2, 5, 8, deep-ask-findings.md

---

## Hidden Limitations

### Colab
- **Anti-abuse termination**: SSH shells, remote desktops, and web UIs for content generation are terminated. Training notebooks are fine.
- **Drive mounting fails with >10,000 items in root** — use subdirectories.
- **Silent quota**: aggressive Drive I/O triggers opaque `[Errno 5] Input/output error`.
- **A100 availability unreliable** even on Pro+ — don't depend on A100 for time-sensitive work.
- **`torch.compile` hangs** — set `TORCHDYNAMO_DISABLE=1` for VoxCPM2 and similar models.

> Source: Round 2 + Colin dogfood 2026-05-29, deep-ask-findings.md

### Kaggle
- **60-minute idle timeout** silently burns quota if you forget to stop session.
- **Pressing "commit" multiple times** runs concurrent batch sessions, draining quota faster.
- **30h/week GPU quota** — plan jobs to fit within weekly allowance.

> Source: Round 2, deep-ask-findings.md

### RunPod
- **Serverless cold starts**: 5-15 seconds scaling from zero.
- **Multi-node capped at 8 GPUs** without InfiniBand.
- **Hidden storage fee**: $0.20/GB/month even when pod stopped — delete unused volumes.

> Source: Round 2, deep-ask-findings.md

### Vast.ai
- **P2P marketplace**: unvetted hardware. **Never store API keys** on Vast.ai instances.
- **Hosts can go offline mid-training** — checkpoint every 30 minutes mandatory.
- **Zero multi-node support**, community-only troubleshooting.

> Source: Round 2, deep-ask-findings.md

### Lambda Labs
- **1-hour minimum billing** — a 5-minute test costs 1 full hour.
- **No spot pricing**, no autoscaling, no serverless.

> Source: Round 2, deep-ask-findings.md

### Hyperscalers (AWS/GCP/Azure)
- **Egress fees**: $0.08-0.12/GB outbound. Syncing a 100GB model = $8-12.
- **Ancillary fees**: static IP, load balancers, persistent volume — costs add up beyond GPU hours.

> Source: Round 2, deep-ask-findings.md

---

## Voice Model Platform Notes

**VoxCPM2** requires ~22GB VRAM — T4 (16GB) causes OOM. Use A100 (Colab Pro) or RTX 4090 (RunPod/Vast.ai).

**GPT-SoVITS** fits on T4 (16GB) for fine-tuning. Mac GPU produces low quality — use CPU locally or cloud GPU.

> Source: Round 3 + Colin dogfood 2026-05-29, deep-ask-findings.md
