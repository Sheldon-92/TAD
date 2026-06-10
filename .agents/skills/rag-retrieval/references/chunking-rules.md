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
| CH6 | Late Chunking for multi-page co-dependent text — needs a token-embedding endpoint; else use contextual headers/parent-doc | deterministic |
| CH7 | GraphRAG ingestion chunks = 500–1000 tokens overlapping | deterministic |

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

> Source: findings.md "Late Chunking" [1]

**determinismLevel**: deterministic.

### CH7: GraphRAG Ingestion Chunk Size

When the downstream architecture is GraphRAG (entity extraction), parse documents into **overlapping chunks of 500–1000 tokens** to capture entity co-occurrence patterns before NER/relation extraction.

> Source: findings.md "GraphRAG Pipeline" + "Scaled Relational Reasoning Architecture" [34]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Semantic-by-default**: It is slower (per-sentence embedding) and benchmarked < 55%. Use recursive-512 unless recall-on-dense-text is the explicit goal.
- **Fixed-size with no overlap**: Splits sentences/tables/code mid-expression, degrading embedding quality. Recursive-512 with 10–20% overlap is the safer baseline.
- **Ignoring document structure**: Markdown headers, HTML tags, and code class/function boundaries are free structural separators — use structure-aware splitting for code/technical docs.
- **One chunk size for all formats**: Paginated tables → Page-Level; code → structure-aware recursive; co-dependent multi-page → Late Chunking.
