# LLM Observability Review

**Subject:** Production LLM chat agent — observability/monitoring setup
**Reviewer perspective:** Senior LLMOps / platform engineer
**Current state (as described):**
- Per-call dollar cost stored in DB
- Budget alert when a tenant hits 100% of monthly budget
- Average end-to-end response time tracked
- Pain point: costs feel high, can't attribute them to a team

---

## Executive Summary

Your setup has the right *intentions* (cost tracking, budget alerting, latency tracking) but is operating at the **aggregate** level when the questions you actually need answered are **dimensional** ("which team," "which model," "which feature," "which prompt version"). The single most impactful gap is that your cost data has no **attribution dimensions**, which is exactly why you can't answer "which team is driving cost." Three other gaps are serious for a production multi-tenant LLM product: (1) you alert at 100% (too late — that's a post-mortem, not an alert), (2) average latency hides the user experience and ignores streaming/token-level metrics, and (3) you have no quality/correctness signal at all, which is the dimension that most distinguishes LLM observability from ordinary app monitoring.

I'd prioritize: **(1) add attribution dimensions to cost → (2) fix budget alerting thresholds → (3) move from averages to percentiles + streaming metrics → (4) add tracing → (5) add a quality/eval signal.**

---

## 1. Cost Attribution — the headline problem

**Finding:** You store "the dollar cost of each call" but apparently as a scalar with no dimensions. That makes cost a single undifferentiated number, so the only question you can answer is "total spend" and "spend vs. a tenant budget." You cannot slice by team because the team dimension was never recorded.

**What you should record per call (minimum viable cost schema):**

| Field | Why |
|---|---|
| `tenant_id` / `org_id` | You have budgets per tenant, so this exists — keep it. |
| `team_id` / `cost_center` | The dimension you're missing. This is the answer to your literal question. |
| `user_id` | Find the power users / runaway loops. |
| `feature` / `route` / `endpoint` | Which product surface drives spend (chat vs. summarize vs. agent loop). |
| `model` + `provider` | Model mix is usually the #1 cost lever. |
| `prompt_tokens`, `completion_tokens`, `cached_tokens` | Cost should be **derived** from tokens, not just stored as a final dollar number (see below). |
| `prompt_version` / `template_id` | A prompt regression can silently 3x token usage. |
| `request_id` / `trace_id` / `parent_id` | For agent loops, one user action = many calls. You must group them. |
| `cache_hit` (bool) + cache write/read tokens | Prompt caching changes economics dramatically. |
| `is_retry` / `is_fallback` | Retries and fallbacks are invisible cost. |

**Critical nuance — don't store dollars as the source of truth:** Store **tokens** (and the model/pricing version) and *compute* dollars. Reasons: (a) vendor prices change and you'll want to re-cost history; (b) cached-input, batch, and discounted tokens are priced differently and a flat "cost" field usually gets them wrong; (c) reasoning/"thinking" tokens (o-series, extended thinking) are billed but often invisible in naive accounting. Keep a small `pricing` table versioned by date so historical re-costing is correct.

**Agent-loop cost trap:** A "chat agent" implies multi-step tool use. The expensive unit is the **session/trace**, not the call. A single user turn can fan out into 10–40 model calls (tool calls, reflection, retries). If you only look at per-call cost you will badly under-estimate the cost of an agentic interaction and you'll never see the runaway-loop pattern (the classic LLM cost incident). Roll cost up to the trace and to the user-visible turn.

**Quick win:** Even before a full schema migration, a backfill of `team_id`, `model`, and token counts onto the existing call records will immediately let you answer the question that prompted this review.

---

## 2. Budget Alerting — alerting at 100% is alerting too late

**Finding:** "Alert when a tenant hits 100% of their monthly budget." By the time you fire, the money is already spent and the tenant is either over budget or about to be cut off with no warning. This is a lagging indicator masquerading as an alert.

