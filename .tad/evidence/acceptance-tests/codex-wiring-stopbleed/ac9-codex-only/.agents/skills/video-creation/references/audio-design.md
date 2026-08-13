# Audio Design Reference

> Source: Research notebook a62f253b (27 sources), Layer 5 + Supplementary Research
> ⚠️ SFX timing rules in §SFX Timing are derived from supplementary WebSearch, not notebook sources — treat as best-practice approximations.

---

## BPM-to-Video-Type Mapping

Match background music BPM to the energy level and purpose of the video type.

| Video Type | BPM Range | Instrumentation |
|-----------|-----------|-----------------|
| Product Demo (high energy) | 130–200 BPM | Upbeat electronic, driving synth basslines, punchy percussion |
| Social Media Short | 110–130 BPM | Medium-fast, lifestyle-oriented, modern pop production |
| Tutorial / Explainer | No strict BPM | Consistent rhythm, organic instruments (acoustic guitar, light piano), NO vocals |
| Corporate / Professional | 100–130 BPM | Pop range, balanced energy, minimal dynamics |
| Emotional / Storytelling | 20–80 BPM | Ambient to full orchestra, sustained synths, cinematic pads |

**Critical Rule**: For any video with voiceover or dialogue, strictly avoid:
- Vocal leads (any track with singing)
- Voice-like lead instruments: trumpet, piano lead melody, lead guitar
- Reason: vocal-range instruments compete with the spoken word frequency (300–3000 Hz)

**Music selection checklist**:
- [ ] BPM matches video type
- [ ] No vocals if voiceover present
- [ ] No voice-like lead instruments if voiceover present
- [ ] Music energy arc matches video story arc (build toward CTA)

[Source: Research findings Supplementary Research]

---

## Volume Rules

### Mix Levels

| Track | Volume Level |
|-------|-------------|
| Voiceover / dialogue | 100% (reference level) |
| Background music | 10–20% of voiceover level |
| Sound effects | 60–80% (present but not jarring) |
| Ambient/room tone | 5–10% |

**Implementation (FFmpeg amix)**:
```bash
ffmpeg -i voiceover.mp3 -i music.mp3 \
  -filter_complex "[1:a]volume=0.15[music];[0:a][music]amix=inputs=2:duration=first" \
  output_mix.mp3
```

**Audio ducking** (auto-lower music when voiceover is active):
```bash
ffmpeg -i music.mp3 -i voiceover.mp3 \
  -filter_complex "[0][1]sidechaincompress=threshold=0.02:ratio=10:attack=50:release=500[out]" \
  -map "[out]" output_ducked.mp3
```
**Recommended music-under-voice values (sourced):** `attack 50ms`, `release 500ms`, `threshold 0.02`, `ratio 10:1`. A more aggressive set is `attack 30ms`, `release 800ms`, `threshold 0.015`, `ratio 15:1`. These run **slower** than naive 20/250 guesses — the longer release lets music swell back smoothly between phrases instead of pumping. Tune attack DOWN (toward 30ms) if early syllables get clipped; tune release UP (toward 800ms) if music pumps between words.

Note: `attack` and `release` are in **milliseconds** (not seconds). Values < 1 (e.g., `attack=0.2`) are interpreted as 0.2ms — effectively instant, producing harsh gain jumps not smooth ducking.

