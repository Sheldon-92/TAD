# RAG Pipeline Review

**Reviewer stance:** Senior ML / retrieval engineer. Below is a stage-by-stage review of the described pipeline, with concrete problems, the reasoning behind them, and recommended fixes.

## Pipeline as described

1. Semantic chunking
2. Embed with a "big model for max dimensions"
3. Store in Chroma
4. Hybrid rank = BM25 score **+** cosine score (raw addition)
5. Take top 200
6. Rerank all 200
7. Eval reports Faithfulness = 0.8 → judged "fine"

There are several real issues here, ranging from a correctness bug (the fusion step) to evaluation gaps. Ordered roughly by severity.

---

## 1. Score fusion by raw addition is the most serious bug

`final = BM25 + cosine` adds two scores that live on completely different and unbounded scales.

- **Cosine similarity** is bounded in `[-1, 1]` (often `[0, 1]` in practice for normalized embeddings).
- **BM25** is unbounded and corpus/query dependent — typical values can range from ~2 to 30+ depending on term frequency, IDF, document length, and query length.

Adding them means **BM25 almost entirely dominates** the ranking; the cosine term becomes rounding noise. You think you have hybrid search, but you effectively have lexical (BM25) search with a negligible dense nudge. This silently defeats the purpose of embedding at all.

**Fixes (in order of preference):**

- **Reciprocal Rank Fusion (RRF):** `score = Σ 1/(k + rank_i)` with `k ≈ 60`. RRF ignores raw score magnitudes and fuses by *rank position*, which is robust and the de-facto standard for hybrid search. This is almost certainly what you want.
- **Min-max or z-score normalization per query** before a weighted sum: `α·norm(dense) + (1−α)·norm(sparse)`. This works but is more fragile (per-query normalization, tuning `α`).
- If you stay with weighted sum, **tune `α` on a labeled set** — don't assume 50/50.

I'd treat this as a must-fix. It is the single change most likely to move retrieval quality.

## 2. "Big model for max dimensions" is the wrong selection heuristic

Choosing an embedding model to maximize dimensionality is an anti-pattern.

