# Distributed Tracing Platform Rules
<!-- capability: distributed_tracing -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| TR1 | Platform selection by architecture: SDK vs proxy-gateway vs OTel-native | deterministic |
| TR2 | Proxy gateways (Helicone) cannot natively reconstruct nested in-app steps | deterministic |
| TR3 | Reconstruct agentic execution as a parent-child span tree, not flat HTTP logs | deterministic |
| TR4 | Self-host requires open license: Langfuse MIT, Phoenix Elastic License 2.0 (2026 pricing inline) | deterministic |
| TR5 | Match framework-native support to your stack before picking a platform | deterministic |
| TR6 | Instrument with an OTel-native layer (OpenLLMetry / OpenInference / OpenLIT); emit OTLP once, fan out — don't hard-couple to one vendor SDK | deterministic |

---

## Rules

### TR1: Platform Selection by Architecture

When choosing an LLM tracing platform, the architecture — not the brand — drives the decision. Standard HTTP logging captures end-to-end latency but fails to map the internal execution graph of an agent (nested model calls, vector retrievals, tool executions).

Pricing/licensing below is dated 2026-06-13 — re-verify before quoting (these figures rot):

| Platform | Architecture | License & 2026 Pricing | Setup Effort | Best For |
|----------|--------------|------------------------|--------------|----------|
| LangSmith | SDK-based framework integration | Closed-source SaaS by default; **Plus $39/seat/mo** (10K base traces; overage **$2.50/1K @ 14-day** or **$5.00/1K @ 400-day** retention); self-host only on Enterprise | ~15 min (auto-enabled for LangChain) | Teams embedded in LangChain / LangGraph |
| Langfuse | SDK-based AND OTel-native (v3 SDK ingests OTLP at `/api/public/otel`) | **MIT** self-host **free forever**; Cloud **Core $29/mo / Pro $199/mo / from $59/seat** | ~30 min cloud / ~60 min self-host | Privacy / self-hosting teams |
| Arize Phoenix | OpenTelemetry-based, local Jupyter → cloud; **Evaluator Hub** (Jan 2026) with versioned LLM-as-judge templates (faithfulness/hallucination/relevance/tool-call) | Elastic License 2.0 open-source, enterprise cloud | ~30 min | ML engineers needing embedding/RAG validation rigor |
| Helicone | Proxy / gateway HTTP interception | Open-source proxy gateway, SaaS; **Pro from $79/mo** | ~5 min (proxy URL redirection) | Early-stage / small teams needing fast setup |

> Source: findings.md "Distributed Tracing Agent Typology in Production" comparison table [3, 5, 6, 7]; 2026 pricing/licensing from SigNoz LangSmith-alternatives (https://signoz.io/comparisons/langsmith-alternatives/, retrieved 2026-06-13); Phoenix Evaluator Hub from Confident AI 2026 tools roundup (https://www.confident-ai.com/knowledge-base/compare/10-llm-observability-tools-to-evaluate-and-monitor-ai-2026, retrieved 2026-06-13).

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

- **Langfuse**: MIT licensed — fully self-hostable, **free forever**. Dual Postgres + ClickHouse storage architecture designed to handle billions of spans while maintaining complete data control. The **v3 SDK is OTel-native** and ingests OTLP at the `/api/public/otel` endpoint, so any OTel-instrumented app can ship traces in without the Langfuse SDK.
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

### TR6: Instrument Once at the OTel-Native Layer, Then Fan Out

The instrumentation library — not the backend SDK — is what produces vendor-neutral `gen_ai.*` spans that ANY backend can ingest. Three OTel-native instrumentation layers cover this:

| Library | Repo / Project | Notes |
|---------|----------------|-------|
| **OpenLLMetry** | `traceloop/openllmetry` | Its semantic conventions were **upstreamed into OpenTelemetry**; adds **Java + Go** coverage beyond the Python/TS SDKs |
| **OpenInference** | `Arize-ai/openinference` | Complementary OTel conventions for AI observability (feeds Arize Phoenix) |
| **OpenLIT** | OpenLIT | OTel-native instrumentation; also extends language coverage |

These emit OTLP that fans out to any backend: **Langfuse v3** ingests OTLP at `/api/public/otel`, Phoenix and Datadog consume the same `gen_ai.*` spans.

**Rule**: Pick the instrumentation library by **language coverage** (OpenLLMetry / OpenLIT add Java + Go beyond the Python/TS backend SDKs), **emit OTLP once**, then fan out to backends. Do **NOT** hard-couple application code to a single vendor's SDK — that locks your spans to one backend and forces a rewrite to migrate. If you instrument with the vendor SDK directly, you cannot dual-export or switch backends without re-instrumenting.

> Source: OpenLLMetry — OTel-native GenAI instrumentation, conventions upstreamed into OpenTelemetry (https://github.com/traceloop/openllmetry, retrieved 2026-06-13); OpenInference (https://github.com/Arize-ai/openinference, retrieved 2026-06-13); Langfuse v3 OTLP ingest at `/api/public/otel` (https://github.com/langfuse/langfuse, retrieved 2026-06-13).

**determinismLevel**: deterministic — a fixed instrumentation-architecture rule + named repos/endpoint.

---

## Anti-Patterns

- **Flat HTTP logging for agents**: Captures end-to-end latency but cannot map the nested execution graph of a multi-step agent.
- **Proxy-only for in-app debugging**: A proxy gateway cannot see steps that never leave the application process.
- **Brand-first selection**: Picking a platform by popularity rather than by architecture (SDK vs proxy vs OTel) and framework match.
- **Ignoring license/plan before self-host**: LangSmith's standard/Plus SaaS plan blocks self-hosting (self-hosted/hybrid is an Enterprise add-on), whereas Langfuse (MIT) and Phoenix (Elastic 2.0) permit it openly.
- **Hard-coupling to a vendor SDK**: Instrumenting app code with one backend's SDK locks your spans to that backend; instrument with an OTel-native layer (OpenLLMetry / OpenInference / OpenLIT), emit OTLP once, fan out.
