# Phase 4 Adversarial Review — ai-voice-production (fact-api lens)

- **lens**: fact-api (factual / API / version correctness)
- **meets_bar**: false
- **reviewer**: Opus 4.8 subagent, 2026-06-13
- **scope**: SKILL.md + all 7 references + 2 scripts + 1 fixture

## Verdict rationale

The pack is mostly accurate and unusually well-sourced (URLs + retrieval dates on the
version-sensitive claims). The big-ticket model facts (IndexTTS2 API, CosyVoice2
latency/MOS, VoxCPM2 architecture, Fish S2 license + 5B split, Kokoro 82M/StyleTTS2,
ChatTTS class/method names) all verified against current primary docs. However the
fact-api bar requires correctness on load-bearing specifics, and I found 2 hard factual
errors in the ACX spec set (one compiled into acx-check.sh -> false rejections), 1 wrong
control-token range in the ChatTTS reference, and 2 licensing/watermark accuracy gaps on
Chatterbox (a recommended GREEN/commercial-safe default). ACX compliance and commercial
license safety are the pack's two highest-stakes deterministic claims, so these clear the
threshold for meets_bar=false on this lens.

## Findings

### F1 (HIGH) — ACX channels: pack says MONO required / "stereo is auto-rejected"; ACX accepts mono OR stereo
audiobook-pipeline.md ACX spec #3 states "Channels: MONO (stereo is auto-rejected)" and
SKILL.md repeats "MONO". The cited primary source (help.acx.com submission-requirements)
states audio must be "all mono or all stereo" (consistent throughout) — stereo is NOT
rejected. Error is compiled into scripts/acx-check.sh (CHANNELS=1; hard-FAILs any non-mono
file). A correctly-mastered stereo audiobook would be falsely rejected by the gate that is
sold as replacing eyeballing.

### F2 (MEDIUM) — ACX head-silence contradicts the cited ACX page
ACX spec #7 says "Head silence: 0.5-1.0 s". The cited ACX submission-requirements page
specifies "between 1 and 5 seconds of room tone at the beginning AND end of each file"
(1-5s both ends). The 0.5-1.0s head figure is not what the cited source says.

### F3 (MEDIUM) — ChatTTS control-token ranges wrong (laugh/break documented as 0-9)
chattts-workflow.md parameter table lists [laugh_N] range 0-9 and [break_N] range 0-9.
Official 2noise/ChatTTS docs define oral_(0-9), laugh_(0-2), break_(0-7). Shipped presets
stay in range so generation won't fail, but the documented ranges are wrong and the prose
even references "搞笑 5+" for laugh — would mislead an agent into out-of-range tokens.

### F4 (MEDIUM) — Chatterbox watermarking omission (watermarks EVERY output by default)
licensing-safety.md Watermarking Traps flags only Fish S2 Pro. Chatterbox embeds a Perth
(Perceptual Threshold) neural watermark on every generated file by default (~100%
detection, survives MP3). Pack markets Chatterbox as GREEN/MIT "full commercial rights"
with no watermark caveat — a material missing disclosure on a recommended default tool, in
the exact section meant to catch this trap.

### F5 (LOW/MEDIUM) — Chatterbox param count inconsistent and likely wrong
tool-landscape.md lists Chatterbox "350M"; apple-silicon.md lists "350M-1.2B". Resemble
AI's primary description is a "0.5B Llama backbone." Internal figures disagree and neither
matches vendor's 0.5B. Low functional impact, but contradictory/unverified spec number.

