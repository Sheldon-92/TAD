# Regression Check: rag-retrieval

**Date**: 2026-06-17
**Pack version**: 0.1.0 (current SKILL.md + 6 reference files)
**Baseline**: dogfood-rag-retrieval.prev.md (2026-06-16, Answer 2 = winner, Clear margin)

---

## Methodology

1. Read the previous dogfood judgment (baseline) including the WebSearch-verified claim table
2. Read the current pack (SKILL.md + all 6 reference files)
3. Generated an answer to the same task using current pack rules
4. Compared every verified-correct specific from the baseline winner against current pack coverage

## Task

Review a RAG pipeline: semantic chunking on quarterly financial reports, max-dimension embedding, Chroma, raw BM25+cosine addition, top-200 to Cohere reranker, Faithfulness 0.8.

---

## Findings: Current Pack vs Previous Winner (Answer 2)

### All major knowledge points PRESERVED in current pack

| Knowledge Point | Previous Winner | Current Pack Location | Status |
|----------------|----------------|----------------------|--------|
| BM25 unbounded + cosine bounded = invalid fusion | Yes | HR3 | PRESERVED |
| RRF formula with k=60 | Yes | HR3 | PRESERVED |
| WANDS benchmark: 0.6983/0.6953/0.7497 | Yes | HR3 | PRESERVED |
| Semantic chunking < 55% vs recursive-512 69% | Yes | CH1, CH4 | PRESERVED |
| Voyage rerank-2.5 +7.94% over Cohere v3.5 | Yes | HR5 | PRESERVED |
| Voyage rerank-2.5 32K context, 8x Cohere v3.5 4K | Yes | HR5 | PRESERVED |
| rerank-2.5-lite +7.16% over Cohere v3.5 | Yes | HR5 | PRESERVED |
| Cohere Rerank v4.0 (pro/fast) existence | Yes | HR5 | PRESERVED |
| gte-reranker-modernbert-base 149M params, 8x smaller | Yes | HR5 | PRESERVED |
| text-embedding-3-large Matryoshka 3072->512 no sig. loss | Yes | EM2 | PRESERVED |
| Quantization error ~0.000001 | Yes | EM2 | PRESERVED |
| Contextual Retrieval 35%/49%/67% failure rate cuts | Yes | CH8 | PRESERVED |
| Contextual Retrieval ~$1.02/M tokens with caching | Yes | CH8 | PRESERVED |
| NVIDIA 2024 page-level 0.648 accuracy, lowest variance | Yes | CH3 | PRESERVED |
| pgvector+pgvectorscale 471 QPS @ 99% recall, 11.4x Qdrant | Yes | VD2 | PRESERVED |
| voyage-law-2: 1024 dims, $0.12/M tokens | Yes | EM1 | PRESERVED |
| Faithfulness domain-tiered: 0.85 general / 0.90 regulated | Yes | RE2 | PRESERVED |
| Faithfulness != correctness caveat | Yes | RE7 | PRESERVED |
| Eval framework selection (RAGAS/DeepEval/TruLens) | Yes | RE7 | PRESERVED |
| Eval suite 100-200 queries floor | Yes | RE6 | PRESERVED |
| P0/P1/P2 severity structure | Yes | Step 2 | PRESERVED |
| Wilcoxon test correctly scoped to 1536 vs 512 | Yes | EM2 | PRESERVED (fixed) |

### Minor detail from previous winner NOT in current pack

| Knowledge Point | Previous Winner | Current Pack | Impact |
|----------------|----------------|-------------|--------|
| "93 datasets" for Voyage rerank-2.5 benchmark | Verified correct | Not stated (only "+7.94%" and source URL cited) | NEGLIGIBLE -- the core claim (+7.94%) is preserved with the source URL; "93 datasets" is supplementary context |

### Pre-existing issues (NOT regressions, present in both versions)

| Issue | Notes |
|-------|-------|
| WANDS 0.7497 is boosted-RRF, not plain RRF | Both versions cite this number the same way; plain RRF = 0.7068 |
| Voyage 3.5 default dims listed as 1,024 | Previous judgment flagged actual default as 2048; current pack still says "1,024 default (256/512/1,024/2,048)" -- not a regression, same inaccuracy in both |

---

## Conclusion

**No regression found.** All knowledge that made the previous Answer 2 the clear winner is preserved in the current pack. The one missing minor detail ("93 datasets") is supplementary context that does not affect the quality of the pipeline review advice. The core rules, thresholds, benchmarks, model recommendations, and evaluation framework guidance are all intact and identically grounded.
