# RAG Evaluation Rules
<!-- capability: rag_evaluation -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| RE1 | Evaluate retrieval and generation SEPARATELY — never one blended score | deterministic |
| RE2 | Faithfulness gate is domain-tiered (block < ~0.85 general / < ~0.90 regulated; 0.85–0.99 review band; 1.0 aspirational) AND Answer Relevance≥0.90 | deterministic |
| RE3 | Reference-based IR metric targets (Precision/Recall/MRR/nDCG@k) | deterministic |
| RE4 | Ragas-style LLM-as-judge metrics: Context Precision/Recall, Groundedness, Answer Relevance | semi-deterministic |
| RE7 | Eval framework selection: RAGAS (experimentation) / DeepEval (CI/CD, 50+ metrics) / TruLens (prod monitoring); faithfulness≠correctness | deterministic |
| RE5 | Domain dictates metric priority: broad → recall; narrow → precision | deterministic |
| RE6 | Continuous eval suite: 100–200 representative queries | deterministic |

---

## Rules

### RE1: Evaluate Retrieval and Generation Separately

When evaluating a RAG system, **analyze the retrieval and generation stages independently**. A single blended "RAG score" hides which stage failed — and the fix is completely different (retriever tuning vs prompt/grounding).

- **Retrieval stage** → Precision@k, Recall@k, MRR, nDCG@k (reference-based) OR Context Precision/Recall (LLM-judge)
- **Generation stage** → Faithfulness/Groundedness, Answer Relevance, optionally ROUGE/BLEU/BERTScore

**Rule**: Every RAG debug starts by splitting the failure: "Did we retrieve the right chunks (retrieval), or did the LLM ignore/distort them (generation)?" Answer with the stage-specific metric before recommending any fix.

> Source: findings.md "Rigorous Validation: Retrieval and Generation Evaluation Frameworks" [35]

**determinismLevel**: deterministic.

### RE2: Faithfulness Gate Is Domain-Tiered (Not a Strict 1.0)

When gating generation quality, treat Faithfulness as a graded risk signal, not a binary. Faithfulness = (Claims Supported by Context) / (Total Claims in Answer); Groundedness = (Grounded Sentences) / (Total Sentences). The **lower** the score, the **larger** the share of answer claims unsupported by the retrieved context — i.e., elevated hallucination/parametric-memory risk. But Faithfulness is a **semi-deterministic LLM-judge score** (RE4): run-to-run judge variance alone keeps a perfectly-grounded answer below 1.0, so a strict `== 1.0` gate would reject essentially every real deployment. 1.0 is the *aspirational* target; gate on a **domain threshold averaged over the eval suite (RE6)**.

Production deployment gate (general-purpose blueprint — calibrate per corpus):

```
Faithfulness   block (P0)  < 0.85 (general)  /  < 0.90 (regulated: finance/health/legal)
               review (P1) 0.85 – 0.99       (inspect unsupported claims; do not auto-ship)
               target      → 1.00 aspirational, averaged over the eval suite
Answer Relevance  ≥ 0.90
Groundedness      ≥ 0.95
```

These thresholds match the 2026 RAG-eval consensus (0.8 general / 0.85 customer-facing / 0.9+ regulated) — not a strict 1.0. Note: an answer can be **highly faithful yet score low on Answer Relevance** if it fails to address the question — both must pass. And Faithfulness measures *grounding, not correctness* (see RE7): a 0.95-faithful answer built on stale context is still wrong.

