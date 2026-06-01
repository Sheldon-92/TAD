# RAG Evaluation Rules
<!-- capability: rag_evaluation -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| RE1 | Evaluate retrieval and generation SEPARATELY — never one blended score | deterministic |
| RE2 | Faithfulness < 1.0 = hallucination; gate prod on Faithfulness=1.0 AND Answer Relevance≥0.90 | deterministic |
| RE3 | Reference-based IR metric targets (Precision/Recall/MRR/nDCG@k) | deterministic |
| RE4 | Ragas-style LLM-as-judge metrics: Context Precision/Recall, Groundedness, Answer Relevance | semi-deterministic |
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

### RE2: Faithfulness Below 1.0 Means Hallucination

When gating generation quality, treat Faithfulness as binary-critical. Faithfulness = (Claims Supported by Context) / (Total Claims in Answer); Groundedness = (Grounded Sentences) / (Total Sentences). **Any score below 1.0 indicates the model is fabricating or relying on parametric memory** rather than the retrieved context.

Production deployment gate (general-purpose blueprint):

```
Faithfulness      = 1.00   (critical — block on any value below)
Answer Relevance  ≥ 0.90
Groundedness      ≥ 0.95
```

Note: an answer can be **100% faithful yet score zero on Answer Relevance** if it fails to address the question — both must pass.

> Source: findings.md "Faithfulness (Groundedness)" + "Answer Relevance" + "General-Purpose High-Performance Baseline" [35, 36]

**determinismLevel**: deterministic.

### RE3: Reference-Based IR Metric Targets

When a human-annotated gold set exists, use reference-based IR metrics with these target thresholds:

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

When no manual gold labels exist, use automated LLM-as-judge (Ragas-style) metrics with these targets:

| Metric | Target | Definition |
|--------|--------|------------|
| **Context Precision** | ≥ 0.85 | Relevant chunks / total retrieved (are relevant chunks at the top?) |
| **Context Recall** | ≥ 0.90 | Necessary chunks retrieved / total necessary |
| **Faithfulness** | 1.00 | Claims supported / total claims (see RE2) |
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

When establishing a regression/continuous-eval suite, run Ragas-style evaluators over a **representative test set of 100–200 queries** covering the real query distribution, and gate production on the composite threshold (Faithfulness = 1.0, Answer Relevance ≥ 0.90).

**Rule**: A handful of cherry-picked queries is not an eval suite. 100–200 representative queries is the floor for trusting a deployment gate.

> Source: findings.md "Continuous Validation" / "General-Purpose High-Performance Baseline" [35, 36]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **One blended RAG score**: Hides whether retrieval or generation failed. Always split (RE1).
- **Shipping below Faithfulness 1.0**: Faithfulness 0.8 means 1 in 5 claims is unsupported — that is hallucination, not "good enough."
- **ROUGE/BLEU as the primary RAG metric**: They measure n-gram overlap, miss semantic paraphrase, and say nothing about grounding. Use BERTScore for semantics and Faithfulness for grounding.
- **Wrong domain priority**: Recall-first on narrow legal corpora floods the generator with noise; precision-first on broad FAQ misses context. Match priority to domain.
- **Tiny eval set**: < 100 queries can't support a trustworthy production gate.
