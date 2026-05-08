# AI Agent Architecture Capability Pack

A decision navigator for designing reliable agent systems. Guides any AI agent through 10 architectural decisions derived from 3 production systems and 7 real production disasters.

## What This Is

Most agent architecture resources list frameworks. This pack helps an AI agent (or a human) make **10 specific decisions** — each with a selection matrix that maps your constraints to a concrete pattern.

Every skipped decision has a documented production disaster. You either make the decision now, or you learn it from the disaster later.

## The 10 Decisions

| # | Decision | Core Question |
|---|----------|---------------|
| D1 | Need an Agent | Do you even need an agent, or will deterministic code suffice? |
| D2 | Coordination | How should agents coordinate and synchronize state? |
| D3 | Memory | How should context and memory be stored across sessions? |
| D4 | Tool Management | How to load and manage tools without token bloat? |
| D5 | Permissions & Safety | What is the agent allowed to do? How to secure MCP connections? |
| D6 | Context Compression | What happens when the context window fills up? |
| D7 | Cost Economics | How to control token cost and API budget at scale? |
| D8 | Observability | How to see what the agent is doing in production? |
| D9 | Testing | How to prove the agent behaves correctly when output is non-deterministic? |
| D10 | Production Disasters | What failures do these decisions prevent? |

## Two Modes

**`/design`** — Design a new agent system. Asks 5 scoping questions, then walks through applicable decisions with selection matrices. Outputs an Architecture Decision Document.

**`/audit`** — Audit an existing agent system. Checks each of D1–D10 against your current design. Outputs an Architecture Audit Report with risk assessment.

## Research Foundation

Built from analysis of 102+ sources across:
- **Claude Code** (Anthropic) — agent harness architecture, permission model, compression pipeline
- **OpenClaw** — multi-channel gateway, approval consumption, telemetry degradation
- **Hermes** (NousResearch) — self-evolution safety gates, dual-layer compression, memory routing
- **OWASP LLM Top 10** — security taxonomy for agent systems
- **Elastic Security Labs** — MCP attack patterns

## Installation

```bash
# Claude Code (Phase 1)
bash install.sh --agent=claude-code

# Dry run first
bash install.sh --agent=claude-code --dry-run
```

## License

Apache 2.0. See LICENSE and LICENSE-ATTRIBUTION.md for third-party credits.
