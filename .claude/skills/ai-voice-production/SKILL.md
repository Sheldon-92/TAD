---
name: ai-voice-production
description: "AI voice production judgment for coding agents — TTS tool selection, voice cloning, audiobook/podcast/dubbing pipelines, Apple Silicon optimization, licensing safety"
version: 0.1.0
type: reference-based
keywords: ["TTS", "text-to-speech", "语音合成", "voice cloning", "声音克隆", "voice design", "音色设计", "audiobook", "有声书", "podcast", "播客", "dubbing", "配音", "narration", "旁白", "audio production", "音频制作", "voice acting", "语音", "朗读", "prosody"]
---

# AI Voice Production Capability Pack

> Cross-agent portable judgment for AI-assisted voice production. Covers TTS tool selection, voice cloning, long-form audiobook pipelines, narration/dubbing workflows, Apple Silicon optimization, and licensing safety.
> **CONSUMES**: Text manuscripts, reference audio samples (optional), brand voice guidelines (optional).
> **PRODUCES**: Production-ready audio files (WAV 48kHz preferred, 44.1kHz for ACX). Naming: `{project}/{chapter|segment}-{NNN}.wav`.
> **INTERFACE**: video-creation pack defers to this pack for voice/TTS tool selection and audio quality thresholds. This pack defers to video-creation for video-specific timing (audio-to-video sync, pacing). If both packs load, this pack takes precedence for tool selection; video-creation takes precedence for visual pacing. ml-training pack provides platform selection and cost estimation for cloud GPU training. This pack defers cloud platform details to ml-training's platform-selection.md. ml-training defers voice-specific tool selection to this pack.
> When both packs load for voice training: ml-training takes precedence for platform/cost decisions; ai-voice-production takes precedence for tool selection and audio quality thresholds.

---

## Step 0: Pack Prerequisites

- **Python 3.10+** — most TTS tools require it
- **FFmpeg** — audio post-processing and mastering
- **pip or uv** — package installation in virtual environment
- Memory-dependent: check `references/apple-silicon.md` for Mac users (Apple Silicon uses unified memory, not discrete VRAM)

Verify: `python3 --version && ffmpeg -version`

---

## Step 1: Context Detection

| User Signal | Load Reference |
|---|---|
| tool comparison, which TTS, choose engine, benchmark | `references/tool-landscape.md` |
| Mac, Apple Silicon, MPS, M-series, unified memory, VRAM, 16GB, 32GB | `references/apple-silicon.md` |
| clone voice, reference audio, sound like, voice design | `references/voice-cloning.md` |
| audiobook, long-form, chapter, ACX, Audible, 有声书 | `references/audiobook-pipeline.md` |
| narration, dubbing, podcast, blog voice, 配音, short-form | `references/narration-dubbing.md` |
| ChatTTS, 自然语音, emotion control, 情绪, 对话, dialogue, speaker | `references/chattts-workflow.md` |
| license, commercial, legal, watermark, open source | `references/licensing-safety.md` |

**Multi-signal**: Load all matched references. Cross-reference links are provided within files.

---

## Step 2: Decision Entry Point

**Q1 — What is the use case?**
- Audiobook (100K+ words, multi-chapter) → load `audiobook-pipeline.md` + `voice-cloning.md`
- Blog/video narration (single voice, <30 min) → load `narration-dubbing.md`
- Podcast (multi-episode, consistent voice) → load `narration-dubbing.md`
- Video dubbing (emotion matching, multilingual) → load `narration-dubbing.md`
- Chinese narration with emotion control or dialogue → load `chattts-workflow.md`
- Quick TTS (one-off, any tool) → load `tool-landscape.md`

**Q2 — What hardware?**
- Apple Silicon Mac → ALSO load `apple-silicon.md`
- NVIDIA GPU → proceed with tool default configs
- CPU only → check MeloTTS or Piper in `tool-landscape.md`
- No local GPU / insufficient VRAM → load ml-training pack's `references/platform-selection.md` for cloud GPU selection. Primary use case: training and fine-tuning; inference can often stay local.

**Q3 — Commercial use?**
- Yes → ALSO load `licensing-safety.md`

---

## Step 3: Apply Rules

Read matched reference(s) and apply rules directly. Rules are concrete parameters — not guidelines.

---

## Quick Rule Index

