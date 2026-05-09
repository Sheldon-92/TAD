# Visual Design Reference

> Source: Research notebook a62f253b (27 sources), Layer 2 (Q2.2 motion design deep ask)

---

## GSAP Easing-by-Emotion Table

Choose easing by the **emotional intent** of the element, not by aesthetics.

| Emotion | GSAP Curve | Duration Range | Use Case |
|---------|-----------|---------------|----------|
| Smooth / professional | `power2.out` | 0.4–0.6s | Text reveals, product screenshots, data callouts |
| Snappy / confident | `power4.out` | 0.2–0.3s | Labels, tags, metric numbers, CTA buttons |
| Bouncy / playful | `back.out(1.6)` | 0.3–0.5s | Icons, illustrations, notification badges |
| Dramatic / cinematic | `expo.out` | 0.3–0.5s | Hero elements, brand reveals, section openers |
| Dreamy / emotional | `sine.inOut` | 0.5–0.8s | Testimonials, emotional beats, slow reveals |
| Mechanical / technical | `steps(5)` | 0.3–0.5s | Code reveals, terminal output, progress bars |

**Decision process**:
1. What emotion should the viewer feel when this element appears?
2. Select the matching curve.
3. Confirm the duration is within range.
4. Apply to the entrance `from` tween.

[Source: Research findings Layer 2]

---

## Motion Rules

### 3-Ease Minimum Rule
**Rule**: Every scene must use at least 3 different easing curves.

**Why**: Single-easing scenes feel robotic. Easing variety creates visual rhythm and hierarchy — important elements get dramatic easing, supporting elements get smooth/snappy.

**Implementation**: Map elements to roles (hero, supporting, label), assign easing by role.

```
Hero element:   expo.out  (dramatic entrance)
Body text:      power2.out (smooth, readable)
Labels/tags:    power4.out (snappy, efficient)
```

[Source: Research findings Layer 2]

---

### Entrance Offset Rule
**Rule**: No element should enter at exactly 0.0s into the scene. Minimum offset: 0.1s. Typical offset: 0.1–0.3s.

**Why**: Simultaneous entrance of all elements collapses visual hierarchy. Offset creates a reading sequence.

**Staggering for multi-element groups**:
```
Element 1: delay=0.1s
Element 2: delay=0.2s
Element 3: delay=0.3s
```
Default stagger increment: 0.1s per element.

**Non-staggered exception**: Very large groups (20+ elements) where individual stagger would exceed scene ceiling — use a single group entrance with shared delay of 0.1–0.2s.

[Source: Research findings Layer 2]

---

### Transition Duration
**Rule**:
- **Minimum**: 0.3s (below this, transitions feel like cuts — use a hard cut instead)
- **Sweet spot**: 0.5s (fast enough to feel decisive, slow enough to register)
- **Maximum for non-cinematic transitions**: 0.8s

**For shader/cinematic transitions**: 0.4–0.8s (see storytelling.md §95% Hard Cut Rule for frequency limits)

[Source: Research findings Layer 2]

---

### The "No Exit" Rule
**Rule**: Do not animate elements exiting a scene. Exceptions: final scene only.

**Implementation**: Set up a hard cut at scene end. The next scene's entrance IS the visual exit of the previous scene's content.

**Final scene**: A brand/logo hold or fade-to-black (0.5s) is acceptable.

[Source: Research findings Layer 2]

---

### Staggering Default
**Rule**: Always stagger multi-element entrances unless the group is exceptionally large (20+ elements).

**Why**: Non-staggered group entrance (all elements at same delay) reads as a single "pop" and loses hierarchy information.

**Pattern**:
```javascript
// GSAP stagger example
gsap.from(".feature-item", {
  opacity: 0,
  y: 20,
  duration: 0.4,
  ease: "power2.out",
  stagger: 0.1,
  delay: 0.2  // entrance offset from scene start
})
```

[Source: Research findings Layer 2]

---

### Persistent Motion After Entrance
**Rule**: Elements must continue moving after entrance animation completes. Static elements in a video context read as a JPEG.

**Minimum persistence animations** (choose one per element):
- **Ken Burns zoom**: Slow scale shift 1.00 → 1.02 over 4s (2% max shift)
- **Breathing float**: translateY oscillation ±3px over 3s, `sine.inOut`
- **Opacity pulse**: 0.9 → 1.0 over 2s, `sine.inOut` (subtle, for background elements)
- **Continuous motion graphic**: SVG path, chart fill, counter — already inherently dynamic

