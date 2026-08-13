# Narration & Dubbing

> Short-to-medium form voice production workflows. For long-form audiobooks (100K+ words), see `audiobook-pipeline.md`.
> Covers blog narration, video dubbing, podcasts, and mixed-language content.

---

## Blog Narration Workflow

**Scenario**: Single voice, short text (<5 min audio), quick turnaround.

### Tool Selection
- **Fastest setup**: Kokoro (82M, minimal resources, instant start)
- **Best quality**: Fish S2 Pro (if available) or VoxCPM2
- **CPU-only**: MeloTTS or Piper
- **Mac user**: See `apple-silicon.md` for hardware-appropriate choice

> Source: baseline-report.md §7 (Best For framework)

### Workflow
1. **Prepare text**: Clean up blog post — remove formatting, links, code blocks
2. **Select voice**: Use existing reference audio or voice design (VoxCPM2)
3. **Generate**: Single-pass, no chunking needed for <2000 words
4. **Post-process**: Normalize + export

### Quick FFmpeg for Blog Audio
```bash
# Generate WAV from TTS tool, then:
ffmpeg -i blog-raw.wav \
  -af "loudnorm=I=-16:TP=-1.5:LRA=11" \
  -ar 44100 -codec:a libmp3lame -b:a 192k \
  blog-final.mp3
```

---

## Video Dubbing Workflow

**Scenario**: Voice over video content, emotion matching, potentially multilingual.

### Integration with video-creation Pack
Per the **INTERFACE** contract in the SKILL.md top blockquote:
- **This pack** decides: which TTS tool, voice quality thresholds, audio specs
- **video-creation pack** decides: audio-to-video sync timing, pacing, visual alignment
- If both load: this pack controls tool selection; video-creation controls timing

### Workflow
1. **Extract timing**: Get scene/segment durations from video timeline
2. **Match emotion**: Tag each segment with target emotion:
   - Action scenes → energetic, fast pace
   - Dialogue → natural, conversational
   - Transitions → neutral, measured
3. **Generate per-segment**: Match audio duration to video timing
4. **Tool choice for dubbing**:
   - Emotion-rich → Chatterbox (paralinguistic tags: `[laugh]`, `[sigh]`)
   - Multilingual → VoxCPM2 (30+ languages, consistent SIM cross-language)
   - Quick turnaround → Kokoro (fast generation, 82M params)

> Source: baseline-report.md §7 (Best For framework), §2 (tool capabilities)
5. **Sync check**: Verify audio length matches video segment ±0.5s

### Duration Matching
```python
# Target duration for a video segment
target_duration = 4.5  # seconds

# If generated audio is too long: increase speech rate
# If too short: add natural pauses or regenerate with slower pace
# Most tools support speed parameter: speed=0.8 (slower) to speed=1.2 (faster)
```

---

## Mixed Language Strategy (Chinese + English)

For content mixing Chinese and English (common in tech blogs, bilingual podcasts):

### Option 1: MeloTTS (Recommended for Mixed Content)
MeloTTS handles Chinese-English code-switching naturally within a single utterance. No language boundary markers needed.

**Advantages**:
- Real-time CPU inference (no GPU required)
- Natural prosody at language transitions
- MIT license (commercial safe)

**Limitation**: Lower overall quality ceiling than Fish S2 Pro or VoxCPM2.

> Source: ask-findings-summary.md §Anti-Patterns (MeloTTS advantage noted for mixed language)

### Option 2: Per-Language Split
For higher quality, split content by language and use language-optimized tools:
```
[zh] 今天我们来讨论一个有趣的话题
[en] The concept of attention mechanisms
[zh] 在深度学习中非常重要
```
Then generate each segment with the appropriate tool:
- Chinese segments → Fish S2 Pro (0.54% WER ZH) or VoxCPM2
- English segments → Fish S2 Pro (0.99% WER EN) or Kokoro

**Trade-off**: Higher quality per segment, but requires careful stitching at language transitions.

> Source: baseline-report.md §3 (Fish S2 Pro WER benchmarks)

