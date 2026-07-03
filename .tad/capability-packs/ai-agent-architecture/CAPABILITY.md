---
name: ai-agent-architecture
description: "Decision navigator for designing reliable agent systems. Guides AI agents through 10 architectural decisions derived from 3 production systems and 7 real production disasters, with /design and /audit modes. Use for any agent architecture design, system audit, or production reliability planning task."
keywords: ["agent", "AI agent", "multi-agent", "MCP", "tool use", "architecture", "智能体", "代理", "agent 设计", "工具调用", "架构"]
type: reference-based
---

**CONSUMES**: User agent system requirements or existing agent codebase
**PRODUCES**: 10 architecture decisions + design document or audit report with P0/P1/P2 findings

# AI Agent Architecture

A decision-by-decision navigator for building reliable agent systems. Each decision has a selection matrix derived from production systems. Each skipped decision has a documented production disaster.

**Audience**: AI agents designing other agent systems.

**Two modes**:
- `/design` — Walk through D1–D10 for a new system
- `/audit` — Check an existing system against all 10 decisions

---

## How to Use This Pack

**On activation**, detect the user's intent:
- Contains: "design / build / create / new agent / architect" → enter `/design` mode
- Contains: "review / audit / check / existing / evaluate" → enter `/audit` mode
- Ambiguous → ask: "Are you designing a new agent system or auditing an existing one?"

---

## /design Mode

### Phase 0 — Scoping (Ask BEFORE reading any reference file)

Ask the following 5 questions. Collect all answers before proceeding to Phase 1.

**Q1** — Scale: Single agent or multi-agent system?
- Single agent → D2 (coordination) is likely skipped
- Multi-agent → D2 is mandatory

**Q2** — Session model: Stateful (long sessions, multi-turn continuity) or stateless (single-turn, ephemeral)?
- Stateless → D3 (memory) may be skipped, simplified D6 (compression) sufficient
- Stateful → D3 and D6 are mandatory

**Q3** — Input trust boundary: Trusted inputs only (internal systems, authenticated users) or untrusted external data (web, email, third-party APIs)?
- Trusted only → D5 (permissions) is simplified, MCP checklist optional
- Untrusted external → D5 MCP checklist is mandatory, dual-agent architecture required

**Q4** — Context budget: Small model (<128K context) or large context model (≥512K)?
- Small → D6 (compression) is critical, D3 memory pattern selection is strict
- Large → D6 triggers are relaxed, but still required

**Q5** — Cost sensitivity: Hobby/prototype or production at scale (>1K sessions/day)?
- Prototype → D7 (cost) optional, D8 (observability) minimal
- Production → D7 and D8 are mandatory from day 1

**After scoping**, output:
```
Applicable decisions: D[X], D[Y], D[Z]...
Skipped: D[A] because [user is stateless, no cross-session memory needed], D[B] because [trusted inputs only]
```

Then proceed to Phase 1 with ONLY the applicable decisions.

---

### Phase 1 — Walk Through Each Applicable Decision

For each applicable decision, in order:

1. Read `references/{decision}.md`
2. Apply the selection matrix against the user's scoping answers
3. Recommend one specific pattern with a brief rationale
4. Record: `Decision: [pattern name] | Rationale: [X constraint → Y pattern] | Cost impact: [Z]`
5. Move to the next applicable decision

**After all decisions**, output the Architecture Decision Document:

```
## Architecture Decision Document
Generated: [date]

Agent Complexity:       D1 → [Level chosen]
Coordination Topology:  D2 → [Pattern chosen] (or: SKIPPED — [reason])
Memory Architecture:    D3 → [Pattern chosen] (or: SKIPPED — [reason])
Tool Loading:           D4 → [Strategy chosen]
Permission Model:       D5 → [Level chosen], MCP checklist: [applied/optional]
Compression Strategy:   D6 → [Pipeline chosen]
Cost Controls:          D7 → [Routing + budget cap strategy]
Observability:          D8 → [Logging + alerting strategy] (or: SKIPPED — prototype)
Testing Approach:       D9 → [Invariant strategy]
Disaster Prevention:    D10 → [Top 3 applicable incidents reviewed]

Total estimated token cost per session: [range]
Estimated production monthly cost at 1K sessions/day: [range]
```

