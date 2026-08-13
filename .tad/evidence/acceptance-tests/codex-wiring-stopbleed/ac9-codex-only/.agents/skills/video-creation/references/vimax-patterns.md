# ViMax-Inspired AI Video Pipeline Patterns

> Source: NotebookLM research notebook `video-creation-vimax-research` (38 sources)
> ViMax repo: https://github.com/HKUDS/ViMax (MIT License)
> Research findings: .tad/evidence/research/video-creation-vimax/2026-05-27-deep-ask-findings.md

These 4 patterns address **shot-level drift prevention** in AI-generated video clips (Seedance, Kling, etc.). They are complementary to, not replacements for, existing pack rules in `ai-asset-generation.md`, `storytelling.md`, and `audio-design.md`.

**Scope boundary**: These patterns apply ONLY when using AI video generation (Seedance image-to-video, text-to-video). Pure GSAP/Remotion/HyperFrames 2D motion graphics do NOT need these — visual elements are programmatically defined.

---

## Quick Index

| Pattern | When to Use | Section |
|---------|-------------|---------|
| 1: Visual Decomposition | Any AI image-to-video call, shot ≥ 2s | §Pattern 1 |
| 2: Intent Routing | Every new video task, first step | §Pattern 2 |
| 3: View-Specific Reference | Character/object in ≥2 shots with angle change | §Pattern 3 |
| 4: Camera Tree | ≥2 consecutive shots in same scene | §Pattern 4 |
| Photo-to-Beat-Sync | Photos → beat-synced dynamic video | §Integration Scene |

---

## Pattern 1: Visual Decomposition（视觉拆解）

**ViMax 出处**: `agents/storyboard_artist.py` → `StoryboardArtist.decompose_visual_description`
**Schema**: `VisDescDecompositionResponse` — enforces 3-part output structure

> **Key prompt excerpt**: "dissect and rewrite a user-provided visual text description of a shot strictly and insightfully into three distinct parts: First Frame Description / Last Frame Description / Motion Description"

### Rule

When writing a prompt for AI image-to-video generation (Seedance, Kling, etc.):

**DO**: Decompose every shot into 3 explicit parts before calling the API:

| Part | What It Describes | How to Use |
|------|-------------------|------------|
| `first_frame` | Static starting state | Generate via gpt-image-2 as reference image |
| `last_frame` | Static ending state | Generate via gpt-image-2 as end-frame reference |
| `motion` | Direction, speed, rhythm between the two | Feed as text prompt to Seedance with both frame references |

**DON'T**: Feed a single narrative description ("a car drives in and stops in the center") — Seedance interprets motion freely, causing drift in 3-5s clips.

### Trigger

- Any `image-to-video` API call where shot duration ≥ 2 seconds
- Especially critical for 3-5s clips (short duration = less room for AI to self-correct)

### Anti-Pattern

```
❌ Seedance prompt: "A woman walks toward the camera and smiles"
   → AI decides walking speed, smile timing, background movement independently

✅ Decomposed:
   first_frame: "Woman standing 3m from camera, neutral expression, park background"
   last_frame: "Woman at 1m from camera, warm smile, same park background"
   motion: "Steady forward walk, 0.5m/s pace, smile begins at 60% of clip duration"
```

### Integration with Existing Pack

- Use with `ai-asset-generation.md` §Seedance Endpoint Selection: decomposed shots → `image-to-video` endpoint (first_frame as start image, last_frame as end image)
- Use with `ai-asset-generation.md` §Visual Consistency Rules: `@character:<id>` anchoring applies to EACH frame independently

