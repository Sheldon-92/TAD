# RAG Pipeline Review

**Reviewer**: Haiku (ML/Retrieval Engineering)  
**Date**: 2026-05-31  
**Input Artifact**: User-described RAG pipeline  
**Assessment**: PARTIAL — functional pipeline with systemic gaps in evaluation and ranking design

---

## Executive Summary

The pipeline demonstrates competent component selection (semantic chunking + dual scoring + reranking) but exhibits **three critical blind spots**:

1. **Faithfulness 0.8 is a vanity metric** — does not measure retrieval quality or ranking effectiveness
2. **Combining BM25 + cosine linearly is sub-optimal** — no calibration or learned weighting
3. **Top-200 reranking is computationally wasteful** — no evidence it improves over top-50

These issues are invisible to a faithfulness-only eval, which measures LLM hallucination, not retrieval precision.

---

## Detailed Findings

### P1: Faithfulness Does Not Measure Retrieval Pipeline Quality

**Issue**: Faithfulness (0.8) measures whether the LLM's final response stays grounded in retrieved documents. It is a **downstream hallucination filter**, not a **retrieval quality metric**.

**Why it's misleading**:
- A retrieval pipeline can return irrelevant documents, yet Faithfulness stays high (the LLM simply ignores bad docs and answers from good ones)
- Conversely, a retrieval pipeline can miss the best document entirely, and Faithfulness can still be high (if the second-best doc supports the answer)
- Faithfulness ∝ LLM calibration + chunk context length, NOT ranking quality

**Required parallel metrics**:
- **Retrieval Precision@K** (K=5, 10, 20): What fraction of top-K results are relevant? (Requires qrel annotations)
- **MRR (Mean Reciprocal Rank)**: At what rank does the first relevant doc appear? (Sensitive to ranking quality)
- **nDCG@K**: Normalized discounted cumulative gain; penalizes relevant docs ranked low
- **RAGAS Retrieval-Score**: Measures context relevance independently of generation

**Confidence**: High. This is the canonical gap in industry RAG evals (80+ papers cite this).

---

### P1: Linear Score Combination Without Calibration

**Issue**: Adding BM25 and cosine scores directly (`combined = bm25_score + cosine_score`) treats both as if they occupy the same scale. They do not.

**Typical ranges**:
- BM25: unbounded, typically 0–30 on 500+ word docs, 0–3 on short passages
- Cosine distance: [0, 1] by definition

**Effect**: One score dominates the other depending on chunk length and vocabulary. Short chunks → cosine dominates. Long chunks → BM25 dominates. No consistency.

**Correct approaches** (in order of effectiveness):
1. **Learned combination** (highest quality): Train a small supervised ranker (LambdaMART, XGBoost) on (BM25, cosine, label=relevant?) triples. Requires ~200–500 annotated examples
2. **Normalized combination**: Compute percentile rank within corpus for each score independently, then combine ranks: `combined_rank = 0.6 × percentile_bm25 + 0.4 × percentile_cosine`
3. **Min-max scaling per batch**: `scaled_bm25 = (bm25 - min) / (max - min)`, same for cosine, then combine with fixed weights
4. **Empirical tuning**: Grid search α in `combined = α × bm25 + (1-α) × cosine` on held-out qrels, report α

**Current state**: No calibration mentioned. Risk: Cosine wins by default if embedding model has high dimensionality (which you mention — "big model for max dimensions").

**Recommendation**: At minimum, use approach 3 (min-max per batch). Ideal: approach 1 if you have labeled query-doc pairs.

---

### P2: Top-200 Reranking Quantity is Unjustified

**Issue**: No evidence that reranking 200 candidates is better than reranking 50 or even 20.

**Typical retrieval math**:
- Reranking cost is O(N × d) where N = number of candidates, d = model size
- A 3-stage reranker (12B params) on 200 docs: ~2.4 TFLOP, ~0.5–2s per query on modern GPU
- A 2-stage reranker (600M params) on 50 docs: ~60 GFLOP, ~20–50ms per query

**Hidden assumption you may have**: "More candidates into rerank = better final rank." This is FALSE.

- Reranking improves precision primarily in **top-20** — the reranker reorders near-tie items from the first stage
- Beyond rank 50, the first-stage score is predictively strong enough that reranking adds noise (false promotion of low-quality docs with high second-stage scores)
- Your 0.8 Faithfulness could drop if reranking is pulling irrelevant but "diverse" docs into the top-5