**Recommendations:**
- **Tiered thresholds:** alert at 50% / 75% / 90% / 100%, with different severities and audiences (internal at 75%, customer-facing at 90%).
- **Burn-rate / run-rate alerting:** the more useful signal is *trajectory*. "Tenant X is on pace to hit 180% of budget by month-end" at day 8 is far more actionable than "hit 100%" on day 28. Compute projected month-end spend from rolling daily burn.
- **Anomaly detection on rate of change:** a 10x day-over-day spike for a tenant should page *regardless* of budget headroom — it's usually a bug (infinite agent loop, prompt injection driving huge generations, a batch job pointed at prod).
- **Enforcement policy, not just alerting:** decide what happens at 100%. Hard cutoff? Soft cap + grace? Throttle to a cheaper model? Right now you have a notification but (apparently) no control loop. Decide this deliberately — silent overage is a billing dispute waiting to happen.
- **Per-team budgets, not just per-tenant:** once you have `team_id`, give teams sub-budgets so attribution and control align.
- **Watch the alerting boundary conditions:** monthly reset timing, timezone of "month," tenants created mid-month (pro-rate), and the case where your *cost computation* itself is delayed (provider usage APIs lag — don't let a 6-hour billing lag mean you find out about a runaway at 100%).

---

## 3. Latency — average is the wrong statistic, and you're missing LLM-specific metrics

**Finding:** "Average end-to-end response time" has two problems: averages hide the tail, and "end-to-end" is the wrong granularity for a chat agent that almost certainly streams.

**Fix the statistic:**
- Track **percentiles: p50, p90, p95, p99** (and max). Averages are dominated by the bulk and hide the painful tail that drives churn. A p99 of 30s with a 2s average is a real and common LLM failure mode.
- Always slice latency by **model, tenant, feature, prompt_version, streaming-vs-not**. An aggregate average across models is nearly meaningless.

**Add the LLM-specific latency metrics:**
- **TTFT (time to first token)** — for a streaming chat UI this *is* the perceived responsiveness. End-to-end time matters much less than TTFT for user experience.
- **TPOT / inter-token latency** (time per output token) and **tokens/sec** throughput.
- **Output token count** as a latency driver — long generations are slow generations; correlate latency with completion length before assuming the provider is slow.
- **Queue/scheduling time vs. provider time vs. your-own-overhead** (retrieval, tool calls, network). "End-to-end" bundles all of these; when latency regresses you need to know which segment moved. This is where tracing (next section) pays off.
- **Time-to-completion for agent traces** (multi-call), distinct from single-call latency.

**Also track latency-adjacent reliability:** error rate, timeout rate, rate-limit (429) rate, provider-fallback rate, and retry count. These are frequently the real story behind "it felt slow."

---

## 4. Tracing — you need request/trace-level visibility, not just metrics

**Finding:** Storing per-call rows in a DB is metrics/aggregates. For a chat *agent* you need **distributed tracing**: the full tree of a user interaction (prompt → retrieval → tool calls → sub-model calls → final answer), with timing, tokens, cost, inputs/outputs, and errors at each span.

**Recommendations:**
- Adopt **OpenTelemetry GenAI semantic conventions** (`gen_ai.*` attributes: system, request model, response model, input/output token counts, etc.). Standardizing on OTel means your traces, metrics, and logs share correlation IDs and you avoid vendor lock-in. This is the current industry direction for LLM telemetry.
- Capture span attributes for: model, prompt version, token counts, cost, cache hit, tool name, retry/fallback flags, and your attribution dimensions (tenant/team/user/feature).
- Consider a purpose-built LLM-observability backend (LangSmith, Langfuse, Arize Phoenix, Helicone, Braintrust, or OTel + a generic backend like Grafana Tempo/Honeycomb/Datadog). Langfuse and Phoenix are strong open-source options; Helicone is a low-friction proxy if you want fast cost/latency capture; LangSmith/Braintrust lean toward eval-integrated workflows. Pick based on whether you want self-hosted (data residency for a multi-tenant product matters) and whether you want eval built in.
- **PII / payload governance:** as soon as you log prompts and completions you are storing customer content. For a multi-tenant product this is a compliance surface. Decide on redaction/sampling/retention up front, and make payload capture sampled or opt-in per tenant. Don't quietly log everyone's chat content forever.

---

## 5. Quality / Correctness — the dimension you have zero coverage on

**Finding:** Nothing in your setup measures whether the agent's answers are *good*. Cost and latency tell you the agent is cheap and fast; they say nothing about whether it's hallucinating, refusing, regressing after a prompt change, or degrading as a provider silently updates a model. For an LLM product, quality drift is the highest-severity failure that traditional monitoring is blind to.

**Recommendations:**
- **Online/production signals (cheap, start here):**
  - Implicit feedback: thumbs up/down, regeneration rate, conversation abandonment, copy-of-answer rate, "user re-asked the same thing" rate.
  - Guardrail/refusal rate, empty-response rate, output-length anomalies.
  - JSON/tool-call **schema validity rate** if you use structured outputs or tools.
- **LLM-as-judge sampling:** run a cheap automated judge over a sample of production traces for groundedness/relevance/safety. Track the score as a metric and alert on drift.
- **Regression eval gate in CI/CD:** before any prompt or model change ships, run a fixed eval set and block on regressions. A prompt edit that "looks fine" is the most common cause of both quality drops *and* silent cost increases. (Note the cost link — eval and cost observability reinforce each other.)
- **Drift detection:** providers update models under stable names; embedding distributions and answer distributions shift. Track input/output distribution drift over time so you catch "it got worse last Tuesday" without a customer telling you.
- **Prompt registry / versioning:** version prompts as first-class artifacts and stamp `prompt_version` on every call (already in the cost schema above). This is what lets you correlate a cost/quality/latency change to a specific deploy.

---

## 6. Dashboards & Operational Hygiene (gaps to close)

- **Cost dashboard** sliced by team → model → feature → user, with month-to-date, run-rate, and top-N movers. This is the artifact that answers "which team is driving cost" on demand instead of via a one-off query.
- **Unit economics:** track **cost per user / per session / per resolved conversation**, not just gross spend. Gross spend going up is fine if it's tracking usage; cost-per-resolution going up is a regression. This reframes "costs feel high" into a measurable question.
- **Cost-optimization levers to instrument so you can prove savings:** model routing/downshifting (cheap model for easy turns), prompt-cache hit rate, max-token caps, RAG context-size control, batching where latency-tolerant, and dedup/short-circuit for repeated queries. Each should be a metric you can watch move.
- **Correlation IDs end-to-end** so a support ticket → trace → cost → prompt version is one hop, not a forensic exercise.
- **SLOs** for latency (e.g., p95 TTFT < Xs) and reliability (success rate), with error budgets, rather than just a tracked average.

---

## Prioritized Action List

1. **Add attribution dimensions** (`team_id`, `model`, `feature`, `user_id`, token counts, `prompt_version`) to the per-call record and backfill what you can. *Directly answers the question that triggered this review.* (Highest impact, low effort.)
2. **Store tokens + model + pricing-version; compute dollars** (don't persist a single opaque cost number). Enables correct re-costing and cache/batch accounting.
3. **Roll cost & latency up to trace/session level** so agent loops and runaway costs are visible.
4. **Fix budget alerting:** tiered thresholds (50/75/90/100) + burn-rate projection + day-over-day spike anomaly + a defined enforcement policy.
5. **Replace average latency with p50/p90/p95/p99 + TTFT + tokens/sec**, sliced by model/feature/tenant.
6. **Adopt OpenTelemetry GenAI conventions and add distributed tracing** (with sampled, redaction-aware payload capture and a retention policy).
7. **Introduce a quality signal:** start with implicit feedback + guardrail/refusal rates, then add LLM-as-judge sampling and a **CI eval gate** on prompt/model changes.
8. **Build the cost dashboard + unit-economics metrics** (cost per session/resolution) and define latency/reliability SLOs.

---

## One-line verdict

You've built **billing-grade aggregate accounting**; what a production multi-tenant LLM agent needs is **dimensional, trace-level, quality-aware observability**. Add attribution dimensions first — it's the cheapest fix and it answers your immediate question — then work down the list toward tracing and evaluation.
