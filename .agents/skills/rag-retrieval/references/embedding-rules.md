# Embedding Model Selection Rules
<!-- capability: embeddings -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| EM1 | Model-by-use-case selection matrix (Voyage 3.5 / Cohere embed-v4 / OpenAI 3-large / BGE-M3) + MTEB(v2 2026) leaders (Gemini 001 68.32 / Qwen3-8B 70.58 / Jina v5 71.7 / voyage-4) | deterministic |
| EM2 | Matryoshka truncation: 3072→512 with no significant quality loss (Wilcoxon) | deterministic |
| EM3 | Cohere embed-v4 quantization: 32× compression, ~90% storage cut, ~3% accuracy loss | deterministic |
| EM4 | Asymmetric/instruction-aware models distinguish query/doc (Voyage via `input_type=`, E5/Qwen3 via query-side instruction prefix); truly symmetric models (OpenAI 3-series) must NOT add prefixes | deterministic |
| EM5 | Voyage produces ~1.6% more tokens than OpenAI for identical text | deterministic |
| EM6 | BGE-M3 unifies dense+sparse+multi-vector in one model — single model for hybrid | deterministic |

---

## Rules

### EM1: Embedding Model Selection Matrix

When selecting an embedding model, match the use case to the grounded pick:

| Use Case | Model | Dims | Context | Cost /1M tokens |
|----------|-------|------|---------|-----------------|
| General-purpose retrieval champion | **voyage-3.5** | 1,024 default (256/512/1,024/2,048) | 32,000 | $0.060 |
| Codebases / technical docs | **voyage-3-large** | 1,024 default (256/512/1,024/2,048) | 32,000 | $0.180 |
| Legal contracts / regulatory | **voyage-law-2** | 1,024 | 16,000 | $0.120 |
| Storage-truncatable (elastic) | **text-embedding-3-large** | 3,072 (truncatable) | 8,191 | $0.130 |
| Low-latency / cost-optimized | **text-embedding-3-small** | 1,536 (truncatable) | 8,191 | $0.020 |
| Global multilingual RAG | **Cohere embed-v4** | 1,536 default (256/512/1,024/1,536, Matryoshka) | 128,000 | $0.120 |
| Self-hosted hybrid (dense+sparse) | **BGE-M3** | 1,024 | 8,192 | $0 (self-hosted) |
| High-accuracy English-only, self-hosted | **BGE-large-en-v1.5** | 1,024 | 512 | $0 (self-hosted) |

**Rule**: Cohere `embed-v4` and BGE-M3 support **100+ languages**; pick them for multilingual corpora. BGE-large-en-v1.5's **512-token** context is a hard ceiling — do not feed it longer chunks.

**Current leaderboard (MTEB v2, March 2026) — refresh layer:** the use-case matrix above stays the selection rule, but the SOTA frontier has moved one generation past voyage-3.5:

| Model | MTEB(v2) avg | Notes |
|-------|--------------|-------|
| **Jina v5-text-small** (677M) | **71.7** | Best quality-to-size — top score from a sub-1B model |
| **Qwen3-Embedding-8B** | **70.58** | Highest open-weight score; heavy to serve |
| **Gemini Embedding 001** | **68.32** (English MTEB leader; **67.71 retrieval**) | Tops the English MTEB leaderboard |
| **voyage-4** | — | MoE architecture, **~40% lower serving cost** vs prior Voyage |

⚠️ **MTEB v2 scores are NOT directly comparable to MTEB v1** (different task mix / scoring) — do **not** rank a v2 model against a v1 number. **Keep selection-by-use-case (the matrix above), not raw leaderboard rank**: a 71.7 generalist can still lose to voyage-law-2 on a legal corpus. Use the leaderboard only to know the current frontier exists, then pick by domain + context-ceiling + cost.

> Source: findings.md "Industry-Leading Embedding Models" table [6, 7, 10, 12, 13, 14, 16, 18]; MTEB(v2) March 2026 leaderboard, https://awesomeagents.ai/leaderboards/embedding-model-leaderboard-mteb-march-2026/ (retrieved 2026-06-13)

**determinismLevel**: deterministic — model selection is a design decision.

### EM2: Matryoshka Dimension Truncation

When using OpenAI `text-embedding-3-large` and storage cost matters, **truncate from 3072 down to 512 (or 256) dimensions**. It uses Matryoshka representations: slicing the first 512 floats and rescaling yields a cosine-similarity quantization error of only **~0.000001**, and a Wilcoxon non-parametric test shows **no significant difference** in retrieval quality between the 1536-dim and 512-dim variants.

**Rule**: Treat dimensions on this model as a storage knob, not a quality knob. Truncating to 512 dramatically cuts vector-DB storage with negligible accuracy impact.

