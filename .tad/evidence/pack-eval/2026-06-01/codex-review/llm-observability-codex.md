[P0] “`gen_ai.client.token.usage` | Counter | tokens”
Why wrong: OpenTelemetry GenAI defines `gen_ai.client.token.usage` as a Histogram, not a Counter. The pack later says “Token usage is a Counter,” which is also wrong.
Fix: Change it to `Histogram` and remove the advice that gauges/counters are the only wrong choices. The correct warning is: use the OTel-defined histogram with `gen_ai.token.type`.

[P0] “`URI Target = "prompts:/qa-assistant/production"`” and “Application code should target `prompts:/<name>/production`”
Why wrong: MLflow prompt aliases use `@alias`, e.g. `prompts:/my_prompt@production`. Slash form is for versions, e.g. `prompts:/my_prompt/1`. This URI would mislead users into writing broken or wrong registry lookups.
Fix: Replace with `prompts:/qa-assistant@production` and `prompts:/<name>@production`.

[P0] “STS `AssumeRole` ... rate limits (typically **500 calls/second**)”
Why wrong: AWS documents the default STS request quota as 600 requests per second per account per Region, shared across STS operations including `AssumeRole`.
Fix: Replace `500 calls/second` with “600 RPS per account per Region by default, shared across STS APIs; check Service Quotas for the account/Region.”

[P0] “LangSmith | SDK-based framework integration | Closed source, cloud-only”
Why wrong: Current LangSmith docs include self-hosted and hybrid deployment modes on AWS. The standard/Plus plan caveat may still matter, but “cloud-only” is false.
Fix: Say “Closed source SaaS by default; self-hosted/hybrid available on enterprise/on-prem deployments.”

[P0] “Across premium models, **response tokens are priced four to five times higher than input tokens**”
Why wrong: This is not generally true. Current OpenAI GPT-5 family pricing has output at 8x input for several models. Treating 4-5x as deterministic will produce bad cost-optimization math.
Fix: Say “output tokens are often materially more expensive than input tokens; compute the multiplier from the provider/model/version pricing table.”

[P1] “a stored pre-computed cost becomes wrong the instant prices change and cannot be corrected for historical traces”
Why wrong: Overbroad. A stored cost can remain historically correct if it records the applied pricing version, effective date, currency, discounts, and billing tier. The real anti-pattern is storing only cost with no usage counters/pricing provenance.
Fix: Require raw counters plus pricing-version metadata; optionally store computed cost as a derived/audit field.

[P1] “Total tokens hides where spend originates. Split into the 4 layers (prompt/tool/memory/response)”
Why wrong: The four-layer taxonomy is useful but not a standard provider or OTel taxonomy. The pack labels it deterministic and gives a vendor-looking namespace, which risks agents treating it as portable schema.
Fix: Mark it as a local attribution model. Require mapping to standard `gen_ai.usage.*` plus custom attributes such as `llm.cost.layer`, not `digitalapplied.*`.

[P1] “Daily Tenant Cap ∈ [1.5, 3.0] × Contracted Limit” and “Tenant Rate Limit ∈ [2.0, 3.0] × Expected Peak”
Why wrong: Unsupported specific ranges. No caveat for contractual hard caps, prepaid plans, regulated usage, fraud posture, or customer-specific burst agreements.
Fix: Present as example starting ranges only, with policy inputs: contract terms, margin, abuse risk, SLA, historical burstiness, and manual override.

[P1] “If **z > 4**, an automated kill switch pauses the tenant's execution loop ... a z>4 spend anomaly is almost always a recursive loop”
Why wrong: Unsupported and dangerous. Spend distributions are often non-normal, seasonal, campaign-driven, and sparse; z-score can false-positive legitimate launches or miss heavy-tailed anomalies.
Fix: Use z-score as one signal. Require minimum baseline volume, robust statistics or EWMA/MAD, absolute spend thresholds, allowlists, and staged actions before hard pause unless blast-radius is severe.

[P1] “PCA ... retaining **95% of variance** (≈ two standard deviations)”
Why wrong: Explained variance retained by PCA is not “approximately two standard deviations.” That conflates dimensional variance retention with normal-distribution mass.
Fix: Delete “≈ two standard deviations.” Say “retain a chosen explained-variance target, commonly 90-99%, calibrated on validation drift cases.”

[P1] “Use Wasserstein distance on PCA-reduced (95% variance) vectors”
Why wrong: Missing critical caveat: multivariate Wasserstein in even reduced dimensions is sample-hungry and implementation-sensitive; many practical systems use sliced Wasserstein, MMD, energy distance, nearest-neighbor density, or cluster-distance monitoring.
Fix: Say “consider sliced/regularized Wasserstein or alternative multivariate tests; fit PCA only on the reference window; calibrate thresholds with backtests.”

[P1] “SORE ... achieving extraction precision comparable to LLM judges at a fraction of the computational cost”
Why wrong: This is an unsupported broad benchmark claim. “Comparable” depends on dataset, language, domain, embedding model, ANN index, and judge rubric.
Fix: Reframe as “can reduce judge volume as a pre-filter; validate precision/recall against a labeled sample before replacing judge calls.”

[P2] “Response Layer | Completion output tokens INCLUDING hidden reasoning / chain-of-thought”
Why wrong: “chain-of-thought” is the wrong operational wording. Providers may expose “reasoning tokens” or “extended thinking” usage counters, but not hidden chain-of-thought content.
Fix: Use “reasoning tokens / extended-thinking tokens when reported by the provider.”

[P2] “query the @production alias, not a pinned version number”
Why wrong: Too absolute. Production services often pin versions for reproducible rollbacks, regulated changes, or deterministic experiments; aliases are useful for rollout indirection but not always correct.
Fix: Say “use aliases for dynamic rollout paths; pin immutable versions for audited workflows, experiments, or emergency rollback verification.”

VERDICT: FIX-FIRST
