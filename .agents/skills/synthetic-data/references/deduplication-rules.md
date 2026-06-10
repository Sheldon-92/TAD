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

> Source: findings.md "Probabilistic Near-Duplicate Detection (MinHashLSH)" [2,11,12] — Jaccard, MinHash signatures, b-bands/r-rows bucketing, O(N²) avoidance.

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

---

## Anti-Patterns

- **Exact-only dedup**: misses copyedited / reformatted / versioned near-duplicates (DEDUP3).
- **Hashing before NFC normalization**: leaves encoding-only duplicates uncaught (DEDUP2).
- **float32 MinHash signatures at scale**: silent precision loss corrupts collisions above 16.7M — store as BINARY_VECTOR (DEDUP4).
- **MinHashLSH at billions of docs**: 200–300 GB+ disk bottleneck — use LSHBloom (DEDUP5).
- **Skipping dedup**: directly accelerates memorization and inflates benchmark scores (DEDUP6).
