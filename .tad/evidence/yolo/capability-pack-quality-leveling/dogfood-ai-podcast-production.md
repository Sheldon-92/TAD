# Dogfood Judgment — ai-podcast-production pack

Task: Produce a finished podcast episode from a 4000-word article + reference voice clip (script → VoxCPM2 narration → BGM → master for Spotify + Apple).

Answer 1 = generic ffmpeg-pipeline plan (no pack). Answer 2 = ai-podcast-production pack applied.

## WebSearch-verified facts

| Claim | Verified value | Source |
|---|---|---|
| VoxCPM2 license | Apache-2.0 | github.com/OpenBMB/VoxCPM |
| VoxCPM2 sample rate | 48kHz (VoxCPM 1.5 = 44.1kHz) | OpenBMB / HF |
| VoxCPM2 voice cloning args | prompt_wav_path + prompt_text | pack tts-production.md TP4 (matches API) |
| Spotify loudness | -14 LUFS | criticallisteninglab, descript, Spotify support |
| Apple Podcasts stereo | -16 LUFS (LKFS) | Apple, criticallisteninglab |
| Apple Podcasts mono | -19 LUFS (sounds = -16 stereo) | criticallisteninglab, podnews |
| True-peak ceiling | -1 dBTP both platforms | Apple audio reqs |
| Distribution | SINGLE file via one RSS feed; both platforms ingest same file and normalize at PLAYBACK | Spotify support, RSS.com, multiple |

## Pack-fidelity check (Answer 2 vs actual pack)

Read the actual installed pack. Answer 2's citations are faithful:
- TP1 large-chunk 200-350 chars / ~20 chunks — matches tts-production.md TP1 exactly.
- TP4 merged loop (generate→noisereduce→loudness→peak), cfg_value=2.0, inference_timesteps=10, denoise=False, prop_decrease=0.85, stationary=True — verbatim.
- TP7b stationary=False for recorded reference clip — matches.
- MA1 envelope follower attack=5ms/release=2000ms, ~17 dB swing — matches.
- MA3 0.5s look-ahead, MA4 log10(1+9t), MA5 0.5%→3.5%, MA6 8s+6s / 15s+10s, MA10 2s crossfade, MA11 no limiter on voice — all match.
- Per-platform LUFS table + the "do NOT hard-code -16" anti-skip — matches TP7a verbatim, including -19 mono.
- loudness-check.sh / chunk-lint.sh validators exist on disk.

Answer 2 is a high-fidelity instantiation of a pack whose own numbers are WebSearch-correct (the pack itself carries retrieval-dated sources).

## Correctness assessment

### Answer 1 (generic)
Mostly correct, conservative, runnable ffmpeg. Specific issues:
- **Loudness target oversimplified but defensible**: claims "-16 is the safe shared spec, master once." -16 is genuinely a safe single-file value (Spotify just turns it up 2 dB, no re-compression). This is a legitimate professional shortcut, NOT wrong — and it correctly notes "upload one file... both ingest the same feed; you don't export differently per platform." This single-file claim is CORRECT and is the real-world delivery model.
- VoxCPM described as "tokenizer-free, context-aware, zero-shot voice cloning" — correct.
- Did NOT commit to a wrong VoxCPM2 sample rate / API signature; explicitly flagged "verify the generate() signature against your installed version." Honest hedge, no wrong specific.
- ffmpeg `sidechaincompress` + two-pass `loudnorm` — both real, correctly used.
- `deesser` as bare ffmpeg filter: ffmpeg's filter is actually `deesser` (exists) — OK.
- No fabricated version numbers.

No specific-but-WRONG claims found in Answer 1. It wins on safety-through-hedging.

### Answer 2 (pack)
Specifics are RICHER and verified-correct (48kHz, Apache-2.0, v2.0.3, -14/-16/-19 targets, prompt_wav_path API). Concerns:
- **The "CRITICAL CORRECTION ... do NOT ship one file to both" framing is partially misleading.** It asserts two masters MUST be produced and "Do NOT ship one file to both." In real podcast distribution you ship ONE file to ONE RSS feed; both platforms normalize at playback. Producing two platform masters is NOT how podcast delivery works (unlike music distribution where you might deliver per-DSP). So Answer 2's headline "correction" overstates: -16 single-master IS a valid pro choice (Spotify nudges +2dB without re-compression). Answer 2 frames Answer-1's valid approach as a forbidden error. This is the one place the pack's confident specificity produces a real-world-questionable mandate.
  - Mitigating: the per-platform LUFS numbers themselves are all correct; the error is the delivery-model implication, not the numbers.
- "-1 dBFS sample-peak ... approximates Apple's -1 dBTP per ITU-R BS.1770-5" — pack is unusually honest that sample-peak != true-peak and recommends ffmpeg ebur128 for a real dBTP guarantee. Correct and sophisticated.
- "~25 corrections across 5 categories" from Codex review — presented as an expectation, hedged ("expect ~"). Not a hard false claim.
- Everything else verified correct.

### Wrong-claim tally
- Answer 1: no specific-but-wrong claims (correctly hedged the uncertain ones).
- Answer 2: no wrong NUMBERS, but one questionable MANDATE ("must ship two masters, do not ship one file to both") that contradicts how single-RSS-feed podcast distribution actually works. The numbers are right; the delivery prescription is overstated.

## Comparison

- **Correctness**: Answer 1 has zero wrong specifics and its single-file delivery claim is the real-world-correct model. Answer 2 has correct numbers but its headline "correction" mis-prescribes dual-master delivery. Edge to A1 on the delivery point, but A2's underlying loudness facts are more complete and more precise. Roughly even; A2 slightly higher because its richer specifics (48kHz, mono -19, API args, dBTP-vs-sample-peak honesty) are all verified true and add real value, while its one overreach is a framing error not a factual one.
- **Actionability**: A2 is far more actionable — concrete validated params (cfg/timesteps/prop_decrease/envelope coeffs/fade lengths), runnable validators (loudness-check.sh, chunk-lint.sh), exact API call, Colab deployment. A1 gives real ffmpeg commands too, but at a coarser grain and explicitly cannot confirm the VoxCPM2 API.
- **Specificity**: A2 decisively higher and the specifics are verified-correct (the danger of a pack is wrong specifics; here they hold up).
- **Completeness**: A2 covers show notes, deployment, dual-BGM, look-ahead, LRA acceptance band, licensing per-model — well beyond A1. A1 covers the core chain well and adds a strong licensing caveat, but is narrower.

Both correctly identified the missing inputs (no article/clip) and refused to fabricate output — good honesty from both.

## Verdict

Winner: 2 (clear). The pack answer wins on actionability, specificity, and completeness with verified-correct specifics — exactly the case where specialized knowledge pays off without the usual "confident-but-wrong" tax. Its only blemish is over-prescribing dual-master delivery (framing a valid single-file approach as forbidden), which A1 actually got right. That keeps it from "decisive": A1 is a genuinely solid, honestly-hedged answer with no wrong specifics. But A2's depth of correct, runnable, validated detail is what the user asked for ("make it sound professional") and substantially exceeds A1.

Margin: clear (not decisive) — A1's correctness and honest hedging keep it respectable; A2 wins on the merits the task rewards, minus one overstated mandate.
