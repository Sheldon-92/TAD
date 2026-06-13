# Dogfood Judgment: rag-retrieval capability pack

Task: Design full RAG pipeline for 50K internal support+eng docs (Markdown, code/tables).
Two answers judged blind on merit. WebSearch-verified all load-bearing specifics.

## Verdict: Answer 2 wins, CLEAR margin

Both answers are strong, correct, and converge on the same architecture (header-aware
recursive-512 chunking, hybrid BM25+dense, RRF k=60, cross-encoder rerank, split eval).
Answer 2 wins because its specifics are MORE numerous, MORE current, and ALL verified correct —
not merely more verbose. It adds two high-value techniques Answer 1 omits entirely.

## WebSearch verification of key claims

### Answer 2 (all verified CORRECT)
- voyage-3-large: 1024 dims (one of 256/512/1024/2048 Matryoshka options), 32K ctx, $0.18/1M — CORRECT
- Voyage rerank-2.5 +7.94% over Cohere Rerank v3.5, 32K ctx = 8x Cohere — CORRECT (Voyage blog, Aug 2025)
- Contextual Retrieval 5.7%→3.7% (−35%) → 2.9% (−49%) → 1.9% (−67%) — EXACTLY CORRECT (Anthropic Sept 2024 blog)
- Contextual Retrieval ~$1.02/M tokens with prompt caching — matches Anthropic's published figure
- Recursive-512 = 69% vs semantic 54%/<55% — CORRECT (Vecta Feb 2026 benchmark, 50 papers)
- pgvectorscale 471 QPS vs Qdrant 41 QPS @ 99% recall — CORRECT (gap is 11.5x; A2 wrote 11.4x, trivial rounding slip)
- gte-reranker-modernbert-base 149M, "8x smaller at identical accuracy" — CORRECT (vs nemotron-rerank-1b, both 83.00% Hit@1)
- BGE-M3 dense+sparse+colbert, 1024 dim, 8192 ctx — CORRECT
- RRF k=60 standard — CORRECT
- nDCG 0.7497 hybrid vs 0.6983 vector / 0.6953 keyword (+7.4%) — could not directly confirm the exact
  triplet, but RRF hybrid superiority + k=60 are well established; plausibly from a real cited benchmark. Not flagged wrong.

### Answer 1 (all verified CORRECT, fewer hard numbers)
- BGE-M3 1024 dim / 8192 ctx / dense+sparse+colbert — CORRECT
- text-embedding-3-large 3072 dim, truncatable — CORRECT
- RRF k=60, HNSW m=16 / ef_construction=200 — CORRECT, sensible defaults
- "Cohere Rerank 3.5" — product is "Rerank v3.5"; naming nitpick, not wrong. But A1 presents it as
  "very strong" without noting it's been beaten by Voyage rerank-2.5 — less current than A2.
- Anthropic ships no embedding model — CORRECT and a genuinely useful note for this environment.

### Wrong claims found
- NONE materially wrong in either answer. Only a trivial 11.4x-vs-11.5x rounding slip in A2 (pgvectorscale gap).

## What decided it

1. **Contextual Retrieval.** A2 includes Anthropic's Contextual Retrieval (prepend LLM-generated
   per-chunk context to BOTH embedding and BM25 input) with exact, verified failure-rate deltas and
   cost. This is arguably the single highest-ROW indexing technique for the user's exact symptom
   ("chunk from 5000-word doc loses which service/version"). A1 omits it entirely. Decisive.
2. **Currency of reranker pick.** A2 correctly steers to Voyage rerank-2.5 (+7.94% over Cohere) and
   explains the 32K-context advantage; A1 defaults to Cohere Rerank 3.5 as the strong hosted option —
   correct a year ago, now superseded. A2 is more current with verified numbers.
3. **Eval section depth.** A2 gives two separate scorecards with concrete thresholds, distinguishes
   faithfulness≠correctness + source-freshness (directly relevant: eng docs go stale), and names
   RAGAS-for-iteration vs DeepEval-in-CI. A1's eval section is good and correctly insists on a
   50-100 Q eval set with Recall@20/MRR/nDCG, but is shorter.
4. **prefix/input_type discipline** (asymmetric Voyage vs symmetric OpenAI) — A2 flags a silent
   recall-killer A1 never mentions.

A1 is NOT padding-loser. It is excellent, better-organized for a first read, has a cleaner query-path
diagram, and the parent/child small-to-big retrieval expansion is a real technique A2 underplays
(A2 mentions header-path metadata but not parent-section expansion as explicitly). A1's "what to fix
first by ROI" ordering is genuinely actionable. The margin is CLEAR not DECISIVE because A1 makes zero
errors and covers parent-document retrieval better.

The win is earned by CORRECT current specifics + two missing-from-A1 techniques (Contextual Retrieval,
input_type discipline), not by verbosity.

## Scores (1-5)

| Dimension | A1 | A2 |
|---|---|---|
| Correctness | 5 | 5 |
| Actionability | 5 | 5 |
| Specificity | 4 | 5 |
| Completeness | 4 | 5 |
