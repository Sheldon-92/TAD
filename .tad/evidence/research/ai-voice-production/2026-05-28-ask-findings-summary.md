# AI Voice Production — Research Findings Summary
Date: 2026-05-28
Notebook: e2f862c7-d984-401c-b3c9-11c8c735668f (26 sources)
Rounds: 5 deep ask rounds + baseline report

## Key Thresholds Extracted

### Quality Metrics
- WER acceptable: EN 1-3%, ZH 0.5-2.5%
- Speaker Similarity (SIM): 70-90% range for high-fidelity cloning
- N-MOS: 3.91-4.25 (naturalness), S-MOS: 3.97-4.18 (similarity)
- RTF real-time target: <0.2 (production), <1.0 (minimum acceptable)

### Apple Silicon (16GB) Viable Tools
- VoxCPM2 (2B): ~8GB VRAM, MPS via --device auto
- Qwen3-TTS 1.7B: 6-8GB, MUST use dtype=torch.float32 on MPS
- Chatterbox-TTS (350M-1.2B): ~6GB, auto float32 patch for MPS
- Kokoro (82M): minimal footprint, needs PYTORCH_ENABLE_MPS_FALLBACK=1
- Bark small: <4GB with SUNO_USE_SMALL_MODELS=True
- MLX-Audio: native Apple Silicon, OpenAI-compatible API

### Voice Cloning Minimum Reference Duration
- 3s: Qwen3-TTS, NeuTTS Air
- 5s: GPT-SoVITS, VibeVoice  
- 6s: XTTS-v2
- 10s: Chatterbox
- 15s: Kokoro
- Optimal quality: 10-30s regardless of minimum

### Audiobook Production Specs (ACX/Audible)
- Format: MP3 192kbps+
- Sample rate: 44.1kHz
- RMS: -23dB to -18dB
- Peak amplitude: below -3dB
- Silent segment at chapter start required

### Chunking Thresholds
- Chatterbox default: 120 chars, range 50-500
- OOM mitigation: reduce to 100-150
- Strategy: sentence boundary splitting

### Anti-Patterns
- ChatTTS/Bark: AR instability → multi-speaker drift, word omission
- Qwen3-TTS 0.6B: noise leakage from reference audio
- Chatterbox-Turbo: accent bleeding cross-language
- ChatTTS: intentionally degraded for anti-commercial (CC BY-NC 4.0)
- XTTS-v2: non-commercial license trap
- Fish S2 Pro: commercial requires enterprise license
- GPT-SoVITS v3: metallic artifacts from non-integer upsampling

### Licensing (Safe for Commercial)
- Apache-2.0: VoxCPM2, Kokoro, Qwen3-TTS
- MIT: Chatterbox, Bark, MeloTTS, Piper, OpenVoice
- RESTRICTED: XTTS-v2 (non-commercial), Fish S2 Pro (enterprise), ChatTTS (CC BY-NC 4.0)