- **More dimensions ≠ better retrieval.** Top models on MTEB at 768 or 1024 dims routinely beat larger-dimension models. Dimensionality is a capacity knob, not a quality metric.
- **Cost scales with dimensions:** storage, memory, and per-query distance computation all grow linearly. High-dim vectors also stress ANN index quality and can *hurt* recall/latency at scale.
- **Right selection criteria:** task fit (retrieval-tuned, not just an LLM's hidden states), domain/language match, MTEB *retrieval* sub-scores (not the average), max sequence length vs. your chunk size, and whether it supports Matryoshka (MRL) truncation so you can dial dimensions down without re-embedding.

**Recommendation:** Pick based on MTEB retrieval benchmarks for your domain/language, validate on *your* eval set, and prefer a model with MRL so you can trade dimensions for cost later. Confirm query/document **prefix instructions** are applied if the model requires them (e.g., `query:` / `passage:`) — forgetting these quietly tanks recall.

## 3. Semantic chunking — verify it's actually helping

Semantic chunking (embedding-similarity-based split points) is fashionable but **frequently underperforms a well-tuned fixed-size + overlap baseline**, while costing more (you embed to chunk, then embed again to store). Several public evaluations found recursive/fixed chunking with sensible overlap matches or beats semantic chunking on many corpora.

**Check / fix:**

- Run an ablation: semantic vs. recursive fixed (~256–512 tokens, 10–20% overlap). Keep semantic only if it wins on *your* eval.
- Verify chunk size is compatible with the embedding model's max sequence length (truncation = silent information loss).
- Preserve structure: don't split tables, code blocks, or list items mid-unit. Attach section/title metadata to each chunk (helps both retrieval and the reranker/LLM).
- Consider parent-document / small-to-big retrieval: retrieve on small chunks, feed larger parent context to the LLM.

## 4. top-200 → rerank-all-200: latency vs. quality tradeoff is unexamined

Reranking 200 candidates with a cross-encoder per query is **expensive** (200 query–doc forward passes) and likely overkill.

- Typical practice: retrieve top 50–100, rerank, keep top 5–10 for the LLM. Reranking 200 rarely improves end answer quality enough to justify the latency/cost, because a decent first-stage retriever already puts the relevant doc in the top ~50.
- The bigger question: **what's `k` after reranking?** You describe reranking 200 but never state how many you pass to the generator. Stuffing too many reranked chunks into the prompt causes "lost in the middle" degradation and dilutes faithfulness.

**Fix:** Sweep retrieval depth (e.g., 50/100/200) and final `k` (e.g., 3/5/8) against your eval. Pick the smallest depth and `k` that hold quality. Measure rerank latency — it's often the dominant cost in the pipeline.

Also confirm the reranker is a real **cross-encoder / LLM reranker** (e.g., a bge/mxbai/Cohere-style reranker), not just a second bi-encoder pass, otherwise it adds little over stage 1.

## 5. Chroma is fine for now, but know its ceiling

Chroma is a reasonable choice for prototyping and small/medium corpora. Watch for:

- **Native hybrid support:** if you're computing BM25 outside Chroma and fusing manually, fine — but that's more moving parts. Vector DBs with built-in BM25 + fusion (e.g., Qdrant, Weaviate, Vespa, OpenSearch) simplify this and do the fusion correctly.
- **Scale:** Chroma's performance and operational story degrade past low-millions of vectors / high QPS. Have a migration plan if the corpus grows.
- **ANN recall:** check the index params (HNSW `ef_search`/`M`). Low `ef_search` silently drops recall, and no amount of reranking recovers a relevant doc that the ANN stage never returned.

## 6. Evaluation is the weakest part — Faithfulness 0.8 alone tells you almost nothing

This is the part I'd push back on hardest. **Faithfulness only measures whether the answer is grounded in the retrieved context — it does NOT measure whether retrieval found the right context, nor whether the answer is correct or complete.**

You can score high Faithfulness while being uselessly wrong: if retrieval returns the wrong-but-coherent passages and the LLM faithfully summarizes them, Faithfulness is high and the user gets a confidently wrong answer. **Faithfulness is necessary, not sufficient.**

What's missing:

- **Retrieval metrics** (the actual subject of your review!): Recall@k, Precision@k, MRR, nDCG, **Context Recall** and **Context Precision** (Ragas). These tell you whether stages 1–6 are doing their job. Right now you have *no* retrieval metric at all — you can't see the BM25-domination bug from Faithfulness.
- **Answer-quality metrics:** Answer Relevance, Answer Correctness / answer-vs-ground-truth, completeness.
- **A labeled eval set:** ideally query → relevant-doc-IDs (for retrieval) and query → reference-answer (for generation). Without gold labels you're flying blind.
- **0.8 has no baseline.** Is 0.8 good? Compared to what? You need a baseline (e.g., dense-only, BM25-only, no-rerank) and per-query distribution, not a single aggregate. Also sanity-check the judge: LLM-as-judge faithfulness scorers have known biases and variance; calibrate against a small human-labeled subset.

**Concrete eval plan:**

1. Build/borrow a labeled set (50–200 queries to start; synthetic Q-A from your own corpus is a fine bootstrap).
2. Add **Context Recall / Context Precision / Recall@k / nDCG@k** as the primary retrieval metrics.
3. Add Answer Correctness against references.
4. Run ablations: BM25-only, dense-only, raw-sum fusion vs. RRF, rerank vs. no-rerank, semantic vs. fixed chunking. Each isolates one of the issues above.

---

## Priority summary

| # | Issue | Severity | Fix |
|---|-------|----------|-----|
| 1 | BM25 + cosine raw addition → BM25 dominates | **Critical (bug)** | Use RRF (k≈60), or normalize-then-weight + tune α |
| 6 | Eval = Faithfulness only; no retrieval/correctness metrics; no baseline | **Critical** | Add Context Recall/Precision, Recall@k, nDCG, Answer Correctness; build labeled set; ablate |
| 2 | "Max dimensions" embedding heuristic | High | Select by MTEB retrieval score + domain fit + MRL; verify query/passage prefixes |
| 4 | Rerank 200 + unspecified final k | Medium–High | Sweep depth & k; confirm true cross-encoder; watch lost-in-the-middle |
| 3 | Semantic chunking unvalidated | Medium | Ablate vs. fixed+overlap; preserve structure; add metadata |
| 5 | Chroma ceiling / ANN recall params | Medium | Check HNSW ef_search; plan scale migration; consider native-hybrid DB |

**Bottom line:** The architecture has the right *shape* (hybrid + rerank + eval), but two things make the current numbers untrustworthy: the fusion step is mathematically broken (so "hybrid" is really lexical-only), and the evaluation measures the one thing that *can't* detect that bug. Fix the fusion (RRF), add retrieval-side metrics with a labeled set and baselines, and re-measure before trusting any of the other components. The embedding-by-dimension and 200-deep rerank choices are likely wasting cost without buying quality, but those are optimizations — the fusion bug and eval blind spot are the things to fix first.
