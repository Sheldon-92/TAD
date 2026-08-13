# Research Findings Index

Maps "research finding #N" citations used throughout this pack to their source identifiers.

All findings sourced from: 102+ unique sources across 4 NotebookLM notebooks, 5 specialized subagents,
and the cross-agent evolution knowledge base (45 sources). Retrieved: 2026-05-07.

> **2026-06-13 evidence refresh**: numeric findings below now carry `source_url` + retrieval date
> (QUALITY-BAR §5 / principles 2026-05-15 "research evidence lacks auditability"). Findings #1 and #3
> were re-grounded against today-retrievable primary sources; the older undated figures are kept only
> as the historical statement they replace.

---

## Agent Failure Taxonomy

**Finding #1** — Compounding-Error Math (Lusser's Law)  [REFRESHED 2026-06-13]
> Reliability multiplies across sequential steps (Lusser's law): a 95%-per-step agent succeeds
> end-to-end only ~36% of a 20-step task (0.95^20 ≈ 0.358). Real production agents run **85–90%
> per step**, NOT 95%. Decision rule: a workflow needing **>~14 sequential LLM steps at 95%
> reliability drops below 50% success** (0.95^14 ≈ 0.488) — decompose or add deterministic
> checkpoints rather than lengthening the chain.
> source_url: https://towardsdatascience.com/the-math-thats-killing-your-ai-agent/  (retrieved 2026-06-13)
> Replaces the older undated statement: "10-agent chain at 98% per-step = 81.7% total success"
> (Anthropic "Building Effective Agents" 2024) — same multiplicative principle, now with a
> today-retrievable threshold and an explicit step-count decision rule. Feeds D1 + D9.
Key claim: each additional step reduces total success probability multiplicatively; design for the
minimum step count and insert deterministic checkpoints past the ~14-step / 50% boundary.

**Finding #2** — Runaway Loops as Primary LLM Error (2026)
> 60% of LLM errors in early 2026 were rate limits caused by looping agents.
Source: Agent failure analysis across main research notebook (58 sources).
Key claim: explicit token/API call budgets per session are required to prevent runaway cost.

**Finding #3** — Agent Sprawl / Token Bloat  [REFRESHED 2026-06-13]
> 40 MCP tools = 8,000–55,000 tokens on tool definitions alone, before any query. At hundreds-to-
> thousands of tools, the fix is no longer "defer the JSON" but **code-execution / progressive tool
> discovery**: Anthropic's "code execution with MCP" cut a Google Drive→Salesforce workflow from
> **150,000 tokens to 2,000 tokens (98.7% reduction)** by exposing MCP tools as on-demand filesystem
> code instead of loading all tool definitions upfront; Cloudflare reported **99.9%** by compressing
> 2,500 API endpoints into 2 tools.
> source_url: https://www.anthropic.com/engineering/code-execution-with-mcp  (retrieved 2026-06-13,
> "150,000 tokens to 2,000 tokens—a 98.7%" quote confirmed via WebFetch of the primary article)
Source: Claude Code architecture analysis + MCP tool loading benchmarks + Anthropic code-execution-with-MCP.
Key claim: tool definition overhead is the largest controllable startup cost; past the deferred-loading
threshold, code-execution tool discovery beats deferred-but-still-JSON loading. Feeds D4.

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

---

## 2026 Evidence Refresh — Sourced Thresholds (added 2026-06-13)

> Every entry below carries `source_url` + retrieval date. These feed the D-file decision rules.

**Finding #25** — Multi-Agent Economics: the 15x Token Multiplier  [D2]
> Anthropic's orchestrator-worker Research system beat single-agent Opus 4 by **90.2%** but burns
> **~15x the tokens** of normal chat; token usage explains **~80% of performance variance** (BrowseComp).
> Decision rule: multi-agent only pays off for high-value breadth-first work whose information exceeds
> one context window (legal due diligence, competitive intel, biomedical review). Consumer Q&A cannot
> absorb the 15x multiplier — default to single-agent.
> source_url: https://www.anthropic.com/engineering/multi-agent-research-system  (retrieved 2026-06-13)

**Finding #26** — Context Editing / Compaction Payoffs  [D6]
> Anthropic context-editing API (launched 2026-09-29 alongside Sonnet 4.5) auto-clears stale tool
> calls/results. Internal evals: context editing alone = **+29%** performance; context editing +
> memory tool = **+39%**; context editing cut **token consumption 84%** in a 100-turn web-search eval.
> Claude Opus 4.6 productized automatic server-side compaction at the context-window limit.
> source_url: https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents  (retrieved 2026-06-13)
> ⚠️ VERIFICATION FLAG (QUALITY-BAR §6): the +29% / +39% / 84% figures were surfaced by the SEARCH
> SUMMARY of the context-editing/memory-tool announcement, NOT found in the engineering-blog body
> (WebFetch confirmed the blog lacks them). Cross-model verify against the primary changelog before
> final acceptance.

**Finding #27** — MCP Attack Surface at Scale  [D5]
> Internet-exposed MCP grew from **1,862 unauthenticated MCP servers** (July 2025 scan) to
> **12,520 internet-accessible MCP services across 8,758 unique IPs / 56 countries** (April 28 2026 scan).
> Two landmark CVEs — **MCPoison (CVE-2025-54136)** and **CurXecute (CVE-2025-54135)** — established
> tool-poisoning (malicious instructions in tool descriptions, visible to the LLM but not the user)
> as the top client-side MCP threat. **9 of 11 MCP registries** tested accepted malicious packages
> with no security review.
> source_url: https://censys.com/blog/mcp-servers-on-the-internet/  (retrieved 2026-06-13)

**Finding #28** — Agentic-AI Project Cancellation Risk  [D1 / D10]
> Gartner (June 2025) predicts **>40% of agentic-AI projects will be canceled by end of 2027** due to
> escalating costs, unclear value, or inadequate risk controls. Quantifies the macro cost of skipping
> the D1 "do you even need an agent?" gate and the D7/D8 cost+observability decisions.
> source_url: https://www.zartis.com/the-compounding-errors-problem-why-multi-agent-systems-fail-and-the-architecture-that-fixes-it/  (retrieved 2026-06-13)

**Finding #29** — Durable-Execution Framework Currency  [D2 / D8]
> LangGraph 1.0 (GA October 2025) unified agent primitives (Router / Supervisor / Subagent) + durable execution
> (persist through failures, **resume from exact checkpoint**); **~33,900 GitHub stars, 34.5M monthly
> downloads**. CrewAI 5K+ stars, role-based. Teach checkpoint-based recovery, not framework names alone.
> source_url: https://github.com/langchain-ai/langgraph  (retrieved 2026-06-13)
