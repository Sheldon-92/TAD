# Hybrid Search, RRF & Reranking Rules
<!-- capability: hybrid_search_reranking -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| HR1 | Two-stage architecture: fast recall (BM25+dense) → cross-encoder precision | deterministic |
| HR2 | BM25 params: k1 ∈ [1.2, 2.0], b = 0.75 | deterministic |
| HR3 | Never sum raw BM25 + cosine — fuse by rank with RRF (k=60) | deterministic |
| HR4 | Over-retrieve then dedup: 30 sparse + 30 dense → k=10 | deterministic |
| HR5 | Reranker selection matrix (latency vs accuracy) | deterministic |
| HR6 | Restrict candidate pool to ≤ 50 to hold 120ms P95; top-50 ≈ 90% of top-200 gain | deterministic |
| HR7 | Sequence-classification rerankers are fast; causal-LM rerankers add latency | deterministic |

---

## Rules

### HR1: Two-Stage Retrieval Architecture

When designing retrieval, use two stages with distinct objectives:

```
Query ──► Fast Bi-Encoder (BM25 + Dense Hybrid) ──► Top 100 Candidates ──► Cross-Encoder Reranker ──► Top 10 to LLM
```

First-stage retrievers prioritize **speed and recall** (process millions of vectors, return 100–200 candidates). The second-stage **cross-encoder** feeds query and document together through attention layers for precision — slower per pair, applied only to the small candidate pool.

**Rule**: Bi-encoders (fast, independent encoding) for recall; cross-encoders (slow, joint encoding) for precision. Never run a cross-encoder over the whole corpus.

> Source: findings.md "Two-Stage Re-Ranking Pipelines" [9, 28, 29]

**determinismLevel**: deterministic.

### HR2: BM25 Parameter Defaults

When configuring the sparse retriever, set BM25 parameters to:

```
k1 ∈ [1.2, 2.0]    # term-frequency saturation
b  = 0.75          # document-length normalization
```

`k1` controls how fast a term's score contribution plateaus with repetition; `b` penalizes longer documents that contain the term by chance.

> Source: findings.md "BM25 Parameters and Scoring Dynamics" [23]

**determinismLevel**: deterministic.

### HR3: Never Sum Raw Scores — Use RRF (k=60)

When fusing sparse and dense results, **do NOT add raw BM25 and cosine scores**. BM25 scores are **unbounded positive** values; dense cosine scores fall in a tightly bounded range (e.g., [-1, 1] or [0, 1]). Summing them is mathematically invalid — **the unbounded BM25 score dominates** unless dataset-specific normalizers are hand-calibrated.

Instead use **Reciprocal Rank Fusion (RRF)**, which operates on **rank order**, bypassing normalization entirely:

```
RRF_Score(d) = Σ_m  1 / (r_m(d) + k)        k = 60 (industry default)
```

Worked example (k=60): a doc ranked 1st in keyword and 2nd in semantic →
`1/(1+60) + 1/(2+60) ≈ 0.01639 + 0.01613 = 0.03252`.
A doc ranked 3rd in keyword, absent in semantic → `1/(3+60) + 0 ≈ 0.01587` (ranks lower).

Empirical lift (WANDS e-commerce): vector 0.6983 NDCG, keyword 0.6953 NDCG, **RRF hybrid 0.7497 NDCG (+7.4%)**.

**Rule**: The smoothing constant `k = 60` prevents top-ranked items from overly dominating. Use RRF as the plug-and-play default; reserve linear combination for when you have labeled training data AND accept continuous manual re-tuning under distribution shift.

> Source: findings.md "The Score Incompatibility Problem" + "Reciprocal Rank Fusion (RRF)" + "Linear Combination Alternative" [23, 24, 25, 26]

**determinismLevel**: deterministic.

### HR4: Over-Retrieve, Then Deduplicate

When running parallel sparse + dense retrieval, **expand retrieval volume before fusion**: e.g., retrieve **30 sparse and 30 dense** candidates for a final **k=10** output, then merge and **deduplicate by unique chunk ID** before RRF.

