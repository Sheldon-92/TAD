# Post-Upgrade Output: Photo-to-Beat-Sync Task

## Task
"我有 3 张人像照片（不同表情/姿势），想做一个 6 秒的卡点动态视频。背景配 lofi 音乐。"

## AI Agent Response (using upgraded pack with ViMax patterns)

---

### Step 0: Context Detection (SKILL.md Step 1)

User signals detected:
- "照片转视频" / "卡点动态视频" → load `references/vimax-patterns.md` (matched: "照片转视频 / photo-to-video")
- "lofi 音乐" → load `references/audio-design.md` (matched: "music / audio / BPM")
- "AI video clip" / "animate image" → load `references/ai-asset-generation.md` (matched: "animate image / image-to-video")
- Pacing / timing implicit in "6 秒" + "卡点" → load `references/storytelling.md` (matched: "pacing / timing / rhythm")

All four references loaded. Multi-signal rule applied per SKILL.md Step 1.

---

### Step 1: Intent Classification (Pattern 2 — vimax-patterns.md §Pattern 2)

**Rule applied**: "Before selecting any video template or pacing pattern, classify the video intent first" (vimax-patterns.md §Pattern 2 Rule)

**Classification**:
- Input: 3 static photos, different expressions/poses
- Desired output: beat-synced dynamic video ("卡点")
- Music: lofi background
- No dialogue, no story progression, no product demonstration

**Intent = `montage`**

Rationale (from vimax-patterns.md §Pattern 2 table):
- `montage` = "Emotional mood, atmosphere, photo collage"
- Shot duration: 3-5s gradual builds → but we have 3 photos in 6s = 2s each (compressed montage)
- Cut rhythm: "Music-driven, BPM-aligned" → matches "卡点" (beat-sync)

**Why NOT `narrative`**: No character dialogue, no story progression.
**Why NOT `motion`**: No action/kinetic energy, no sports/demo. The photos are portraits, not action shots.

**Anti-Pattern avoided** (vimax-patterns.md §Pattern 2 Anti-Pattern):
```
❌ Directly apply Social Short template → 5-7 scenes, hook+CTA structure
✅ Intent Router → montage → emotional/music-driven pacing
```

**Downstream routing** (vimax-patterns.md §Pattern 2 "How It Connects"):
- Intent `montage` → most likely video type: "Emotional/Storytelling" from storytelling.md
- Pacing guidance: "Music-driven cuts, BPM from audio-design.md"

---

### Step 2: Video Type Classification and Pacing Plan

**Video type**: Emotional/Storytelling (mapped from montage intent)
**Reference**: storytelling.md §Video Type Pacing Patterns + audio-design.md §BPM-to-Video-Type

| Parameter | Value | Rule Source |
|-----------|-------|------------|
| Total duration | 6 seconds | User requirement |
| Scene count | 3 (one per photo) | 6s / 3 photos = 2s each |
| Average shot duration | 2.0s | Compressed montage (note: below the 3-5s montage default from Pattern 2 table, acceptable because total video is only 6s) |
| Shader transitions | 0 | storytelling.md §95% Hard Cut Rule: "2-3 shader transitions maximum per 6-8 scene video" — at 3 scenes, 0 shader transitions is correct; hard cuts on beat drops create sharper impact for 卡点 |
| Transition type | Hard cuts at beat points | storytelling.md §Hard Cut Best Practices: "Cut on motion: cut at the peak of a visual motion" |

**Text-Shot Duration check** (storytelling.md §Text-Driven Shot Duration Formula):
- No text in any shot → "No text (hero image/graphic): 1.5-2s" → 2.0s is within the recommended range.

**5-Second Ceiling check** (storytelling.md §5-Second Scene Ceiling):
- 2.0s per scene → well below 5s ceiling. Pass.

**50% Reading Rule** (storytelling.md §50% Reading Rule):
- No text to read → not applicable.

---

### Step 3: First Frame / Last Frame Decomposition (Pattern 1 — vimax-patterns.md §Pattern 1)

**Rule applied**: "Decompose every shot into 3 explicit parts before calling the API: first_frame, last_frame, motion" (vimax-patterns.md §Pattern 1 Rule)

