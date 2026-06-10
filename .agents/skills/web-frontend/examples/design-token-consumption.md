---
name: design-token-consumption
description: "Tests DESIGN.md detection + token consumption (not creation) + container queries + RSC/component-boundary judgment for a React build"
pack: web-frontend
tests_rules:
  - "Step 0: DESIGN.md detection (always run first)"
  - "Interface contract: consume tokens, NEVER select colors/typography"
  - "Container queries for component responsiveness (not just media queries)"
  - "component-architecture.md: RSC / server-component boundary"
min_marker_count: 3
# DISCRIMINATIVE gate: ONLY pack-specific markers. Excludes generic "build a React component"/
# "make it responsive"/"use CSS". DESIGN.md+tokens.json consume-not-create contract,
# container-type/@container responsive rule, RSC/use-client boundary, and the defer-to-web-ui-design
# interface are pack-introduced (a no-pack agent hardcodes hex + uses media queries).
discriminative_pattern: "DESIGN\\.md|tokens\\.json|container-type|@container|RSC|use client|defer to web.?ui.?design"
min_discriminative: 3
---

# Fixture: React Build Consuming Design Tokens

## Input Scenario

"Build the React product-card component for our app. We have a DESIGN.md with CSS custom properties and a tokens.json. Make it responsive and split server vs client components correctly."

## Expected Markers

When an AI agent processes the Input Scenario with the web-frontend pack loaded,
the output MUST contain these markers:

1. **DESIGN.md detection + token consumption** [structural]: the agent FIRST checks for DESIGN.md / tokens.json and consumes `--color-*` / `--spacing-*` custom properties rather than inventing hex values
   grep pattern: `DESIGN\.md|tokens\.json|--color-|--spacing-|custom propert|DTCG|design token`
2. **Consume-not-create boundary**: the agent explicitly does NOT pick colors/typography (defers to web-ui-design)
   grep pattern: `consume(s)? (the )?(design )?(token|artifact)|NEVER (touch|select) (color|typograph)|defer.+(web.?ui.?design|design pack)`
3. **Container queries for component responsiveness**: not just viewport media queries
   grep pattern: `container quer|container-type|@container|component.?level responsive`
4. **RSC / server-vs-client boundary**: the component-architecture judgment
   grep pattern: `[Ss]erver component|RSC|use client|client boundary|server/client (split|boundary)`

## Verification Command

```bash
grep -oE 'DESIGN\.md|tokens\.json|--color-|--spacing-|custom property|DTCG|design token|consume the token|NEVER select color|defer to web.?ui.?design|container query|container-type|@container|server component|RSC|use client|client boundary' design-token-consumption-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 3
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "DESIGN.md detection + consume --color-*/tokens.json" (the pack's mandatory Step 0 — no-pack agent hardcodes hex)
- ✅ "consume-not-create: NEVER select colors, defer to web-ui-design" (the pack's interface contract)
- ✅ "container queries / container-type for component responsiveness" (the pack's specific responsive rule)
- ✅ "RSC / server-vs-client boundary" (the pack's component-architecture judgment)
- ❌ "build a React component" (restates the input)
- ❌ "make it responsive" (generic without container-query specificity)
- ❌ "use CSS" (non-discriminative)
