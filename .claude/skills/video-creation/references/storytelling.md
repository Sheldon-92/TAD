# Storytelling & Pacing Reference

> Source: Research notebook a62f253b (27 sources), Layers 2 + 4

---

## Video Type Quick Reference

The three most common agent video tasks are: **product demo** (16:9, 30-60s), **social short** (9:16, 10-15s), and **tutorial** / explainer (16:9, variable duration). Each has a distinct pacing pattern. See §Video Type Pacing Patterns for the 12-scene rhythm template and timing details.

---

## Pacing Rules

### 3-5 Second Attention Rule
**Rule**: Every 3-5 seconds, there must be a visually meaningful change — a new element entering, a transition, a motion shift, or a scene cut.

**Why**: Human attention resets on visual change. Longer static holds cause viewer drop-off. Shorter than 3s feels frantic unless intentional (fast-cut style).

**Exceptions**: Counter animations, hero holds (deliberate dramatic pause). Maximum exception: 8 seconds.

[Source: Research findings Layer 2]

---

### Text-Driven Shot Duration Formula

| Text Amount | Duration |
|-------------|----------|
| No text (hero image/graphic) | 1.5–2s |
| 1–3 words (kicker, label) | 2–3s |
| 4–10 words (headline) | 3–4s |
| 11–20 words (sentence) | 4–6s |
| 21–35 words (paragraph) | 6–8s |
| 35+ words | **MUST split across two scenes** |

**Implementation**: Calculate scene duration by word count first, then verify against 5-Second Ceiling.

[Source: Research findings Layer 2]

---

### 50% Reading Rule
**Rule**: The last readable element must finish its entrance animation by the 50% mark of the scene's total duration.

**Why**: Viewers need the second half of the scene duration to read and absorb content. An element that finishes entering at 90% gives no reading time.

**Application**: If a scene is 4 seconds, the last text element must be fully visible by 2.0s.

[Source: Research findings Layer 2]

---

### 5-Second Scene Ceiling
**Rule**: No scene may exceed 5 seconds, except:
- Counter animations (counting up to a number)
- Hero holds (deliberate dramatic pause — use sparingly, maximum 8s)

**Why**: Beyond 5 seconds, a static composition reads as a static image, not video. Motion must continue (see visual-design.md §JPEG with Progress Bar).

[Source: Research findings Layer 2]

---

### 95% Hard Cut Rule
**Rule**: 95% of scene transitions should be hard cuts (instantaneous). Use shader/cinematic transitions sparingly:
- **2-3 shader transitions maximum** per 6-8 scene video
- **Placement**: Hero reveal (scene 1→2), energy shift (mid-video), CTA push (final)

**Why**: Every shader transition takes 0.3-0.5s and costs viewer attention. Overuse cheapens impact and extends runtime.

**Hard cut**: Frame A ends at frame N, Frame B starts at frame N+1. No crossfade, no wipe.

[Source: Research findings Layer 2]

---

### Hook Timing (Social Media)
**Rule**: The first 3-5 seconds must contain a visual hook — a striking image, motion, or statement that stops the scroll.

**For 9:16 short-form video (TikTok, Reels, Shorts)**:
- Frame 0-3s: Hook (visual impact or immediate transition)
- Frame 3-10s: Core content delivery
- Frame 10-15s: CTA

**Anti-pattern**: Opening with a logo hold. The logo can appear after the hook.

[Source: Research findings Layer 4]

---

## Video Type Pacing Patterns

### Product Demo (16:9, 30-60s)

**Scene structure**:
- 10-18 scenes total
- 95% hard cuts (2-3 shader transitions at: hero reveal, energy shift, CTA)

**12-Scene Rhythm Template** (proven structure for 30s demos):
```
Scene 1:  3.0s  — Logo/Brand reveal
Scene 2:  3.0s  — Problem statement (hook)
Scene 3:  4.0s  — Solution intro
Scene 4:  3.5s  — Feature 1
Scene 5:  4.0s  — Feature 2
Scene 6:  5.0s  — Feature 3 (longest — most important)
Scene 7:  3.5s  — Feature 4
Scene 8:  4.0s  — Social proof / stat
Scene 9:  3.5s  — Benefit summary
Scene 10: 4.0s  — Demo/visual proof
Scene 11: 4.0s  — Secondary CTA
Scene 12: 3.5s  — Final CTA + logo
Total: ~49s
```

**Scene types**: Logo → Problem → Features (3-5) → Social Proof → CTA
**Shader transition placement**: After Scene 1 (brand reveal), after Scene 5 (midpoint energy), before Scene 12 (CTA push)

[Source: Research findings Layer 4]

---

### Social Media Short (9:16, 10-15s)

**Scene structure**:
- 5-7 scenes
- First 3-5s: visual hook (no logo opener)
- Karaoke-style captions synced to TTS narration
- CTA: visual overlay with contrasting color + caption text

**Timing template (15s short)**:
```
Scene 1:  3.0s  — Hook (striking visual or action)
Scene 2:  2.5s  — Core claim
Scene 3:  3.0s  — Supporting point 1
Scene 4:  3.0s  — Supporting point 2
Scene 5:  3.5s  — CTA (overlay + caption)
Total: ~15s
```

**Caption rules for social**:
- Burn-in captions (not soft — most users watch without sound)
- Karaoke highlight: current word contrast-color or bold
- Max 3-4 words on screen at once for karaoke style
- Caption safe zone: avoid bottom 15% (platform UI overlap)

[Source: Research findings Layer 4]

---

### Tutorial / Explainer (16:9, variable duration)

**Duration formula**:
- Word count → scene duration (Text-Shot Duration Formula)
- 35+ words per scene → hard split into 2 scenes
- Total video = sum of scene durations + 2s intro + 2s outro