### Option 3: VoxCPM2 (Unified Multilingual)
VoxCPM2 supports 30+ languages with consistent voice identity across all of them. Best when voice consistency matters more than per-language perfection.

> Source: baseline-report.md §3 (VoxCPM2 17/24 language SIM leadership)

---

## Short Content (<5 min) vs Medium Content (5-30 min)

| Aspect | Short (<5 min) | Medium (5-30 min) |
|---|---|---|
| Chunking | Not needed | Recommended (100-150 chars) |
| Voice drift risk | Negligible | Moderate — use seed locking |
| Tool choice | Any (Kokoro for speed) | Quality tools (Fish S2, VoxCPM2) |
| QC | Quick listen-through | Spot-check + automated SIM comparison |
| Post-processing | Simple normalize | Full loudnorm + silence padding |

---

## Podcast Specifications

### Platform-Specific LUFS Targets (integrated loudness)
These are LLM-non-restatable, platform-specific thresholds — use the exact numbers:

| Platform | Integrated LUFS | True Peak | Notes |
|---|---|---|---|
| Apple Podcasts (stereo) | **-16 LUFS** | **<= -1 dBTP** | Apple's stated target |
| Apple Podcasts (mono) | **-19 LUFS** | **<= -1 dBTP** | Mono target differs from stereo |
| Spotify | **-14 LUFS** | **<= -1 dBTP** | Spotify normalizes podcasts to -14 |
| YouTube | **-14 LUFS** | **<= -1 dBTP** | Consistent with video standards |
| Broadcast (EBU R128) | **-23 LUFS** | **<= -1 dBTP** | EBU R128 broadcast standard |
| General distribution | -16 LUFS | <= -1 dBTP | Safe default for multi-platform |

> Source: https://sone.app/blog/podcast-loudness-standards-2026-spotify-apple-youtube (retrieved 2026-06-13)

**Validate**: `scripts/lufs-check.sh apple episode.wav` (also: `apple-mono | spotify | youtube | ebu`).
Asserts integrated LUFS in band + true peak <= -1 dBTP. Re-master via two-pass loudnorm
(see `audiobook-pipeline.md` §Two-pass loudnorm) if it fails.

### FFmpeg Podcast Mastering
TP set to <= -1 dBTP per platform spec. For accuracy use two-pass loudnorm
(see `audiobook-pipeline.md` §Two-pass loudnorm) — single-pass shown here for quick turnaround.
```bash
# Apple Podcasts target (-16 LUFS stereo, TP <= -1 dBTP)
ffmpeg -i episode-raw.wav \
  -af "loudnorm=I=-16:TP=-1.0:LRA=11" \
  -ar 44100 -codec:a libmp3lame -b:a 128k \
  episode-apple.mp3

# Spotify target (-14 LUFS, TP <= -1 dBTP)
ffmpeg -i episode-raw.wav \
  -af "loudnorm=I=-14:TP=-1.0:LRA=11" \
  -ar 44100 -codec:a libmp3lame -b:a 128k \
  episode-spotify.mp3

# Broadcast EBU R128 target (-23 LUFS, TP <= -1 dBTP)
ffmpeg -i episode-raw.wav \
  -af "loudnorm=I=-23:TP=-1.0:LRA=11" \
  -ar 44100 -codec:a libmp3lame -b:a 128k \
  episode-ebu.mp3
```

### Podcast vs Audiobook Key Differences
| Aspect | Podcast | Audiobook |
|---|---|---|
| LUFS target | -16 to -14 | -23 to -18 RMS (ACX) |
| Format | MP3 128kbps typical | MP3 192kbps (ACX) |
| Episode length | 20-60 min typical | 8-12 hours total |
| Voice consistency | Per-episode | Cross-chapter critical |
| Multi-voice | Common (host + guest) | Character-based |

---

## Integration Points

- **Voice setup**: Always start in `voice-cloning.md` — establish identity before production
- **Long-form (>30 min)**: Transition to `audiobook-pipeline.md` — chunking and consistency management become critical
- **Tool selection**: Confirm choice in `tool-landscape.md` — especially hardware compatibility
- **Commercial use**: Verify license in `licensing-safety.md` before publishing