**Grounded in**: [agents/storyboard_artist.py](https://github.com/HKUDS/ViMax/blob/main/agents/storyboard_artist.py), ViMax MIT License

---

## Pattern 2: Intent Routing（意图路由）

**ViMax 出处**: `agents/script_planner.py` → `ScriptPlanner.plan_script`
**Schema**: `IntentRouterResponse` with `Literal["narrative", "motion", "montage"]`

> **Key prompt excerpt**: "intent: 'narrative' for characters multi-conversation focus, 'motion' for action/kinetic focus, 'montage' for emotional montage focus"

### Rule

Before selecting any video template or pacing pattern, **classify the video intent first**:

| Intent | Characteristics | Shot Duration | Cut Rhythm |
|--------|----------------|---------------|------------|
| `narrative` | Character dialogue, story progression | 4-6s medium shots | Dialogue-paced |
| `motion` | Action, kinetic energy, sports, demos | 1.5-3s fast cuts | Beat-synced or action-driven |
| `montage` | Emotional mood, atmosphere, photo collage | 3-5s gradual builds | Music-driven, BPM-aligned |

### How It Connects to Existing Templates

Intent routing sits **above** the existing `storytelling.md` §Video Type Patterns:

```
User request
  → Intent Router (this pattern): narrative / motion / montage
    → storytelling.md Video Type: Product Demo / Social Short / Tutorial / etc.
      → Specific pacing parameters
```

| Intent | Most Likely Video Types | Pacing Guidance |
|--------|------------------------|-----------------|
| `narrative` | Tutorial, Corporate | Longer holds, dialogue-driven timing |
| `motion` | Product Demo, Social Short | Fast cuts, high energy per `storytelling.md` templates |
| `montage` | Emotional/Storytelling, Social Short | Music-driven cuts, BPM from `audio-design.md` |

### Trigger

- First step of every new video task — classify before choosing template
- Re-classify if user changes direction mid-project

### Anti-Pattern

```
❌ User says "做品牌片" → directly apply Product Demo template
   Problem: brand films can be narrative OR montage — wrong pacing if misclassified

✅ User says "做品牌片" → Intent Router → montage (emotional brand story)
   → Select Emotional/Storytelling pacing (3-5s shots, BPM 20-80)
   → NOT Product Demo pacing (1-2s fast cuts, BPM 130-200)
```

**Grounded in**: [agents/script_planner.py](https://github.com/HKUDS/ViMax/blob/main/agents/script_planner.py), ViMax MIT License

---

## Pattern 3: View-Specific Reference Selection（机位参考选择）

**ViMax 出处**: `agents/reference_image_selector.py` → `ReferenceImageSelector.select_reference_images_and_generate_prompt`

> **Key prompt excerpt**: "For character portraits, you can only select at most one image from multiple views (front, side, back). Choose the most appropriate one based on the frame description. For example, when depicting a character from the side, choose the side view of the character."

### Rule

When the same character or object appears in ≥2 shots with different camera angles:

**Step 1**: Generate a **character sheet** with 3 views using gpt-image-2:
- Front view (正面)
- Side view (侧面)
- Back view (背面)

Prompt template for gpt-image-2:
```
"Character reference sheet: [character description]. Three views on white background:
left panel = front view, center panel = side view (3/4 angle), right panel = back view.
Consistent lighting, proportions, and clothing across all three views."
```

**Step 2**: For each shot's image-to-video call, **select the view that matches the camera angle**:

| Camera Angle in Shot | Reference View to Feed |
|---------------------|----------------------|
| Facing camera | Front view |
| Profile / 3/4 angle | Side view |
| Away from camera | Back view |

**Step 3**: Feed the selected view as the reference image to Seedance (not always the front view).

### Trigger

- Character or object appears in ≥2 shots AND at least 1 shot has a different camera angle
- NOT triggered for single-shot videos or same-angle-throughout sequences

### How It Extends Existing Pack

- `ai-asset-generation.md` §Visual Consistency Rules provides `@character:<id>` for prompt-level consistency
- This pattern adds **visual-reference-level consistency** — the AI sees the correct angle, not just the correct text description

### Anti-Pattern

```
❌ All shots use front-view reference → side/back angles hallucinated by AI
✅ Side-angle shot uses side-view reference → AI has accurate visual anchor
```

### Fallback

If character sheet generation fails or only produces 1 view: use the available view for all shots (degrade gracefully — some reference is better than none). This follows ViMax's `BestImageSelector` fallback pattern (idx=0 when LLM response is invalid).

**Grounded in**: [agents/reference_image_selector.py](https://github.com/HKUDS/ViMax/blob/main/agents/reference_image_selector.py), ViMax MIT License

---

## Pattern 4: Camera Tree（镜头空间继承）

**ViMax 出处**: `agents/camera_image_generator.py` → `CameraImageGenerator.construct_camera_tree`

> **Key prompt excerpt**: "Your task is to analyze the input camera position data to construct a 'camera position tree'. This tree structure represents a relationship where a parent camera's content encompasses that of a child camera."

### Rule

When ≥2 consecutive shots occur in the **same scene** (same space, same time):

**Step 1**: Identify the **widest shot** as the parent (establishing shot). This defines the spatial layout.

**Step 2**: All tighter shots (medium, close-up) in the same scene are **children**. Each child prompt MUST explicitly reference spatial elements from the parent:

```
Parent (wide shot): "Living room — sofa on left, painting on back wall, lamp upper-right, warm afternoon light"

Child (medium shot): "Following the wide-shot composition: sofa visible on left edge,
painting on back wall partially visible. Character sitting on sofa, reading."

Child (close-up): "Following the wide-shot composition: warm afternoon light consistent
with establishing shot. Character's hands holding book, sofa fabric texture visible."
```

**Step 3**: Key spatial elements to inherit:

| Element | Why Inherit |
|---------|-------------|
| Object positions | Prevents furniture/prop teleportation between cuts |
| Lighting direction | Prevents shadow direction flip |
| Color temperature | Prevents warm→cool shifts within same scene |
| Background details | Prevents wall art / window / texture changes |

### Trigger

- ≥2 consecutive shots in the same physical space
- NOT needed for montage-style cuts across different locations
- NOT needed for pure GSAP/Remotion 2D (programmatic elements don't hallucinate)

### Anti-Pattern

```
❌ Each shot gets independent prompt → AI invents different backgrounds per cut
   Shot 1: "Man in living room" → AI generates blue walls, modern lamp
   Shot 2: "Man reading on sofa" → AI generates white walls, no lamp
   Result: jarring discontinuity on cut

✅ Camera tree with parent context →
   Shot 1 (parent): "Living room, blue walls, modern lamp, bookshelf right"
   Shot 2 (child): "Same living room (blue walls, modern lamp visible upper-left,
   bookshelf right edge). Medium shot of man reading on sofa."
   Result: spatial continuity preserved
```

### Integration with Existing Pack

- `production.md` §Render Pipeline: camera tree analysis happens BEFORE individual shot generation (during "compose" phase)
- `visual-design.md` §GSAP Easing: camera tree is for AI video shots only — GSAP-driven scenes have programmatic spatial control

**Grounded in**: [agents/camera_image_generator.py](https://github.com/HKUDS/ViMax/blob/main/agents/camera_image_generator.py), ViMax MIT License

---

## Integration Scene: Photo-to-Beat-Sync

**Scenario**: User has a set of static photos and wants them converted into a beat-synced dynamic video (卡点视频).

### 4-Pattern Workflow

| Step | Pattern Used | Action |
|------|-------------|--------|
| 1. Classify intent | Pattern 2 | Multiple photos + beat sync → **montage** intent |
| 2. Per-photo decomposition | Pattern 1 | Each photo = `first_frame`. Generate `last_frame` (subtle motion end state) via gpt-image-2. Define `motion` (e.g., slow zoom, parallax shift, expression change). |
| 3. View consistency | Pattern 3 | If same person appears across photos at different angles → extract view-specific references, feed angle-matched view per Seedance call |
| 4. Scene cohesion | Pattern 4 | If multiple photos share the same location → establish parent (widest framing), child shots inherit spatial details |
| 5. Audio sync | `audio-design.md` | Montage intent → BPM 20-80 per Emotional/Storytelling range. Use BPM-to-cut: `cut_interval = 60 / BPM`. SFX Pre-Lead Rule: whoosh 10-20ms before each cut. |

### Example: 3 Photos → 6s Video

```
Input: 3 portrait photos, different expressions/poses, lofi music

Step 1 — Intent: montage (photo collage + emotional mood)
Step 2 — Decomposition per photo (2s each):
  Photo 1: first_frame=photo, last_frame="slight smile develops", motion="subtle zoom in 10%"
  Photo 2: first_frame=photo, last_frame="head tilts right", motion="slow pan left-to-right"
  Photo 3: first_frame=photo, last_frame="eyes look up", motion="gentle dolly back"

Step 3 — View check: 3 different people → Pattern 3 not triggered (no repeated character)
         (If same person, different angles → generate character sheet, match views)

Step 4 — Scene check: 3 different locations → Pattern 4 not triggered
         (If same room, different framings → establish parent wide shot)

Step 5 — Audio: lofi → 75 BPM (Emotional range 20-80, fits lofi aesthetic)
         Cut interval: 60/75 = 0.8s beats → cuts on every 2-3 beats ≈ 2.0s per photo
         SFX: soft whoosh at 1.98s, 3.98s (Pre-Lead 20ms before cuts at 2.0s, 4.0s)
```

### Anti-Patterns for Photo-to-Beat-Sync

| Anti-Pattern | Why It Fails | Correct Approach |
|-------------|-------------|-----------------|
| Skip intent classification, use Product Demo template | 30s beat-sync treated as product demo → pacing too fast (1-2s cuts) | Classify as montage → 2-3s per photo |
| Feed photo + "make it move" to Seedance | AI decides motion direction freely → uncontrolled drift | Decompose: photo=first_frame, generate last_frame, specify motion |
| Manually align cuts to beats | Time-consuming, error-prone | Use `audio-design.md` BPM-to-cut formula: `cut_interval = 60 / BPM` |

---

## Cross-References

| Reference | Relationship |
|-----------|-------------|
| `ai-asset-generation.md` §Seedance Endpoint Selection | Patterns 1+3 refine endpoint input selection (which images to feed) |
| `ai-asset-generation.md` §Visual Consistency Rules | Pattern 3 adds visual-reference consistency on top of prompt-level `@character:<id>` |
| `storytelling.md` §Video Type Patterns | Pattern 2 intent routing sits above video type selection |
| `audio-design.md` §BPM-to-Video-Type | Photo-to-Beat-Sync uses montage→BPM mapping + cut formula |
| `visual-design.md` §GSAP Easing | Pattern 4 scope excludes GSAP (programmatic spatial control) |
| `production.md` §Render Pipeline | Camera tree analysis in "compose" phase, before shot generation |

---

## License Attribution

Patterns derived from [HKUDS/ViMax](https://github.com/HKUDS/ViMax) (MIT License).
Implementation rules adapted for motion-graphics context — original code patterns
translated into judgment rules for AI coding agents. Not a code port.
