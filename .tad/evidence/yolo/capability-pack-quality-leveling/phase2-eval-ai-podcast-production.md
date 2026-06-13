# Phase 2 Behavioral Discriminative Eval — ai-podcast-production

**Date**: 2026-06-13
**Pack**: ai-podcast-production (v0.1.0)
**Fixture**: `.claude/skills/ai-podcast-production/examples/full-episode-production.md`
**Result**: ✅ DISCRIMINATIVE PASS

---

## 1. Fixture parameters

- **discriminative_pattern**:
  `200-350|envelope.?follower|attack.?5|release.?2000|0\.5%|3\.5%|-1 ?dBTP|-14 ?LUFS|-16 ?LUFS|-19 ?LUFS|pyln\.normalize\.peak|merged (loop|processing)|prop_decrease|cfg_value|Codex (adversarial|review)|look-ahead`
- **min_discriminative**: 4
- **Scenario**: "I have a 4000-word article and a reference voice clip. Produce a finished podcast
  episode: write the script, generate the narration with VoxCPM2, add background music, and master
  it for Spotify and Apple Podcasts. Make it sound professional."

## 2. Method

- WITH-PACK answer: produced by applying `SKILL.md` rules (Codex review gate, 200-350 char chunks,
  merged generate→denoise→normalize loop with cfg_value/prop_decrease, per-platform LUFS table,
  -1 dBTP via pyln.normalize.peak, envelope follower 5ms/2000ms + look-ahead, 0.5%/3.5% BGM bed).
- CONTROL answer: generalist agent, no pack — describes the same task in plain terms ("clone the
  voice", "duck the music", "normalize loudness", "make sure nothing clips") with no pack-specific
  numbers or APIs.
- Both run through `grep -oE PATTERN | sort -u | wc -l`.

Artifacts: `_with-pack-output.md`, `_control-output.md` (same directory).

## 3. Results

| Answer | Unique discriminative markers | Threshold (≥4) |
|---|---|---|
| WITH-PACK | **16** | PASS |
| CONTROL  | **0**  | (correctly below) |

WITH-PACK unique markers matched:
`-1 dBTP`, `-14 LUFS`, `-16 LUFS`, `-19 LUFS`, `0.5%`, `200-350`, `3.5%`, `attack=5`,
`cfg_value`, `Codex review`, `envelope follower`, `look-ahead`, `merged processing`,
`prop_decrease`, `pyln.normalize.peak`, `release=2000`

CONTROL unique markers matched: (none)

## 4. Verdict

```
discriminative_pass = (with_pack_disc >= min_discriminative) AND (control_disc < min_discriminative)
                    = (16 >= 4) AND (0 < 4)
                    = TRUE
```

The pack produces strongly differentiated, research-grounded behavior the generalist baseline does
not emit. The control answer pattern-matches to the generic failure modes the fixture's anti-slop
section calls out ("duck the music", "normalize the loudness", "make it sound professional") and
scores zero discriminative markers. Gate PASSES with a wide margin (16 vs 0, threshold 4).
