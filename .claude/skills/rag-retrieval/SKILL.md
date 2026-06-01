---
name: rag-retrieval
description: RAG & retrieval engineering capability pack. Gives AI agents the judgment rules a senior retrieval engineer applies automatically — chunking strategy selection, embedding model choice, vector database routing, hybrid search with Reciprocal Rank Fusion, two-stage cross-encoder reranking, GraphRAG, and reference-based + LLM-as-judge RAG evaluation. Research-grounded rules with specific numbers from chunking benchmarks, embedding/reranker/vector-DB comparisons, and Ragas-style evaluation. Use for any RAG pipeline design, retrieval quality debugging, chunking/embedding/vector-DB selection, hybrid search fusion, reranker selection, or RAG eval task.
keywords: ["RAG", "检索增强", "retrieval", "检索", "chunking", "分块", "embedding", "嵌入", "向量数据库", "vector database", "reranker", "重排序", "hybrid search", "混合检索", "RRF", "BM25", "pgvector", "GraphRAG", "faithfulness", "向量检索"]
type: reference-based
---

**CONSUMES**: User RAG/retrieval task + corpus description (size, format, language, domain) + optional existing pipeline config (chunker, embedder, vector DB, reranker, eval suite)
**PRODUCES**: Applied retrieval judgment rules + chunking strategy decision + embedding model selection + vector DB routing + hybrid-search/RRF config + reranker selection + RAG eval suite with target thresholds

# RAG & Retrieval Engineering Capability Pack

**Version**: 0.1.0
**Compatibility**: Claude Code (Phase 1); Codex / Cursor / Gemini in Phase 3
**License**: Apache 2.0

---

## What This Pack Does

