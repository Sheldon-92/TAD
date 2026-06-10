# Production Reference

> Source: Research notebook a62f253b (27 sources), Layer 3

---

## Agent Failure Modes Checklist (17 Items)

Run this checklist before every render. Each item represents a class of failure observed in AI-agent video production.

### Category 1: Timing & Determinism Errors

These cause non-deterministic renders — frames look different each time, or the render hangs.

| # | Failure Mode | Detection | Fix |
|---|-------------|-----------|-----|
| 1 | `Date.now()` in timeline | Search for `Date.now` | Use frame index / scene timestamp from framework |
| 2 | `Math.random()` in animation | Search for `Math.random` | Seed randomness to a constant, or use pre-computed values |
| 3 | `setInterval` / `setTimeout` | Search for `setInterval`, `setTimeout` | Remove — use framework timeline only |
| 4 | `repeat: -1` (infinite loop) | Search for `repeat.*-1\|repeat:\s*-1` | Use `repeat: 0` + manual re-trigger |
| 5 | `async/await`, `Promises` in timeline | Search for `async\|await\|\.then\(` in timeline scope | Move async to data-prep phase before render |
| 6 | Hardcoded frame math | Search for `fps \*\|/ fps\|frame \+\|-` literals | Use `durationInFrames`, `fps` from framework config |
| 7 | Overlay timecode past total duration | Check all overlays' `end` times vs `totalDuration` | Clamp overlay exit to `totalDuration - 0.1s` |

### Category 2: Animation Mistakes

These cause elements to be invisible, frozen, or to blink.

| # | Failure Mode | Detection | Fix |
|---|-------------|-----------|-----|
| 8 | `visibility` / `display` used as tween target | Search for `to.*visibility\|from.*display` | Replace with `autoAlpha` (GSAP handles opacity+visibility atomically) |
| 9 | Inline `opacity: 0` on elements | Search for `style="opacity: 0"\|opacity:0` in HTML | Use `tl.set(el, {autoAlpha: 0})` inside the GSAP timeline instead |
| 10 | `gsap.set()` on elements before DOM load | Manual review: find `gsap.set(` calls at module/script top level (outside DOMContentLoaded or timeline context) — cannot be reliably detected with grep alone | Move to `tl.set()` inside timeline after DOM elements exist |
| 11 | Exit tween before shader transition | Search for `to.*opacity.*0\|to.*x.*-\d\d\d` before transition | Remove exit tweens — hard cut IS the exit (see storytelling.md §No Exit Rule) |
| 12 | Direct `<video>` tag animation | Search for `gsap.*video\|tl.*video` | Animate wrapper `<div>` instead |
| 13 | Manual `video.play()` / `audio.play()` | Search for `\.play\(\)` | Remove — let framework own playback; attach audio via framework audio API |

### Category 3: Composition Errors

These cause rendering failures, blank frames, or memory crashes.

| # | Failure Mode | Detection | Fix |
|---|-------------|-----------|-----|
| 14 | SVG filter grain via `data:image/svg+xml` | Search for `data:image/svg\+xml.*filter` | Replace with external `.svg` file; inline data URIs taint `html2canvas` and break WebGL shaders |
| 15 | `<br>` tags inside text elements | Search for `<br` inside text containers | Remove `<br>` — use CSS `white-space: pre-line` or `<p>` tags |
| 16 | Missing `staticFile()` in Remotion | Search for `src="` in Remotion components (not using `staticFile`) | Replace all static asset references with `staticFile("path")` |
| 17 | Missing `useMemo` on heavy computations in Remotion | Review computation-heavy components | Wrap array operations, complex calculations in `useMemo` |

---

## Prevention Patterns (5 Items)

### 1. Use Agent Skill (Not General Coding Knowledge)
**Pattern**: Load the HyperFrames or Remotion skill file at the start of every video task.  
**Why**: General coding agents default to web patterns — `Date.now()`, `async/await`, inline styles — that break deterministic rendering.  
**Implementation**: Explicitly load `hyperframes` skill or reference `remotion.dev/docs/ai/coding-agents` before generating composition code.