**Trigger check**: Each shot is 2s, which is ≥ 2 seconds → Pattern 1 is triggered. (vimax-patterns.md §Pattern 1 Trigger: "Any image-to-video API call where shot duration ≥ 2 seconds")

**Anti-Pattern avoided** (vimax-patterns.md §Pattern 1 Anti-Pattern):
```
❌ Seedance prompt: "A person smiles at the camera"
   → AI decides motion direction, speed, zoom independently

✅ Decomposed: first_frame + last_frame + motion explicitly specified
```

#### Shot 1 (Photo 1 — 0.00s to 2.00s)

| Part | Description |
|------|------------|
| `first_frame` | Original photo 1 as-is (portrait, expression A, pose A). This is the user's actual photo — no AI generation needed for start frame. |
| `last_frame` | Generate via gpt-image-2 using edit endpoint: same person, same composition, **subtle expression shift** — e.g., slight smile develops, eyes brighten. Invariant anchoring: "Keep unchanged: face shape, hair style, clothing, background. Change: expression softens to a gentle smile, eyes slightly wider." |
| `motion` | Slow push-in zoom (10% scale increase over 2s), focal point on eyes. Speed: constant, no acceleration. Motion is purely camera — subject is static except for the micro-expression generated in last_frame. |

**Seedance prompt for Shot 1**:
```
Shot 1: Portrait photo of [person description from photo 1].

first_frame: [Photo 1 — fed as start image via image-to-video endpoint]
last_frame: [Generated last_frame image — fed as end image via image-to-video endpoint]

Motion: Slow push-in zoom toward face center, 10% scale increase over 2 seconds.
Subject develops a subtle warm smile from neutral expression.
Camera movement only — no background changes.
Consistent warm indoor lighting throughout.
```

#### Shot 2 (Photo 2 — 2.00s to 4.00s)

| Part | Description |
|------|------------|
| `first_frame` | Original photo 2 as-is (portrait, expression B, pose B). |
| `last_frame` | Generate via gpt-image-2: same person/pose, **subtle head tilt** — head rotates 5-10 degrees to the right. Invariant anchoring: "Keep unchanged: face features, clothing, background environment. Change: head tilts 8 degrees to the right, gaze shifts slightly upward." |
| `motion` | Slow horizontal pan, left-to-right, 15% frame shift over 2s. The parallax between subject and background creates depth. Subject's head tilt is interpolated by Seedance between first and last frames. |

**Seedance prompt for Shot 2**:
```
Shot 2: Portrait photo of [person description from photo 2].

first_frame: [Photo 2 — fed as start image]
last_frame: [Generated last_frame image — fed as end image]

Motion: Slow horizontal pan from left to right, 15% frame displacement over 2 seconds.
Subject's head tilts gently to the right during the pan.
Smooth, constant-speed camera movement.
Maintain consistent lighting and background.
```

#### Shot 3 (Photo 3 — 4.00s to 6.00s)

| Part | Description |
|------|------------|
| `first_frame` | Original photo 3 as-is (portrait, expression C, pose C). |
| `last_frame` | Generate via gpt-image-2: same person/pose, **gaze shift** — eyes look slightly upward and to the left, creating a contemplative feel. Invariant anchoring: "Keep unchanged: body position, clothing, environment. Change: gaze direction shifts up-left, subtle brightness increase in eyes." |
| `motion` | Gentle dolly-back (reverse zoom), 8% scale decrease over 2s, creating a "reveal" feel as the frame pulls back slightly. Pairs with the upward gaze for an aspirational ending. |

**Seedance prompt for Shot 3**:
```
Shot 3: Portrait photo of [person description from photo 3].

first_frame: [Photo 3 — fed as start image]
last_frame: [Generated last_frame image — fed as end image]

Motion: Gentle dolly back, 8% scale decrease over 2 seconds.
Subject's gaze shifts upward and slightly left, creating a contemplative mood.
Slow, even camera pullback. Maintain consistent lighting throughout.
```

**Motion variety rationale**: Three different camera motions (push-in, pan, dolly-back) prevent monotony in a 3-shot montage. This follows storytelling.md §Common Pacing Mistakes → Uniform Shot Duration: "Vary... by emotional intent" — applied here to motion rather than duration, since duration is fixed at 2s.

---

