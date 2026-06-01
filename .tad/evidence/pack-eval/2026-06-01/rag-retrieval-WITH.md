## RAG / Retrieval Review: end-to-end pipeline (chunking → embedding → Chroma → fusion → rerank → eval)

Your pipeline has **three P0 blockers** that will produce wrong or hallucinated results, plus several required and advisory fixes. Walking it stage by stage against the grounded rules:

---

### P0 — Blocking (will produce wrong or hallucinated results)

**[P0] Rule RE2 (eval): Faithfulness 0.8 is NOT "fine" — it means 1 in 5 claims is hallucinated.**
Faithfulness = (claims supported by context) / (total claims). **Any score below 1.0 means the model is fabricating or relying on parametric memory rather than the retrieved context.** At 0.8, 20% of your answer's claims are unsupported. This is the single most dangerous "looks fine" number in your description.
→ Gate production on the composite blueprint: **Faithfulness = 1.00 (block on any value below), Answer Relevance ≥ 0.90, Groundedness ≥ 0.95.** Do not ship at 0.8. Also note: an answer can be 100% faithful yet score 0 on Answer Relevance if it never addresses the question — both must pass.

**[P0] Rule HR3 (hybrid): Adding the BM25 score and the cosine score together is mathematically invalid.**
BM25 scores are **unbounded positive** values; cosine sits in a tightly bounded range ([-1,1] or [0,1]). Summing them lets the **unbounded BM25 score dominate** the fusion entirely — your "hybrid" ranking is effectively just BM25 with cosine noise.
→ Fuse by **rank**, not raw score, using **Reciprocal Rank Fusion (RRF) with k=60** (industry default):
`RRF_Score(d) = Σ_m 1 / (r_m(d) + k)`. RRF bypasses normalization entirely. Empirical lift (WANDS): vector 0.6983 NDCG, keyword 0.6953 NDCG → **RRF hybrid 0.7497 NDCG (+7.4%)**. Reserve linear score combination only if you have labeled training data AND accept continuous manual re-tuning under distribution shift.

**[P0] Rule RE1 (eval): You are reporting a single blended generation number with no retrieval evaluation at all.**
A RAG system has two independent failure surfaces — **retrieval** (did we fetch the right chunks?) and **generation** (did the answer stay grounded?). Faithfulness only measures generation. You have zero visibility into whether your retriever is even surfacing the right context.
→ Split the eval. Add retrieval metrics with targets: **Context Precision ≥ 0.85, Context Recall ≥ 0.90** (Ragas LLM-judge, no gold set needed), or reference-based **Precision@k ≥ 0.70 / Recall@k ≥ 0.80 @ k=20 / MRR ≥ 0.85 / nDCG@k ≥ 0.80 @ k=10** if you have a gold set. When something is wrong, *Context Precision low → retriever drowning the generator in noise; Context Recall low → incomplete context.* You cannot debug a blended number.

---

### P1 — Required (fix before trusting retrieval quality)

**[P1] Rule CH4 / CH1 (chunking): Semantic chunking is the wrong default — it benchmarked < 55% vs recursive-512's 69%.**
You reached for semantic chunking because it "sounds advanced," but under an **equal context budget** on academic texts it **degraded to < 55% retrieval accuracy** versus **Recursive-512's 69%** — and it pays a persistent per-sentence embedding/API cost. Complexity does not buy accuracy.
→ Switch to **Recursive Character Splitting at a 512-token target with 10–20% sliding-window overlap**, separator hierarchy `["\n\n", "\n", " ", ""]`. Only keep semantic chunking if recall on long-form *dense unstructured* text is the explicit goal (it can add up to ~9% recall there) — not as a general default. If your corpus is paginated PDFs with tables, use **Page-Level chunking** instead (NVIDIA-2024 winner, 0.648 acc, lowest variance).

**[P1] Rule HR6 (rerank): Reranking the top-200 pays linear latency for ~10% of the marginal accuracy.**
You retrieve top-200 and rerank all of them. **Reranking the top-50 captures ~90% of the accuracy gain of top-200** while staying under a strict **120ms P95** budget. The other 150 candidates are mostly latency cost.
→ Cap the first-stage candidate pool at **≤ 50** before the cross-encoder, unless an eval *proves* the extra candidates change the answer. Combine with batched/parallel scoring and pre-warmed (pinned) GPU workers.

---