### 2. Maintain DESIGN.md / Brand Context File
**Pattern**: Keep a `DESIGN.md` (or equivalent) with brand colors, typography, and visual rules.  
**Why**: Without explicit brand context, AI agents default to generic palettes and fonts ("AI aesthetic" — Inter/Roboto + purple gradient). DESIGN.md is the explicit override.  
**Contents**: Brand hex colors, font names + weights, logo file paths, safe zone rules, primary motion direction.

### 3. Pre-Validated Skeletons
**Pattern**: Start every composition from a skeleton that already passes `npx hyperframes lint`.  
**Why**: Skeletons enforce correct structure (audio separation, frame config, scene container pattern) before the agent writes any content.  
**Source**: HyperFrames provides starter skeletons (`npx hyperframes init`).

### 4. CLI Validation Loop
**Pattern**: Run validation commands after every significant change — do not save validation for the final render.

```bash
# HyperFrames validation sequence
npx hyperframes lint ./scenes/      # structural validation
npx hyperframes validate ./video.json  # composition validation
npx hyperframes inspect ./video.json   # timing inspection (scene durations, overlap check)
# Only after all 3 pass:
npx hyperframes render ./video.json --output ./output.mp4
```

**Why**: Render is expensive (CPU + time). Validate cheaply first.

### 5. Sequential Skill Chaining
**Pattern**: Break complex video into sequential skill invocations, not a single "make a video" prompt.

```
Step 1: generate-motion-graphic  → individual scene compositions
Step 2: add-overlay              → captions, lower thirds, CTA elements
Step 3: sync-captions            → TTS generation + caption alignment
Step 4: composite                → FFmpeg final mix (video + audio + captions)
```

**Why**: Each step has clear inputs/outputs. An error in step 2 doesn't require re-running step 1. Skills stay focused.

---

## Render Pipeline

Full pipeline for a production render:

```
1. scaffold     → npx hyperframes init (or Remotion: npx create-video)
2. compose      → write scene files using DESIGN.md context
3. preview      → npx hyperframes preview (or Remotion Studio)
4. validate     → npx hyperframes lint + validate + inspect
5. render       → npx hyperframes render --output video.mp4
6. export       → ffmpeg -i video.mp4 [platform flags] output_final.mp4
```

**Between steps 4 and 5**: Run the Agent Failure Modes Checklist (17 items above).  
**Between steps 5 and 6**: Apply platform export settings from quality.md.

---

## HyperFrames-Specific Patterns

### Frame Adapter Pattern
HyperFrames uses Frame Adapters to integrate animation libraries:
- **GSAP Adapter**: `data-hf-gsap` attribute — connects GSAP timeline to HyperFrames frame clock
- **Lottie Adapter**: `data-hf-lottie` — syncs Lottie animations to frame position
- **Three.js Adapter**: `data-hf-three` — renders 3D scenes per frame

**Critical**: Never call `gsap.play()` or control GSAP playhead manually. The Frame Adapter owns playback control.

---

## Remotion-Specific Patterns

### Frame-Based Timing
In Remotion, all timing is in frames, not seconds:
```typescript
// Wrong (seconds)
const startTime = 3; // in seconds

// Correct (frames)
const { fps } = useVideoConfig();
const startFrame = 3 * fps; // convert seconds to frames
```

### Sequence and Series
Use `<Sequence>` for temporal composition (parallel), `<Series>` for sequential scenes:
```typescript
// Parallel
<Sequence from={0} durationInFrames={90}>
  <SceneA />
</Sequence>
<Sequence from={90} durationInFrames={90}>
  <SceneB />
</Sequence>

// Sequential (automatic offset)
<Series>
  <Series.Sequence durationInFrames={90}><SceneA /></Series.Sequence>
  <Series.Sequence durationInFrames={90}><SceneB /></Series.Sequence>
</Series>
```

---

## Extended Agent Failure Mode Details

### Failure Mode Deep-Dive: `repeat: -1` (Item 4)

This is the most dangerous failure mode because it seems harmless in browser preview.

**What happens**: A GSAP animation set to `repeat: -1` creates an infinite loop. HyperFrames and Remotion render by capturing frames at specified positions. When the render engine seeks to a frame INSIDE an infinite loop, the seek operation either (a) hangs until timeout (120s in HyperFrames default), or (b) returns the wrong frame position.

**Detection**: `grep -rn "repeat.*-1\|repeat: -1" ./scenes/`

