# D7: Cost and Token Economics

**Decision**: How does the agent manage API costs, token budgets, and resource consumption?

Context scarcity IS cost. Every architectural decision in D1-D9 has a token/API cost dimension. This file makes those costs explicit and provides mechanisms to control them before runaway agents exhaust budgets in production.

---

## The Core Insight [Source: Claude Code #3]

> "Context scarcity shapes everything. The binding constraint drives all design decisions."

Token budget is not a billing concern — it is an architectural constraint that must be designed around from the start. An agent without token budget management will:
1. Hit rate limits (60% of LLM errors in early 2026 = rate limits from looping agents) [Source: research finding #2]
2. Produce degraded output as context fills with failed attempts [Source: research finding #4 — Context Rot]
3. Run up unbounded costs in production

---

## Model Routing: 40-60% Cost Reduction [Source: OmniRoute research]

Not all tasks require the most capable (most expensive) model.

**Routing matrix**:

| Task Type | Model Tier | Cost Ratio |
|-----------|-----------|-----------|
| Simple classification, extraction | Small/cheap | 1x |
| Standard generation, analysis | Mid-tier | 4-8x |
| Complex reasoning, multi-step planning | Capable | 20-40x |
| Context-heavy, long documents | Context-specialized | 10-20x |

**Rule** [Source: Anthropic Building Effective Agents, Pattern 2 — Routing]: use cheap model for classification (what kind of task is this?) and route complex cases to capable models. 40-60% cost reduction when classification accuracy exceeds 90%.

**Implementation**: add a routing step before the main agent loop. Classify task complexity, select model tier, route. The classification cost (~$0.001) is amortized against the $0.05-0.40 saved per complex task routed correctly.

---

## Entropy-Based Lazy Retrieval [Source: research finding #17]

**Problem**: RAG pipeline retrieves vector store context on every query regardless of whether it's needed.

**Solution**: measure LLM uncertainty (entropy) before retrieval. If the model is confident without retrieval (low entropy, high probability on top token), skip the retrieval step.

```
if model_entropy(query) < threshold:
    skip_retrieval()  # save 1.44s + retrieval tokens
else:
    retrieve_and_augment()
```

**When to apply**: RAG pipelines where retrieval is the bottleneck (latency or cost), and where the query set includes a significant fraction of questions the model can answer from training data alone.

**When NOT to apply**: below 10K queries/day or when retrieval is cheap (in-memory store). Estimating LLM uncertainty requires either a separate API call (additional cost) or logprobs access (model/endpoint-specific). The implementation cost of entropy gating can exceed retrieval savings at low volume. For low-volume RAG, keyword pre-filtering or cached retrieval is simpler and cheaper.

**Savings**: retrieval tokens (context from retrieved documents) + retrieval latency (1.44s median for flat vector store). At 100K queries/day with 60% answered without retrieval: substantial.

---

## Budget Caps per Session [Source: research finding #2]

**Rule**: every agent session MUST have explicit token/API call budgets with hard stops.

Without budget caps:
- A looping agent (Evaluator-Optimizer that never converges) runs forever
- A verbose agent spends 10,000 tokens per turn when 500 suffice
- A misbehaving tool (returns large payloads, agent retries) exhausts daily budget in minutes

**Implementation**:
```
session_budget:
  max_tokens_total: 100000
  max_api_calls: 50
  max_tool_calls_per_turn: 10
  on_budget_exceeded: [alert, pause, summarize_and_continue, terminate]
```

**On budget exceeded**: choose the response that matches your availability requirements:
- `pause`: stop and notify human (safest)
- `summarize_and_continue`: compress context, continue with remaining budget
- `terminate`: stop and return partial result with reason
- `alert`: notify but continue (monitoring only)

---

## Graduated Extension Cost Tiers [Source: Claude Code #9]

Every tool/extension type has a token cost. Design the extension type to match the task's importance:

| Tier | Type | Token Cost | Monthly Cost at 10K sessions/day |
|------|------|-----------|----------------------------------|
| 0 | Hooks (event-based) | 0 | $0 |
| 1 | Skills/Prompts | 500-2K tokens | $7-$30 |
| 2 | Plugins | 2K-8K tokens | $30-$120 |
| 3 | MCP Servers | 8K-55K tokens | $120-$825 |

**Decision rule**: before adding a new extension, determine the minimum tier that achieves the requirement. A file-watching capability implemented as a Hook costs $0. The same capability implemented as an MCP server costs $120+/month.

---

## Tool Definition Overhead [Source: research finding #3, D4]

40 MCP tools loaded = 8,000-55,000 tokens on definitions alone (before any query).

**Cost at scale** (relative — verify current provider pricing before budgeting):
- 40 MCP tools upfront: ~55,000 definition tokens per session
- Deferred loading index: ~1,000 tokens per session
- Ratio: deferred loading uses ~1/55 (98%) fewer tokens on tool definitions
- At any price per token, this 55x reduction is the architectural constant; absolute dollar amounts depend on current provider pricing

**Rule**: deferred loading pays for itself after 1,000 sessions. Below 100 sessions/day, upfront loading is acceptable. [Source: D4 — tool-management.md]

---

## SkillTool vs AgentTool Cost Trade-off [Source: Claude Code #13]

| Mode | Token Cost | Use When |
|------|-----------|----------|
| SkillTool (inline) | ~1x | Standard tool use, output fits in context |
| AgentTool (sub-agent) | ~7x | Output is verbose, exploratory, or context-polluting |

**When the 7x cost is justified**:
- Sub-task generates 10,000 tokens but only 200 tokens of useful result (sub-agent returns 200-token summary)
- Sub-task risks context pollution (untrusted data processing, long file reading)
- Sub-task is independent and can run in parallel (7x per sub-agent, but parallel reduces wall time)

**When 7x is NOT justified**:
- Simple tool call that returns a short, clean result
- Any case where SkillTool handles the task with acceptable context usage

---

## Practical Token Profile by Agent Type (use relative sizing — absolute costs change with provider pricing)

| Agent Type | Token Range per Session | Relative Cost (vs simple chatbot) |
|-----------|------------------------|----------------------------------|
| Simple chatbot (no tools) | 1K-5K | 1x baseline |
| RAG Q&A (vector retrieval) | 5K-20K | 4-20x |
| Code assistant (file reading) | 10K-50K | 10-50x |
| Research agent (web + synthesis) | 50K-200K | 50-200x |
| Autonomous agent (multi-tool) | 100K-500K | 100-500x |

**Design implication**: know which tier your agent will operate in before deployment. The token cost difference between a Research Agent and an Autonomous Agent is 10x. If you design for Research Agent token usage but implement an Autonomous Agent, you'll pay 10x more than planned — regardless of absolute current pricing.

> Note: verify current per-token pricing with your provider before capacity planning. Model prices change quarterly. The relative ratios above are more stable than absolute costs.

---

## Cost Monitoring Tools [Source: research — Tool Mapping]

- **tokencost**: token counting + USD estimation across 400+ LLMs (pre-call estimation)
- **LiteLLM**: unified proxy with cost tracking + failover between providers
- **Helicone**: LLM proxy for cost tracking and dashboards
- **OmniRoute**: automatic model routing for 40-60% cost reduction

**Required production setup**: at minimum, implement cost tracking per session from day 1. Retrofitting cost attribution after the agent is live is a 2-4 week engineering project.

---

## Cross-Reference

- **Model routing requires coordination**: see D2 (coordination-and-state.md)
- **Tool loading strategies that reduce cost**: see D4 (tool-management.md)
- **Compression strategies that reduce context cost**: see D6 (context-compression.md)
- **Cost dashboards in production**: see D8 (observability.md)
- **Disasters cost controls prevent**: see D10 (production-disasters.md), Incident #7 (double-charge from runaway retries without budget cap)