**Scene structure rules**:
- Every scene with text: apply 50% Reading Rule
- Mid-scene activity mandatory: SVG draw animation, chart fill, counter animate, code reveal
- No static slides — even text-only scenes need a persistent motion element

**Mid-scene activity options**:
- SVG path draw (stroke-dasharray reveal)
- Number counter animation
- Chart/graph fill animation
- Code text typewriter (word-by-word, not character-by-character)
- Subtle Ken Burns zoom on background image (max 2-3% scale shift per 4s)

[Source: Research findings Layer 2 + 4]

---

## Scene Structure Template

For any video type, build scenes with this structure:

```
[Scene N]
Duration:     [Xs — from shot duration formula]
Entry:        [Elements entering + entrance offset]
Mid:          [Ongoing motion — never static after entrance]
Exit:         [Hard cut ONLY — no exit animations except final scene]
Transition:   [Hard cut / Shader — per 95% hard cut rule]
```

**The "No Exit" principle**: Do not animate elements exiting a scene. The transition IS the exit. The only exception is the final scene fade-to-black or brand reveal hold.

[Source: Research findings Layer 2]

---

## Common Pacing Mistakes

### Uniform Shot Duration
**Mistake**: Every scene is the same duration (e.g., every scene is exactly 3s).  
**Problem**: Creates a mechanical, metronome feel. The brain stops noticing transitions.  
**Fix**: Vary duration by text density (Text-Shot Duration Formula) and by emotional intent. Feature highlights get longer; transitions get shorter.

---

### Leading with the Logo
**Mistake**: Opening the video with a static logo hold for 2-3 seconds.  
**Problem**: No visual hook → viewers drop off in the first 3 seconds, especially on social media.  
**Fix**:
- Social media: Lead with the hook visual first, logo appears in the last 2 seconds or as a watermark.
- Corporate/brand: Accept a short logo intro (max 1.5s) if brand requirement, then immediately cut to a strong visual.

---

### Overcrowding Shader Transitions
**Mistake**: Using a shader/cinematic transition every 3-4 scenes.  
**Problem**: Transitions draw attention to themselves rather than the content. Each one burns 0.5s and costs the viewer's attention.  
**Fix**: Maximum 2-3 shader transitions per 6-8 scene video. Reserve for hero moments only (brand reveal, CTA push).

---

### Ignoring the 50% Reading Rule on Text-Heavy Scenes
**Mistake**: A paragraph of text enters at 70-80% of the scene duration.  
**Problem**: Viewer has only 20-30% of scene time to read after entrance animation completes — not enough.  
**Fix**: Calculate: if text needs 4s to read, and entrance takes 0.5s, the scene must be at least (4s + 0.5s entrance) × 2 = 9s — but that exceeds the 5-Second Ceiling. Solution: split into two scenes.

---

### Static Mid-Scene (JPEG effect)
**Mistake**: Elements enter, then freeze for the rest of the scene.  
**Problem**: A static composition in a video context reads as a paused/broken playback.  
**Fix**: Every scene needs a persistence motion. See visual-design.md §Persistent Motion After Entrance for the full options list.

---

## Platform-Specific Hook Patterns

### YouTube (16:9, long-form)
- First 30 seconds: state the video's value proposition explicitly ("In this video you'll learn...")
- First 5 seconds: strong visual or statement — the "thumbnail moment"
- Pattern-interrupt at 30s and 60s to retain viewers past drop-off spikes

### TikTok / Instagram Reels (9:16, short-form)
- First 1-2 seconds: the most visually arresting frame of the video — or text hook
- Never start with a black frame or silent hold
- Talking-head style: face must appear in first 2 seconds
- Text hook works: large bold text that asks a question or makes a bold claim

### LinkedIn / Corporate (16:9)
- First 3 seconds: professional, brand-aligned — not "hook-bait"
- Problem statement in first 10 seconds is acceptable (audiences are engaged)
- Captions are critical (most LinkedIn video is watched without sound)

---

## Scene Transition Placement Guide

### Shader Transition Placement (for 12-scene videos)
**Recommended positions** for the 2-3 allowed shader transitions:
1. **After Scene 2** (after the hook/problem statement — entering the "solution" phase creates an energy shift)
2. **After Scene 7-8** (mid-video energy refresh — prevents monotony in longer videos)
3. **Before the last scene** (CTA push — signals "this is the moment")

### Hard Cut Best Practices
- Cut on motion: cut at the peak of a visual motion (element fully on screen) not mid-animation
- Match cut: if cutting between two scenes with similar visual elements, align them spatially
- Audio: ensure no audio bleed from one scene into the next (separate `<audio>` tags with timeline control)

---

## Narrative Arc for Video Types

### Product Demo Narrative Arc
```
Opening (Scene 1-2):   Problem / pain point — establish emotional stake
Build (Scene 3-6):     Feature introduction — building toward the solution
Proof (Scene 7-9):     Social proof, results, metrics — credibility
Resolution (Scene 10-12): CTA — clear next action
```

### Tutorial Narrative Arc
```
Opening (Scene 1):     "What you'll learn" — set expectations
Context (Scene 2-3):   Why this matters — motivation
Steps (Scene 4-N):     Each step as a scene — 50% reading rule throughout
Summary (Scene N+1):   Recap with key takeaways
CTA (Final):           Next tutorial, subscribe, related resource
```

### Social Short Narrative Arc
```
Hook (0-3s):           Visual or text hook — stop the scroll
Value (3-10s):         Core insight delivered immediately — no buildup
CTA (10-15s):          Single clear action — follow, click, try
```