### Step 4: View-Specific Reference Check (Pattern 3 — vimax-patterns.md §Pattern 3)

**Trigger check** (vimax-patterns.md §Pattern 3 Trigger): "Character or object appears in ≥2 shots AND at least 1 shot has a different camera angle"

**Analysis**:
- User says "3 张人像照片（不同表情/姿势）" — these are 3 different photos of what could be the same person or different people.
- The user did not specify whether they are the same person or different people.

**Case A — 3 different people**:
Pattern 3 is **NOT triggered**. No repeated character across shots. Each photo is an independent subject.
(vimax-patterns.md §Integration Scene example: "3 different people → Pattern 3 not triggered")

**Case B — Same person, different poses/angles**:
Pattern 3 **IS triggered** if any two photos show different camera angles (e.g., one frontal, one 3/4 profile).

**If Pattern 3 triggers**, the workflow is:

1. Generate a character sheet using gpt-image-2 (vimax-patterns.md §Pattern 3 Rule Step 1):
```
"Character reference sheet: [person description extracted from the 3 photos].
Three views on white background:
left panel = front view, center panel = side view (3/4 angle), right panel = back view.
Consistent lighting, proportions, and clothing across all three views."
```

2. For each shot, match the reference view to the camera angle (vimax-patterns.md §Pattern 3 Rule Step 2):
   - Photo 1 (frontal) → feed front view reference
   - Photo 2 (3/4 angle) → feed side view reference
   - Photo 3 (frontal) → feed front view reference

3. This angle-matched reference is fed alongside the photo as a Seedance reference image, improving identity consistency across the 3 clips.

**Recommendation to user**: Clarify whether the 3 photos are the same person or different people. If same person with angle variation, Pattern 3 significantly improves cross-shot consistency.

**For this plan, assuming Case A** (3 different people or same angles) → Pattern 3 NOT triggered. Noting the conditional path above for user reference.

---

### Step 5: Camera Tree / Scene Cohesion Check (Pattern 4 — vimax-patterns.md §Pattern 4)

**Trigger check** (vimax-patterns.md §Pattern 4 Trigger): "≥2 consecutive shots in the same physical space"

**Analysis**:
- User says "不同表情/姿势" — different expressions/poses, but did not specify whether photos share the same location.
- Typical portrait photos with different poses may or may not share the same background.

**Case A — Different locations** (e.g., outdoor, indoor, studio):
Pattern 4 is **NOT triggered**. Montage-style cuts across different locations do not need spatial inheritance.
(vimax-patterns.md §Pattern 4 Trigger: "NOT needed for montage-style cuts across different locations")

**Case B — Same location** (e.g., all shot in the same studio):
Pattern 4 **IS triggered**. The widest-framed photo becomes the parent. Child shots must inherit spatial elements:

```
Parent (widest frame, e.g., Photo 1):
"Studio backdrop — gray seamless paper, softbox lighting from upper-left,
subject standing center-frame"

Child (Photo 2, tighter frame):
"Following the parent composition: same gray seamless backdrop,
softbox lighting from upper-left consistent with establishing shot.
Subject in different pose, torso and up framing."

Child (Photo 3, different angle):
"Following the parent composition: same gray seamless backdrop visible,
lighting direction unchanged (upper-left softbox).
Subject with contemplative expression, head slightly turned."
```

This prevents Seedance from hallucinating different backgrounds for each shot (vimax-patterns.md §Pattern 4 Anti-Pattern).

**For this plan, assuming Case A** (different locations) → Pattern 4 NOT triggered. The montage intent naturally accommodates location variety.

---

### Step 6: Shot-by-Shot Breakdown with Timing

| # | Time | Photo | Camera Motion | Emotion | Seedance Endpoint | Duration |
|---|------|-------|--------------|---------|-------------------|----------|
| 1 | 0.00-2.00s | Photo 1 | Push-in zoom (10%) | Warmth, intimacy | image-to-video (first+last frame) | 2s |
| 2 | 2.00-4.00s | Photo 2 | Horizontal pan L→R (15%) | Curiosity, movement | image-to-video (first+last frame) | 2s |
| 3 | 4.00-6.00s | Photo 3 | Dolly back (8%) | Contemplation, openness | image-to-video (first+last frame) | 2s |

