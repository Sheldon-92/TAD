# Research Findings Index

Maps "research finding #N" citations used throughout this pack to their source identifiers.

All findings sourced from: 102+ unique sources across 4 NotebookLM notebooks, 5 specialized subagents,
and the cross-agent evolution knowledge base (45 sources). Retrieved: 2026-05-07.

---

## Agent Failure Taxonomy

**Finding #1** — Probabilistic Pipeline Failure
> 10-agent chain at 98% per-step reliability = 81.7% total success. 
Source: Anthropic "Building Effective Agents" (2024) + agent reliability analysis.
Key claim: each additional step reduces total success probability multiplicatively.

**Finding #2** — Runaway Loops as Primary LLM Error (2026)
> 60% of LLM errors in early 2026 were rate limits caused by looping agents.
Source: Agent failure analysis across main research notebook (58 sources).
Key claim: explicit token/API call budgets per session are required to prevent runaway cost.

**Finding #3** — Agent Sprawl / Token Bloat
> 40 MCP tools = 8,000–55,000 tokens on tool definitions alone, before any query.
Source: Claude Code architecture analysis + MCP tool loading benchmarks.
Key claim: tool definition overhead is the largest controllable startup cost.

**Finding #4** — Context Rot
> Failed attempts fill context and degrade reasoning quality.
Source: Hermes runtime analysis + agent failure taxonomy (cross-agent evolution notebook).
Key claim: Knowledge Activation Units (AKUs) + auto-compaction are required to prevent degradation.

**Finding #5** — Static Tool Retrieval Breakdown
> The right tool for step 2 depends on step 1's outcome, which isn't known at session start.
Source: Dynamic Tool Dependency Retrieval (DTDR) research from main notebook.
Key claim: dynamic per-step tool retrieval outperforms upfront static loading for multi-step tasks.

**Finding #6** — World Model Failure
> LLMs cannot predict state-change consequences without explicit planning phase.
Source: Chain of Abstraction research (plan-before-execute pattern).
Key claim: agents that plan before executing have lower irreversible-error rates.

**Finding #7** — Agent-to-Agent Taint Propagation
> Attacker → Slack → triage agent → dev agent → backdoor in GitHub.
Source: Multi-agent security analysis (main notebook + cross-agent evolution knowledge base).
Key claim: A2A protocol boundaries must be established at the routing layer.

**Finding #8** — Indirect Prompt Injection / MCP Poisoning
> Malicious instructions in external data are processed by agents with tool access.
Source: Elastic Security Labs (2025), Invariant Labs disclosure, OWASP LLM Top 10.
Key claim: runtime guardrails at API gateway are the primary defense.

**Finding #9** — Excessive Agency / Permission Creep
> "God-mode" service accounts with blanket permissions enable worst-case failures.
Source: PocketOS incident post-mortem + identity management research.
Key claim: SPIFFE/SPIRE identity + RBAC per tool limits blast radius.

**Finding #10** — Improper Output Handling
> LLM output passed to system without validation can execute unintended operations.
Source: OWASP LLM Top 10, output handling security research.
Key claim: treat all LLM output as untrusted input requiring validation.

---

## Architecture Pattern Selection

**Finding #11** — Agent Necessity Gate
> If single LLM call + retrieval solves it, don't build an agentic system.
Source: Claude Code #11, Anthropic "Building Effective Agents" (2024).
Key claim: unnecessary agents multiply failure probability; simpler patterns should be chosen first.

**Finding #12** — Deferred Tool Loading Threshold
> If agent uses >5 tools, implement deferred loading rather than upfront loading.
Source: Tool loading analysis from Claude Code architecture + MCP token overhead benchmarks.
Key claim: 5+ tools crosses the threshold where deferred loading breaks even vs upfront.

**Finding #13** — Context-as-Limiting-Constraint
> If context is the limiting factor, use hierarchical delivery and pointer-based navigation.
Source: Claude Code architecture analysis (tree-sitter AST navigation pattern).
Key claim: pointer-based navigation (load on demand) scales where upfront loading fails.

**Finding #16** — JIT Memory Invalidation
> Stale memory is worse than no memory in high-change domains.
Source: Memory freshness analysis across main research notebook.
Key claim: domain-specific TTLs and JIT invalidation checks are required for production memory.

**Finding #17** — Entropy-Based Lazy Retrieval
> Skip vector retrieval when LLM uncertainty (entropy) is low.
Source: Entropy-based RAG optimization research, main notebook.
Key claim: skipping retrieval when confidence is high saves 1.44s + retrieval tokens per query.

**Finding #18** — HITL Approval Fatigue
> When >90% of approvals are granted blindly, approval gates provide no safety.
Source: Human-in-the-loop research, permission UX analysis, main notebook.
Key claim: two-stage classifier (fast gate + adaptive human review) restores safety value.

**Finding #19** — Dual-Agent for Untrusted Data
> Untrusted external data must be processed by an unprivileged parser before the privileged planner sees results.
Source: OWASP LLM Top 10 (dual-agent pattern), indirect prompt injection defense research.
Key claim: quarantined parser with zero tools prevents prompt injection from triggering actions.

**Finding #22** — Network Isolation for Benchmarks
> Web-enabled agents can search for and read their own benchmark answer keys.
Source: Agent evaluation integrity research, SWE-bench analysis.
Key claim: complete network isolation is required for valid benchmark measurement of web-enabled agents.

**Finding #23** — AI-Assisted Trace Analysis
> For traces spanning hundreds of steps, AI evaluators are required for block-level responsibility scoring.
Source: Agent observability research, AgentOps analysis, main notebook.
Key claim: humans cannot manually review >50 trace steps; AI-assisted analysis enables debugging of long autonomous sessions.

**Finding #24** — Stochastic Behavior Fingerprinting
> Non-deterministic agents require statistical invariant testing, not binary pass/fail.
Source: Agent evaluation methodology research, DeepEval documentation, main notebook.
Key claim: behavioral fingerprinting over N runs (N=10-100) is the only valid approach for probabilistic agents.