### P2 — Advisory (improves quality / latency / cost)

**[P2] Rule EM2 (embedding): "Big model for max dimensions" is a misconception — dimensions are a storage knob, not a quality knob (on Matryoshka models).**
If you're on OpenAI `text-embedding-3-large`, you can **truncate 3072 → 512 dims with no significant retrieval quality loss** (Wilcoxon test: no significant difference; cosine quantization error ~0.000001) — slashing vector-DB storage. Picking a model purely for max dimensions buys storage cost, not accuracy.
→ Pick the embedder by use case, not dimension count: **voyage-3.5** is the general retrieval champion (32k context, $0.060/1M); **voyage-3-large** for code/technical docs; **Cohere embed-v4** or **BGE-M3** for multilingual (100+ langs); **BGE-M3 / embed-v4** if you want dense+sparse in one model so you don't run a second sparse model for your hybrid stage. Also check **Rule EM4**: symmetric models (OpenAI 3-series, Qwen3) must NOT get `query:`/`passage:` prefixes; asymmetric (Voyage/E5) MUST — a mismatch silently lowers recall.

**[P2] Rule VD1 / VD2 (vector DB): Chroma is a prototyping store (< 1M vectors) — don't ship production on it.**
Chroma is for local prototyping with a ceiling around **< 1M vectors**. If this is production-bound at any real scale, you'll hit a wall.
→ For **< 100M vectors** and a team already on PostgreSQL, default to **pgvector + pgvectorscale** — it hit **471 QPS @ 99% recall on 50M vectors, 11.4× Qdrant's 41 QPS**, and unifies app data + metadata + embeddings in one ACID store (no sync pipeline). Reserve **Milvus** for petabyte/billions-scale + GPU.

**[P2] Rule HR1 / HR4 (hybrid): Confirm your two-stage architecture and over-retrieve+dedup discipline.**
Make sure stage 1 (BM25 + dense bi-encoders) is purely for fast recall and stage 2 (cross-encoder) is the precision pass — never run a cross-encoder over the whole corpus. Over-retrieve then deduplicate by unique chunk ID before fusion (e.g., 30 sparse + 30 dense → k=10). Set BM25 params `k1 ∈ [1.2, 2.0]`, `b = 0.75` (Rule HR2). For the reranker itself, prefer **gte-reranker-modernbert-base (149M)** for low-latency production (seq-classification, single forward pass, 8× smaller than 1B models at comparable accuracy) over a 4B causal-LM reranker that will blow the latency budget (Rule HR5/HR7).

---

### Retrieval vs Generation Split (Cross-Cutting Rule — mandatory)

- **Retrieval metrics + targets**: Context Precision ≥ 0.85, Context Recall ≥ 0.90 (Ragas LLM-judge); or Precision@k ≥ 0.70, Recall@k ≥ 0.80 @ k=20, MRR ≥ 0.85, nDCG@k ≥ 0.80 @ k=10 (gold set). **You currently measure none of these.**
- **Generation metrics + targets**: Faithfulness = 1.00 (block below), Answer Relevance ≥ 0.90, Groundedness ≥ 0.95. **You are at Faithfulness 0.8 — failing.**
- **Eval suite size (Rule RE6)**: Run over **100–200 representative queries** covering your real query distribution. A handful of queries is not an eval suite and cannot support a deployment gate.
- **Domain priority (Rule RE5)**: broad-domain (FAQ/general) → prioritize Recall; narrow-domain (legal/medical/code) → prioritize Precision. Tune toward the right failure mode for your corpus.

---

### Corrected Pipeline Blueprint

Recursive-512 (10–20% overlap) → use-case-matched embedder (Voyage 3.5 / BGE-M3, dims as storage knob) → pgvector+pgvectorscale (if < 100M; Chroma only for prototype) → BM25 + dense, over-retrieve 30+30, dedup → **RRF fusion k=60** → cross-encoder rerank on **top ≤ 50** (gte-reranker-modernbert-base) → top-10 to LLM → **eval split: retrieval (Context Precision/Recall) + generation (Faithfulness=1.0 gate)** over 100–200 queries.

**Bottom line:** the two changes that will move quality the most right now are (1) stop summing BM25+cosine → use RRF k=60, and (2) stop trusting Faithfulness 0.8 — it is a hallucination signal, not a passing grade. Then split your eval so you can actually tell whether retrieval or generation is failing.
