# Audiobook Production Pipeline

> Complete pipeline for long-form audio production (100K+ word manuscripts).
> This is the deepest reference file. Covers the full workflow from manuscript prep to ACX-ready output.

---

## Non-Negotiable Requirements

Any competitive audiobook TTS system MUST satisfy all four:

1. **Voice Consistency** — stable timbre, pacing, and emotional resonance across 8-12 hours of continuous audio. No "voice drift" between chapters.
2. **Emotional Range** — performance-based delivery, not flat narration. Must execute complex narrative arcs.
3. **Chapter-Level Control** — revisions to a single paragraph do NOT require regenerating the entire chapter.
4. **Multi-Character Support** — distinct vocal identities for different characters with speaker-turn management.

> Source: baseline-report.md §1 (Fish Audio technical analysis)

**Tool implication**: Only Fish S2 Pro and VoxCPM2 currently satisfy all four at production quality. Kokoro and Chatterbox satisfy 1-3 but have limitations on multi-character at scale.

---

## Chunking Strategy

Long texts must be split to prevent VRAM exhaustion and generation quality degradation.

### Rules
- **Split at sentence boundaries** — never mid-sentence, never mid-word
- **Default chunk size**: 120 characters (Chatterbox default)
- **Safe range**: 100-150 characters per chunk
- **OOM mitigation**: If generation crashes, reduce to 100 characters
- **Maximum**: 500 characters (quality degrades beyond this for most models)

> Source: ask-findings-summary.md §Chunking Thresholds

### Implementation
```python
import re

def chunk_text(text, max_chars=120):
    sentences = re.split(r'(?<=[.!?。！？])\s+', text)
    chunks = []
    current = ""
    for sent in sentences:
        if len(current) + len(sent) > max_chars and current:
            chunks.append(current.strip())
            current = sent
        else:
            current = current + " " + sent if current else sent
    if current:
        chunks.append(current.strip())
    return chunks
```

---

## Consistency Management

### Seed Locking
Use generation seeds to maintain identical vocal characteristics across sessions:
```python
# Set seed BEFORE each generation call
import torch
torch.manual_seed(42)
# Same seed + same reference audio = consistent voice identity
```

### Voice Conditioning Cache
Pre-compute and cache the voice embedding from reference audio:
```python
# Compute once, reuse across all chapters
voice_embedding = model.encode_reference(ref_audio_path)
# Save to disk for cross-session consistency
torch.save(voice_embedding, "voice_cache/narrator.pt")
```

### Tokenizer-Free Architecture (VoxCPM2)
VoxCPM2 uses a Tokenizer-free Diffusion-AR architecture that inherently resists voice drift across long-form generation. No additional consistency configuration needed beyond seed locking.

> Source: baseline-report.md §2 (VoxCPM2 architectural highlight: "Tokenizer-free Diffusion-AR")

---

## Multi-Character Management

### Character Voice Registry
```yaml
characters:
  narrator:
    tool: fish-s2-pro
    ref_audio: voices/narrator-30s.wav
    seed: 42
    emotion_default: neutral
  protagonist:
    tool: voxcpm2
    voice_design: "(young male voice, energetic, slightly breathless)"
    seed: 1337
  antagonist:
    tool: chatterbox
    ref_audio: voices/villain-15s.wav
    seed: 7777
    paralinguistic: ["[laugh]", "[whisper]"]
```

### Speaker Turn Detection
Tag dialogue in manuscript before generation:
```
[narrator] The door opened slowly.
[protagonist] "Who's there?" he called out.
[antagonist] [whisper] "Just me." [laugh]
```

### Emotion Tagging (Fish S2 Pro)
Fish S2 Pro supports 15,000+ paralinguistic tags for fine-grained emotion control:
- Emotion tags: `<happy>`, `<sad>`, `<angry>`, `<fearful>`, `<surprised>`
- Paralinguistic: `[chuckle]`, `[sigh]`, `[gasp]` (Chatterbox native)

> Source: baseline-report.md §6

---

## Production Pipeline (5 Steps)

### Step 1: Manuscript Preparation
1. Standardize punctuation (smart quotes → straight quotes, em dashes consistent)
2. Tag all dialogue with character identifiers (see speaker turn format above)
3. Mark chapter boundaries: `--- CHAPTER {N}: {Title} ---`
4. Mark emotional beats: `[emotion: tense]` before charged passages
5. Split into per-chapter files: `chapters/ch-001.txt`, `ch-002.txt`, etc.

### Step 2: Voice Setup
1. Record or select reference audio per character (see `voice-cloning.md`)
2. Test each voice with 2-3 sample passages
3. Evaluate: SIM >85%, WER <2%, listen test for naturalness
4. Lock seeds and cache voice embeddings
5. Document voice registry (see format above)

### Step 3: Generation
1. Process chapter-by-chapter, chunk-by-chunk
2. Apply per-character voice + emotion tags
3. Save raw output: `raw/{chapter}-{chunk}-{NNN}.wav`
4. Log generation parameters for each chunk (reproducibility)

