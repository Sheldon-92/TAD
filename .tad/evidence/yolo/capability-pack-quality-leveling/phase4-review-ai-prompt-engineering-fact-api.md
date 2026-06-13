# Phase 4 Adversarial Review — ai-prompt-engineering (fact-api lens)

- **Lens**: fact-api (factual / API correctness; version-sensitive claims verified against current primary docs)
- **Reviewer**: Claude Opus 4.8 subagent
- **Date**: 2026-06-13
- **meets_bar**: true (clears the fact-api bar — no P0 API-breaking errors in load-bearing guidance; findings are P2 string-level / one self-contradiction + one genuine wrong class-name alias)

## Verdict

The pack's Anthropic/Claude API surface is **accurate and current** — it was clearly re-grounded
against the in-context `claude-api` skill (`shared/model-migration.md` + `shared/models.md`) on
2026-06-13, and every version-sensitive Claude claim I checked matches the authoritative source.
The non-Anthropic tool claims (promptfoo OWASP plugins, DSPy GEPA, DeepEval metrics) are also
substantively correct. One genuine wrong API name (DeepEval `DagMetric` alias), one self-contradiction
in the starter YAML (`temperature` on a 4.6-family model that would 400), and one stale-but-in-context
cross-provider temperature note. None break the load-bearing guidance; F2 is the most material.

## Findings

### F1 (P2, genuine API-name error) — selection-matrix introduces a wrong DeepEval class alias `DagMetric`
`tools/selection-matrix.md` line 216 labels the metric `DAGMetric` (correct) in the table cell, but the
prose at L216 and L219 introduces the alias **`DAG (DagMetric)`** / "`DAG` (DagMetric)". The real
DeepEval class is `DAGMetric` (all-caps DAG): `from deepeval.metrics import DAGMetric`; the graph object
is `DeepAcyclicGraph` from `deepeval.metrics.dag`. `DagMetric` is not a class that exists in DeepEval.
Verified against deepeval.com/docs/metrics-dag. Fix: replace both `DagMetric` mentions with `DAGMetric`.

### F2 (P2, self-contradiction → would 400) — promptfoo-starter sets `temperature: 0.0` on `claude-sonnet-4-6`
`tools/promptfoo-starter.yaml` L19–22 pins `anthropic:messages:claude-sonnet-4-6` then sets
`config: { temperature: 0.0 }`. Per the authoritative `claude-api` skill, `temperature`/`top_p`/`top_k`
are removed on the Fable 5 / Opus 4.7/4.8 family AND on Sonnet 4.6 — sending any returns HTTP 400
(`shared/error-codes.md`). The pack's own `references/claude.md` "Old patterns" table lists `temperature`
on 4.7+ as a 400. So the starter template a user copies verbatim would 400 on the pinned model. Most
material finding: SKILL teaches "remove temperature" yet ships a template that includes it. Fix: delete
the `temperature: 0.0` line (steer determinism via `effort: low` + prompt per claude.md Rule 1). The
comment "Deterministic for testing; adjust for creative tasks" reflects the same obsolete mental model.

### F3 (P3, cross-provider, in-context) — failure-catalog FM-6 cites `temperature` ranges as a config lever
`references/failure-catalog.md` FM-6 (L258, L282) frames "temperature=1.0 too high" and "creative
0.7–1.0; precise 0.0–0.3" as a config check. Correct as a general LLM principle, and FM-3/FM-6 are
deliberately provider-neutral (use `gpt-4o`), so not wrong in context — but stale for a Claude reader.
Optional: add "(on current Claude, steer via effort + prompting — temperature is removed)".

### F4 (PASS, notable) — All Claude model IDs, thinking API, effort, caching minimums are CURRENT
`references/claude.md` table + Rules 1–8 match the authoritative skill exactly: `claude-opus-4-8`
(default 1M/128K), `budget_tokens` REMOVED→400 on 4.7+, adaptive thinking + `output_config.effort`
(low|medium|high|xhigh|max), prefill removed→400 on 4.6/4.7/4.8/Fable 5, structured outputs via
`output_config.format`, min cacheable prefix 4096 (Opus/Haiku) vs 2048 (Sonnet 4.6/Fable 5),
`mid-conversation-system-2026-04-07` beta, Fable 5 always-on thinking + `{type:"disabled"}`→400 + ~30%
tokenizer + `refusal` + 30-day retention, server-side `fallbacks` (`server-side-fallback-2026-06-01`).
The file header self-documents the 2026-06-13 correction of the prior wrong `budget_tokens` guidance.

### F5 (PASS) — `count_tokens` over tiktoken guidance correct
`phase1-write.md` L44 + SKILL L103/L117 match `shared/token-counting.md` (tiktoken undercounts ~15–20%;
use `client.messages.count_tokens(model=...)`).

