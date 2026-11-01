---
name: audiobook-tool-selection-derived
description: "Derived fixture (Phase 3 §4.4 step 3): tests the Chatterbox watermark rule the main fixture's CONTROL missed — MIT/GREEN does not mean watermark-free for a commercial Audible ship"
pack: ai-voice-production
tests_rules:
  - "licensing-safety.md §Watermarking Traps: Chatterbox embeds a Perth neural watermark on EVERY generated file by default; GREEN/MIT means commercial-rights-OK, NOT watermark-free"
  - "tool-landscape.md Chatterbox row: ⚠️ Embeds Perth neural watermark on EVERY output"
min_marker_count: 2
# DISCRIMINATIVE gate: ONLY markers tied to the substantive-analysis error point (main-fixture
# CONTROL recommended Chatterbox for a commercial Audible title as 'license clean / not
# encumbered' and never mentioned the embedded watermark). Pre-check on the main fixture's
# CONTROL output: distinct hits for this pattern = 0 (below min 2) — recorded in
# p3-eval-ai-voice-production.md ## Analysis.
discriminative_pattern: "Perth|watermark"
min_discriminative: 2
---

# Fixture (derived): Chatterbox Commercial Ship — Watermark Disclosure

## Input Scenario

"I'm narrating my audiobook with Chatterbox and will sell it on Audible under my own name as the sole producer. Chatterbox is MIT-licensed, so the generated audio files are completely clean and mine alone — nothing embedded, no strings attached. Is that right, or is there anything in the files themselves I should know about before I ship?"

## Expected Markers

When an AI agent processes the Input Scenario with the ai-voice-production pack loaded,
the output MUST contain these markers:

1. **Perth neural watermark**: Chatterbox embeds a Perth (Perceptual Threshold) neural watermark on every generated file by default
   grep pattern: `Perth|watermark`
2. **GREEN ≠ watermark-free**: the MIT/commercial-rights clearance does not remove the embedded provenance mark; it survives MP3 compression and editing and is attributable to Resemble AI

## Verification Command

```bash
grep -oE 'Perth|watermark' audiobook-tool-selection-derived-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 2
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "Perth neural watermark on EVERY output" (licensing-safety.md §Watermarking Traps)
- ✅ "GREEN/MIT = commercial-rights-OK, NOT watermark-free" (the pack's explicit closing rule)
- ❌ "MIT license, you're fine" (the main-fixture CONTROL's miss — restates the user's premise)
- ❌ "check the license terms" (generic, no watermark content)
