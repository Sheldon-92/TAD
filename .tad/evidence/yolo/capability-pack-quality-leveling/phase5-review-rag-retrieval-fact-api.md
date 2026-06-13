# Phase 5 Adversarial Review — rag-retrieval — Lens: fact-api

- **Lens**: fact-api (factual / API correctness; replaces cross-model review)
- **Reviewer**: Claude Opus 4.8 (1M) subagent
- **Date**: 2026-06-13
- **Target**: `.claude/skills/rag-retrieval/` (SKILL.md + 6 references + fixture + lint script)
- **meets_bar**: **false** (3 factual/API errors, two of them behavior-changing, in version-sensitive embedding/reranker claims)

---

## Verdict

The pack is unusually well-grounded — the overwhelming majority of its load-bearing
numbers verify **exactly** against current primary sources (Voyage blog, OpenAI/Cohere
docs, Anthropic Contextual Retrieval, arXiv, AIMultiple, the awesomeagents MTEB page it
cites). But the fact-api lens found **three concrete errors** in version-sensitive
embedding/reranker specifics, two of which would cause an agent to misconfigure a model:

1. **[P1] Cohere `embed-v4` default dimensions wrong** — pack says 1024, actual 1536.
2. **[P1] Cohere Rerank v4.0 "Nimble" variant name fabricated** — "Nimble" is the
   Rerank **3** fast variant; v4.0's variants are **pro / fast**.
3. **[P0-behavioral] Qwen3-Embedding mislabeled "symmetric / MUST NOT add prefixes"** —
   Qwen3-Embedding is an **instruction-aware / asymmetric** model that *prepends an
   instruction to the query* (documented +1–5%). Following the pack would strip the
   instruction and lose recall — the exact failure EM4 claims to prevent. Appears twice
   (EM4 rule body + Anti-Patterns "Prefix everything").

Per QUALITY-BAR §6, version-sensitive reviewer findings were independently verified
against current primary docs before being recorded as P0/P1 (not blindly trusted).

---

## Findings

### [P1] EM1 — Cohere embed-v4 default dimensions = 1536, not 1024
`references/embedding-rules.md` EM1 matrix lists `Cohere embed-v4 | 1,024 | 128,000`.
Cohere docs / AWS Bedrock / Azure model card all state embed-v4's **default vector length
is 1536**, with Matryoshka outputs [256, 512, 1024, 1536]. The 128,000 context is correct;
the dimension is wrong. Fix: change dims to **1536 (Matryoshka 256/512/1024/1536)**.

### [P1] HR5 — "Nimble" fast variant attributed to Cohere Rerank v4.0 is wrong
`references/hybrid-rerank-rules.md` HR5 row: `Cohere Rerank v4.0-pro ... "Nimble" fast
variant`. Cohere's Rerank v4.0 ships as **rerank-v4.0-pro** and **rerank-v4.0-fast**.
"Nimble" was the **Rerank 3** fast model name. Fix: rename to `rerank-v4.0-fast`.
(Side note, not an error: the pack's "Voyage 32K = 8× Cohere" claim is correctly scoped to
Cohere v3.5's 4K context; Rerank v4.0 also has 32K — pack already says v3.5 explicitly, so
the comparison stays accurate.)

### [P0-behavioral] EM4 — Qwen3-Embedding wrongly classified as symmetric / no-prefix
`references/embedding-rules.md` EM4 ("Symmetric models (OpenAI text-embedding-3 series,
Qwen3): MUST NOT add prefixes") and the Anti-Pattern "Prefix everything ... symmetric model
(OpenAI/Qwen3)". Qwen3-Embedding is explicitly **instruction-aware**: the recommended input
format is `{Instruction} {Query}<|endoftext|>` with the **document left unchanged** — the
textbook asymmetric/instruction-prefixed setup, yielding a documented **+1–5%**. Telling an
agent Qwen3 "MUST NOT add prefixes" inverts the vendor's own guidance and costs recall.
Fix: move Qwen3 to the asymmetric/instruction-aware column (note: instruction goes on the
query only, doc unchanged); keep OpenAI text-embedding-3 as the symmetric example.

### [P2] EM1 — text-embedding-3 context listed as 8,000; actual max is 8,191
Minor: matrix shows `8,000` context for both 3-large and 3-small. OpenAI's documented max
input is **8191 tokens**. Rounding is harmless for guidance but technically off; tighten to
8,191 for accuracy.

