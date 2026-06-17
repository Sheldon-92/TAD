# Pack Dogfood Judgment -- rag-retrieval

**Task**: Review a RAG pipeline over quarterly financial reports: semantic chunking, max-dimension embedding, Chroma, raw BM25+cosine addition for hybrid search, top-200 to Cohere reranker, Faithfulness 0.8 "seems fine."

**Date**: 2026-06-16
**Judge**: independent technical judge (blind to which answer used the skill)

---

## Verification of key specific claims (WebSearch against primary docs)

| Claim | Answer | Verdict | Source |
|-------|--------|---------|--------|
| BM25 unbounded, cosine [-1,1], raw addition means BM25 dominates | Both | CORRECT | standard IR textbook; both explain correctly |
| RRF formula: RRF(d) = sum(1/(k + rank_i(d))), k=60 is standard | Both | CORRECT | Cormack et al. 2009 SIGIR; confirmed as cross-vendor default (OpenSearch, Azure, Elasticsearch, Weaviate) |
| RRF on WANDS: vector 0.6983, keyword 0.6953, RRF hybrid 0.7497 (+7.4%) | A2 | PARTIALLY MISLEADING | The 0.7497 is from BOOSTED RRF (name-field boosting), not plain RRF. Plain RRF = 0.7068. The individual vector/keyword numbers are correct. A2 presents 0.7497 as the RRF result, but it is the boosted-RRF result. Not wrong per se (RRF is the fusion method used), but conflates tuned vs baseline. Source: Doug Turnbull March 2025 WANDS benchmarks |
| Semantic chunking < 55% accuracy vs recursive-512 at 69% | A2 | CORRECT | Feb 2026 benchmark of 7 strategies across 50 academic papers; semantic chunking at 54% (43-token fragments), recursive-512 at 69% |
| Cohere charges "per document per search. 200 docs x N queries adds up" | A1 | WRONG | Cohere charges PER SEARCH (per query), not per document. Up to 100 doc chunks per query on Bedrock. 200 docs = 2 queries, not 200 billable units. The cost concern is directionally valid (more docs = more latency) but the pricing claim is factually wrong. Source: Cohere pricing docs, OpenRouter, AWS Bedrock |
| Voyage rerank-2.5 beats Cohere Rerank v3.5 by +7.94% on 93 datasets | A2 | CORRECT | Voyage AI blog (Aug 2025): "+7.94% accuracy improvement over Cohere Rerank v3.5" on 93 retrieval datasets |
| Voyage rerank-2.5 32K context, 8x Cohere v3.5's 4K | A2 | CORRECT | Voyage AI docs confirm 32K; Cohere v3.5 = 4K confirmed |
| Cohere Rerank v4.0 (rerank-v4.0-pro/fast) has shipped since v3.5 | A2 | CORRECT | Released Dec 11, 2025 per Cohere changelog and VentureBeat |
| rerank-2.5-lite beats Cohere v3.5 by +7.16% | A2 | CORRECT | Voyage AI blog Aug 2025 |
| gte-reranker-modernbert-base: 149M params, 8x smaller than 1B models with identical accuracy | A2 | CORRECT (with nuance) | 149M confirmed. Vs nemotron-rerank-1b (1.2B): same Hit@1 (83.00%), nemotron edges on MRR@10 (0.8514 vs 0.8483). "Identical" is slightly generous but Hit@1 match is real |
| text-embedding-3-large at 3072 dims truncate to 512 "no significant quality loss (Wilcoxon test)" | A2 | IMPRECISE | The Wilcoxon test was applied to 1536 vs 512 dimensions (not 3072 vs 512). The general claim that 512 is sufficient holds, but the specific Wilcoxon test attribution to 3072->512 is wrong. Source: Chris Thomas blog (Oct 2025) |
| Matryoshka 512 quantization error ~0.000001 | A2 | CORRECT | Confirmed in Medium article on Matryoshka embeddings experiments |
| Contextual Retrieval cuts top-20 failure rate by 35% (embeddings alone), 49% (+BM25), 67% (+reranking) | A2 | CORRECT | Anthropic's Contextual Retrieval blog (2024): from 5.7% to 3.7% (35%), to 2.9% (49%), to 1.9% (67%) |
| Contextual Retrieval cost ~$1.02/M document tokens with prompt caching | A2 | CORRECT | Anthropic cookbook confirms for 800-token chunks in 8K-token documents |
| NVIDIA 2024 page-level chunking won at 0.648 accuracy, lowest variance | A2 | CORRECT | NVIDIA RAG benchmarks: page-level = 0.648 accuracy, stdev 0.107, across 5 datasets |
| pgvector+pgvectorscale 471 QPS @ 99% recall, 11.4x Qdrant | A2 | CORRECT | May 2025 benchmarks widely cited; 50M vectors, DiskANN+SBQ |
| voyage-law-2: 1024 dims, $0.12/M tokens | A2 | CORRECT | Pinecone docs show 1024 default dim; pricing confirmed at $0.12/M tokens |
| Voyage 3.5: 1024 dims, 32K context, $0.06/M tokens | A2 | PARTIALLY WRONG | Voyage 3.5 default is 2048 dims (not 1024), supports 256/512/1024/2048. Price $0.06/M and 32K context are correct |
| Faithfulness 0.8 = 20% claims unsupported -- serious for financial data | Both | CORRECT | Standard interpretation of Faithfulness metric |
| A1: "text-embedding-3-large at 1024 or even 768 dims often matches or beats 3072" | A1 | DIRECTIONALLY CORRECT | General consensus, though the specific "768" cutpoint is not a standard Matryoshka dim for this model (OpenAI API accepts arbitrary dims, but standard benchmarks use 256/512/1024/3072) |
| A1: Chroma uses "brute-force or HNSW" | A1 | CORRECT | Chroma uses HNSW (via hnswlib) by default; brute-force fallback for small collections |