[Source: Research findings Layer 2]

---

## Anti-Patterns

### "JPEG with Progress Bar"
**Pattern**: Element enters with animation, then freezes completely for the rest of the scene.  
**Why it fails**: The brain interprets a static composition as a paused video or a broken animation.  
**Fix**: Add a persistence animation (see Persistent Motion After Entrance above).

---

### Banned Visual Effects
Do not use the following in any production video:

| Effect | Why Banned |
|--------|-----------|
| Animated gradients | CPU-intensive, seizure risk, distracting from content |
| Typography stretching | Breaks brand guidelines, looks amateur |
| Motion blur | Reduces readability; renders poorly at standard framerates |
| Character-by-character text animation | Acceptable only if legibility is preserved; banned when letters are read individually |
| Invisible bridges | 0.01s flash-through-white between scenes — causes flicker, looks like encoding error |

---

### Loop Limit Rule
**Rule**: Any looping animation (e.g., `repeat: -1`) must be capped:
- **Stop after 5s** OR **after 1 complete loop** (whichever is shorter)
- Accessibility: Screen readers interpret infinite loops as content still loading

**Implementation**: `repeat: 0` + manually re-trigger if needed. Never use `repeat: -1` in production render — it causes 120s engine timeout in HyperFrames/Remotion render pipelines.

[Source: Research findings Layer 2 + 3]

---

### No Invisible Bridges
**Pattern**: Inserting a 0.01s white/black frame as a "buffer" between scenes.  
**Why it fails**: Causes visible flicker in encoded video. Hard cuts are frame-accurate — no buffer needed.  
**Fix**: Use direct hard cuts. Scene A ends at frame N; Scene B starts at frame N+1.

---

## Color and Typography for Video

### Contrast Requirements
- **Standard text**: minimum 4.5:1 contrast ratio (WCAG AA)
- **Large text** (≥24px or ≥18px bold): minimum 3:1
- **Text over video/motion background**: test at 3 representative frames, not just a static screenshot

### Typography Motion Rules
- Serif fonts: use `power2.out` or `sine.inOut` (elegant, slower)
- Sans-serif fonts: use `power4.out` or `expo.out` (clean, faster)
- Monospace/code: use `steps(5)` (mechanical, matches the content type)
- Maximum font animation: scale from 0.95 → 1.0 (subtle) or from 0 opacity. Never animate font-size directly (reflow = jank).

### Video-Safe Color Range
For broadcast or platform-encoded video, ensure luminance stays in video-safe range (16-235 on 8-bit scale). Full-range (0-255) may clip on TVs. For web-only delivery, full range is acceptable.

---

## Composition Principles

### Visual Hierarchy in Motion
Priority order for element entrance timing:
1. **Hero**: enters first, dramatic easing, largest motion
2. **Headline/primary text**: enters 0.1-0.2s after hero
3. **Supporting text**: enters 0.2-0.3s after headline
4. **Labels/tags/badges**: enter last, snappiest easing

### Safe Zones
- **Action safe**: 10% margin from all edges (critical content must stay within)
- **Title safe**: 5% margin (all text must stay within)
- **Social media overlay zone**: bottom 15% often covered by platform UI — reserve for CTA only

---

## Advanced Motion Patterns

### Layered Entrance Choreography
For multi-element scenes, choreograph entrances in 3 layers:

**Layer 1 — Background** (0.1s offset):
- Large decorative shapes, gradients, abstract elements
- Easing: `sine.inOut` (slow, non-distracting)
- Duration: 0.6–0.8s

**Layer 2 — Primary Content** (0.3s offset):
- Main hero image, product shot, core graphic
- Easing: `expo.out` (dramatic) or `power2.out` (clean)
- Duration: 0.4–0.6s

**Layer 3 — Text / Labels** (0.5s offset):
- Headline, subhead, data callouts
- Easing: `power4.out` (snappy) for short text; `power2.out` for longer reads
- Duration: 0.2–0.4s

**Why**: This sequence ensures the viewer's eye follows: environment → subject → information. Matching human visual scanning pattern.

---

### Motion Direction Principles

**Inward/upward motion signals arrival**: Elements entering from outside the frame toward center signal importance. Use `from: { x: 30, opacity: 0 }` or `from: { y: 20, opacity: 0 }`.

**Downward motion signals conclusion**: Final elements (closing stats, CTA) can enter from slightly above. Creates a sense of settling/landing.

