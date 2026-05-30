# ML Training Pack — Deep Ask Research Findings

**Date:** 2026-05-29
**Notebook:** 36711adf-3587-48ed-bfe6-98b2555dbe30 (14 sources, 8 rounds)
**Epic:** EPIC-20260529-ml-training-pack Phase 1

---

## Round 1: Tool Benchmark (Unsloth vs LlamaFactory vs Axolotl)

### VRAM Requirements (LlamaFactory verified)
| Method | 7B Model VRAM |
|--------|--------------|
| 16-bit LoRA | 16GB |
| 8-bit QLoRA | 10GB |
| 4-bit QLoRA | 6GB |
| 2-bit QLoRA | 4GB |

### Performance Claims
- Unsloth: 2x faster, 70% less VRAM (custom Triton kernels)
- Specific per-step benchmarks (tokens/sec) NOT available in any source

---

## Round 2: Platform Hidden Limitations (Gotchas)

### Colab
- Anti-abuse terminates SSH shells, remote desktops, and web UIs for content generation
- Drive mounting fails with >10,000 items in root
- Silent quota: aggressive Drive I/O triggers opaque `[Errno 5] Input/output error`
- A100 availability unreliable even on Pro+

### Kaggle
- 60-minute idle timeout silently burns quota if you forget to stop session
- Pressing "commit" multiple times runs concurrent batch sessions, draining quota

### RunPod
- Serverless cold starts: 5-15 seconds scaling from zero
- Multi-node capped at 8 GPUs without InfiniBand
- Hidden storage fee: $0.20/GB/month even when pod stopped

### Vast.ai
- P2P marketplace: unvetted hardware, never store API keys
- Hosts can go offline mid-training: checkpoint every 30 minutes
- Zero multi-node support, community-only troubleshooting

### Lambda Labs
- 1-hour minimum billing (5-min test costs 1 hour)
- No spot pricing, no autoscaling, no serverless

### CoreWeave
- Approval process takes days, Kubernetes-native (steep learning curve)

### Hyperscalers (AWS/GCP/Azure)
- Egress fees: $0.08-0.12/GB outbound. 100GB model sync = $8-12
- Ancillary fees: static IP, load balancers, persistent volume

---

## Round 3: Voice vs LLM Fine-Tune Differences

| Dimension | Voice (VoxCPM2/GPT-SoVITS) | LLM (Qwen/Llama) |
|-----------|---------------------------|-------------------|
| Data format | Audio + transcript pairs, `.list` annotation | JSONL ChatML / Alpaca / ShareGPT |
| Loss function | Diffusion/Flow Matching (VoxCPM2), vocoder-based (GPT-SoVITS) | Cross-entropy next-token |
| Eval metrics | WER, CER, SIM (speaker similarity), RTF | Perplexity, BLEU, human eval |
| Min data | 1 min (GPT-SoVITS), 5-10 min audio (VoxCPM2) | 200-500 examples (classification), 500-2K (generation) |
| Hardware quirk | GPT-SoVITS Mac GPU = low quality, must use CPU | No Mac-specific quality issue for QLoRA |

---

## Round 4: Complete Decision Framework

### Q1: Fine-tune vs Prompting/RAG?
- <50 examples → few-shot prompting or RAG
- 100-300 examples, simple classification → fine-tune
- 200-500 examples, extraction → fine-tune
- 500-2K examples, content generation/style → fine-tune
- Voice cloning → fine-tune (1-10 min audio)

### Q2: Which platform?
- Budget <$50/mo + can tolerate interruptions → Vast.ai spot ($0.15-0.55/hr)
- Budget $50-300/mo + need reliability → RunPod ($0.34-0.44/hr RTX 4090)
- Free + short job (<12h) → Colab Free T4 or Kaggle P100
- Free + student .edu → Colab Pro (free with .edu verification)
- Voice training on Mac → CPU only (GPT-SoVITS Mac GPU quality issue)

### Q3: Which tool?
- Minimal setup + Colab → **Unsloth** (pre-built notebooks, 70% less VRAM)
- Widest model support (100+ LLMs) → **LlamaFactory** (WebUI + CLI)
- Pipeline reproducibility + YAML config → **Axolotl** (MLOps focused)
- Voice cloning (Chinese) → **GPT-SoVITS** (WebUI with ASR pipeline)
- Voice cloning (multilingual, high quality) → **VoxCPM2** (2B params, 48kHz)

### Q4: Configuration for 7B QLoRA?
- LoRA rank: 16 (style tasks), 32 (multi-turn), 64 (complex reasoning)
- Alpha: 2x rank
- Learning rate: 2e-4
- Epochs: 2-3 (personality cloning: monitor overfitting)
- target_modules: "all-linear"
- DoRA: enabled

---

## Round 5: Cost & Time Estimates (Voice Models)

