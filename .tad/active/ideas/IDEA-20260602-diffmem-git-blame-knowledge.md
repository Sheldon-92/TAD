# Idea: DiffMem-Style Git-Blame Tool for In-Session Knowledge Reasoning

**ID:** IDEA-20260602-diffmem-git-blame-knowledge
**Date:** 2026-06-02
**Status:** promoted
**Scope:** medium

---

## Summary & Problem

TAD's learning loop is cross-session only: trace events → *optimize batch analysis → proposals → human approval → next session. Blake has no way to query WHY a project-knowledge rule exists during the same session it encounters the rule. When a rule in `.tad/project-knowledge/architecture.md` causes a retry or seems inapplicable, Blake can only blindly follow or ignore — it cannot check "who added this rule, what handoff triggered it, what was the original context."

DiffMem (Growth-Kinetics/DiffMem) solves this by exposing `git log`, `git diff`, `git blame` as sandboxed tools. The agent queries its own knowledge history on-demand, enabling real-time temporal reasoning about its own memory.

**Concrete integration:** Give Blake a `git-blame-knowledge` MCP tool (or simple Bash wrapper) scoped to `.tad/project-knowledge/`. When Blake encounters a rule that seems wrong or inapplicable, it can:
1. `git blame .tad/project-knowledge/architecture.md` on the specific line → find the commit
2. `git log --oneline <commit>` → see which handoff/gate created the rule
3. Make an informed judgment (follow, adapt, or flag for review) instead of blind follow/ignore

This fills TAD's biggest gap: **in-session real-time learning** — from "static knowledge base" to "queryable memory system."

## Open Questions

- Should this be an MCP tool (persistent, available to all agents) or a Bash wrapper (simpler, in-session only)?
- Scope: just `.tad/project-knowledge/` or also `.claude/skills/` and `.tad/hooks/`?
- Should Blake auto-trigger git-blame when a Layer 1 retry is caused by a knowledge rule, or only on explicit need?
- How does this interact with the stale-knowledge-check.sh advisory tool?
- Token budget: git-blame output can be verbose — need a summary/filter layer?

## Notes

- Source: AI Tinkerers #29 (2026-06-01), DiffMem project by Growth-Kinetics
- DiffMem repo: https://github.com/Growth-Kinetics/DiffMem
- Also related: consulting-os (Sean Cofoid) — session-inline meta-heuristic learning loop
- Research findings: .tad/evidence/research/newsletter-29-inspiration/2026-06-02-findings.md
- NotebookLM deep ask confirmed: DiffMem's git-blame approach is the highest-ROI addition for in-session learning (Rank #2, 2-4 days effort)
- Prerequisite: #1 codebase-memory-mcp integration should land first (establishes the MCP tool pattern in TAD)
- Follow-up to: IDEA-20260602-gap-protocol-tad-export (GAP is the portability standard; this is the memory capability)

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: Handoff (via *analyze — 2026-06-02)
