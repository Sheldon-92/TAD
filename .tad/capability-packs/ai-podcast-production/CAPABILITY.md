---
name: ai-podcast-production
description: "AI podcast production judgment for coding agents. Covers script writing, large-chunk TTS generation, dual-BGM music arrangement with envelope follower ducking, show notes, and Colab deployment. Use for any AI-assisted podcast or audio content production task."
version: 0.1.0
type: reference-based
keywords: ["podcast", "播客", "podcast production", "播客制作", "podcast script", "播客文案", "TTS", "text-to-speech", "语音合成", "music arrangement", "编曲", "混音", "BGM", "背景音乐", "ducking", "sidechain", "envelope follower", "show notes", "节目笔记", "Colab", "VoxCPM2", "voice cloning", "声音克隆", "audio production", "音频制作", "noisereduce", "loudness normalization", "podcast workflow", "播客流程"]
---

# AI Podcast Production Capability Pack

> Cross-agent portable judgment for AI-produced podcasts. Covers the full pipeline: article analysis to script writing with adversarial Codex review, large-chunk TTS generation with inline denoising, dual-BGM selection and envelope-follower arrangement, show notes production, and Colab deployment patterns. Grounded in 2 episodes produced, 10+ arrangement iterations, 25+ Codex corrections validated.

**CONSUMES**: Source articles/books (text), reference voice audio (WAV), LoRA weights (safetensors), BGM tracks (WAV/MP3).
**PRODUCES**: Podcast script (text), episode audio (WAV 48kHz), show notes (markdown), Colab notebooks (.ipynb).

> **INTERFACE**: ai-voice-production pack defers to this pack for podcast-specific TTS chunking strategy, arrangement algorithms, and script methodology. This pack defers to ai-voice-production for TTS tool selection and voice cloning method choice. ml-training pack provides platform selection and cost estimation for cloud GPU. This pack defers cloud platform details to ml-training's platform-selection.md. When all three packs load: ml-training takes precedence for platform/cost; ai-voice-production takes precedence for tool selection; this pack takes precedence for podcast-specific workflow (chunking, arrangement, script quality, show notes).

---

## Step 0: Pack Prerequisites

- **Google Colab Pro** (or free tier with gotcha awareness) — TTS requires A100 GPU
- **Python 3.10+** with: `voxcpm`, `soundfile`, `numpy`, `noisereduce`, `pyloudnorm`, `tqdm`, `huggingface_hub`
- **yt-dlp** — BGM download in Colab
- **Google Drive** — storage for all artifacts (checkpoints, audio, notebooks)
- **Codex CLI or API access** — adversarial script review (o3/o4-mini)
- **Chrome + Claude MCP extension** — browser-automated Colab workflows (optional)

Verify (in Colab): `!python --version && !pip show voxcpm soundfile noisereduce pyloudnorm`

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| script, 文案, article analysis, 读书, book podcast, 稿子, draft, Codex review | `references/script-writing.md` |
| TTS, generate voice, 语音合成, chunk, denoise, normalize, loudness | `references/tts-production.md` |
| BGM, music, 选曲, audition, dual track, no-copyright, 背景音乐 | `references/music-selection.md` |
| arrange, 编曲, ducking, sidechain, envelope, mix, fade, 混音 | `references/music-arrangement.md` |
| show notes, 节目笔记, timestamps, golden quotes, 金句, episode description | `references/show-notes.md` |
| Colab, notebook, deploy, upload, Drive, session, GPU, 部署 | `references/colab-deployment.md` |
| full episode, end-to-end, complete pipeline, 完整流程 | Load **all references** sequentially |

**Multi-signal**: Load all matched references. Cross-reference links are provided within files.

---

## Step 2: Decision Entry Point

**Q1 — What pipeline stage?**
- Have source material, need a script → load `references/script-writing.md`
- Have a script, need audio → load `references/tts-production.md`
- Have voice audio, need music → load `references/music-selection.md` + `references/music-arrangement.md`
- Have final audio, need show notes → load `references/show-notes.md`
- Need to deploy notebooks → load `references/colab-deployment.md`
- Starting from scratch → load ALL references, execute in order

**Q2 — Which voice model?**
- Colin (custom LoRA) → load `references/tts-production.md` (Colin gotchas section)
- Sheldon (custom LoRA) → load `references/tts-production.md` (standard path)
- New voice → defer to ai-voice-production pack for tool selection, then return here for chunking strategy

**Q3 — Is this a partial edit or full production?**
- Full episode → full pipeline
- Script edit only → `references/script-writing.md` only
- Single chunk re-record → `references/tts-production.md` (partial regeneration section)
- Arrangement tweak → `references/music-arrangement.md` only

---

## Step 3: Apply Rules

Read matched reference(s) and apply rules directly. Rules are concrete parameters with validated values from production episodes — not guidelines.

---

## Cross-Cutting Rule: The 85-to-95 Point Gap

> **The difference between a competent podcast and an excellent one is NOT talent — it is a repeatable 5-step delta**: (1) original text quotation vs paraphrase (+2), (2) technique analysis vs plot summary (+2), (3) personal memory specificity vs generic reflection (+2), (4) factual precision via adversarial Codex review (+2), (5) non-resolution thesis vs tidy conclusion (+2). Each step is learnable, auditable, and has clear before/after examples. This pack encodes all five.

