# Attribution and Third-Party Credits

This capability pack was built on research from the following systems and organizations.
Their work directly shaped the decision matrices and rules in this pack.

---

## Anthropic — Claude Code

**License**: Apache 2.0 (Anthropic, 2024)
**Source**: Claude Code architecture analysis, session-based agent harness design
**Contribution to this pack**:
- 98.4% harness / 1.6% AI logic architecture principle (D1)
- Deny-first permission model with independent failure modes (D5)
- 5-layer graduated context compression pipeline (D6)
- Zero-cost extension hierarchy: Hooks → Skills → Plugins → MCP (D4, D7)
- SkillTool vs AgentTool cost trade-off (~7x token isolation) (D1, D7)
- File-based memory with no vector DB (D3)
- Permission boundaries per session (D5)
- JSONL append-only audit logging (D8)

---

## OpenClaw — Multi-Channel Agent Gateway

**License**: MIT
**Source**: OpenClaw agent gateway source code analysis (14 sources, NotebookLM notebook 44a28f1c)
**Contribution to this pack**:
- Atomic approval consumption with one-time tokens (D5)
- Hierarchical routing fallback (peer → guild → team → account → channel) (D2)
- Closed-by-default ingress with explicit operator pairing (D5)
- Context-aware sandboxing (D5)
- Graceful telemetry degradation to safe defaults (D8)
- Stream context limits for continuous multi-user channels (D3)
- Pending delivery persistence across network failures (D2)
- Plugin isolation from core engine (D4)

---

## NousResearch — Hermes Agent System

**License**: MIT / Apache 2.0 (NousResearch)
**Source**: Hermes runtime, GEPA self-evolution, memory system, compression pipeline (16 sources, NotebookLM notebook 8ccf8d90)
**Contribution to this pack**:
- 5-gate self-evolution safety (test pass + size limit + cache compat + semantic preservation + human review) (D1)
- Dual-layer compression triggers (50% + 85%) with anti-thrashing (D6)
- Pre-LLM output pruning: strip tool outputs >200 chars to metadata (D6)
- Atomic tool_call/tool_result boundaries during compression (D6)
- Memory vs Skill routing: facts → memory, procedures → skills (D3)
- Single-active memory backend to prevent conflicting truth sources (D3)
- Tool-use enforcement: agent must execute in same response as statement (D4)
- Iterative summary updates (pass previous summary + new turns) (D6)

---

## OWASP — Open Web Application Security Project

**License**: Creative Commons Attribution-ShareAlike 4.0
**Source**: OWASP LLM Top 10, agent security guidance
**Contribution to this pack**:
- Dual-agent architecture for untrusted data (privileged Planner + unprivileged Parser) (D5)
- Lethal trifecta detection: data access + untrusted ingestion + external communication (D5)
- Output handling: treat all LLM output as untrusted input requiring validation (D5)
- Indirect prompt injection taxonomy and mitigations (D5, D10)

---

## Elastic — Security Research

**License**: Elastic License 2.0
**Source**: Elastic Security Labs MCP security research (2025)
**Contribution to this pack**:
- MCP tool poisoning attack taxonomy (D5)
- Cross-server dataflow boundary requirements (D5, D10)
- Hidden `<IMPORTANT>` tag attack vector documentation (D5, D10)

---

## Invariant Labs — MCP Security Research

**License**: Research publication
**Source**: MCP security analysis and tool shadowing documentation
**Contribution to this pack**:
- Tool shadowing attack patterns across MCP servers (D5)
- Cross-server trust boundary violations (D5)

---

## Anthropic — "Building Effective Agents" Guide

**License**: Anthropic (2024)
**Source**: Anthropic's official agent design guide
**Contribution to this pack**:
- 6-pattern agent coordination taxonomy (D2):
  - Prompt Chaining, Routing, Parallelization, Orchestrator-Workers, Evaluator-Optimizer, Autonomous
- Selection criteria for each pattern (D2)

---

## Production Incident Sources

The 7 production disasters documented in `references/production-disasters.md` are drawn from:
- PocketOS incident: public post-mortem (Railway + AI agent wipe)
- Cursor MCP poisoning: public security disclosure (2024)
- Email hijacking: VulnerableMCP research disclosure
- E-commerce stale state: agent coordination failure patterns (multiple sources)
- Support ticket race: hub-spoke anti-pattern documentation
- Financial ordering: causal consistency research
- Double-charging: idempotency failure patterns in distributed systems

---

## Research Infrastructure

- **NotebookLM**: knowledge synthesis across 102+ sources
- **Research corpus**: 5 specialized subagents + 4 domain notebooks
