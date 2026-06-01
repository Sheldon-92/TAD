## RAG / Retrieval Review: Full Pipeline

### P0 — Blocking (will produce wrong or hallucinated results)
- **[Rule HR3] Score Fusion**: BM25 and cosine scores are summed directly. BM25 is mathematically unbounded and will dominate the tightly bounded cosine score, breaking the ranking. **Fix**: Never sum raw scores. Fuse by rank using Reciprocal Rank Fusion (RRF) with `k=60`.
- **[Rule RE2] Evaluation / Hallucination**: A Faithfulness score of 0.8 means 1 in 5 claims (20%) in your answers are hallucinated or relying on parametric memory rather than the context. This is not "fine." **Fix**: Treat Faithfulness as binary-critical. Gate production deployments on **Faithfulness = 1.0** and Answer Relevance ≥ 0.90. 

### P1 — Required (fix before trusting retrieval quality)
- **[Rule CH4] Chunking Strategy**: Pipeline defaults to Semantic chunking. Under an equal context budget, semantic chunking benchmarks at **< 55%** accuracy compared to recursive-512's **69%**, while incurring persistent per-sentence API latency. **Fix**: Switch baseline to Recursive Character Splitting at a **512-token target with 10–20% overlap**.
- **[Rule VD1] Vector Database**: Pipeline uses Chroma as a default datastore. Chroma's scale ceiling is **< 1M vectors** and it is designed for local prototyping. **Fix**: Do not ship a production system on Chroma. If your corpus is under 100M vectors, use **pgvector + pgvectorscale**, which benchmarks at **471 QPS @ 99% recall** (11.4× faster than dedicated DBs like Qdrant).
- **[Cross-Cutting Rule] Evaluation Architecture**: You are only citing a generation metric (Faithfulness) to evaluate the pipeline. A single blended metric hides whether the retriever failed to fetch chunks or the generator hallucinated. **Fix**: Evaluate retrieval and generation SEPARATELY.

### P2 — Advisory (improves quality/latency/cost)
- **[Rule HR6] Reranker Candidate Pool**: Reranking the top 200 candidates pays linear latency for marginal gain. **Fix**: Restrict the candidate pool to **≤ 50 documents**. Reranking the top-50 captures **~90% of the accuracy gain** of the top-200 while helping to hold a ~120ms P95 latency budget.
- **[Rule EM2] Embedding Dimensions**: Using a "big model for max dimensions" assumes dimension count dictates quality. On models like `text-embedding-3-large`, Matryoshka truncation from **3072 down to 512 dimensions** yields a Wilcoxon test showing **no significant quality loss** while drastically cutting storage costs. **Fix**: Treat dimensions as a storage knob, not a quality knob; truncate if using a Matryoshka model.

### Retrieval vs Generation Split (Cross-Cutting Rule)
- **Retrieval metrics + targets**: Precision @k (≥0.70 for narrow domain), Recall @k (≥0.80 at k=20), MRR (≥0.85), nDCG @k (≥0.80 at k=10), or LLM-judged Context Precision (≥0.85) / Context Recall (≥0.90).
- **Generation metrics + targets**: Faithfulness = 1.0, Answer Relevance ≥ 0.90, Groundedness ≥ 0.95.

### Pipeline Blueprint 
- **Chunking** → Recursive-512 (10–20% overlap)
- **Embedding** → Voyage 3.5 (quality) or text-embedding-3-large truncated to 512 dims (storage)
- **Vector DB** → pgvector + pgvectorscale (if < 100M vectors)
- **Hybrid + RRF** → Over-retrieve (30 sparse + 30 dense) → Dedup → RRF (k=60)
- **Reranker** → gte-reranker-modernbert-base (cap candidates at 50)
- **Eval gate** → Separate Retrieval metrics (Context Precision/Recall) & Generation metrics (Faithfulness=1.0)
