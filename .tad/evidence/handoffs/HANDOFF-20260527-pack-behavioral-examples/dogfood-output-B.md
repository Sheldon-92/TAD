# Dogfood Output B: 30-Second Product Demo with Voiceover + Captions

> **User Task**: "I have a 30-second product demo footage and need to add voiceover narration and subtitles."
> **Pack Version**: video-creation 0.1.0
> **Date**: 2026-05-27

---

## Rule Application Trace

### 1. Intent Router Rule (Pattern 2, vimax-patterns.md)

**Classification**: `narrative`

**Reasoning**: The user has existing product demo footage with voiceover narration. This is character/speaker-driven content with story progression (explaining a product). The voiceover narration drives the pacing, placing it firmly in the `narrative` intent category.

| Intent | Match? | Why |
|--------|--------|-----|
| `narrative` | YES | Voiceover narration drives content; pacing follows speech rhythm; story progression (product explanation) |
| `motion` | No | Not action/kinetic energy focused; no beat-synced fast cuts |
| `montage` | No | Not emotional mood/atmosphere; not photo collage; not music-driven |

**Downstream routing**: `narrative` intent maps to Product Demo video type per storytelling.md, which provides the 12-Scene Rhythm Template and 30s timing structure.

---

### 2. Voice-First Timing Rule (ai-asset-generation.md, SKILL.md Quick Rule Index)

**Applies**: YES — this is the most critical rule for this task.

> "Generate TTS voiceover BEFORE composing video scenes — voiceover duration drives scene timing"

**Application**: The user already has 30 seconds of footage, but needs to add voiceover. The Voice-First Timing Rule dictates the production order:

1. **Write the voiceover script first** — word count determines pacing
2. **Generate or record TTS voiceover** — actual audio duration becomes the master clock
3. **Segment the 30s footage into scenes** aligned to voiceover segments
4. **Add captions** synced to the voiceover timing
5. **Mix audio** (voiceover + background music if any)

**Cross-reference with audio-design.md §Voiceover Recording Guidelines**:
> "Record voiceover first, then build scene durations to match. Do not write scene durations then try to fit the voiceover into them — this produces rushed or padded delivery."

Since the footage already exists (30s fixed length), the voiceover script MUST be timed to fit within 30s. At standard speaking pace (130-150 WPM per audio-design.md), this means:

- **30s at 130 WPM** = ~65 words maximum
- **30s at 150 WPM** = ~75 words maximum
- **Recommended**: Target 65-70 words to leave breathing room for pauses between scenes

---

### 3. Volume Mix Rules (audio-design.md §Volume Rules)

**Concrete parameters for voiceover-primary video**:

| Track | Volume Level | dBFS Target |
|-------|-------------|-------------|
| Voiceover | 100% (reference level) | -12 to -6 dBFS peak |
| Background music | 10-20% of voiceover level | -20 to -25 dBFS |
| Sound effects (if any) | 60-80% | -10 to -14 dBFS |

**No Vocals Rule applies**: Since this video has voiceover narration, background music MUST:
- Have no vocal leads (no singing)
- Have no voice-like lead instruments (trumpet, piano lead melody, lead guitar)
- Reason: vocal-range instruments compete with the spoken word frequency (300-3000 Hz)

**BPM selection** (audio-design.md §BPM-to-Video-Type Mapping):
- Product Demo = 130-200 BPM
- However, with voiceover narration, prefer the lower end (130-140 BPM) to avoid music fighting the speech rhythm
- Instrumentation: upbeat electronic, driving synth basslines, punchy percussion — but kept at 10-20% volume, so it serves as energy bed, not competing element

**Audio ducking** (recommended): Use FFmpeg sidechaincompress to auto-lower music when voiceover is active:
```bash
ffmpeg -i voiceover_clean.wav -i music.mp3 \
  -filter_complex "
    [1:a]volume=0.15[music_quiet];
    [0:a][music_quiet]sidechaincompress=threshold=0.02:ratio=4:attack=10:release=300[mixed];
    [mixed]loudnorm=I=-14:TP=-1.5:LRA=11[out]
  " \
  -map "[out]" final_audio.m4a
```
Note: `attack=10:release=300` = 10ms attack, 300ms release (milliseconds, not seconds).

---

### 4. ViMax Patterns: Applicability Analysis

#### Pattern 1: Visual Decomposition Rule — DOES NOT APPLY

