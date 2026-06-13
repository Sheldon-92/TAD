# Phase 5 Behavioral Discriminative Eval — rag-retrieval

**Date**: 2026-06-13
**Pack**: rag-retrieval (v0.1.0)
**Fixture**: `.claude/skills/rag-retrieval/examples/rag-retrieval-fixture.md` (`rag-pipeline-review`)
**Eval type**: discriminative (with-pack vs control)

---

## Fixture parameters

- **discriminative_pattern**:
  ```
  recursive.?512|< ?55%|69%|RRF|k ?= ?60|471 QPS|11\.4|top.?50|120\s?ms|[Ff]aithfulness ?= ?1|gte-reranker-modernbert|pgvectorscale|35%|49%|67%|rerank.?2\.5|7\.94|32K|1\.02
  ```
- **min_discriminative**: 4
- **Scenario**: Naive RAG over quarterly financial reports — semantic chunking, max-dimension embedding, Chroma, BM25+cosine raw-sum ranking, top-200 Cohere rerank, Faithfulness 0.8.

---

## Method

1. Produced a WITH-PACK answer by applying SKILL.md judgment rules (CH4, HR3, HR5, HR6, CH8, VD2, RE2 cross-cutting) to the scenario.
2. Produced a CONTROL answer as a generalist with NO pack — standard RAG advice from general knowledge.
3. Applied the discriminative pattern: `grep -oE PATTERN | sort -u | wc -l` against each answer.

Inputs preserved: `_withpack.md`, `_control.md` (same directory).

---

## Results

| Answer | Distinct discriminative markers | >= min (4)? |
|--------|--------------------------------|-------------|
| WITH-PACK | **19** | YES |
| CONTROL | **0** | NO |

**WITH-PACK matched markers** (sort -u):
`< 55%`, `1.02`, `11.4`, `120ms`, `32K`, `35%`, `471 QPS`, `49%`, `67%`, `69%`, `7.94`, `Faithfulness = 1`, `Faithfulness=1`, `k=60`, `pgvectorscale`, `recursive-512`, `rerank-2.5`, `RRF`, `top-50`

**CONTROL matched markers**: none. The control answer used only generic RAG vocabulary ("better chunking", "hybrid search", "normalize scores", "improve evaluation", "Cohere is strong") and produced zero pack-specific benchmarked numbers or named rules.

---

## Verdict

**discriminative_pass = TRUE**

- with-pack disc (19) >= min_discriminative (4) ✅
- control disc (0) < min_discriminative (4) ✅

The pack is discriminative: its specific benchmarked numbers and named rules (recursive-512=69% vs <55%, RRF k=60, pgvectorscale 471 QPS / 11.4x, top-50 @ 120ms, Faithfulness=1.0, Contextual Retrieval 35/49/67% + $1.02/M, Voyage rerank-2.5 +7.94% / 32K) do not appear in a generalist answer. The control correctly accepted "Cohere is best" and called Faithfulness 0.8 "decent" — exactly the failures the pack corrects.
