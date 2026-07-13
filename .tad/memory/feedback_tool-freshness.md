---
name: Tool Freshness Problem in Domain Pack
description: Claude doesn't know about new tools. Domain Pack must teach Claude about tools AND keep the list current.
type: feedback
---

Claude's knowledge has a cutoff — it does NOT know about new MCP servers, CLI tools, or APIs released after training. Domain Pack must:

1. **Teach Claude about unknown tools**: Each tool entry in domain.yaml must include enough detail (install command, usage pattern, example call, expected output) for Claude to use it even if it's never seen it before. Just listing a tool name is useless.

2. **Keep tool list current**: New tools appear weekly. Recommended approach for now: periodic manual research (Blake tool audit). Future: automated search or MCP marketplace integration.

**Why:** User correctly pointed out that Alex didn't know many tools had CLI versions until explicitly searching. Same applies to Claude — it can't discover tools it doesn't know exist. This is the core value of Harness Engineering: providing information the model's training data doesn't have.

**How to apply:** Every tool in domain.yaml needs: name, type, description, install command, usage pattern with example, expected output format. The "recommended" field will go stale, but the detailed usage info remains valuable.