### Note (not a defect) — MTEB v2 numbers match the cited source and are correctly caveated
EM1's MTEB refresh (Gemini 001 68.32, Qwen3-8B 70.58, Jina v5-small 71.7, voyage-4 MoE)
matches the pack's cited awesomeagents.ai March-2026 page. The pack correctly warns these
are NOT comparable to MTEB v1 and that Qwen3-8B's 70.58 is an MMTEB/multilingual figure
(the source flags it as a different leaderboard). Selection-by-use-case framing is sound.
No change required, but the Qwen3-8B "70.58" carries a known leaderboard-mismatch asterisk.

---

## fact_checks (each version-sensitive claim verified against current primary docs)

1. Voyage rerank-2.5 = +7.94% over Cohere v3.5, lite = +7.16%, MAIR +12.70%, 32K ctx = 8× Cohere v3.5, no price increase, released 2025-08-11 — **CONFIRMED** (blog.voyageai.com/2025/08/11/rerank-2-5/, MongoDB blog).
2. OpenAI text-embedding-3-large default 3072 dims, text-embedding-3-small 1536, Matryoshka truncation — **CONFIRMED** (OpenAI docs). Context 8191 not "8,000" — **MINOR DISCREPANCY**.
3. Cohere embed-v4 default dimension — pack says 1,024; actual **1536** (Matryoshka 256/512/1024/1536), 128k context — **WRONG (dims)**, context confirmed (Cohere docs, AWS Bedrock, Azure).
4. Cohere Rerank v4.0 variant names — pack says "Nimble" fast variant; actual **pro/fast**; "Nimble" = Rerank 3 — **WRONG** (docs.cohere.com/changelog/rerank-v4.0; cohere.com/blog/rerank-3-nimble). Rerank v3.5 ctx 4096, v4.0 ctx 32k — confirmed.
5. Voyage-3.5: 1024 default dims (256/512/1024/2048 Matryoshka), 32K context, $0.06/1M — **CONFIRMED** (blog.voyageai.com/2025/05/20/voyage-3-5/, MongoDB).
6. Qwen3-Embedding symmetry — pack says symmetric/no-prefix; actual **instruction-aware/asymmetric**, query gets instruction prefix, doc unchanged, +1–5% — **WRONG** (QwenLM/Qwen3-Embedding, arXiv 2506.05176, HF model card).
7. BGE-M3 = dense+sparse+multi-vector(ColBERT), 100+ languages, 8192 context — **CONFIRMED** (BAAI HF card, arXiv 2402.03216).
8. pgvector+pgvectorscale 471.57 QPS @ 99% recall vs Qdrant 41.47 QPS = 11.4×, 50M × 768-dim — **CONFIRMED** (tigerdata.com pgvector-vs-qdrant benchmark).
9. Anthropic Contextual Retrieval top-20 failure 5.7%→3.7% (−35%) →2.9% (−49%) →1.9% (+rerank −67%), ~$1.02/M tokens with prompt caching — **CONFIRMED** (anthropic.com/news/contextual-retrieval, multiple mirrors).
10. Late Chunking arXiv:2409.04701, Günther et al., v3 updated 7 Jul 2025, nDCG@10 gain across all models/datasets, no retraining — **CONFIRMED** (arxiv.org/abs/2409.04701).
11. DeepEval "50+ metrics", native Pytest CI/CD, RAG/agents/multi-turn/safety — **CONFIRMED** (deepeval.com docs, PyPI).
12. Qwen3-Reranker-4B >1s/query, ~4.5× nemotron latency for ~5.3pp less accuracy; seq-classification single forward pass vs decoder-LM autoregressive — **CONFIRMED** (aimultiple.com/rerankers, the pack's cited source).
13. RRF k=60 industry default, rank-based fusion (no score normalization), BM25 k1∈[1.2,2.0]/b=0.75 — **CONFIRMED** (standard IR; WANDS +7.4% lift is source-specific, scoped correctly).
14. MTEB v2 leaders (Gemini 001 68.32 / 67.71 retrieval; Qwen3-8B 70.58; Jina v5-small 71.7; voyage-4 MoE) — **MATCHES CITED SOURCE** with the pack's own "not v1-comparable" caveat; Qwen3-8B 70.58 carries an MMTEB/leaderboard-version asterisk per the source.
