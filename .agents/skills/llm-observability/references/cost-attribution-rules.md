# Cost Attribution & Budget Governance Rules
<!-- capability: cost_attribution -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| CA1 | Account tokens across 4 layers: prompt, tool, memory, response | deterministic |
| CA2 | Output tokens are materially pricier than input — Response Layer dominates spend (compute the exact multiplier per provider/model) | deterministic |
| CA3 | Propagate metadata tags (X-TFY-METADATA) down the whole execution tree | deterministic |
| CA4 | Budget enforcement: soft alert at 80%, HTTP 429 block at 100%, route-down at >90% | deterministic |
| CA5 | Margin caps: daily ∈ [1.5,3.0]× contracted; rate limit ∈ [2.0,3.0]× expected peak | semi-deterministic |
| CA6 | Runaway kill switch: rolling spend z-score > 4 over a 7-day window | non-deterministic |
| CA7 | AWS Bedrock: cache STS AssumeRole with 1-hour TTL (shares the 600 RPS/account/Region STS quota) | deterministic |

---

## Rules

### CA1: Four-Layer Token Accounting

Standard provider interfaces aggregate cost globally by API key, creating a visibility gap. To compute accurate unit economics, categorize token consumption across **four distinct layers**:

| Layer | Contains | Cost Behavior |
|-------|----------|---------------|
| **Prompt Layer** | System instructions, user inputs, hardcoded/static examples | Baseline cost; highly receptive to semantic prompt caching |
| **Tool Layer** | Injected JSON tool schemas + raw execution payloads returned by functions | Schemas re-injected every agent step → frequent source of silent token bloat |
| **Memory Layer** | RAG context, long-term memory records, conversational history buffer | Scales cumulatively as session length increases |
| **Response Layer** | Completion output tokens INCLUDING reasoning / extended-thinking tokens when reported by the provider | Most expensive component (see CA2) |

**Rule**: Tracking only "total tokens" hides where spend originates. Tag spans into these four layers (e.g., custom namespace `digitalapplied.*`) so you can detect tool-schema bloat and target caching at the Prompt Layer.

> Source: findings.md "Token Accounting at Four Layers... telemetry spans should use a unified custom namespace, such as digitalapplied.*" [10]

**determinismLevel**: deterministic — layer classification is a design decision.

### CA2: Output Tokens Are Materially Pricier Than Input — Compute the Multiplier

Across providers, **output tokens are priced materially higher than input tokens** (the multiplier varies by provider/model/version — e.g. roughly 4-5x on some frontier models, up to ~8x on others such as the OpenAI GPT-5 family), making the Response Layer (CA1) the most expensive component of system operations — and reasoning / extended-thinking tokens count toward it where the provider reports them.

**Rule**: When optimizing cost, prioritize reducing output/reasoning tokens before input tokens, and compute the exact output:input multiplier from the provider/model/version pricing table rather than assuming a fixed ratio. Because output is several times more expensive than input on most models, a small output-token reduction often saves more than a much larger prompt reduction. Track `gen_ai.usage.reasoning.output_tokens` separately so reasoning spend is visible.

> Source: findings.md "response tokens are priced [several times] higher than input tokens, making the Response Layer the most expensive component" [10]; exact multiplier is provider/model/version-specific (verify against the live pricing table — e.g. OpenAI GPT-5 family lists output at up to ~8x input).

**determinismLevel**: deterministic — output > input is a documented pricing relationship; the exact multiplier is provider/model-specific.

### CA3: Emit Raw Token Counters + Propagate Metadata Tags

**Emit raw token counters, NOT pre-calculated costs.** Because providers frequently change list prices, storing raw counters lets downstream billing engines dynamically compute exact historical costs by querying a versioned pricing matrix. A pre-multiplied cost field becomes wrong the moment list prices change.

For attribution, inject custom metadata tags on the initial call and propagate them down the entire execution tree so automated tool calls and model fallbacks inherit the original metadata:

- **TrueFoundry Gateway**: application injects an `X-TFY-METADATA` JSON header on the initial call; the gateway propagates tags (e.g., `tenant_id`, `user_id`, `task_id`) down the whole tree. Cost is computed at span close against a versioned pricing table using the exact usage tokens in the final response chunk. Raw traces → minute-level counters rolled up into TimescaleDB or ClickHouse.

**Rule**: Store raw counters and a versioned pricing matrix; never store a single pre-computed cost. Propagate tags at the gateway, not per-call in app code, so fallbacks inherit them.