**Consistent direction within a scene**: All elements in a scene should enter from the same direction or perpendicular directions. Mixed entry directions (some from left, some from right, some from bottom) create visual noise.

**Directional momentum for cuts**: If the last element in Scene A is moving right, Scene B's first element should also enter from the right (continuation) OR be completely static (contrast). Avoid reversals without a hard cut.

---

### Micro-Animation Patterns

**Number counters**:
```javascript
// Counting up to a target value
{ from: { innerText: 0 }, to: { innerText: targetNumber }, duration: 1.5,
  ease: "power2.out", snap: { innerText: 1 } }
```
- Always use snap for integer values
- Duration: 1.0–2.0s depending on magnitude
- Pair with a scale bounce at the end: `power2.out` 1.0 → 1.05 → 1.0

**SVG path draw**:
```javascript
// Reveal SVG drawing (stroke-dasharray technique)
gsap.set("path", { strokeDasharray: totalLength, strokeDashoffset: totalLength })
gsap.to("path", { strokeDashoffset: 0, duration: 1.2, ease: "power2.inOut" })
```

**Progress bars / chart fills**:
- Animate `width` or `scaleX` from 0 → target
- Ease: `power2.out` for straightforward fill; `elastic.out(1, 0.5)` for a bouncy finish
- Never animate simultaneously with text — stagger the text entrance 0.2s before fill completes

---

### Easing Selection Decision Tree

```
What is the element's role?
├── Primary hero / brand reveal → expo.out
├── Product screenshot / data viz → power2.out
├── Metric / number callout → power4.out
├── Icon / illustration / badge → back.out(1.6)
├── Testimonial / emotional text → sine.inOut
└── Code / terminal / technical → steps(5)

How fast should it feel?
├── Needs to feel quick/decisive → duration 0.2-0.3s
├── Standard professional → duration 0.4-0.6s
└── Deliberate / cinematic → duration 0.5-0.8s
```

---

## Color Usage in Video Context

### Video-Safe Color Guidelines

**High contrast for legibility**:
- Text on solid background: minimum 4.5:1 contrast ratio (WCAG AA)
- Text over video/motion background: test at multiple frames — background luminance changes
- Use a semi-transparent background panel (70-85% opacity) behind text over complex backgrounds

**Saturation management**:
- Highly saturated colors (HSL: 80%+ saturation) can bleed/bloom in video encoding
- Safe saturation range for video: 60-75% for primary colors
- Test with `-pix_fmt yuv420p` encoding — some hues shift under chroma subsampling

**Color temperature consistency**:
- Mixing warm and cool tones across scenes creates unintentional brand inconsistency
- Set a base white point for the video and stay within ±500K across all scenes

### Brand Color to Video Safe Conversion
If a brand color fails video safe range:
1. Check luminance: keep between 16-235 in 8-bit video (0 = pure black, 255 = pure white)
2. Reduce saturation by 10-15% while keeping hue identical
3. Test in FFmpeg: `ffmpeg -i test.mp4 -vf signalstats -f null -` — check luma_max/luma_min

---

## Typography in Motion

### Font Rendering for Video
- **Avoid system fonts** (Arial, Helvetica) in final output — rendering varies by OS during Puppeteer/headless capture
- **Use web-loaded fonts** (Google Fonts via `@import`, or local file via `@font-face`) — consistent cross-platform rendering
- **Minimum font size**: 24px for body text at 1080p (below this, subpixel rendering smears in h.264 compression)

### Safe Text Sizes by Resolution
| Content Type | Min Size @ 1080p | Min Size @ 720p |
|-------------|-----------------|-----------------|
| Body / supporting text | 24px | 20px |
| Headline | 40px | 32px |
| Title / hero text | 64px+ | 48px+ |
| Labels / tags | 18px | 16px (minimum) |

### Animation-Safe Typography Rules
- Never animate `font-size` — causes layout reflow → jank
- Never animate `letter-spacing` — visual rhythm breaks during transition
- Safe to animate: `opacity`, `transform` (translateX/Y, scale), `color` (gradually)
- For text reveals: use `clipPath` or `overflow: hidden` container rather than character-by-character opacity

### Text Contrast for Motion Backgrounds
Motion backgrounds (video loops, animated gradients) have variable luminance. Ensure text is readable at:
- **Brightest frame**: text still meets 4.5:1
- **Darkest frame**: text still meets 4.5:1
- **Average frame**: text ideally exceeds 7:1 (AAA)

If these can't be met simultaneously, add a background panel (see Color Usage above).