> Source: findings.md "Matryoshka Representation and Dimension Truncation" [7, 8, 10]

**determinismLevel**: deterministic.

### EM3: Cohere embed-v4 Quantization

When using Cohere `embed-v4` and storage/cost is a constraint, enable its native **binary and int8 quantization**: it compresses vectors by up to **32×**, cutting downstream storage costs by up to **~90%**, at a cost of only **~3%** reduction in retrieval accuracy.

> Source: findings.md "Quantization Support" [7, 10]

**determinismLevel**: deterministic.

### EM4: Asymmetric vs Symmetric Prefix Discipline

When wiring up the embedder, respect its training symmetry:

- **Asymmetric / instruction-aware models** (Voyage AI, E5, **Qwen3-Embedding**): distinguish queries from documents. For **Voyage**, do this through the API — set `input_type="query"` or `input_type="document"` and Voyage automatically prepends its own retrieval prompt (do NOT hand-prepend `query:`/`passage:`, which double-encodes). For **E5-style open models**, use the model-documented textual prefixes (e.g., `query:` / `passage:`). For **Qwen3-Embedding**, prepend a task **instruction to the QUERY only** (vendor format `{Instruction} {Query}<|endoftext|>`, e.g. "Given a web search query, retrieve relevant passages that answer the query") and leave the document unchanged — the vendor documents a **+1–5%** retrieval gain from this, and omitting the query instruction *drops* recall ~1–5%.
- **Truly symmetric models** (OpenAI `text-embedding-3` series): MUST NOT add prefixes. Adding classic search instructions to a symmetric model can **degrade** performance on specialized legal/technical datasets.

**Rule**: A mismatched query/document convention silently lowers recall. Check the model's symmetry AND its mechanism (Voyage API `input_type` param vs E5 textual prefix vs Qwen3 query-side instruction) before wiring it. Note Qwen3-Embedding is instruction-aware/asymmetric — stripping its query instruction loses the +1–5% the convention exists to capture.

> Source: findings.md "Asymmetric vs. Symmetric Execution" [12]; Voyage embeddings API docs (`input_type`); Qwen3-Embedding model card + arXiv:2506.05176 (query-side instruction, +1–5%)

**determinismLevel**: deterministic.

### EM5: Tokenization Variance Across Vendors

When estimating token cost or comparing models, note the tokenizer differs: OpenAI uses **CL100k**, Voyage AI uses custom Hugging Face tokenizers. Voyage produces **~1.6% more tokens** than OpenAI for the identical corpus, slightly increasing processing volume and cost.

> Source: findings.md "Vocabulary and Tokenization Variance" [8]

**determinismLevel**: deterministic.

### EM6: Unified Hybrid Models Eliminate a Second Model

When the goal is hybrid (dense + sparse) retrieval, prefer a model that unifies them: **BGE-M3** produces dense, sparse (lexical), AND multi-vector (ColBERT-style) representations in a single model execution. This **eliminates running and maintaining two separate models** to achieve hybrid search. (Note: **Cohere embed-v4** is a multimodal dense embedder with quantized output types — float/int8/uint8/binary/ubinary — NOT a native sparse/multi-vector model; do not rely on it for one-pass hybrid.)

> Source: findings.md "Multilingual and Hybrid Capabilities" [10, 17]; Cohere Embed v4 API docs (embedding output types)

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **More dimensions = better**: On text-embedding-3-large, 1536→512 truncation shows no significant Wilcoxon difference. Dimensions trade storage, not quality (on Matryoshka models).
- **Prefix the wrong model**: Adding `query:`/`passage:` to a truly symmetric model (OpenAI 3-series) degrades specialized-domain retrieval. But Qwen3-Embedding is instruction-aware/asymmetric — it WANTS a query-side task instruction (+1–5%); stripping it loses recall. Match the mechanism: Voyage via `input_type=` API param (auto-prepends its prompt), E5 via literal `query:`/`passage:` prefix, Qwen3 via a query-only instruction (`{Instruction} {Query}<|endoftext|>`).
- **Ignoring context ceilings**: BGE-large-en-v1.5 caps at 512 tokens, embed-multilingual-v3.0 at 1,000 — feeding longer chunks silently truncates content.
- **Ranking by raw MTEB leaderboard position**: MTEB v2 scores (Gemini 001 68.32, Qwen3-8B 70.58, Jina v5-small 71.7) are NOT comparable to v1, and a generalist top scorer can lose to a domain model (voyage-law-2) on specialized corpora. Select by use-case, not leaderboard rank.
- **Running two models for hybrid**: BGE-M3 gives dense+sparse+multi-vector in one pass — no need to maintain a separate sparse model. (Cohere embed-v4 does NOT — it is dense-only with quantized output types.)
