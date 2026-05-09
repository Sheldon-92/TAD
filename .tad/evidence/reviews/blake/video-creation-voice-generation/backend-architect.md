# Backend Architecture Review — video-creation-voice-generation

**Date:** 2026-05-08
**Reviewer:** backend-architect (sub-agent, 2 rounds)
**Handoff:** HANDOFF-20260508-video-creation-voice-generation.md

## Round 1 Verdict: FAIL (1 P0, 2 P1)
## Round 2 Verdict: PASS (all fixed, no regressions)

## BA Constraints Verified
| Constraint | Status |
|-----------|--------|
| BA-P0-1 (TTS sync vs Seedance async) | ✅ Correctly documented |
| BA-P0-3 (Consent gate mandatory before clone) | ✅ Correctly positioned |
| BA-P1-1 (WAV/PCM format) | ✅ Fish Audio native WAV/PCM via TTSRequest.format |
| BA-P1-3 (Seedance + TTS collision) | ✅ With clarified FFmpeg approach |
| BA-P1-4 (Serialize TTS + 429 backoff 10s) | ✅ Correctly documented |
| BA-P1-5 (voice_id lifecycle + 404) | ✅ Correctly documented |

## Round 1 P0/P1 Findings (all fixed in Round 2)

**P0-1 FIXED**: Fish Audio SDK `with session.tts() as response:` — invalid context manager.
Fixed to: `for chunk in session.tts(request):` with inline comment explaining the difference.

**P1-1 FIXED**: Fish Audio claimed MP3-only. Fish Audio natively supports WAV and PCM via `TTSRequest(format="wav", sample_rate=44100)`. Tool Comparison Table updated. Format Recommendation corrected. Transcode step now marked legacy-only.

**P1-2 FIXED**: ElevenLabs SFX `loop=true` requires `model_id="eleven_text_to_sound_v2"`. Added to bullet point and code example.

## P2 Items (applied where appropriate)
- P2-1: Fish Audio CJK pricing math corrected (1M UTF-8 bytes = ~333K CJK chars, not 60K)
- P2-2: Fish Audio `reference_id` vs `references` mutual exclusivity documented
- P2-3: `import fish_audio_sdk` redundant import removed
- Seedance collision FFmpeg: clarified "recommended: re-generate clip" vs "alternative: mute all audio"
