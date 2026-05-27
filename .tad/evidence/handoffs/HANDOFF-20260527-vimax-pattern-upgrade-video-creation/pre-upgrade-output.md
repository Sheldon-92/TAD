# Pre-Upgrade Baseline: Photo-to-Beat-Sync Task

## Task
"我有 3 张人像照片（不同表情/姿势），想做一个 6 秒的卡点动态视频。背景配 lofi 音乐。"

## AI Agent Response (using current pack rules)

---

### 1. Video Type Classification

**Classification: Social Media Short (9:16)**

Rationale: A 6-second beat-sync video with portrait photos maps closest to the **Social Media Short** pattern from `storytelling.md` §Video Type Pacing Patterns. The template specifies 9:16 aspect ratio, 5-7 scenes, and 10-15s duration. However, this task is **shorter than the template minimum** (6s vs 10-15s), which is the first gap identified.

The Social Short narrative arc (`storytelling.md` §Social Short Narrative Arc) prescribes:
- Hook (0-3s): Visual or text hook
- Value (3-10s): Core insight
- CTA (10-15s): Single clear action

For a 6s personal photo video, this narrative arc does not apply well — there is no "insight" or "CTA." This is a **personal expression / aesthetic showcase** video type, which the pack does not have a dedicated template for.

**GAP IDENTIFIED**: The pack's Video Type Pacing Patterns (`storytelling.md` §Video Type Pacing Patterns) cover Product Demo, Social Media Short, and Tutorial/Explainer. There is no pattern for **personal/aesthetic/montage** videos, **beat-sync (卡点)** videos, or videos shorter than 10 seconds. The agent must improvise from general pacing rules.

---

### 2. Pacing Plan

**Applying general pacing rules from `storytelling.md`:**

- **3-5 Second Attention Rule** (`storytelling.md` §Pacing Rules): Every 3-5 seconds, a visually meaningful change must occur. For a 6s video, this means at minimum 1-2 visual changes, which aligns with 3 photos across 6 seconds.
- **Text-Driven Shot Duration Formula** (`storytelling.md` §Text-Driven Shot Duration Formula): No text in this video → "No text (hero image/graphic) = 1.5-2s" per shot. With 3 photos at 2s each = 6s total. This fits perfectly.
- **5-Second Scene Ceiling** (`storytelling.md` §Pacing Rules): Each 2s shot is well under the 5s ceiling.
- **95% Hard Cut Rule** (`storytelling.md` §Pacing Rules): For a 3-scene video, the rule allows 0 shader transitions (2-3 max per 6-8 scene video). However, for a beat-sync video, the user likely wants snappy hard cuts anyway.

**Scene Breakdown:**

| Scene | Duration | Content | Transition In |
|-------|----------|---------|---------------|
| Scene 1 | 2.0s | Photo 1 (e.g., neutral/calm expression) | Fade from black (0.3s) |
| Scene 2 | 2.0s | Photo 2 (e.g., smile/warm expression) | Hard cut on beat |
| Scene 3 | 2.0s | Photo 3 (e.g., dynamic/action pose) | Hard cut on beat |

- **Shader transitions used: 0** (all hard cuts except opening fade)
- The opening fade-from-black counts as the single allowed non-hard-cut transition for this ultra-short format.

**50% Reading Rule** (`storytelling.md` §Pacing Rules): No text to read, so this rule does not apply. However, the spirit of the rule suggests that any entrance animation on the photo should complete within the first 1.0s of each 2.0s scene (50% mark), giving the viewer 1.0s to absorb the image.

**GAP IDENTIFIED**: The pack has no **beat-sync / 卡点** timing methodology. "Beat-sync" means cuts are timed to musical beats, not to content duration. The pack's timing rules are all content-driven (word count, reading time). For beat-sync, the music BPM should DRIVE the cut timing, but the pack treats music as a background layer that follows the video, not the other way around.

---

### 3. Shot-by-Shot Breakdown with Motion Design