[Source: Research findings Layer 5 + https://ffmpeg.org/pipermail/ffmpeg-user/2018-August/040933.html + https://cloudinary.com/guides/video-effects/ffmpeg-add-audio-to-video, retrieved 2026-06-14]

---

## Audio Structure Rules

### Separate `<audio>` Tags
**Rule**: Audio must be in separate `<audio>` tags, not attached to `<video>` tags.

**Why**: Attaching audio to the video element causes sync issues during frame capture (Puppeteer-based renderers capture frames, not realtime). Audio and video are composited by FFmpeg at export time.

**Wrong**:
```html
<video src="clip.mp4" audio="music.mp3">  <!-- not valid anyway -->
```

**Correct** (HyperFrames):
```html
<audio id="bg-music" src="music.mp3" data-hf-audio-track="background"></audio>
```

[Source: Research findings Layer 5]

---

### Caption Leak Prevention
**Rule**: After every caption group exits, send a hard kill command to the caption element.

**Why**: TTS timing can have trailing silence that leaves the last caption visible into the next scene. A hard kill prevents bleed.

**Pattern**:
```javascript
// HyperFrames timeline pattern
tl.to(".caption", { opacity: 0, duration: 0.1 }, "scene-exit")
tl.set(".caption", { innerHTML: "" }, "scene-exit+=0.1")  // hard kill
```

[Source: Research findings Layer 5]

---

## TTS Integration Rules

### Whisper Model Selection
- **English audio**: Use `whisper-1` or `large-v2`
- **Non-English audio**: Do NOT use `.en` suffix models (e.g., `whisper-en` — restricted to English phonemization)
- **Non-English phonemization**: Install `espeak-ng` for accurate phoneme breakdown
- **Locale inference**: Auto-infer locale from Voice ID when using cloud TTS (ElevenLabs, Azure TTS, etc.)

### Caption Accuracy
- Auto-generated captions (Whisper): typical accuracy 85–95%
- Required accuracy for publication: ≥99% → manual review required for all auto-generated captions
- Review focus: proper nouns, technical terms, numbers, abbreviations

---

## SFX Timing Rules

> ⚠️ [Source: WebSearch — approximate] The following rules are derived from supplementary web research, not the primary research notebook. Treat as best-practice starting points, verify against your specific implementation.

### Pre-Lead Timing
**Rule**: Start a whoosh/transition sound effect 10–20ms BEFORE the visual transition begins.

**Why**: The human brain processes audio approximately 10–20ms faster than visual input. Starting audio slightly ahead aligns perceived sync.

**Fast whoosh**: Use for quick cuts and snappy transitions  
**Slow whoosh**: Use for dramatic reveals and anticipation-building transitions

[Source: WebSearch — approximate]

### Visual Event → SFX Type Mapping

| Visual Event | SFX Type |
|-------------|----------|
| Object appearing / popping in | pop / rise |
| Slide / screen transition | whoosh |
| Object hitting / impacting | impact / boom |
| UI interaction / button click | click / mechanical |
| Direction change / reversal | sweep |
| Text appearing (typewriter) | soft keyboard ticks |

[Source: WebSearch — approximate]

### Frequency Separation for Overlapping SFX
When multiple SFX overlap (e.g., transition + element appearance):
- **Sharp/transient SFX**: keep in high frequencies (8kHz+)
- **Whoosh/sweep SFX**: keep in mid frequencies (500Hz–4kHz)
- **Impact/rumble SFX**: keep in low frequencies (sub-500Hz)

This prevents frequency masking and keeps each effect audible.

[Source: WebSearch — approximate]

### Looping SFX Rule
**Rule**: Looping sound effects must stop after 5 seconds or 1 complete loop (whichever is shorter).  
**Why**: Infinite audio loops cause accessibility issues (screen readers interpret as loading state) and are jarring if the video loops.

[Source: WebSearch — approximate]

---

## Platform Audio Requirements

| Platform | Audio Format | Bitrate | Max Channels |
|----------|-------------|---------|--------------|
| YouTube | AAC | 128kbps+ | Stereo |
| TikTok | AAC | 128kbps+ | Stereo |
| Instagram Reels | AAC | 128kbps+ | Stereo |
| Twitter/X | AAC | 128kbps+ | Stereo |
| Web (general) | AAC or WebM/Opus | 128kbps+ | Stereo |

> ⚠️ **TikTok / Instagram audio specs above are partial or absent at the source.** TikTok's official
> Content Posting API lists NO audio codec/sample-rate/bitrate; Instagram's primary spec gives only
> "AAC, 48 kHz maximum, 1–2 channels, 128 kbps". The 128 kbps+ / stereo rows for TikTok are
> third-party convention, not first-party. [Source: deep-research §(d), TikTok Content Posting API +
> Meta Graph API media reference, retrieved 2026-06-14]

**Normalize audio before export, but there is NO single cross-platform LUFS number.** The only
DOCUMENTED target is YouTube **-14 LUFS** (attenuate-only). TikTok and Instagram Reels publish **no
official LUFS figure** (every online number for them is an estimate). A safe pragmatic master for
short-form mixed speech+music is **-16 LUFS / -1 dBTP** — see `references/quality.md §Loudness
Normalization` for the full documented-vs-estimated table.

---

## Music Licensing Guidance

> Note: This section addresses practical guidance only. Consult legal counsel for compliance decisions.

### License Types for Background Music
| Type | Typical Source | Usage Right |
|------|---------------|-------------|
| Royalty-free | Epidemic Sound, Artlist, Musicbed | One-time license fee, unlimited use |
| Creative Commons (CC0) | ccMixter, Free Music Archive | Free to use, no attribution required for CC0 |
| Creative Commons (CC BY) | Various platforms | Free to use with attribution |
| Stock music | Pond5, AudioJungle | Per-project license |
| AI-generated | Suno, Udio, Soundraw | Check platform terms — varies |

**For commercial video**: Use royalty-free or purchased licenses (Epidemic Sound, Artlist). CC music can require attribution in video description, which affects platform presentation.

**For social media with platform music**: TikTok, Instagram, and YouTube have built-in licensed music libraries for organic (non-paid) content. Using these avoids copyright claims automatically within those platforms. Exporting platform-music content to other contexts may still trigger claims.

---

## Audio Post-Production Workflow

### Standard Mixing Order
1. **Record / source all audio**: voiceover, music, SFX
2. **Clean voiceover**: noise reduction, de-click, equalization
3. **Level voiceover**: normalize to -12 to -6 dBFS peak
4. **Add music bed**: bring in at -20 to -25 dBFS (10-20% of voiceover)
5. **Layer SFX**: add at -10 to -14 dBFS (louder than music, quieter than voice)
6. **Sidechain compress** (optional): auto-duck music under voiceover (see FFmpeg `sidechaincompress` above)
7. **Normalize to a pragmatic target**: -16 LUFS integrated, -1 dBTP true peak for short-form mixed speech+music (YouTube documents -14 attenuate-only; TikTok/IG publish no number — see `references/quality.md §Loudness`)
8. **Export**: AAC 128kbps+ stereo

### FFmpeg Audio Mastering Chain
Complete audio mastering for voiceover video:
```bash
# Step 1: Normalize voiceover
ffmpeg -i raw_voiceover.wav \
  -filter:a "highpass=f=80,dynaudnorm=p=0.9:m=100:g=15" \
  voiceover_clean.wav

# Step 2: Mix with music and sidechain compress
ffmpeg -i voiceover_clean.wav -i music.mp3 \
  -filter_complex "
    [1:a]volume=0.15[music_quiet];
    [0:a][music_quiet]sidechaincompress=threshold=0.02:ratio=10:attack=50:release=500[mixed];
    [mixed]loudnorm=I=-16:TP=-1:LRA=11[out]
  " \
  -map "[out]" final_audio.m4a
```
Note: `sidechaincompress` attack/release units are **milliseconds**. `attack=50:release=500` = 50ms attack, 500ms release (sourced music-under-voice values). Do not use fractional values below 1 — they produce instant gain reduction, not ducking. `loudnorm` here targets **−16 LUFS / −1 dBTP** as a pragmatic short-form master (mixed speech+music). ⚠️ **There is no single cross-platform LUFS standard:** YouTube documents −14 (attenuate-only), Spotify −14 (bidirectional), Apple Music ~−16 (third-party only); **TikTok and Instagram Reels publish NO official number** — do not present any TikTok/IG LUFS as fact. Full documented-vs-estimated table: `references/quality.md §Loudness Normalization`.

[Source: https://ffmpeg.org/pipermail/ffmpeg-user/2018-August/040933.html (sidechain values) + deep-research report §(a) LOUDNESS (per-platform targets), retrieved 2026-06-14]

---

## Voiceover Recording Guidelines

### Technical Requirements
- **Sample rate**: 48kHz (video standard) or 44.1kHz (web standard)
- **Bit depth**: 24-bit during recording (reduces to 16-bit on export)
- **Format during recording**: WAV (lossless — convert to AAC only at final export)
- **Noise floor**: below -60 dBFS (record in a quiet room, use noise gate)

### Speaking Pace for Video
- **Standard pace**: 130-150 words per minute (approx 2.2 words/second)
- **Explanation / technical content**: 110-130 WPM (slower = more comprehension)
- **Social media / energetic**: 150-170 WPM (faster = higher engagement for short content)

**Timing cross-check**: Record voiceover first, then build scene durations to match. Do not write scene durations then try to fit the voiceover into them — this produces rushed or padded delivery.

### AI TTS & Voice Generation
For comprehensive TTS, voice cloning, and AI sound effects rules, see
**`references/ai-asset-generation.md` §TTS Voiceover Rules**.
This section covers tool comparison (ElevenLabs / Fish Audio / OpenAI), API integration,
emotion control, voice cloning workflows, SFX generation, and cost control.