| Platform | GPU | VRAM | Est. Time (full LoRA) | Cost | Free? | Gotcha |
|----------|-----|------|-----------------------|------|-------|--------|
| Colab Free | T4 | 16GB | 4-8h | $0 | Yes | Anti-abuse terminations |
| Colab Pro | A100 | 40-80GB | 2-4h (1-2h w/ Unsloth) | $10-50/mo | .edu free | Unreliable A100 |
| Kaggle | P100 | 16GB | 4-8h | $0 | Yes | Idle timeout eats quota |
| RunPod | RTX 4090 | 24GB | 1-2h (w/ Unsloth) | $0.68-1.76 | No | Storage fees |
| Vast.ai | RTX 4090 | 24GB | 1-2h (w/ Unsloth) | $0.30-2.20 | No | Security risk |

---

## Round 6: Head-to-Head Tool Comparison

| Dimension | Unsloth | LlamaFactory | Axolotl |
|-----------|---------|-------------|---------|
| Learning curve | <1 hour (WebUI + notebooks) | Fast (WebUI CLI) | Steeper (YAML config) |
| Colab integration | **Best** — pre-built free notebooks | Good — official Colab link | Basic — Docker focused |
| Model support 2026 | Major models (custom kernels limit coverage) | **100+ LLMs/VLMs** | Strong + MoE/Multimodal |
| GitHub stars | ~65.3K | **~71.7K** | ~12K |
| Best for | Free T4/Kaggle, minimal setup | Widest model coverage, enterprise | Reproducible MLOps pipelines |
| Pick for Qwen 2.5 7B on T4 | **Yes — pre-built Qwen notebook** | Also works | Overkill for solo dev |

---

## Round 7: LLM Personality Cloning Workflow (Anthony Example)

### Data Preparation
1. Extract 500 chat messages → clean, filter irrelevant
2. Convert to ShareGPT multi-turn JSON format
3. Expect 100-200 usable examples after cleaning
4. AI bootstrap: use GPT-4/Claude to generate 300+ synthetic training pairs in Anthony's style
5. Human review all synthetic examples

### Training Config
- Rank: 16 or 32 (personality needs capacity)
- Alpha: 32 or 64 (2x rank)
- LR: 2e-4
- Epochs: 3 (watch for overfitting — model starts repeating catchphrases)

### Evaluation
- No automated "personality score" metric exists
- Baseline: test few-shot prompting first (if this works, don't fine-tune)
- Coverage: 20-30 examples per scenario category
- Expert review: someone who knows Anthony reviews 50-100 outputs
- Supervised deployment: collect edge cases for next iteration

---

## Round 8: LLM-Specific Cost & Time (Qwen 2.5 7B QLoRA, 1K samples, 3 epochs)

| Platform | VRAM fits? | Est. Time | Cost | Free? |
|----------|-----------|-----------|------|-------|
| Colab Free (T4) | ✅ 6GB < 16GB | 4-8h | $0 | Yes |
| Colab Pro (A100) | ✅ 6GB < 40GB | 1-4h (1-2h w/ Unsloth) | $10-50/mo | .edu free |
| Kaggle (P100) | ✅ 6GB < 16GB | 4-8h | $0 | Yes (30h/week) |
| RunPod (RTX 4090) | ✅ 6GB < 24GB | 1-4h (1-2h w/ Unsloth) | $0.34-1.76 | No |
| Vast.ai (RTX 4090) | ✅ 6GB < 24GB | 1-4h (1-2h w/ Unsloth) | $0.15-2.20 | No |

**Key finding:** 7B QLoRA 4-bit only needs 6GB VRAM — ALL platforms can run it, including free tiers.

---

## Colin Project First-Hand Data (Category A)

| Parameter | Value | Source |
|-----------|-------|--------|
| VoxCPM2 training VRAM | ~22GB (T4 OOM, needs A100) | Colin dogfood |
| VoxCPM2 LoRA weights | ~70MB | Colin dogfood |
| Training data (cleaned) | 117 segments, 12.2 min | Colin dogfood |
| Steps progression | 500→2000→3500 (quality improved with more steps + clean data) | Colin dogfood |
| TORCHDYNAMO_DISABLE=1 | torch.compile hangs on Colab | Colin dogfood |
| Colab Pro student | Free with .edu | Colin dogfood |
| Data quality impact | 248→117 segments after cleaning; clean data + 3500 steps > dirty data + 2000 steps | Colin dogfood |
| PAUSE Protocol | Agent stops all browser tools during auth; navigates away before resuming | Colin dogfood |

---

## Sources (14 curated in notebook 36711adf)
1. pdaicode/awesome-LLMs-finetuning (GitHub)
2. zszazi/Deep-learning-in-cloud (GitHub)
3. binga/cloud-gpus (GitHub)
4. unslothai/unsloth (GitHub, ~65.3K stars)
5. hiyouga/LLaMA-Factory (GitHub, ~71.7K stars)
6. axolotl-ai-cloud/axolotl (GitHub, ~12K stars)
7. OpenBMB/VoxCPM (GitHub)
8. RVC-Boss/GPT-SoVITS (GitHub)
9. Google Colab FAQ
10. Kaggle GPU Docs
11. RunPod Getting Started
12. hjLabs Fine-Tuning Best Practices 2026
13. Particula: How Much Data for Fine-Tune
14. ToolHalla: Best GPU Cloud 2026
15. Spheron: GPU Cloud Pricing 2026
