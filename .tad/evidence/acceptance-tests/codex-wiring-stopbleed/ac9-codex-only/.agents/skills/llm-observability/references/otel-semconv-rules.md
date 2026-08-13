# OpenTelemetry GenAI Semantic Convention Rules
<!-- capability: otel_semconv -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| OT1 | Opt in to latest GenAI semconv via env var AND pin SDK/Collector ≥ v1.37 (still experimental) | deterministic |
| OT2 | Required span attributes: gen_ai.operation.name + gen_ai.provider.name | deterministic |
| OT3 | Use the standard gen_ai.usage.* token attributes (incl. cache + reasoning) | deterministic |
| OT4 | Message capture gated by OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT; messages now span attributes | deterministic |
| OT5 | Use standard metrics as Histograms with the spec-defined advisory bucket boundaries | deterministic |
| OT6 | provider.name supersedes legacy gen_ai.system — read new first, fall back | deterministic |

---

## Rules

### OT1: Opt In to Latest GenAI Semconv

The CNCF OpenTelemetry GenAI Semantic Conventions standardize spans/events/metrics so telemetry is portable across APM platforms and avoids vendor lock-in. The latest conventions are NOT emitted by default — applications must opt in via an environment variable:

```
OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental
```

**Rule**: Without this env var, your SDK emits older/partial conventions and downstream consumers miss the new attributes (cache tokens, reasoning tokens, TTFT). Set it explicitly in the runtime environment. The `gen_ai_latest_experimental` value emits the **latest experimental** convention version while suppressing the old v1.36.0-or-prior emission.

**Pin a concrete version floor, not just the opt-in.** The GenAI conventions are still in **Development / experimental** status as of 2026 (NOT stable — breaking changes possible between minor releases). Require **OTel SDK / Collector ≥ v1.37** and version-pin your collector: Datadog LLM Observability natively supports "OpenTelemetry GenAI Semantic Conventions v1.37 and up" (Dec 2025), so a collector below v1.37 emits attributes a v1.37+ consumer may not read. Document the experimental status in your runbook so a minor-version bump is treated as a potential breaking change, not a silent upgrade.