### Tool Landscape (`references/tool-landscape.md`)
- **Tier A/B Split**: 11 researched tools with benchmarks (incl. IndexTTS2 emotion control, CosyVoice2-0.5B ~150ms streaming) vs 4 notable tools → §Tier A / §Tier B
- **4 Selection Rules**: by language, hardware, use case, commercial license → §Quick Selection Rules

### Validation Scripts (`scripts/`)
- **`scripts/acx-check.sh`**: asserts the deterministically-measurable ACX specs — MP3 192kbps, 44.1kHz, channel layout (all-mono OR all-stereo), RMS -23..-18, sample peak < -3 dBFS, noise floor < -60, head 0.5-1.0s / tail 1.0-5.0s room-tone duration — exit code drives the gate. Note: "peak" here is SAMPLE peak (dBFS, ACX's spec), NOT dBTP; the script measures silence DURATION but cannot verify the silence is room tone vs digital zero (manual check).
- **`scripts/lufs-check.sh <platform>`**: asserts integrated LUFS in band + genuine true peak (input_tp dBTP) <= -1 dBTP (apple/apple-mono/spotify/youtube/ebu)

### Apple Silicon (`references/apple-silicon.md`)
- **16GB Budget Table**: 6 tools with VRAM data, MPS configs → §16GB Memory Budget
- **MPS Workarounds**: float32, s3tokenizer patch, PYTORCH_ENABLE_MPS_FALLBACK → §MPS Configuration

### Voice Cloning (`references/voice-cloning.md`)
- **3 Methods**: zero-shot, fine-tuned, voice design → §Cloning Methods
- **Minimum Reference Duration**: 3s to 15s per tool → §Reference Duration Table
- **Failure Modes**: noise leakage, accent bleeding, emotional flatness → §Failure Modes

### Audiobook Pipeline (`references/audiobook-pipeline.md`)
- **4 Non-Negotiables**: consistency, emotion, chapter control, multi-character → §Non-Negotiable Requirements
- **5-Step Pipeline**: prep → voice setup → generation → QC → post-processing → §Production Pipeline
- **ACX 8 Hard Specs**: MP3 192kbps CBR, 44.1kHz, all-mono OR all-stereo (mixed layout rejected), RMS -23 to -18 dB, sample peak < -3 dBFS, noise floor < -60, head 0.5-1.0s / tail 1.0-5.0s room tone → §ACX/Audible Specifications (validate with `scripts/acx-check.sh`)
- **Two-pass loudnorm**: measure (print_format=json) → apply measured values; I=-16 podcast / I=-23 EBU → §FFmpeg Mastering Commands

### Narration & Dubbing (`references/narration-dubbing.md`)
- **Blog Narration**: single voice, quick turnaround → §Blog Narration
- **Video Dubbing**: emotion matching, multilingual → §Video Dubbing
- **Mixed Language**: Chinese/English strategy → §Mixed Language Strategy

### ChatTTS Workflow (`references/chattts-workflow.md`)
- **Voice Persistence**: save/load `.pt` files for cross-session consistency → §创建并保存声音身份
- **Emotion Control**: oral/laugh/break parameters + scene presets → §情绪参数体系
- **Dual Speaker**: two `.pt` files + shared seed for dialogue → §双人对话工作流

### Licensing & Safety (`references/licensing-safety.md`)
- **GREEN/YELLOW/RED**: per-tool commercial safety classification → §License Tiers
- **Watermarking Traps**: hidden markers in generated audio → §Watermarking
- **Quality Sabotage**: intentional degradation patterns → §Anti-Patterns

---

## Anti-Skip Table

| Shortcut Attempt | Required Action |
|---|---|
| "I'll pick an appropriate TTS tool" | MUST use `tool-landscape.md` decision rules — tool choice depends on use case + hardware + license |
| "Short reference audio is fine" | MUST check minimum duration per tool in `voice-cloning.md` — ranges from 3s to 15s |
| "This tool is open source" | MUST check license tier in `licensing-safety.md` — open weights ≠ commercial use |
| "I'll master the audio later" | MUST apply ACX/podcast specs DURING pipeline in `audiobook-pipeline.md`, not after |
| "The loudness looks about right" | MUST run `scripts/acx-check.sh` / `scripts/lufs-check.sh` — ACX auto-rejects on ANY of 8 specs; eyeballing is not a gate |
| "I'll use IndexTTS2 duration control" | MUST NOT — token-count duration control is documented but NOT yet enabled in the current release (`voice-cloning.md` §4); the API will fail |
| "Any voice will work for now" | MUST set up voice identity BEFORE generation in `voice-cloning.md` — retrofitting means re-generating all audio |
