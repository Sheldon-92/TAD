---
name: llm-observability
description: LLM observability & LLMOps capability pack. Gives AI agents the judgment rules for production-grade distributed tracing, real-time cost attribution & budget governance, OpenTelemetry GenAI semantic conventions, latency/TTFT profiling, prompt registry & versioning, and online evaluation with groundedness & drift detection. Research-grounded rules from LangSmith, Langfuse, Arize Phoenix, Helicone, MLflow, Braintrust, TrueFoundry, vLLM, and the OpenTelemetry GenAI semantic conventions. Use for any LLM monitoring, tracing, cost governance, prompt versioning, latency profiling, or production drift/hallucination task.
keywords: ["可观测性", "observability", "LLMOps", "监控", "monitoring", "分布式追踪", "tracing", "OpenTelemetry", "OTel", "成本归因", "cost attribution", "token 计费", "延迟", "latency", "TTFT", "提示词版本", "prompt registry", "漂移检测", "drift", "groundedness", "Langfuse", "vLLM"]
type: reference-based
---

**CONSUMES**: User observability/LLMOps task + production LLM-or-agent system description + optional existing tracing/cost/registry configs
**PRODUCES**: Applied observability judgment rules + tracing platform recommendation + cost-attribution & budget-governance design + OTel GenAI semconv audit + latency/TTFT profiling plan + prompt-registry versioning policy + online-eval & drift-detection pipeline

# LLM Observability & LLMOps Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents wire up LLM observability by copying a tracing SDK's quickstart. They log end-to-end latency and call it monitoring — missing TTFT, the metric that actually governs perceived responsiveness in streaming. They store a single pre-computed dollar cost per call, which silently goes wrong the moment a provider changes list prices. They aggregate spend globally by API key, so no one can say which tenant drove the bill. They hardcode prompts in app code, coupling every typo fix to a redeploy. They run a Kolmogorov–Smirnov test on raw embeddings to "detect drift" and find nothing, because univariate tests are blind to high-dimensional shift.

This pack embeds the judgment rules that LLMOps and reliability engineers apply automatically — rules from production tracing platforms, cost-attribution gateways, the OpenTelemetry GenAI semantic conventions, vLLM inference monitoring, prompt-registry internals, and drift-detection pipelines.

**Pack = observability/LLMOps judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Emit Raw Token Counters, Not Pre-Calculated Costs

> **In every span, metric, and trace, record RAW token counters (input / output / cache_read / cache_creation / reasoning) — NEVER a single pre-multiplied dollar cost.** Providers frequently change list prices; a stored pre-computed cost becomes wrong the instant prices change and cannot be corrected for historical traces. Downstream billing engines must compute cost dynamically by querying a *versioned pricing matrix* against the raw counters.

This rule applies to: cost attribution, OTel semconv emission, gateway design, and chargeback reporting. It is surfaced here because burying it in one reference file is exactly how agents end up with un-reconcilable historical billing.

---

## Step 0: Context Detection

When the user mentions observability / LLMOps work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "tracing", "span tree", "LangSmith", "Langfuse", "Phoenix", "Helicone", "which platform", "分布式追踪" | `references/tracing-platform-rules.md` |
| "cost", "token budget", "chargeback", "per-tenant", "rate limit", "budget enforcement", "成本归因", "token 计费" | `references/cost-attribution-rules.md` |
| "OpenTelemetry", "OTel", "semantic conventions", "gen_ai attributes", "span attributes", "metrics", "semconv" | `references/otel-semconv-rules.md` |
| "latency", "TTFT", "time to first token", "ITL", "vLLM", "profiling", "prefill", "decode", "延迟" | `references/latency-profiling-rules.md` |
| "prompt registry", "prompt versioning", "MLflow prompt", "Braintrust", "alias", "staged rollout", "提示词版本" | `references/prompt-registry-rules.md` |
| "online eval", "LLM-as-judge", "groundedness", "hallucination", "drift", "Wasserstein", "embedding drift", "漂移检测" | `references/online-eval-drift-rules.md` |
| "full observability", "complete LLMOps setup", "monitor everything" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's observability setup, config, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix
4. **Enforce the Emit-Raw-Counters cross-cutting rule** on every cost/telemetry emission you review
5. **Check determinismLevel annotations** — they tell you how stable a rule's signal is:
   - `deterministic`: a fixed architectural/schema fact (platform choice, OTel requirement level, install command)
   - `semi-deterministic`: a tunable range or judge-derived ratio (margin caps, groundedness score)
   - `non-deterministic`: depends on live production distribution (z-score kill switch, embedding drift)

