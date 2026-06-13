# Phase 5 — Behavioral Discriminative Eval: video-creation

Date: 2026-06-13
Pack: video-creation (v0.1.0)
Fixture: `examples/photo-to-beat-sync.md` (exercises all 4 ViMax patterns)

## Fixture Parameters

- `discriminative_pattern`: `first_frame|last_frame|montage|camera_tree`
- `min_discriminative`: 4
- All 4 markers are pack-introduced ViMax terms (Pattern 1 first_frame/last_frame fields,
  Pattern 2 montage intent classification, Pattern 4 camera_tree spatial hierarchy).

## Scenario

> 我有 3 张人像照片（不同表情/姿势），想做一个 6 秒的卡点动态视频。背景配 lofi 音乐。

## Method

1. WITH-PACK answer: applied SKILL.md Step 0/1/2 routing + `references/vimax-patterns.md`
   Patterns 1-4 (`dogfood-output-A.md`).
2. CONTROL answer: generalist video-editing advice, no pack loaded
   (`dogfood-output-control.md`).
3. Applied `grep -oE '<pattern>' <file> | sort -u | wc -l` to each.

## Results

| Output | Distinct markers matched | Markers |
|--------|--------------------------|---------|
| WITH-PACK (A) | 4 | camera_tree, first_frame, last_frame, montage |
| CONTROL | 1 | montage |

- WITH-PACK disc = 4  (>= min_discriminative 4) ✅
- CONTROL disc = 1   (< min_discriminative 4) ✅

The CONTROL legitimately surfaces "montage" because a generalist naturally describes a
photo-collage edit as "montage-style." But it emits NONE of the ViMax structural fields
(first_frame / last_frame / camera_tree) — those are pack-introduced decomposition and
spatial-hierarchy concepts a no-pack agent does not produce. The gap (4 vs 1) is driven
entirely by pack-specific structure, confirming the markers discriminate.

## Verdict

discriminative_pass = **true**
(with-pack disc 4 >= 4 AND control disc 1 < 4)