Also apply the two query-engineering components: **Query Rewriting/Decomposition** (split user input into vector queries + keyword sequences) and **Dynamic Query Bias Upweighting** (upweight BM25 for short queries with exact serial numbers; upweight dense vectors for long descriptive queries).

> Source: findings.md "Pipeline Orchestration Requirements" [27]

**determinismLevel**: deterministic.

### HR5: Reranker Selection Matrix

When selecting a reranker, balance precision against the latency budget:

| Reranker | Architecture | Params | Notes |
|----------|--------------|--------|-------|
| **Cohere Rerank v4.0-pro** | Proprietary cross-encoder | Proprietary | High multilingual accuracy; "Nimble" fast variant; API cost + network latency |
| **Qwen3-Reranker-4B** | Causal LM | 4B | Top MTEB accuracy; autoregressive decoding latency |
| **nv-rerankqa-mistral-4b-v3** | QA cross-encoder | 4B | Benchmark QA champion; high GPU need |
| **Jina Reranker v3** | Listwise | Proprietary | 131k tokens / 64 docs together; handles relative ordering |
| **bge-reranker-v2-m3** | Cross-encoder | < 600M | Lightweight, runs on consumer hardware |
| **gte-reranker-modernbert-base** | Seq. classification (ModernBERT) | 149M | **8× smaller than 1B models with identical accuracy**; English-centric |
| **nemotron-rerank-1b** | Autoregressive prompt-based | 1.2B | High Hit@10 / MRR@10; slower than seq-classification |
| **FlashRank** | Lightweight cross-encoder | < 100M | Ultra-fast, CPU-only / edge; lower absolute accuracy |

**Rule**: For low-latency production, default to **gte-reranker-modernbert-base (149M)** — cross-encoder precision at a fraction of the size. Reserve 4B causal-LM rerankers (Qwen3, nv-rerankqa) for accuracy-first, non-realtime RAG.

> Source: findings.md "State-of-the-Art Reranker Profiles" table [9, 28, 31]

**determinismLevel**: deterministic.

### HR6: Restrict Candidate Pool to ≤ 50

When latency matters, **cap the first-stage candidate pool at ≤ 50 documents** before reranking. Reranking the **top-50 captures roughly 90% of the accuracy gain of reranking the top-200** while avoiding substantial latency. Combined with batching/parallel scoring, pinned (pre-warmed) GPU workers, and optionally **ColBERT late interaction**, this keeps end-to-end reranking under a strict **120ms P95** threshold.

**Rule**: Reranking the top-200 pays linear latency for ~10% of the marginal accuracy. Cap at 50 unless an eval proves the extra candidates matter.

> Source: findings.md "Production Latency Mitigation Strategies" [30]

**determinismLevel**: deterministic.

### HR7: Sequence-Classification vs Causal-LM Latency

When a reranker's latency is the concern, prefer the architecture, not just the size:

- **Sequence classification** (e.g., `gte-reranker-modernbert-base`): a classification head on a **single forward pass** maps the query-doc pair to a probability — fast even on light hardware.
- **Causal language modeling** (e.g., `Qwen3-Reranker-4B`): **autoregressive decoding** (scoring the logit of "yes"/"no") needs multiple sequential passes — substantially higher latency.

**Rule**: A small seq-classification model can beat a large causal-LM reranker on latency at comparable accuracy. Check the architecture, not just the parameter count.

> Source: findings.md "Latency Profiles and Structural Execution Trade-offs" [29, 31]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Raw score fusion**: Summing unbounded BM25 with bounded cosine lets BM25 dominate. Use RRF (k=60) on ranks.
- **Reranking the top-200**: Top-50 gives ~90% of the gain. Cap the candidate pool to hold the 120ms P95 budget.
- **Picking a reranker by accuracy alone**: A 4B causal-LM reranker may blow the latency budget. Match architecture (seq-classification vs causal-LM) to the latency target.
- **No over-retrieve/dedup**: Retrieving exactly k from each path before fusion under-fills the candidate pool. Over-retrieve (30+30 → 10) and dedup by chunk ID.
