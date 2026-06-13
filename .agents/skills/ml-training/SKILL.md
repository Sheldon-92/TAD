---
name: ml-training
description: "ML model training on cloud GPU — platform selection, LoRA/QLoRA fine-tuning, cost estimation, human-AI collaboration via browser MCP"
version: 0.1.0
type: reference-based
keywords: ["fine-tune", "微调", "LoRA", "QLoRA", "train model", "训练模型", "Colab", "Kaggle", "RunPod", "cloud GPU", "云GPU", "云训练", "training data", "训练数据", "GPU hours", "model training", "模型训练", "personality clone", "个性克隆"]
---

# ML Training Capability Pack

> Cross-agent portable judgment for ML model training on cloud GPU. Covers platform selection, LoRA/QLoRA fine-tuning for LLM and voice models, data preparation, cost estimation, and human-AI collaboration workflows.
**CONSUMES**: Training data (JSONL/ShareGPT/audio+transcript pairs), base model name, hardware constraints, budget.
**PRODUCES**: Platform recommendation, tool selection, training configuration, cost estimate.
> **INTERFACE**: ai-voice-production pack defers voice training platform selection to this pack's `platform-selection.md`. This pack defers voice-specific tool selection (GPT-SoVITS, VoxCPM2 configs, audio quality thresholds) to ai-voice-production pack. When both packs load for voice training: this pack takes precedence for platform/cost decisions; ai-voice-production takes precedence for tool selection and audio quality.

---

## Step 0: Prerequisites

- **Python 3.10+** — required by Unsloth, LlamaFactory, Axolotl
- **pip or uv** — install in virtual environment (never global)
- **Cloud account** — at least one of: Google (Colab/Kaggle), RunPod, Vast.ai
- **Chrome + Claude MCP extension** — for browser-automated Colab workflows (optional)
- **jq + awk** — required by `scripts/dataset-check.sh` / `cost-estimate.sh` / `vram-fit.sh`

Verify: `python3 --version`

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| fine-tune, 微调, LoRA, QLoRA, train model, 训练模型 | `references/lora-finetune.md` |
| Colab, Kaggle, RunPod, Vast.ai, cloud GPU, 云GPU, 云训练 | `references/platform-selection.md` |
| training data, 训练数据, chat logs, 聊天记录, data prep | `references/data-preparation.md` |
| cost, 成本, pricing, 多少钱, budget, GPU hours | `references/cost-estimation.md` |
| browser automation, MCP, Colab操作, 人机协作 | `references/mcp-collaboration.md` |
| personality clone, 个性克隆, sound like, 像某人 | `references/lora-finetune.md` + `references/data-preparation.md` |

**Multi-signal**: Load all matched references. Cross-reference links are provided within files.

---

## Step 2: Decision Entry Point

**Q1 — What type of model?**
- LLM (text: Qwen/Llama/Mistral) → load `lora-finetune.md`
- Voice (TTS/cloning: VoxCPM2/GPT-SoVITS) → defer to ai-voice-production pack for tool selection; load `platform-selection.md` for GPU choice
- Image/other → out of scope, state clearly

**Q2 — What hardware do you have locally?**
- Apple Silicon 8-16GB → cloud training mandatory for 7B+ LoRA 16-bit; local only for QLoRA 2-bit or inference
- NVIDIA GPU ≥16GB → local QLoRA possible; cloud for LoRA 16-bit or larger models
- No GPU → cloud mandatory

**Q3 — What's your budget?**
- $0 → Colab Free / Kaggle (with gotcha awareness — read `platform-selection.md`)
- $10-50/mo → Colab Pro (student free w/ .edu) / RunPod
- >$50/mo → RunPod Secure / Lambda (if uptime critical)

**Q4 — What tool?**
- Minimal setup + Colab/Kaggle → Unsloth (~70% VRAM reduction via `use_gradient_checkpointing="unsloth"`, 2-5× speedup)
- Widest models + GUI → LlamaFactory v0.9.4 (LlamaBoard no-code UI + CLI)
- RL / post-training pipeline → Axolotl v0.17.0 (single YAML, GRPO/DPO/KTO/ORPO)
- Voice → GPT-SoVITS or VoxCPM2 (defer to ai-voice-production pack)

---

## Step 3: Apply Rules

