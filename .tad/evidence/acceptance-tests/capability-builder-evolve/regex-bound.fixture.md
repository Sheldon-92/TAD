---
name: regex-bound
skill: example-skill
discriminative_pattern: '(a+)+$'
min_discriminative: 1
---

# Fixture: Regex Bound (catastrophic pattern + oversize output)

## Input Scenario

Evil pattern with oversize output to prove size-cap bounding (deterministic, no timing claim; BSD/macOS grep is DFA).

## Verification Command

```bash
grep -oE '(a+)+$' "${OUTPUT_FILE}" | sort -u | wc -l
```
