---
name: single-clip-narration
description: "Tests narrative intent routing + voice-first timing — Pattern 3/4 should NOT trigger"
pack: video-creation
tests_rules:
  - "Intent Router Rule"
  - "Voice-First Timing Rule"
  - "Volume Mix"
min_marker_count: 3
---

# Fixture: Single-Clip Narration

## Input Scenario

"我有一段 30 秒的产品演示画面，需要加旁白和字幕。"

## Expected Markers

When an AI agent processes the Input Scenario with the video-creation pack loaded,
the output MUST contain these markers:

1. **Intent Classification**: explicit "narrative" intent classification as the first step
   grep pattern: `narrative`
2. **Voice-First Timing** [structural]: production plan where TTS voiceover is generated BEFORE scene composition — the output describes voice generation as a prerequisite step, not an afterthought
   grep pattern: `voice.first|voiceover.+before|tts.+before|generate.+voice`
3. **Volume Priority**: voiceover volume dominance (100%) with background music reduced (10-20%)
   grep pattern: `voiceover.+100|music.+1[0-9]|music.+20|volume.+mix`

Markers that MUST NOT appear (discriminative check):
- ❌ "view_specific" or "angle_match" (Pattern 3 — no multi-angle character)
- ❌ "camera_tree" or "parent_shot" (Pattern 4 — single continuous clip)

## Verification Command

```bash
grep -oE 'narrative|voice.first|voiceover.+before|tts.+before|generate.+voice|voiceover.+100|music.+1[0-9]|music.+20|volume.+mix' dogfood-output-B.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "narrative" as explicit intent classification (Intent Router Rule)
- ✅ "voice_first" (pack rule: generate TTS before scene assembly)
- ✅ "volume_mix" with specific percentages (pack rule from audio-design.md)
- ❌ "voiceover" alone (generic — any narration task mentions voiceover)
- ❌ "subtitle" (generic — input explicitly asks for subtitles)