> Source: findings.md "applications must opt in using the following environment variable: OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental" [15]; Datadog "OpenTelemetry GenAI Semantic Conventions v1.37 and up" (https://www.datadoghq.com/blog/llm-otel-semantic-convention/, retrieved 2026-06-13); OTel GenAI semconv still in Development (https://opentelemetry.io/docs/specs/semconv/gen-ai/, retrieved 2026-06-13).

**determinismLevel**: deterministic — a fixed env-var contract + version floor.

### OT2: Required Span Attributes

Two attributes are **Required** on every GenAI span; others are conditionally required or recommended:

| Attribute | Requirement | Allowed / Example Values |
|-----------|-------------|--------------------------|
| `gen_ai.operation.name` | **Required** | `chat`, `embeddings`, `retrieval`, `execute_tool` |
| `gen_ai.provider.name` | **Required** | `openai`, `anthropic`, `gcp.vertex_ai` |
| `error.type` | Conditionally Required (on failure) | `timeout`, `500`, `java.net.UnknownHostException` |
| `gen_ai.request.model` | Conditionally Required | `gpt-4`, `claude-3-5-sonnet` |
| `gen_ai.response.model` | Recommended | `gpt-4-0613` (the model that actually executed) |
| `gen_ai.conversation.id` | Recommended | correlates multi-turn messages, e.g. `conv_5j66UpCpwteGg4YSx` |
| `gen_ai.agent.name` / `gen_ai.agent.id` | Recommended | `math_agent` / `asst_5j66UpCpwteGg4YSx` |
| `gen_ai.request.temperature` | Recommended (Double) | `0.0`, `0.7` |
| `gen_ai.request.stream` | Recommended (Boolean) | `true`, `false` |

**Rule**: A span missing `gen_ai.operation.name` or `gen_ai.provider.name` is non-conformant. Record `gen_ai.response.model` separately from `gen_ai.request.model` — model fallback/routing means the executed model may differ from the requested one.

> Source: findings.md "Span and Event Attributes" table [15, 16, 17]

**determinismLevel**: deterministic — schema-defined requirement levels.

### OT3: Standard Token-Usage Attributes (Cache & Reasoning Included)

Use the standard token attributes so billing engines and APM tools read them uniformly:

| Attribute | Meaning |
|-----------|---------|
| `gen_ai.usage.input_tokens` | Total prompt tokens consumed (including cache) |
| `gen_ai.usage.output_tokens` | Response tokens generated |
| `gen_ai.usage.cache_read.input_tokens` | Tokens read from provider cache |
| `gen_ai.usage.cache_creation.input_tokens` | Tokens written to provider cache |
| `gen_ai.usage.reasoning.output_tokens` | Tokens consumed by model reasoning |

**Rule**: Do not invent custom token fields when these standard keys exist. Capturing `cache_read`/`cache_creation` separately is what makes prompt-cache ROI measurable; capturing `reasoning.output_tokens` is what exposes hidden reasoning spend (see cost CA2).

> Source: findings.md "Token Usage and Payload Attributes" table [15, 16]

**determinismLevel**: deterministic — schema-defined keys.

### OT4: Message Payloads — Capture Gated by a Dedicated Env Var; Now Span Attributes

`gen_ai.input.messages` and `gen_ai.output.messages` carry the structured prompt/response arrays. Their requirement level is **Opt-In** — they are NOT emitted by default.

**Two freshness facts the audit must enforce:**

1. **Dedicated capture gate.** Message-content capture is gated by its OWN env var, **`OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT`** — this is SEPARATE from `OTEL_SEMCONV_STABILITY_OPT_IN` (OT1). Opting into the latest semconv does NOT by itself emit message bodies; you must additionally set the capture flag. Treat this flag as the explicit **PII gate**: it is the single switch that decides whether user prompts and model outputs land in your trace store.
2. **Events → span attributes migration.** In the latest GenAI semconv, `gen_ai.input.messages` / `gen_ai.output.messages` migrated from log-based **EVENTS** to **SPAN ATTRIBUTES**, following the Input/Output messages JSON schema (entries in **send order**). A parser that reads only attributes will NOT see messages from older SDKs that still emit them as events (the same new→legacy fallback reasoning as OT6).

**Rule**: Treat message capture as a privacy decision, not a default. Gate it behind `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` + a PII/compliance policy; for privacy-sensitive workloads keep the flag unset and rely on token counters + metadata tags. When consuming messages, read span attributes first and fall back to the legacy event form for older SDKs, or attribute-only parsers will silently drop their payloads.

> Source: OTel GenAI events spec — capture gated by `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT`, messages now span attributes (Input/Output JSON schema, send order) (https://opentelemetry.io/docs/specs/semconv/gen-ai/gen-ai-events/, retrieved 2026-06-13); MLflow confirms events→attributes migration + `MLFLOW_ENABLE_OTEL_GENAI_SEMCONV` (https://mlflow.org/docs/latest/genai/tracing/opentelemetry/genai-semconv/, retrieved 2026-06-13); findings.md "gen_ai.input.messages | Opt-In ... gen_ai.output.messages | Opt-In" [15, 16].

**determinismLevel**: deterministic — a fixed env-var gate + schema requirement level.

### OT5: Standard Metrics for Portability

Emit the standard GenAI metrics rather than bespoke ones so any OTel-compatible backend can consume them:

| Metric | Instrument | Unit | Key Attributes |
|--------|-----------|------|----------------|
| `gen_ai.client.token.usage` | Histogram | tokens | `gen_ai.token.type`, `gen_ai.request.model`, `gen_ai.provider.name` |
| `gen_ai.client.operation.duration` | Histogram | seconds | `gen_ai.operation.name`, `gen_ai.request.model` |
| `gen_ai.client.operation.time_to_first_chunk` | Histogram | seconds | `gen_ai.request.model`, `gen_ai.provider.name` |
| `gen_ai.server.request.duration` | Histogram | seconds | `gen_ai.request.model`, `server.address` |
| `gen_ai.server.time_to_first_token` | Histogram | seconds | `gen_ai.response.model`, `server.address` |

**Rule**: All of these are Histograms in the OTel GenAI semconv — `gen_ai.client.token.usage` is the spec-defined token-usage histogram (split by `gen_ai.token.type` for input vs output), and durations/TTFT are histograms too (so you can compute p50/p95/p99). Use the OTel-defined histogram with `gen_ai.token.type`; do not substitute a Counter or gauge, which breaks downstream percentile/distribution aggregation.

**Pin the spec-defined advisory bucket boundaries — do NOT let your metrics backend auto-bucket.** The OTel GenAI semconv ships explicit advisory `ExplicitBucketBoundaries` per metric. If you let the backend auto-bucket, TTFT/ITL percentiles are NOT comparable across services. Pin these exact arrays:

| Metric | Unit | Advisory bucket boundaries |
|--------|------|----------------------------|
| `gen_ai.client.token.usage` | `{token}` | `[1, 4, 16, 64, 256, 1024, 4096, 16384, 65536, 262144, 1048576, 4194304, 16777216, 67108864]` |
| `gen_ai.client.operation.duration` / `gen_ai.server.request.duration` | `s` | `[0.01, 0.02, 0.04, 0.08, 0.16, 0.32, 0.64, 1.28, 2.56, 5.12, 10.24, 20.48, 40.96, 81.92]` |
| `gen_ai.server.time_to_first_token` | `s` | `[0.001, 0.005, 0.01, 0.02, 0.04, 0.06, 0.08, 0.1, 0.25, 0.5, 0.75, 1.0, 2.5, 5.0, 7.5, 10.0]` |
| `gen_ai.server.time_per_output_token` | `s` | `[0.01, 0.025, 0.05, 0.075, 0.1, 0.15, 0.2, 0.3, 0.4, 0.5, 0.75, 1.0, 2.5]` |

Note the duration buckets are a **power-of-two** progression (0.01 × 2ⁿ up to 81.92s) while TTFT/ITL use **finer sub-second** boundaries (down to 1ms / 10ms) — because first-token and per-token latency live in the tens-of-ms range where coarse duration buckets would collapse the whole distribution into one bucket.

> Source: OpenTelemetry GenAI metrics spec — exact `ExplicitBucketBoundaries` for `gen_ai.client.token.usage`, `*.operation.duration`, `gen_ai.server.request.duration`, `gen_ai.server.time_to_first_token`, `gen_ai.server.time_per_output_token` (https://github.com/open-telemetry/semantic-conventions-genai/blob/main/docs/gen-ai/gen-ai-metrics.md, retrieved 2026-06-13); findings.md "Generative AI metrics" [17].

**determinismLevel**: deterministic — instrument types AND advisory boundaries are schema-defined.

### OT6: provider.name Supersedes Legacy gen_ai.system

When parsing spans for the provider, read the standard tag first and fall back for older libraries. Apache SkyWalking 10.4 extracts provider names by checking `gen_ai.provider.name` first, falling back to the legacy `gen_ai.system` tag for older library compatibility, then using prefix-matching rules in `gen-ai-config.yml` if no tags are present.

**Rule**: A parser that reads only `gen_ai.system` misses spans from new SDKs; one that reads only `gen_ai.provider.name` misses spans from old SDKs. Read new → legacy → prefix-match, in that order.

> Source: findings.md "checking the standard gen_ai.provider.name tag first, falling back to the legacy gen_ai.system tag for older library compatibility, and using prefix matching rules in gen-ai-config.yml" [18]

**determinismLevel**: deterministic — a fixed fallback chain.

---

## Anti-Patterns

- **Relying on defaults**: The latest semconv is opt-in; without `OTEL_SEMCONV_STABILITY_OPT_IN` you silently emit partial data.
- **Custom token field names**: Reinventing `gen_ai.usage.*` breaks billing/APM interoperability.
- **Capturing messages by default**: `input.messages`/`output.messages` are Opt-In for privacy reasons — enabling them writes PII into traces.
- **Single provider-tag parsing**: Reading only `gen_ai.system` OR only `gen_ai.provider.name` drops spans from the other SDK generation.
- **Wrong instrument types**: Substituting a Counter or gauge for the spec-defined `gen_ai.client.token.usage` Histogram, or a counter for latency, breaks p95/p99 distribution aggregation.
