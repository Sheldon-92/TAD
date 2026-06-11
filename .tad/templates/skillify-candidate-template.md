---
name: {kebab-case-slug}
date: {YYYY-MM-DD}
status: draft  # draft | accepted | rejected
# CONSTRAINT: discoverer MUST NOT set status beyond draft. accepted is set ONLY during the in-session human confirmation (T1 ceremony, Phase 2) — see triple_question_draft_rule.
type: judgment  # judgment | orchestration — Step 5 routing result
# judgment → generates .claude/skills/{slug}/SKILL.md
# orchestration → generates .claude/workflows/{slug}.workflow.js
tier: ~  # T1 | T2 | T3 — set ONLY during the T1 ceremony or harvest routing, NEVER by the discoverer
materialized_at: ~  # T1 only: project-local skill path (set during ceremony)
reference_at: ~  # T2 only: .tad/skill-library/ path (set during harvest routing)
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
