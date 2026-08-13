# Tool Selection Reference

> Source: Research notebook a62f253b (27 sources), Layer 1
> Note: Motion Canvas and Manim entries are [Source: WebSearch — not in notebook]

---

## Decision Tree

Use this decision tree to select the right tool before writing any code.

```
Need to produce a video? →

  Do you need to GENERATE visual assets first?
  (no existing images/video clips — need AI to create them from scratch)
    YES → See references/ai-asset-generation.md
    NO  ↓ (you already have assets)

  Is it pure video processing?
  (trim, concat, encode, add audio, extract frames)
    YES → FFmpeg (no composition layer needed)
    NO  ↓

  Does the composition use React components or state?
  (useState, useEffect, data-driven components, distributed rendering)
    YES → Remotion
    NO  ↓

  Is it primarily math animations or academic visualizations?
  (geometry proofs, calculus, physics simulations)
    YES → Motion Canvas or Manim [Source: WebSearch — not in notebook]
    NO  ↓

  → HyperFrames (default for HTML/CSS/GSAP compositions)
```

**Default choice**: HyperFrames — it is the AI-first tool. Only diverge when the decision tree points elsewhere.

---

## Tool Comparison

### HyperFrames

**When HyperFrames wins**:
- Agent is writing HTML/CSS/GSAP (no JSX translation needed)
- Rapid iteration — no build step means instant preview
- Agent-generated code is HTML-passthrough (paste arbitrary HTML/CSS directly)
- Single-agent, non-collaborative workflow
- Simpler compositions (product demos, social shorts, explainers)

**When HyperFrames loses**:
- Composition requires complex React state management
- Distributed rendering (parallel rendering across machines)
- Team is already in a React ecosystem with shared component libraries
- Need Remotion-specific features (Player, Studio, Lambda renderer)

**Key characteristics** (re-verified 2026-06-13 — heygen-com/hyperframes, v0.6.97, ~21.9k stars):
- Authoring: HTML-native — `index.html` with `data-start` / `data-duration` attributes; HTML-passthrough (paste arbitrary HTML/CSS)
- Build step: None — HTML plays as-is
- Runtimes supported: **GSAP, Lottie, Three.js, Anime.js, WAAPI**
- AI advantage: Pre-wired skeletons + broad agent detection (Claude Code, Cursor, Windsurf, Cline, Gemini CLI, Crush)
- Rendering: **headless Chrome seeks each frame → FFmpeg encodes → deterministic MP4** (the per-frame seek is why Date.now/Math.random/setInterval break — see references/visual-design.md §Anti-Patterns)
- Export paths: MP4 (default); **native animated-GIF via two-pass palette encoding (v0.6.97, 2026-06-11)** — see references/quality.md §GIF Export
- Tooling: GSAP-aware razor/blade timeline split tool for cutting clips on the timeline

**Pin**: `npx hyperframes@0.6.97` (verified current 2026-06-13). Node.js ≥22 required.

**Documentation**: `hyperframes.mintlify.app/quickstart`

[Source: Research findings Layer 1 + heygen-com/hyperframes releases, retrieved 2026-06-13]

---

### Remotion

**When Remotion wins**:
- Complex compositions requiring React component reuse
- State-driven animations (data fetching, dynamic content)
- Team has React expertise and existing component library
- Need distributed rendering (Remotion Lambda)
- Headless video generation pipeline with custom React logic

