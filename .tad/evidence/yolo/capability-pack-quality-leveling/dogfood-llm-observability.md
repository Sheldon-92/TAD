# Dogfood Judgment: llm-observability capability pack

Task: Review an LLM chat agent observability setup (stored dollar cost per call, 100% budget
alert, average e2e latency, Langfuse vendor SDK in app code, `gen_ai.client.token.usage`
Counter, raw message capture on for debugging, can't attribute cost per team).

Two answers; one used the `llm-observability` skill, one did not. Judged on merit with
WebSearch verification of every load-bearing specific.

---

## WebSearch verification of specific claims

### Answer 1 specifics — ALL VERIFIED CORRECT

| Claim | Verdict | Source |
|---|---|---|
| `gen_ai.client.token.usage` is a **Histogram**, not Counter | CORRECT | OTel semconv-genai repo |
| Histogram bucket boundaries `[1, 4, 16, 64, 256, 1024, ... 67108864]` | EXACT MATCH | semconv-genai gen-ai-metrics.md: `[1,4,16,64,256,1024,4096,16384,65536,262144,1048576,4194304,16777216,67108864]` |
| `gen_ai.client.operation.time_to_first_chunk` (client) exists | CORRECT | semconv-genai (recommended histogram) |
| `gen_ai.server.time_to_first_token` (server) exists | CORRECT | semconv-genai |
| TTFT is a metric, not a span attribute | CORRECT | semconv-genai metrics |
| `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` is the opt-in PII gate; off by default | CORRECT | OTel instrumentation docs (default NO_CONTENT) |
| It is SEPARATE from the semconv stability opt-in | CORRECT | two distinct env vars |
| `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental`, SDK/Collector >= v1.37 | CORRECT | OTel semconv (v1.36 default, latest_experimental needed) |
| Langfuse ingests OTLP at `/api/public/otel`; v3 SDK OTel-native | CORRECT | Langfuse OTEL docs (endpoint introduced v3.22.0) |
| TrueFoundry `X-TFY-METADATA` for per-tenant cost attribution at gateway | CORRECT | TrueFoundry request-headers + cost-attribution blog (customer_id multi-tenant) |
| Output ~5x input on Claude 4.x | CORRECT | Opus $5 in / $25 out = exactly 5x |
| Output ~6x input on GPT-5 | CORRECT | GPT-5.5 $5 in / $30 out = exactly 6x (hedged "verify live") |

One minor imprecision: "Pin the spec's finer sub-second TTFT bucket boundaries (down to 1ms)."
The verified TTFT / operation.duration boundaries start at **0.01s = 10ms**, not 1ms. This is a
small overstatement of granularity, not a wrong instrument or wrong metric name. Does not
materially mislead. Counts as a minor specificity blemish, not a correctness-tanking error.

The "Rule CA3 / OT5 / C3 / C4" internal rule-ID references are the pack's own taxonomy — not
externally verifiable but not claims about the world; harmless.

### Answer 2 specifics — ALL CORRECT, none wrong

| Claim | Verdict |
|---|---|
| `gen_ai.client.token.usage` defined as Histogram, want p50/p95/p99 distribution | CORRECT |
| TTFT vs total latency, alert p95/p99 not mean | CORRECT |
| Vendor SDK → instrument on OTel, export OTLP to Langfuse (config not rewrite) | CORRECT |
| Cost should be token-derived + versioned price list, recompute history | CORRECT |
| Raw capture = PII/GDPR/CCPA/secrets landmine; redact + sample + retention | CORRECT |
| Add attribution dims tenant.id/team.id/model/feature → GROUP BY | CORRECT |
| Alert 50/80/100% + projected run-rate; circuit breaker | Reasonable/CORRECT |

Answer 2 makes **zero false specifics**. It deliberately stays general (no exact bucket arrays,
no env var names, no header names) — and is therefore never wrong. It also raises two items
Answer 1 underweights: **online eval / quality signal** (#9) and **prompt versioning tied to
traces** (#10), both squarely in the pack's stated scope (prompt registry, online eval,
groundedness/drift).

---

## Scoring (1-5)

| Dimension | A1 | A2 |
|---|---|---|
| Correctness | 5 | 5 |
| Actionability | 5 | 4 |
| Specificity | 5 | 3 |
| Completeness | 5 | 4 |

Both are correct. The differentiator is specificity grounded in verified fact. Answer 1
delivers exact env var names, the exact histogram bucket array, the exact OTLP endpoint path,
the exact gateway header, and correct cost multipliers — every one of which checked out against
primary docs. This is NOT verbosity-as-padding: each specific is directly actionable (the reader
can copy the env var, the endpoint, the header). Answer 1 also nails the two-env-var subtlety
(stability opt-in is separate from content capture) that a non-expert routinely conflates.

Answer 2 is a genuinely strong, well-organized review and covers two scope items A1 underweights
(online eval, prompt versioning). But it is correct largely by staying general; where A1 commits
to a specific and is right, A2 declines to commit. On a "review my setup, tell me exactly what to
change" task, the verified-correct specifics win.

Answer 1's only blemish (TTFT "down to 1ms" vs actual 10ms floor) is minor and does not flip the
correctness scores.

## Winner: Answer 1, CLEAR margin

Won on CORRECT, verified specifics — not verbosity. Every high-risk specific (env vars, bucket
array, endpoint, header, cost ratios) was confirmed against primary sources. The likely
skill-using answer is Answer 1.
