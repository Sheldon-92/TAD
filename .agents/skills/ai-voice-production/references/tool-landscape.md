# TTS Tool Landscape (2026)

> Tool selection judgment rules. All benchmark data from NotebookLM research (26 sources).
> Tier A = benchmarked tools; Tier B = notable tools without full benchmark data.

---

## Tier A — Research-Benchmarked Tools

| Tool | Params | License | License Tier | WER (EN) | WER (ZH) | SIM | RTF | VRAM | Best For |
|---|---|---|---|---|---|---|---|---|---|
| Fish S2 Pro | 4B | Fish Research License | YELLOW | 0.99% | 0.54% | N/R | N/R | N/R | Professional audiobooks (chapter-level control, 15K+ paralinguistic tags) |
| VoxCPM2 | 2B | Apache-2.0 | GREEN | N/R | N/R | 89.0 (FI) | 0.13 (w/ Nano-vLLM) | ~8GB | Multilingual diversity (30+ languages, voice design) |
| Chatterbox | 350M | MIT | GREEN | N/R | N/R | N/R | N/R | ~6GB | Paralinguistic expression ([laugh], [cough], [sigh]) |
| Kokoro | 82M | Apache-2.0 | GREEN | N/R | N/R | N/R | N/R | minimal | Rapid/cost-effective deployment (SOTA at 82M params) |
| F5-TTS | 300M | Open-Source | GREEN | N/R | N/R | N/R | N/R | N/R | Zero-shot similarity (diffusion-based) |
| Bark | ~1.5B | MIT | GREEN | N/R | N/R | N/R | N/R | <4GB (small) | Generative audio (integrated SFX and music) |
| MeloTTS | VITS2 | MIT | GREEN | N/R | N/R | N/R | N/R | CPU-capable | CPU-only real-time inference |
| OpenVoice V2 | AFM | MIT | GREEN | N/R | N/R | N/R | N/R | N/R | Instant voice cloning (tone color) |
| Piper | N/A | MIT | GREEN | N/R | N/R | N/R | N/R | CPU-capable | Low-latency local-first (C++ engine) |

> Source: baseline-report.md §2-3, ask-findings-summary.md §Quality Metrics

**Reading the table**: N/R = not researched (no benchmark data available). Only fill numbers where research data exists — never invent benchmarks.

### Key Benchmark Notes

- **Fish S2 Pro** leads intelligibility: 0.99% WER (EN), 0.54% WER (ZH), 81.88% EmergentTTS-Eval win rate
- **VoxCPM2** leads cross-lingual similarity: outperformed ElevenLabs in 17/24 languages on MiniMax-MLS-test; Finnish SIM 89.0, Arabic 79.1; 1.68% average error rate across 30-language ASR
- **RTF 0.13** is achievable with VoxCPM2 + Nano-vLLM/vLLM-Omni integration
- **Kokoro** achieves quality comparable to 1B+ models at 82M params — the efficiency benchmark

> Source: baseline-report.md §3

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
- Expressive/emotional → Chatterbox (paralinguistic tags)
- Voice cloning → OpenVoice V2 (instant) or VoxCPM2 (controllable)

**Rule 4 — By Commercial License**:
- Must be commercial-safe → filter by GREEN tier only (see `licensing-safety.md`)
- Research/personal → any tool acceptable
