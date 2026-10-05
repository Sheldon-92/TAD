---
name: example-skill
description: Example project-owned skill for capability-builder acceptance testing with structural markers.
---

# Example Skill

This is a minimal project-owned Agent Skill used as the downstream fixture for the Capability Builder Phase 1 acceptance driver. It intentionally carries the discriminative markers that the behavioral fixture asserts.

## Vision

Provide a reproducible, capability-specific outcome for a bounded example task: a design decision that a without-skill agent will not emit.

## Execution

When given the canonical example task (`prompt/task.md`), an agent with this skill loaded MUST:

- Apply `EXAMPLE_RULE_ALPHA` (the skill's named alpha rule — not a generic term).
- Enforce `EXAMPLE_THRESHOLD_42` (the 42-unit threshold the skill introduces).
- Emit `EXAMPLE_EXIT_99` as the terminal verification token.

The skill places these markers as output-shape evidence — generic quality language alone does not satisfy the fixture.

## Validation

Exit condition for the fixture is `disc >= 3`:

```bash
grep -oE 'EXAMPLE_RULE_ALPHA|EXAMPLE_THRESHOLD_42|EXAMPLE_EXIT_99' "${OUTPUT_FILE}" | sort -u | wc -l
```

## Notes

- Canonical location: `.agents/skills/example-skill/` (project authority).
- Projection target: `.claude/skills/example-skill/` (generated, byte-identical).
- No `CAPABILITY.md`, no root `README.md`/`CHANGELOG.md`, no `install.sh`.
