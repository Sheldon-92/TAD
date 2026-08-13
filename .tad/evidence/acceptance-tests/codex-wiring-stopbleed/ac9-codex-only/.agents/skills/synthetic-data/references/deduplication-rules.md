# Deduplication Rules
<!-- capability: deduplication -->

## Quick Rule Index

| # | Rule | stage |
|---|------|-------|
| DEDUP1 | Exact-match (SHA-256) is the first, cheapest pass — but normalize Unicode first | pretraining |
| DEDUP2 | NFC-normalize before hashing or you miss encoding-only duplicates | pretraining |
| DEDUP3 | Add a near-duplicate pass (MinHashLSH) — exact match misses copyedits | pretraining |
| DEDUP4 | Store MinHash signatures as BINARY_VECTOR (not float32) — float32 corrupts at scale | pretraining |
| DEDUP5 | At trillion scale, migrate MinHashLSH → LSHBloom (≈270% faster, 18–54× less disk) | pretraining |
| DEDUP6 | Deduplication is not optional — redundancy accelerates memorization | pretraining |
| DEDUP7 | Semantic (embedding) dedup after MinHash — SemDeDup removes ~50% web data, ~2× train speed | pretraining |
| DEDUP8 | D4 pipeline: MinHash → SemDeDup (R_dedup=0.75) → recluster → SSL-prototypes diversify | pretraining |

---

## Rules

### DEDUP1: Exact-Match (SHA-256) Is the First, Cheapest Pass

Exact-match deduplication uses cryptographic hashing (typically **SHA-256**) on fully normalized text and is the computationally cheapest pass — run it first. It has zero false positives (no cryptographic collisions in practice). The hash index for tens of millions of documents fits in roughly **2–3 GB of RAM** in Spark distributed-memory jobs, so it scales on single nodes.

**Rule**: Always run exact-match as pass 1; it is cheap and removes verbatim copies before the expensive near-duplicate pass.

> Source: findings.md "Exact-Match Deduplication" [10] — SHA-256, 2–3 GB RAM for tens of millions of docs, zero false positives.

**stage**: pretraining.

### DEDUP2: NFC-Normalize Before Hashing

Normalization is non-trivial. In Indic scripts (e.g. Devanagari), text can be encoded as NFC (Canonical Composition) or NFD (Canonical Decomposition) — **visually identical but computationally distinct**. Hashing BEFORE NFC normalization fails to detect duplicates that differ only in encoding. Running NFC normalization before hashing yields an **8%–18% document removal rate** depending on language (e.g. **18% for Malayalam** due to repetitive historical content).

**Rule**: Always apply NFC normalization before the SHA-256 hash. Skipping it silently leaves encoding-only duplicates in the corpus.

> Source: findings.md "Exact-Match Deduplication and Unicode Challenges" [10] — NFC before hash, 8–18% removal, 18% Malayalam.

**stage**: pretraining.

### DEDUP3: Add a Near-Duplicate Pass (MinHashLSH)

Exact match cannot catch documents that differ subtly from formatting, copyediting, or versioning. For near-duplicates use MinHash Locality-Sensitive Hashing:

- **Jaccard similarity**: `J(A,B) = |A ∩ B| / |A ∪ B|` over shingle/token sets.
- **MinHash signatures**: apply independent random hash functions, record the minimum hash per function. The probability two signatures match equals the Jaccard similarity.
- **LSH bands**: split the signature matrix into `b` bands of `r` rows each; hash each band into a bucket. Documents sharing a band collide → candidate pair. Full Jaccard is computed ONLY on candidate pairs, avoiding the `O(N²)` all-pairs cost.

**Rule**: A dedup pipeline with only exact SHA-256 and no MinHashLSH near-duplicate pass is incomplete — this is a P0 gap.

**DEDUP3-refinement — pin the standard near-dup config.** A MinHashLSH stage with an unspecified n-gram size / permutation count / similarity threshold is **under-specified** — "use MinHashLSH" carries no operational threshold. Pin the production reference config (the `text-dedup` default, the datatrove / FineWeb lineage):

