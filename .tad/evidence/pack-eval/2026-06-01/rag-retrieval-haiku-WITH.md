# RAG / Retrieval Review: Your Pipeline Configuration

## P0 — Blocking (will produce wrong or hallucinated results)

**[P0-1] RE2 Cross-Cutting Rule: Faithfulness 0.8 means hallucination**

Your Faithfulness score of **0.8 is NOT "fine"** — it means **1 in 5 claims is unsupported**. The pack's rule:

> **Any Faithfulness score below 1.0 indicates the model is fabricating or relying on parametric memory rather than the retrieved context.**

**Production deployment gate (RE2):**
- Faithfulness = **1.00** (critical — block on any value below)
- Answer Relevance ≥ 0.90
- Groundedness ≥ 0.95

→ Your pipeline is NOT production-ready at Faithfulness 0.8. Do NOT ship this. Investigate and fix the underlying cause before deploying.

**[P0-2] RE1 Cross-Cutting Rule: You report a blended metric, hiding the real failure**

You report a single "eval gives a Faithfulness 0.8" without splitting **retrieval vs generation metrics separately**. This hides which stage is broken:

- **Retrieval stage failure** (you're fetching wrong chunks) → fix: reranker, chunking strategy, or embedding model
- **Generation stage failure** (you're retrieving right chunks but the LLM ignores them) → fix: prompt/grounding instruction

The Faithfulness score alone tells you GENERATION is failing, but you need retrieval metrics to know whether retrieval is also degraded.

→ **Re-measure with the split metric suite below** before moving forward.

---

## P1 — Required (fix before trusting retrieval quality)

**[P1-1] HR3: BM25 + cosine scores summed directly = mathematically invalid**

Your pipeline "add the BM25 score and the cosine score together to rank."

BM25 is **unbounded positive**; cosine is **bounded in [-1,1]**. Summing them is mathematically invalid — **BM25 dominates the fusion** and cosine contribution is noise.

**Rule HR3**: Use **Reciprocal Rank Fusion (RRF) with k=60** instead:

```
RRF_Score(d) = Σ_m  1 / (r_m(d) + k)   where k = 60
```

This operates on **rank order**, bypassing normalization entirely. Empirical lift (WANDS e-commerce): **RRF hybrid 0.7497 nDCG vs vector 0.6983 and keyword 0.6953 (+7.4%)**.

→ Replace raw-score addition with RRF. Library examples: `reciprocal-rank-fusion` (Python), built into Weaviate/Pinecone/Qdrant.

**[P1-2] HR6: Reranking top-200 is paying latency for marginal gain**

Your pipeline reranks "all of them" — which you indicate is "top 200."

**Rule HR6**: Reranking the **top-50 captures roughly 90% of the accuracy gain of reranking the top-200**, while cutting latency substantially. The benchmark reports **~120ms P95** for top-50 reranking (with pre-warmed GPU workers).

→ **Cap the candidate pool at ≤ 50 before reranking** unless an eval on YOUR stack/reranker proves the extra 150 candidates matter. Start with top-50, measure quality-vs-latency trade-off on your hardware, then expand only if justified.

---

## P2 — Advisory (improves quality/latency/cost)

**[P2-1] Chunking strategy unknown — verify it's not semantic**

You mention "semantic chunking" to split docs. 

**Rule CH4**: Semantic chunking **benchmarked < 55% accuracy vs recursive-512's 69%** on academic texts under an equal context budget. It is slower (per-sentence embedding calls) and less accurate.

→ **Unless recall-on-dense-unstructured-text is your explicit priority** (which would justify the accuracy/latency cost), switch to **Recursive Character Splitting at 512 tokens with 10–20% overlap** (Rule CH1 baseline).

**[P2-2] Embedding dimensions — clarify if you're using truncation**

You mention "embed with a big model for max dimensions."

**Rule EM2**: If you're using OpenAI `text-embedding-3-large` at its full 3072 dimensions for retrieval, you can **truncate to 512 with no significant quality loss** (Wilcoxon non-parametric test, Matryoshka representation). This cuts vector-DB storage dramatically.

→ If storage/cost is a concern, measure quality with 512-dim truncation first; dimensions are a **storage knob, not a quality knob** on this model.

---

## Retrieval vs Generation Split (Cross-Cutting Rule)

### Retrieval Metrics (Replace the blended score)

Measure these independently with reference-based IR metrics OR LLM-as-judge:

| Metric | Target | Your Status |
|--------|--------|-------------|
| **Precision@k** (k=10) | ≥ 0.70 | Unknown — measure |
| **Recall@k** (k=20) | ≥ 0.80 | Unknown — measure |
| **nDCG@k** (k=10) | ≥ 0.80 | Unknown — measure |
| **Context Precision** (LLM-judge) | ≥ 0.85 | Unknown — measure |
| **Context Recall** (LLM-judge) | ≥ 0.90 | Unknown — measure |

**If these pass** → retriever is healthy; focus on generation fixes.  
**If these fail** → fix chunking/embedding/reranker before touching generation.

### Generation Metrics

| Metric | Target | Your Status |
|--------|--------|-------------|
| **Faithfulness** | **= 1.00** | **0.8 ✗ FAIL** |
| **Answer Relevance** | ≥ 0.90 | Unknown — measure |
| **Groundedness** | ≥ 0.95 | Unknown — measure |

**Action**: Your Faithfulness 0.8 indicates the generation stage is hallucinating. Before you can trust any fix, run the retrieval metrics above to determine whether the problem is also in retrieval (low Context Precision/Recall) or ONLY in generation (high retrieval metrics + low Faithfulness).

---

## Evaluation Suite Checklist (RE6)

Establish a continuous eval with these requirements:

- **Test set size**: 100–200 representative queries covering your real query distribution (not cherry-picked)
- **Metrics computed per query**: Precision@k, Recall@k, nDCG@k, AND Context Precision/Recall, AND Faithfulness/Answer Relevance
- **Production gate**: Faithfulness = 1.00 AND Answer Relevance ≥ 0.90 (AND Context Precision ≥ 0.85 + Context Recall ≥ 0.90 for retrieval health)

→ Your current "Faithfulness 0.8 seems fine" indicates you're shipping without an eval suite or have cherry-picked queries that don't reflect real distribution. Expand to 100–200 representative queries before declaring readiness.

---

## Summary

**Immediate actions:**

1. **Stop shipping at Faithfulness 0.8.** This is hallucination, not "good enough." (P0-1)
2. **Split your eval into retrieval vs generation metrics.** Measure Context Precision/Recall + Faithfulness/Answer Relevance separately. (P0-2, RE1)
3. **Replace raw score fusion with RRF (k=60).** BM25 + cosine is mathematically invalid. (P1-1, HR3)
4. **Cap reranking candidate pool at 50.** Top-200 pays 4× latency for ~10% of the accuracy gain. (P1-2, HR6)
5. **Verify chunking strategy.** If semantic, switch to Recursive-512 unless dense-unstructured-recall is the explicit goal. (P2-1, CH4)

**Next step:** Re-measure with a 100–200-query eval suite split into retrieval and generation stages. Report the retrieval metrics (Context Precision/Recall) and generation metrics (Faithfulness/Answer Relevance) separately. That will tell you which stage to fix and whether P1-1 (fusion), P1-2 (reranker pool), or prompt/grounding is the priority.
