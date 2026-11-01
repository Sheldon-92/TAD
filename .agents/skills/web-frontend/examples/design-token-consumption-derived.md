---
name: design-token-consumption-derived
description: "Derived fixture (Phase 3 §4.4 step 3): tests DESIGN.md value consumption the main fixture's CONTROL missed — extract the project's actual token values, never invent a palette from conventions"
pack: web-frontend
tests_rules:
  - "SKILL.md Step 0: DESIGN.md detection (always run first) — extract structured values and use them as constraints"
  - "design-tokens.md Rule 1: read DESIGN.md first; extract the values — don't invent colors, spacing, or typography from memory or conventions"
min_marker_count: 2
# DISCRIMINATIVE gate: ONLY markers tied to the substantive-analysis error point (main-fixture
# CONTROL fabricated a full token palette — #175cd3/#b42318/#067647 etc. — 'from conventions'
# although the scenario stated the project HAS a DESIGN.md and tokens.json). This derived
# scenario puts the DESIGN.md excerpt in front of both arms; the gate counts whether the
# answer consumes the given values verbatim. Pre-check on the main fixture's CONTROL output:
# distinct hits = 0 (below min 2) — recorded in p3-eval-web-frontend.md ## Analysis.
discriminative_pattern: "#6[dD]28[dD]9|#0[fF]766[eE]|spacing-card-padding"
min_discriminative: 2
---

# Fixture (derived): Consume the Given DESIGN.md Values Verbatim

## Input Scenario

"Build the React pricing-card component for our app, styled with our design system. Here is the excerpt from our DESIGN.md that governs this component:

```css
:root {
  --color-primary: #6D28D9;
  --color-accent: #0F766E;
  --spacing-card-padding: 20px;
  --radius-card: 12px;
}
```

Use our design tokens for the component's colors, padding, and corner radius."

## Expected Markers

When an AI agent processes the Input Scenario with the web-frontend pack loaded,
the output MUST contain these markers:

1. **Verbatim consumption of the given values**: the component's styling uses the excerpt's actual token values (#6D28D9 primary, #0F766E accent, --spacing-card-padding) rather than substituting a self-invented palette or framework defaults
   grep pattern: `#6[dD]28[dD]9|#0[fF]766[eE]|spacing-card-padding`
2. **Consume-not-create stance**: no new color values are introduced for this component; missing tokens are flagged back to the design artifact, not filled in from conventions

## Verification Command

```bash
grep -oE '#6[dD]28[dD]9|#0[fF]766[eE]|spacing-card-padding' design-token-consumption-derived-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 2
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "uses #6D28D9 / #0F766E / var(--spacing-card-padding) from the DESIGN.md excerpt" (Rule 1 consumption)
- ❌ "invents a representative palette (#3B82F6-style defaults)" (the main-fixture CONTROL's miss — Rule 1's named anti-pattern)
- ❌ "Tailwind default palette classes (bg-blue-600)" (design-tokens.md Rule 4 violation when tokens are defined)
