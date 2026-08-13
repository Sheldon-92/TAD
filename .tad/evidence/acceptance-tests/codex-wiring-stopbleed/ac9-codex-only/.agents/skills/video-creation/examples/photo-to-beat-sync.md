---
name: photo-to-beat-sync
description: "Tests all 4 ViMax patterns: montage of portrait photos into beat-synced video"
pack: video-creation
tests_rules:
  - "Visual Decomposition Rule"
  - "Intent Router Rule"
  - "View-Specific Reference Rule"
  - "Camera Tree Rule"
min_marker_count: 6
# DISCRIMINATIVE gate: ALL markers here are pack-specific (no severity tags / generic nouns to strip).
# first_frame/last_frame (ViMax Pattern 1 fields), montage (Pattern 2 intent), camera_tree (Pattern 4)
# are pack-introduced. DEEPENED 2026-06-14 (beat-sync-montage.md): added Tier-0 complexity routing
# (Tier 1/2/3) + cut-on-downbeat + anticipation cut (cut 1-2 frames before beat) + zoompan jitter fix —
# all markers a no-pack generalist does NOT emit (the dogfood CONTROL won by offering CapCut + craft
# tips but never named a complexity tier, downbeat cut placement, the frame-accurate anticipation
# offset, or the zoompan prescale fix). min_discriminative=6 raised from 4 to require the new depth.
# RE-GROUNDED 2026-06-14 to the deep-research report: the "anticipation" / "1-2 frame" marker is now
# pack-presented as PRACTITIONER CONVENTION (not measured fact) and the zoompan fix as a PARTIAL,
# never-merged workaround. Markers are unchanged (still discriminate vs. a generalist); the WITH-PACK
# answer is now expected to present them with the honesty hedge, which a generalist still does NOT do.
discriminative_pattern: "first_frame|last_frame|montage|camera_tree|Tier 1|Tier 3|downbeat|anticipation|zoompan|Beat Sync|1.2 frame|1-2 frame"
min_discriminative: 6
# Revalidated 2026-06-14: original 4 ViMax markers + new beat-sync depth markers (Tier routing,
# downbeat cut placement, anticipation-frame offset, zoompan jitter fix, CapCut Beat Sync) all stay
# pack-specific. A correct WITH-PACK montage answer now MUST name the complexity tier + frame-accurate
# cut craft, not just decompose photos — and should flag the anticipation offset as convention.
---

# Fixture: Photo-to-Beat-Sync

## Input Scenario

"我有 3 张人像照片（不同表情/姿势），想做一个 6 秒的卡点动态视频。背景配 lofi 音乐。"

## Expected Markers

When an AI agent processes the Input Scenario with the video-creation pack loaded,
the output MUST contain these markers (≥6 distinct):

1. **Complexity Tier Routing** [DEEP]: explicit Tier-0 weight classification — a casual 3-photo brief routes to **Tier 1** (CapCut/FFmpeg), NOT auto Tier 3 (HyperFrames/Remotion). The agent names the tier and justifies the weight.
   grep pattern: `Tier 1|Tier 3`
2. **CapCut Beat Sync** [DEEP]: names CapCut Beat Sync (auto beat-markers on the waveform, free tier) as the fast consumer path.
   grep pattern: `Beat Sync`
3. **Cut-on-Downbeat** [DEEP]: major cuts placed on downbeats (every 4th beat), not every beat.
   grep pattern: `downbeat`
4. **Anticipation Cut** [DEEP]: cut placed 1–2 frames BEFORE the beat for impact (frame-accurate craft), presented as PRACTITIONER CONVENTION — not a measured psychoacoustic fact (per the deep-research §(b) UNVERIFIED flag).
   grep pattern: `anticipation|1-2 frame|1.2 frame`
5. **Ken Burns jitter fix** [DEEP]: ffmpeg `zoompan` with high-res 8000×4000 prescale to reduce jitter — flagged as a PARTIAL, never-merged-upstream workaround (Tier-2 path).
   grep pattern: `zoompan`
6. **Visual Decomposition** [structural]: per-photo first_frame/last_frame breakdown (ViMax Pattern 1) — only if escalating to AI-animation.
   grep pattern: `first_frame|last_frame`
7. **Intent Classification**: explicit "montage" intent as the routing step.
   grep pattern: `montage`

## Verification Command

```bash
grep -oE 'first_frame|last_frame|montage|camera_tree|Tier 1|Tier 3|downbeat|anticipation|zoompan|Beat Sync|1.2 frame|1-2 frame' dogfood-output-A.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 6
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack — the dogfood CONTROL won WITHOUT
naming any of them, proving they discriminate):
- ✅ "Tier 1" / "Tier 3" (complexity-weight routing — generalists pick a tool, not a tier)
- ✅ "downbeat" cut placement (frame-accurate beat craft — generalist says "sync to the beat")
- ✅ "anticipation" / "1-2 frame" cut offset (sub-100ms craft a generalist never quantifies)
- ✅ "zoompan" with prescale jitter fix (specific ffmpeg failure-mode remedy)
- ✅ "Beat Sync" as the named CapCut feature (verified-real, free-tier)
- ✅ "first_frame" / "last_frame" / "montage" / "camera_tree" (ViMax pack fields)
- ❌ "video" / "photo" / "lofi" (too generic — from the input, not the pack)
- ❌ "sync to the beat" / "use CapCut" (a generalist emits these — NOT in the discriminative set)
