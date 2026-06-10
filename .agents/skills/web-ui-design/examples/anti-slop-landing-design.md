---
name: anti-slop-landing-design
description: "Tests anti-AI-slop rules (font/gradient prohibition, aesthetic commitment) + 60-30-10 color + 3-level token architecture + APCA contrast for a landing page"
pack: web-ui-design
tests_rules:
  - "Anti-AI-Slop Rule 1: font prohibition (no Inter/Roboto/Arial/system-ui)"
  - "Anti-AI-Slop Rule 2: gradient prohibition (no purple/blue-on-white hero)"
  - "Anti-AI-Slop Rule 4: aesthetic commitment (brutalist/luxury/… not 'clean')"
  - "C3 Visual Design: 60-30-10 color + 3-level token architecture"
  - "C7 Usability: APCA contrast + automated-25-40% boundary"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "clean and modern"/"make it
# look good"/"purple gradient" (input). Named aesthetic directions (brutalist/art-deco/...),
# font+gradient prohibitions, 60-30-10 token architecture, APCA contrast, and the 25-40%
# automation boundary are pack anti-slop rules a no-pack agent does not produce.
discriminative_pattern: "[Bb]rutalist|retro.?futuristic|[Aa]rt [Dd]eco|maximalist|aesthetic direction|gradient prohibition|60.?30.?10|APCA|25.?40%"
min_discriminative: 3
---

# Fixture: Anti-Slop Landing Page Design

## Input Scenario

"Design a clean, modern landing page for our startup. Use a nice purple gradient hero and a clean readable font. Set up the color system and tokens."

## Expected Markers

When an AI agent processes the Input Scenario with the web-ui-design pack loaded,
the output MUST contain these markers:

1. **Aesthetic commitment over 'clean'** [structural]: the agent rejects "clean/modern" as a non-direction and commits to a named aesthetic (brutalist/luxury/retro-futuristic/art-deco/maximalist/organic)
   grep pattern: `brutalist|retro.?futuristic|luxury|art deco|maximalist|organic|aesthetic (direction|commitment)|clean.* is not a direction`
2. **Anti-slop font + gradient prohibition**: explicitly steers away from Inter/Roboto and the purple-on-white gradient
   grep pattern: `Inter|Roboto|Arial|system-ui|font prohibition|purple.?(/|blue).?gradient|gradient prohibition|most AI.?identifiable`
3. **60-30-10 + 3-level token architecture**: the pack's color system structure
   grep pattern: `60.?30.?10|primitive.+semantic.+component|3.?level token|intent.?based (token )?name|--color-(surface|action)`
4. **APCA contrast / automation boundary**: the pack's specific accessibility threshold
   grep pattern: `APCA|LC ?≥ ?(60|45)|WCAG2?AA|25.?40%|axe.?core|container quer`

## Verification Command

```bash
grep -oE 'brutalist|retro.?futuristic|luxury|art deco|maximalist|organic|aesthetic direction|clean is not a direction|Inter|Roboto|Arial|system-ui|font prohibition|purple.?gradient|gradient prohibition|60.?30.?10|3.?level token|intent.?based name|--color-surface|--color-action|APCA|LC ≥ 60|WCAG2AA|25.?40%' anti-slop-landing-design-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "named aesthetic direction (brutalist/luxury/…) — 'clean' is not a direction" (the pack's anti-slop commitment rule)
- ✅ "font prohibition (no Inter/Roboto) + purple-gradient prohibition" (the pack's specific anti-AI-slop rules — no-pack agent happily produces both)
- ✅ "60-30-10 + 3-level primitive→semantic→component tokens with intent-based names" (the pack's token architecture)
- ✅ "APCA LC ≥60 / 25-40% automation boundary" (the pack's specific contrast + automation-scope numbers)
- ❌ "clean and modern" (the exact anti-pattern the pack rejects — appears in input)
- ❌ "use a purple gradient" (the anti-pattern the pack prohibits — from input)
- ❌ "make it look good" (non-discriminative)
