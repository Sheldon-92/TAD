# Video Creation Capability Pack — Research Findings

> Notebook: a62f253b-c31a-448e-abcc-10e98c3755bf (27 sources)
> Date: 2026-05-08
> 5 layers, 5 deep-ask questions

---

## Layer 1: Tool Landscape — HyperFrames vs Remotion

### Architecture Comparison

| Dimension | HyperFrames | Remotion |
|-----------|-------------|---------|
| Authoring | HTML + CSS + GSAP data-attributes | React TSX components |
| Build step | None (HTML plays as-is) | Bundler required |
| Code passthrough | Paste arbitrary HTML/CSS directly | Must translate to JSX |
| Animation | Frame Adapter pattern (GSAP, Lottie, Three.js) | Own primitives (spring(), interpolate()) |
| Rendering | Puppeteer + FFmpeg | Browser screenshots + compositor |
| AI-first design | Yes (explicit) | No (adapted) |

### AI Agent Efficiency Verdict
- **HyperFrames wins** for agent workflows: fewer syntax errors (no JSX translation), faster iteration (no build step), structural validity via pre-wired skeletons, non-interactive CLI
- **Remotion wins** for complex compositions requiring React ecosystem (state management, component reuse, distributed rendering)

---

## Layer 2: Video Design Principles — Codifiable Rules

### Pacing & Timing Rules

1. **3-5 Second Attention Rule**: Visually meaningful change every 3-5 seconds
2. **Text-Driven Shot Duration Formula**:
   - No text (hero image): 1.5-2s
   - 1-3 words (kicker): 2-3s
   - 4-10 words (headline): 3-4s
   - 11-20 words (sentence): 4-6s
   - 21-35 words (paragraph): 6-8s
   - 35+ words: MUST split across two scenes
3. **50% Reading Rule**: Last readable element must finish entrance animation by 50% of scene duration
4. **5-Second Scene Ceiling**: Hard max per scene (exceptions: counter animation, hero hold)
5. **95% Hard Cut Rule**: Only 2-3 shader transitions per 6-8 scene video

### Motion Design Rules

6. **Easing by Emotion** (GSAP curves):
   - Smooth: power2.out (0.4-0.6s)
   - Snappy: power4.out (0.2-0.3s)
   - Bouncy: back.out(1.6) (0.3-0.5s)
   - Dramatic: expo.out (0.3-0.5s)
   - Dreamy: sine.inOut (0.5-0.8s)
   - Mechanical: steps(5) (0.3-0.5s)
7. **3-Ease Minimum**: At least 3 different easing curves per scene
8. **Entrance Offset**: Never start at 0.0s — offset 0.1-0.3s into scene
9. **Transition Duration**: Min 0.3s, sweet spot 0.5s
10. **"No Exit" Rule**: Never use exit animations except final scene — transition IS the exit
11. **Staggering Default**: Always stagger multi-element entrances (non-staggered only for very large groups)

### Anti-Patterns

12. **"JPEG with Progress Bar"**: Every element must keep moving after entrance (slow Ken Burns zoom, breathing float, opacity pulse)
13. **Banned Effects**: No animated gradients, stretching typography, motion blur
14. **No Character-by-Character Text Animation** if it hurts legibility
15. **Loop Limit**: Looping animations must stop after 5s or 1 loop
16. **No Invisible Bridges**: No 0.01s flash-through-white padding between scenes

---

## Layer 3: AI Agent Video Failure Modes

### Timing & Determinism Errors
- `Date.now()`, `Math.random()`, `setInterval` break deterministic rendering
- `repeat: -1` hangs engine (120s timeout)
- `async/await`, Promises, `setTimeout` break synchronous timeline capture
- Hardcoded frame math instead of centralized config (Remotion)
- Overlay timecodes extending past video total duration

### Animation Mistakes
- `visibility`/`display` not tweeable — must use `autoAlpha`
- Inline `opacity: 0` causes permanent invisibility during WebGL resets — use `tl.set()` toggle
- `gsap.set()` on future elements fails (DOM not loaded) — use `tl.set()` inside timeline
- Exit tween before shader transition = blinking
- Direct `<video>` tag animation — must animate wrapper `<div>`
- Manual `video.play()`/`audio.play()` — let framework own playback

### Composition Errors
- SVG filter grain via `data:image/svg+xml` taints html2canvas, breaks WebGL shaders
- `<br>` tags inside text = broken natural text wrap
- Missing `staticFile()` (Remotion) = asset path failures
- Missing `useMemo` = out-of-memory on render

### Prevention Patterns
1. **Skill Loading**: Use `/hyperframes` or Remotion skill, never general coding knowledge
2. **CLAUDE.md / DESIGN.md**: Brand colors, typography, styling rules — prevents AI aesthetics hallucination
3. **Pre-Validated Skeletons**: Templates that already pass linting
4. **CLI Validation Loop**: `npx hyperframes lint` + `validate` + `inspect` before render
5. **Sequential Skill Chaining**: generate-motion-graphic → add-overlay → sync-captions → composite

