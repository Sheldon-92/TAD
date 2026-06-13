---
name: video-creation
description: "Professional video production judgment for AI coding agents — storytelling, motion design, audio, tools (HyperFrames/Remotion)"
version: 0.1.0
type: reference-based
keywords: ["video", "animation", "motion design", "HyperFrames", "Remotion", "视频", "动画", "剪辑", "音频"]
---

# Video Creation Capability Pack

> Cross-agent portable judgment for AI-produced video. Covers storytelling, motion design, audio, tool selection, and quality.
> **CONSUMES**: Brand/design artifacts (optional). **PRODUCES**: Professional-quality video compositions.

---

## Step 0: Pack Prerequisites

This pack requires:
- **FFmpeg** — encoding and audio mixing
- **Node.js ≥22** — HyperFrames or Remotion runtime
- **HyperFrames CLI** (`npx hyperframes`, pinned v0.6.97 / 2026-06-13) OR **Remotion** (`npx remotion`, pinned v4.0.447 / 2026-06-08)
- **fal.ai API key** (`FAL_KEY`) — for Seedance 2.0 video generation (optional, only if using AI asset generation)
- **Codex CLI** — for gpt-image-2 image generation (optional, only if using AI asset generation)
- **ElevenLabs API key** (`ELEVENLABS_API_KEY`) — for TTS, voice cloning, and AI SFX (optional)
- **Fish Audio API key** (`FISH_API_KEY`) — for cross-lingual TTS and voice cloning (optional, alternative to ElevenLabs)

Verify: `ffmpeg -version && node --version && npx hyperframes --version`
Or run the deterministic preflight: `bash scripts/verify-prereqs.sh` (exit 0 = ready; 1 = ffmpeg missing; 2 = node < v22; 3 = composition CLI missing). Add `--remotion` to check Remotion instead.

---

## Step 1: Context Detection

Detect the user's request type and load the appropriate reference file(s).

| User Signal | Load Reference |
|-------------|---------------|
| pacing / timing / rhythm / scene duration / shot length | `references/storytelling.md` |
| animation / motion / easing / transition / GSAP | `references/visual-design.md` |
| music / audio / sound / voiceover / BPM / SFX | `references/audio-design.md` |
| HyperFrames / Remotion / FFmpeg / which tool / setup | `references/tool-selection.md` |
| error / bug / broken / not rendering / blank / crash | `references/production.md` |
| export / quality / resolution / accessibility / captions / WCAG / platform | `references/quality.md` |
| generate image / AI image / character art / background art / $imagegen | `references/ai-asset-generation.md` §Codex gpt-image-2 Rules |
| generate video / AI video / Seedance / video clip / animate image | `references/ai-asset-generation.md` §Seedance 2.0 Rules |
| cost / budget / pricing / how much | `references/ai-asset-generation.md` §Cost Control |
| voiceover / narration / TTS / text-to-speech / generate voice | `references/ai-asset-generation.md` §TTS Voiceover Rules |
| voice clone / brand voice / clone voice / custom voice | `references/ai-asset-generation.md` §Voice Cloning Rules |
| sound effect / SFX / generate sound / ambient / foley | `references/ai-asset-generation.md` §AI Sound Effects Rules |
| Seedance / image-to-video / first-last frame / 照片转视频 / photo-to-video / AI video clip / multi-shot scene | `references/vimax-patterns.md` |

**Multi-signal**: Load all matched references. Cross-reference sections are linked within files.

---

## Step 2: Apply Rules

Read the matched reference file(s) and apply the rules directly. Rules are concrete parameters — not guidelines.

1. **Detect** — identify signal from user request
2. **Load** — read matched reference(s)
3. **Apply** — use the concrete rules (timing values, GSAP curves, BPM ranges, failure checklists)
4. **Produce** — structured findings report (see Output Format below)

---

## Quick Rule Index

One-line summary per rule with reference pointer. **Do not inline rules here** — load the reference.

