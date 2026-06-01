# OpenTelemetry GenAI Semantic Convention Rules
<!-- capability: otel_semconv -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| OT1 | Opt in to latest GenAI semconv via OTEL_SEMCONV_STABILITY_OPT_IN env var | deterministic |
| OT2 | Required span attributes: gen_ai.operation.name + gen_ai.provider.name | deterministic |
| OT3 | Use the standard gen_ai.usage.* token attributes (incl. cache + reasoning) | deterministic |
| OT4 | gen_ai.input.messages / output.messages are Opt-In — gate on PII policy | deterministic |
| OT5 | Use standard metrics (token.usage Histogram, *.duration Histogram) for portability | deterministic |
| OT6 | provider.name supersedes legacy gen_ai.system — read new first, fall back | deterministic |

---

## Rules

### OT1: Opt In to Latest GenAI Semconv

The CNCF OpenTelemetry GenAI Semantic Conventions standardize spans/events/metrics so telemetry is portable across APM platforms and avoids vendor lock-in. The latest conventions are NOT emitted by default — applications must opt in via an environment variable:

```
OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental
```

**Rule**: Without this env var, your SDK emits older/partial conventions and downstream consumers miss the new attributes (cache tokens, reasoning tokens, TTFT). Set it explicitly in the runtime environment.

> Source: findings.md "applications must opt in using the following environment variable: OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental" [15]

**determinismLevel**: deterministic — a fixed env-var contract.

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
| `gen_ai.response.time_to_first_chunk` | TTFT in streaming calls (seconds) |

**Rule**: Do not invent custom token fields when these standard keys exist. Capturing `cache_read`/`cache_creation` separately is what makes prompt-cache ROI measurable; capturing `reasoning.output_tokens` is what exposes hidden reasoning spend (see cost CA2).

> Source: findings.md "Token Usage and Payload Attributes" table [15, 16]

**determinismLevel**: deterministic — schema-defined keys.

### OT4: Message Payloads Are Opt-In (PII Gate)

`gen_ai.input.messages` and `gen_ai.output.messages` carry the structured prompt/response arrays. Their requirement level is **Opt-In** — they are NOT emitted by default.

**Rule**: Treat capturing raw messages as a privacy decision, not a default. Enabling Opt-In message capture writes user prompts and model outputs into your trace store; gate it behind a PII/compliance policy. For privacy-sensitive workloads keep them off and rely on token counters + metadata tags.

> Source: findings.md "gen_ai.input.messages | Opt-In ... gen_ai.output.messages | Opt-In" [15, 16]

**determinismLevel**: deterministic — a fixed requirement level + policy choice.

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

> Source: OpenTelemetry GenAI semantic conventions, "Generative AI metrics" — `gen_ai.client.token.usage` is a Histogram filtered by `gen_ai.token.type`; durations are Histograms [17]

**determinismLevel**: deterministic — instrument types are schema-defined.

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
