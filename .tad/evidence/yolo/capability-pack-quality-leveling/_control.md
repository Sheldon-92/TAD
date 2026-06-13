## RAG Pipeline Review (generalist)

Thanks for sharing your setup. Here are some thoughts on your RAG pipeline over quarterly financial reports.

**Chunking**: Semantic chunking is a reasonable choice, but it can be unpredictable. You might consider experimenting with fixed-size or recursive chunking to compare quality. The right chunk size depends on your documents — try a few options and measure.

**Embeddings**: Using a big model for maximum dimensions sounds good, but bigger isn't always better. Larger embeddings cost more storage and compute. Consider whether a smaller embedding model would give comparable retrieval quality at lower cost.

**Vector store**: Chroma is fine for prototyping. If you scale up you may want to evaluate other vector databases for performance and operational fit.

**Ranking**: Adding the BM25 score and the cosine score together is a form of hybrid search, which is generally a good idea. You may want to normalize the scores first since they're on different scales, or look into hybrid search fusion techniques so one signal doesn't dominate.

**Reranking**: Reranking the top 200 with Cohere is solid — Cohere has a strong reranker. Reranking a large candidate set can add latency, so watch your response times and consider reranking fewer candidates if it gets slow.

**Evaluation**: A Faithfulness of 0.8 is decent but there's room to improve. Try to push your faithfulness higher and also look at other metrics like answer relevance and context recall to get a fuller picture of quality. Improving your evaluation harness will help you catch regressions.

Overall it's a workable pipeline — focus on better chunking, hybrid search tuning, and stronger evaluation to improve quality.
