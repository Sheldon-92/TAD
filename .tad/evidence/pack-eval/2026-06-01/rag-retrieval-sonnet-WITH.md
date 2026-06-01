## RAG / Retrieval Review: User Pipeline (semantic chunking + big-model embedding + Chroma + BM25+cosine sum + top-200 rerank + Faithfulness 0.8)

---

### P0 — Blocking (will produce wrong or hallucinated results)

**[P0-1] Rule RE2 (eval): Faithfulness 0.8 is NOT "fine" — it means 1 in 5 claims is hallucinated.**
Faithfulness = (Claims Supported by Context) / (Total Claims in Answer). The production gate is Faithfulness = **1.00**. A score of 0.8 means 20% of generated claims are unsupported by retrieved context — the model is fabricating or drawing on parametric memory rather than your documents. Shipping at 0.8 is shipping a system that hallucinates on every fifth claim.
→ Do not treat 0.8 as acceptable. Gate deployment on Faithfulness = **1.00** AND Answer Relevance ≥ **0.90**. Diagnose root cause first by splitting retrieval vs. generation (see P0-2).

**[P0-2] Rule RE1 (eval): A single Faithfulness score is a blended score — you don't know which stage is failing.**
You reported one metric (Faithfulness). That is a generation metric alone. You have no retrieval metrics (Precision@k, Recall@k, MRR, nDCG@k, Context Precision/Recall), so you cannot tell whether the hallucination is caused by the retriever fetching the wrong chunks (retrieval failure) or the LLM ignoring the right chunks (generation failure). These two failures have completely different fixes.
→ Add the retrieval split immediately:
  - Retrieval: Precision@k ≥ 0.70, Recall@k ≥ 0.80 at k=20, MRR ≥ 0.85, nDCG@k ≥ 0.80 at k=10
  - Generation: Faithfulness = 1.00, Groundedness ≥ 0.95, Answer Relevance ≥ 0.90
  - If you have no gold labels: use Context Precision ≥ 0.85 and Context Recall ≥ 0.90 (Ragas-style LLM-as-judge).

**[P0-3] Rule HR3 (hybrid): Adding BM25 and cosine scores together is mathematically invalid — BM25 dominates.**
BM25 scores are unbounded positive values; cosine similarity is bounded in [-1, 1]. Summing them gives BM25 unconstrained control over the ranking unless you apply dataset-specific normalizers that require continuous manual recalibration. This is not a minor tuning issue — the fusion is structurally broken.
→ Replace with Reciprocal Rank Fusion (RRF, k=60), which operates on rank order and bypasses normalization entirely:
  `RRF_Score(d) = Σ_m  1 / (r_m(d) + k)   k = 60`
  Empirical lift on WANDS e-commerce: RRF hybrid nDCG **0.7497** vs. vector-only **0.6983** and keyword-only **0.6953** (+7.4%). The k=60 smoothing constant prevents top-ranked items from dominating.

---

### P1 — Required (fix before trusting retrieval quality)

**[P1-1] Rule CH4 (chunking): Semantic chunking benchmarked < 55% accuracy — it is not the advanced choice, it is the worse choice.**
Semantic chunking embeds every sentence, splits on cosine-similarity drops, and under an equal context budget on academic texts it degraded to **< 55% retrieval accuracy** vs. Recursive Character Splitting at 512 tokens which scored **69%**. The only justified use of semantic chunking is dense unstructured text where recall (not budget) is the explicit priority — and even then it adds only ~9% recall on that specific scenario.
→ Switch the default to **Recursive Character Splitting at 512 tokens with 10–20% sliding-window overlap**, using separator hierarchy `["\n\n", "\n", " ", ""]`. This preserves natural paragraph and syntactic structure without any model calls, and it is the benchmark winner under equal context budget.

**[P1-2] Rule EM2 (embedding): Using "max dimensions" wastes storage with no quality gain on Matryoshka models.**
If your "big model for max dimensions" is OpenAI `text-embedding-3-large` at 3,072 dims, you are paying for storage you don't need. The model uses Matryoshka representations: truncating from 3,072 → **512 dimensions** produces a cosine-similarity quantization error of only ~0.000001, and a Wilcoxon non-parametric test shows **no significant quality difference** between the 1,536-dim and 512-dim variants. Dimensions are a storage knob on this model, not a quality knob.
→ Truncate to 512 dims (or 256) and dramatically cut vector-DB storage. If you are using a different large model, check whether it supports Matryoshka truncation before assuming max dims = max quality.

