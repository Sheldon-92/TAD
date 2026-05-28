# Voice Cloning

> Voice identity setup and validation rules. For chapter-level USE of a cloned voice, see `audiobook-pipeline.md`.
> Cross-reference, don't duplicate.

---

## Cloning Methods

### 1. Zero-Shot Cloning
Replicate a speaker's timbre from a short audio sample — no fine-tuning required.

**Tools**: OpenVoice V2, Fish Speech S2, VoxCPM2, F5-TTS
**Reference audio**: 10-30 seconds sufficient for most tools (see duration table below)
**Trade-off**: Fastest setup, lowest fidelity ceiling. Good for prototyping and non-critical voice matching.

> Source: baseline-report.md §4

### 2. Fine-Tuned / Ultimate Cloning
Highest fidelity — requires **both the reference audio AND its exact transcript**. Audio-continuation method reproduces vocal nuance including rhythm, breathing patterns, and micro-pauses.

**Tools**: VoxCPM2 (controllable cloning), Fish Speech S2 (ultimate cloning mode)
**Reference audio**: 30s+ recommended for best results
**Trade-off**: Highest quality, requires transcript preparation. Best for production audiobooks.

> Source: baseline-report.md §4

### 3. Voice Design (Text Description)
Create a synthetic voice from natural language description — no reference audio needed.

**Tool**: VoxCPM2 (exclusive feature)
**Syntax**: `(warm middle-aged female voice with a slow, calm pace) Your text here.`
**Trade-off**: No audio sample needed, but less precise than cloning from reference. Good for fictional characters.

> Source: baseline-report.md §4

---

## Reference Audio Duration Table

Minimum duration required for acceptable cloning quality per tool:

| Tool | Minimum Duration | Optimal Range | Notes |
|---|---|---|---|
| Qwen3-TTS | 3s | 10-30s | Lowest barrier to entry |
| NeuTTS Air | 3s | 10-30s | Ultra-low minimum |
| GPT-SoVITS | 5s | 10-30s | Foundational cloning methodology |
| VibeVoice | 5s | 10-30s | Same minimum as GPT-SoVITS |
| XTTS-v2 | 6s | 10-30s | Non-commercial license (see licensing-safety.md) |
| Chatterbox | 10s | 15-30s | Below 10s → quality degrades noticeably |
| Kokoro | 15s | 20-30s | Needs more audio for StyleTTS2 conditioning |

> Source: ask-findings-summary.md §Voice Cloning Minimum Reference Duration

**Note**: Only tools with research-measured minimums are listed above. Other tools (OpenVoice V2, VoxCPM2, Fish S2 Pro, F5-TTS) support zero-shot cloning with the general "10-30 seconds" recommendation from baseline research, but their exact per-tool minimums were not benchmarked.

**Universal rule**: Regardless of per-tool minimum, **10-30 seconds of clean audio** is the optimal range. Shorter CAN work but quality drops.

---

## Reference Audio Quality Rules

### MUST
- Clean recording with minimal background noise (SNR > 30dB)
- Consistent speaking style (don't mix whisper and shout in one sample)
- Natural speech (not read-aloud-from-script monotone)
- Single speaker only in the reference clip
- Match the target output style (if you want expressive narration, provide expressive reference)

### MUST NOT
- Use audio with background music or ambient noise
- Use compressed/low-bitrate audio (<128kbps) as reference
- Use audio with reverb/echo (dry recording preferred)
- Mix multiple speakers in one reference clip
- Use AI-generated audio as reference for cloning (quality compounding loss)

---

## Quality Threshold Interpretation

When evaluating cloning results, use these thresholds:

| Metric | Research Range | Interpretation |
|---|---|---|
| SIM (Speaker Similarity) | 70-90% | High-fidelity cloning range. VoxCPM2 achieved 89.0 (FI), 79.1 (AR) |
| WER (Word Error Rate) | EN 1-3%, ZH 0.5-2.5% | Acceptable intelligibility. Fish S2 Pro leads: 0.99% EN, 0.54% ZH |
| N-MOS (Naturalness) | 3.91-4.25 | Research-observed range for current SOTA tools |
| S-MOS (Similarity) | 3.97-4.18 | Research-observed range for speaker fidelity |
| RTF (Real-Time Factor) | <0.2 production, <1.0 minimum | VoxCPM2 + Nano-vLLM achieves 0.13 |

> Source: ask-findings-summary.md §Quality Metrics, baseline-report.md §3

**Interpretation guide**: Compare your output against the research ranges above. Values within range = production-quality. Values outside range = investigate tool choice, reference audio quality, or generation parameters.

---

## Failure Modes

| Failure | Cause | Detection | Fix |
|---|---|---|---|
| Noise leakage | Noisy reference audio bleeds into output | Listen for consistent background hiss | Re-record reference in quiet environment |
| Accent bleeding | Cross-language accent contamination | Target language has wrong prosody patterns | Use language-matched reference audio |
| Emotional flatness | Reference audio too monotone | Output lacks dynamic range | Provide expressive reference sample |
| Voice drift | Inconsistent timbre across long generation | Compare first and last segments | Use seed locking (see `audiobook-pipeline.md`) |
| Metallic artifacts | Non-integer upsampling (GPT-SoVITS v3) | Tinny/robotic quality in output | Switch to different tool or version |
| Word omission | AR model instability (ChatTTS/Bark) | Missing words in output | Use non-AR model or regenerate segment |

> Source: ask-findings-summary.md §Anti-Patterns

---

## Cloning Workflow

```
1. SELECT method (zero-shot / fine-tuned / voice design)
   └── Based on: reference audio availability + quality requirement + time budget

2. PREPARE reference audio
   └── Check: duration meets tool minimum + quality rules above + single speaker

3. TEST with short passage (1-2 sentences)
   └── Evaluate: SIM score + listen test + check for failure modes

4. ITERATE if needed
   └── Adjust: reference audio, tool selection, or generation parameters

5. LOCK voice identity
   └── Save: generation seed, reference audio path, tool config
   └── Hand off to audiobook-pipeline.md for production use
```
