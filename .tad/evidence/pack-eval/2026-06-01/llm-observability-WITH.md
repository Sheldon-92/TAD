# Observability Review: LLM Chat Agent — cost attribution, budget governance, latency

Your setup has three load-bearing flaws, and all three map to specific rules in the LLM observability ruleset. The headline symptom you raised — "costs feel high but we can't tell which team is driving them" — is a direct consequence of two of them (stored pre-computed cost + global-by-API-key accounting). Here is the prioritized review.

---

## P0 — Blocking (must fix before you trust the data)

### P0-1 — You store a single dollar cost per call instead of raw token counters
**Rule CA3 (cost-attribution) + cross-cutting "Emit Raw Token Counters, Not Pre-Calculated Costs".**

You wrote: *"we store the dollar cost of each call in our DB."* This is the single most damaging decision in the setup. A pre-multiplied dollar figure becomes **wrong the instant a provider changes list prices, and is un-reconcilable for every historical trace** — you can never re-cost the past. Your "costs feel high" investigation is already crippled by this: you can't recompute, model-substitute, or break down what you already spent.

→ **Fix:** Store **raw token counters per call** — and store them under the standard OTel keys, not invented fields (Rule OT3):
- `gen_ai.usage.input_tokens`
- `gen_ai.usage.output_tokens`
- `gen_ai.usage.cache_read.input_tokens`
- `gen_ai.usage.cache_creation.input_tokens`
- `gen_ai.usage.reasoning.output_tokens`

Then compute cost **downstream at query time** by joining those counters against a **versioned pricing matrix**. Cost is derived, never stored. When a provider reprices, you update one matrix row and every historical and future trace re-costs correctly.

### P0-2 — Spend is aggregated globally (by API key), so no per-tenant/per-team attribution exists
**Rule CA1 (Four-Layer Token Accounting) + CA3 metadata propagation. Anti-pattern: "Global-by-API-key costing".**

"We can't tell which team is driving them" is the textbook symptom of global-by-API-key aggregation — the documented visibility gap. You have no attribution dimension on the spend.

→ **Fix (two parts):**
1. **Inject and propagate metadata tags down the whole execution tree.** Attach `tenant_id` / `team_id` / `user_id` / `task_id` at the **gateway**, e.g. a TrueFoundry-style `X-TFY-METADATA` JSON header on the initial call, so the tag propagates through automated tool calls and model fallbacks. Do **not** tag per-call in app code — per-call tags drop on fallback (anti-pattern: "Per-call tag injection"). This is what finally lets you group spend by team.
2. **Split each call's tokens across the 4 layers** — Prompt / Tool / Memory / Response (Rule CA1). "Total tokens" hides *where* the spend comes from. In an agentic chat product the **Tool Layer is a frequent silent bloat source** because JSON tool schemas are re-injected on every agent step, and the **Memory Layer scales cumulatively** with conversation history. Tag spans into these layers (e.g. a `digitalapplied.*` custom namespace) so you can see whether your high cost is schema re-injection or runaway history, not just a big undifferentiated number.

---

## P1 — Required (fix before trusting the telemetry)

### P1-1 — Your latency SLO is end-to-end response time, which is the wrong metric for a streaming chat agent
**Rule LP1 (latency-profiling). Anti-pattern: "End-to-end SLOs for streaming".**

You track "average end-to-end response time." For a streaming chat agent, end-to-end latency is a poor proxy for what the user actually feels. The canonical illustration: **a 10s end-to-end response with 500ms TTFT feels instantaneous, while a 5s response with 4s TTFT feels frozen.** You are optimizing the number that doesn't govern perceived responsiveness.

→ **Fix:** Re-base your SLO on:
- **TTFT (Time to First Token)** — perceived responsiveness. Capture `gen_ai.response.time_to_first_chunk` (and server-side `gen_ai.server.time_to_first_token`).
- **ITL (Inter-Token Latency)** — streaming smoothness.

Also: stop using **average**. Latency must be a **Histogram** instrument, not a gauge/average, so you can report **p50 / p95 / p99** (Rule OT5). An average hides the tail that actually generates complaints.

### P1-2 — Hard 100% budget cutoff causes user-facing outages
**Rule CA4 (Budget Enforcement Thresholds 80 / 90 / 100). Anti-pattern: "Binary 100% cutoff".**

You "alert when a tenant hits 100% of their monthly budget." Two problems: (a) you only *alert* at 100% — too late to do anything graceful, and (b) a single binary 100% threshold means tenants slam into a wall and you take a user-facing outage at the worst moment.

→ **Fix: make enforcement tiered, using atomic Redis counters** (safe under concurrent spend):
- **80%** of allocation → soft alert (warn, do not block).
- **>90%** under heavy utilization → **budget-aware routing**: redirect to cheaper models (e.g. Opus → Sonnet) to degrade gracefully instead of failing.
- **100%** → gateway **blocks** and returns **HTTP 429**.

