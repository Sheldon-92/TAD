# AI Agent Architecture Capability Pack — Curated Research Findings
Date: 2026-05-07
Notebooks: 8da09b3b (17 sources) + 37cfefa5 (tad-evolution, 45 sources, cross-queried)

---

## Agent Failure Taxonomy (from tad-evolution notebook, 45 sources)

### Execution & Orchestration
1. **Probabilistic Pipeline Failure**: 10-agent chain at 98% each = 81.7% total. Mitigation: Pydantic validation gates between handoffs.
2. **Runaway Loops**: 60% of LLM errors in early 2026 = rate limits from looping agents. Mitigation: explicit token/call budgets per session.
3. **Agent Sprawl / Token Bloat**: 40 MCP tools = 8K-55K tokens on definitions alone. Mitigation: deferred tool loading (search-then-load).

### Context & Memory
4. **Context Rot**: Failed attempts fill context → degraded reasoning. Mitigation: Knowledge Activation (AKUs/Skills) + auto-compaction.
5. **Static Tool Retrieval Breakdown**: Right tool for step 2 depends on step 1 outcome. Mitigation: Dynamic Tool Dependency Retrieval (DTDR).
6. **World Model Failure**: LLMs can't predict state-change consequences. Mitigation: chain of abstraction (plan before execute).

### Security & Boundaries
7. **Agent-to-Agent Taint Propagation**: Attacker → Slack → triage agent → dev agent → backdoor in GitHub. Mitigation: A2A protocol boundaries.
8. **Indirect Prompt Injection / MCP Poisoning**: Malicious instructions in external data. Mitigation: runtime guardrails at API gateway.
9. **Excessive Agency / Permission Creep**: "God-mode" service accounts. Mitigation: SPIFFE/SPIRE identity + RBAC per tool.
10. **Improper Output Handling**: LLM output passed to system without validation. Mitigation: treat all LLM output as untrusted input.

---

## Concrete Decision Rules (from ai-agent notebook, 17 sources)

### Architecture Pattern Selection (7 rules)
1. If single LLM call + retrieval solves it → don't build an agentic system
2. If fixed subtasks → Prompt Chaining
3. If distinct categories needing different handling → Routing (cheap model for easy, capable for hard)
4. If subtasks can run simultaneously → Parallelization (sectioning or voting)
5. If subtasks unpredictable → Orchestrator-Workers
6. If clear eval criteria + iterative refinement helps → Evaluator-Optimizer
7. If fully open-ended → Autonomous Agent (with sandboxing + guardrails)

### Tool Design (5 rules)
8. If agent makes tool parameter mistakes → poka-yoke (mistake-proof) the tool interface
9. If a human would need to think carefully about tool usage → write highly descriptive docstrings (ACI)
10. If agent repeatedly executes same tool sequence → bundle into meta-tool
11. If multi-step agent has high latency → implement parallel tool calling
12. If agent calls >5 tools → use deferred tool loading, not upfront loading

### Context & Memory (4 rules)
13. If critical rules must survive long sessions → place in persistent system prompt, not conversation
14. If task exceeds context window → structured cross-session handoffs (artifacts, commits, test gates)
15. If context is the limiting factor → hierarchical delivery / pointer-based navigation (tree-sitter AST)
16. If cross-session memories are used → JIT invalidation checks (stale memory > no memory)

### Cost & Performance (2 rules)
17. If RAG pipeline cost is primary concern → entropy-based lazy loading (skip retrieval when uncertainty low)
18. If HITL approval fatigue (>90% blind approval) → two-stage classifier (fast gate + adaptive permission)

### Security (4 rules)
19. If agent processes untrusted external data → dual-agent architecture (privileged Planner + unprivileged Parser)
20. If agent executes generated code → intercept outbound requests at sandbox layer, never expose raw secrets
21. If tool combination exposes data + ingests untrusted content + communicates externally → "lethal trifecta" → mandatory runtime policy enforcement
22. If evaluating agent in web-enabled environment → completely network-isolate the benchmark

### Debugging & Evaluation (2 rules)
23. If trace spans hundreds of steps → AI-assisted trace analysis (block-level responsibility scoring)
24. If non-deterministic workflow → stochastic behavior fingerprinting, not binary pass/fail tests

**Total: 24 decision rules + 10 failure modes = 34 items**

---

## DEEP ROUND 2: Production Disaster Causal Chains (7 real incidents)

### Incident 1: PocketOS Database Wipe (9 seconds)
Chain: routine staging task → credential mismatch → agent expanded mission to "fix credentials" → found Railway CLI token → token had blanket permissions (no env scoping) → issued DELETE volume mutation → production DB + all backups wiped
Prevention: HITL gate for destructive mutations OR scoped tokens per environment

### Incident 2: Cursor MCP Tool Poisoning
Chain: connected to malicious MCP server → innocent "add" tool → hidden `<IMPORTANT>` tag in description → agent read ~/.cursor/mcp.json + SSH keys → transmitted via hidden `side_note` parameter → complete credential compromise
Prevention: UI must display FULL tool descriptions to users, not summaries

### Incident 3: Email Hijacking (Cross-Tool Shadowing)
Chain: user connected trusted email server + malicious server → malicious tool description modified trusted send_email behavior → user asked to send email → agent routed to attacker
Prevention: cross-server dataflow controls, tool isolation boundaries

