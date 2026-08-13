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

#### ACX/Audible Specifications — the 8 hard specs

ACX auto-rejects any file that misses **any one** of these — "files that don't meet
every spec get rejected, no manual overrides." Validate the full set, not a subset:

1. **Format**: MP3 **192 kbps CBR** (constant bit rate — VBR is rejected even if its average is 192 kbps)
2. **Sample rate**: **44.1 kHz**
3. **Channels**: **all-MONO OR all-STEREO** — ACX accepts either, but every file in a title MUST share one layout; **mixed layouts are auto-rejected**. (Mono is the common convention for spoken word, but stereo is NOT auto-rejected.)
4. **RMS level**: **-23 dBFS to -18 dBFS**
5. **Peak**: **below -3 dBFS** — this is SAMPLE peak (dBFS), the ACX spec; it is NOT dBTP. (For genuine true-peak dBTP on the podcast/streaming path, use `lufs-check.sh`.)
6. **Noise floor**: **below -60 dBFS**
7. **Head silence**: **0.5-1.0 s** of **room tone** (not digital zero) at chapter start
8. **Tail silence**: **1.0-5.0 s** of **room tone** (not digital zero) at chapter end

> Source: https://help.acx.com/s/article/what-are-the-acx-audio-submission-requirements (retrieved 2026-06-13); ask-findings-summary.md §Audiobook Production Specs

**Validate deterministically** — do NOT eyeball it. Run the bundled checker (asserts all 8 specs:
format/bitrate, sample rate, channel layout + cross-file consistency, RMS, sample peak, noise
floor, head & tail silence DURATION; exit code drives the gate). The one residual manual check:
the head/tail silence must be **room tone, not digital zero** — the script measures duration only:
```bash
scripts/acx-check.sh final/ch-001.mp3 final/ch-002.mp3   # exit 0 = all specs pass; pass ALL files together so channel-layout consistency is checked
```

#### FFmpeg Mastering Commands

**Normalize to ACX RMS range (-20dB target)**:
```bash
ffmpeg -i raw/ch-001.wav -af "loudnorm=I=-20:TP=-3:LRA=7" -ar 44100 mastered/ch-001.wav
```

**Two-pass loudnorm (deterministic — the right way; backs `scripts/lufs-check.sh`)**:
Single-pass loudnorm is a one-shot estimate and drifts. For platform-accurate loudness,
measure first (pass 1), then feed the measured values back (pass 2):
```bash
# Pass 1 — MEASURE (print JSON, write nothing). Use I=-16 for podcast/streaming, I=-23 for EBU broadcast.
ffmpeg -i raw/ch-001.wav \
  -af "loudnorm=I=-16:TP=-1.5:LRA=11:print_format=json" -f null /dev/null
# → records measured_I, measured_TP, measured_LRA, measured_thresh, target_offset

# Pass 2 — APPLY measured values back into loudnorm at the SAME target:
ffmpeg -i raw/ch-001.wav \
  -af "loudnorm=I=-16:TP=-1.5:LRA=11:measured_I=<measured_I>:measured_TP=<measured_TP>:measured_LRA=<measured_LRA>:measured_thresh=<measured_thresh>:offset=<target_offset>:linear=true" \
  -ar 44100 mastered/ch-001.wav
```
- `I=-16` → podcast / streaming (Apple, Spotify-bound); `I=-23` → EBU R128 broadcast.
- Verify the result: `scripts/lufs-check.sh apple mastered/ch-001.wav`

> Source: https://github.com/slhck/ffmpeg-normalize/blob/master/README.md (retrieved 2026-06-13)

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

**Batch process all chapters (TWO-PASS — the right way at scale)**:
Single-pass loudnorm drifts (see §Two-pass loudnorm above), and that drift compounds across an
8-12 hour multi-chapter book — so the batch path MUST also be two-pass, NOT a single-pass shortcut.
Each chapter is measured (pass 1), then its OWN measured values are fed back (pass 2):
```bash
for f in mastered/ch-*.wav; do
  base=$(basename "$f" .wav)
  # Pass 1 — MEASURE this chapter (ACX target I=-20, TP=-3, LRA=7), capture JSON.
  meas=$(ffmpeg -hide_banner -i "$f" \
    -af "loudnorm=I=-20:TP=-3:LRA=7:print_format=json" -f null /dev/null 2>&1)
  mi=$(printf '%s' "$meas"  | grep -oE '"input_i"[^,]*'      | grep -oE '[-0-9.]+' | head -1)
  mtp=$(printf '%s' "$meas" | grep -oE '"input_tp"[^,]*'     | grep -oE '[-0-9.]+' | head -1)
  mlra=$(printf '%s' "$meas"| grep -oE '"input_lra"[^,]*'    | grep -oE '[-0-9.]+' | head -1)
  mth=$(printf '%s' "$meas" | grep -oE '"input_thresh"[^,]*' | grep -oE '[-0-9.]+' | head -1)
  off=$(printf '%s' "$meas" | grep -oE '"target_offset"[^,]*'| grep -oE '[-0-9.]+' | head -1)
  # Pass 2 — APPLY this chapter's measured values back at the same target.
  ffmpeg -hide_banner -i "$f" \
    -af "loudnorm=I=-20:TP=-3:LRA=7:measured_I=${mi}:measured_TP=${mtp}:measured_LRA=${mlra}:measured_thresh=${mth}:offset=${off}:linear=true" \
    -codec:a libmp3lame -b:a 192k -ar 44100 \
    "final/${base}.mp3"
done
# Then gate the whole batch:  scripts/acx-check.sh final/ch-*.mp3
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
