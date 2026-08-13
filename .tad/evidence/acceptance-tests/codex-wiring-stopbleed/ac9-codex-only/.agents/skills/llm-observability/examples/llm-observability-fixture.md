---
name: llm-observability-cost-latency-review
description: "Tests Emit-Raw-Counters cross-cutting rule + TTFT-not-E2E latency rule + tiered budget enforcement (80/90/100% HTTP 429) on a production LLMOps setup"
pack: llm-observability
tests_rules:
  - "Cross-Cutting Rule: Emit raw token counters, not pre-calculated costs (versioned pricing matrix)"
  - "LP1 (latency): measure TTFT + ITL, not end-to-end, for streaming"
  - "CA4 (cost): tiered budget enforcement — 80% soft alert / 90% route-down / 100% HTTP 429"
  - "CA1 (cost): four-layer token accounting (prompt/tool/memory/response)"
  - "P0/P1/P2 finding output format"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-UNIQUE markers (named rules + specific mechanisms from findings.md).
# Excludes generic nouns (latency, cost, tracing, monitoring), severity tags, words from the input
# scenario, AND commodity LLMOps knowledge a no-pack senior engineer states unprompted:
#   - "raw token counter" (well-known FinOps emit-raw-not-precomputed billing pattern)
#   - "TTFT / time-to-first-token" (standard streaming-LLM knowledge; the two aliases also double-count one phrase)
#   - "HTTP 429" (the obvious budget/rate-limit status code)
# Those 4 remain in the human-facing Verification Command below, but MUST NOT drive the gate:
# a negative control (no-pack LLMOps engineer) scored 4/4 of them => false PASS. The markers kept
# here each name a pack-specific mechanism (versioned pricing matrix, z-score kill switch, Wasserstein
# drift, four-layer prompt/tool/memory/response accounting, X-TFY-METADATA propagation, the OTEL
# opt-in env var) that the same negative control scores 0 on. See code-quality.md
# "A Behavioral-Eval Gate Must Run on a SEPARATE Discriminative Field" (2026-05-31).
discriminative_pattern: "versioned pricing matrix|z.?score|Wasserstein|four.?layer|prompt/tool/memory/response|X-TFY-METADATA|OTEL_SEMCONV_STABILITY_OPT_IN|OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT|ExplicitBucketBoundaries|OpenLLMetry|api/public/otel|v1\\.37"
min_discriminative: 3
---

# Fixture: Production LLMOps Cost + Latency Review

## Input Scenario

"We just shipped an LLM chat agent. For monitoring we store the dollar cost of each call in our DB and alert when a tenant hits 100% of their monthly budget. We track average end-to-end response time. We wired tracing with the Langfuse vendor SDK directly in app code, emit a `gen_ai.client.token.usage` Counter, and turned on raw message capture for debugging. Costs feel high but we can't tell which team is driving them. Review our observability setup."

## Expected Markers

When an AI agent processes the Input Scenario with the llm-observability pack loaded,
the output MUST contain these markers:

1. **Emit raw token counters, not pre-computed cost** [structural]: the agent flags the stored-dollar-cost field as the cross-cutting violation and prescribes raw counters + a versioned pricing matrix — not a generic "track cost better"
   grep pattern: `raw token counter|versioned pricing matrix|pre.?(computed|calculated) cost`
2. **TTFT instead of end-to-end for streaming**: the agent rejects average end-to-end latency and names TTFT / time-to-first-token (and ITL)
   grep pattern: `time.?to.?first.?token|TTFT|inter.?token latency|ITL`
3. **Tiered budget enforcement (80/90/100, HTTP 429)**: the agent replaces the binary 100% cutoff with the 80% soft-alert / 90% route-down / 100% HTTP 429 chain
   grep pattern: `HTTP 429|80%|90%|route.?down|soft alert`