### F6 (PASS) — DSPy GEPA API correct
`dspy.GEPA(metric=, max_metric_calls=, reflection_lm=)`, `reflection_lm` REQUIRED, `.compile(program,
trainset=)`, ~3 examples. `reflection_lm`/`max_metric_calls` confirmed real GEPA args. `pip install -U
dspy` (renamed from `dspy-ai`) correct. Headline numbers carry source URLs + retrieval date (YOLO-audit
remediation applied) — auditable, not bare.

### F7 (PASS) — promptfoo OWASP red-team syntax correct
`owasp:llm` preset, `owasp:llm:01`..`:10`, strategies prompt-injection/jailbreak/crescendo, LLM07
System Prompt Leakage new in 2025 — all confirmed (promptfoo.dev OWASP docs, genai.owasp.org LLM07:2025).
CLI `npx promptfoo@latest init` / `eval --no-cache` / `redteam generate|run` valid.

### F8 (PASS) — DeepEval metric names (besides F1 alias) correct
`FaithfulnessMetric`, `HallucinationMetric`, `AnswerRelevancyMetric`, `ContextualRecallMetric`, `GEval`,
`ConversationalTestCase`, `LLMTestCase`, `assert_test` — all real; threshold directions correct
(Faithfulness ≥0.8, Hallucination ≤0.2). `pip install deepeval` correct.

## fact_checks

1. CLAIM: budget_tokens removed → 400 on Opus 4.7/4.8/Fable 5; adaptive thinking + output_config.effort is current. VERDICT: CORRECT (in-context claude-api skill, 2026-06-13).
2. CLAIM: effort low|medium|high|xhigh|max; xhigh added 4.7; max Opus-tier only; default high. VERDICT: CORRECT (claude-api §Thinking & Effort).
3. CLAIM: model IDs opus-4-8 (1M/128K default), sonnet-4-6 (1M/64K), haiku-4-5 (200K/64K), fable-5 (1M/128K). VERDICT: CORRECT (shared/models.md).
4. CLAIM: prefill removed → 400 on 4.6/4.7/4.8/Fable 5; use output_config.format. VERDICT: CORRECT (claude-api).
5. CLAIM: min cacheable prefix 4096 (Opus/Haiku 4.5) vs 2048 (Sonnet 4.6/Fable 5). VERDICT: CORRECT (shared/prompt-caching.md).
6. CLAIM: cache reads ~0.1x; writes 1.25x (5m)/2x (1h); max 4 breakpoints. VERDICT: CORRECT (shared/prompt-caching.md).
7. CLAIM: Fable 5 always-on thinking, {type:disabled}→400, ~30% tokenizer, refusal HTTP 200, 30-day retention. VERDICT: CORRECT (claude-api + models.md).
8. CLAIM: server-side fallback beta `server-side-fallback-2026-06-01`, target claude-opus-4-8. VERDICT: CORRECT (migration guide refusal section).
9. CLAIM: temperature: 0.0 valid for claude-sonnet-4-6 in promptfoo config. VERDICT: INCORRECT (F2) — temperature removed on Sonnet 4.6 + 4.7/4.8/Fable; sending it → HTTP 400 (shared/error-codes.md). Self-contradicts pack's own claude.md "Old patterns".
10. CLAIM: DeepEval DAG metric class `DagMetric` (selection-matrix prose). VERDICT: INCORRECT (F1) — real class `DAGMetric` (from deepeval.metrics import DAGMetric; graph DeepAcyclicGraph from deepeval.metrics.dag). Source: https://deepeval.com/docs/metrics-dag (2026-06-13).
11. CLAIM: DSPy GEPA reflection_lm REQUIRED + max_metric_calls; pip install -U dspy (renamed from dspy-ai). VERDICT: CORRECT. Source: https://gepa-ai.github.io/gepa/, https://dspy.ai/api/optimizers/GEPA/.
12. CLAIM: promptfoo owasp:llm + owasp:llm:01..:10; LLM07 System Prompt Leakage new 2025; strategies prompt-injection/jailbreak/crescendo. VERDICT: CORRECT. Source: https://www.promptfoo.dev/docs/red-team/owasp-llm-top-10/, https://genai.owasp.org/llmrisk/ (LLM07:2025).
13. CLAIM: tiktoken undercounts Claude ~15–20%; use count_tokens model-specific. VERDICT: CORRECT (shared/token-counting.md).
14. CLAIM: DeepEval FaithfulnessMetric/HallucinationMetric/AnswerRelevancyMetric/GEval/ConversationalTestCase real, thresholds directionally correct. VERDICT: CORRECT (deepeval.com docs).
15. CLAIM (FM-6, cross-provider): temperature creative 0.7–1.0 / precise 0.0–0.3 as a config lever. VERDICT: CORRECT-AS-GENERAL-PRINCIPLE but stale for current Claude; acceptable because FM-6 is provider-neutral (gpt-4o). (F3)
