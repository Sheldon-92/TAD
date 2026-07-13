---
name: CLI-first Tool Design Preference
description: Domain Pack tools should be CLI-first, MCP only for stateful/remote scenarios — user confirmed this matches industry trend
type: feedback
---

Domain Pack tool integration should follow CLI-first, MCP-when-needed principle.

**Why:** MCP adds configuration overhead (server process, auth, JSON-RPC). Most local tools work better as CLI commands via BashTool. MCP is only justified for stateful interactions (DB connections, OAuth sessions), structured remote APIs (Linear, Figma), or when fine-grained permission control is needed.

**How to apply:** When designing Domain Packs, default to CLI tool integration (via CLAUDE.md/Skill instructions telling the model how to use the CLI). Only add MCP for tools that genuinely need persistent state or remote cloud APIs. The formula is: Skill + CLI/MCP + Hook + Knowledge + Gate.