**Reason**: Visual Decomposition is for AI image-to-video generation (Seedance, Kling, etc.) where the agent must decompose a shot into first_frame + last_frame + motion before calling the API. The user already HAS existing product demo footage — no AI video generation is involved. The footage is pre-recorded, not AI-generated.

> vimax-patterns.md scope boundary: "These patterns apply ONLY when using AI video generation (Seedance image-to-video, text-to-video). Pure GSAP/Remotion/HyperFrames 2D motion graphics do NOT need these — visual elements are programmatically defined."

Pre-recorded footage is even further outside scope than programmatic motion graphics.

#### Pattern 2: Intent Router Rule — APPLIED (see Section 1 above)

This is the one ViMax pattern that applies universally to every video task, regardless of whether AI generation is used. The classification step happens before any tool or footage decision.

#### Pattern 3: View-Specific Reference Rule — DOES NOT APPLY

**Reason**: View-Specific Reference is for generating character sheets (front/side/back views) to feed as reference images to AI video generation APIs. Two conditions must be met:
1. Character or object appears in >=2 shots (may or may not be true in the footage)
2. Using AI image-to-video generation for those shots

Even if the footage contains a character in multiple shots at different angles, the footage is ALREADY RECORDED. There is no AI generation step where we would feed angle-matched reference images. The visual content is fixed.

#### Pattern 4: Camera Tree Rule — DOES NOT APPLY

**Reason**: Camera Tree is for ensuring spatial continuity when generating multiple AI video shots in the same scene — child shot prompts must cite parent shot's spatial elements. The trigger requires:
- >=2 consecutive shots in the same physical space
- Using AI video generation for those shots

The user's footage is pre-recorded. Spatial continuity is already baked into the footage by the camera operator. There is no AI prompt where we would need to inject parent-shot spatial context.

**Summary of ViMax pattern applicability**:

| Pattern | Applies? | Reason |
|---------|----------|--------|
| 1: Visual Decomposition | NO | Pre-recorded footage, no AI video generation |
| 2: Intent Router | YES | Universal — classifies every video task |
| 3: View-Specific Reference | NO | Pre-recorded footage, no AI reference image feeding |
| 4: Camera Tree | NO | Pre-recorded footage, spatial continuity already captured |

---

### 5. Caption / Subtitle Guidance

**From quality.md §Accessibility (WCAG)**:

#### Caption Type Selection

For a product demo, the platform determines caption format:

| Distribution Channel | Caption Format | Rationale |
|---------------------|---------------|-----------|
| Website / web embed | Soft captions (WebVTT .vtt) | User can toggle on/off, CSS-styleable |
| YouTube | Soft captions (SRT upload) | YouTube allows user toggle + auto-translate |
| TikTok / Instagram Reels | Burn-in captions | Most viewers watch without sound |
| LinkedIn | Burn-in captions | Most LinkedIn video is watched without sound |

#### Caption Content Requirements (WCAG Accessibility)

Captions must include:
- All spoken words (>=99% accuracy — human review required after auto-generation)
- `[Speaker Name:]` — identify speaker if multiple speakers or off-screen voice
- `[sound effect]` — describe significant sound effects (e.g., `[click sound]`, `[notification chime]`)
- `[music: mood]` — describe music when relevant (e.g., `[upbeat electronic music]`)

#### Caption Styling

- Text contrast: minimum 4.5:1 ratio against video background
- If direct contrast is insufficient: use semi-transparent background panel behind caption text
- Test contrast at 3 representative frames: lightest, darkest, and mid-tone backgrounds
- Caption safe zone: avoid bottom 15% on social platforms (platform UI overlap)

#### Caption Timing (synced to voiceover)

- Karaoke-style highlighting (current word contrast-color or bold) for social media
- Max 3-4 words on screen at once for karaoke style
- Caption groups must clear completely between scenes — use **Caption Leak Prevention** pattern:

```javascript
// After every caption group exits, hard kill the caption element
tl.to(".caption", { opacity: 0, duration: 0.1 }, "scene-exit")
tl.set(".caption", { innerHTML: "" }, "scene-exit+=0.1")  // hard kill
```

Reason: TTS timing can have trailing silence that leaves the last caption visible into the next scene.

#### Auto-Caption Generation

If using Whisper for auto-captioning:
- English audio: Use `whisper-1` or `large-v2`
- Non-English audio: Do NOT use `.en` suffix models
- Auto-generated accuracy: typically 85-95% — MUST be human-reviewed to reach >=99% threshold
- Review focus: proper nouns, technical terms, numbers, abbreviations