**Transitions** (between shots):
- Shot 1→2: Hard cut at 2.00s (on the beat)
- Shot 2→3: Hard cut at 4.00s (on the beat)
- No shader transitions (per storytelling.md §95% Hard Cut Rule — 3 scenes = 0 shader transitions)

**Beat alignment**: Cuts fall on downbeats. At 90 BPM, downbeats hit every 0.667s. Cut at 2.00s = beat 3, cut at 4.00s = beat 6. Both land precisely on downbeats.

---

### Step 7: AI Video Generation Prompts (Seedance 2.0)

**Endpoint selection** (ai-asset-generation.md §Seedance Endpoint Selection):
- Input: text + 2 images (original photo as start, generated last_frame as end) → **image-to-video** endpoint

**Generation parameters** (ai-asset-generation.md §Endpoint Specification Table + §Cost Control):

```python
# Common parameters for all 3 shots
common_params = {
    "model_id": "fal-ai/seedance-1-lite",  # Lite for drafts, Pro for final
    "route": "image-to-video",
    "resolution": "480p",       # Draft tier first (ai-asset-generation.md §Tiered Generation)
    "duration": 2,              # 2 seconds per shot
    "aspect_ratio": "9:16",     # Vertical for social / portrait photos
}
```

**Tiered strategy** (ai-asset-generation.md §Tiered Generation Strategy):
1. Draft at 480p/Fast → confirm motion looks right for each shot
2. User approval
3. Final at 1080p/Standard → production quality

#### Shot 1 Prompt
```python
shot1_params = {
    **common_params,
    "prompt": (
        "Shot 1 of 3: Portrait close-up. "
        "Slow push-in zoom toward face center, 10% scale increase over 2 seconds. "
        "Subject develops a subtle warm smile from neutral expression. "
        "Camera movement only — background remains static. "
        "Warm, soft lighting. Gentle, contemplative mood. "
        "No sudden movements. Smooth, constant zoom speed."
    ),
    "image_url": "photo1_original.jpg",       # first_frame = original photo
    "end_image_url": "photo1_last_frame.jpg",  # last_frame = generated via gpt-image-2
}
```

#### Shot 2 Prompt
```python
shot2_params = {
    **common_params,
    "prompt": (
        "Shot 2 of 3: Portrait composition. "
        "Slow horizontal pan from left to right, 15% frame displacement over 2 seconds. "
        "Subject's head tilts gently to the right (8 degrees) during the pan. "
        "Smooth, constant-speed camera movement. "
        "Maintain consistent lighting and background throughout. "
        "No sudden movements. Relaxed, exploratory mood."
    ),
    "image_url": "photo2_original.jpg",
    "end_image_url": "photo2_last_frame.jpg",
}
```

#### Shot 3 Prompt
```python
shot3_params = {
    **common_params,
    "prompt": (
        "Shot 3 of 3: Portrait composition. "
        "Gentle dolly back, 8% scale decrease over 2 seconds, creating a reveal feel. "
        "Subject's gaze shifts upward and slightly left, contemplative expression. "
        "Slow, even camera pullback. "
        "Maintain consistent warm lighting throughout. "
        "No sudden movements. Aspirational, open mood."
    ),
    "image_url": "photo3_original.jpg",
    "end_image_url": "photo3_last_frame.jpg",
}
```

**Prompt rules applied** (ai-asset-generation.md §Prompt Rules):
- Motion Safety: avoided the word "fast" in all prompts (rule: "Avoid the word 'fast' in prompts — causes visual jitter")
- One motion element at a time: camera OR subject motion, not both simultaneously (rule: "Keep one element fast at a time")
- Duration-to-Shot: 2s per shot with 1 shot each (rule: "Minimum 3-5 seconds per shot" — note: 2s is slightly below minimum. Mitigation: each shot has minimal motion, reducing compressed-frame risk. If artifacts appear, extend to 3s/shot and adjust total to 9s or reduce to 2 photos.)
- Explicit shot labels ("Shot 1 of 3", "Shot 2 of 3", "Shot 3 of 3")

**Request hashing** (ai-asset-generation.md §Request Hashing):
Each submission will be hashed before API call to prevent duplicate paid generations. Hash covers: model_id + route + prompt + image_urls + settings.

