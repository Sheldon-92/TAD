**P1 Findings**

- **P1: Adding BM25 and cosine scores directly is not valid ranking math.**  
  BM25 and cosine live on different scales and distributions. A raw sum can let one scorer dominate unpredictably. Use rank fusion such as RRF, or normalize/calibrate scores per query before combining.

- **P1: “Big model for max dimensions” is not automatically better.**  
  Higher-dimensional embeddings can improve capacity, but may increase cost, latency, storage, and sometimes noise. Retrieval quality depends more on domain fit, embedding model training, chunking, and query/document alignment than dimensionality alone.

- **P1: Faithfulness 0.8 alone is insufficient to judge the RAG pipeline.**  
  Faithfulness measures whether generated answers are grounded in retrieved context, not whether retrieval found the best evidence. You also need retrieval metrics like recall@k, nDCG, MRR, context precision, answer correctness, and failure-case review.

- **P1: Reranking top 200 may be expensive and possibly unnecessary.**  
  Reranking 200 candidates can work, but you should validate the cutoff. If recall@200 is not much better than recall@50, you are paying latency for little gain. If recall@200 is poor, reranking cannot recover missing evidence.

**P2 Findings**

- **P2: Semantic chunking needs guardrails.**  
  Semantic chunking can produce uneven chunks, lose metadata boundaries, or split tables/code/procedures badly. Track chunk size distribution, overlap strategy, section metadata, and whether answers require multi-chunk evidence.

- **P2: Hybrid retrieval should be evaluated by query type.**  
  BM25 helps exact terms, IDs, names, and rare phrases. Dense retrieval helps paraphrase and concept matching. Evaluate separately across lexical, semantic, multi-hop, and long-tail queries.

- **P2: Chroma is fine, but index settings matter.**  
  Make sure distance metric matches embedding normalization assumptions. Cosine retrieval usually expects normalized vectors or a cosine-aware index.

- **P2: Top-k retrieval and final context size are separate decisions.**  
  “Top 200 reranked” is candidate generation. The final number passed to the LLM should be much smaller and optimized for context precision, not just recall.

**No P0 Findings**

No immediate catastrophic flaw, but the score fusion and eval interpretation are serious enough that I would not treat the current `Faithfulness = 0.8` as proof the system is good.
