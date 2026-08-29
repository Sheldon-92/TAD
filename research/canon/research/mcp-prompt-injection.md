---
title: MCP Prompt Injection Defense
what: Techniques and defenses for prompt injection via MCP tool outputs
type: research
citable: false
explores:
  - ai-guardrails
topics:
  - ai-guardrails
  - mcp-servers
availability: open
verified_on: 2026-08-28
depth: cited
wiki_page: research/wiki/research/mcp-prompt-injection.md
raw_refs:
  - path: research/raw/papers/mcp-001.md
    locator: "p.2 / para 1"
    note: "injection taxonomy"
  - path: research/raw/articles/mcp-002.md
    locator: "para 4"
    note: "tool output sanitization"
  - path: research/raw/github/mcp-003.md
    locator: "timestamp 00:02:10"
    note: "awesome-mcp defense list"
provenance: "https://arxiv.org/abs/2401.00001"
---
MCP tools expose prompt injection via tool outputs that bypass system prompts.
Layered parsing isolates untrusted content before LLM ingestion.
Policy denies any tool output containing instruction-like tokens unless allowlisted.
Three sources converge on sanitize-then-verify as the baseline defense.
Reuse of this canon is tracked via generated indexes.