**When Remotion loses**:
- Agent lacks React/JSX fluency (JSX translation errors = #1 Remotion agent failure)
- Simple composition that doesn't need component state
- Rapid prototyping (build step adds friction)
- Agent is more comfortable with HTML/CSS

**Key characteristics**:
- Authoring: React TSX components
- Build step: Bundler required
- Animation: Own primitives (`spring()`, `interpolate()`, `useCurrentFrame()`)
- Rendering: Browser screenshots + compositor; `renderMedia()` exposes `--concurrency` / `--jpeg-quality` / `--crf` tuning (see references/quality.md §Remotion renderMedia Tuning Knobs). Note: v4.0 renamed the old `parallelism` param to **`concurrency`** in both `renderMedia()` and `renderFrames()`.

**Pin**: `remotion@4.0.477` (latest stable, verified 2026-06-14 — supersedes the earlier 4.0.447). Node.js ≥22 required.

**Documentation**: `remotion.dev/docs/ai/coding-agents`

[Source: Research findings Layer 1 + https://www.npmjs.com/package/remotion + https://www.remotion.dev/docs/4-0-migration, retrieved 2026-06-14]

---

### FFmpeg

**When FFmpeg wins**:
- Pure processing: trim, concatenate, encode, transcode
- Adding audio track to a rendered video
- Converting formats (MP4 → WebM, etc.)
- Extracting frames or thumbnails
- Batch processing a directory of clips

**When FFmpeg loses**:
- Creating original compositions (use HyperFrames or Remotion for that)
- Anything requiring a timeline or animation authoring

**Common patterns**:
```bash
# Encode with quality target
ffmpeg -i input.mp4 -crf 20 -preset fast output.mp4

# Add audio to silent video
ffmpeg -i video.mp4 -i audio.mp3 -c:v copy -c:a aac -shortest output.mp4

# Mix voiceover + music
ffmpeg -i voiceover.mp3 -i music.mp3 \
  -filter_complex "[1:a]volume=0.15[m];[0:a][m]amix=inputs=2:duration=first" \
  mixed.mp3
```

**Documentation**: `ffmpeg.org/ffmpeg.html`

---

### Motion Canvas / Manim

> [Source: WebSearch — not in notebook] The following is derived from supplementary research, not verified by the primary notebook sources.

**Motion Canvas**: TypeScript-native animation framework for programmatic animations. Strong for geometric/abstract visualizations, code walkthroughs, and technical diagrams.

**Manim**: Python-based mathematical animation library. Designed for academic math visualizations — geometry, calculus, algorithms. Steep learning curve but precise control.

**Use when**: The composition is primarily mathematical or abstract, and HyperFrames/Remotion would require significant workarounds to produce the same result.

**Avoid when**: The task is standard product or social video — overkill, longer setup, smaller AI agent compatibility.

---

## Failure Modes of Wrong Tool Choice

| Wrong Choice | Scenario | Result |
|-------------|----------|--------|
| Remotion for simple overlay | Agent uses Remotion for a 10s branded clip with no state | 40% more errors (JSX translation, build setup), slower iteration |
| HyperFrames for React app | Complex data-driven dashboard animation requiring useState | Framework limitations require workarounds, bugs accumulate |
| FFmpeg alone for composition | Trying to create animated titles purely in FFmpeg | Extremely verbose filter_complex, fragile, unmaintainable |
| Manim for product video | Using Python math library for a social media short | Incompatible mental model, no timeline abstraction |

---

## Tool Prerequisites Checklist

Before writing any video composition code, verify tools are installed:

```bash
# HyperFrames workflow
node --version         # must be ≥22
npx hyperframes --version
ffmpeg -version

# Remotion workflow
node --version         # must be ≥22
npx remotion --version
ffmpeg -version

# FFmpeg-only workflow
ffmpeg -version
```

**If tools are missing**: Do not auto-install. Report missing dependencies to the user with the installation command (e.g., `brew install ffmpeg`, `nvm install 22`).

---

## Tool Documentation Pointers

Do not reproduce CLI documentation here. Reference the official sources for version-specific command flags:

- **HyperFrames**: `hyperframes.mintlify.app/quickstart` — scaffold, lint, validate, inspect, render commands
- **Remotion**: `remotion.dev/docs/ai/coding-agents` — AI-specific guidance for agent code generation
- **FFmpeg**: `ffmpeg.org/ffmpeg.html` — complete CLI reference