Output format per finding:
```
[P0] Rule CA3 (cost-attribution): Spans store a pre-computed cost field, no raw token counters.
→ Emit gen_ai.usage.input_tokens / output_tokens / cache_read / reasoning; compute cost downstream from a versioned pricing matrix.

[P1] Rule LP1 (latency-profiling): SLO is written against end-to-end latency for a streaming chat product.
→ Re-base the SLO on TTFT (perceived responsiveness) + ITL (streaming smoothness); capture TTFT via the gen_ai.client.operation.time_to_first_chunk histogram (client) / gen_ai.server.time_to_first_token (server) — TTFT is a metric, not a span attribute.
```

---

## Step 1.5: Run the Conformance Checker (deterministic)

When the user supplies an OTLP/trace export (JSON), an SDK config, or an env file, run the
deterministic verifier instead of eyeballing the four OTel semconv invariants:

```bash
scripts/otel-conformance-check.sh <export-or-config-file>   # or '-' for stdin
```

It checks (exit code = number of failed checks; 0 = PASS):
- **C1** `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental` is set (OT1)
- **C2** required span attrs `gen_ai.operation.name` + `gen_ai.provider.name` present (OT2)
- **C3** raw `gen_ai.usage.*_tokens` counters present AND no pre-computed flat `cost` field (OT3 + cross-cutting rule)
- **C4** `gen_ai.client.token.usage` emitted as **Histogram**, not Counter/Gauge (OT5)

Fold each failed check into the Telemetry Conformance Audit (Step 2) as a P0/P1 finding. Deterministic
ops belong in code — do not re-derive these by hand when the user gave you the actual telemetry.

---

## Step 2: Output

Produce a structured observability review:

```
## Observability Review: [area reviewed]

### P0 — Blocking (must fix before production)
- [finding + specific fix]

### P1 — Required (fix before trusting the telemetry)
- [finding + specific fix]

### P2 — Advisory (improves observability quality)
- [finding + specific fix]

### Telemetry Conformance Audit
[checklist: OTEL_SEMCONV_STABILITY_OPT_IN set? required gen_ai.* attributes present? raw counters not pre-computed costs?]

### Platform / Tool Recommendation
[tracing platform by architecture + framework match; gateway for cost governance]
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "We log latency, that's monitoring" | End-to-end latency is the wrong SLO for streaming. A 500ms TTFT with 10s total feels instant; a 4s TTFT with 5s total feels frozen. Measure TTFT + ITL. |
| "We store the cost per call, simpler" | Pre-computed cost is wrong the moment list prices change and is un-reconcilable for historical traces. Store raw counters + a versioned pricing matrix. |
| "We track total tokens" | Total tokens hides where spend originates. Split into the 4 layers (prompt/tool/memory/response) — tool-schema re-injection is silent bloat, and output tokens are materially more expensive than input (compute the exact multiplier from the provider/model pricing table). |
| "A proxy gateway gives us tracing" | A proxy only intercepts external API calls; it cannot reconstruct nested in-app agent steps unless context headers are explicitly passed. Use an SDK/OTel tracer for the span tree. |
| "Prompts live in the codebase" | Hardcoded prompts couple every template tweak to a redeploy. Use a registry; query the @production alias, not a pinned version number. |
| "We run a KS test for drift" | Kolmogorov–Smirnov is univariate and blind to high-dimensional embedding shift. Use Wasserstein distance on PCA-reduced (95% variance) vectors, then a judge LLM to classify the driver. |

---

## Tool Quick Reference

| Tool | Install / Wire-up | Primary Use |
|------|-------------------|-------------|
| Langfuse | SDK (Python/TS) or OTel; MIT, self-hostable | Framework-agnostic tracing, prompt-to-trace, data sovereignty |
| Arize Phoenix | OTel-based, local Jupyter → cloud; Elastic License 2.0 | Embedding/RAG validation rigor |
| Helicone | Proxy URL redirection (~5 min setup) | Fast external-API interception, caching, failover |
| vLLM + OTel | OTel deps ship bundled with current vLLM (else install `opentelemetry-sdk` / `opentelemetry-api` / `opentelemetry-exporter-otlp`); start with `--otlp-traces-endpoint`, scrape `/metrics` every 15s | Self-hosted inference latency (prefill/decode, TTFT, time-in-queue) |
| MLflow Prompt Registry | `mlflow.genai.register_prompt`, alias `@production` | Immutable versioned prompts, dual-TTL cache |
| OpenTelemetry GenAI semconv | `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental`; pin SDK/Collector ≥ **v1.37** (still experimental — version-pin) | Portable `gen_ai.*` spans/metrics, vendor-neutral |
| OTel-native instrumentation | OpenLLMetry (`traceloop`), OpenInference (Arize), OpenLIT — emit OTLP once, fan out to any backend | Vendor-neutral `gen_ai.*` spans into Langfuse/Phoenix/Datadog (Java+Go beyond Python/TS SDKs) |
| `scripts/otel-conformance-check.sh` | `scripts/otel-conformance-check.sh <export-or-config>` (exit 0 = PASS; non-zero = #failed checks) | Deterministic OTel semconv conformance audit (C1–C4) |