---

## /audit Mode

Read the user's existing agent code or design description.

For each of D1–D10, check:
1. Was this decision made explicitly?
2. If yes, does it match the recommended pattern for the agent's constraints?
3. If no (decision was skipped), flag with the production disaster it enables

Output the Architecture Audit Report:

```
## Architecture Audit Report

Decision   | Status        | Finding
-----------|---------------|--------
D1 (agent) | ✅ Addressed  | Level 3 Orchestrator — appropriate for task
D2 (coord) | ⚠️ Incomplete | Hub-spoke used but no idempotency tokens → Incident #7 risk
D3 (mem)   | ❌ Missing    | No memory strategy declared → Incident #4 risk (stale state)
...

## Risk Assessment
High:   [decisions where the specific disaster is likely given this system's constraints]
Medium: [decisions skipped but low-probability disaster for this topology]
Low:    [decisions not applicable or well-implemented]

## Recommended Actions (Priority Order)
1. [Missing D, risk: disaster reference]
2. ...
```

---

## Decision Reference Index

| Decision | File | Core Question |
|----------|------|---------------|
| D1 — Need an Agent | references/need-an-agent.md | Do you even need an agent? |
| D2 — Coordination | references/coordination-and-state.md | How should agents coordinate and sync state? |
| D3 — Memory | references/context-memory.md | How should context and memory be stored? |
| D4 — Tools | references/tool-management.md | How to load and manage tools efficiently? |
| D5 — Permissions | references/permissions-safety.md | What is the agent allowed to do? MCP security? |
| D6 — Compression | references/context-compression.md | What happens when context fills up? |
| D7 — Cost | references/cost-token-economics.md | How to control token cost and API budget? |
| D8 — Observability | references/observability.md | How to see what the agent is doing in production? |
| D9 — Testing | references/testing-evaluation.md | How to prove the agent behaves correctly? |
| D10 — Disasters | references/production-disasters.md | What production failures do these decisions prevent? |

---

### Anti-Skip Table

| Excuse to Skip a Decision | Why It's Wrong | Legitimate Skip Condition |
|--------------------------|----------------|--------------------------|
| "This is just a prototype, we'll add observability later" | Retrofitting traces into a live multi-agent system takes 3-6 weeks. Launch with at minimum JSONL logging — it costs 2 hours now vs weeks later. | Skip full dashboards for prototypes; keep basic JSONL logging always. |
| "Context compression is for long sessions, mine are short" | "Short" sessions become "long" sessions as scope creep happens. A session that was designed for 10 turns often runs 40. Build compression before you need it. | Skip only if hard limit enforces session length (enforced budget cap, not just hope). |
| "We don't need permission design for internal tools" | Internal tools accessed by an agent can still cause PocketOS-style disasters. Scoped tokens and deny-first apply equally to internal APIs. | Skip only if agent is read-only (no writes, no destructive operations). |
| "Multi-agent coordination is premature until we need it" | Adding hub-spoke state management after two agents are live requires touching both agents simultaneously. Design the state ownership model before the second agent is built. | Skip only if permanently single-agent (verify: is there a second agent planned in the next 3 months?). |
| "We'll test it when it's done" | Agent testing requires production traces. You cannot write stochastic invariant tests without observing real behavior. Start collecting traces on day 1 even if you don't analyze them immediately. | Skip full evaluation suite for exploratory prototypes; collect basic traces always. |

---

## Source Attribution

Built from research across 102+ sources including:
- **Claude Code** (Anthropic) — architecture analysis, 12-session course
- **OpenClaw** — multi-channel gateway source code (14 sources)
- **Hermes** (NousResearch) — self-evolution, compression, memory source code (16 sources)
- **OWASP LLM Top 10** — security taxonomy
- **Elastic Security Labs** — MCP attack research
- **Invariant Labs** — tool shadowing documentation
- **Anthropic "Building Effective Agents"** — coordination patterns

Full attribution: see LICENSE-ATTRIBUTION.md
