# Pack Dogfood Judgment -- rag-retrieval

**Task**: Review a RAG pipeline over quarterly financial reports: semantic chunking, max-dimension embedding, Chroma, raw BM25+cosine addition for hybrid search, top-200 to Cohere reranker, Faithfulness 0.8 "seems fine."

**Date**: 2026-06-17
**Judge**: independent technical judge (blind to which answer used the skill)

---

## Verification of key specific claims (WebSearch against primary docs)

| Claim | Answer | Verdict | Source |
|-------|--------|---------|--------|
| BM25 unbounded, cosine [-1,1], raw addition means BM25 dominates | Both | CORRECT | Standard IR textbook; both explain correctly |
| RRF formula: RRF(d) = sum(1/(k + rank_i(d))), k=60 is standard | Both | CORRECT | Cormack et al. 2009 SIGIR; confirmed as cross-vendor default (OpenSearch, Azure, Elasticsearch, Weaviate) |
| RRF on WANDS: vector 0.6983, keyword 0.6953, RRF hybrid 0.7497 (+7.4%) | A2 | PARTIALLY MISLEADING | The 0.7497 is from BOOSTED RRF (name-field boosting), not plain RRF. Plain RRF = 0.7068. The individual vector/keyword numbers are correct. A2 presents 0.7497 as the RRF result, conflating tuned vs baseline. Source: Doug Turnbull March 2025 WANDS benchmarks |
| Semantic chunking < 55% accuracy vs recursive-512 at 69% | A2 | CORRECT | Vecta Feb 2026 benchmark of 7 strategies across 50 academic papers; semantic = 54% (43-token fragments), recursive-512 = 69% |
| A1: Cohere "200 chunks is 2 search units per query (100 per unit). You are paying 4x what you would at top-50" | A1 | PARTIALLY WRONG | The search-unit math is correct (200 docs = 2 searches), but 50 docs = 1 search, so 200 docs = 2x cost, NOT 4x. The "4x" multiplier is wrong. Source: Cohere pricing docs |
| Voyage rerank-2.5 beats Cohere Rerank v3.5 by +7.94% on 93 datasets | A2 | CORRECT | Voyage AI blog (Aug 2025): "+7.94% accuracy improvement over Cohere Rerank v3.5" on 93 retrieval datasets |
| Voyage rerank-2.5 32K context, 8x Cohere v3.5's 4K | A2 | CORRECT | Voyage AI docs confirm 32K; Cohere v3.5 = 4,096 tokens confirmed |
| Cohere Rerank v4.0 has shipped since v3.5 | A2 | CORRECT | Released Dec 11 2025 per Cohere changelog |
| rerank-2.5-lite beats Cohere v3.5 by +7.16% | A2 | CORRECT | Voyage AI blog Aug 2025 |
| gte-reranker-modernbert-base: 149M params, 8x smaller than 1B models with identical accuracy | A2 | CORRECT (with nuance) | 149M confirmed. Vs nemotron-rerank-1b (1.2B): same Hit@1 (83.00%); nemotron edges on MRR@10 (0.8514 vs 0.8483). "Identical" is slightly generous but Hit@1 match is real |
| A2: text-embedding-3-large 3072->512 "Wilcoxon test shows no significant quality difference" | A2 | IMPRECISE | The Wilcoxon test in cited sources was 1536 vs 512 dims (not 3072 vs 512). General direction holds (512 is near full quality), but specific test attribution is wrong |
| Contextual Retrieval cuts top-20 failure rate by 35% (embeddings alone), 49% (+BM25), 67% (+reranking) | A2 | CORRECT | Anthropic Contextual Retrieval blog (2024): 5.7% -> 3.7% (35%), -> 2.9% (49%), -> 1.9% (67%) |
| Contextual Retrieval cost ~$1.02/M document tokens with prompt caching | A2 | CORRECT | Anthropic cookbook confirms for 800-token chunks in 8K-token documents |
| NVIDIA 2024 page-level chunking won at 0.648 accuracy, lowest variance | A2 | CORRECT | NVIDIA RAG benchmarks: page-level = 0.648 accuracy, stdev 0.107, across 5 datasets |
| pgvector+pgvectorscale 471 QPS @ 99% recall on 50M vectors, 11.4x Qdrant | A2 | CORRECT | May 2025 benchmarks; 50M vectors, DiskANN+SBQ |
| voyage-law-2: 1024 dims, 16K context, $0.12/M tokens | A2 | CORRECT | Pinecone docs: 1024 dims; Voyage pricing: $0.12/M; 16K context confirmed |
| voyage-3.5: 32K context, $0.06/M tokens | A2 | CORRECT | Voyage AI blog (May 2025) confirms both |
| Faithfulness 0.8 = 20% claims unsupported -- dangerous for financial data | Both | CORRECT | Standard interpretation of Faithfulness metric |
| A1: "text-embedding-3-large ... 256-1024 dimensions capture >95% of the quality" | A1 | CORRECT | Multiple sources confirm 256 dims retain ~95-97% of full-dim quality for Matryoshka models |
| A1: Chroma uses "brute-force" in some modes | A1 | MISLEADING | Chroma uses HNSW (via hnswlib) by default. The claim about "no HNSW index by default in Python client's persistent mode for older versions" is outdated/incorrect for current Chroma |
| A1: ColBERT and Cohere's docs recommend 50-100 candidates for reranking | A1 | DIRECTIONALLY CORRECT | Cohere best practices recommend tuning candidate count; "50-100" is a reasonable range but not a direct quote from ColBERT paper |
| Cohere Rerank v3.5 context window = 4,096 tokens | A2 | CORRECT | Cohere docs, Pinecone docs confirm 4,096 |