4. **Four-layer token accounting + tag propagation** [structural]: the agent attributes the "which team" gap to global-by-API-key costing and prescribes 4-layer accounting (prompt/tool/memory/response) with propagated metadata tags
   grep pattern: `four.?layer|prompt/tool/memory/response|X-TFY-METADATA|propagat.* (metadata )?tag`
5. **Severity-tagged findings**: P0/P1/P2 output structure with rule references
   grep pattern: `\[P0\]|\[P1\]|\[P2\]|Rule (CA|LP|TR|OT|PR|OE)[0-9]`

## Verification Command

```bash
grep -oE 'raw token counter|versioned pricing matrix|time.?to.?first.?token|TTFT|inter.?token latency|ITL|HTTP 429|80%|90%|route.?down|four.?layer|prompt/tool/memory/response|X-TFY-METADATA|z.?score|Wasserstein' llm-observability-fixture-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

The DISCRIMINATIVE-gate markers below each name a pack-UNIQUE mechanism — a no-pack LLMOps
engineer does NOT emit them unprompted:
- ✅ "versioned pricing matrix" (the pack's named rule for WHY raw counters beat a stored dollar cost)
- ✅ "z-score kill switch" (the pack's 7-day rolling spend z>4 runaway-loop pause)
- ✅ "Wasserstein drift" (the pack's PCA-reduced embedding drift metric vs ineffective K-S test)
- ✅ "four-layer token accounting (prompt/tool/memory/response)" (the pack's cost-decomposition; output tokens are materially pricier than input, with the exact multiplier computed per provider/model)
- ✅ "X-TFY-METADATA tag propagation" (the pack's specific attribution mechanism)
- ✅ "OTEL_SEMCONV_STABILITY_OPT_IN" (the pack's specific opt-in env var for latest GenAI semconv)
- ✅ "OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT" (the dedicated PII capture gate, separate from the opt-in env var — a no-pack engineer says "be careful with PII" but does not name this exact flag)
- ✅ "ExplicitBucketBoundaries" (the spec-defined advisory histogram buckets the pack pins so TTFT/ITL percentiles are cross-service comparable — not reconstructable from training memory)
- ✅ "OpenLLMetry / api/public/otel / v1.37" (named OTel-native instrumentation layer, Langfuse OTLP ingest endpoint, and the concrete v1.37 semconv version floor)

These are COMMODITY markers — kept in the human-facing Verification Command for context, but
DELIBERATELY EXCLUDED from the discriminative_pattern because a senior LLMOps engineer states them
WITHOUT the pack (a negative control scored 4 unique hits on exactly these → false PASS):
- ❌ "raw token counter" (well-known FinOps emit-raw-not-precomputed billing pattern)
- ❌ "TTFT / time-to-first-token" (standard streaming-LLM metric; the two aliases also double-count one phrase, inflating the unique count by 1)
- ❌ "HTTP 429" (the obvious budget/rate-limit status code)
- ❌ "track your costs better" / "monitor latency" / "set up better alerting" / "use a monitoring tool" (generic — restate the input, name no pack-specific mechanism)

### Negative-control proof (the gate MUST FAIL this)

A no-pack LLMOps engineer's review:
"emit raw token counters... compute cost later from a pricing table; use TTFT (time-to-first-token) not end-to-end; warn at 80%, hard block at 100% with an HTTP 429"

```bash
# Negative control against the DISCRIMINATIVE gate → MUST be 0 (< min_discriminative=3 ⇒ FAIL)
printf 'emit raw token counters... compute cost later from a pricing table; use TTFT (time-to-first-token) not end-to-end; warn at 80%%, hard block at 100%% with an HTTP 429' \
  | grep -oE 'versioned pricing matrix|z.?score|Wasserstein|four.?layer|prompt/tool/memory/response|X-TFY-METADATA|OTEL_SEMCONV_STABILITY_OPT_IN' | sort -u | wc -l
# Expected: 0  (the same control scored 4 against the OLD contaminated pattern → false PASS)
```
