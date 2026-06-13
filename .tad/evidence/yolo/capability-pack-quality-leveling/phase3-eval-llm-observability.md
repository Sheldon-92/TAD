# Phase 3 Behavioral Discriminative Eval — llm-observability

**Date**: 2026-06-13
**Pack**: llm-observability (v0.1.0)
**Fixture**: `.claude/skills/llm-observability/examples/llm-observability-fixture.md`
**Eval type**: Discriminative (separate field) — WITH-PACK vs CONTROL (no-pack generalist)

---

## Gate Parameters (from fixture frontmatter)

- `min_discriminative`: **3**
- `discriminative_pattern`:
  ```
  versioned pricing matrix|z.?score|Wasserstein|four.?layer|prompt/tool/memory/response|X-TFY-METADATA|OTEL_SEMCONV_STABILITY_OPT_IN|OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT|ExplicitBucketBoundaries|OpenLLMetry|api/public/otel|v1\.37
  ```
- Measurement: `grep -oE PATTERN | sort -u | wc -l`
- **Pass condition**: with-pack disc >= 3 AND control disc < 3

The discriminative pattern is deliberately scoped to pack-UNIQUE mechanisms only. Commodity LLMOps knowledge (`raw token counter`, `TTFT`, `HTTP 429`) is excluded because a no-pack senior engineer emits those unprompted — the fixture documents a prior false PASS (control scored 4/4) on the old contaminated pattern.

---

## Scenario

> "We just shipped an LLM chat agent. For monitoring we store the dollar cost of each call in our DB and alert when a tenant hits 100% of their monthly budget. We track average end-to-end response time. We wired tracing with the Langfuse vendor SDK directly in app code, emit a `gen_ai.client.token.usage` Counter, and turned on raw message capture for debugging. Costs feel high but we can't tell which team is driving them. Review our observability setup."

---

## WITH-PACK Answer (SKILL.md rules applied)

The agent loads cost-attribution, latency-profiling, otel-semconv, and online-eval-drift references and produces a P0/P1/P2 structured review:

- **[P0] CA3** — stored dollar cost violates the Emit-Raw-Counters cross-cutting rule → emit raw token counters, compute cost downstream from a **versioned pricing matrix**.
- **[P0] CA1** — "can't tell which team" = global-by-API-key costing → **four-layer** token accounting (**prompt/tool/memory/response**), propagate per-tenant **X-TFY-METADATA** tag.
- **[P1] LP1** — end-to-end SLO wrong for streaming → TTFT + ITL, pin spec **ExplicitBucketBoundaries** histogram buckets.
- **[P1] CA4** — binary 100% cutoff → tiered 80/90/100 + HTTP 429 + 7-day rolling **z-score** kill switch (z>4).
- **[P1] OT1/OT3** — Counter must be Histogram; set **OTEL_SEMCONV_STABILITY_OPT_IN**=gen_ai_latest_experimental, pin **v1.37**, prefer **OpenLLMetry** OTLP into Langfuse **api/public/otel** ingest.
- **[P2] OT4** — raw message capture leaks PII → gate behind **OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT**.
- **[P2] OE2** — no drift detection; KS test blind → **Wasserstein** distance on PCA-reduced embeddings.

All twelve pack-unique mechanisms are grounded in the reference files (verified by grep over `references/`).

## CONTROL Answer (generalist, NO pack)

A competent senior LLMOps engineer's unprompted review: emit raw token counters and compute cost later from a pricing table; tag by tenant/team; warn at 80% then route to a cheaper model before a hard 100% HTTP 429 block; use TTFT not end-to-end; consider OpenTelemetry over vendor SDK lock-in; be careful with PII in raw message capture.

This control is strong on commodity knowledge but names **zero** pack-unique mechanisms (no versioned pricing matrix, no four-layer / prompt-tool-memory-response decomposition, no X-TFY-METADATA, no z-score kill switch, no Wasserstein, no specific OTel env vars / ExplicitBucketBoundaries / v1.37 / OpenLLMetry / api/public/otel).

---

## Measurement

```
PATTERN='versioned pricing matrix|z.?score|Wasserstein|four.?layer|prompt/tool/memory/response|X-TFY-METADATA|OTEL_SEMCONV_STABILITY_OPT_IN|OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT|ExplicitBucketBoundaries|OpenLLMetry|api/public/otel|v1\.37'
grep -oE "$PATTERN" <answer> | sort -u | wc -l
```

| Answer | Unique markers | Count |
|--------|----------------|-------|
| WITH-PACK | versioned pricing matrix, four-layer, prompt/tool/memory/response, X-TFY-METADATA, z-score, Wasserstein, OTEL_SEMCONV_STABILITY_OPT_IN, OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT, ExplicitBucketBoundaries, OpenLLMetry, api/public/otel, v1.37 | **12** |
| CONTROL | (none) | **0** |

---

## Verdict

| Criterion | Threshold | Actual | Result |
|-----------|-----------|--------|--------|
| with-pack disc | >= 3 | 12 | PASS |
| control disc | < 3 | 0 | PASS |

**discriminative_pass = TRUE**

The pack produces 12 pack-unique mechanisms that a strong no-pack generalist does not emit (0). The gate cleanly separates pack-conferred judgment from commodity LLMOps knowledge. No false PASS — the control, despite covering raw counters / TTFT / 80-90-100 / HTTP 429 / OpenTelemetry / PII, scores 0 on the discriminative field by construction.
