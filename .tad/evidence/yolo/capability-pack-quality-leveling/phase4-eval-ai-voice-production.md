# Phase 4 — Behavioral Discriminative Eval: ai-voice-production

- **Pack**: ai-voice-production (v0.1.0, reference-based)
- **Date**: 2026-06-13
- **Fixture**: `.claude/skills/ai-voice-production/examples/audiobook-tool-selection.md`
- **Method**: WITH-PACK vs CONTROL answer to the fixture scenario, scored by the fixture's
  `discriminative_pattern` via `grep -oE PATTERN | sort -u | wc -l`.

---

## Fixture parameters

- `discriminative_pattern`:
  `ACX|44\.1kHz|192kbps|RMS -2[0-9]|-23 to -18|dBTP|LUFS|loudnorm|emo_alpha|150ms|speaker embedding|seed reset|MPS|float32`
- `min_discriminative`: 3
- **Scenario**: "I want to narrate a 120,000-word audiobook with a single consistent cloned
  voice, on my 16GB M-series Mac, and publish it to Audible. Which tool and pipeline?"

## Gate rule

`discriminative_pass = true` ONLY IF `with-pack disc >= min_discriminative (3)`
AND `control disc < min_discriminative (3)`.

---

## Results

| Answer | Distinct discriminative markers | Threshold |
|---|---|---|
| WITH-PACK | **11** | >= 3 |
| CONTROL | **0** | < 3 |

### WITH-PACK distinct markers (11)
`192kbps`, `44.1kHz`, `ACX`, `dBTP`, `float32`, `loudnorm`, `LUFS`, `MPS`,
`RMS -23`, `seed reset`, `speaker embedding`

These are all pack-introduced specifics grounded in the references:
- ACX 8 hard specs (192kbps CBR / 44.1kHz / MONO / RMS -23 to -18) — `audiobook-pipeline.md` §ACX/Audible
- Two-pass `loudnorm` + LUFS / dBTP platform numbers — `audiobook-pipeline.md` §FFmpeg Mastering
- `.pt` speaker embedding + seed reset cross-session consistency — `audiobook-pipeline.md` §Consistency
- MPS / float32 Apple Silicon rules — `apple-silicon.md` §MPS Configuration / 16GB Budget

### CONTROL distinct markers (0)
The generalist answer (no pack) named no specific tool minimums, no ACX numbers, no MPS
rule, and no loudness targets — it said "check Audible's guidelines", "normalize the volume",
"use the same cloned voice". Zero pattern hits, as expected for non-discriminative slop.

---

## Verdict

**discriminative_pass = TRUE**

- with-pack disc (11) >= min_discriminative (3): PASS
- control disc (0) < min_discriminative (3): PASS

The pack produces behavior a generalist agent does not: it discriminates strongly (11 vs 0).
No marker leaked into the control answer, so the gate is not a false positive — the markers
genuinely require the pack's references to surface.