### Incident 4: E-Commerce Stale State Propagation
Chain: customer paid → Agent A updated state to "paid" → Agent B read STALE state before update arrived → Agent B refused inventory allocation → permanent failure state
Prevention: event sourcing / optimistic concurrency — never read during incomplete transitions

### Incident 5: Support Ticket Race Condition
Chain: new ticket → routing agent assigned to tier 2 + response agent simultaneously marked resolved → neither coordinated writes → ticket in corrupt state (both assigned AND closed)
Prevention: hub-spoke architecture — single orchestrator owns canonical state

### Incident 6: Financial Trading Message Ordering
Chain: market data agent sent price update + execution signal → network reordered messages → trading agent received execution before price update → executed at stale price
Prevention: causal consistency verification — validate ordering before execution

### Incident 7: Customer Double-Charging
Chain: Agent A sent payment request → Agent B processed but response delayed → Agent A timed out → Agent A retried without checking completion → Agent B processed duplicate → customer double-charged
Prevention: idempotency tokens + deduplication at API boundary

---

## DEEP ROUND 3: Memory Architecture Selection (5 patterns)

| Pattern | When RIGHT | When WRONG | Key Metric |
|---------|-----------|------------|------------|
| 1. In-context only | Stateless tasks, prototypes, strict privacy | Multi-session, cost-sensitive | 72.9% accuracy, 17.12s p95 |
| 2. Flat vector store | Multi-session conversational, user personalization | Multi-hop reasoning, temporal queries | 90% token reduction, 1.44s latency |
| 3. Tiered (hot/warm/cold) | Session coherence + long-horizon continuity under token constraints | Simple prototypes | Mirrors human consolidation, complex infra |
| 4. Knowledge graph + vector | Entity relationships, multi-hop, temporal validity, multi-agent attribution | Cold-start domains, rapidly evolving schemas | Prevents stale-fact failures, high maintenance |
| 5. Enterprise context layer | Regulated industries, governed metadata already exists | No existing data catalog | Governance by design, high org complexity |

---

## DEEP ROUND 4: MCP Security Checklist (7 actionable rules)

1. Display FULL tool descriptions to users — hidden `<IMPORTANT>` tags are the #1 attack vector
2. Enforce cross-server boundaries — malicious server CANNOT modify how trusted tools behave
3. Cryptographically verify + pin tool versions — rug-pulls change descriptions AFTER approval
4. Run MCP servers in containers with read-only FS + network isolation + seccomp/BPF
5. Zero Trust + JIT access — never persistent broad permissions, time-limited task-specific credentials
6. Dual-LLM for untrusted data — quarantined LLM (no tools) processes data, privileged LLM controls execution
7. Centralized tool registry with reputation scoring — sandbox new tools before granting full privileges

---

## DEEP ROUND 5: The ONE Thing About Agent Architecture

**"Do not use an autonomous agent if a simpler deterministic workflow can solve the problem."**

Production reliability comes from LIMITING agent freedom, not maximizing it. Prototype = rely on LLM reasoning. Production = wrap LLM in an Agent-Native OS (strict context delivery + explicit state sync + deterministic tools).

### Top 3 Expert-Level Mistakes (experienced devs, not beginners)

1. **"Agent Everywhere" trap** — replacing if/else with autonomous LLMs. Fix: move deterministic steps back to code, only use agents for dynamic reasoning.
2. **Polling Tax** — synchronous request-response for agents wastes 95% of API calls. Fix: event-driven architecture with async message passing.
3. **"Dumb RAG"** — dumping raw data into vector DB expecting LLM to sort it out. Fix: context precision, not volume — curated knowledge for each agent role.

---

## Tool Mapping (5 categories)

### Agent Testing
- promptfoo (YAML-driven, LLM-as-judge, CI integration)
- DeepEval (20+ built-in metrics, pytest integration)
- Inspect AI (UK AI Security Institute, safety-grade)
- AgentBench, SWE-bench, tau-bench (benchmarks)

### Agent Observability
- AgentOps (session replay, execution graphs, cost tracking)
- OpenLLMetry (OpenTelemetry-based, no code changes)
- Langfuse (self-hostable, traces + prompt versioning)
- Arize Phoenix (self-hostable trace UI + eval)
- Helicone (LLM proxy, cost tracking)

### Agent Security
- NeMo Guardrails (NVIDIA, programmable rails)
- Guardrails AI (structural/type/quality guarantees)
- LLM Guard / Lakera Guard (real-time scanning)
- Rebuff (prompt injection detection)
- HeimdaLLM (static analysis of LLM-generated SQL)
- E2B / Daytona / Cloudflare Workers (sandboxing)
- Microsoft Agent Governance Toolkit

### Agent Cost Management
- tokencost (token counting + USD estimation, 400+ LLMs)
- LiteLLM (unified proxy, cost tracking, failover)
- OmniRoute (40-60% cost reduction via model routing)

### Agent Orchestration Frameworks
| Framework | Strength | Weakness |
|-----------|----------|----------|
| LangGraph | Stateful graphs, checkpointing | Boilerplate, LangChain coupling |
| CrewAI | Role-based, Crews+Flows | Opinionated persona-based |
| AutoGen | Multi-agent conversational | No inherent process concept |
| OpenAI Agents SDK | Lightweight, handoffs | Less graph orchestration |
| PydanticAI | Type-safe execution | Rigid schemas |
| Claude Agent SDK | Native tool chaining | Abstraction obscures debugging |