This rule applies across script-writing, TTS production (script quality determines audio quality), and show notes (golden quotes require the script to have quotable lines). It is surfaced here because treating podcast quality as subjective taste rather than a structured delta is the primary failure mode.

---

## Cross-Cutting Rule: Merge Processing Steps, Never Separate Them

> **Every audio processing step (generate, denoise, normalize) MUST happen in a single loop iteration per chunk.** Separating steps into different cells, notebooks, or passes creates three failure classes: (1) omission — forgetting to process some segments, (2) session disconnect — Colab drops between steps and loses VM state, (3) mismatch — applying different parameters to different segments. The merged loop pattern is: `generate -> squeeze -> nr.reduce_noise -> pyloudnorm.normalize -> sf.write`.

This rule applies to TTS production and any audio post-processing. It is surfaced here because "I'll denoise in a separate pass" is the single most common failure in Colab audio workflows.

---

## Quick Rule Index

### Script Writing (`references/script-writing.md`)
- **Source Selection**: Thematic diptych — two works that mirror one question from opposite angles → SS1-SS3
- **Reference Style (Xu Zhiqiang Method)**: 8 techniques from direct quotation to cultural bridging → SS4-SS8
- **Codex Adversarial Review**: 5 correction categories, 25+ fixes per episode → SS9-SS11
- **Quality Scoring Rubric**: 8 dimensions, 100-point scale, 85→95 gap analysis → SS12

### TTS Production (`references/tts-production.md`)
- **Large-Chunk Strategy**: 200-350 chars/chunk, ~20 chunks/episode → TP1-TP3
- **Merged Processing Loop**: generate → denoise → normalize in one iteration → TP4
- **Colin Model Gotchas**: base_model hardcode, weight file rename → TP5
- **Partial Regeneration**: single-chunk mini notebook for edits → TP6
- **Post-Cut Silence Detection**: threshold=0.015, min 8s segments → TP7

### Music Selection (`references/music-selection.md`)
- **Atmosphere Over Melody**: sparse notes, no competing melody → MS1
- **Dual-Track Strategy**: two BGMs alternating by chapter → MS2
- **Audition Workflow**: 3 candidates → 30s each → pick 2 → MS3

### Music Arrangement (`references/music-arrangement.md`)
- **Envelope Follower**: attack 5ms / release 2s, DAW-standard sidechain → MA1-MA2
- **Look-Ahead Ducking**: 0.5s offset, music anticipates voice → MA3
- **Logarithmic Fade Curves**: log10(1+9*t) matching human hearing → MA4
- **BGM Volume Sweet Spot**: 0.5% during voice, 3.5% during silence → MA5
- **Head/Tail Fades**: 8s+6s opening, 15s+10s ending → MA6
- **Inter-Segment Gaps**: 1.5s intra-chunk, 2.5s inter-chapter → MA7
- **Memory Trap Avoidance**: downsample before smoothing, never convolve at 48kHz → MA8

### Show Notes (`references/show-notes.md`)
- **9-Section Structure**: header → hook → timestamps → books → authors → quotes → extensions → credits → audience → SN1-SN9
- **Golden Quote Selection**: 8-10 quotable lines, blockquote format → SN6

### Colab Deployment (`references/colab-deployment.md`)
- **Notebook Separation**: TTS (GPU) and arrangement (no GPU) as separate notebooks → CD1
- **Self-Contained Notebooks**: never ask users to paste code → CD2
- **Drive Upload Format**: textContent + application/json + disableConversion → CD3
- **Drive Mount Recovery**: disconnect + delete runtime on timeout → CD4

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I'll generate TTS per sentence for more control" | MUST use 200-350 char large chunks (TP1) — per-sentence causes random volume/timbre fluctuations across 50+ segments |
| "I'll denoise after all TTS is done" | MUST merge in generation loop (TP4) — separation risks omission and Colab disconnect between steps |
| "Any BGM track will work" | MUST audition 3 candidates x 30s each, select 2 for dual-track (MS2-MS3) — single melodic track causes listener fatigue |
| "I'll use linear volume fades" | MUST use log10(1+9*t) fade curves (MA4) — linear linspace sounds unnatural to human ears (Weber-Fechner law) |
| "BGM at 8% should be subtle enough" | MUST use 0.5%/3.5% sweet spot (MA5) — 8% is too loud, validated across 10+ iterations |
| "I'll add a soft limiter on the voice track" | MUST NOT over-process voice (PP-001) — only denoise + loudness normalize; tail decay compression introduces artifacts |
| "The script is good enough without Codex review" | MUST run adversarial Codex review (SS9) — single pass catches 25+ factual/logical/colloquial errors that AI-human collaborative draft misses |
| "I'll just paste the fix into the notebook cell" | MUST upload a complete new notebook (CD2) — pasting caused 3 errors: cell overwrite, undefined vars, param mismatch |
| "np.convolve with a 2-second window should be fine" | MUST downsample first (MA8) — 48kHz x 13min = 39M samples with large window hangs or crashes Colab |
| "I'll skip the head/tail fade to save time" | MUST add opening (8s+6s) and ending (15s+10s) fades (MA6) — without them the show sounds like a switch being flipped |
