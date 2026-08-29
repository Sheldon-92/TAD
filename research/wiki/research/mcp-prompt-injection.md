---
title: MCP Prompt Injection Defense — Wiki
topics:
  - ai-guardrails
  - mcp-servers
raw_refs:
  - path: research/raw/papers/mcp-001.md
    locator: "p.2 / para 1"
    note: "injection taxonomy"
  - path: research/raw/articles/mcp-002.md
    locator: "para 4"
    note: "sanitization delimiter"
  - path: research/raw/github/mcp-003.md
    locator: "timestamp 00:02:10"
    note: "defense allowlist"
source_canon: research/canon/research/mcp-prompt-injection.md
depth: cited
---

- MCP tool outputs can carry injected instructions that bypass system prompts [^research/raw/papers/mcp-001.md]
- Delimiter isolation sanitizes output before LLM ingestion [^research/raw/articles/mcp-002.md]
- Allowlist verification of tool commands blocks instruction-like tokens [^research/raw/github/mcp-003.md]
