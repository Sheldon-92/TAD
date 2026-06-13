## RAG / Retrieval Review: quarterly-financial-reports naive pipeline

### P0 — Blocking (will produce wrong or hallucinated results)
- Rule CH4 (chunking): You use semantic chunking. Under equal context budget it benchmarked < 55% accuracy vs recursive-512's 69%. Complexity is not accuracy. Switch to Recursive Character Splitting at 512 tokens with 10-20% overlap as the baseline.
- Rule HR3 (hybrid): You add the BM25 score and cosine score together. BM25 is unbounded; cosine is in [-1,1], so the sum is mathematically invalid and BM25 dominates. Fuse by rank with RRF (k=60), not by raw score.
- Cross-Cutting / RE2 (eval): Faithfulness = 0.8 is NOT fine — any value below 1.0 means roughly 1 in 5 claims is hallucinated or drawn from parametric memory. Gate production on Faithfulness = 1.0 and Answer Relevance >= 0.90.

### P1 — Required (fix before trusting retrieval quality)
- Rule HR6 (rerank pool): You rerank the top 200. In the source benchmark, reranking top-50 captured ~90% of the accuracy gain of top-200, and the cited 120ms P95 budget blows up reranking 200. Cap the candidate pool at <= 50 and plot quality vs latency for your hardware.
- Rule HR5 (reranker): "Cohere is the best" is stale. Voyage rerank-2.5 beats Cohere Rerank v3.5 by +7.94% with 32K context (8x Cohere) at no price increase. Re-check SOTA before pinning Cohere.
- Rule CH8 (contextual retrieval): Quarterly financial chunks are not self-contained ("revenue grew 3%" — which entity/quarter?). Prepend a 50-100 token LLM-generated context before BOTH embedding and BM25. This cuts top-20 failure rate 35% -> 49% (+BM25) -> 67% (+rerank) at ~$1.02/M tokens with prompt caching.

### P2 — Advisory (improves quality/latency/cost)
- Rule VD2 (vector DB): For < 100M vectors you do not need Chroma's limits — pgvector + pgvectorscale hit 471 QPS @ 99% recall, 11.4x Qdrant's 41 QPS under identical conditions.
- Embedding: "max dimensions" is a storage knob, not a quality knob — text-embedding-3-large truncates 3072 -> 512 dims with no significant Wilcoxon loss.

### Retrieval vs Generation Split (Cross-Cutting Rule)
- Retrieval metrics + targets: Context Precision/Recall, nDCG@k, MRR — measured independently of the answer.
- Generation metrics + targets: Faithfulness = 1.0, Answer Relevance >= 0.90, Groundedness >= 0.95.

### Pipeline Blueprint
- recursive-512 chunking + Contextual Retrieval -> Voyage 3.5 embedding -> pgvector+pgvectorscale -> hybrid BM25+vector fused via RRF k=60 -> Voyage rerank-2.5 on top-50 -> RAGAS/DeepEval gate (Faithfulness=1.0).