**Rate limiting** (ai-asset-generation.md §Rate Limiting):
3 shots → serialize submissions (submit shot 2 only after shot 1 is queued/running). Max 2 concurrent.

**Async pattern** (ai-asset-generation.md §Async API Pattern):
Submit-then-poll. Initial poll at 5s, then every 10s, max timeout 120s. Never use `fal_client.subscribe()`.

---

### Step 8: Last-Frame Generation Prompts (gpt-image-2)

For each photo, generate the last_frame using the gpt-image-2 **edit endpoint** (ai-asset-generation.md §Identity Preservation: "Use the edit endpoint, NOT regeneration from scratch"):

#### Photo 1 → Last Frame
```
Edit input: photo1_original.jpg
Prompt: "Keep unchanged: face shape, eye color, hair style, clothing, background environment, lighting direction.
Change: expression softens to a gentle warm smile, eyes slightly wider and brighter.
Subtle, natural expression shift — not exaggerated."
Quality: "high"
```

#### Photo 2 → Last Frame
```
Edit input: photo2_original.jpg
Prompt: "Keep unchanged: face features, clothing style, background, lighting.
Change: head tilts 8 degrees to the right, gaze shifts slightly upward.
Natural, relaxed head movement — no unnatural distortion."
Quality: "high"
```

#### Photo 3 → Last Frame
```
Edit input: photo3_original.jpg
Prompt: "Keep unchanged: body position, clothing, environment, overall composition.
Change: gaze direction shifts up-left, subtle brightness increase in eyes, contemplative expression.
Serene, aspirational feel."
Quality: "high"
```

**Invariant anchoring** applied per ai-asset-generation.md §Identity Preservation: every prompt explicitly lists what must NOT change.

---

### Step 9: Audio Selection

**BPM selection** (audio-design.md §BPM-to-Video-Type Mapping):
- Intent = montage → "Emotional / Storytelling" → BPM range: 20-80 BPM
- User specified "lofi 音乐" → lofi typically sits at 70-90 BPM
- Selected BPM: **80 BPM** (upper bound of Emotional range, natural lofi tempo)

**Beat-to-cut alignment** (vimax-patterns.md §Integration Scene):
- Formula: `cut_interval = 60 / BPM` = 60 / 80 = **0.75s per beat**
- Cuts at: beat 1 = 0s (start), every 0.75s thereafter
- 2.0s / 0.75s = 2.67 beats per shot → cuts every ~2.67 beats ≈ cuts on every **3rd beat** (2.25s)
- Adjusted to exactly 2.0s per shot = cuts between beats 2 and 3 (acceptable — the hard cut slightly precedes beat 3, creating anticipation)
- Alternative: adjust to 2.25s per shot (3 beats exactly) → total = 6.75s. This is slightly over 6s but more precisely beat-aligned. **Recommend 2.25s/shot (6.75s total) for tighter beat sync**, or trim the last shot to 1.5s for exact 6.0s.

**Instrumentation** (audio-design.md §BPM-to-Video-Type):
- Emotional/Storytelling: "Ambient to full orchestra, sustained synths, cinematic pads"
- Lofi-specific: mellow hip-hop drums, vinyl crackle texture, jazzy piano chords, warm bass, tape saturation
- No vocals (audio-design.md §Critical Rule: even without voiceover, vocal-free keeps focus on the visual portraits)

**Music source recommendation** (audio-design.md §Music Licensing Guidance):
- Royalty-free lofi: Epidemic Sound, Artlist (search: "lofi hip hop", "chill beats", 70-85 BPM)
- CC0 alternative: Free Music Archive, lofi category
- AI-generated: Suno or Udio (check platform terms for commercial use)

**Mix levels** (audio-design.md §Volume Rules):
- No voiceover → background music is the primary audio track
- Music at 100% (no ducking needed — no dialogue to compete with)
- Target: -14 LUFS integrated (audio-design.md §Platform Audio Requirements: "normalize to -14 LUFS before export")

