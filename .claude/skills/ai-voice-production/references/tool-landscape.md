# TTS Tool Landscape (2026)

> Tool selection judgment rules. All benchmark data from NotebookLM research (26 sources).
> Tier A = benchmarked tools; Tier B = notable tools without full benchmark data.

---

## Tier A — Research-Benchmarked Tools

| Tool | Params | License | License Tier | WER (EN) | WER (ZH) | SIM | RTF | VRAM | Best For |
|---|---|---|---|---|---|---|---|---|---|
| Fish S2 / S2-Pro | 5B (4B slow-AR + 400M fast-AR) | Fish Audio Research License | YELLOW | 0.99% | 0.54% | N/R | N/R | N/R | Professional audiobooks (chapter-level control, 15K+ paralinguistic tags). Trained 10M+ hrs / 80+ langs |
| IndexTTS2 | Qwen3-based | Apache-2.0 (code); see model card | GREEN | N/R | beats F5-TTS by ~0.5pp, MaskGCT by ~2pp on test-zh | beats F5-TTS & MaskGCT | N/R | CUDA 12.8+, FP16 | Zero-shot TTS with disentangled emotion+speaker control (emo_audio_prompt + emo_alpha); token-count duration control (NOT yet enabled in current release) |
| CosyVoice2-0.5B | 0.5B | Apache-2.0 | GREEN | N/R | lowest CER on Seed-TTS hard set | N/R | first-packet latency ~150ms (streaming) | low | Low-latency streaming TTS (text-in/audio-out); 9 langs + 18+ Chinese dialects; cross-lingual & code-switch zero-shot |
| VoxCPM2 | 2B | Apache-2.0 | GREEN | N/R | N/R | 89.0 (FI) | 0.13 (w/ Nano-vLLM) | ~8GB | Multilingual diversity (30+ languages, voice design) |
| Chatterbox | 0.5B (Llama backbone) | MIT | GREEN | N/R | N/R | N/R | N/R | ~6GB | Paralinguistic expression ([laugh], [cough], [sigh]). ⚠️ Embeds Perth neural watermark on EVERY output — see `licensing-safety.md` §Watermarking |
| Kokoro | 82M | Apache-2.0 | GREEN | N/R | N/R | N/R | N/R | minimal | Rapid/cost-effective deployment (SOTA at 82M params) |
| F5-TTS | 300M | Open-Source | GREEN | N/R | N/R | N/R | N/R | N/R | Zero-shot similarity (diffusion-based) |
| Bark | ~1.5B | MIT | GREEN | N/R | N/R | N/R | N/R | <4GB (small) | Generative audio (integrated SFX and music) |
| MeloTTS | VITS2 | MIT | GREEN | N/R | N/R | N/R | N/R | CPU-capable | CPU-only real-time inference |
| OpenVoice V2 | AFM | MIT | GREEN | N/R | N/R | N/R | N/R | N/R | Instant voice cloning (tone color) |
| Piper | N/A | MIT | GREEN | N/R | N/R | N/R | N/R | CPU-capable | Low-latency local-first (C++ engine) |

> Source: baseline-report.md §2-3, ask-findings-summary.md §Quality Metrics

**Reading the table**: N/R = not researched (no benchmark data available). Only fill numbers where research data exists — never invent benchmarks.

### Key Benchmark Notes