### F6 (LOW, advisory) — IndexTTS2 emo_alpha sweep exceeds documented default range
voice-cloning.md recommends sweeping emo_alpha across 0 / 0.6 / 1.0 / 1.4. README documents
default 1.0 with stated 0.0-1.0 range. 1.4 may work as over-drive (labeled "over-driven,
may distort") and API accepts a float, so not a hard error; asserts a value beyond the
documented range without flagging it. Could not confirm explicit upper bound from HF card.

## fact_checks (each version-sensitive claim verified vs current primary docs)

1. IndexTTS2 infer() params (spk_audio_prompt, text, emo_audio_prompt, emo_alpha) — VERIFIED CORRECT vs github.com/index-tts/index-tts README (2026-06-13). emo_vector/use_emo_text also present.
2. IndexTTS2 "duration control NOT yet enabled in current release" — VERIFIED CORRECT; README: "This functionality is not yet enabled in this release," despite arXiv title headlining Duration-Controlled.
3. IndexTTS2 CUDA 12.8+ — VERIFIED CORRECT.
4. IndexTTS2 uv mandatory + FP16 supported — VERIFIED CORRECT.
5. IndexTTS2 arXiv 2506.21619 + Bilibili IndexTeam — VERIFIED CORRECT.
6. IndexTTS2 emo_alpha range — PARTIAL: default 1.0, doc 0.0-1.0; pack sweeps to 1.4 (F6).
7. CosyVoice2-0.5B ~150ms first-packet streaming — VERIFIED CORRECT (funaudiollm.github.io/cosyvoice2 + arXiv 2412.10117).
8. CosyVoice2 MOS 5.4 -> 5.53 — VERIFIED CORRECT.
9. CosyVoice2 18+ Chinese dialects + cross-lingual — VERIFIED CONSISTENT.
10. VoxCPM2 2B, tokenizer-free diffusion-AR, voice design, 30 langs, Apache-2.0 — VERIFIED CORRECT (OpenBMB/VoxCPM, HF openbmb/VoxCPM2). 48kHz confirmed.
11. VoxCPM2 RTF 0.13 with Nano-vLLM — VERIFIED CORRECT (~0.13 on RTX 4090 via Nano-vLLM).
12. Fish S2-Pro 5B total (4B slow-AR + 400M fast-AR), 10M+ hrs / 80+ langs — VERIFIED CORRECT (fish.audio blog, HF fishaudio/s2-pro).
13. Fish Audio Research License (non-commercial free; commercial incl. self-hosted needs business@fish.audio) — VERIFIED CORRECT; pack's VERIFIED-NO-CHANGE note accurate.
14. Kokoro 82M, Apache-2.0, StyleTTS2 — VERIFIED CORRECT (HF hexgrad/Kokoro-82M).
15. ChatTTS class/method names Chat()/.load()/sample_random_speaker()/InferCodeParams(spk_emb,temperature,top_P,top_K)/RefineTextParams(prompt) — VERIFIED CORRECT (2noise/ChatTTS, PyPI chattts).
16. ChatTTS [oral_N] 0-9 — VERIFIED CORRECT; [laugh_N]/[break_N] ranges WRONG (F3: laugh 0-2, break 0-7).
17. ChatTTS CC BY-NC 4.0 non-commercial — VERIFIED CONSISTENT.
18. XTTS-v2 non-commercial — VERIFIED CORRECT; precise name Coqui Public Model License (CPML) 1.0.0. Pack RED/Non-Commercial substantively correct.
19. Chatterbox MIT + Resemble AI — VERIFIED CORRECT, but mandatory Perth watermark omitted (F4) and param count 0.5B Llama backbone not 350M (F5).
20. ACX RMS -23..-18, peak <-3, noise floor <-60, 44.1kHz, 192kbps+ CBR MP3 — VERIFIED CORRECT (help.acx.com, 2026-06-13).
21. ACX channels MONO-only / stereo-rejected — WRONG (F1): ACX accepts all-mono OR all-stereo. Error compiled into acx-check.sh.
22. ACX head silence 0.5-1.0s — WRONG vs cited page (F2): 1-5s room tone both ends.
23. Podcast LUFS: Apple -16, Spotify -14, YouTube -14, EBU R128 -23, TP <= -1 dBTP — VERIFIED CORRECT. Apple mono -19 plausible.
24. FFmpeg two-pass loudnorm (print_format=json, measured_I/TP/LRA/offset/linear=true) — VERIFIED CORRECT.
