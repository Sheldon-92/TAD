---
name: rag-pipeline-review
description: "Tests recursive-512 vs semantic benchmark + RRF k=60 (not raw-score sum) + pgvector 11.4x + Faithfulness=1.0 gate + top-50 reranker latency + Contextual Retrieval 35-67% + Voyage rerank-2.5 vs Cohere on a naive RAG pipeline"
pack: rag-retrieval
tests_rules:
  - "CH1/CH4: recursive-512 (69%) beats semantic (<55%) under equal budget"
  - "CH8: Contextual Retrieval prepends 50-100 token context before embed+BM25 — cuts top-20 failure 35-67%"
  - "HR3: never sum raw BM25+cosine — fuse by rank with RRF k=60"
  - "VD2: pgvector + pgvectorscale = 471 QPS @ 99% recall, 11.4x Qdrant"
  - "HR5: Voyage rerank-2.5 beats Cohere v3.5 +7.94%, 32K context"
  - "HR6: cap candidate pool ≤50 for 120ms P95"
  - "RE7: Faithfulness ≠ correctness; RAGAS/DeepEval/TruLens framework selection"
  - "Cross-Cutting / RE2: domain-tiered Faithfulness gate (0.8 fails the ~0.85 general / ~0.90 regulated-financial floor; 1.0 aspirational); split retrieval vs generation"
min_marker_count: 4
# DISCRIMINATIVE gate: ONLY pack-specific numbers / named rules from findings + Batch-4 refresh.
# Excludes generic RAG vocabulary (chunk, embedding, vector, retrieval, rerank) and
# words from the input scenario. A no-pack agent would describe a RAG pipeline but
# would NOT produce these specific benchmarked numbers (69%, <55%, k=60, 471 QPS,
# 11.4x, top-50, 120ms, Faithfulness=1.0, 35/49/67% contextual-retrieval failure
# reductions, +7.94% Voyage-vs-Cohere) or the named fusion rule.
discriminative_pattern: "recursive.?512|< ?55%|69%|RRF|k ?= ?60|471 QPS|11\\.4|top.?50|120\\s?ms|[Ff]aithfulness ?= ?1|gte-reranker-modernbert|pgvectorscale|35%|49%|67%|rerank.?2\\.5|7\\.94|32K|1\\.02"
min_discriminative: 4
---

# Fixture: Naive RAG Pipeline Review

## Input Scenario

"Here's my RAG setup over a corpus of quarterly financial reports: I split docs with semantic chunking, embed each chunk as-is with a big model for max dimensions, store in Chroma, then I add the BM25 score and the cosine score together to rank, take the top 200, rerank all of them with Cohere because it's the best, and my eval gives a Faithfulness of 0.8 which seems fine. Review my pipeline."

## Expected Markers

When an AI agent processes the Input Scenario with the rag-retrieval pack loaded,
the output MUST contain these markers (grep-verifiable):

1. **Recursive-512 beats semantic benchmark** [structural]: the agent rejects semantic chunking with the specific benchmark numbers, not a vague "semantic is risky"
   grep pattern: `recursive.?512|69%|< ?55%`
2. **RRF k=60, not raw-score sum** [structural]: the agent flags that summing unbounded BM25 with bounded cosine is invalid and prescribes RRF with the k=60 default
   grep pattern: `RRF|k ?= ?60|reciprocal rank fusion|unbounded`
3. **pgvector scale fact**: the agent cites the pgvector + pgvectorscale benchmark over Chroma/Qdrant
   grep pattern: `471 QPS|11\.4|pgvectorscale`
4. **Reranker candidate-pool cap**: the agent caps the pool at ≤50 for the 120ms P95 budget instead of reranking top-200
   grep pattern: `top.?50|≤ ?50|120\s?ms`
5. **Domain-tiered Faithfulness gate** [structural]: the agent rejects Faithfulness 0.8 as below the domain floor (financial reports → ~0.90 regulated; ~0.85 general) — not "fine" — and splits retrieval vs generation eval
   grep pattern: `[Ff]aithfulness ?= ?1|0\.85|0\.90|below.{0,12}(floor|threshold)|hallucinat|retrieval.{0,20}generation`
6. **Contextual Retrieval for non-self-contained financial chunks**: the agent prescribes prepending generated context before embedding+BM25 with the failure-rate reduction numbers
   grep pattern: `35%|49%|67%|contextual retrieval|1\.02`
7. **Voyage rerank-2.5 over Cohere** [structural]: the agent corrects "Cohere is best" with the SOTA reranker and its margin/context advantage
   grep pattern: `rerank.?2\.5|7\.94|32K`

At least one marker is [structural] — verifies the agent applied the rule (prescribed RRF/k=60, rejected 0.8, corrected the Cohere claim) not merely named a concept.

## Verification Command

```bash
grep -oE 'recursive.?512|< ?55%|69%|RRF|k ?= ?60|471 QPS|11\.4|top.?50|120\s?ms|[Ff]aithfulness ?= ?1|gte-reranker-modernbert|pgvectorscale|unbounded|35%|49%|67%|rerank.?2\.5|7\.94|32K|1\.02' rag-pipeline-review-output.md | sort -u | wc -l | tr -d ' '
# Expected: ≥ 4
```

## Anti-Slop Check

These markers are pack-specific (would NOT appear without the pack):
- ✅ "recursive-512 = 69% vs semantic < 55%" (the pack's specific benchmark numbers under equal budget)
- ✅ "RRF k=60" (the pack's named fusion rule + industry-default smoothing constant)
- ✅ "pgvector + pgvectorscale = 471 QPS @ 99% recall, 11.4× Qdrant" (the pack's specific scale benchmark)
- ✅ "rerank top-50, not top-200, for the 120ms P95 budget" (the pack's specific latency rule)
- ✅ "Faithfulness 0.8 is below the domain floor (~0.85 general / ~0.90 regulated-financial); 1.0 aspirational" (the pack's domain-tiered production gate)
- ✅ "Contextual Retrieval: prepend 50–100 token context before embed+BM25 → 35%/49%/67% failure-rate cut, ~$1.02/M tokens" (the pack's CH8 research numbers — financial reports are the canonical non-self-contained corpus)
- ✅ "Voyage rerank-2.5 beats Cohere v3.5 +7.94% with 32K context" (the pack's HR5 SOTA correction — a no-pack agent would accept "Cohere is best")
- ❌ "use better chunking" (generic — any agent says this without the 69%/<55% numbers)
- ❌ "consider hybrid search" (generic — restates a known technique without the RRF k=60 rule)
- ❌ "your embedding model matters" (generic; no Matryoshka/dimension specificity)
- ❌ "improve your evaluation" (generic; no Faithfulness=1.0 threshold or retrieval/generation split)
