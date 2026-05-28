# Idea: Declarative Agent Constraints — Separate Config from Judgment

**ID:** IDEA-20260528-declarative-agent-constraints
**Date:** 2026-05-28
**Status:** captured
**Scope:** large

---

## Summary & Problem

TAD currently encodes both mechanical constraints (permissions, step limits, forbidden actions) and judgment guidance (quality criteria, decision heuristics) in the same natural language SKILL.md files. This mixing causes two problems: (1) AI agents can "forget" or rationalize around text-based constraints, and (2) SKILL files grow to thousands of lines, making maintenance difficult. Borrowing from OpenCode's declarative agent config pattern — structured YAML for mechanical rules, natural language only for judgment — would make constraints enforceable rather than advisory.

Key insight from OpenCode deep research (2026-05-28): OpenCode uses `permission` (glob-pattern ACLs), `steps` (iteration cap), and `model` (per-agent model override) as structured frontmatter, while keeping system prompts as free-text. This separation means a `permission.edit: deny` physically prevents file edits, vs TAD's "Alex MUST NOT write implementation code" which relies on LLM compliance.

## Open Questions

- What schema for a `constraints:` block in SKILL.md frontmatter? (permission, steps, forbidden_tools, scope_limits)
- How much of the existing `forbidden_implementations` text can migrate to config vs must stay as judgment guidance?
- Does Claude Code's settings.json already support enough granularity, or does TAD need its own constraint layer on top?
- Migration path: can we do incremental (one SKILL at a time) or does it need to be atomic?
- Cross-platform: would OpenCode/Codex parse and respect the same frontmatter schema?

## Notes

- Source: OpenCode (github.com/anomalyco/opencode) — 166K stars, TypeScript, MIT
- OpenCode's `.opencode/agents/*.md` format: YAML frontmatter (permission, steps, temperature, model, description) + markdown body (system prompt)
- OpenCode actively supports `.claude/skills/` path compatibility — SKILL.md is becoming a cross-platform standard
- TAD architecture.md entry "Mechanical Enforcement Rejected on Single-User CLI" (2026-04-15) is relevant — user previously rejected hook-based enforcement, but declarative config is lighter than hooks
- Related ideas: IDEA-20260527-agent-adapter-pattern (agent portability), IDEA-20260527-tad-methodology-skeleton (methodology extraction)
- Three concrete wins: (1) sub-agent `steps` cap prevents runaway loops, (2) `permission` replaces 30+ forbidden_implementations lines, (3) structured config is parseable by other platforms

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
