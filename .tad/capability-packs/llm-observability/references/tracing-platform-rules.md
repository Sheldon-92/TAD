# Distributed Tracing Platform Rules
<!-- capability: distributed_tracing -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| TR1 | Platform selection by architecture: SDK vs proxy-gateway vs OTel-native | deterministic |
| TR2 | Proxy gateways (Helicone) cannot natively reconstruct nested in-app steps | deterministic |
| TR3 | Reconstruct agentic execution as a parent-child span tree, not flat HTTP logs | deterministic |
| TR4 | Self-host requires open license: Langfuse MIT, Phoenix Elastic License 2.0 | deterministic |
| TR5 | Match framework-native support to your stack before picking a platform | deterministic |

---

## Rules

### TR1: Platform Selection by Architecture

When choosing an LLM tracing platform, the architecture — not the brand — drives the decision. Standard HTTP logging captures end-to-end latency but fails to map the internal execution graph of an agent (nested model calls, vector retrievals, tool executions).

| Platform | Architecture | License & Model | Setup Effort | Best For |
|----------|--------------|-----------------|--------------|----------|
| LangSmith | SDK-based framework integration | Closed source SaaS by default; self-hosted / hybrid available as an Enterprise add-on, $39/seat + usage | ~15 min (auto-enabled for LangChain) | Teams embedded in LangChain / LangGraph |
| Langfuse | SDK-based AND OpenTelemetry-compliant | MIT licensed open-source, self-host or cloud; Cloud from $59/seat | ~30 min cloud / ~60 min self-host | Privacy / self-hosting teams |
| Arize Phoenix | OpenTelemetry-based, local Jupyter → cloud | Elastic License 2.0 open-source, enterprise cloud | ~30 min | ML engineers needing embedding/RAG validation rigor |
| Helicone | Proxy / gateway HTTP interception | Open-source proxy gateway, SaaS | ~5 min (proxy URL redirection) | Early-stage / small teams needing fast setup |

> Source: findings.md "Distributed Tracing Agent Typology in Production" comparison table [3, 5, 6, 7]

**determinismLevel**: deterministic — platform selection is an architectural decision.

### TR2: Proxy Gateways Cannot Reconstruct Nested In-App Steps

When a team picks Helicone (or any proxy gateway) for its ~5-minute setup, they MUST know its structural limit: a proxy intercepts external API requests by redirecting the base API URL to the gateway endpoint. It is **fundamentally restricted to intercepting external API requests** — it cannot natively reconstruct nested, stateful execution steps occurring inside the core application logic unless context headers are explicitly passed.

**Rule**: If your value is debugging a multi-step agent's internal state-machine, a proxy gateway alone is insufficient. Use an SDK-based (LangSmith) or OTel-native (Langfuse / Phoenix) tracer, or pass context headers explicitly through the proxy.

> Source: findings.md "Helicone operates differently by using a proxy gateway approach... cannot natively reconstruct nested, stateful execution steps... unless context headers are explicitly passed" [3, 6, 7]

**determinismLevel**: deterministic — a structural property of the proxy model.

### TR3: Reconstruct the Span Tree, Not Flat Logs

A single user interaction with an autonomous agent can trigger an entire tree of nested model calls, vector database retrievals, and external tool executions. Production platforms must reconstruct these hierarchies as structured trace trees, establishing clear **parent-child span relationships**.

**Rule**: A trace that only records end-to-end latency is incomplete for agentic workloads. Require parent-child span nesting that maps the execution graph. If your traces are flat (one span per HTTP call), you cannot debug where in the agent loop a failure or cost spike occurred.

> Source: findings.md "Production platforms must reconstruct these hierarchies as structured trace trees, establishing clear parent-child span relationships" [2, 3]

**determinismLevel**: deterministic — a structural requirement.

### TR4: Self-Host Licensing Check

When self-hosting is a requirement (data sovereignty, air-gapped), verify the license permits it:

- **Langfuse**: MIT licensed — fully self-hostable. Dual Postgres + ClickHouse storage architecture designed to handle billions of spans while maintaining complete data control.
- **Arize Phoenix**: Elastic License 2.0 — open-source, self-hostable, with enterprise cloud option.
- **LangSmith**: Closed source SaaS by default — NOT self-hostable on the standard/Plus plan. Self-hosted (run components + data stores in your own cloud/VPC or on-prem) and hybrid (managed control plane + self-hosted data plane) ARE available as an Enterprise add-on requiring a license.

> Source: findings.md tracing comparison table; "Langfuse... dual Postgres and ClickHouse storage architecture designed to handle billions of spans" [3, 5, 7]; LangSmith self-hosted/hybrid Enterprise add-on per LangChain docs.

**determinismLevel**: deterministic — license is a fixed fact.

### TR5: Framework-Native Support Match

Match the platform's native framework support to your stack before committing:

| Platform | Framework Native Support |
|----------|--------------------------|
| LangSmith | LangChain, LangGraph |
| Langfuse | Framework-agnostic (Python, TypeScript SDKs) |
| Arize Phoenix | LlamaIndex, Haystack, DSPy, OpenAI Agents SDK |
| Helicone | Framework-agnostic (proxy-level) |

**Rule**: Choosing LangSmith for a LlamaIndex stack, or Phoenix for a pure-LangGraph stack, means losing auto-instrumentation and writing manual spans. Pick the platform whose native support matches your framework.

> Source: findings.md tracing comparison table "Framework Native Support" row [3, 6]

**determinismLevel**: deterministic — a compatibility fact.

---

## Anti-Patterns

- **Flat HTTP logging for agents**: Captures end-to-end latency but cannot map the nested execution graph of a multi-step agent.
- **Proxy-only for in-app debugging**: A proxy gateway cannot see steps that never leave the application process.
- **Brand-first selection**: Picking a platform by popularity rather than by architecture (SDK vs proxy vs OTel) and framework match.
- **Ignoring license/plan before self-host**: LangSmith's standard/Plus SaaS plan blocks self-hosting (self-hosted/hybrid is an Enterprise add-on), whereas Langfuse (MIT) and Phoenix (Elastic 2.0) permit it openly.