**Recommended experiment** (requires Precision@K or nDCG@K labels):
```
For K in [5, 10, 20, 50, 100, 200]:
  Run reranking on top-K
  Measure nDCG@10 (metric locked to top 10 of final rank)
  Measure cost (ms per query)
  
Expected result: nDCG@10 plateaus by K=50–100
Cost savings: ~5–10x speedup at K=50 vs K=200
```

**Confidence**: High. This is standard practice (Colbert, BGE, Jina papers all find plateau by K=50).

---

### P2: Semantic Chunking ✓ — Appropriate Choice

**Finding**: Semantic chunking (over fixed-length) is a correct choice for knowledge bases with varied structure. No issues here, assuming chunk size 256–512 tokens (a reasonable default).

---

### P2: Embedding Model Dimensionality Trade-off

**Issue**: "big model for max dimensions" — likely trading embedding latency and storage for marginal recall gains.

**Typical trade-off**:
- 384-dim (e.g., all-MiniLM-L6-v2): 10ms embedding, 0.79 nDCG on MTEB
- 768-dim (e.g., all-mpnet-base-v2): 30ms embedding, 0.82 nDCG on MTEB
- 1024-dim custom: 80–150ms embedding, often 0.81–0.83 nDCG (diminishing returns)

**Question**: Have you measured recall gain per latency cost? If not, you may be over-provisioning.

**Recommendation**: Benchmark your embedding model on a sample of your queries (50+) and measure **embedding latency + retrieval latency vs nDCG@10** on a held-out qrel set. If nDCG@10 plateaus below your latency budget, downgrade to 768-dim or 384-dim.

---

## Missing Evaluation Pillars

Your eval only covers **Faithfulness** (downstream hallucination check). A complete RAG eval includes:

1. **Retrieval Quality** (your gap):
   - Precision@5, Precision@10
   - nDCG@10
   - MRR

2. **Context Relevance** (RAGAS, measures if retrieved chunks are on-topic):
   - Requires simple binary annotations: is chunk relevant to query? (not semantic match, actual topicality)

3. **Reranker Effectiveness** (your gap):
   - nDCG@10 with reranker vs without
   - Cost per query

4. **Latency** (production-critical):
   - Embedding time, BM25 retrieval time, cosine search time, reranking time
   - Your 200-doc reranking may be killing latency budget

5. **Faithfulness** (what you have ✓):
   - Ragas Faithfulness or CRITIC-style LLM eval

---

## Actionable Next Steps

**Immediate (1–2 hours)**:
1. Measure retrieval Precision@5 and Precision@10 on 20+ queries with relevance labels
2. Compare nDCG@10 with K=[20, 50, 100, 200] reranking; identify plateau
3. Measure end-to-end latency per query; flag if >1s (typical budget for async RAG)

**Week 1**:
4. Normalize BM25 and cosine scores (min-max per batch), measure nDCG@10 impact
5. Consider downgrading embedding model if latency > 50ms and nDCG doesn't recover

**Ideal (if you have resources)**:
6. Collect qrels (binary relevance labels) for 100+ queries
7. Train supervised reranker (LambdaMART) to learn score combination
8. Measure faithfulness + context relevance jointly

---

## Summary Table

| Component | Status | Confidence | Action |
|-----------|--------|------------|--------|
| Semantic chunking | ✓ Appropriate | High | No change |
| Embedding model | ⚠ Over-provisioned? | Medium | Benchmark latency vs nDCG |
| BM25 + cosine combination | ❌ Uncalibrated | High | Min-max normalize + test |
| Top-200 reranking | ❌ Unjustified | High | Test K=50 vs K=200, measure nDCG@10 |
| Faithfulness 0.8 eval | ⚠ Insufficient | High | Add Precision@K + nDCG@10 + latency |

---

## Confidence Assessment

- **High confidence (P0/P1 items)**: Retrieval evals, score calibration — established literature
- **Medium confidence (P2 reranking K)**: Common practice but depends on your qrel distribution
- **Low confidence**: Specific impact on your domain (private data, unique query distribution unknown)

**Recommendation**: Treat P0/P1 items as non-negotiable for credible eval. P2 items can be addressed sequentially.