### Storytelling (`references/storytelling.md`)
- **3-5s Attention Rule**: Meaningful visual change every 3-5 seconds → §Pacing Rules
- **Text-Shot Duration Formula**: 0 words=1.5-2s, 1-3=2-3s, 4-10=3-4s, 11-20=4-6s, 21-35=6-8s → §Text-Driven Shot Duration Formula
- **50% Reading Rule**: Last element entrance finishes at 50% of scene duration → §Pacing Rules
- **5-Second Scene Ceiling**: Hard max (exceptions: counter, hero hold) → §Pacing Rules
- **95% Hard Cut Rule**: Only 2-3 shader transitions per 6-8 scene video → §Pacing Rules
- **Video Type Patterns**: Product Demo / Social Short / Tutorial timing templates → §Video Type Pacing Patterns

### Visual Design (`references/visual-design.md`)
- **Easing-by-Emotion**: 6 GSAP curves mapped to emotion (power2.out → smooth, etc.) → §GSAP Easing-by-Emotion Table
- **3-Ease Minimum**: At least 3 different easing curves per scene → §Motion Rules
- **Entrance Offset**: Never start at 0.0s — offset 0.1-0.3s into scene → §Motion Rules
- **Transition Duration**: Min 0.3s, sweet spot 0.5s → §Motion Rules
- **No Exit Rule**: Never exit-animate except final scene → §Motion Rules
- **Anti-Patterns**: JPEG-with-progress-bar, banned effects, loop limits → §Anti-Patterns

### Audio Design (`references/audio-design.md`)
- **BPM-to-Video-Type**: 5 types × BPM range × instrumentation → §BPM-to-Video-Type Mapping
- **Volume Mix**: Voiceover=100%, background music=10-20% → §Volume Rules
- **No Vocals Rule**: Explainer/tutorial music must avoid vocals and voice-like instruments → §BPM-to-Video-Type Mapping
- **SFX Pre-Lead**: Whoosh starts 10-20ms before visual transition → §SFX Timing Rules

### Tool Selection (`references/tool-selection.md`)
- **HyperFrames-first**: HTML-native, no build, AI-friendly — default choice → §Decision Tree
- **Remotion-when**: React components/state required → §Decision Tree
- **FFmpeg-direct**: Processing/encoding only, no composition → §Decision Tree

### Production (`references/production.md`)
- **17 Agent Failure Modes**: Timing, animation, composition errors → §Agent Failure Modes Checklist (17 Items)
- **5 Prevention Patterns**: Skill loading, DESIGN.md, skeletons, CLI loop, chaining → §Prevention Patterns (5 Items)
- **Render Pipeline**: scaffold → compose → preview → validate → render → export → §Render Pipeline

### Quality (`references/quality.md`)
- **Export Settings**: Per-platform (YouTube/TikTok/Instagram/Twitter) → §Platform Export Specifications
- **WCAG Accessibility**: ≥99% caption accuracy, 4.5:1 contrast, WebVTT → §Accessibility (WCAG)
- **CRF 18-23**: Quality range (18=high, 23=standard) → §Export Settings

### AI Asset Generation (`references/ai-asset-generation.md`)
- **Seedance Default Rule**: Video clips → Seedance 2.0; 4K needed → Kling 3.0; existing Runway → Runway Gen-4 → §Decision Tree
- **Multi-Shot Planner Rule**: 4K + multi-shot → Kling 3.0 AI-Director (≤6 shots/15s native); else Seedance manual "Shot N:" → §Multi-Shot: Kling AI-Director vs Seedance
- **gpt-image Model Guard**: Pin gpt-image-2 for ALL work; gpt-image-1.5/1-mini/chatgpt-image-latest all shut down 2026-12-01, DALL·E shut down 2026-05-12 — do NOT route cheap drafts to 1-mini, use gpt-image-2 quality="low" → §Model Lineup
- **Endpoint Selection Rule**: text-only → text-to-video; have image → image-to-video; multi-ref → reference-to-video → §Seedance Endpoint Selection
- **Submit-Then-Poll Rule**: Never subscribe(), always submit-then-poll with 5s/10s/120s schedule → §Async API Pattern
- **Tiered Generation Rule**: Draft 480p/Fast → approval → Final 1080p/Standard → §Cost Control
- **Request Hashing Rule**: hash(model+prompt+settings) before every API call, re-roll uses attempt_number → §Request Hashing
- **Prompt Consistency Rule**: gpt-image-2 invariant anchoring + Seedance @character:<id> → §Visual Consistency Rules
- **Path Split Rule**: Remotion assets → `public/generated-{images,clips}/`; HyperFrames assets → `assets/generated-{images,clips}/` → §File Path Convention
- **TTS Tool Selection**: English expressiveness → ElevenLabs v3; CJK/cross-lingual → Fish Audio S2 Pro; simple/cheap → OpenAI tts-1-hd → §TTS Voiceover Rules
- **Voice-First Timing Rule**: Generate TTS voiceover BEFORE composing video scenes — voiceover duration drives scene timing → §Voice Pipeline Integration
- **Clone Minimum**: Fish Audio 10–15s sample; ElevenLabs 30–60s (IVC) or 30min (PVC) → §Voice Cloning Rules
- **SFX Source Rule**: Diegetic/scene-tied → Seedance native audio; specific/imaginative/looping → ElevenLabs SFX API → §AI Sound Effects Rules