Applying motion rules that would normally come from `visual-design.md` (referenced in SKILL.md §Quick Rule Index but not loaded for this task since the user's signal was about photos/video/audio, not animation). The agent would load it based on the multi-signal rule. Key rules cited from SKILL.md §Quick Rule Index:

- **Entrance Offset**: Never start at 0.0s — offset 0.1-0.3s into scene
- **3-Ease Minimum**: At least 3 different easing curves per scene
- **No Exit Rule**: Never exit-animate except final scene

#### Scene 1 (0.0s - 2.0s): Photo 1
- **Entry (0.0s-0.5s)**: Photo fades in from black. Offset 0.1s per Entrance Offset rule.
  - Scale: 105% → 100% (subtle Ken Burns zoom-out for life)
  - Opacity: 0 → 1 over 0.3s
- **Mid (0.5s-2.0s)**: Slow Ken Burns zoom continues (100% → 98%). Per `storytelling.md` §Tutorial/Explainer: "Subtle Ken Burns zoom on background image (max 2-3% scale shift per 4s)" — for 2s, ~1.5% shift is appropriate.
- **Exit**: Hard cut (no exit animation per No Exit Rule)

#### Scene 2 (2.0s - 4.0s): Photo 2
- **Entry (2.0s-2.3s)**: Hard cut in. Photo enters at slight offset (0.1s). 
  - Scale: 95% → 100% (push-in, contrast to Scene 1's pull-out)
  - Position: slight lateral shift (10px left → center)
- **Mid (2.3s-4.0s)**: Ken Burns slow push continues (100% → 102%)
- **Exit**: Hard cut

#### Scene 3 (4.0s - 6.0s): Photo 3
- **Entry (4.0s-4.3s)**: Hard cut. Most dynamic entrance for the dynamic pose.
  - Scale: 110% → 100% (bigger zoom for energy climax)
  - Slight rotation: 2deg → 0deg
- **Mid (4.3s-5.7s)**: Hold with subtle drift
- **Exit (5.7s-6.0s)**: Fade to black over 0.3s (final scene exception to No Exit Rule)

**GAP IDENTIFIED**: The pack's visual-design rules (3-Ease Minimum, GSAP easing curves) are designed for multi-element motion graphics, not for photo-based videos. Applying "3 different easing curves per scene" to a single-photo Ken Burns effect is awkward — there are not 3 independent animated elements to apply 3 curves to.

---

### 4. AI Video Generation Prompts

**Tool Selection (Decision Tree from `ai-asset-generation.md` §Decision Tree):**

The user has 3 static photos and wants a dynamic video. Two approaches:

**Approach A: Seedance image-to-video** — Generate 3 separate AI video clips from the 3 photos, each ~2s. This adds AI-generated motion (hair blowing, expression shifting) to the static photos.

**Approach B: Composition tool (HyperFrames/FFmpeg)** — Use the photos as-is with programmatic Ken Burns / transition effects. No AI generation needed.

Per the Decision Tree: "Need a video clip? → Is 4K mandatory? NO → Is existing toolchain Runway-native? NO → Seedance 2.0 (default for agent workflows)."

However, the pack's Decision Tree assumes the user needs to GENERATE new visual assets. For this task, the user already HAS the photos. The decision between "AI-animate the photos" vs "programmatically compose them" is not covered by the pack's Decision Tree.

**Recommendation: Hybrid approach** — Use Seedance image-to-video for subtle animation of each photo (gives life to the portraits), then compose with HyperFrames/FFmpeg for precise beat-sync timing.

#### Seedance Prompts (if using Approach A)

Per `ai-asset-generation.md` §Seedance Endpoint Selection: User has images → **image-to-video** endpoint.

Per `ai-asset-generation.md` §Prompt Rules:
- Avoid the word "fast" (Motion Safety)
- Minimum 3-5 seconds per shot (Duration-to-Shot Allocation) — but we only need 2s clips. This is a conflict: the pack says minimum 3-5s per Seedance shot, but the video needs 2s clips.

**GAP IDENTIFIED**: Seedance minimum shot duration (3-5s) conflicts with beat-sync timing needs (2s per beat). The pack provides no guidance for generating clips shorter than 3s or trimming longer clips to beat markers.

**Workaround**: Generate 5s clips (minimum safe duration per pack rules), then trim to 2s in FFmpeg.

##### Clip 1 Prompt (Photo 1 — neutral expression):
```
Endpoint: image-to-video
Input image: photo1.jpg (portrait, neutral expression)
Prompt: "A portrait of a person with a calm neutral expression, subtle hair movement from a gentle breeze, soft ambient lighting, shallow depth of field, lofi aesthetic with warm color grading"
Duration: 5 (seconds — minimum per Seedance rules, trim to 2s post)
Resolution: 720p (Draft tier per §Cost Control — 480p for initial test, 720p for approval)
Aspect ratio: 9:16
```

##### Clip 2 Prompt (Photo 2 — smile):
```
Endpoint: image-to-video
Input image: photo2.jpg (portrait, smiling)
Prompt: "A portrait of a person breaking into a warm genuine smile, eyes lighting up with joy, soft natural lighting, shallow depth of field, lofi aesthetic with warm color grading"
Duration: 5
Resolution: 720p
Aspect ratio: 9:16
```

##### Clip 3 Prompt (Photo 3 — dynamic pose):
```
Endpoint: image-to-video
Input image: photo3.jpg (portrait, dynamic pose)
Prompt: "A portrait of a person in a confident dynamic pose, subtle body sway, hair movement, expressive energy, soft lighting, shallow depth of field, lofi aesthetic with warm color grading"
Duration: 5
Resolution: 720p
Aspect ratio: 9:16
```

**Consistency rules applied** (from `ai-asset-generation.md` §Visual Consistency Rules):
- **Color Palette Lock**: "lofi aesthetic with warm color grading" used verbatim in all 3 prompts
- **Lighting Continuity**: "soft lighting, shallow depth of field" used in all prompts
- **Character Consistency**: Since we are using real photos of the same person as input images, Seedance's image-to-video endpoint should maintain identity. No @character:<id> tag needed (that is for text-to-video character generation).

**Cost estimate** (from `ai-asset-generation.md` §Cost Table):
- 3 clips x 5s x $0.30/s (fal.ai Standard) = $4.50 total
- Draft tier (480p/Fast): 3 x 5s x $0.24/s = $3.60
- Per §Tiered Generation: Draft first at 480p → approval → Final at 720p

**Tiered Generation Plan** (from `ai-asset-generation.md` §Cost Control §Tiered Generation Strategy):
1. Draft: 480p / Fast → $3.60 → confirm style and motion look good
2. Final: 720p / Standard → $4.50 → production clips

#### FFmpeg Trim Commands (post-generation)

```bash
# Trim each 5s Seedance clip to the needed 2s segment
# Select the best 2s window from each clip
ffmpeg -i clip1_5s.mp4 -ss 0.5 -t 2.0 -c:v libx264 -c:a aac clip1_2s.mp4
ffmpeg -i clip2_5s.mp4 -ss 0.5 -t 2.0 -c:v libx264 -c:a aac clip2_2s.mp4
ffmpeg -i clip3_5s.mp4 -ss 0.5 -t 2.0 -c:v libx264 -c:a aac clip3_2s.mp4
```

#### FFmpeg Concatenation

```bash
# Create concat list
cat > concat-list.txt << 'EOF'
file 'clip1_2s.mp4'
file 'clip2_2s.mp4'
file 'clip3_2s.mp4'
EOF

# Concatenate with hard cuts (no transition filter)
ffmpeg -f concat -safe 0 -i concat-list.txt -c copy video_no_audio.mp4
```

---

### 5. Audio Selection

**Applying `audio-design.md` §BPM-to-Video-Type Mapping:**

The user requested "lofi 音乐" (lofi music). From the BPM table:

| Video Type | BPM Range | Instrumentation |
|-----------|-----------|-----------------|
| Emotional / Storytelling | 20-80 BPM | Ambient to full orchestra, sustained synths, cinematic pads |

Lofi hip-hop typically sits at **70-90 BPM** — the upper end of Emotional/Storytelling range. However, for a **beat-sync (卡点)** video, the BPM directly determines cut timing.

**BPM Calculation for Beat-Sync:**

For 3 cuts in 6 seconds (one cut every 2 seconds):
- 1 beat every 2s = 30 BPM (too slow — this would be ambient, not lofi)
- **Actually: lofi at 75-85 BPM = ~1.4 beats/second = beat every ~0.75s**
- With 3 photos at 2s each, the cuts happen every 4th beat at 80 BPM (4 x 0.75s = 3.0s) — that is too slow.
- **At 90 BPM**: beat interval = 0.667s. 3 beats = 2.0s. Cuts align with every 3rd beat.

**Recommended BPM: 90 BPM** — Each photo holds for exactly 3 beats (3 x 0.667s = 2.0s). Cuts on the downbeat of every 4th beat.

Alternatively, **at 80 BPM**: beat interval = 0.75s. 2.67 beats per 2s — does not align cleanly. Not recommended.

**Or at 75 BPM**: beat interval = 0.8s. 2.5 beats per 2s — cuts on the "and" of beat 2, which is syncopated but intentional in lofi.

**Final recommendation: 85-90 BPM lofi** for clean beat-sync alignment.

**GAP IDENTIFIED**: The pack's BPM mapping is organized by video type (Product Demo, Tutorial, etc.), not by music genre. "Lofi" is a genre the user requested, but the pack does not provide genre-to-BPM mappings. The agent must use general music knowledge. Additionally, the pack has no rules for **BPM-driven cut timing** — the beat-sync workflow inverts the pack's assumption that video timing drives audio selection.

**Instrumentation (per `audio-design.md` §BPM-to-Video-Type Mapping):**
- No vocals (per Critical Rule: "strictly avoid vocal leads" — even though there is no voiceover, lofi with vocal samples could distract from the photo focus)
- Appropriate: mellow Rhodes piano, vinyl crackle, soft drum machine (kick + hi-hat), ambient pads, tape hiss texture
- Avoid: lead guitar, trumpet, piano lead melody (voice-like instruments)

**Volume Mix (per `audio-design.md` §Volume Rules):**
- No voiceover in this video → background music can be louder than the typical 10-20% level
- Since music is the ONLY audio track: 100% (reference level)
- Normalize to **-14 LUFS** per `audio-design.md` §Platform Audio Requirements

**SFX consideration (per `audio-design.md` §SFX Timing Rules):**
- For beat-sync cuts: a subtle **whoosh** SFX starting 10-20ms before each hard cut (per §Pre-Lead Timing: "Start a whoosh/transition sound effect 10-20ms BEFORE the visual transition begins")
- SFX type: per §Visual Event to SFX Type Mapping: "Slide / screen transition → whoosh"
- Keep SFX subtle to not overpower the lofi aesthetic
- **Frequency separation** (§Frequency Separation): Whoosh in mid frequencies (500Hz-4kHz), lofi music occupies mostly low-mid, so minimal masking

**SFX generation (per `ai-asset-generation.md` §AI Sound Effects Rules):**
- Per §SFX Source Decision: "Specific/imaginative SFX → ElevenLabs SFX API" (a subtle transition whoosh is not tied to video scene motion, so ElevenLabs, not Seedance native audio)
- However, for a lofi aesthetic, the whoosh should be very subtle — or omitted entirely. Standard lofi beat-sync videos often rely on the beat itself as the "audio marker" for cuts.

```python
# Optional: Generate subtle whoosh for transitions
# Per ai-asset-generation.md §AI Sound Effects Rules
import httpx

response = httpx.post(
    "https://api.elevenlabs.io/v1/sound-generation",
    headers={"xi-api-key": os.getenv("ELEVENLABS_API_KEY")},
    json={
        "text": "A very soft subtle swoosh transition sound, gentle and warm, lofi aesthetic",
        "model_id": "eleven_text_to_sound_v2",
        "duration_seconds": 0.5,
        "prompt_influence": 0.3,
    },
)
with open("sfx/soft-whoosh.mp3", "wb") as f:
    f.write(response.content)
```

**Music source guidance (per `audio-design.md` §Music Licensing Guidance):**
- For social media posting: Use platform's built-in music library (TikTok/Instagram have licensed lofi tracks)
- For cross-platform use: Royalty-free from Epidemic Sound or Artlist
- For AI-generated: Suno or Soundraw can generate custom lofi at target BPM — but "check platform terms" per the pack

---

### 6. Tool Selection Rationale

**From SKILL.md §Quick Rule Index → Tool Selection:**
- **HyperFrames-first**: HTML-native, no build, AI-friendly — default choice
- **Remotion-when**: React components/state required
- **FFmpeg-direct**: Processing/encoding only, no composition

**Decision path:**
1. Do we need React components/state? NO — this is a simple photo sequence with Ken Burns.
2. Is this processing/encoding only? Partially — if using Seedance clips, FFmpeg concat is sufficient.
3. Default → **HyperFrames** for composition if adding overlays/text, or **FFmpeg-direct** if pure clip concatenation.

**Recommendation**: 
- **If using Seedance AI-animated clips**: FFmpeg-direct (concat + audio mix). No need for HyperFrames since there is no text overlay, no complex animation — just clip sequencing.
- **If using photos directly (no AI animation)**: HyperFrames for Ken Burns effects + transitions.

**FFmpeg Final Mix Command:**

```bash
# Mix video + lofi music + optional SFX whooshes
# Per audio-design.md §Volume Rules and §Audio Post-Production Workflow

# Step 1: Concatenate video clips (already done above)
# video_no_audio.mp4 exists

# Step 2: Add lofi music track, trimmed to 6s
ffmpeg -i video_no_audio.mp4 -i lofi_track.mp3 \
  -filter_complex "[1:a]atrim=0:6,volume=1.0,loudnorm=I=-14:TP=-1.5:LRA=11[music]" \
  -map 0:v -map "[music]" \
  -c:v copy -c:a aac -b:a 128k \
  final_output.mp4

# Step 3 (optional): Add whoosh SFX at cut points
# Whoosh at 1.98s (20ms pre-lead before 2.0s cut) and 3.98s (20ms pre-lead before 4.0s cut)
# Per audio-design.md §SFX Timing Rules §Pre-Lead Timing
ffmpeg -i final_output.mp4 -i sfx/soft-whoosh.mp3 \
  -filter_complex \
    "[1:a]adelay=1980|1980[w1]; \
     [1:a]adelay=3980|3980[w2]; \
     [0:a][w1][w2]amix=inputs=3:duration=first:weights=1 0.3 0.3[out]" \
  -map 0:v -map "[out]" \
  -c:v copy -c:a aac -b:a 128k \
  final_with_sfx.mp4
```

---

### 7. Export Quality Targets

Per SKILL.md §Quick Rule Index → Quality:
- **Platform**: Social media (TikTok / Instagram Reels / Douyin)
- **Resolution**: 1080x1920 (9:16)
- **Format**: H.264/AVC with AAC audio
- **CRF**: 18 (high quality end per §Export Settings CRF 18-23)
- **Audio**: AAC 128kbps+ stereo (per `audio-design.md` §Platform Audio Requirements)
- **Normalization**: -14 LUFS integrated (per `audio-design.md` §Platform Audio Requirements)
- **Captions**: Not required (no speech/voiceover content)

---

### 8. Failure Mode Pre-Check

Per SKILL.md §Quick Rule Index → Production (§Agent Failure Modes Checklist):

- [x] No Date.now/Math.random/setInterval — N/A (FFmpeg pipeline, no JS)
- [x] No repeat:-1 — N/A
- [x] No async/await in timeline — N/A
- [x] autoAlpha not visibility — N/A
- [x] No inline opacity:0 — N/A
- [x] Duration matches spec: 3 clips x 2.0s = 6.0s total

---

### 9. Summary of Identified Gaps

The following areas are where the current pack does NOT provide specific guidance for this task type:

| Gap | Description | What the agent had to improvise |
|-----|-------------|-------------------------------|
| **No beat-sync (卡点) workflow** | Pack assumes video timing drives audio; beat-sync inverts this (audio BPM drives cut timing) | Agent manually calculated BPM-to-cut-timing alignment |
| **No photo-montage video type** | Pack covers Product Demo, Social Short, Tutorial only | Agent adapted Social Short template and general pacing rules |
| **No sub-10s video pattern** | Shortest template is 15s Social Short | Agent derived from general pacing rules |
| **No photo-to-video decision guidance** | Decision Tree assumes user needs to GENERATE assets; no path for "I already have photos, should I AI-animate or compose?" | Agent proposed hybrid approach based on general principles |
| **Seedance minimum 3-5s conflicts with 2s beats** | Pack says "minimum 3-5 seconds per shot" for Seedance but beat-sync needs 2s clips | Agent used generate-then-trim workaround |
| **No genre-to-BPM mapping** | BPM table is organized by video type, not music genre; "lofi" is a genre | Agent used music knowledge outside the pack |
| **No music-as-primary-audio rule** | Volume rules assume voiceover is primary; no guidance when music is the only track | Agent set music to 100% reference level |
| **Ken Burns parameter guidance** | Mentioned in storytelling.md (max 2-3% per 4s) but not detailed for photo-only videos | Agent extrapolated to shorter durations |
| **No motion design rules for single-element scenes** | 3-Ease Minimum assumes multi-element compositions; single photo has one element | Agent could not meaningfully apply the rule |

---

### 10. Complete Parameter Summary

```yaml
# Video Parameters
duration: 6s
aspect_ratio: "9:16"
resolution: "1080x1920"
fps: 30
codec: H.264
crf: 18

# Scene Timing (beat-sync at ~90 BPM)
scenes:
  - id: 1
    start: 0.0s
    end: 2.0s
    source: photo1.jpg
    motion: "Ken Burns zoom-out 105% → 98%"
    transition_in: "fade from black (0.3s)"
  - id: 2
    start: 2.0s
    end: 4.0s
    source: photo2.jpg
    motion: "Ken Burns push-in 95% → 102%"
    transition_in: "hard cut on beat"
  - id: 3
    start: 4.0s
    end: 6.0s
    source: photo3.jpg
    motion: "Ken Burns zoom-out 110% → 100%"
    transition_in: "hard cut on beat"
    transition_out: "fade to black (0.3s)"

# Audio Parameters
music:
  genre: lofi
  bpm: 85-90
  instrumentation: "Rhodes piano, vinyl crackle, soft kick + hi-hat, ambient pads"
  avoid: "vocals, trumpet, lead guitar, piano lead melody"
  volume: "100% (sole audio track)"
  normalization: "-14 LUFS"
  format: "AAC 128kbps stereo"

sfx:
  type: "soft whoosh (optional)"
  timing: "10-20ms pre-lead before each hard cut"
  positions: [1.98s, 3.98s]
  volume: "30% of music level"

# Seedance Parameters (if AI-animating photos)
seedance:
  endpoint: image-to-video
  resolution: 720p  # (480p for draft)
  duration: 5  # minimum safe, trim to 2s post
  aspect_ratio: "9:16"
  consistency:
    color: "lofi aesthetic with warm color grading"
    lighting: "soft lighting, shallow depth of field"
  cost_estimate:
    draft: "$3.60 (480p/Fast)"
    final: "$4.50 (720p/Standard)"

# Tool Selection
composition_tool: "FFmpeg-direct (concat + audio mix)"
alternative: "HyperFrames (if adding text overlays or complex animations)"
```

---

### 11. Rules Cited (Traceability)

| Rule | Source File | Section |
|------|-----------|---------|
| 3-5 Second Attention Rule | storytelling.md | §Pacing Rules |
| Text-Driven Shot Duration Formula | storytelling.md | §Text-Driven Shot Duration Formula |
| 50% Reading Rule | storytelling.md | §Pacing Rules |
| 5-Second Scene Ceiling | storytelling.md | §Pacing Rules |
| 95% Hard Cut Rule | storytelling.md | §Pacing Rules |
| Social Short Pacing Pattern | storytelling.md | §Video Type Pacing Patterns |
| Social Short Narrative Arc | storytelling.md | §Social Short Narrative Arc |
| Ken Burns max 2-3% per 4s | storytelling.md | §Tutorial/Explainer (mid-scene activity) |
| No Exit Rule | SKILL.md | §Quick Rule Index → Visual Design |
| Entrance Offset (0.1-0.3s) | SKILL.md | §Quick Rule Index → Visual Design |
| 3-Ease Minimum | SKILL.md | §Quick Rule Index → Visual Design |
| BPM-to-Video-Type Mapping | audio-design.md | §BPM-to-Video-Type Mapping |
| No Vocals Rule | audio-design.md | §BPM-to-Video-Type Mapping (Critical Rule) |
| Volume Mix Levels | audio-design.md | §Volume Rules |
| -14 LUFS normalization | audio-design.md | §Platform Audio Requirements |
| SFX Pre-Lead 10-20ms | audio-design.md | §SFX Timing Rules |
| Visual Event to SFX Mapping | audio-design.md | §Visual Event to SFX Type Mapping |
| Frequency Separation | audio-design.md | §Frequency Separation for Overlapping SFX |
| Seedance Default Rule | ai-asset-generation.md | §Decision Tree |
| Endpoint Selection (image-to-video) | ai-asset-generation.md | §Seedance Endpoint Selection |
| Motion Safety (avoid "fast") | ai-asset-generation.md | §Prompt Rules |
| Duration-to-Shot Allocation (min 3-5s) | ai-asset-generation.md | §Prompt Rules |
| Color Palette Lock | ai-asset-generation.md | §Visual Consistency Rules |
| Lighting Continuity | ai-asset-generation.md | §Visual Consistency Rules |
| Tiered Generation (draft→final) | ai-asset-generation.md | §Cost Control |
| Cost Table | ai-asset-generation.md | §Cost Table |
| SFX Source Decision | ai-asset-generation.md | §AI Sound Effects Rules |
| ElevenLabs SFX API | ai-asset-generation.md | §AI Sound Effects Rules |
| HyperFrames-first default | SKILL.md | §Quick Rule Index → Tool Selection |
| CRF 18-23 | SKILL.md | §Quick Rule Index → Quality |
| Failure Mode Pre-Check | SKILL.md | §Quick Rule Index → Production |