> Source: findings.md "It is critical to emit raw token counters rather than pre-calculated costs... TrueFoundry... X-TFY-METADATA JSON header... propagates these tags down the entire execution tree" [10, 11]

**determinismLevel**: deterministic — an architectural rule.

### CA4: Budget Enforcement Thresholds (80% / 90% / 100%)

When implementing a cost-attribution gateway, enforce concurrent spending with **atomic Redis counters** at three thresholds:

| Threshold | Action |
|-----------|--------|
| Crosses **80%** of allocation | Trigger soft alert (warn, do not block) |
| Under heavy utilization **>90%** | Budget-aware routing: redirect queries to cheaper models (e.g., Claude Opus → Sonnet) to gracefully degrade rather than outage |
| Crosses **100%** | Gateway BLOCKS further execution and returns **HTTP 429** |

**Rule**: Budget enforcement must be tiered, not binary. A single hard cutoff at 100% causes user-facing outages; the 80% soft alert + 90% route-down chain degrades gracefully. Track budgets with atomic Redis counters to handle concurrent spend safely.

> Source: findings.md "When a tenant crosses 80% of their allocation, soft alerts are triggered; crossing 100% causes the gateway to block further execution and return an HTTP 429. Under heavy utilization (>90%), budget-aware routing can automatically redirect queries to cheaper models" [11]

**determinismLevel**: deterministic — fixed threshold contract.

### CA5: Margin-Protection Caps

To guard against infinite loops and runaway agent sessions, set multi-layered caps relative to the tenant's contracted/expected usage:

- **Daily Tenant Cap** ∈ [1.5, 3.0] × Contracted Limit
- **Tenant Rate Limit** ∈ [2.0, 3.0] × Expected Peak

**Rule**: Caps are multiples of a contracted baseline, not absolute magic numbers. Pick within the stated ranges based on burst tolerance. These bound worst-case spend before the z-score kill switch (CA6) fires.

> Source: findings.md "Daily Tenant Cap ∈ [1.5, 3.0] × Contracted Limit ... Tenant Rate Limit ∈ [2.0, 3.0] × Expected Peak" [10]

**determinismLevel**: semi-deterministic — a tunable range, not a single value.

### CA6: Runaway Kill Switch via Spend Z-Score

To stop runaway recursive loops from causing catastrophic financial loss, compute a rolling spend z-score over a **7-day historical window**:

```
z = (x − μ) / σ
```
where `x` = rolling **10-minute** spend, `μ` = historical 7-day mean, `σ` = standard deviation.

**Rule**: If **z > 4**, an automated kill switch pauses the tenant's execution loop AND pages the on-call engineer. Do not alert-only — a z>4 spend anomaly is almost always a recursive loop, so pause first.

> Source: findings.md "z = (x − μ)/σ > 4 ... If z > 4, an automated kill switch pauses the tenant's execution loop and pages the on-call engineer" [10]

**determinismLevel**: non-deterministic — depends on live spend distribution.

### CA7: AWS Bedrock — Cache STS AssumeRole (1-Hour TTL)

For AWS Bedrock granular cost attribution, calls via developer API keys map to IAM identities via `line_item_iam_principal` and cost allocation tags, integrating with Cost Explorer and Cost and Usage Reports (CUR 2.0).

**Rule**: Calling STS `AssumeRole` per request introduces latency and consumes the shared STS request quota — **600 requests/second per account per Region by default, shared across STS APIs** (`AssumeRole`, `GetCallerIdentity`, etc.); check Service Quotas for your account/Region. Implement an in-memory session cache with a **1-hour TTL** so STS is queried only once per user per hour. Per-request AssumeRole will throttle at scale.

> Source: AWS IAM/STS quotas documentation — "600 requests per second, per account, per Region" shared across STS operations (findings.md [13] cited 500/sec; corrected to the AWS-documented 600 RPS default).

**determinismLevel**: deterministic — a fixed mitigation pattern.

---

## Anti-Patterns

- **Global-by-API-key costing**: Aggregating spend by API key hides which team/feature/customer drives consumption.
- **Storing pre-computed costs**: Breaks the moment provider list prices change; store raw counters + versioned pricing matrix instead.
- **Per-call tag injection**: Tags must propagate at the gateway so fallbacks/tool calls inherit them — per-call app-code tagging drops on fallback.
- **Binary 100% cutoff**: Causes user-facing outages; use the 80%/90%/100% tiered chain.
- **Per-request STS AssumeRole on Bedrock**: Consumes the shared 600 RPS/account/Region STS quota and throttles at scale; cache with 1-hour TTL.
