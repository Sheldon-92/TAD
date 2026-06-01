## RAG / Retrieval Review: Current Pipeline

### P0 — Blocking

- [P0] Rule RE2: Faithfulness of `0.8` is not fine. Faithfulness below `1.0` means unsupported claims are appearing in answers; `0.8` implies about 1 in 5 claims is not grounded.
  → Block production until `Faithfulness = 1.00`, with `Answer Relevance >= 0.90` and `Groundedness >= 0.95`.

- [P0] Rule HR3: You are summing raw BM25 and cosine scores. BM25 is unbounded while cosine is bounded, so BM25 can dominate the ranking.
  → Use Reciprocal Rank Fusion instead: `RRF_Score(d) = sum(1 / (rank + 60))`, with `k=60`.

### P1 — Required

- [P1] Rule CH4: Semantic chunking is a weak default. It benchmarked `<55%` accuracy under equal context budget, while recursive-512 reached `69%`.
  → Start with Recursive Character Splitting at `512 tokens` and `10–20%` overlap. Use separator order from CH2: `["\n\n", "\n", " ", ""]`.

- [P1] Rule VD1: Chroma is a prototyping vector DB, suitable under roughly `1M` vectors. It is not the right default for a production or multi-million-vector corpus.
  → If under `100M` vectors and you already use Postgres, prefer `pgvector + pgvectorscale`; benchmark cited `471 QPS @ 99% recall` on `50M` vectors.

- [P1] Rule HR6: Reranking top `200` is likely wasting latency. Top-50 captures roughly `90%` of the accuracy gain of top-200 in the cited benchmark.
  → Cap reranking candidates at `<=50` unless your eval proves top-200 materially improves quality.

- [P1] Rule RE1: Your eval is only reporting generation faithfulness. That hides whether the root failure is retrieval or generation.
  → Split eval into retrieval metrics and generation metrics. Do not use one blended RAG score.

### P2 — Advisory

- [P2] Rule EM2: “Big model for max dimensions” is not automatically better. With `text-embedding-3-large`, truncating `3072 -> 512` dimensions showed no significant quality loss, with cosine error around `0.000001`.
  → Treat dimensions as a storage/cost knob, not a quality knob. If using OpenAI 3-large, evaluate `512` dims before storing full `3072`.

- [P2] Rule HR4: The pipeline should over-retrieve separately before fusion, then deduplicate.
  → Start with something like `30 BM25 + 30 dense -> dedupe by chunk ID -> RRF -> final top 10`.

### Retrieval vs Generation Split

- Retrieval targets: `Precision@k >= 0.70` for narrow domains, `Recall@20 >= 0.80`, `MRR >= 0.85`, `nDCG@10 >= 0.80`.
- LLM-judge retrieval targets: `Context Precision >= 0.85`, `Context Recall >= 0.90`.
- Generation targets: `Faithfulness = 1.00`, `Answer Relevance >= 0.90`, `Groundedness >= 0.95`.

Pipeline fix: Recursive-512 chunking → right-sized embedding dims → production-grade vector store → BM25+dense with RRF `k=60` → rerank `<=50` candidates → top 10 to LLM → separate retrieval and generation eval gates.
