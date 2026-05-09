# Changelog

All notable changes to the video-creation capability pack.

## [0.1.0] — 2026-05-08

### Initial Release

- **CAPABILITY.md**: Context detection router with 6-reference dispatch, quick rule index, anti-skip table, and structured output format
- **references/storytelling.md**: Pacing rules (3-5s attention rule, text-shot duration formula, 50% reading rule, 5-second ceiling, 95% hard cut rule); video type patterns (Product Demo 12-scene rhythm, Social Short, Tutorial/Explainer)
- **references/visual-design.md**: GSAP easing-by-emotion table (6 curves × emotion × duration), motion rules (3-ease minimum, entrance offset, transition duration, no-exit rule, staggering), anti-patterns (JPEG-with-progress-bar, banned effects, loop limit, invisible bridges)
- **references/audio-design.md**: BPM-to-video-type mapping (5 types), volume mix rules, audio structure (separate `<audio>` tags, caption leak prevention), TTS integration, SFX timing (with source approximation tags)
- **references/tool-selection.md**: HyperFrames vs Remotion decision tree, tool comparison, failure modes of wrong tool choice, tool documentation pointers
- **references/production.md**: 17 agent failure modes checklist (timing, animation, composition), 5 prevention patterns, render pipeline, HyperFrames/Remotion-specific patterns
- **references/quality.md**: Platform export specs (YouTube/TikTok/Instagram/Twitter/LinkedIn/Web), codec/quality settings, WCAG accessibility (caption requirements, contrast, motion), pre-export checklist
- **install.sh**: Claude Code installation + tool detection; Phase 2 stubs for Codex/Cursor/Gemini

### Research Basis
- Notebook: a62f253b (27 sources)
- 5 layers of deep-ask research
- Supplementary WebSearch for SFX timing and audio specifics (tagged as approximate)
