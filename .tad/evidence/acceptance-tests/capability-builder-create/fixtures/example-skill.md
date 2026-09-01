---
name: example-skill-fixture
skill: example-skill
discriminative_pattern: 'EXAMPLE_RULE_ALPHA|EXAMPLE_THRESHOLD_42|EXAMPLE_EXIT_99'
min_discriminative: 3
---

# Fixture: Example Skill Behavioral Proof

## Input Scenario

Using the single canonical prompt at `.tad/evidence/acceptance-tests/capability-builder-create/prompt/task.md`, produce a design output.

## Expected Markers

A WITH-Skill run must contain all three discriminative markers:
- `EXAMPLE_RULE_ALPHA` — named alpha rule
- `EXAMPLE_THRESHOLD_42` — 42-unit threshold
- `EXAMPLE_EXIT_99` — exit token

## Verification Command

```bash
grep -oE 'EXAMPLE_RULE_ALPHA|EXAMPLE_THRESHOLD_42|EXAMPLE_EXIT_99' "${OUTPUT_FILE}" | sort -u | wc -l
```