**Fix pattern**:
```javascript
// Wrong
gsap.to(".icon", { rotation: 360, repeat: -1, duration: 2 })

// Correct — calculate exact repetitions needed for video duration
const videoSeconds = 30; // your video length
const animDuration = 2;  // single rotation duration
const repeatCount = Math.floor(videoSeconds / animDuration);
gsap.to(".icon", { rotation: 360, repeat: repeatCount, duration: animDuration })
```

---

### Failure Mode Deep-Dive: `visibility` vs `autoAlpha` (Item 8)

**What happens**: GSAP cannot tween `visibility: hidden` to `visibility: visible` — these are discrete states (on/off), not numeric ranges. If you try to fade in an element set to `visibility: hidden`, GSAP tweens the opacity but the element remains invisible because `visibility` is never changed.

`autoAlpha` is GSAP's combined property: it tweens `opacity` AND sets `visibility: hidden` when opacity reaches 0, `visibility: visible` when opacity > 0. This is the correct pattern.

```javascript
// Wrong
gsap.from(".element", { visibility: "hidden", opacity: 0 })

// Correct
gsap.from(".element", { autoAlpha: 0 })
// This sets visibility:hidden at opacity=0, automatically transitions to visibility:visible
```

---

### Failure Mode Deep-Dive: Canvas Taint (Item 14)

**What happens**: `html2canvas` (used in HyperFrames rendering for some shader compositions) is blocked by CORS when it encounters certain SVG content. Specifically, SVG filters embedded as `data:image/svg+xml` URI — even those that create simple grain/noise effects — can taint the canvas. Once tainted, `html2canvas` throws a security exception and WebGL shaders on that canvas fail silently, producing a blank frame.

**Why it seems to work locally but fails in production**: The local development server may serve all assets from the same origin (no CORS). The render pipeline may use a different origin configuration that triggers the CORS check.

**Fix**: Serve the SVG grain filter as a separate file (e.g., `./filters/grain.svg`) and reference it via a relative URL with CORS headers. Never embed SVG filters as inline data URIs in compositions that use `html2canvas` or WebGL shaders.

---

## Production Debugging Checklist

When a composition renders blank, glitches, or hangs:

### Step 1: Isolate the Scene
Render only the problematic scene (set `durationInFrames` to just that scene's frames). If the isolated render works, the issue is an inter-scene timing conflict.

### Step 2: Check the Failure Modes Checklist
Run through all 17 items. The checklist catches 80% of failures systematically.

### Step 3: Inspect the Timeline
```bash
npx hyperframes inspect ./video.json
```
This outputs: scene durations, element entry times, audio track positions, and any overlap conflicts. Review for:
- Overlay timecodes extending past `totalDuration`
- Negative `delay` values (elements scheduled before scene start)
- Audio tracks with duration > video duration

### Step 4: Check Console Output
During `npx hyperframes preview`, open the browser console. Look for:
- `CanvasRenderingContext2D is not available` — html2canvas blockage (Failure Mode 14)
- `SecurityError: The operation is insecure` — canvas taint
- `Cannot read property of undefined` — `gsap.set()` called before DOM ready (Failure Mode 10)

### Step 5: Render at Low Quality First
```bash
npx hyperframes render ./video.json --quality low --output ./debug.mp4
```
Low quality renders 10-20× faster. If the low-quality render shows the issue, you've confirmed it's not an encoding artifact.

---

## Version Control for Video Projects

### What to Commit
```
✅ Commit: scene files (*.json, *.html, *.ts), assets (./public/), config (*.config.*)
✅ Commit: DESIGN.md and brand assets
❌ Do not commit: render output (*.mp4, *.webm) — large binary files
❌ Do not commit: node_modules/ — reproducible via npm install
```

### .gitignore for Video Projects
```gitignore
# Render output
out/
*.mp4
*.webm
*.gif
*.mov

# Dependencies
node_modules/

# Build artifacts
.next/
dist/
build/

# Temporary render files
/tmp-render/
*.tmp
```

### Tagging Render Milestones
```bash
git tag -a v0.1.0-render -m "Approved render: product demo v1"
git push origin v0.1.0-render
```
Tagging lets you return to the exact scene files that produced an approved render.
