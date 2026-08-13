---
name: audiobook-tool-selection
description: "Tests reference-duration table + ACX spec numbers + voice-identity persistence + Apple Silicon VRAM rule for a long-form audiobook on a 16GB Mac"
pack: ai-voice-production
tests_rules:
  - "Voice Cloning §Reference Duration Table (3s-15s per tool)"
  - "Audiobook Pipeline §ACX/Audible Specifications"
  - "ChatTTS/Voice Persistence — save .pt voice identity"
  - "Apple Silicon §16GB Memory Budget + MPS workarounds"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "TTS"/"audiobook". The exact
# ACX/Audible mastering spec (RMS dB / 44.1kHz / 192kbps / mono), the two-pass loudnorm LUFS/dBTP
# numbers, .pt speaker-embedding + seed-reset voice-consistency primitive, MPS/float32
# Apple-Silicon rules, and the new tool APIs (IndexTTS2 emo_alpha, CosyVoice2 ~150ms streaming)
# are all pack-introduced specifics no agent emits without this pack.
discriminative_pattern: "ACX|44\\.1kHz|192kbps|RMS -2[0-9]|-23 to -18|dBTP|LUFS|loudnorm|emo_alpha|150ms|speaker embedding|seed reset|MPS|float32"
min_discriminative: 3
---

# Fixture: Audiobook Tool Selection on 16GB Mac

## Input Scenario

"I want to narrate a 120,000-word audiobook with a single consistent cloned voice, on my 16GB M-series Mac, and publish it to Audible. Which tool and pipeline?"

## Expected Markers

When an AI agent processes the Input Scenario with the ai-voice-production pack loaded,
the output MUST contain these markers:

1. **Per-tool reference-duration minimum** [structural]: the agent cites a specific minimum-reference-audio duration for the cloning tool (3s-15s range), not a vague "a short sample"
   grep pattern: `[0-9]+ ?s (reference|minimum|of audio)|reference duration|3s|5s|6s|10s|15s|minimum reference`
2. **ACX / Audible spec numbers**: the pack's concrete mastering targets
   grep pattern: `ACX|44\.1 ?kHz|192 ?kbps|RMS -2[0-9]|-23 to -18|peak -3`
3. **Voice-identity persistence**: saving/loading a voice embedding for cross-chapter consistency
   grep pattern: `\.pt|voice identity|speaker embedding|save.+voice|seed (reset|42)|cross.?session`
4. **Apple Silicon VRAM / MPS rule**: the 16GB budget table + MPS workarounds
   grep pattern: `16GB|VRAM|MPS|PYTORCH_ENABLE_MPS_FALLBACK|float32|Apple Silicon`
5. **Platform loudness numbers** [if podcast/streaming distribution is in scope]: integrated LUFS band + true peak
   grep pattern: `-16 LUFS|-19 LUFS|-14 LUFS|-23 LUFS|dBTP|two-pass|loudnorm`

## Verification Command

```bash
grep -oE 'reference duration|minimum reference|3s|5s|6s|10s|15s reference|ACX|44\.1 ?kHz|192 ?kbps|RMS -2[0-9]|-23 to -18|dBTP|LUFS|loudnorm|emo_alpha|150ms|\.pt|voice identity|speaker embedding|seed reset|16GB|MPS|PYTORCH_ENABLE_MPS_FALLBACK|float32' audiobook-tool-selection-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "ACX 44.1kHz / 192kbps / mono / RMS -23 to -18 dB" (the pack's exact 8-spec Audible mastering set)
- ✅ "per-tool reference duration 3s-15s" (the pack's voice-cloning minimum-duration table)
- ✅ ".pt speaker embedding / seed reset" (the pack's cross-session voice-consistency primitive)
- ✅ "16GB VRAM budget + MPS fallback / float32" (the pack's Apple Silicon optimization rules)
- ✅ "-16 LUFS / -19 LUFS mono / <= -1 dBTP / two-pass loudnorm" (platform loudness — only on the distribution path)
- ✅ "IndexTTS2 emo_alpha 0.9 / CosyVoice2 ~150ms first packet" (the pack's newly researched tool APIs)
- ❌ "use a TTS tool" (generic — any agent says this)
- ❌ "make it sound good" (non-discriminative)
- ❌ "audiobook" (in the input)