---

## Layer 4: Video Type Templates

### Product Demo (16:9, 30-60s)
- 10-18 scenes, 95% hard cuts
- 2-3 shader transitions (hero reveal, energy shift, CTA)
- 12-scene timing rhythm: 3.0, 3.0, 4.0, 3.5, 4.0, 5.0, 3.5, 4.0, 3.5, 4.0, 4.0, 3.5

### Social Media Short (9:16, 10-15s)
- 5-7 scenes
- Hook in first 3-5 seconds (visual hook or immediate transition)
- Talking-head + bouncy karaoke captions + TTS narration
- CTA: visual overlay with contrasting color + in-caption text

### Tutorial/Explainer
- Word count drives duration (11-20 words = 4-6s, 21-35 words = 6-8s)
- 35+ words = hard split into 2 scenes
- 50% reading time rule
- Mid-scene activity mandatory (SVG draw, chart fill, counter animate)

---

## Layer 5: Quality & Production

### Audio Design
- Background music at 10-20% volume relative to voiceover
- FFmpeg `amix` for mixing; `sidechaincompress` for ducking
- Audio in separate `<audio>` tags, not attached to video tags
- Caption "leak" prevention: hard kill command after every caption group exit

### TTS Integration
- Never use `.en` Whisper models on non-English audio
- Install `espeak-ng` for non-English phonemization
- Locale auto-inferred from Voice ID

### Export Settings
- Codec: H.264 (MP4) for universal compatibility, WebM for web-optimized
- Audio: AAC 128kbps+
- Quality: CRF 18-23 (18 = high quality, Remotion default)
- Minimum bitrate for Twitter/X: 5000 kbps
- Resolution: 1080p or 1440p
- Web optimization: `-movflags +faststart` (always)

---

## Key Insights for Pack Design

1. **HyperFrames-first, Remotion-aware**: Pack should default to HyperFrames patterns (HTML-native, agent-friendly) with Remotion escape hatch for complex React compositions
2. **Rules are quantifiable**: Unlike web-ui-design where rules are aesthetic judgments, video rules are timing-precise (3-5s attention, 0.3s min transition, CRF 18-23) — can be parameterized
3. **Failure modes are deterministic**: Most agent failures come from using web patterns in video context (Date.now, async, visibility). A checklist prevents 80% of failures
4. **Video types share core rules**: The 95% hard cut rule, 3-5s attention rule, and easing-by-emotion mapping apply across ALL video types. Type-specific patterns are timing templates on top of universal rules
5. **Audio is partially filled**: BPM-to-video-type mapping obtained; SFX timing rules remain sparse (only "10-20ms pre-lead" from web search, notebook sources confirmed gap)
6. **Accessibility is a must-include**: 99% caption accuracy, 4.5:1 contrast, WebVTT format, speaker ID + sound effects + music cues required

---

## Supplementary Research (Gap-Filling Round)

### BPM-to-Video-Type Mapping

| Video Type | BPM Range | Instrumentation |
|-----------|-----------|-----------------|
| Product Demo (high energy) | 130-200 | Upbeat electronic, driving synth basslines |
| Social Media Short | 110-130 | Medium-fast, lifestyle-oriented |
| Tutorial / Explainer | No strict BPM | Consistent rhythm, organic instruments (acoustic guitar), NO vocals |
| Corporate | 100-130 | Pop range, balanced energy |
| Emotional / Storytelling | 20-80 | Ambient to full orchestra, sustained synths |

**Critical Rule**: For dialogue videos, strictly avoid vocals and voice-like lead instruments (trumpet, piano lead, lead guitar) — they compete with voiceover.

### Sound Effect Timing (Partial — WebSearch-derived)
- Whoosh pre-lead: start sound 10-20ms BEFORE visual transition (brain processes audio faster)
- Fast whoosh → quick cuts/snappy transitions; Slow whoosh → dramatic reveals/anticipation
- Frequency separation for overlapping: sharp in highs, sweeps in mids, rumbles in lows
- Visual event → SFX type mapping:
  - Object appearing → pop/rise
  - Object colliding/hitting → impact/boom
  - Slide/transition → whoosh
  - UI interaction → click/mechanical
  - Direction change → sweep
- Looping animation SFX must stop after 5s or 1 loop (accessibility)

### Accessibility Requirements (WCAG)
1. Caption accuracy: ≥99% (auto-generated typically 85-95% — human review required)
2. Captions ≠ subtitles: captions include speaker ID, sound effects, music cues
3. Required caption elements: `[Speaker:]`, `[sound effect]`, `[music: mood]`
4. Format: WebVTT (.vtt) preferred for web (CSS styleable); SRT for universal compat
5. Soft captions (toggleable) for web; burn-in for social media
6. Text contrast: 4.5:1 minimum for standard text, 3:1 for large text
