# Dogfood Judgment — video-creation pack

**Task:** 3 portrait photos → 6s beat-sync video with lofi background music.
**Date:** 2026-06-14
**Judge:** blind, merit-only (did not know which answer used the pack at scoring time).

## WebSearch verification of key specifics

| Claim | Answer | Verdict |
|-------|--------|---------|
| lofi 70–90 BPM | both | CORRECT (bpmcalc, MasterClass, multiple) |
| 80 BPM = 0.75s/beat; 75 BPM = 0.8s/beat; downbeat every 4 beats = 3.2s; 6s≈7.5 beats | both | CORRECT (arithmetic verified) |
| FFmpeg zoompan integer-pixel rounding → jitter; fix = pre-scale to 8000x4000 then downscale | A2 | CORRECT (datarecoveryunion, usercomp both confirm upscale-before-zoompan is the canonical fix) |
| FFmpeg xfade offset/zoompan recipe (A1) timing valid | A1 | CORRECT (recomputed: v0=2.8s, xfade@2.5+0.3=2.8 OK; running total 4.5s, xfade@4.0+0.3=4.3 OK; final 6.2s trimmed to 6 OK) |
| CapCut Beat Sync / Auto Beat free, mobile + desktop | both (A2 says NOT Web) | CORRECT — mobile Auto Beat + desktop right-click Add Beat>Auto Beat, free tier confirmed. A2's "NOT CapCut Web" is the more precise claim — defensible, not contradicted. |
| madmom DBNDownBeatTrackingProcessor returns sec + downbeat flag; better than librosa.beat_track for downbeats | A2 | CORRECT — madmom docs confirm 2D output with beat+downbeat columns. librosa.beat_track returns frame indices (no downbeat). |
| H.264 High + AAC MP4 = universal upload codec; AV1 delivery-only, not for upload | A2 | CORRECT — H.264 standard across platforms; AV1 may fail to upload on TikTok. |
| "-14 LUFS for TikTok/IG is a myth, only YouTube -14 documented"; pragmatic loudnorm=I=-16:TP=-1 | A2 | DEFENSIBLE — sources genuinely conflict on TikTok/IG (-10 to -16, one says no in-feed normalization); only YouTube -14/-1 consistently documented. A2 correctly flags uncertainty instead of asserting a false number. |
| lofi sources Pixabay/YouTube Audio Library/Uppbeat/Chosic royalty-free | A1 | CORRECT |
| Audacity waveform peak = beat for manual cueing | A1 | CORRECT |

**No specific-but-WRONG claims found in either answer.** Both are unusually clean on facts. A2 additionally self-flags its two softest claims (1–2 frame anticipation cut = "convention not measured fact"; zoompan upscale = "partial never-merged workaround") — calibrated honesty, opposite of confident-wrong.

## Scoring (1–5)

### Answer 1 (generalist, clean)
- Correctness 5 — every specific verified, recipe math sound.
- Actionability 5 — two complete paths (CapCut steps + runnable FFmpeg), explicit "how to find the beat" (Audacity), offer to tune to BPM.
- Specificity 4 — concrete timeline, BPM math, named tools/sources, working FFmpeg. Less domain-deep than A2.
- Completeness 4 — structure, both tiers, transitions, motion, music sourcing, aspect ratio. MISSES portrait-specific continuity across 3 different poses (the crux of THIS brief) and loudness.

### Answer 2 (pack-driven)
- Correctness 5 — every verifiable specific confirmed; soft claims hedged; no wrong facts.
- Actionability 4 — strong CapCut steps + FFmpeg, but wrapped in Tier-0/1/2/3 routing jargon + a "Failure Mode Pre-Check / not applicable" section that adds reading cost for a casual user.
- Specificity 5 — ms@fps anticipation cut, madmom vs librosa with exact processor name + bias, upload-vs-delivery codec, safe-zone px, loudnorm string, ISMIR stat.
- Completeness 5 — uniquely nails portrait continuity across different expressions/poses (head-height parity, eye-line, white-balance), audio mix levels, loudness reality, codec, i2v escalation path. Correctly resists over-engineering.

## Winner: 2 (clear)

A2 wins on CORRECT specifics, not verbosity. Decisive right differentiators A1 lacks:
1. **Portrait-continuity** — literal crux of "3 photos different expressions/poses": head-height parity, eye-line, white-balance match. Prevents face-jump a beat-only plan produces.
2. **Correct over-engineering guard** — routes casual one-off to CapCut, says Tier-3 code-render NOT justified, still gives FFmpeg fallback.
3. **Deeper-but-correct craft** — zoompan jitter fix, anticipation cut, madmom downbeat, codec/loudness reality, all verified.

A2's cost is minor: Tier-0/Failure-Mode framing is process-leakage a casual user doesn't need (A1 reads more naturally for a beginner). Hence "clear" not "decisive" — A1 is genuinely excellent. But on merit/correct-specificity/fit-to-brief A2 leads.

Margin: clear.
