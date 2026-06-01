# Embedding Model Selection Rules
<!-- capability: embeddings -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| EM1 | Model-by-use-case selection matrix (Voyage 3.5 / Cohere embed-v4 / OpenAI 3-large / BGE-M3) | deterministic |
| EM2 | Matryoshka truncation: 3072→512 with no significant quality loss (Wilcoxon) | deterministic |
| EM3 | Cohere embed-v4 quantization: 32× compression, ~90% storage cut, ~3% accuracy loss | deterministic |
| EM4 | Asymmetric models need query:/passage: prefixes; symmetric models must NOT | deterministic |
| EM5 | Voyage produces ~1.6% more tokens than OpenAI for identical text | deterministic |
| EM6 | BGE-M3 / embed-v4 unify dense+sparse+multi-vector — single model for hybrid | deterministic |

---

## Rules

### EM1: Embedding Model Selection Matrix

When selecting an embedding model, match the use case to the grounded pick:

| Use Case | Model | Dims | Context | Cost /1M tokens |
|----------|-------|------|---------|-----------------|
| General-purpose retrieval champion | **voyage-3.5** | Low (3–8× shorter) | 32,000 | $0.060 |
| Codebases / technical docs | **voyage-3-large** | Low (3–8× shorter) | 32,000 | $0.180 |
| Legal contracts / regulatory | **voyage-law-2** | Low (3–8× shorter) | 16,000 | $0.120 |
| Storage-truncatable (elastic) | **text-embedding-3-large** | 3,072 (truncatable) | 8,000 | $0.130 |
| Low-latency / cost-optimized | **text-embedding-3-small** | 1,536 (truncatable) | 8,000 | $0.020 |
| Global multilingual RAG | **Cohere embed-v4** | 1,024 | 128,000 | $0.120 |
| Self-hosted hybrid (dense+sparse) | **BGE-M3** | 1,024 | 8,192 | $0 (self-hosted) |
| High-accuracy English-only, self-hosted | **BGE-large-en-v1.5** | 1,024 | 512 | $0 (self-hosted) |

**Rule**: Cohere `embed-v4` and BGE-M3 support **100+ languages**; pick them for multilingual corpora. BGE-large-en-v1.5's **512-token** context is a hard ceiling — do not feed it longer chunks.

> Source: findings.md "Industry-Leading Embedding Models" table [6, 7, 10, 12, 13, 14, 16, 18]

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

- **Asymmetric models** (Voyage AI, E5): MUST prepend prefixes — `query:` to queries and `passage:` to documents — to optimize retrieval.
- **Symmetric models** (OpenAI `text-embedding-3` series, Qwen3): MUST NOT add prefixes. Adding classic search instructions to symmetric models can **degrade** performance on specialized legal/technical datasets.

**Rule**: A mismatched prefix convention silently lowers recall. Check the model's symmetry before adding any `query:`/`passage:` wrapper.

> Source: findings.md "Asymmetric vs. Symmetric Execution" [12]

**determinismLevel**: deterministic.

### EM5: Tokenization Variance Across Vendors

When estimating token cost or comparing models, note the tokenizer differs: OpenAI uses **CL100k**, Voyage AI uses custom Hugging Face tokenizers. Voyage produces **~1.6% more tokens** than OpenAI for the identical corpus, slightly increasing processing volume and cost.

> Source: findings.md "Vocabulary and Tokenization Variance" [8]

**determinismLevel**: deterministic.

### EM6: Unified Hybrid Models Eliminate a Second Model

When the goal is hybrid (dense + sparse) retrieval, prefer a model that unifies them: **BGE-M3** and **Cohere embed-v4** produce dense, multi-vector, AND sparse retrieval in a single model execution. This **eliminates running and maintaining two separate models** to achieve hybrid search.

> Source: findings.md "Multilingual and Hybrid Capabilities" [10, 17]

**determinismLevel**: deterministic.

---

## Anti-Patterns

- **More dimensions = better**: On text-embedding-3-large, 1536→512 truncation shows no significant Wilcoxon difference. Dimensions trade storage, not quality (on Matryoshka models).
- **Prefix everything**: Adding `query:`/`passage:` to a symmetric model (OpenAI/Qwen3) degrades specialized-domain retrieval. Only asymmetric models (Voyage/E5) need prefixes.
- **Ignoring context ceilings**: BGE-large-en-v1.5 caps at 512 tokens, embed-multilingual-v3.0 at 1,000 — feeding longer chunks silently truncates content.
- **Running two models for hybrid**: BGE-M3 / embed-v4 give dense+sparse in one pass — no need to maintain a separate sparse model.