AI agents build RAG pipelines by copying a tutorial: fixed-size chunks, `text-embedding-3-small`, Chroma, top-k similarity, and a prompt. They reach for semantic chunking because it sounds advanced (it benchmarked **< 55%** vs recursive-512's **69%**). They fuse BM25 and vector scores by adding them directly (mathematically invalid — BM25 is unbounded). They rerank the top-200 (paying latency for ~10% of the accuracy gain). They never separate retrieval evaluation from generation evaluation, and they ship at Faithfulness 0.8 thinking it's "good enough" — it means 1 in 5 claims is hallucinated.

This pack embeds the judgment rules retrieval engineers apply automatically — rules grounded in 2026 chunking benchmarks, embedding/reranker/vector-DB comparisons, and Ragas-style evaluation, with the specific numbers a no-pack LLM would not produce.

**Pack = retrieval judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Evaluate Retrieval and Generation Separately, and Faithfulness Below 1.0 Means Hallucination

> **A RAG system has two failure surfaces that MUST be measured independently: retrieval (did we fetch the right chunks?) and generation (did the answer stay grounded in them?). Never report a single blended "RAG score."** Retrieval is measured with reference-based IR metrics (Precision@k, Recall@k, MRR, nDCG@k) or LLM-judged Context Precision/Recall. Generation is measured with Faithfulness/Groundedness and Answer Relevance. **Any Faithfulness score below 1.0 means the model is fabricating or relying on parametric memory rather than the retrieved context** — gate production deployments on Faithfulness = 1.0 and Answer Relevance ≥ 0.90.
> *Source: findings.md "Rigorous Validation" + "Actionable Recommendations" [35, 36]*

This rule applies to every RAG eval, every "why is my RAG wrong?" debug (always split: bad retrieval vs bad generation), and every production gate. It is surfaced here because a blended score hides whether the retriever or the generator is the problem — and that determines the entire fix.

---

## Step 0: Context Detection

When the user mentions RAG/retrieval work, detect the context and load the right reference:

| User Signal | Reference to Load |
|-------------|-------------------|
| "chunking", "chunk size", "splitting", "semantic chunk", "late chunking", "page-level", "分块", "切分" | `references/chunking-rules.md` |
| "embedding model", "voyage", "cohere embed", "bge", "text-embedding-3", "dimensions", "Matryoshka", "嵌入模型" | `references/embedding-rules.md` |
| "vector database", "pgvector", "Qdrant", "Pinecone", "Milvus", "HNSW", "IVFFlat", "metadata filter", "向量数据库" | `references/vector-database-rules.md` |
| "hybrid search", "BM25", "RRF", "reciprocal rank fusion", "reranker", "rerank", "cross-encoder", "混合检索", "重排序" | `references/hybrid-rerank-rules.md` |
| "GraphRAG", "knowledge graph", "multi-hop", "entity", "relationship", "Leiden", "图谱", "多跳" | `references/graphrag-rules.md` |
| "RAG eval", "faithfulness", "context precision", "recall@k", "nDCG", "Ragas", "groundedness", "hallucination", "评估" | `references/rag-evaluation-rules.md` |
| "full RAG pipeline", "design my RAG", "end-to-end retrieval", "build a RAG" | Load **all references** sequentially |

---

## Step 1: Apply Rules

After loading the relevant reference file(s):

1. **Read the reference completely** — do not skim
2. **Apply each rule as a judgment check** against the user's pipeline, config, or request
3. **For each violated rule**: state the violation clearly, then give the specific fix with the grounded number/command
4. **Enforce the Cross-Cutting Rule** on every eval setup and every retrieval-quality debug — split retrieval vs generation before recommending a fix
5. **Always cite the specific threshold/number** from the reference — a recommendation without the grounded number is generic advice the user could have gotten from any LLM

Output format per finding:
```
[P0] Rule CH4 (chunking): Pipeline uses semantic chunking on academic docs — benchmarked < 55% accuracy vs recursive-512's 69% under equal context budget.
→ Switch to Recursive Character Splitting at 512 tokens with 10–20% overlap.

[P1] Rule HR3 (hybrid): BM25 and cosine scores are summed directly. BM25 is unbounded; it dominates the fusion.
→ Fuse by rank with RRF (k=60), not by raw score.
```

---

## Step 2: Output

Produce a structured retrieval review:

```
## RAG / Retrieval Review: [pipeline or stage reviewed]

### P0 — Blocking (will produce wrong or hallucinated results)
- [finding + specific fix + grounded number]

### P1 — Required (fix before trusting retrieval quality)
- [finding + specific fix + grounded number]

### P2 — Advisory (improves quality/latency/cost)
- [finding + specific fix + grounded number]

### Retrieval vs Generation Split (Cross-Cutting Rule)
- Retrieval metrics + targets: [Precision@k / Recall@k / MRR / nDCG@k / Context Precision/Recall]
- Generation metrics + targets: [Faithfulness=1.0, Answer Relevance≥0.90, Groundedness≥0.95]

### Pipeline Blueprint (if full design requested)
- Chunking → Embedding → Vector DB → Hybrid + RRF → Reranker → Eval gate
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "Semantic chunking is more advanced, let's use it" | Under equal context budget on academic docs it scored **< 55%** vs recursive-512's **69%** [4]. Complexity ≠ accuracy. Use recursive-512 as the baseline. |
| "We'll just add BM25 and vector scores together" | BM25 is unbounded; cosine is in [-1,1]. The sum is mathematically invalid and BM25 dominates [23]. Use RRF (k=60) on ranks. |
| "Rerank the top 200 for best accuracy" | Reranking top-50 captures ~90% of the accuracy gain of top-200 while staying under the 120ms P95 budget [30]. |
| "We need a dedicated vector DB at our scale" | For < 100M vectors, pgvector + pgvectorscale hit **471 QPS @ 99% recall** — **11.4× Qdrant's 41 QPS** under identical conditions [11]. Don't add a second datastore prematurely. |
| "Our RAG eval passes, ship it" | What score? Faithfulness below **1.0** means hallucination [35]. And a single blended score hides whether retrieval or generation failed. |
| "More dimensions = better embeddings" | text-embedding-3-large truncates 3072→512 with a Wilcoxon test showing no significant quality loss [7,8] — cutting DB storage. Dimensions are a storage knob, not a quality knob here. |

---

## Tool / Model Quick Reference

| Component | Grounded Pick (from research) | Why |
|-----------|-------------------------------|-----|
| Chunking baseline | Recursive Character Splitting, 512 tokens, 10–20% overlap | Highest accuracy (69%) under equal budget [4] |
| Embedding (general) | Voyage 3.5 | Retrieval champion, 32k context [10,12] |
| Embedding (storage-truncatable) | OpenAI text-embedding-3-large → 512 dims | Matryoshka, no significant loss [7,8] |
| Embedding (self-hosted hybrid) | BGE-M3 | Native dense+sparse+multi-vector, 100+ langs, $0 [16,17] |
| Vector DB (< 100M, relational) | pgvector + pgvectorscale | 471 QPS @ 99% recall, 11.4× Qdrant [11] |
| Vector DB (petabyte/GPU) | Milvus | Billions+, DiskANN, GPU [20,21] |
| Fusion | RRF, k=60 | Rank-based, no score normalization [23,25] |
| Reranker (low-latency) | gte-reranker-modernbert-base (149M) | Cross-encoder precision, 8× smaller than 1B [31] |
| Eval | Ragas-style + IR metrics | Split retrieval vs generation [35] |