### Step 4: Quality Control
1. **Automated**: Run WER check on generated audio vs source text
2. **Automated**: Compare SIM between first and last chunk of each chapter (drift detection)
3. **Manual listen**: Spot-check 3-5 chunks per chapter for naturalness
4. **Regenerate**: Failed chunks only — chapter-level control means no full re-gen

### Step 5: Post-Processing (Mastering)

#### ACX/Audible Specifications
- **Format**: MP3 192kbps CBR (constant bit rate)
- **Sample rate**: 44.1kHz
- **RMS level**: -23dB to -18dB
- **Peak amplitude**: below -3dB (no clipping)
- **Noise floor**: below -60dB
- **Opening**: 0.5-1.0s silence at chapter start
- **Closing**: 1.0-5.0s silence at chapter end

> Source: ask-findings-summary.md §Audiobook Production Specs (ACX/Audible)

#### FFmpeg Mastering Commands

**Normalize to ACX RMS range (-20dB target)**:
```bash
ffmpeg -i raw/ch-001.wav -af "loudnorm=I=-20:TP=-3:LRA=7" -ar 44100 mastered/ch-001.wav
```

**Convert to ACX-compliant MP3**:
```bash
ffmpeg -i mastered/ch-001.wav -codec:a libmp3lame -b:a 192k -ar 44100 final/ch-001.mp3
```

**Add chapter silence (0.5s opening, 2s closing)**:
```bash
ffmpeg -i mastered/ch-001.wav \
  -af "adelay=500|500,apad=pad_dur=2" \
  -ar 44100 padded/ch-001.wav
```

**Batch process all chapters**:
```bash
for f in mastered/ch-*.wav; do
  base=$(basename "$f" .wav)
  ffmpeg -i "$f" \
    -af "loudnorm=I=-20:TP=-3:LRA=7" \
    -codec:a libmp3lame -b:a 192k -ar 44100 \
    "final/${base}.mp3"
done
```

**Verify ACX compliance**:
```bash
# Check RMS level (should be between -23 and -18)
ffmpeg -i final/ch-001.mp3 -af "volumedetect" -f null /dev/null 2>&1 | grep mean_volume

# Check peak level (should be below -3)
ffmpeg -i final/ch-001.mp3 -af "volumedetect" -f null /dev/null 2>&1 | grep max_volume
```

---

## Quality Verification Commands

### Full chapter QC script
```bash
#!/bin/bash
# verify-acx.sh — check all final MP3s against ACX specs
for f in final/ch-*.mp3; do
  echo "=== $(basename $f) ==="
  stats=$(ffmpeg -i "$f" -af "volumedetect" -f null /dev/null 2>&1)
  rms=$(echo "$stats" | grep "mean_volume" | grep -oE '[-0-9.]+')
  peak=$(echo "$stats" | grep "max_volume" | grep -oE '[-0-9.]+')
  
  # RMS check: -23 to -18
  if (( $(echo "$rms < -23" | bc -l) )) || (( $(echo "$rms > -18" | bc -l) )); then
    echo "  FAIL RMS: ${rms}dB (need -23 to -18)"
  else
    echo "  PASS RMS: ${rms}dB"
  fi
  
  # Peak check: below -3
  if (( $(echo "$peak > -3" | bc -l) )); then
    echo "  FAIL Peak: ${peak}dB (need below -3)"
  else
    echo "  PASS Peak: ${peak}dB"
  fi
done
```

---

## Throughput Expectations

| Tool | RTF (GPU) | RTF (Apple Silicon) | 1 Hour Audio Generation Time |
|---|---|---|---|
| VoxCPM2 + Nano-vLLM | 0.13 | N/A (server-side) | ~8 minutes |
| Kokoro | N/R | Fast (82M minimal) | ~15-30 minutes (estimated) |
| MeloTTS | N/R (CPU real-time) | CPU real-time | ~60 minutes (1:1) |
| Fish S2 Pro | N/R | N/R | Varies by config |

> Source: baseline-report.md §5 (VoxCPM2 RTF 0.13 with Nano-vLLM)

**Planning rule**: For a 10-hour audiobook, budget 2-4 hours for generation (with VoxCPM2/GPU) or 10+ hours (with CPU-only tools). Add 2-3 hours for QC and mastering regardless of tool speed.

---

## File Organization

```
project/
├── manuscript/
│   ├── ch-001.txt          # Tagged, cleaned chapter text
│   ├── ch-002.txt
│   └── characters.yaml     # Voice registry
├── voices/
│   ├── narrator-30s.wav    # Reference audio per character
│   └── narrator.pt         # Cached voice embedding
├── raw/
│   └── ch-001-chunk-001.wav
├── mastered/
│   └── ch-001.wav          # Normalized, full chapter
└── final/
    └── ch-001.mp3          # ACX-compliant output
```
