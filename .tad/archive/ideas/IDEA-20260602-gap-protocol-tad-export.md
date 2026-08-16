# Idea: GitAgent Protocol (GAP) Export for TAD Cross-Platform Portability

**ID:** IDEA-20260602-gap-protocol-tad-export
**Date:** 2026-06-02
**Status:** captured
**Scope:** large

---

## Summary & Problem

TAD's .tad/ directory structure (config.yaml, project-knowledge/, skills/, hooks/) maps closely to GitAgent Protocol's agent format (agent.yaml, memory/, skills/, hooks/). Exporting TAD as a GAP-compatible repo would enable TAD skills and knowledge to run on non-Claude runtimes (Cursor, OpenClaw, Codex, Gemini CLI) without per-platform adaptation. This supports the "TAD as universal method" direction.

## Open Questions

- How much of TAD's protocol logic (Socratic Inquiry, Gate system, Ralph Loop) is Claude-specific vs framework-agnostic?
- GAP's agent.yaml is much simpler than TAD's config.yaml module system — what's the right mapping?
- Does GAP's SOUL.md + RULES.md split map better to CLAUDE.md (combined) or to Alex/Blake separate SKILLs?
- Would the export be one-way (TAD → GAP read-only) or bidirectional (GAP agents can import into TAD)?
- GAP is still v0.1.0 spec — is it stable enough to build against?

## Notes

- Source: AI Tinkerers #29 (2026-06-01), consulting-os presentation by Sean Cofoid
- GitAgent repo: https://github.com/open-gitagent/gitagent
- GAP Protocol spec: https://www.gitagent.sh/
- Research findings: .tad/evidence/research/newsletter-29-inspiration/2026-06-02-findings.md
- GAP exports to: Claude Code, Codex, Gemini CLI, Cursor, OpenClaw, Lyzr Agent, CrewAgent, Agents SDK
- TAD already has Codex-edition SKILLs (.tad/codex/) — GAP could be a more general version of that pattern

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled by *idea promote)
