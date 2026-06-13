---
name: full-episode-production
description: "Tests the podcast pipeline judgment a no-pack agent lacks — large-chunk TTS sizing, merged generate/denoise/normalize loop, per-platform loudness + -1 dBFS sample-peak reserve (approximating the -1 dBTP platform target), envelope-follower ducking params, and adversarial Codex script review"
pack: ai-podcast-production
tests_rules:
  - "TP1: large-chunk TTS strategy 200-350 chars, ~20 chunks (NOT per-sentence)"
  - "TP4: merged generate → denoise → normalize loop in one iteration"
  - "TP7a: per-platform loudness target (NOT hard-coded -16); -14 default"
  - "MA8: -1 dBFS sample-peak reserve via pyln.normalize.peak (NOT old 0.95 clamp; sample-peak, not measured dBTP — real dBTP needs ffmpeg ebur128)"
  - "MA1: envelope follower attack=5ms / release=2000ms sidechain ducking"
  - "MA5: BGM 0.5% during voice / 3.5% during silence sweet spot"
  - "SS9: adversarial Codex script review before TTS"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific markers — every alternative is a research-grounded
# number or pack-introduced API that a no-pack agent does NOT emit. A generic agent says
# "generate TTS", "normalize the audio", "duck the music", "review the script" with NO
# specific chunk size, NO -1 dBFS peak reserve / per-platform LUFS table, NO 5ms/2000ms envelope coeffs,
# NO 0.5%/3.5% bed, NO pyln.normalize.peak, NO Codex adversarial pass. Excludes generic
# "produce a podcast" / "add background music" / "make it sound good".
discriminative_pattern: "200-350|envelope.?follower|attack.?5|release.?2000|0\\.5%|3\\.5%|-1 ?dBTP|-14 ?LUFS|-16 ?LUFS|-19 ?LUFS|pyln\\.normalize\\.peak|merged (loop|processing)|prop_decrease|cfg_value|Codex (adversarial|review)|look-ahead"
min_discriminative: 4
---

# Fixture: Full Episode Production from a Source Article

## Input Scenario

"I have a 4000-word article and a reference voice clip. Produce a finished podcast
episode: write the script, generate the narration with VoxCPM2, add background music,
and master it for Spotify and Apple Podcasts. Make it sound professional."

## Expected Markers

When an AI agent processes the Input Scenario with the ai-podcast-production pack loaded,
the output MUST contain these markers (research-grounded, pack-specific):

1. **Large-chunk TTS sizing** [TP1]: splits the script into **200-350 char** chunks (~20/episode), explicitly NOT per-sentence
   grep pattern: `200-350|200.?to.?350|large.?chunk|~?20 chunks`
2. **Merged processing loop** [TP4]: generate → denoise → loudness-normalize in ONE iteration per chunk, with `cfg_value=2.0`, `inference_timesteps=10`, `prop_decrease`, `denoise=False`
   grep pattern: `merged (loop|processing)|cfg_value|inference_timesteps|prop_decrease|denoise=False`
3. **Per-platform loudness, not a -16 constant** [TP7a]: cites distinct targets — Apple-stereo **-16 LUFS**, Apple-mono **-19 LUFS**, Spotify/YouTube **-14 LUFS** — defaulting to -14 for multi-platform
   grep pattern: `-14 ?LUFS|-16 ?LUFS|-19 ?LUFS|per-platform|LKFS`
4. **-1 dBFS sample-peak reserve** [MA8]: reserves headroom via `pyln.normalize.peak(audio, -1.0)` (sample-peak, approximating the platform -1 dBTP target), NOT the old 0.95 clamp; notes that a true dBTP guarantee needs `ffmpeg ebur128=peak=true`
   grep pattern: `-1 ?dBFS|-1 ?dBTP|pyln\.normalize\.peak|sample.?peak|true.?peak`
5. **Envelope-follower ducking** [MA1]: sidechain envelope follower with **attack=5ms / release=2000ms** and 0.5s **look-ahead**
   grep pattern: `envelope.?follower|attack.?5|release.?2000|look-ahead`
6. **BGM volume sweet spot** [MA5]: BGM at **0.5%** during voice, **3.5%** during silence (continuous bed, ~17 dB swing)
   grep pattern: `0\.5%|3\.5%|0\.005|0\.035`
7. **Adversarial Codex script review** [SS9]: runs a Codex review pass on the script BEFORE TTS to catch factual/logical errors
   grep pattern: `Codex (adversarial|review)|adversarial.+(review|Codex)`

## Verification Command

```bash
grep -oE '200-350|envelope follower|envelope-follower|attack=5|release=2000|0\.5%|3\.5%|-1 dBTP|-14 LUFS|-16 LUFS|-19 LUFS|pyln\.normalize\.peak|merged loop|merged processing|prop_decrease|cfg_value|Codex adversarial|Codex review|look-ahead' full-episode-production-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "200-350 char chunks, ~20/episode" (TP1 — no-pack agent generates per-sentence or unspecified)
- ✅ "merged generate→denoise→normalize loop, cfg_value=2.0 / prop_decrease=0.85" (TP4 — pack's exact params)
- ✅ "per-platform LUFS: -16 Apple-stereo / -19 Apple-mono / -14 Spotify·YouTube" (TP7a — no-pack agent says "normalize loudness")
- ✅ "-1 dBFS sample-peak reserve via pyln.normalize.peak; real dBTP via ffmpeg ebur128" (MA8 — no-pack agent clamps at 0.95, skips it, or wrongly calls a sample-peak scaler a true-peak meter)
- ✅ "envelope follower attack=5ms/release=2000ms + 0.5s look-ahead" (MA1 — pack's exact coefficients)
- ✅ "BGM 0.5%/3.5% sweet spot" (MA5 — validated values, not 'lower the music')
- ✅ "Codex adversarial script review before TTS" (SS9 — pack's review gate)
- ❌ "produce a podcast episode" (restates the input)
- ❌ "add background music and normalize the audio" (generic, no params)
- ❌ "make it sound professional" (non-discriminative)
