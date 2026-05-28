---
name: "{scenario-slug}"
description: "{one-line: what this fixture tests}"
pack: "{pack-name}"
tests_rules:
  - "{Quick Rule Index entry 1}"
  - "{Quick Rule Index entry 2}"
min_marker_count: 3
---

# Fixture: {Scenario Title}

## Input Scenario

"{User task description — exactly what a user would say to trigger this pack}"

## Expected Markers

When an AI agent processes the Input Scenario with this pack loaded,
the output MUST contain these markers (grep-verifiable):

1. **{Marker name}**: {description of what to look for}
   grep pattern: `{regex}`
2. **{Marker name}** [structural]: {description — verifies output structure, not just vocabulary}
   grep pattern: `{regex}`

At least one marker MUST be [structural] — distinguishes "applied the rule" from "mentioned the rule".

## Verification Command

```bash
grep -oE '{pattern1}|{pattern2}|...' {output_file} | sort -u | wc -l | tr -d ' '
# Expected: ≥ {min_marker_count}
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "{pack-specific term}" ({why it's pack-specific})
- ❌ "{generic term}" ({why it fails anti-slop — any AI would say this})
