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
- Minimal setup + Colab/Kaggle → Unsloth (pre-built notebooks, 70% less VRAM claim)
- Widest model support (100+ LLMs) → LlamaFactory (WebUI + CLI)
- MLOps pipeline reproducibility → Axolotl (YAML config)
- Voice → GPT-SoVITS or VoxCPM2 (defer to ai-voice-production pack)

---

## Step 3: Apply Rules

Read matched reference(s) and apply rules directly. Rules are concrete decision parameters — not step-by-step tutorials.

---

## Quick Rule Index

### Platform Selection (`references/platform-selection.md`)
- **Budget Decision Tree**: $0 / $10-50 / $50+ routing with gotcha awareness → §Budget Decision Tree
- **5 Platform Gotchas**: Colab anti-abuse, Kaggle idle timeout, RunPod storage, Vast.ai security, hyperscaler egress → §Hidden Limitations
- **Free Tier Comparison**: T4 vs P100, time limits, quota burn risks → §Platform Comparison Table

### LoRA Fine-Tuning (`references/lora-finetune.md`)
- **Fine-tune vs RAG Threshold**: <50 examples = prompting, 100-500 = classification, 500-2K = generation → §When to Fine-Tune
- **VRAM Requirements**: 4-bit QLoRA 6GB, 8-bit 10GB, 16-bit LoRA 16GB → §VRAM Requirements
- **Rank Selection Table**: 16 (style), 32 (multi-turn), 64 (complex reasoning) → §Configuration
- **Tool Head-to-Head**: Unsloth vs LlamaFactory vs Axolotl → §Tool Comparison

### Data Preparation (`references/data-preparation.md`)
- **LLM Data Pipeline**: chat logs → clean → ShareGPT JSON format → §LLM Data Pipeline
- **Voice Data Pipeline**: audio → VAD → transcript → annotation list → §Voice Data Pipeline
- **AI Bootstrap Technique**: frontier model generates synthetic training pairs → §AI Bootstrap

### MCP Collaboration (`references/mcp-collaboration.md`)
- **PAUSE Protocol**: auth triggers, forbidden tools during PAUSE, resume procedure → §PAUSE Protocol
- **Chrome MCP Tool Map**: 10 tools for Colab automation → §Chrome MCP Tools
- **Security Rules**: no reading auth pages, navigate away before resuming → §Security Rules

### Cost Estimation (`references/cost-estimation.md`)
- **VRAM-to-Cost Mapping**: method × platform cost formula → §VRAM-to-Cost
- **"Can I Do It Free?" Tree**: quick-check decision flow → §Free Tier Decision Tree

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I'll just use Colab Free" | MUST read `platform-selection.md` gotchas — anti-abuse termination kills SSH/remote desktop, Drive I/O errors after 10K files, idle quota burn |
| "200 examples should be enough for everything" | MUST check task-type threshold in `lora-finetune.md` — classification 100-500, generation 500-2K, personality needs AI bootstrap to reach target |
| "I'll fine-tune first, test later" | MUST check fine-tune vs prompting/RAG threshold in `lora-finetune.md` — if <50 examples, use few-shot prompting first |
| "My Mac can handle it" | MUST check VRAM requirements in `lora-finetune.md` — 7B LoRA 16-bit needs 16GB VRAM, 8GB Mac = cloud mandatory for anything above 2-bit QLoRA |
| "I'll skip data cleaning" | MUST read `data-preparation.md` quality rule — 117 clean segments outperformed 248 dirty segments at same step count (Colin dogfood) |
