---
name: design-md-hidden-location
description: "Tests Step 0 detection at the third location: the project's design values exist only inside a scratch-tree file the scenario never names; the answer must consume those hidden values verbatim and flag the deliberately missing radius token instead of inventing one"
pack: web-frontend
tests_rules:
  - "SKILL.md Step 0: DESIGN.md detection (always run first) — locations in order: ./DESIGN.md, ./design/DESIGN.md, ./.design/DESIGN.md; extract structured values and use them as constraints"
  - "design-tokens consumption: read the design artifact first and consume its actual values — never invent colors, spacing, or radius from conventions; a missing token is flagged back to the design artifact, not filled in"
min_marker_count: 2
# DISCRIMINATIVE gate: ONLY values reachable solely by running the pack's Step 0 detection
# into the third location and extracting the file's token block — the two hex values and the
# spacing token name live ONLY in the scratch tree's .design/DESIGN.md (see ## Tree Spec),
# nowhere in this scenario; the fourth alternative proves the answer cites that hidden path
# as its value source. Generic CSS/React vocabulary is NEVER in this pattern.
discriminative_pattern: "#0[bB]7285|#5[fF]3[dD][cC]4|--spacing-card-padding|\\.design/DESIGN\\.md"
min_discriminative: 2
---

# Fixture: Consume Design Values Hidden at the Third Detection Location

## Input Scenario

"Build the React pricing-card component for our app. The project is at <WF_TREE_PATH> and it already has an established design system — style the component with that design system. The card needs rounded corners. Deliver the component code plus a short note on your styling choices."

## Expected Markers

When an AI agent processes the Input Scenario with this pack loaded,
the output MUST contain these markers (grep-verifiable):

1. **Verbatim consumption of the hidden token values**: the component's styling uses the design file's actual values — primary `#0B7285`, accent `#5F3DC4`, and the `--spacing-card-padding` token — rather than a self-invented palette or framework defaults
   grep pattern: `#0[bB]7285|#5[fF]3[dD][cC]4|--spacing-card-padding`
2. **Value source cited at the third detection location** [structural]: the styling note names `.design/DESIGN.md` as the file the consumed values were extracted from — proves the detection sequence ran past the first two locations and the answer's values are sourced, not recalled
   grep pattern: `\.design/DESIGN\.md`
3. **Missing-token handling (Analysis read, NOT in the runner pattern)**: the design file deliberately defines no radius token. The answer must flag the missing radius token back to the design artifact (consume-not-create) instead of silently inventing a radius value. Read by a human/reviewer into the eval record's Analysis section; the Outcome counts runner arms only.

## Verification Command

```bash
grep -oE '#0[bB]7285|#5[fF]3[dD][cC]4|--spacing-card-padding|\.design/DESIGN\.md' {output_file} | sort -u | wc -l | tr -d ' '
# Expected: ≥ 2
```

Formal verdict: `pack-eval-runner.sh` single-fixture form against this fixture — the
runner's verdict text (`→ PASS` / `→ FAIL`) is the criterion; its exit code is advisory (always 0).

## Tree Spec

Rebuild the scenario's project tree exactly as follows (the run binds `<WF_TREE_PATH>` to
the rebuilt tree's absolute path; this fixture itself carries no absolute path):

Tree layout:

```
<tree>/
  .design/DESIGN.md   (content verbatim below)
  src/                (placeholder directory; may hold a single empty .gitkeep)
  README.md           (one line, content verbatim below)
```

`.design/DESIGN.md` — full content, verbatim:

````markdown
# Project Design Tokens

Design tokens for this project. Consume these values; do not invent replacements.

```css
:root {
  --color-primary: #0B7285;
  --color-accent: #5F3DC4;
  --spacing-card-padding: 28px;
}
```
````

`README.md` — full content, verbatim (one line):

```
Pricing UI project (component source under src/).
```

Note: the DESIGN.md above deliberately contains NO radius token of any kind — that
absence is part of the test (Expected Marker 3).

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "#0B7285 / #5F3DC4" (this tree's token values — they exist in no training data and in no part of the scenario; only Step 0 detection + extraction reaches them)
- ✅ "--spacing-card-padding" (the tree's own token name, consumed verbatim)
- ✅ ".design/DESIGN.md" (the pack's third detection location, cited as the value source)
- ❌ "DESIGN.md" alone (a generic design-artifact word — any agent may mention one; only the third-location path is discriminative)
- ❌ "React / component / pricing card / rounded corners / border-radius" (words from the input scenario itself)
- ❌ "Tailwind default palette (bg-blue-600 etc.)" (the no-pack failure mode this fixture exists to catch, not a marker)