### Validation Scripts (`scripts/`)
- **failure-mode-precheck.sh**: Deterministic linter — greps a composition for the 6 banned timeline anti-patterns (Date.now/Math.random/setInterval, repeat:-1, async-await, visibility, inline opacity:0); exits 1 on hit → `scripts/failure-mode-precheck.sh <file|dir>`
- **verify-prereqs.sh**: Step-0 preflight — ffmpeg + node≥22 + HyperFrames v0.6.97 (or `--remotion` v4.0.447) with explicit exit codes 1/2/3 → `scripts/verify-prereqs.sh`

### ViMax Patterns (`references/vimax-patterns.md`)
- **Visual Decomposition Rule**: AI image-to-video → decompose into first_frame + last_frame + motion, never single description → §Pattern 1
- **Intent Router Rule**: every new video task → classify narrative/motion/montage FIRST → §Pattern 2
- **View-Specific Reference Rule**: character in ≥2 shots → generate front/side/back sheet → feed angle-matched view per shot → §Pattern 3
- **Camera Tree Rule**: multi-shot in same scene → child shot prompt MUST cite parent shot's spatial elements → §Pattern 4

---

## Anti-Skip Table

Common agent rationalizations and why they fail:

| Rationalization | Why It Fails |
|----------------|-------------|
| "I'll use appropriate timing for this video" | No concrete value → agent defaults to uniform 3s → monotone pacing |
| "I'll use a smooth easing for the animation" | "Smooth" maps to 6 different GSAP curves — pick the emotion first |
| "This is a short video, audio doesn't matter" | Missing BPM match → music fights the visual energy, not supports it |
| "HyperFrames and Remotion both work here" | Wrong tool choice → 40% more agent errors (no-build vs build-required) |
| "I'll fix accessibility after the video renders" | Caption timing depends on scene structure — retrofit = full redo |
| "Date.now() is fine for timing" | Non-deterministic → frame timing breaks on render → blank frames |

---

## Output Format

Produce findings in this structure:

```markdown
## Video Production Findings

### Pacing Plan
- Scene count: [N]
- Average shot duration: [Xs]
- Shader transitions: [N] (positions: [list])
- [Scene-by-scene timing table if video type pattern applies]

### Motion Design
- Easing selection: [emotion → GSAP curve] per scene
- Entrance offsets: [0.Xs per element type]
- Transition duration: [Xs]

### Audio
- Music BPM target: [N-N]
- Mix: voiceover=[%], music=[%]
- SFX: [event → SFX type list]

### Tool
- Selected: [HyperFrames / Remotion / FFmpeg]
- Rationale: [decision tree path]

### Quality Targets
- Platform: [name]
- Resolution: [WxH]
- Format: [codec]
- Captions: [required/not required, format]

### Failure Mode Pre-Check
- [ ] No Date.now/Math.random/setInterval
- [ ] No repeat:-1
- [ ] No async/await in timeline
- [ ] autoAlpha not visibility
- [ ] No inline opacity:0
```

**Run the executable gate, do not eyeball it:** `bash scripts/failure-mode-precheck.sh <composition-file-or-dir>` greps the composition for all 6 banned anti-patterns above and exits non-zero on any hit — block the render until it exits 0.
