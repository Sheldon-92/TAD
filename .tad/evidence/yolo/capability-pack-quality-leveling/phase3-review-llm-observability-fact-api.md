# Phase 3 Adversarial Review — llm-observability — Lens: fact-api

**Reviewer**: Claude Opus 4.8 (fact-api lens, replaces cross-model review)
**Date**: 2026-06-13
**Verdict (meets_bar)**: **false** — 2 fabricated API/identifier facts (P1) that an agent would emit verbatim into a user's telemetry config and OTel SDK install. The pack is otherwise unusually well-sourced (most version-sensitive claims verified against primary docs), but the fact-api bar is "no wrong API names/constants," and it carries two.

---

## Lens
fact-api: hunt for wrong class/attribute names, deprecated/renamed APIs, wrong metric types, wrong constants/versions. Every version-sensitive claim WebSearched against current primary documentation.

---

## Findings

### P1 — `gen_ai.response.time_to_first_chunk` is a FABRICATED span attribute
- Appears in: SKILL.md Step 1.5 / Step 1 output example (`capture gen_ai.response.time_to_first_chunk`), `otel-semconv-rules.md` OT3 table (row `gen_ai.response.time_to_first_chunk | TTFT in streaming calls (seconds)`), and `latency-profiling-rules.md` LP1 ("Capture TTFT via `gen_ai.response.time_to_first_chunk`").
- Primary docs: the OTel GenAI semconv defines TTFT **only as metrics** — `gen_ai.client.operation.time_to_first_chunk` (Histogram) and `gen_ai.server.time_to_first_token` (Histogram). There is **no `gen_ai.response.*` namespace** and **no `time_to_first_chunk` span attribute**. An agent applying OT3 would instruct the user to emit a non-existent attribute that no conformant backend reads.
- Fix: drop the OT3 table row; in LP1/Step 1.5 say "capture TTFT via the `gen_ai.client.operation.time_to_first_chunk` histogram (client) / `gen_ai.server.time_to_first_token` (server); TTFT is a metric, not a span attribute."

### P1 — `pip install vllm[otel]` extra does not exist
- Appears in: SKILL.md Tool Quick Reference (`vLLM + OTel | pip install vllm[otel]`) and `latency-profiling-rules.md` LP3 (`pip install vllm[otel]`, and the rule text "Use the `vllm[otel]` extra (not a hand-rolled exporter)").
- Primary docs: vLLM's official OpenTelemetry POC instructs installing the OTel packages explicitly — `pip install 'opentelemetry-sdk>=1.26.0,<1.27.0' 'opentelemetry-api>=1.26.0,<1.27.0' 'opentelemetry-exporter-otlp>=1.26.0,<1.27.0' 'opentelemetry-semantic-conventions-ai>=0.4.1,<0.5.0'` (and notes these are bundled with recent vLLM). There is **no `[otel]` extra** in vLLM's packaging. `pip install vllm[otel]` will not resolve the documented extra.
- Fix: replace with the explicit `opentelemetry-*` package set (or "OTel deps ship bundled with current vLLM; otherwise install opentelemetry-sdk/api/exporter-otlp"). Keep `--otlp-traces-endpoint` and `/metrics` scrape (both correct).

### P2 — CA2 speculative model names (`GPT-5.4`, `GPT-5.4 Pro`) and exact prices
- `cost-attribution-rules.md` CA2 table cites GPT-5.4 $2.50/$15, GPT-5.4 Pro $30/$180. These specific SKU names/prices could not be confirmed as current. MITIGATED: the rule explicitly labels them "dated anchors that will rot — verify against the live pricing table before quoting" and the actionable rule is "compute the exact multiplier from live pricing," so an agent is steered to re-verify. Downgraded from P1 to P2 on that hedge. Recommend tagging the rows "illustrative" to avoid an agent quoting them as fact.

### P2 — OT5 listed metric `gen_ai.client.operation.time_to_first_chunk` is correct but the SKILL pairs it confusingly with the fabricated span attr
- Once the P1 span-attribute fix lands, ensure the metric names used (`gen_ai.client.operation.time_to_first_chunk`, `gen_ai.server.time_to_first_token`) stay — they are verified-correct.

---

## fact_checks (every version-sensitive claim → primary source)

