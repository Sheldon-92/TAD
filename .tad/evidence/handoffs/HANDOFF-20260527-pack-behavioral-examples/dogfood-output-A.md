# Production Plan: 3-Photo Portrait Beat-Sync Video (6s)

> Pack rules applied: Intent Router (Pattern 2), Visual Decomposition (Pattern 1), View-Specific Reference (Pattern 3), Camera Tree (Pattern 4), BPM-to-Video-Type, Volume Rules, SFX Timing Rules.
> Input: 3 portrait photos (different expressions/poses), lofi background music, 6 seconds total.

---

## 1. Intent Router Rule (Pattern 2) -- FIRST

**Classification: `montage`**

Rationale: Multiple photos + beat sync + emotional mood (lofi music) = montage intent per Pattern 2 table:

| Intent | Characteristics | Match? |
|--------|----------------|--------|
| `narrative` | Character dialogue, story progression | No -- no dialogue, no story arc |
| `motion` | Action, kinetic energy, sports, demos | No -- portraits, not action content |
| **`montage`** | **Emotional mood, atmosphere, photo collage** | **Yes -- photo collage + lofi = emotional mood** |

Montage intent parameters:
- Shot duration: 3-5s gradual builds (we use 2s per photo to fit 6s total = 3 shots)
- Cut rhythm: Music-driven, BPM-aligned
- Most likely Video Type: Emotional/Storytelling
- Pacing source: `audio-design.md` BPM mapping, not Product Demo template

**Anti-Pattern avoided**: Did NOT default to Product Demo template (130-200 BPM, 1-2s fast cuts). That would produce frantic pacing incompatible with lofi aesthetic.

---

## 2. Visual Decomposition Rule (Pattern 1) -- Per Photo

Each photo = `first_frame`. Generate `last_frame` via gpt-image-2. Define `motion` explicitly.

### Shot 1 (0.0s - 2.0s): Photo A

| Part | Description |
|------|-------------|
| `first_frame` | Original photo A (expression 1, pose 1). Feed directly as start image. |
| `last_frame` | Subtle expression shift -- e.g., "same framing, eyes soften slightly, ambient light warms 5%". Generate via gpt-image-2 with original photo as reference. |
| `motion` | Slow zoom in 8-10%, centered on eyes. Steady pace, no acceleration. |

### Shot 2 (2.0s - 4.0s): Photo B

| Part | Description |
|------|-------------|
| `first_frame` | Original photo B (expression 2, pose 2). Feed directly as start image. |
| `last_frame` | Gentle head tilt -- e.g., "same composition, head tilts 5 degrees right, slight smile begins". Generate via gpt-image-2. |
| `motion` | Slow pan left-to-right, 5% horizontal travel. Linear pace. |

### Shot 3 (4.0s - 6.0s): Photo C

| Part | Description |
|------|-------------|
| `first_frame` | Original photo C (expression 3, pose 3). Feed directly as start image. |
| `last_frame` | Gaze shift upward -- e.g., "same pose, eyes look up 10 degrees, natural light brightens 3%". Generate via gpt-image-2. |
| `motion` | Gentle dolly back (zoom out 6-8%), creating a breathing-out feeling to close the video. |

**Anti-Pattern avoided**: Did NOT feed photos to Seedance with "make it move" -- that allows AI to decide motion direction freely, causing uncontrolled drift. Every shot has explicit `first_frame` + `last_frame` + `motion`.

**Trigger check**: All 3 shots are image-to-video calls with duration = 2s (>= 2s threshold). Pattern 1 applies to all shots.

---

## 3. View-Specific Reference Rule (Pattern 3) -- Check

**Assessment: Need user clarification.**

Two scenarios:

### Scenario A: 3 photos are of the SAME person (different expressions/poses)

Pattern 3 IS triggered: same character in >= 2 shots.

**Action required**:
1. Examine the 3 photos for camera angle differences (front/side/back)
2. If angles differ: Generate a character sheet via gpt-image-2:
   ```
   "Character reference sheet: [person description from photos]. Three views on white background:
   left panel = front view, center panel = side view (3/4 angle), right panel = back view.
   Consistent lighting, proportions, and clothing across all three views."
   ```
3. For each shot's Seedance call, select the view that matches the camera angle:

   | Camera Angle in Shot | Reference View to Feed |
   |---------------------|----------------------|
   | Facing camera | Front view |
   | Profile / 3/4 angle | Side view |
   | Away from camera | Back view |

4. Feed the angle-matched view as reference image (not always the front view).

