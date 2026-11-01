# LoRA Fine-Tuning — Decision Rules

> Judgment rules for when to fine-tune, which method to use, and how to configure training. Covers both LLM (text) and Voice model fine-tuning.

---

## When to Fine-Tune

**IF <50 examples → DO NOT fine-tune.** Use few-shot prompting or RAG instead.
**IF 100-300 examples + simple classification → fine-tune.**
**IF 200-500 examples + extraction task → fine-tune.**
**IF 500-2K examples + content generation/style transfer → fine-tune.**
**IF voice cloning → fine-tune** (1-10 min reference audio, not an example-count question).

> Source: Round 4 Q1, deep-ask-findings.md

The threshold is task-dependent, not universal. "200 examples" is enough for classification but insufficient for personality cloning — personality needs 500+ (including AI-bootstrapped synthetic pairs).

> Source: Round 7, deep-ask-findings.md

---

## LoRA vs QLoRA vs Full Fine-Tune

| Method | 7B Model VRAM | When to Use |
|--------|--------------|-------------|
| LoRA 16-bit | 16GB | Best quality. Use when platform has ≥16GB VRAM (A100, RTX 4090). |
| QLoRA 8-bit | 10GB | Good balance. Fits T4/P100 with headroom. |
| QLoRA 4-bit | 6GB | Minimum viable. Fits ALL free-tier GPUs (T4 16GB, P100 16GB). |
| QLoRA 2-bit | 4GB | Experimental. Only option for 8GB Mac local training. Quality degrades. |

> Source: Round 1, deep-ask-findings.md (LlamaFactory verified numbers)

**Decision rule**: Use the highest bit-width your VRAM allows. 4-bit QLoRA is the sweet spot for free-tier cloud GPUs — 6GB fits comfortably in 16GB T4/P100 with room for batch size.

---

## VRAM Requirements

| Method | 7B VRAM | Fits T4 (16GB)? | Fits P100 (16GB)? | Fits A100 (40GB)? | Fits RTX 4090 (24GB)? |
|--------|---------|-----------------|-------------------|--------------------|-----------------------|
| 16-bit LoRA | 16GB | Tight | Tight | ✅ Yes | ✅ Yes |
| 8-bit QLoRA | 10GB | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| 4-bit QLoRA | 6GB | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |
| 2-bit QLoRA | 4GB | ✅ Yes | ✅ Yes | ✅ Yes | ✅ Yes |

> Source: Round 1, deep-ask-findings.md

**Key finding**: 7B QLoRA 4-bit needs only 6GB VRAM — ALL cloud platforms can run it, including free tiers.

> Source: Round 8, deep-ask-findings.md

---

## Base Model Selection

The research mentions Qwen 2.5 7B specifically in the context of Unsloth pre-built notebooks. Other model recommendations (Llama, Mistral, CodeLlama) are general knowledge, not from this pack's research.

**Research-grounded recommendation**: Qwen 2.5 7B for Chinese/multilingual tasks on Colab Free — Unsloth has a pre-built Qwen notebook for T4.

> Source: Round 4 Q3 + Round 6, deep-ask-findings.md

---

## Configuration

### LoRA Hyperparameters (7B QLoRA)

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| LoRA rank | 16 (style tasks), 32 (multi-turn/personality), 64 (complex reasoning) | Higher rank = more capacity but more VRAM |
| Alpha | 2× rank (32, 64, or 128) | Standard scaling rule |
| Learning rate | 2e-4 | Consensus across tools |
| Epochs | 2-3 | Personality: monitor for overfitting — model starts repeating catchphrases |
| target_modules | `all-linear` | Covers all attention + MLP layers |
| DoRA | Enabled | Improved LoRA variant, negligible overhead |

> Source: Round 4 Q4 + Round 7, deep-ask-findings.md

### Personality Cloning Specific Config
- Rank: 16 or 32 (personality needs capacity for stylistic patterns)
- Alpha: 32 or 64 (2× rank)
- LR: 2e-4
- Epochs: 3 (watch for overfitting — model repeating catchphrases is the signal)

> Source: Round 7, deep-ask-findings.md

---

## Tool Comparison

| Dimension | Unsloth | LlamaFactory | Axolotl |
|-----------|---------|-------------|---------|
| Learning curve | <1 hour (WebUI + notebooks) | Fast (WebUI + CLI) | Steeper (YAML config) |
| Colab integration | **Best** — pre-built free notebooks | Good — official Colab link | Basic — Docker focused |
| Model support | Major models (custom kernels limit coverage) | **100+ LLMs/VLMs** | Strong + MoE/Multimodal |
| GitHub stars | ~65.3K | **~71.7K** | ~12K |
| Best for | Free T4/Kaggle, minimal setup | Widest model coverage, enterprise | Reproducible MLOps pipelines |
| VRAM claim | 70% less (custom Triton kernels) | Standard | Standard |

> Source: Round 6, deep-ask-findings.md

**Tool selection rule:**
- **IF** Colab Free + first-time → Unsloth (pre-built Qwen notebook, fastest start)
- **IF** need 100+ model support or WebUI → LlamaFactory
- **IF** need YAML-driven reproducible pipeline → Axolotl

> Source: Round 4 Q3 + Round 6, deep-ask-findings.md

---

## Voice Model Fine-Tuning (Platform/VRAM only)

Voice-specific tool configuration is in the ai-voice-production pack. This section covers only platform and VRAM requirements.

| Voice Tool | Min VRAM | Fits T4? | Recommended Platform |
|------------|---------|----------|---------------------|
| GPT-SoVITS | Fits T4 (16GB) | ✅ Yes | Colab Free T4 or Kaggle P100 |
| VoxCPM2 | ~22GB | ❌ OOM | Colab Pro A100 or RunPod RTX 4090 |

> Source: Round 3 (GPT-SoVITS fits T4) + Colin dogfood 2026-05-29 (VoxCPM2 22GB), deep-ask-findings.md

**Mac-specific**: GPT-SoVITS on Mac GPU produces low quality — use CPU mode locally or train on cloud.

> Source: Round 3, deep-ask-findings.md