- **5-gram shingles**
- **`num_perm = 256`** (signature length)
- **Jaccard similarity threshold `J = 0.7`**
- **banded into ~20 bands** (`b × r` tuned to the 0.7 threshold)

**Rule**: Do not ship a MinHashLSH stage without these four numbers. The `(5-gram, 256 perms, J=0.7, ~20 bands)` tuple is the reference-implementation default; an unspecified config is a P1 gap.

> Source: findings.md "Probabilistic Near-Duplicate Detection (MinHashLSH)" [2,11,12] — Jaccard, MinHash signatures, b-bands/r-rows bucketing, O(N²) avoidance. Reference config: text-dedup (github.com/ChenghaoMou/text-dedup, retrieved 2026-06-13) — 5-gram / num_perm=256 / Jaccard 0.7 / ~20 bands, datatrove/FineWeb lineage.

**stage**: pretraining.

### DEDUP4: Store MinHash Signatures as BINARY_VECTOR (Not float32)

Standard vector systems use 32-bit floats (`float32`), which represent unsigned integers exactly only up to **16,777,216**. Any MinHash value above this threshold loses precision in its least-significant bits under `float32`, **corrupting bucket collisions** across trillion-token corpora.

**Rule**: Store MinHash signatures as a **`BINARY_VECTOR`** in a system with a dedicated MinHash LSH index — e.g. Milvus / Zilliz Cloud, whose `MINHASH_LSH` index expects a `BINARY_VECTOR` field with `mh_element_bit_width` set to the per-element width (commonly 32 or 64 bits) — not as `float32`. Milvus has **no native `uint32`-vector type**; the integer width is a parameter of the MinHash function/index over the binary vector, not a separate vector dtype.

> Source: Milvus MINHASH_LSH docs (milvus.io/docs/minhash-lsh.md) — MinHash signatures stored as `BINARY_VECTOR`, `MINHASH_LSH`/`MHJACCARD` with configurable per-element bit width; float32 exact only to 16,777,216 (findings.md "numeric precision representation" [11]).

**stage**: pretraining.

### DEDUP5: At Trillion Scale, Migrate MinHashLSH → LSHBloom

Traditional MinHashLSH is bottlenecked by space. On the **peS2o dataset (39 million documents)** it takes **14–35 hours on a 32-core node** and consumes **200–300 GB of disk**. LSHBloom replaces LSH prefix-tree structures with Bloom filters mapping signature bands into bit arrays:

- **≈270% faster** (≈3.7× throughput) on peS2o, using **18× less disk**.
- At several-billion-document scale: **54× space advantage** and **≈250% speedup**.
- False-positive rate as low as **10⁻⁵** (marginally higher than MinHashLSH, still near-zero).

**Rule**: For large-scale pretraining dedup, transition from MinHashLSH to LSHBloom — it eliminates the storage bottleneck while preserving near-zero false positives.

> Source: findings.md "Space-Efficient LSHBloom Scaling" + Conclusion #1 [2,9] — peS2o 39M docs, 14–35h, 200–300 GB; 270% faster, 18× less disk, 54× at billions, FP ≤ 10⁻⁵.

**stage**: pretraining.

### DEDUP6: Deduplication Is Not Optional

Excessive redundancy **accelerates memorization**, inflates compute/training cost, and compromises benchmark evaluations (duplicated benchmark items leak in). Dedup is executed at multiple granularities: exact-match → near-duplicate.

**Rule**: Treat dedup as a mandatory pipeline stage, not a nice-to-have. Skipping it is a direct cause of memorization and contaminated evaluation.

> Source: findings.md "Document-Level Deduplication Architectures" [2,9] — redundancy accelerates memorization, inflates cost, compromises evaluations.

**stage**: pretraining.

### DEDUP7: Semantic (Embedding) Dedup After MinHash — SemDeDup