- **Fish S2 Pro** leads intelligibility: 0.99% WER (EN), 0.54% WER (ZH), 81.88% EmergentTTS-Eval win rate. S2-Pro = 5B total (4B slow-AR + 400M fast-AR), trained on 10M+ hrs across 80+ languages
- **IndexTTS2** (Bilibili IndexTeam, arXiv 2506.21619): industrial zero-shot TTS with disentangled emotion + speaker control via a soft-instruction mechanism built on a fine-tuned Qwen3. Outperforms F5-TTS and MaskGCT on WER / speaker-similarity / emotional-fidelity; on **test-zh** it surpasses F5-TTS by **~0.5 percentage points** and MaskGCT by **~2 pp**. Explicit token-count duration control is documented but NOT yet enabled in the current release (see voice-cloning.md)
- **CosyVoice2-0.5B** (FunAudioLLM): 0.5B streaming model, **first-packet synthesis latency as low as 150ms** with text-in/audio-out streaming. Reduces pronunciation errors **30%-50% vs CosyVoice1**, reaches the **lowest CER on the Seed-TTS hard test set**; MOS **5.4 → 5.53**. Covers 9 languages (ZH/EN/JP/KO/DE/ES/FR/IT/RU) + **18+ Chinese dialects** with cross-lingual & code-switch zero-shot cloning. Fills the pack's low-latency streaming gap
- **VoxCPM2** leads cross-lingual similarity: outperformed ElevenLabs in 17/24 languages on MiniMax-MLS-test; Finnish SIM 89.0, Arabic 79.1; 1.68% average error rate across 30-language ASR
- **RTF 0.13** is achievable with VoxCPM2 + Nano-vLLM/vLLM-Omni integration
- **Kokoro** achieves quality comparable to 1B+ models at 82M params — the efficiency benchmark

> Source: baseline-report.md §3; IndexTTS2 — https://arxiv.org/abs/2506.21619 (retrieved 2026-06-13); CosyVoice2 — https://funaudiollm.github.io/cosyvoice2/ (retrieved 2026-06-13)

---

## Tier B — Notable Tools (Partial Data)

| Tool | License | License Tier | Key Strength |
|---|---|---|---|
| Qwen3-TTS | Apache-2.0 | GREEN | Two variants (0.6B streaming, 1.7B quality); 6-8GB VRAM on Apple Silicon |
| GPT-SoVITS | MIT | GREEN | Foundational zero-shot cloning methodology; v3 has non-integer upsampling artifacts |
| MLX-Audio | MIT | GREEN | Native Apple Silicon framework; OpenAI-compatible API |
| ChatTTS | CC BY-NC 4.0 | RED | Expressive conversational speech; intentionally degraded for anti-commercial |
| NeuTTS Air | N/R | N/R | Ultra-low 3s minimum reference for voice cloning |
| VibeVoice | N/R | N/R | Low 5s minimum reference for voice cloning |
| XTTS-v2 | Non-Commercial | RED | 6s minimum reference; commonly mistaken as open source (license trap) |

> Source: baseline-report.md §2 Notable Mentions, ask-findings-summary.md §Anti-Patterns + §Voice Cloning Minimum Reference Duration

---

## Quick Selection Rules

**Rule 1 — By Language Priority**:
- Chinese-primary → Fish S2 Pro (0.54% WER ZH) or VoxCPM2 (30+ languages)
- English-primary → Fish S2 Pro (0.99% WER EN) or Kokoro (efficient)
- Multilingual (3+) → VoxCPM2 (best cross-lingual SIM scores)
- Chinese+English mixed → MeloTTS (see `narration-dubbing.md` §Mixed Language)

**Rule 2 — By Hardware**:
- Apple Silicon 16GB → see `apple-silicon.md` for viable tool list
- NVIDIA GPU → any Tier A tool (check VRAM column)
- CPU only → MeloTTS or Piper (only options for real-time CPU inference)

**Rule 3 — By Use Case**:
- Audiobook → Fish S2 Pro (chapter control) or VoxCPM2 (multilingual)
- Quick narration → Kokoro (fast, minimal resources)
- Low-latency streaming (live / interactive, ~150ms first packet) → CosyVoice2-0.5B
- Expressive/emotional → Chatterbox (paralinguistic tags) or IndexTTS2 (reference-audio emotion transfer via `emo_audio_prompt` + `emo_alpha`, see `voice-cloning.md`)
- Voice cloning → OpenVoice V2 (instant) or VoxCPM2 (controllable); IndexTTS2 for disentangled emotion+speaker control

**Rule 4 — By Commercial License**:
- Must be commercial-safe → filter by GREEN tier only (see `licensing-safety.md`)
- Research/personal → any tool acceptable