---

## Production Plan

### Phase 1: Script & Voice (Voice-First)

| Step | Action | Output |
|------|--------|--------|
| 1.1 | Write voiceover script | 65-70 words, matching product demo narrative arc |
| 1.2 | Script structure follows Product Demo arc | Problem (hook) -> Features -> Social proof -> CTA |
| 1.3 | Generate TTS or record voiceover | WAV file, 48kHz, 24-bit |
| 1.4 | Clean voiceover audio | Noise reduction, normalize to -12 to -6 dBFS peak |
| 1.5 | Measure actual voiceover duration | Must fit within 30s with pauses |

### Phase 2: Scene Segmentation

| Step | Action | Rule Applied |
|------|--------|-------------|
| 2.1 | Segment voiceover into logical chunks per scene | Text-Shot Duration Formula (storytelling.md) |
| 2.2 | Map voiceover segments to footage cuts | Voice-First: audio drives scene timing |
| 2.3 | Verify 3-5s attention rule | Every 3-5s must have meaningful visual change |
| 2.4 | Verify 50% Reading Rule for text overlays | Last text element visible by 50% of scene duration |
| 2.5 | Apply 95% Hard Cut Rule | 2-3 shader transitions max for a 30s demo |

**Estimated scene breakdown** (30s product demo, ~8-10 scenes):

```
Scene 1:  3.0s  — Hook / Problem statement (voiceover segment 1)
Scene 2:  3.5s  — Solution intro (voiceover segment 2)
Scene 3:  4.0s  — Feature 1 (voiceover segment 3)
Scene 4:  3.5s  — Feature 2 (voiceover segment 4)
Scene 5:  4.0s  — Feature 3 — longest, most important (voiceover segment 5)
Scene 6:  3.5s  — Social proof / stat (voiceover segment 6)
Scene 7:  3.0s  — Benefit summary (voiceover segment 7)
Scene 8:  3.0s  — CTA + logo (voiceover segment 8)
Scene 9:  2.5s  — Final frame / end card
Total: ~30s
```

Shader transition placement: after Scene 1 (entering solution), after Scene 5 (midpoint energy), before Scene 8 (CTA push).

### Phase 3: Caption Production

| Step | Action | Details |
|------|--------|---------|
| 3.1 | Auto-generate captions from voiceover | Whisper large-v2 (or whisper-1 for English) |
| 3.2 | Human review captions | Target >=99% accuracy; focus on proper nouns, technical terms |
| 3.3 | Add non-speech elements | `[music: upbeat electronic]`, `[click sound]` as needed |
| 3.4 | Export caption format | WebVTT for web, SRT for YouTube, burn-in for social |
| 3.5 | Style captions | 4.5:1 contrast, semi-transparent background if needed |
| 3.6 | Verify caption safe zone | Bottom 15% clear on social platforms |

### Phase 4: Audio Mixing

| Step | Action | Parameter |
|------|--------|-----------|
| 4.1 | Select background music | 130-140 BPM, no vocals, no voice-like leads |
| 4.2 | Set music volume | 10-20% of voiceover (volume=0.15 in FFmpeg) |
| 4.3 | Apply sidechain compression | attack=10ms, release=300ms, threshold=0.02 |
| 4.4 | Add SFX if needed | Whoosh pre-lead 10-20ms before transitions |
| 4.5 | Normalize final mix | -14 LUFS integrated, -1.5 dBTP true peak |

**FFmpeg master chain**:
```bash
# Step 1: Clean voiceover
ffmpeg -i raw_voiceover.wav \
  -filter:a "highpass=f=80,dynaudnorm=p=0.9:m=100:g=15" \
  voiceover_clean.wav

# Step 2: Mix with music + sidechain + normalize
ffmpeg -i voiceover_clean.wav -i music.mp3 \
  -filter_complex "
    [1:a]volume=0.15[music_quiet];
    [0:a][music_quiet]sidechaincompress=threshold=0.02:ratio=4:attack=10:release=300[mixed];
    [mixed]loudnorm=I=-14:TP=-1.5:LRA=11[out]
  " \
  -map "[out]" final_audio.m4a
```

### Phase 5: Final Composition & Export

