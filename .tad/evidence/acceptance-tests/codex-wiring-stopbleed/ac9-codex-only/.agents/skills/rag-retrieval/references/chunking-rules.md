# Chunking Strategy Rules
<!-- capability: chunking -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| CH1 | Recursive-512 is the default baseline — 69% accuracy, beats semantic under equal budget | deterministic |
| CH2 | Recursive splitter separator order: `["\n\n", "\n", " ", ""]` | deterministic |
| CH3 | Paginated docs with tables → Page-Level chunking (NVIDIA-2024 winner, 0.648 acc, lowest variance) | deterministic |
| CH4 | Do NOT default to Semantic chunking — < 55% under equal context budget | deterministic |
| CH5 | Semantic chunking thresholds: 95th percentile / 3σ / IQR | semi-deterministic |
| CH6 | Late Chunking for multi-page co-dependent text — needs a token-embedding endpoint; nDCG@10 gain scales with doc length, no retraining | deterministic |
| CH7 | GraphRAG ingestion chunks = 500–1000 tokens overlapping | deterministic |
| CH8 | Contextual Retrieval: prepend 50–100 token LLM-generated context before embedding AND BM25 — cuts top-20 failure rate 35–67% | deterministic |

---

## Rules

### CH1: Recursive-512 Is the Default Baseline

When no special document structure forces another choice, default to **Recursive Character Splitting at a 512-token target with 10–20% sliding-window overlap**.

In comparative testing (Gemini-2.5-flash-lite + ChromaDB + `text-embedding-3-small` over academic texts), under an **equal context budget**:

| Strategy | Retrieval Accuracy | Page-Level F1 | Document-Level F1 |
|----------|-------------------|---------------|-------------------|
| Recursive 512 | **69%** | 0.92 | 0.86 |
| Fixed 512 | 67% | 0.91 | 0.84 |
| Page-Level | 64.8% | Moderate | 0.88 |
| Semantic | **< 55%** | Low | Low |
| Proposition | Low | Low | Low |

**Rule**: Complexity does not buy accuracy. Recursive-512 preserves natural paragraph/syntactic structure without any external model calls and wins the benchmark.

> Source: findings.md "Benchmark Evaluations and Context Budgets" table + "General-Purpose High-Performance Baseline" [2, 4]

**determinismLevel**: deterministic — strategy selection is a design decision.

### CH2: Recursive Splitter Separator Hierarchy

When configuring a recursive splitter, use the prioritized separator hierarchy:

```
["\n\n", "\n", " ", ""]
```

This corresponds to paragraph breaks → line breaks → word boundaries → individual characters. The splitter applies each delimiter recursively until segments fall below the target size, preserving syntactic structure without model calls.

> Source: findings.md "Recursive Character Splitting" [1, 5]

**determinismLevel**: deterministic.

### CH3: Page-Level Chunking for Paginated Tables

When the corpus is **paginated files (PDFs) containing tables**, use Page-Level chunking (process page-by-page).

Standard parsers scatter tabular data across arbitrary boundaries. Page-Level chunking won NVIDIA's 2024 benchmarks with **accuracy 0.648 and the lowest variance** among evaluated approaches, primarily by keeping paginated tables intact.

> Source: findings.md "Page-Level and Structure-Aware Segmentation" [1]

**determinismLevel**: deterministic.

### CH4: Do NOT Default to Semantic Chunking