### Scenario B: 3 photos are of DIFFERENT people

Pattern 3 is NOT triggered: no repeated character across shots.
No character sheet needed. Each photo serves as its own standalone reference.

**Recommendation**: Ask user to confirm whether the 3 photos are of the same person or different people. This determines whether view-specific reference generation is required.

**Fallback (per ViMax `BestImageSelector` pattern)**: If character sheet generation fails or only produces 1 view, use the available view for all shots -- degrade gracefully.

---

## 4. Camera Tree Rule (Pattern 4) -- Check

**Assessment: NOT triggered.**

Trigger condition: >= 2 consecutive shots in the **same physical space** (same scene, same time).

Analysis:
- 3 portrait photos with different expressions/poses -- these are likely taken at different times/locations
- Even if taken at the same location, a montage intent treats each photo as an independent emotional beat, not a continuous scene
- No establishing (wide) shot exists to serve as a parent shot

If user clarifies that all 3 photos are from the same location AND wants spatial continuity:

**Would require**:
1. Identify the widest framing as parent shot
2. All tighter shots = children, each child prompt MUST cite parent shot's spatial elements:
   - Object positions (prevents prop teleportation between cuts)
   - Lighting direction (prevents shadow direction flip)
   - Color temperature (prevents warm-to-cool shifts)
   - Background details (prevents wall art / texture changes)

**Current verdict**: Pattern 4 not applicable for this montage of independent portrait photos.

---

## 5. Audio Design -- BPM Guidance

### BPM Selection

Per `audio-design.md` BPM-to-Video-Type Mapping:

| Video Type | BPM Range | Match? |
|-----------|-----------|--------|
| Product Demo | 130-200 | No -- too energetic for lofi |
| Social Media Short | 110-130 | No -- too upbeat |
| Tutorial / Explainer | No strict BPM | No -- wrong category |
| Corporate / Professional | 100-130 | No -- wrong mood |
| **Emotional / Storytelling** | **20-80 BPM** | **Yes -- montage intent maps here** |

**Target BPM: 70-80 BPM** (upper range of Emotional/Storytelling, appropriate for lofi hip-hop which typically sits at 70-90 BPM; capping at 80 to stay within pack range).

**Instrumentation**: Ambient to sustained synths, cinematic pads -- aligns with lofi aesthetic (mellow keys, vinyl crackle, soft drums).

### Beat-Sync Calculation

Per `vimax-patterns.md` Integration Scene, BPM-to-cut formula:

```
cut_interval = 60 / BPM
```

At 75 BPM:
- `cut_interval = 60 / 75 = 0.8s` per beat
- 2.0s per photo / 0.8s per beat = 2.5 beats per photo
- Cuts on every 2-3 beats = 2.0s per photo (fits 6s / 3 photos exactly)
- Cut points: 2.0s, 4.0s (hard cuts between photos)

### SFX Timing

Per `audio-design.md` SFX Pre-Lead Rule:

| Cut Point | SFX Start | SFX Type | Note |
|-----------|-----------|----------|------|
| 2.000s | 1.980s | Soft whoosh | Pre-Lead 20ms before visual cut |
| 4.000s | 3.980s | Soft whoosh | Pre-Lead 20ms before visual cut |

SFX type = whoosh per Visual Event to SFX Type Mapping (slide/screen transition = whoosh).

### Volume Mix

Per `audio-design.md` Volume Rules:

| Track | Level |
|-------|-------|
| Background music (lofi) | 100% (no voiceover, music is primary) |
| Sound effects (whoosh) | 60-80% of music level |
| Voiceover | N/A -- no voiceover in this video |

Note: Since there is no voiceover, the "No Vocals Rule" does not apply -- vocals in the lofi track are acceptable. However, lofi typically uses instrumental anyway.

### Audio Export

- Format: AAC
- Bitrate: 128kbps+
- Channels: Stereo
- Normalize to: -14 LUFS integrated, -1 dBTP true peak

---

## 6. Video Production Findings (Pack Output Format)

### Pacing Plan

- Scene count: 3
- Average shot duration: 2.0s (6s total / 3 shots)
- Shader transitions: 0 (all hard cuts per 95% Hard Cut Rule -- 3 scenes is below the 6-8 scene threshold where 2-3 shader transitions are allowed)
- Intent: `montage`

| Scene | Duration | Content | Transition In |
|-------|----------|---------|---------------|
| 1 | 0.0s - 2.0s | Photo A: slow zoom in, subtle expression shift | Hard start |
| 2 | 2.0s - 4.0s | Photo B: slow pan L-to-R, gentle head tilt | Hard cut (whoosh at 1.98s) |
| 3 | 4.0s - 6.0s | Photo C: dolly back, gaze shift upward | Hard cut (whoosh at 3.98s) |