Read matched reference(s) and apply rules directly. Rules are concrete decision parameters — not step-by-step tutorials. Run the deterministic checks (Step 4) instead of eyeballing VRAM/cost/schema.

---

## Step 4: Validation Scripts (don't punt determinism to prose)

| Script | Checks |
|---|---|
| `scripts/vram-fit.sh <params_B> <method> <gpu_gb>` | Does the config fit the card? (qlora4/lora8/lora16, unsloth-qlora4) |
| `scripts/cost-estimate.sh <num_examples> [epochs] [batch] [sec/step] [rate]` | GPU-hour cost from the formula + 2026 rate anchors |
| `scripts/dataset-check.sh <file.jsonl>` | JSONL validity + schema detect (ShareGPT/ChatML/Alpaca/preference) + size verdict + dedup |

---

## Quick Rule Index (router — depth lives in references/)

> Each entry is a POINTER, not the answer. The concrete numbers (ranks, VRAM, prices,
> learning rates, quotas) are in the linked reference so this index stays a true router.

### Platform Selection → `references/platform-selection.md`
- Budget decision tree ($0 / $10-50 / $50+) → §Budget Decision Tree
- Free-tier hard limits (Colab/Kaggle quotas, session caps) → §Free Tier Hard Limits
- The 5 platform gotchas (anti-abuse, idle timeout, ephemeral storage, untrusted hosts, egress) → §Hidden Limitations
- VRAM → card mapping → §VRAM → Platform mapping

### LoRA Fine-Tuning → `references/lora-finetune.md`
- When to fine-tune (dataset-size → task threshold) → §When to Fine-Tune
- VRAM requirements + Unsloth gradient-checkpointing flag → §VRAM Requirements
- LoRA vs QLoRA quality/VRAM tradeoff + 2026 default config → §LoRA vs QLoRA
- Rank (r) + alpha rule → §Rank Selection
- Learning rate (SFT vs DPO/GRPO) → §Learning Rate
- Overfitting tripwires + training budget → §Overfitting Tripwires
- Preference tuning (DPO/GRPO config) → §Preference Tuning
- Version-pinned tool comparison → §Tool Comparison

### Data Preparation → `references/data-preparation.md`
- Quality > quantity rule → §Dataset Quality Rule
- LLM data pipeline + schemas (ShareGPT/ChatML/Alpaca) → §LLM Data Pipeline
- Preference-pair data (DPO/GRPO triples) → §Preference-Pair Data
- Voice data pipeline (defer audio thresholds) → §Voice Data Pipeline
- AI bootstrap to reach the example floor → §AI Bootstrap

### MCP Collaboration → `references/mcp-collaboration.md`
- PAUSE protocol (auth triggers, forbidden tools, resume) → §PAUSE Protocol
- Chrome MCP tool map → §Chrome MCP Tool Map
- Security rules → §Security Rules

### Cost Estimation → `references/cost-estimation.md`
- Cost formula → §Cost Formula
- 2026 price anchors → §Cloud GPU Price Anchors
- "Can I do it free?" tree → §"Can I Do It Free?" Decision Tree

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I'll just use Colab Free" | MUST read `platform-selection.md` gotchas — anti-abuse termination kills SSH/remote desktop, Drive I/O errors after 10K files, idle quota burn |
| "200 examples should be enough for everything" | MUST check task-type threshold in `lora-finetune.md` — practical floor 100, sweet spot 500-10000; personality needs AI bootstrap to reach ~500. Run `scripts/dataset-check.sh` for the size verdict |
| "I'll fine-tune first, test later" | MUST check fine-tune threshold in `lora-finetune.md` — if <100 examples, use few-shot prompting/RAG first (below practical floor) |
| "My Mac can handle it" | MUST check VRAM in `lora-finetune.md` — 7-8B LoRA 16-bit needs ~16GB, 8GB Mac = cloud mandatory above QLoRA 4-bit. Run `scripts/vram-fit.sh` to confirm |
| "I'll reuse the SFT learning rate for DPO" | MUST check `lora-finetune.md` §Learning Rate — DPO/GRPO LR is 5e-6, ~40× lower than SFT 2e-4; reusing 2e-4 diverges |
| "I'll skip data cleaning" | MUST read `data-preparation.md` quality rule — 500 clean examples outperform 5,000 noisy; 117 clean > 248 dirty segments at same step count (Colin dogfood) |