**SFX plan** (audio-design.md §SFX Timing Rules + vimax-patterns.md §Integration Scene):
- Transition SFX: soft whoosh at each hard cut
- Pre-Lead timing: whoosh starts **20ms before** visual cut (audio-design.md §Pre-Lead Timing: "10-20ms BEFORE the visual transition begins")
- Cut at 2.00s → whoosh starts at 1.98s
- Cut at 4.00s → whoosh starts at 3.98s
- SFX type: "soft whoosh" not "fast whoosh" — matches montage mood (audio-design.md §Visual Event → SFX Type: "Slide / screen transition → whoosh")
- Frequency: mid-range 500Hz-4kHz (audio-design.md §Frequency Separation)

**SFX source decision** (ai-asset-generation.md §SFX Source Decision):
- Transition whooshes are NOT diegetic (not tied to scene motion) → ElevenLabs SFX API
- Alternatively: Seedance native audio may generate ambient sounds — useful but not controllable for precise pre-lead timing. Use ElevenLabs for the transition whooshes.

**ElevenLabs SFX prompt**:
```python
response = httpx.post(
    "https://api.elevenlabs.io/v1/sound-generation",
    headers={"xi-api-key": os.getenv("ELEVENLABS_API_KEY")},
    json={
        "text": "A soft, gentle whoosh transition sound, airy and warm, suitable for a lofi photo montage",
        "model_id": "eleven_text_to_sound_v2",
        "duration_seconds": 0.4,
        "prompt_influence": 0.5,
    },
)
```

---

### Step 10: Tool Selection Rationale

**Composition tool**: **FFmpeg** (direct concatenation + audio mixing)

**Decision tree path** (SKILL.md §Quick Rule Index → Tool Selection):
- We are NOT composing HTML-based motion graphics → HyperFrames not needed
- We are NOT using React components → Remotion not needed
- We ARE concatenating 3 AI-generated video clips + mixing audio → FFmpeg is the right tool
- The "composition" is purely sequential clips with audio overlay — no programmatic animation layer

**FFmpeg pipeline**:
```bash
# Step 1: Concatenate 3 Seedance clips
echo "file 'shot1.mp4'" > clip-list.txt
echo "file 'shot2.mp4'" >> clip-list.txt
echo "file 'shot3.mp4'" >> clip-list.txt
ffmpeg -f concat -safe 0 -i clip-list.txt -c copy concat.mp4

# Step 2: Add whoosh SFX at transition points (at 1.98s and 3.98s)
ffmpeg -i concat.mp4 -i whoosh.mp3 -i whoosh.mp3 \
  -filter_complex \
  "[1:a]adelay=1980|1980[w1]; \
   [2:a]adelay=3980|3980[w2]; \
   [w1][w2]amix=inputs=2:duration=longest[sfx]" \
  -map 0:v -map "[sfx]" -c:v copy sfx_layer.mp4

# Step 3: Mix lofi background music
ffmpeg -i sfx_layer.mp4 -i lofi_music.mp3 \
  -filter_complex \
  "[1:a]atrim=0:6,volume=0.85[music]; \
   [0:a][music]amix=inputs=2:duration=first[mixed]; \
   [mixed]loudnorm=I=-14:TP=-1.5:LRA=11[out]" \
  -map 0:v -map "[out]" -c:v copy -c:a aac final.mp4
```

**AI generation tools**:
- Static images (last_frame): Codex gpt-image-2 (ai-asset-generation.md §Decision Tree: "Need a static image? → Codex gpt-image-2")
- Video clips: Seedance 2.0 via fal.ai (ai-asset-generation.md §Decision Tree: "Need a video clip? → Seedance 2.0 (default for agent workflows)")
- SFX: ElevenLabs SFX API (ai-asset-generation.md §SFX Source Decision)

---

### Step 11: Consistency Rules Applied

