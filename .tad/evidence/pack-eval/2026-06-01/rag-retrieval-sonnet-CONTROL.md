# RAG Pipeline Review

**Reviewer**: Senior ML/Retrieval Engineer  
**Date**: 2026-05-31  
**Mode**: CONTROL (no capability pack loaded)

---

## Pipeline Summary (as described)

1. Semantic chunking
2. Embed with a large model (max dimensions)
3. Store in Chroma
4. Hybrid retrieval: BM25 score + cosine score (raw addition)
5. Top-200 recall set
6. Rerank all 200
7. Eval: Faithfulness = 0.8

---

## Issues Found

### 1. Raw Score Addition for Hybrid Retrieval is Broken

**Severity: High**

BM25 scores are unnormalized TF-IDF-weighted term frequencies — they range roughly 0 to 20+ depending on document length and collection statistics. Cosine similarity scores range 0.0 to 1.0. Adding these raw numbers means BM25 numerically dominates in nearly every case. The cosine score contributes almost nothing to the final rank.

The standard fix is Reciprocal Rank Fusion (RRF): convert each retrieval method to a rank, then combine via `1 / (k + rank)` where k=60 is the conventional constant. RRF is distribution-agnostic — it doesn't matter that BM25 and cosine live in different numeric spaces. Alternatively, normalize each score independently to [0,1] before combining (min-max normalization per query), then apply a weighted sum. The weight between sparse and dense should be tuned on your eval set, not left at 0.5.

### 2. Top-200 Recall Then Rerank All 200 is Expensive and Likely Wasteful

**Severity: Medium**

Rerankers (cross-encoders) are O(n) in inference cost per query and typically run at 5-20ms per document on GPU. Reranking 200 documents adds 1-4 seconds of latency per query. The typical production pattern is:

- First-stage: 50-100 candidates (not 200)
- Rerank: top 20-30 of those
- Pass final top-k (typically 5-10) to the LLM context

If your reranker is a cross-encoder (e.g., ms-marco-MiniLM), its quality degrades little if you reduce the recall set from 200 to 50-100 because documents ranked below 50 by both BM25 and cosine are rarely rescued by reranking anyway. The cost savings are substantial.

### 3. Faithfulness 0.8 is Not "Fine" — It's the Wrong Metric to Optimize

**Severity: High (evaluation design)**

Faithfulness measures whether the generated answer is grounded in the retrieved context. A score of 0.8 means 20% of generated claims are not supported by the retrieved documents — that is a significant hallucination rate for most production use cases.

More critically, Faithfulness alone tells you almost nothing about retrieval quality. A system that retrieves wrong-but-internally-consistent documents can score 1.0 on Faithfulness while giving completely wrong answers. The metrics you need alongside Faithfulness:

- **Answer Relevancy**: Does the answer address the actual question?
- **Context Recall** (requires ground truth): Did retrieval surface the documents that actually contain the answer? This is the retrieval-quality metric you're missing.
- **Context Precision**: Of the retrieved documents, what fraction were relevant?

A complete RAGAS evaluation includes all four. Running only Faithfulness gives a misleadingly positive signal.

### 4. "Max Dimensions" for Embedding is Not Always Better

**Severity: Medium**

Larger embedding models (e.g., text-embedding-3-large at 3072 dimensions vs. text-embedding-3-small at 1536) do not always outperform smaller ones on domain-specific retrieval tasks. Key considerations:

- Matryoshka Representation Learning (MRL) models (e.g., OpenAI's text-embedding-3 series) allow dimension truncation — you can get 90%+ of quality at 256 dimensions, which is 6x faster ANN search and 6x smaller index.
- The embedding model's training domain matters more than its size. A model trained on general web text may underperform a smaller domain-specific model on legal, medical, or code retrieval tasks.
- MTEB leaderboard scores are computed on benchmark datasets, not your specific corpus. Always run a retrieval eval on your own data before committing to an embedding model.

### 5. Semantic Chunking: Missing Critical Parameters

**Severity: Medium**

"Semantic chunking" is underspecified. The key questions:

- What is your breakpoint threshold? Most implementations use cosine distance between adjacent sentence embeddings, with a threshold around 0.3-0.5. Too aggressive (low threshold) = tiny fragments that lack context; too permissive (high threshold) = chunks too large for effective retrieval.
- Are you preserving document structure? Headers, section titles, and metadata should be embedded into the chunk text (e.g., prepend "Section: Introduction" to each chunk from that section), not stripped out. This significantly improves retrieval for structured documents.
- Are chunks too long for your embedding model's context window? Many embedding models have a 512-token limit. Chunks exceeding this are silently truncated, losing the tail of every long chunk.

### 6. Chroma in Production: Scalability Consideration

**Severity: Low (depends on scale)**

Chroma is suitable for development and small-to-medium corpora (<1M vectors). At scale, its HNSW index does not support incremental updates efficiently — you need to rebuild the index after large batch inserts. If you expect >500K documents or >100 QPS, consider Weaviate, Qdrant, or Pinecone, which have production-grade distributed ANN with better concurrent write/read support.

---

## Summary of Recommendations

| Issue | Fix |
|-------|-----|
| Raw score addition | Replace with RRF or per-query normalized weighted sum |
| Recall set too large | Reduce to 50-100 candidates; rerank top 20-30 |
| Faithfulness-only eval | Add Context Recall + Context Precision + Answer Relevancy |
| Max-dim assumption | Benchmark your specific domain; try MRL truncation |
| Chunking underspecified | Tune breakpoint threshold; preserve structure; check token limits |
| Chroma at scale | Fine for now; plan migration path at >500K vectors |

The most impactful change is fixing the hybrid scoring (issue 1) and expanding the eval suite (issue 3). The 0.8 Faithfulness score is unlikely to be the binding constraint — Context Recall is almost certainly lower and currently invisible.