### Motion Design

- Easing selection: montage mood = contemplative/gentle
  - Shot 1 (zoom in): `power1.out` (soft, steady build)
  - Shot 2 (pan): `sine.inOut` (smooth lateral movement)
  - Shot 3 (dolly back): `power2.out` (graceful retreat, slight deceleration)
- Note: These GSAP curves apply to the HyperFrames/Remotion composition layer (text overlays, frame positioning). The Seedance AI-generated motion within each clip is controlled by the `motion` field in the Visual Decomposition (Pattern 1), not GSAP.
- Entrance offsets: 0.15s (per Entrance Offset Rule: never start at 0.0s)
- Transition duration: N/A (hard cuts, no shader transitions)

### Audio

- Music BPM target: 70-80 (Emotional/Storytelling range, lofi aesthetic)
- Mix: voiceover=N/A, music=100% (primary), SFX=60-80%
- SFX: soft whoosh at 1.98s and 3.98s (Pre-Lead 20ms)
- Normalize: -14 LUFS, AAC 128kbps+ stereo

### Tool

- Selected: **HyperFrames** (default per HyperFrames-first Rule)
- Rationale: HTML-native, no build step, AI-friendly. No React state/components needed for photo montage. Seedance for AI video clips, HyperFrames for composition/sequencing, FFmpeg for final audio mixing.

### Quality Targets

- Platform: TBD (ask user -- TikTok/Instagram Reels/YouTube Shorts affects aspect ratio)
- Resolution: 1080x1920 (9:16 vertical, standard for portrait content and short-form platforms)
- Format: H.264 codec, AAC audio
- CRF: 18-20 (high quality for short content)
- Captions: Not required (no voiceover/dialogue)

### Failure Mode Pre-Check

- [x] No Date.now/Math.random/setInterval (deterministic timeline)
- [x] No repeat:-1 (finite 6s duration)
- [x] No async/await in timeline (Seedance calls are pre-generation, not in timeline)
- [x] autoAlpha not visibility (if opacity animations used)
- [x] No inline opacity:0 (elements start visible)

---

## 7. Open Questions for User

1. **Same person or different people?** Determines if View-Specific Reference Rule (Pattern 3) is triggered.
2. **Same location or different locations?** Determines if Camera Tree Rule (Pattern 4) is triggered.
3. **Target platform?** (TikTok / Instagram Reels / YouTube Shorts / other) Determines aspect ratio and export settings.
4. **Specific lofi track provided?** If yes, extract exact BPM for precise beat-sync. If no, source a royalty-free lofi track at ~75 BPM.
5. **Text overlays needed?** (title, captions, watermark) Affects Text-Shot Duration Formula applicability.

---

## Rules Applied Summary

| Rule | Source | Applied? | Verdict |
|------|--------|----------|---------|
| Intent Router Rule | `vimax-patterns.md` Pattern 2 | Yes | `montage` |
| Visual Decomposition Rule | `vimax-patterns.md` Pattern 1 | Yes | 3 shots decomposed (first_frame / last_frame / motion) |
| View-Specific Reference Rule | `vimax-patterns.md` Pattern 3 | Conditional | Triggered if same person; needs user input |
| Camera Tree Rule | `vimax-patterns.md` Pattern 4 | No | Different locations assumed; no parent shot needed |
| BPM-to-Video-Type Mapping | `audio-design.md` | Yes | 70-80 BPM (Emotional/Storytelling) |
| BPM-to-Cut Formula | `vimax-patterns.md` Integration Scene | Yes | 60/75 = 0.8s per beat, cut every 2-3 beats |
| SFX Pre-Lead Rule | `audio-design.md` | Yes | Whoosh 20ms before cuts at 2.0s and 4.0s |
| Volume Rules | `audio-design.md` | Yes | Music=100% (no VO), SFX=60-80% |
| 95% Hard Cut Rule | `storytelling.md` (via SKILL.md index) | Yes | 0 shader transitions for 3-scene video |
| HyperFrames-first Rule | `tool-selection.md` (via SKILL.md index) | Yes | Default tool selection |
| 3-Ease Minimum | `visual-design.md` (via SKILL.md index) | Yes | 3 different GSAP curves assigned |
| Entrance Offset Rule | `visual-design.md` (via SKILL.md index) | Yes | 0.15s offset |
