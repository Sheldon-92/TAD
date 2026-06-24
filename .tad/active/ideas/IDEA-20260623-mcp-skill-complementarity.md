# IDEA: MCP + Skill File Complementarity Model

**Created**: 2026-06-23
**Source**: AI Tinkerers #32 — Maestro by Ady Ngom
**Status**: promoted
**Promoted To**: Epic phase (Community Pattern Adoption — 2026-06-23)
**Scope**: large (architecture direction)

## What

Formalize the relationship between TAD's skill files and MCP tools as complementary layers, not competing approaches. Skill files encode JUDGMENT (when/why to do X), MCP provides CAPABILITY (how to do X). Maestro validates this split works in production.

## Why

Maestro demonstrated MCP as a "separation of concerns" composition layer — independent packages composed via MCP, hot-swappable without redeployment. TAD already uses MCP tools (NotebookLM, codebase-memory, Claude-in-Chrome) but doesn't have a principled model for when to use skill files vs. MCP vs. both.

Current state: TAD's 25 capability packs are all skill files. Some contain tool-usage rules that could be MCP servers instead (e.g., research-notebook commands wrapping NotebookLM CLI).

## How it might work

1. Define the split: Skill = judgment rules + constraints + protocols. MCP = tool capabilities + data access + external integrations.
2. Audit current capability packs: which rules are judgment (keep in skill) vs. which are tool-wrapping (candidate for MCP)?
3. "Fast MCP wraps REST" pattern from Maestro — could apply to TAD's CLI wrappers (NotebookLM, Codex, Gemini)
4. Hot-swap benefit: adding a new research tool = new MCP server, no SKILL.md edit needed

## Evidence

- Maestro demo: MCP composition, Pandini, Avatar Generator, Fast MCP wrapping REST
- TAD current MCP usage: codebase-memory-mcp, claude-in-chrome, NotebookLM CLI (not MCP yet)
- Decision brief: .tad/evidence/research/agent-orchestration-patterns/2026-06-23-decision-brief-community-orchestration.md

## Risk

- MCP servers add operational complexity (startup, auth, process management)
- For single-user CLI (TAD's context), MCP overhead may not justify the hot-swap benefit
- L1 principle "Mechanical Enforcement Rejected on Single-User CLI" — MCP is a form of mechanical enforcement
- Need clear ROI before converting any skill to MCP