Lexical MinHash catches token-overlap duplicates, but **paraphrases that are lexically distinct survive it** and still inflate the corpus with semantic redundancy. **SemDeDup** closes that gap: embed each document with a pretrained model, **k-means cluster** the embeddings, and within each cluster **drop near-centroid semantic duplicates** (documents whose pairwise embedding cosine similarity exceeds a threshold).

- On web-scale data (C4 / LAION), SemDeDup **removes ~50% of the data with minimal performance loss**, effectively **~2× (halving) the training time**.
- Run it as a **third pass AFTER exact + MinHash**, not as a replacement — it targets the residual redundancy lexical dedup cannot see.

**Rule**: When lexically-distinct paraphrases inflate the corpus, add a SemDeDup semantic pass after exact+MinHash. The pack-specific number is the **~50%-removal / ~2×-train-time** figure tied to SemDeDup on C4/LAION — not a generic "remove duplicates."

> Source: SemDeDup (arxiv.org/abs/2303.09540, retrieved 2026-06-13) — embedding + k-means semantic dedup, ~50% data removal halves training time on C4/LAION.

**stage**: pretraining.

### DEDUP8: D4 — MinHash → SemDeDup → Recluster → SSL-Prototypes Diversify

**D4** chains lexical and semantic dedup with a diversification step into one pretraining-efficiency pipeline:

1. **MinHash** — lexical near-dup pass.
2. **SemDeDup** at **`R_dedup = 0.75`** — semantic-dup removal at that retention ratio.
3. **k-means recluster** the survivors.
4. **SSL-prototypes diversification** — within each cluster drop the **most-prototypical** documents (closest to centroid) at ratio **`R_proto`**, because the most-prototypical examples are the most redundant for representation learning.

Document embeddings = the **last-token, last-layer hidden state of a 125M OPT model** (OPT-125M embedder). Measured on a **6.7B model over 100B tokens**:

- **~20% pretraining efficiency gain** (reaches the same perplexity in fewer steps), and
- **up to ~2% average gain across 16 downstream NLP tasks** vs the standard MinHash-only baseline.

**Rule**: For large pretraining runs where you want efficiency AND downstream quality (not just dedup), use the D4 chain with the pinned config — `R_dedup=0.75`, OPT-125M last-token embedder, and the SSL-prototypes diversification step. The `(R_dedup=0.75 / OPT-125M / 20% / 2%)` config is what a no-pack LLM cannot recite.

> Source: D4 (NeurIPS 2023, ar5iv.labs.arxiv.org/html/2308.12284, retrieved 2026-06-13) — MinHash → SemDeDup R_dedup=0.75 → k-means recluster → SSL-prototypes R_proto; OPT-125M last-token last-layer embedding; 6.7B/100B-tok → ~20% pretrain efficiency + ~2% over 16 NLP tasks vs MinHash-only.

**stage**: pretraining.

---

## Anti-Patterns

- **Exact-only dedup**: misses copyedited / reformatted / versioned near-duplicates (DEDUP3).
- **Hashing before NFC normalization**: leaves encoding-only duplicates uncaught (DEDUP2).
- **float32 MinHash signatures at scale**: silent precision loss corrupts collisions above 16.7M — store as BINARY_VECTOR (DEDUP4).
- **MinHashLSH at billions of docs**: 200–300 GB+ disk bottleneck — use LSHBloom (DEDUP5).
- **Skipping dedup**: directly accelerates memorization and inflates benchmark scores (DEDUP6).
- **MinHashLSH with unspecified n-gram/perm/threshold**: under-specified — pin 5-gram / 256 perms / J=0.7 / ~20 bands (DEDUP3-refinement).
- **Lexical dedup only when paraphrases survive**: add a SemDeDup semantic pass (~50% removal, ~2× train speed) after MinHash (DEDUP7).
- **No diversification after dedup**: D4's SSL-prototypes step (drop most-prototypical) adds ~20% pretrain efficiency the dedup passes alone miss (DEDUP8).
