---
name: photo-to-beat-sync
description: "Tests all 4 ViMax patterns: montage of portrait photos into beat-synced video"
pack: video-creation
tests_rules:
  - "Visual Decomposition Rule"
  - "Intent Router Rule"
  - "View-Specific Reference Rule"
  - "Camera Tree Rule"
min_marker_count: 4
# DISCRIMINATIVE gate: ALL markers here are already pack-specific (no severity tags / generic
# nouns to strip). first_frame/last_frame (ViMax Pattern 1 fields), montage (Pattern 2 intent),
# camera_tree (Pattern 4) are pack-introduced terms. This fixture exercises all 4 ViMax patterns,
# so min_discriminative=4 mirrors the design intent (a no-pack agent emits none of these fields).
discriminative_pattern: "first_frame|last_frame|montage|camera_tree"
min_discriminative: 4
---

# Fixture: Photo-to-Beat-Sync

## Input Scenario

"我有 3 张人像照片（不同表情/姿势），想做一个 6 秒的卡点动态视频。背景配 lofi 音乐。"

## Expected Markers

When an AI agent processes the Input Scenario with the video-creation pack loaded,
the output MUST contain these markers:

1. **Visual Decomposition** [structural]: per-photo decomposition with explicit first_frame and last_frame descriptions — the agent outputs a structured breakdown per photo, not a single narrative description
   grep pattern: `first_frame|last_frame`
2. **Intent Classification**: explicit "montage" intent classification as the first routing step
   grep pattern: `montage`
3. **View Reference**: view-specific reference sheet or angle-matched guidance for character consistency across shots
   grep pattern: `view.specific|angle.match|front.+side.+back`
4. **Camera Tree**: parent-child spatial reference linking consecutive shots in the same scene
   grep pattern: `camera.tree|parent.+shot|spatial.+element`

## Verification Command

```bash
grep -oE 'first_frame|last_frame|montage|view.specific|angle.match|front.+side.+back|camera.tree|parent.+shot|spatial.+element' dogfood-output-A.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "first_frame" (ViMax Pattern 1 decomposition field — no generic AI outputs this)
- ✅ "last_frame" (ViMax Pattern 1 decomposition field)
- ✅ "montage" as intent classification (ViMax Pattern 2 routes to montage/narrative/motion)
- ✅ "camera_tree" (ViMax Pattern 4 spatial hierarchy concept)
- ❌ "video" (too generic — any video task mentions this)
- ❌ "photo" (too generic — input naturally mentions photos)
- ❌ "lofi" (from input, not from pack rules)