**Wrong-claim tally:**
- A1: 1 hard-wrong (Cohere pricing "per document per search")
- A2: 1 imprecise (Wilcoxon test was 1536->512 not 3072->512), 1 partially misleading (WANDS 0.7497 is boosted-RRF not plain RRF), 1 partially wrong (Voyage 3.5 default is 2048 dims not 1024)

---

## Scoring

### Answer 1

| Dimension | Score | Notes |
|-----------|-------|-------|
| Correctness | 4 | Core recommendations all correct. One factual error on Cohere pricing model. No version/benchmark numbers to verify beyond that |
| Actionability | 4 | Clear fix instructions for each issue. Concrete suggestions (RRF, top-40-50, golden eval set of 50-100 Q/A pairs). Practical priority ordering |
| Specificity | 3 | General best-practice advice without specific model names, benchmark numbers, or version references. "text-embedding-3-large at 1024 or even 768" is the most specific it gets. No alternative reranker suggestions, no chunking benchmark data |
| Completeness | 4 | Covers 6 major issues: fusion, reranker pool size, embedding dims, chunking for tables, eval gaps, Chroma scale. Misses: contextual retrieval, specific reranker alternatives, financial-domain faithfulness thresholds |

### Answer 2

| Dimension | Score | Notes |
|-----------|-------|-------|
| Correctness | 4 | Almost all specific claims verified correct. Three imprecisions noted (Wilcoxon test scope, WANDS attribution, Voyage 3.5 dims). None are catastrophically wrong -- they are imprecise attributions rather than fabrications. The core technical advice is uniformly sound |
| Actionability | 5 | Every issue has a concrete fix with specific model names, version numbers, pricing, and migration paths. Alternative models named with context windows and pricing. Eval targets quantified (>= 0.90 for finance, >= 0.85 for general). Cost estimates for contextual retrieval |
| Specificity | 5 | Cites 93-dataset benchmarks, WANDS nDCG numbers, NVIDIA chunking results, Anthropic contextual retrieval percentages, pgvectorscale QPS, model parameter counts, context window sizes, pricing per M tokens. Nearly all verified correct |
| Completeness | 5 | 11 issues across P0/P1/P2. Covers everything A1 covers plus: contextual retrieval technique, specific reranker alternatives (Voyage + self-hosted), regulated-domain faithfulness thresholds, retrieval/generation metric split with concrete targets, source-freshness for financial temporal data, eval suite sizing, page-level chunking for PDFs |

---

## Winner Determination

Answer 2 wins on every dimension except correctness (tied at 4). The margin is clear:

- **Specificity gap is decisive**: A2 provides ~20 verifiable specifics (model names, versions, benchmark numbers, pricing, context windows). A1 provides ~3. Of A2's specifics, the vast majority verified correct; the few imprecisions are attribution nuances, not fabricated claims.
- **Completeness gap is significant**: A2 covers 11 issues to A1's 6. Key additions: contextual retrieval (a directly relevant technique for financial docs with non-self-contained chunks), specific reranker alternatives with head-to-head data, regulated-domain faithfulness thresholds, temporal metadata freshness.
- **Actionability gap**: A2 gives model names you can drop into code today (voyage-rerank-2.5, gte-reranker-modernbert-base, voyage-3.5) with pricing. A1 says "alternatives exist" without naming them.
- **A1's Cohere pricing error** (per document vs per search) is a harder factual error than any of A2's imprecisions, though it does not undermine the directional advice.
- **A2's structured P0/P1/P2 severity** adds decision-making value for prioritization.

The winner wins on CORRECT specifics, not just verbosity. The benchmark numbers, model comparisons, and pricing data are overwhelmingly verified.

**Winner: Answer 2, Clear margin.**
