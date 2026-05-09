# Video Creation Capability Pack

A cross-agent, self-contained capability pack that teaches AI coding agents professional-grade video production judgment. Covers storytelling, motion design, audio design, tool selection (HyperFrames vs Remotion), and quality/accessibility.

## What This Pack Does

AI agents can write video via HTML (HyperFrames) and React (Remotion), but they produce amateur-looking output — bad timing, generic motion, wrong easing. This pack bridges the judgment gap: it provides concrete, parameterized rules that transform "technically renders" into "looks professional."

**Rules are concrete parameters**, not guidelines:
- `power2.out` (not "smooth easing")
- `3–5 seconds` (not "appropriate timing")
- `CRF 18–23` (not "good quality")
- `10–20ms pre-lead for SFX` (not "sync sound to video")

## Quick Start

### 1. Install

```bash
# Clone or download the pack, then:
bash install.sh                    # Claude Code (default)
bash install.sh --agent claude-code  # Explicit
bash install.sh --check           # Check prerequisites only
```

### 2. Load

The pack activates automatically in Claude Code when you work on video tasks. Context detection happens in CAPABILITY.md Step 1.

### 3. Use

For video tasks, the pack will:
1. Detect your context (pacing? motion? audio? tool choice?)
2. Load the matched reference file
3. Apply concrete rules from that reference
4. Produce a structured findings report

## Structure

```
video-creation/
├── CAPABILITY.md            # Context detection router + quick rule index
└── references/
    ├── storytelling.md      # Pacing rules, shot duration, video type patterns
    ├── visual-design.md     # GSAP easing-by-emotion, motion rules, anti-patterns
    ├── audio-design.md      # BPM mapping, volume mix, SFX timing, TTS
    ├── tool-selection.md    # HyperFrames vs Remotion decision tree
    ├── production.md        # 17 agent failure modes, prevention patterns
    └── quality.md           # Export settings, WCAG accessibility, platform specs
```

## Tool Requirements

| Tool | Required | Purpose |
|------|---------|---------|
| FFmpeg | Required | Video encoding, audio mixing, format conversion |
| Node.js ≥22 | Required | HyperFrames or Remotion runtime |
| HyperFrames | Required for HTML-native video | AI-first HTML→video framework |
| Remotion | Required for React-based video | React component→video framework |

Check prerequisites:
```bash
bash install.sh --check
```

## Tool Philosophy

**HyperFrames-first**: HTML-native, no build step, AI-friendly (fewer agent errors). Default choice for most video tasks.

**Remotion-when**: Complex React compositions requiring state management or component reuse.

**FFmpeg-direct**: Processing and encoding only — not for composition authoring.

## License

Apache 2.0. See [LICENSE](LICENSE) and [LICENSE-ATTRIBUTION.md](LICENSE-ATTRIBUTION.md) for source credits.

## Version

v0.1.0 — Initial release. See [CHANGELOG.md](CHANGELOG.md).