| Step | Action | Parameter |
|------|--------|-----------|
| 5.1 | Merge footage + audio + captions | FFmpeg or editing tool |
| 5.2 | Add `-movflags +faststart` for web | Mandatory for web delivery |
| 5.3 | Export at CRF 20-23 | 20 for premium, 23 for web standard |
| 5.4 | Resolution: 1920x1080 (16:9) | Product demo standard |
| 5.5 | Audio: AAC 128kbps+ stereo | Platform universal |
| 5.6 | Normalize to -14 LUFS | Streaming standard |

```bash
# Final export with captions burned in (social version)
ffmpeg -i footage.mp4 -i final_audio.m4a \
  -vf "subtitles=captions.srt:force_style='FontSize=22,PrimaryColour=&H00FFFFFF,OutlineColour=&H00000000,Outline=2,BackColour=&H80000000'" \
  -c:v libx264 -crf 22 -preset fast -movflags +faststart \
  -c:a aac -b:a 128k \
  -map 0:v -map 1:a \
  output_social.mp4

# Web version with soft captions
ffmpeg -i footage.mp4 -i final_audio.m4a \
  -c:v libx264 -crf 20 -preset fast -movflags +faststart \
  -c:a aac -b:a 128k \
  -map 0:v -map 1:a \
  output_web.mp4
# Deliver captions.vtt separately for web player
```

---

## Quality Targets

| Attribute | Value |
|-----------|-------|
| Platform | Web / YouTube (16:9 product demo) |
| Resolution | 1920x1080 |
| Codec | H.264 (MP4) |
| CRF | 20-22 |
| Audio | AAC 128kbps stereo |
| Loudness | -14 LUFS integrated |
| Captions | WebVTT (web) / burn-in (social) / SRT (YouTube) |
| Caption accuracy | >=99% (human-reviewed) |
| Text contrast | >=4.5:1 (WCAG AA) |

---

## Failure Mode Pre-Check

Not directly applicable (pre-recorded footage, not HyperFrames/Remotion composition), but verify:

- [ ] No audio clipping (peaks below -1 dBTP)
- [ ] No caption leak between scenes (hard kill pattern applied)
- [ ] Voiceover fits within 30s footage duration
- [ ] Background music has no vocals or voice-like leads
- [ ] Caption contrast verified at 3 luminance levels
- [ ] `-movflags +faststart` included in export
- [ ] SFX pre-lead timing: 10-20ms before visual transitions (if SFX used)
- [ ] Final mix normalized to -14 LUFS

---

## Rules Applied (Audit Trail)

| Rule | Source | Applied? |
|------|--------|----------|
| Intent Router Rule | vimax-patterns.md §Pattern 2 | YES — classified as `narrative` |
| Voice-First Timing Rule | SKILL.md Quick Rule Index, ai-asset-generation.md | YES — voiceover before composition |
| Volume Mix Rule | audio-design.md §Volume Rules | YES — VO=100%, music=10-20% |
| No Vocals Rule | audio-design.md §BPM-to-Video-Type Mapping | YES — no vocals in background music |
| BPM-to-Video-Type | audio-design.md §BPM-to-Video-Type Mapping | YES — 130-140 BPM for product demo |
| SFX Pre-Lead | audio-design.md §SFX Timing Rules | YES — 10-20ms before visual transitions |
| Caption Leak Prevention | audio-design.md §Caption Leak Prevention | YES — hard kill after caption groups |
| Caption Accuracy >=99% | quality.md §Accessibility (WCAG) | YES — human review required |
| Text Contrast 4.5:1 | quality.md §Accessibility (WCAG) | YES — test at 3 luminance levels |
| 3-5s Attention Rule | storytelling.md §Pacing Rules | YES — visual change every 3-5s |
| Text-Shot Duration Formula | storytelling.md §Pacing Rules | YES — word count drives scene duration |
| 50% Reading Rule | storytelling.md §Pacing Rules | YES — last element by 50% of scene |
| 95% Hard Cut Rule | storytelling.md §Pacing Rules | YES — max 2-3 shader transitions |
| Product Demo Template | storytelling.md §Video Type Pacing Patterns | YES — 8-10 scenes, narrative arc |
| Audio Ducking (sidechain) | audio-design.md §Volume Rules | YES — sidechaincompress applied |
| Visual Decomposition | vimax-patterns.md §Pattern 1 | NO — pre-recorded footage, no AI generation |
| View-Specific Reference | vimax-patterns.md §Pattern 3 | NO — pre-recorded footage, no AI reference images |
| Camera Tree | vimax-patterns.md §Pattern 4 | NO — pre-recorded footage, spatial continuity already captured |