This converts a cliff into a graceful degradation chain.

---

## P2 — Advisory (improves observability quality)

### P2-1 — Add a runaway kill switch (you have none)
**Rule CA6.** A monthly-budget alert will not catch a recursive agent loop burning the month's budget in minutes. Compute a rolling spend **z-score** over a **7-day window**: `z = (x − μ)/σ`, where `x` = rolling 10-minute spend. If **z > 4**, *pause* the tenant's execution loop and page on-call — pause first, don't merely alert (a z>4 spend spike is almost always a recursive loop).

### P2-2 — Set margin-protection caps
**Rule CA5.** Bound worst-case spend before the kill switch fires: **Daily Tenant Cap ∈ [1.5, 3.0]× contracted limit**, **Tenant Rate Limit ∈ [2.0, 3.0]× expected peak**. These are multiples of a contracted baseline, not absolute magic numbers.

### P2-3 — Track reasoning + cache tokens specifically
**Rules CA2 / OT3.** Response tokens are priced **4–5× input tokens**, and hidden reasoning/chain-of-thought tokens count toward the Response Layer. When you optimize "high cost," cut **output/reasoning** tokens first — a 100-token output reduction beats a 400-token prompt reduction at a 4–5× multiplier. Track `gen_ai.usage.reasoning.output_tokens` separately so reasoning spend is visible, and `cache_read`/`cache_creation` separately so prompt-cache ROI is measurable.

### P2-4 — Distinguish a gateway from a tracer
If your per-call cost record comes from a proxy/gateway, note (anti-skip): a proxy only intercepts external API calls and **cannot reconstruct nested in-app agent steps** unless context headers are explicitly propagated. Use an SDK/OTel tracer for the span tree; use the gateway for cost-attribution metadata and budget enforcement.

---

## Telemetry Conformance Audit

| Check | Status | Action |
|-------|--------|--------|
| `OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental` set? | ❓ Almost certainly NO | Set it (Rule OT1) — otherwise you silently emit partial conventions and miss cache/reasoning/TTFT attributes. |
| Raw counters stored, not pre-computed cost? | ❌ FAIL | You store dollar cost. Switch to raw `gen_ai.usage.*` counters + versioned pricing matrix (CA3). |
| Required span attrs `gen_ai.operation.name` + `gen_ai.provider.name` present? | ❓ Verify | Required on every span (OT2). Also record `gen_ai.response.model` separately from request model — fallback/routing means the executed model differs. |
| Attribution tags (`tenant_id`/`team_id`) propagated at gateway? | ❌ FAIL | No per-team breakdown today (CA1/CA3). |
| TTFT captured (`gen_ai.response.time_to_first_chunk`)? | ❌ FAIL | Only end-to-end latency tracked (LP1). |
| Latency as Histogram (p95/p99), not average? | ❌ FAIL | You track averages (OT5). |
| Budget enforcement tiered 80/90/100? | ❌ FAIL | Binary 100% alert only (CA4). |
| `gen_ai.input/output.messages` capture gated on PII policy? | ⚠️ Decide | These are Opt-In; enabling writes user prompts/outputs into traces — gate behind a compliance policy (OT4). |

---

## Platform / Tool Recommendation

- **Cost attribution + budget governance gateway:** a metadata-propagating gateway (TrueFoundry-style `X-TFY-METADATA`) that injects `tenant_id`/`team_id`, computes cost at span close against a **versioned pricing table**, and rolls raw minute-level counters into **TimescaleDB or ClickHouse**. Enforce budgets with **atomic Redis counters** at the 80/90/100 thresholds. This directly answers "which team is driving cost."
- **Tracing / span tree:** **Langfuse** (MIT, self-hostable, framework-agnostic, OTel-compatible) for the in-app agent span tree, since a proxy alone can't reconstruct nested agent steps. **Arize Phoenix** if you later need embedding/RAG validation rigor. **Helicone** for fast (~5 min) external-API interception/caching, but only as a complement — not as your tracer.
- **Standards layer:** emit OTel GenAI semconv (`OTEL_SEMCONV_STABILITY_OPT_IN=gen_ai_latest_experimental`) so the above stays vendor-neutral.

---

## Bottom line on "which team is driving cost"

You cannot answer it today for two structural reasons: (1) you store a **pre-computed dollar cost** instead of raw counters (CA3), so you can't re-slice or re-cost; and (2) you aggregate **globally by API key** with no propagated `tenant_id`/`team_id` tags (CA1/CA3). Fix those two and the question becomes a trivial group-by. The latency and budget findings are independent but equally concrete: measure **TTFT/ITL at p95/p99**, not average end-to-end (LP1/OT5), and replace the **binary 100% alert** with the **80/90/100 tiered enforcement** chain plus a **z>4 kill switch** (CA4/CA6).
