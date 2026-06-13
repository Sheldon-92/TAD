---
name: ai-podcast-production
description: "AI podcast production judgment for coding agents — script writing with Codex review, large-chunk TTS generation, dual-BGM music arrangement with envelope follower ducking, show notes, Colab deployment"
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
- **Codex CLI or API access** — adversarial script review (current Codex default; as of 2026-06 that is GPT-5.5-class — use whatever the installed CLI defaults to)
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
| verify loudness, true-peak, LRA, lint chunks, validate audio | Run `scripts/loudness-check.sh` / `scripts/chunk-lint.sh` (see Validation Scripts) |

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
- **Validated Params + Per-Platform Loudness**: -16/-19 Apple, -14 Spotify/YouTube; platform true-peak target -1 dBTP (Apple cites ITU-R BS.1770-5), reserved via -1 dBFS sample-peak (pyloudnorm has no dBTP meter); LRA 5-15 LU → TP7/TP7a-d
- **VoxCPM2 Facts + Voice-Model Escape Hatches**: Apache-2.0, v2.0.3, cfg_value=2.0; Kokoro/XTTS-v2 alt, F5-TTS non-commercial → TP8a

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
- **Envelope vs DAW Norm**: pack's ~17 dB swing vs conventional 3-6 dB / 50-200ms release → MA1
- **Inter-Segment Gaps**: 1.5s intra-chunk, 2.5s inter-chapter → MA7
- **Anti-Clipping = -1 dBFS Sample-Peak Reserve**: `pyln.normalize.peak(mix, -1.0)` (sample-peak, not measured dBTP) replaces the old 0.95 clamp; for a real dBTP guarantee use `ffmpeg ebur128=peak=true` → MA8

### Show Notes (`references/show-notes.md`)
- **9-Section Structure**: header → hook → timestamps → books → authors → quotes → extensions → credits → audience → SN1-SN9
- **Golden Quote Selection**: 8-10 quotable lines, blockquote format → SN6

### Colab Deployment (`references/colab-deployment.md`)
- **Notebook Separation**: TTS (GPU) and arrangement (no GPU) as separate notebooks → CD1
- **Self-Contained Notebooks**: never ask users to paste code → CD2
- **Drive Upload Format**: textContent + application/json + disableConversion → CD3
- **Drive Mount Recovery**: disconnect + delete runtime on timeout → CD4

---

### Validation Scripts (`scripts/`)
- **`loudness-check.sh <final.wav> [platform]`** — asserts integrated LUFS within ±1 LU of the per-platform target (TP7a, measured BS.1770-4), LRA in 5-15 LU (EBU Tech 3342, measured), and peak ≤ -1 dBFS — true-peak (dBTP) when ffmpeg is present, else a sample-peak proxy (honestly labeled). LRA that cannot be measured FAILS (no silent pass). Exit 0 = PASS. Deterministic check, not "punt to Claude".
- **`chunk-lint.sh <chunks.txt | seg-dir/>`** — text mode: every chunk 200-350 chars (TP1); audio mode: no post-cut segment < 8s (TP3). Exit 1 on violation.

### Fixtures (`examples/`)
- **`full-episode-production.md`** — discriminative eval fixture (`discriminative_pattern` + `min_discriminative=4`) for the end-to-end pipeline; markers are pack-specific numbers/APIs (200-350 chunks, -1 dBTP, envelope 5ms/2000ms, 0.5%/3.5%, per-platform LUFS, Codex review).

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I'll generate TTS per sentence for more control" | MUST use 200-350 char large chunks (TP1) — per-sentence causes random volume/timbre fluctuations across 50+ segments |
| "I'll denoise after all TTS is done" | MUST merge in generation loop (TP4) — separation risks omission and Colab disconnect between steps |
| "Any BGM track will work" | MUST audition 3 candidates x 30s each, select 2 for dual-track (MS2-MS3) — single melodic track causes listener fatigue |
| "I'll use linear volume fades" | MUST use log10(1+9*t) fade curves (MA4) — linear linspace sounds unnatural to human ears (Weber-Fechner law) |
| "BGM at 8% should be subtle enough" | MUST use 0.5%/3.5% sweet spot (MA5) — 8% is too loud, validated across 10+ iterations |
| "I'll add a soft limiter on the voice track" | MUST NOT over-process voice (MA11) — only denoise + loudness normalize; tail decay compression introduces artifacts |
| "The script is good enough without Codex review" | MUST run adversarial Codex review (SS9) — single pass catches 25+ factual/logical/colloquial errors that AI-human collaborative draft misses |
| "I'll just paste the fix into the notebook cell" | MUST upload a complete new notebook (CD2) — pasting caused 3 errors: cell overwrite, undefined vars, param mismatch |
| "np.convolve with a 2-second window should be fine" | MUST downsample first (MA8) — 48kHz x 13min = 39M samples with large window hangs or crashes Colab |
| "I'll skip the head/tail fade to save time" | MUST add opening (8s+6s) and ending (15s+10s) fades (MA6) — without them the show sounds like a switch being flipped |
| "I'll just normalize everything to -16 LUFS" | MUST use per-platform targets (TP7a): -16 Apple-stereo / -19 Apple-mono / -14 Spotify·YouTube·Amazon·Google. -16 is too quiet for Spotify/YouTube; default to -14 when platform unknown |
| "Clamp the sample peak at 0.95 to avoid clipping" | MUST reserve -1 dBFS via `pyln.normalize.peak(mix, -1.0)` (MA8) — 0.95≈-0.45 dBFS leaves too little headroom; -1 dBFS is a conservative margin for the inter-sample overs lossy encoders add. NOTE: this is sample-peak, not a measured dBTP; for a true-peak guarantee run `ffmpeg ebur128=peak=true` |
| "F5-TTS sounds great, I'll use it for this show" | MUST check license first (TP8a) — F5-TTS is CC-BY-NC 4.0 (non-commercial); shipping it in a monetized podcast is a license violation. XTTS-v2 is ALSO non-commercial (Coqui CPML, no commercial path post-shutdown). For a monetized show use VoxCPM2 or Kokoro (both Apache-2.0) |
| "I'll verify loudness by listening" | MUST run `scripts/loudness-check.sh` (TP7d) — integrated loudness (BS.1770-4) and LRA (EBU Tech 3342) are measured by pyloudnorm; true-peak is measured by ffmpeg ebur128 when present, else reported as a -1 dBFS sample-peak proxy. Not subjective |
