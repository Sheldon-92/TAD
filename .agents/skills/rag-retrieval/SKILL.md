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

AI agents build RAG pipelines by copying a tutorial: fixed-size chunks, `text-embedding-3-small`, Chroma, top-k similarity, and a prompt. They reach for semantic chunking because it sounds advanced (it benchmarked **< 55%** vs recursive-512's **69%**). They fuse BM25 and vector scores by adding them directly (mathematically invalid — BM25 is unbounded). They rerank the top-200 (paying latency for ~10% of the accuracy gain). They never separate retrieval evaluation from generation evaluation, and they report a single blended "RAG score" with no domain-calibrated Faithfulness gate — so they can't tell whether the retriever or the generator is the problem, or whether the answer is even grounded.

This pack embeds the judgment rules retrieval engineers apply automatically — rules grounded in 2026 chunking benchmarks, embedding/reranker/vector-DB comparisons, and Ragas-style evaluation, with the specific numbers a no-pack LLM would not produce.

**Pack = retrieval judgment. Your workflow system = process constraints. No overlap.**

---

## Cross-Cutting Rule: Evaluate Retrieval and Generation Separately, and Gate Faithfulness on a Domain Threshold

> **A RAG system has two failure surfaces that MUST be measured independently: retrieval (did we fetch the right chunks?) and generation (did the answer stay grounded in them?). Never report a single blended "RAG score."** Retrieval is measured with reference-based IR metrics (Precision@k, Recall@k, MRR, nDCG@k) or LLM-judged Context Precision/Recall. Generation is measured with Faithfulness/Groundedness and Answer Relevance. **Faithfulness is the fraction of answer claims supported by the retrieved context; the lower it is, the larger the share of unsupported (potentially fabricated) claims.** 1.0 is the *aspirational* target, but Faithfulness is a semi-deterministic LLM-judge score (run variance alone keeps a perfectly-grounded answer below 1.0), so gate on a **domain threshold averaged over the eval suite**, not a strict ==1.0: **block (P0) below ~0.85 general / ~0.90 regulated** (finance/health/legal), treat **0.85–0.99 as a P1 risk band**, and pair with Answer Relevance ≥ 0.90.
> *Source: findings.md "Rigorous Validation" + "Actionable Recommendations" [35, 36]; Ragas faithfulness docs + 2026 RAG-eval threshold guidance (0.8 general / 0.85 customer-facing / 0.9+ regulated), retrieved 2026-06-13*

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
| "RAG eval", "faithfulness", "context precision", "recall@k", "nDCG", "Ragas", "RAGAS", "DeepEval", "TruLens", "groundedness", "hallucination", "评估" | `references/rag-evaluation-rules.md` |
| "contextual retrieval", "prepend context", "chunk context", "context generation" | `references/chunking-rules.md` (CH8) |
| "full RAG pipeline", "design my RAG", "end-to-end retrieval", "build a RAG" | Load **all references** sequentially |
| User hands a concrete pipeline **config** (chunker/embedder/vectorDB/fusion/reranker/eval thresholds) and wants a deterministic check | Run `scripts/rag-config-lint.sh <config>` FIRST, then apply judgment rules to its findings |

---

## Validation Script (deterministic checks — do not hand-recompute)

When the user provides a machine-readable pipeline config, run the linter instead of mentally re-deriving the thresholds:

```bash
bash scripts/rag-config-lint.sh <path-to-pipeline-config>
```

It reads a flat `key=value` (or JSON) config and emits **P0/P1/P2** findings with grounded numbers, exiting **1 on any P0** (raw-score fusion; semantic chunking on academic *or* unspecified-doc-type corpora; Faithfulness gate below the domain floor — < 0.85 general / < 0.90 regulated), **2 on P1-only** (candidate pool > 50, eval suite < 100 queries, Faithfulness gate in the 0.85–0.99 review band), **0 when clean**. P2s cover dedicated vector DB < 100M vectors and missing Contextual Retrieval on legal/medical/academic corpora. The deterministic checks live in code (QUALITY-BAR A10) — the prose rules in `references/` remain the source of the *why* and the judgment calls the script cannot make.

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
- Generation metrics + targets: [Faithfulness ≥ domain threshold (~0.85 general / ~0.90 regulated; 1.0 aspirational), Answer Relevance≥0.90, Groundedness≥0.95]

### Pipeline Blueprint (if full design requested)
- Chunking → Embedding → Vector DB → Hybrid + RRF → Reranker → Eval gate
```

---

## Anti-Skip Table

| Excuse | Counter |
|--------|---------|
| "Semantic chunking is more advanced, let's use it" | Under equal context budget on academic docs it scored **< 55%** vs recursive-512's **69%** [4]. Complexity ≠ accuracy. Use recursive-512 as the baseline. |
| "We'll just add BM25 and vector scores together" | BM25 is unbounded; cosine is in [-1,1]. The sum is mathematically invalid and BM25 dominates [23]. Use RRF (k=60) on ranks. |
| "Rerank the top 200 for best accuracy" | In the source benchmark, reranking top-50 captured ~90% of the accuracy gain of top-200 [30]. Treat top-50 as the starting point and plot quality vs latency for your own reranker/hardware (the cited ~120ms P95 is benchmark-specific, not a portable constant). |
| "We need a dedicated vector DB at our scale" | For < 100M vectors, pgvector + pgvectorscale hit **471 QPS @ 99% recall** — **11.4× Qdrant's 41 QPS** under identical conditions [11]. Don't add a second datastore prematurely. |
| "Our RAG eval passes, ship it" | What score, on what suite? Faithfulness below your **domain threshold** (~0.85 general / ~0.90 regulated) flags elevated hallucination risk and should block [35]; 0.85–0.99 is a review band, not an automatic pass. And a single blended score hides whether retrieval or generation failed. |
| "More dimensions = better embeddings" | text-embedding-3-large truncates 3072→512 with a Wilcoxon test showing no significant quality loss [7,8] — cutting DB storage. Dimensions are a storage knob, not a quality knob here. |
| "Chunks are fine as-is, just embed them" | If chunks aren't self-contained ("revenue grew 3% last quarter" — which company/quarter?), apply Contextual Retrieval (CH8): prepend 50–100 token LLM context BEFORE embedding AND BM25 → cuts top-20 failure rate **35% → 49% (+BM25) → 67% (+rerank)** at ~$1.02/M tokens with prompt caching. |
| "Faithfulness is 0.95, the answer is correct" | Faithfulness measures grounding in the retrieved context, NOT correctness. With stale/wrong context a 0.95-faithful answer is still wrong — no framework distinguishes wrong-context from right-context [RE7]. Pair with retrieval metrics + source freshness. |
| "Cohere Rerank is the best API reranker" | Voyage rerank-2.5 beats Cohere Rerank v3.5 by **+7.94%** (lite: +7.16%) with **32K context (8× Cohere)** at no price increase [HR5]. Re-check SOTA before pinning a managed reranker. |

---

## Tool / Model Quick Reference

| Component | Grounded Pick (from research) | Why |
|-----------|-------------------------------|-----|
| Chunking baseline | Recursive Character Splitting, 512 tokens, 10–20% overlap | Highest accuracy (69%) under equal budget [4] |
| Chunking (non-self-contained chunks) | Contextual Retrieval — prepend 50–100 token LLM context before embed + BM25 | Cuts top-20 failure 35–67%; ~$1.02/M tokens cached (CH8) |
| Embedding (general) | Voyage 3.5 (frontier: voyage-4 MoE, Gemini 001, Qwen3-8B, Jina v5-small) | Retrieval champion, 32k context [10,12]; select by use-case not MTEB rank (EM1) |
| Reranker (managed API, accuracy + long ctx) | Voyage rerank-2.5 (lite if latency-bound) | +7.94% vs Cohere v3.5, 32K context (8×), no price increase (HR5) |
| Embedding (storage-truncatable) | OpenAI text-embedding-3-large → 512 dims | Matryoshka, no significant loss [7,8] |
| Embedding (self-hosted hybrid) | BGE-M3 | Native dense+sparse+multi-vector, 100+ langs, $0 [16,17] |
| Vector DB (< 100M, relational) | pgvector + pgvectorscale | 471 QPS @ 99% recall, 11.4× Qdrant [11] |
| Vector DB (petabyte/GPU) | Milvus | Billions+, DiskANN, GPU [20,21] |
| Fusion | RRF, k=60 | Rank-based, no score normalization [23,25] |
| Reranker (low-latency) | gte-reranker-modernbert-base (149M) | Cross-encoder precision, 8× smaller than 1B [31] |
| Eval | RAGAS (experiment) / DeepEval (CI/CD) / TruLens (prod) + IR metrics | Split retrieval vs generation; Faithfulness ≠ correctness (RE7) |