1. **OT1 `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental`** — CORRECT. opentelemetry.io/docs/specs/semconv/gen-ai: the value "emits the latest experimental version… and does not emit the old one (v1.36.0 or prior)." Pack's "suppresses v1.36.0-or-prior" wording matches verbatim.
2. **OT1 version floor "≥ v1.37, still experimental"** — CORRECT & still valid. GenAI semconv is in Development; latest tag is now v1.38.0 (v1.37 remains a sound floor; pack already says "version-pin / treat minor bump as breaking").
3. **OT2 required attrs `gen_ai.operation.name` + `gen_ai.provider.name`** — CORRECT. Confirmed Required on GenAI spans (livekit issue #4639 + spans spec).
4. **OT3 token attrs `gen_ai.usage.input_tokens / output_tokens / cache_read.input_tokens / cache_creation.input_tokens / reasoning.output_tokens`** — ALL CORRECT. Confirmed in the gen-ai attribute registry (input/output_tokens; cache_creation.input_tokens; cache_read.input_tokens; reasoning.output_tokens all exist; prompt_tokens/completion_tokens deprecated).
5. **OT3/Step1.5/LP1 `gen_ai.response.time_to_first_chunk` span attribute** — WRONG / FABRICATED (see P1 #1). No such attribute; TTFT is metric-only.
6. **OT4 `OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT` + events→span-attributes migration** — CORRECT. Matches OTel gen-ai-events spec + MLflow semconv docs (messages migrated to span attributes; capture gated by dedicated env var).
7. **OT5 instrument types (all Histograms incl. `gen_ai.client.token.usage`)** — CORRECT. Confirmed Histogram in gen-ai-metrics spec.
8. **OT5 bucket boundaries** — CORRECT (verified against raw semconv-genai metrics.md). token.usage `[1,4,16,…,67108864]` ✓; operation.duration `[0.01,…,81.92]` ✓; `gen_ai.server.time_to_first_token` `[0.001,0.005,0.01,0.02,0.04,0.06,0.08,0.1,0.25,0.5,0.75,1.0,2.5,5.0,7.5,10.0]` ✓ exact; `gen_ai.server.time_per_output_token` `[0.01,0.025,0.05,0.075,0.1,0.15,0.2,0.3,0.4,0.5,0.75,1.0,2.5]` ✓ exact. (An intermediary summarizer initially mis-claimed all arrays were identical; the raw spec file confirms the pack's finer sub-second TTFT/TPOT arrays are right.)
9. **OT6 `gen_ai.provider.name` supersedes legacy `gen_ai.system`** — CORRECT. provider.name is the current discriminator; gen_ai.system is the legacy/deprecated form; new→legacy fallback is sound.
10. **CA7 AWS STS AssumeRole quota 600 RPS/account/Region shared** — CORRECT. AWS IAM/STS quotas doc = 600 req/s per account per Region, shared across STS. Pack correctly overrode findings.md's erroneous 500.
11. **CA4 budget thresholds 80%/90%/100% + HTTP 429** — internally consistent, sourced to findings; not a public-API fact (no contradiction found).
12. **CA2 output:input multipliers / GPT-5.4 / Claude 4.x prices** — UNVERIFIED SKUs (see P2). Relationship "output > input" is correct; specific SKU names/prices not confirmed; pack hedges as "dated anchors, verify live."
13. **PR3 MLflow APIs `mlflow.genai.register_prompt`, `set_prompt_model_config` (model_name/temperature/max_tokens), `set_prompt_version_tag`, `delete_prompt_version` one-at-a-time** — CORRECT. Confirmed against MLflow Prompt Registry API docs (PromptModelConfig fields model_name/temperature/max_tokens/top_p/top_k match).
14. **PR4 dual-TTL: version=infinite, alias=60s** — CORRECT. MLflow docs: alias default 60s (`MLFLOW_ALIAS_PROMPT_CACHE_TTL_SECONDS=60`), version default None/infinite.
15. **PR5 URI syntax: alias `prompts:/<name>@<alias>`, version `prompts:/<name>/<n>`** — CORRECT, and the pack's note "corrected from the slash-alias form" is right. MLflow uses `prompts:/name@alias` and `prompts:/name/version`.
16. **LP3 `pip install vllm[otel]` extra** — WRONG / FABRICATED (see P1 #2). vLLM has no `[otel]` extra; use explicit opentelemetry-* packages.
17. **LP3 `--otlp-traces-endpoint` flag + `/metrics` scrape** — CORRECT. Matches vLLM OTel POC docs.
18. **LP4 vLLM span attrs `gen_ai.latency.time_in_model_prefill` / `time_in_model_decode`** + metric `vllm:time_per_output_token_seconds`** — CORRECT. Confirmed as real vLLM SpanAttributes (vllm/tracing/utils.py) and a real Prometheus metric.
19. **LP5 `gen_ai.latency.time_in_queue`** — CORRECT. Real vLLM queue-interval span attribute.
20. **TR1/TR4/TR5 Langfuse MIT + OTLP `/api/public/otel`; Phoenix Elastic License 2.0; LangSmith closed-SaaS self-host=Enterprise** — licenses/architecture consistent with vendor docs; pricing explicitly dated/hedged ("rot before quoting"). No factual error found; pricing not independently re-priced (hedged).
21. **OE3 Wasserstein on PCA-reduced embeddings (95% var), not KS test** — methodologically correct; no API/constant to mis-state.

---

## Bottom line
- Verified-correct: 18 of 21 version-sensitive claim clusters, including all OTel constants/bucket arrays, all MLflow APIs, AWS STS quota, and vLLM span/metric names — this is a strongly-sourced pack.
- Disqualifying for fact-api lens: **2 P1 fabrications** an agent will emit verbatim into config — a non-existent OTel span attribute (`gen_ai.response.time_to_first_chunk`) and a non-existent pip extra (`vllm[otel]`). Both are cheap, surgical fixes; once corrected the pack clears the fact-api bar.
- meets_bar = **false** (until the two P1 identifier fixes land).