When tempted to use Semantic chunking because it "sounds smarter," stop. Semantic chunking embeds every sentence and splits on cosine-similarity drops — incurring **persistent API/inference calls per sentence**, and it **degraded to < 55% accuracy** (vs recursive-512's 69%) under an equal context budget on academic texts.

**Rule**: Reserve Semantic chunking for long-form, dense, unstructured text where recall (not budget) is the priority; it can improve recall by up to **9%** over simpler methods in dense unstructured texts — but never as the general-purpose default.

> Source: findings.md "Semantic and Model-Driven Segmentation" + benchmark table [1, 4]

**determinismLevel**: deterministic.

### CH5: Semantic Chunking Split Thresholds

If Semantic chunking is justified (per CH4), select one of the three split-threshold methods:

| Method | Split Trigger |
|--------|---------------|
| Percentile | Similarity difference exceeds a pre-defined percentile (typically **95th**) of the doc's global distribution |
| Standard Deviation | Similarity difference diverges **> 3σ** from the global mean |
| Interquartile Range | Outliers via the middle 50% of similarity scores — resilient to extreme localized variation |

> Source: findings.md "Semantic and Model-Driven Segmentation" [1]

**determinismLevel**: semi-deterministic — threshold method is fixed; per-document split points vary with content.

### CH6: Late Chunking for Co-Dependent Multi-Page Text

When chunks are highly co-dependent across page boundaries (the answer needs context that spans chunks), use **Late Chunking**: run the **entire unsegmented document** through a long-context embedding model FIRST to produce **token-level** vectors with bidirectional attention across the whole document, THEN split along structural boundaries and **mean-pool** the token embeddings into final chunk vectors.

**Rule**: Standard chunking splits before embedding, which severs the transformer's attention across boundaries. Late chunking preserves global context inside localized chunk vectors. **Implementation caveat**: standard embedding APIs (OpenAI, Voyage, Cohere) return ONE pooled vector per input, not token-level vectors — late chunking requires a local model / endpoint that exposes per-token hidden states (e.g., jina-embeddings late-chunking, or a self-hosted encoder). If you only have a pooled-vector API, use **contextual chunk headers, parent-document retrieval, or overlapping windows** instead.

**Grounded benchmark**: the peer-reviewed late-chunking evaluation (arXiv:2409.04701, updated Jul 2025) shows late chunking improves **nDCG@10 over naive chunking across ALL tested embedding models and datasets**, with the improvement **correlating with document length** (longer docs → larger gain) and requiring **no retraining** of the embedding model. This is a measured retrieval-quality lift, not just a mechanism — but it depends on a token-level-output encoder (see caveat above).

> Source: findings.md "Late Chunking" [1]; Günther et al., "Late Chunking: Contextual Chunk Embeddings Using Long-Context Embedding Models," arXiv:2409.04701 (updated Jul 2025), https://arxiv.org/pdf/2409.04701 (retrieved 2026-06-13)

**determinismLevel**: deterministic.

### CH7: GraphRAG Ingestion Chunk Size

When the downstream architecture is GraphRAG (entity extraction), parse documents into **overlapping chunks of 500–1000 tokens** to capture entity co-occurrence patterns before NER/relation extraction.

> Source: findings.md "GraphRAG Pipeline" + "Scaled Relational Reasoning Architecture" [34]

**determinismLevel**: deterministic.

### CH8: Contextual Retrieval — Prepend Generated Context Before Embedding AND BM25

When a chunk loses meaning once it is severed from its source document ("The company's revenue grew 3% over the previous quarter" — *which* company? *which* quarter?), apply **Contextual Retrieval**: use an LLM to generate a **chunk-specific 50–100 token explanatory context** that situates each chunk within the whole document, then **prepend that context to the chunk BEFORE you embed it AND before you build the BM25 index**. Both the dense vector and the sparse lexical index then carry the document-level disambiguation.

**Grounded numbers** (Anthropic, "Introducing Contextual Retrieval," 2026-06-13):

| Technique | Top-20 retrieval failure rate | Reduction vs naive |
|-----------|-------------------------------|--------------------|
| Naive (chunk only) | 5.7% | baseline |
| Contextual Embeddings | 3.7% | **−35%** |
| Contextual Embeddings + Contextual BM25 | 2.9% | **−49%** |
| + Reranking on top | 1.9% | **−67%** |

The one-time context-generation cost is **~$1.02 per million document tokens** when using **prompt caching** (caching the full document once, then generating per-chunk context against the cache cuts cost by up to **~90%**). Chunks stay a few hundred tokens; the prepended context adds 50–100 tokens each.

**Rule**: For any corpus where chunks are not self-contained (financial reports, legal contracts, technical docs with cross-references), prepend LLM-generated context to BOTH the embedding input AND the BM25 document **before indexing** — not at query time. Use prompt caching so the cost stays ~$1.02/M tokens. Stack reranking on top to reach the 67% failure-rate reduction. This is an indexing-time decision, so it must be made before the corpus is embedded.

> Source: Anthropic, "Introducing Contextual Retrieval," https://www.anthropic.com/news/contextual-retrieval (retrieved 2026-06-13)

**determinismLevel**: deterministic — strategy + threshold are fixed; the generated context text varies per chunk.

---

## Anti-Patterns

- **Semantic-by-default**: It is slower (per-sentence embedding) and benchmarked < 55%. Use recursive-512 unless recall-on-dense-text is the explicit goal.
- **Fixed-size with no overlap**: Splits sentences/tables/code mid-expression, degrading embedding quality. Recursive-512 with 10–20% overlap is the safer baseline.
- **Ignoring document structure**: Markdown headers, HTML tags, and code class/function boundaries are free structural separators — use structure-aware splitting for code/technical docs.
- **One chunk size for all formats**: Paginated tables → Page-Level; code → structure-aware recursive; co-dependent multi-page → Late Chunking.
- **Non-self-contained chunks shipped raw**: A chunk like "revenue grew 3% over the previous quarter" is ambiguous out of context and retrieves poorly. Apply Contextual Retrieval (CH8) — prepend 50–100 token LLM context before embedding AND BM25 — to cut top-20 failure rate 35–67%.
- **Adding context at query time instead of index time**: Contextual Retrieval prepends context BEFORE embedding/indexing; generating it per query defeats prompt caching (~$1.02/M token saving) and the BM25 lift.
