---
name: {kebab-case-slug}
date: {YYYY-MM-DD}
status: pending  # pending | accepted | rejected
source: {handoff slug or "session-explicit"}
trigger_conditions: "{what scenario triggers this pattern}"
reusable: true
non_trivial: true
verified: true
not_already_captured: true
---

## Pattern: {Pattern Name}

### When to Use
{Trigger conditions description — when should an agent apply this pattern}

### Steps
1. {Step 1}
2. {Step 2}
3. {Step 3}

### Quality Criteria
- {Quality standard 1}
- {Quality standard 2}

### Anti-Patterns
- {Anti-pattern 1 — what NOT to do}

## Evidence
- Source handoff: {HANDOFF-{date}-{slug}.md or "current session"}
- Gate 3 result: {PASS / N/A for explicit *skillify}
- Key files: {key file paths involved}

## Proposed Skill Outline
If accepted, SKILL.md should contain:
- name: {slug}
- description: {one-line description}
- triggers: [{trigger phrase 1}, {trigger phrase 2}]
- Body: {above Steps + Quality Criteria + Anti-Patterns}