> Source: findings.md "Faithfulness (Groundedness)" + "Answer Relevance" + "General-Purpose High-Performance Baseline" [35, 36]; Ragas faithfulness docs + 2026 RAG-eval threshold guidance (https://docs.ragas.io/en/stable/concepts/metrics/available_metrics/faithfulness/, https://blog.premai.io/rag-evaluation-metrics-frameworks-testing-2026/, retrieved 2026-06-13)

**determinismLevel**: deterministic — the *gate policy* (domain-tiered thresholds) is a design decision; the underlying Faithfulness score is semi-deterministic (RE4), so average it over the suite.

### RE3: Reference-Based IR Metric Targets

When a human-annotated gold set exists, use reference-based IR metrics. The targets below are **General-Purpose Blueprint defaults — calibrate them to your corpus and domain** (a narrow legal corpus may demand higher Precision@k; a broad FAQ may relax it for Recall). They are starting points to gate against, not universal constants:

| Metric | Target | Failure Mode Covered |
|--------|--------|----------------------|
| **Precision@k** | ≥ 0.70 (narrow domain) | Surfacing irrelevant distracting docs |
| **Recall@k** | ≥ 0.80 at k=20 | Missing critical source context |
| **MRR** | ≥ 0.85 | Target chunk buried deep in result list |
| **nDCG@k** | ≥ 0.80 at k=10 | Relevant chunks appearing late |

Definitions: Precision@k = relevant-in-top-k / k; Recall@k = relevant-in-top-k / total-relevant; MRR = mean of 1/rank of first relevant doc; nDCG logarithmically discounts relevance by position. Hit Rate@k = % of queries with ≥1 relevant doc in top-k; MAP averages precision at each relevant rank (use when queries have multiple relevant docs and order matters).

> Source: findings.md "Classic Information Retrieval Metrics" + "Metric Validation Taxonomy" table [35, 36, 37, 38, 39]

**determinismLevel**: deterministic.

### RE4: Ragas-Style LLM-as-Judge Metrics

When no manual gold labels exist, use automated LLM-as-judge (Ragas-style) metrics. The targets below are **calibratable blueprint defaults**, not universal constants — tune to your corpus/domain and average over the eval suite (RE6) to damp judge variance:

| Metric | Target | Definition |
|--------|--------|------------|
| **Context Precision** | ≥ 0.85 | Relevant chunks / total retrieved (are relevant chunks at the top?) |
| **Context Recall** | ≥ 0.90 | Necessary chunks retrieved / total necessary |
| **Faithfulness** | ≥ 0.85 gen / ≥ 0.90 regulated (1.0 aspirational) | Claims supported / total claims (see RE2 for the tiered gate) |
| **Groundedness** | ≥ 0.95 | Grounded sentences / total sentences |
| **Answer Relevance** | ≥ 0.90 | Does the answer address the question? |
| **BERTScore** | ≥ 0.85 | Cosine of contextual token embeddings (captures paraphrase) |

**Rule**: Context Precision low → retriever drowning the generator in noise. Context Recall low → incomplete context → partial answers. Use these to localize the retrieval failure that IR metrics alone (no gold set) cannot.

> Source: findings.md "Automated LLM-as-a-Judge (Ragas-Style) Evaluators" + "Metric Validation Taxonomy" table [35, 36, 38, 39]

**determinismLevel**: semi-deterministic — LLM-judge scores vary across runs; sample multiple runs to bound variance.

### RE5: Domain Dictates Metric Priority

When choosing which metric to optimize, let the domain decide:

- **Broad-domain RAG** (FAQ, general web) → **prioritize Recall** to minimize missed context.
- **Narrow-domain RAG** (legal, medical, code) → **prioritize Precision** to minimize distracting noise.

**Rule**: Optimizing precision on a broad FAQ corpus (or recall on a narrow legal corpus) targets the wrong failure mode. Match the priority metric to the domain before tuning.

> Source: findings.md "Metric Validation Taxonomy" [35]

**determinismLevel**: deterministic.

### RE6: Continuous Evaluation Suite Size

When establishing a regression/continuous-eval suite, run Ragas-style evaluators over a **representative test set of 100–200 queries** covering the real query distribution, and gate production on the composite threshold **averaged over the suite** (Faithfulness ≥ domain floor per RE2 — ~0.85 general / ~0.90 regulated, Answer Relevance ≥ 0.90). Averaging over 100–200 queries also damps the LLM-judge variance that makes any single answer's Faithfulness noisy.

**Rule**: A handful of cherry-picked queries is not an eval suite. 100–200 representative queries is the floor for trusting a deployment gate.

> Source: findings.md "Continuous Validation" / "General-Purpose High-Performance Baseline" [35, 36]

**determinismLevel**: deterministic.

### RE7: Evaluation Framework Selection — and Why Faithfulness Is Not Correctness

When picking the eval framework (not just the metric), match the tool to the lifecycle stage instead of saying "Ragas-style" generically:

| Framework | What it gives | Best for |
|-----------|---------------|----------|
| **RAGAS** | 4 core RAG metrics (Context Precision/Recall, Faithfulness, Answer Relevance), **no ground-truth needed**, claim-level decomposition | Fast experimentation / iteration on a new pipeline |
| **DeepEval** | **50+ metrics** across RAG / agents / multi-turn / MCP / safety; native CI/CD via **Pytest** integration | CI/CD regression gates (run metrics as unit tests) |
| **TruLens** | Feedback functions + **OpenTelemetry tracing** | Production monitoring of a live deployment |

**Rule**: Use RAGAS when iterating (no labels required), DeepEval when wiring an eval into CI/CD (Pytest-native, broadest metric set), TruLens when monitoring production (OTel traces). Don't reach for a 50-metric framework to A/B two chunkers, and don't ship a production system monitored only by an experimentation-stage tool.

⚠️ **Critical caveat — Faithfulness is NOT a correctness gate**: a RAG system can score **0.95 Faithfulness and still give a wrong answer** when the *retrieved context itself is stale or incorrect. Faithfulness only measures whether the answer is grounded in the retrieved context — **no current framework can distinguish factually-wrong context from correct context.** So a high Faithfulness score with bad source data produces a confidently-grounded wrong answer. Pair Faithfulness with retrieval-quality metrics (RE3) AND source-freshness checks; never treat Faithfulness alone as proof of correctness.

> Source: findings.md "Automated LLM-as-a-Judge (Ragas-Style) Evaluators" [35]; AIMultiple, "RAG Evaluation Tools," https://research.aimultiple.com/rag-evaluation-tools/ (retrieved 2026-06-13)

**determinismLevel**: deterministic — framework selection is a design decision; the underlying LLM-judge scores remain semi-deterministic.

---

## Anti-Patterns

- **One blended RAG score**: Hides whether retrieval or generation failed. Always split (RE1).
- **Treating Faithfulness as pass/fail at 1.0**: A strict ==1.0 gate rejects every real deployment (judge variance keeps grounded answers <1.0). Gate on the domain floor (~0.85 general / ~0.90 regulated) averaged over the suite (RE2); a low score is *elevated unsupported-claim risk*, inspect it — don't equate every <1.0 with "hallucination."
- **ROUGE/BLEU as the primary RAG metric**: They measure n-gram overlap, miss semantic paraphrase, and say nothing about grounding. Use BERTScore for semantics and Faithfulness for grounding.
- **Wrong domain priority**: Recall-first on narrow legal corpora floods the generator with noise; precision-first on broad FAQ misses context. Match priority to domain.
- **Tiny eval set**: < 100 queries can't support a trustworthy production gate.
- **Treating Faithfulness as a correctness gate**: A 0.95-Faithfulness answer can still be wrong if the retrieved context is stale/incorrect — no framework distinguishes factually-wrong context from correct context. Pair Faithfulness with retrieval-quality (RE3) and source-freshness checks.
- **Wrong framework for the stage**: RAGAS for experimentation (no labels), DeepEval for CI/CD gates (Pytest, 50+ metrics), TruLens for production monitoring (OTel). Using an experimentation-stage tool to monitor production leaves drift undetected.