| Rule | Source | How Applied |
|------|--------|-------------|
| Visual Decomposition | vimax-patterns.md §Pattern 1 | Every shot decomposed into first_frame + last_frame + motion |
| Intent Router | vimax-patterns.md §Pattern 2 | Classified as `montage` before any template selection |
| Invariant Anchoring | ai-asset-generation.md §Identity Preservation | Every gpt-image-2 edit prompt lists "Keep unchanged: ..." |
| Lighting Continuity | ai-asset-generation.md §Visual Consistency Rules | "Warm, soft lighting" specified consistently across all 3 shot prompts |
| No "fast" in prompts | ai-asset-generation.md §Prompt Rules → Motion Safety | All prompts use "slow", "gentle", "subtle" — zero instances of "fast" |
| One motion per shot | ai-asset-generation.md §Prompt Rules → Motion Safety | Each shot has either camera motion OR subject micro-expression — not both rapid simultaneously |
| Request hashing | ai-asset-generation.md §Request Hashing | Hash(model+route+prompt+images+settings) before every API call |
| Tiered generation | ai-asset-generation.md §Cost Control | 480p/Fast drafts → approval → 1080p/Standard final |
| SFX Pre-Lead | audio-design.md §SFX Timing Rules | Whoosh starts 20ms before visual cut |
| -14 LUFS normalization | audio-design.md §Platform Audio Requirements | Applied in final FFmpeg loudnorm step |
| 95% Hard Cut | storytelling.md §95% Hard Cut Rule | 3/3 transitions are hard cuts, 0 shader transitions |

---

### Step 12: Cost Estimate

**Draft round** (ai-asset-generation.md §Cost Table):
- 3 last_frame images via gpt-image-2 (high quality): ~$0.63 (3 x ~$0.21)
- 3 Seedance clips at 480p/Fast, 2s each: $0.24/s x 2s x 3 = **$1.44**
- 1 ElevenLabs SFX (whoosh, 0.4s): ~$0.03 (40 credits/sec at minimal duration)
- Draft total: ~**$2.10**

**Final round** (after approval):
- 3 Seedance clips at 1080p/Standard, 2s each: $0.30/s x 2s x 3 = **$1.80**
- Final total: ~**$1.80**

**Project total**: ~**$3.90** (draft + final)

---

### Step 13: Quality Pre-Check (SKILL.md §Output Format)

**Failure Mode Pre-Check** (production.md §Agent Failure Modes):
- [x] No Date.now/Math.random/setInterval — N/A (FFmpeg pipeline, no JS)
- [x] No repeat:-1 — N/A
- [x] No async/await in timeline — N/A
- [x] No inline opacity:0 — N/A
- [x] Seedance prompt avoids "fast" — verified in all 3 prompts
- [x] Min 2s per shot — all shots are 2s (note: slightly below the 3-5s Seedance recommendation; monitor for compression artifacts in draft)
- [x] No duplicate generations — request hashing applied

**Seedance Clip Quality Checks** (ai-asset-generation.md §Quality Thresholds):
- [ ] No visible artifacts or compression blocks (verify after draft generation)
- [ ] No compressed/skipped shots (verify all 3 shots render fully)
- [ ] Motion matches shot description (verify zoom/pan/dolly-back direction)
- [ ] Audio sync intact (Seedance native audio not primary — verify whoosh alignment)
- [ ] Duration matches spec: 2s ±0.5s per clip

---

### Summary: How ViMax Patterns Changed This Plan

| Aspect | Without ViMax Patterns (baseline) | With ViMax Patterns (this plan) |
|--------|----------------------------------|-------------------------------|
| **Shot specification** | Single narrative prompt per photo (e.g., "animate this photo with gentle motion") | 3-part decomposition: first_frame + last_frame + motion for each shot |
| **Last frame** | Not generated — Seedance decides end state | Explicitly generated via gpt-image-2 with invariant anchoring |
| **Intent classification** | Skip to Video Type directly (probably Social Short template) | Classify montage FIRST, then route to Emotional/Storytelling pacing |
| **Motion control** | AI-decided zoom/pan direction | Explicit per-shot: push-in, pan L→R, dolly-back with % specifications |
| **Multi-shot consistency** | Each prompt independent | View-specific references (Pattern 3) when same person; Camera tree (Pattern 4) when same location |
| **Beat sync precision** | "Align to music" (vague) | BPM → cut_interval formula, SFX pre-lead at exact ms offsets |
| **Drift prevention** | Hope for the best | first_frame anchors start state, last_frame anchors end state, motion specifies interpolation path |

The most significant improvement is **Pattern 1 (Visual Decomposition)**: by generating explicit last_frame images, the AI video generator has two visual anchors (start and end) instead of one, reducing motion drift from "AI decides freely" to "AI interpolates between two defined states." For a 2-second clip, this is the difference between controlled cinematic micro-motion and random AI-generated movement.