**[P1-3] Rule HR6 (reranking): Reranking top-200 pays linear latency for ~10% of the marginal accuracy gain.**
In the source benchmark, reranking the **top-50 captured ~90% of the accuracy gain of reranking top-200**. You are doing 4× the reranker work for roughly 10% of the remaining improvement. The benchmark target is ≤50 candidates to stay under ~120ms P95 reranking latency (benchmark-specific — measure on your own stack).
→ Cap the first-stage candidate pool at **≤ 50** before passing to the reranker. Only expand back toward 200 if an explicit eval proves the extra candidates move your Recall@k target.

---

### P2 — Advisory (improves quality / latency / cost)

**[P2-1] Rule VD1 (vector DB): Chroma is a prototyping database — its scale ceiling is < 1M vectors.**
Chroma's ceiling in the routing matrix is under 1M vectors; it is designed for local prototyping and fast Python setup, not production systems with multi-million-vector corpora. If your doc set is or will be > 1M vectors, you are building on the wrong foundation.
→ For < 100M vectors with an existing Postgres stack: **pgvector + pgvectorscale** achieves **471 QPS at 99% recall on 50M vectors — 11.4× faster than Qdrant** under identical conditions, with no second datastore to sync. For larger corpora or dedicated deployment: Qdrant (< 50M) or Milvus (petabyte scale).

**[P2-2] Rule HR4 (hybrid): Over-retrieve before fusion, then deduplicate by chunk ID.**
Your pipeline takes top-200 and hands it to the reranker. After switching to RRF (P0-3) and capping at top-50 (P1-3), implement the over-retrieve pattern at the retrieval stage: retrieve **30 sparse + 30 dense** candidates, deduplicate by unique chunk ID, then fuse with RRF before passing to the reranker. This fills the candidate pool without score-incompatibility.

**[P2-3] Rule HR5 + HR7 (reranker selection): Check the reranker architecture against your latency budget.**
You mentioned reranking but not which reranker. For low-latency production: **gte-reranker-modernbert-base (149M params, seq-classification)** — cross-encoder precision at 8× smaller than 1B models with identical accuracy. Reserve 4B causal-LM rerankers (Qwen3-Reranker-4B, nv-rerankqa-mistral-4b-v3) for accuracy-first, non-realtime settings.

**[P2-4] Rule RE6 (eval): Confirm your eval suite has 100–200 representative queries.**
A trustworthy production gate requires a test set of **100–200 representative queries** covering the real query distribution. Fewer than 100 queries cannot support a reliable deployment gate — cherry-picked queries systematically miss failure modes in the tail of the distribution.

---

### Retrieval vs. Generation Split (Cross-Cutting Rule RE1)

Your pipeline currently reports one generation metric (Faithfulness 0.8). Both stages need independent measurement before any fix can be localized:

**Retrieval metrics — targets:**
| Metric | Target |
|--------|--------|
| Precision@k | ≥ 0.70 (narrow domain) |
| Recall@k | ≥ 0.80 at k=20 |
| MRR | ≥ 0.85 |
| nDCG@k | ≥ 0.80 at k=10 |
| Context Precision (LLM-judge, no gold set) | ≥ 0.85 |
| Context Recall (LLM-judge, no gold set) | ≥ 0.90 |

**Generation metrics — production gate:**
| Metric | Target |
|--------|--------|
| Faithfulness | **1.00** (current: 0.8 — BLOCKED) |
| Groundedness | ≥ 0.95 |
| Answer Relevance | ≥ 0.90 |

---

### Corrected Pipeline Blueprint

```
Docs
 └─► Recursive-512 (10–20% overlap, separator: ["\n\n", "\n", " ", ""])
      └─► Embed (voyage-3.5 OR text-embedding-3-large @ 512 dims)
           ├─► Vector DB (pgvector+pgvectorscale if <100M; Qdrant/Milvus at scale)
           │    └─► Dense retrieval: top-30
           └─► BM25 (k1 ∈ [1.2, 2.0], b=0.75)
                └─► Sparse retrieval: top-30
                     └─► Dedup by chunk ID
                          └─► RRF fusion (k=60)   ← NOT raw score sum
                               └─► Top-50 candidates   ← NOT top-200
                                    └─► Reranker: gte-reranker-modernbert-base (149M)
                                         └─► Top-10 to LLM
                                              └─► Eval gate: Faithfulness=1.0, AnswerRelevance≥0.90, Recall@k≥0.80
```

**Summary of blocking issues:**
1. Faithfulness 0.8 = production block (1 in 5 claims hallucinated)
2. No retrieval/generation split = can't diagnose the root cause
3. BM25 + cosine sum = mathematically invalid fusion (BM25 dominates)
4. Semantic chunking = < 55% accuracy vs recursive-512's 69%
5. Reranking top-200 = 4× latency for ~10% marginal gain

Fix P0-3 (RRF), P1-1 (chunking), and P0-2 (eval split) first — they are the most likely drivers of the Faithfulness 0.8 floor.
