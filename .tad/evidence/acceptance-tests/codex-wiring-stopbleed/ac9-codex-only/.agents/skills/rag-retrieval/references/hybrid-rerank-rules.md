# Hybrid Search, RRF & Reranking Rules
<!-- capability: hybrid_search_reranking -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| HR1 | Two-stage architecture: fast recall (BM25+dense) → cross-encoder precision | deterministic |
| HR2 | BM25 params: k1 ∈ [1.2, 2.0], b = 0.75 | deterministic |
| HR3 | Never sum raw BM25 + cosine — fuse by rank with RRF (k=60) | deterministic |
| HR4 | Over-retrieve then dedup: 30 sparse + 30 dense → k=10 | deterministic |
| HR5 | Reranker selection matrix — Voyage rerank-2.5 (+7.94% vs Cohere v3.5, 32K ctx) / gte-modernbert (self-host) / latency vs accuracy | deterministic |
| HR6 | Restrict candidate pool to ≤ 50 to hold 120ms P95; top-50 ≈ 90% of top-200 gain | deterministic |
| HR7 | Seq-classification rerankers are fast; decoder-LM rerankers add latency (larger model + longer pair prompt, not extra passes) | deterministic |

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
| **Voyage rerank-2.5** | Instruction-following cross-encoder | Proprietary | **SOTA**: +7.94% over Cohere Rerank v3.5, +2.25% over Qwen3-Reranker-8B, +12.70% over Cohere on the MAIR benchmark; **32K-token context (8× Cohere v3.5)** at no price increase |
| **Voyage rerank-2.5-lite** | Instruction-following cross-encoder | Proprietary | Latency-optimized; still **+7.16% over Cohere Rerank v3.5**; 32K context; pick when rerank-2.5 latency is too high but you still want to beat Cohere |
| **Cohere Rerank 3.5** | Proprietary cross-encoder | Proprietary | ~**595–603ms avg latency/query**; multilingual; now bettered by Voyage rerank-2.5/-lite on accuracy AND context length |
| **Cohere Rerank v4.0** | Proprietary cross-encoder | Proprietary | Ships as `rerank-v4.0-pro` (SOTA quality) and `rerank-v4.0-fast` (low-latency/high-throughput); both multilingual + JSON + 32K context; API cost + network latency |
| **Qwen3-Reranker-4B** | Decoder-LM (prompt-based) | 4B | Top MTEB accuracy; **>1s/query (~4.5× nemotron latency for ~5.3pp less accuracy)** — accuracy-first only |
| **Qwen3-Reranker-8B** | Decoder-LM (prompt-based) | 8B | Highest open accuracy; Voyage rerank-2.5 still edges it by +2.25%; heaviest latency |
| **nv-rerankqa-mistral-4b-v3** | QA cross-encoder | 4B | Benchmark QA champion; high GPU need |
| **Jina Reranker v3** | Listwise | Proprietary | 131k tokens / 64 docs together; handles relative ordering |
| **bge-reranker-v2-m3** | Cross-encoder | < 600M | Lightweight, runs on consumer hardware |
| **gte-reranker-modernbert-base** | Seq. classification (ModernBERT) | 149M | **8× smaller than 1B models with identical accuracy**; English-centric |
| **nemotron-rerank-1b** | Autoregressive prompt-based | 1.2B | High Hit@10 / MRR@10; slower than seq-classification |
| **FlashRank** | Lightweight cross-encoder | < 100M | Ultra-fast, CPU-only / edge; lower absolute accuracy |

**Rule**: For self-hosted low-latency production, default to **gte-reranker-modernbert-base (149M)** — cross-encoder precision at a fraction of the size. For a managed API where accuracy + long context matter, default to **Voyage rerank-2.5** (beats Cohere v3.5 by +7.94% with 8× the context at no price increase); drop to **rerank-2.5-lite** when its latency is too high (still +7.16% over Cohere v3.5). Reserve decoder-LM rerankers (Qwen3-Reranker-4B/8B, nv-rerankqa) for accuracy-first, non-realtime RAG — Qwen3-Reranker-4B at **>1s/query** is ~4.5× the nemotron latency for ~5.3pp less accuracy, so do not reach for it under a realtime budget.

> Source: findings.md "State-of-the-Art Reranker Profiles" table [9, 28, 31]; Voyage AI, "rerank-2.5 and rerank-2.5-lite," https://blog.voyageai.com/2025/08/11/rerank-2-5/ (retrieved 2026-06-13); AIMultiple reranker latency benchmark, https://aimultiple.com/rerankers (retrieved 2026-06-13)

**determinismLevel**: deterministic.

### HR6: Restrict Candidate Pool to ≤ 50

When latency matters, **cap the first-stage candidate pool at ≤ 50 documents** before reranking. Reranking the **top-50 captures roughly 90% of the accuracy gain of reranking the top-200** while avoiding substantial latency. Combined with batching/parallel scoring, pinned (pre-warmed) GPU workers, and optionally **ColBERT late interaction**, this keeps end-to-end reranking under a strict **120ms P95** threshold.

**Rule**: Reranking the top-200 pays linear latency for ~10% of the marginal accuracy. Cap at 50 unless an eval proves the extra candidates matter.

> Source: findings.md "Production Latency Mitigation Strategies" [30]. The **top-50 ≈ 90%-of-top-200** result and the **~120ms P95** figure are from that specific benchmark (reranker/hardware/corpus-dependent) — use them as a starting point, not portable constants; plot quality vs latency on your own stack.

**determinismLevel**: deterministic.

### HR7: Sequence-Classification vs Causal-LM Latency

When a reranker's latency is the concern, prefer the architecture, not just the size:

- **Sequence classification** (e.g., `gte-reranker-modernbert-base`): a classification head on a **single forward pass** maps the query-doc pair to a probability — fast even on light hardware.
- **Decoder-only / prompt-based** (e.g., `Qwen3-Reranker-4B`): scores relevance by reading the logit of a "yes"/"no" token, which is typically **one forward pass** (or one generated token) — NOT inherently "multiple sequential passes." The latency penalty comes from the **larger generative model and the longer pair prompt**, not from repeated decoding. Measure batch latency against a seq-classification cross-encoder rather than assuming the architecture alone is slower.

**Rule**: A small seq-classification model often beats a large decoder-LM reranker on latency at comparable accuracy — but confirm with a batch-latency measurement. Check the architecture AND model/prompt size, not just the parameter count.

> Source: findings.md "Latency Profiles and Structural Execution Trade-offs" [29, 31]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **Raw score fusion**: Summing unbounded BM25 with bounded cosine lets BM25 dominate. Use RRF (k=60) on ranks.
- **Reranking the top-200**: Top-50 gives ~90% of the gain. Cap the candidate pool to hold the 120ms P95 budget.
- **Picking a reranker by accuracy alone**: A 4B causal-LM reranker may blow the latency budget — Qwen3-Reranker-4B runs >1s/query (~4.5× nemotron) for ~5.3pp less accuracy. Match architecture (seq-classification vs causal-LM) to the latency target.
- **Defaulting to an outdated API reranker**: Cohere Rerank v3.5 (~595–603ms, 4K context) is now beaten by Voyage rerank-2.5 (+7.94%) and rerank-2.5-lite (+7.16%) with 32K context at no price increase. Re-check the SOTA before pinning a managed reranker.
- **No over-retrieve/dedup**: Retrieving exactly k from each path before fusion under-fills the candidate pool. Over-retrieve (30+30 → 10) and dedup by chunk ID.
