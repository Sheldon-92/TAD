# Canonical Task — Example Skill Behavioral Proof

**The same file is used for CONTROL and WITH. The only delta is Skill availability.**

Produce a one-page design decision for the fixture-project's example bounded task.

Constraints:
- Output must be a plain markdown file.
- Do not change the prompt between runs.
- CONTROL is the no-Skill run; WITH is the Skill-enabled run that must apply the skill's named rules and thresholds.

Discriminative expectation for WITH (checked by `fixtures/example-skill.md`):
- Must contain `EXAMPLE_RULE_ALPHA`, `EXAMPLE_THRESHOLD_42`, `EXAMPLE_EXIT_99` (3/3 → PASS).
- CONTROL must contain 0/3 → FAIL. Generic quality language does not suffice.