**Wrong-claim tally:**
- A1: 1 wrong (Cohere reranking "4x cost" -- actual is 2x), 1 misleading (Chroma brute-force claim for persistent mode)
- A2: 1 imprecise (Wilcoxon test scope was 1536->512, not 3072->512), 1 partially misleading (WANDS 0.7497 is boosted-RRF, not plain RRF)

---

## Scoring

### Answer 1

| Dimension | Score | Notes |
|-----------|-------|-------|
| Correctness | 4 | Core recommendations all correct. Two factual errors (4x cost claim, Chroma brute-force claim) are minor relative to overall advice quality. No model-version specifics to go wrong on |
| Actionability | 4 | Clear fix for each issue. Practical priority table. Concrete advice: "retrieve top 50, rerank, take top 5-10." But lacks specific model alternatives -- says "benchmark at 256, 512, 1024" without naming what to benchmark against |
| Specificity | 3 | General best-practice advice. No benchmark numbers, no alternative model names, no pricing data, no context-window comparisons. The most specific data point is "256-1024 dimensions capture >95% of quality" |
| Completeness | 3.5 | Covers 6 issues: fusion, reranker pool size, embedding dims, eval gaps, contextual enrichment, Chroma scale. Misses: specific reranker alternatives, semantic chunking critique (structured docs), regulated-domain faithfulness thresholds, retrieval/generation metric split, eval suite sizing, source-freshness for temporal data |

### Answer 2

| Dimension | Score | Notes |
|-----------|-------|-------|
| Correctness | 4 | Nearly all specific claims verified correct. Two imprecisions noted (Wilcoxon scope, WANDS boosted-RRF attribution). Neither is a fabrication -- both are imprecise attributions of real data. Core technical advice is uniformly sound |
| Actionability | 5 | Every issue has a concrete fix with specific model names, versions, pricing, and migration paths. Alternative models named with context windows and pricing. Eval targets quantified (>= 0.90 for finance). Cost estimates for contextual retrieval ($1.02/M tokens). Self-hosted option named (gte-reranker-modernbert-base) |
| Specificity | 5 | Cites 93-dataset benchmarks, WANDS nDCG numbers, NVIDIA chunking results, Anthropic contextual retrieval percentages, pgvectorscale QPS, model parameter counts, context window sizes, pricing per M tokens. ~20 verifiable specifics, vast majority confirmed correct |
| Completeness | 5 | 12 issues across P0/P1/P2. Covers everything A1 covers plus: contextual retrieval with grounded numbers, specific reranker alternatives (Voyage + self-hosted + Cohere v4), semantic chunking critique for structured docs with benchmark data, regulated-domain faithfulness thresholds, retrieval/generation metric split with concrete target ranges, eval suite sizing, page-level chunking for financial PDFs, source-freshness for temporal data, domain-tuned embedding model suggestion |

---

## Winner Determination

Answer 2 wins on specificity, actionability, and completeness. Correctness is tied at 4 (both have minor errors).

- **Specificity gap is decisive**: A2 provides ~20 verifiable specifics (model names, versions, benchmark numbers, pricing, context windows). A1 provides ~3. Of A2's specifics, the vast majority verified correct.
- **Completeness gap is significant**: A2 covers 12 issues to A1's 6. Key additions: contextual retrieval with Anthropic's grounded failure-rate numbers, specific reranker alternatives with head-to-head benchmark data, semantic chunking critique with NVIDIA/Vecta benchmarks, regulated-domain faithfulness thresholds, retrieval vs generation diagnostic framework.
- **Actionability gap**: A2 gives model names you can evaluate today (voyage-rerank-2.5, gte-reranker-modernbert-base, voyage-law-2, voyage-3.5) with pricing and context windows. A1 says "alternatives exist" without naming them.
- **Both answers share the same core correct advice**: fix the score fusion (use RRF), reduce candidate pool, benchmark embedding dimensions, add contextual metadata, expand eval metrics.
- **Error comparison**: A1's errors (4x cost claim, Chroma brute-force) and A2's errors (Wilcoxon scope, WANDS attribution) are comparable in severity -- both are imprecisions rather than fundamentally wrong advice.
- **A2's structured P0/P1/P2 severity classification** with rule references adds decision-making value.

The winner wins on CORRECT specifics, not just verbosity. The benchmark numbers, model comparisons, and pricing data are overwhelmingly verified against primary sources.

**Winner: Answer 2, Clear margin.**
