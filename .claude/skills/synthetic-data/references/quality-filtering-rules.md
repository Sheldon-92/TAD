# Quality Filtering Rules
<!-- capability: quality_filtering -->

## Quick Rule Index

| # | Rule | stage |
|---|------|-------|
| QF1 | Heuristic gate first: length, symbol ratio, langID, entropy, n-gram diversity | pretraining |
| QF2 | Perplexity filtering has in-distribution bias — do not use it alone | pretraining |
| QF3 | Ask-LLM captures a different signal than perplexity (near-zero correlation) | pretraining/post-training |
| QF4 | Pair quality scoring with density sampling for coverage | pretraining/post-training |
| QF5 | Complexity Gap (CG) score detects label noise in post-training pairs | post-training |
| QF6 | Pick the selection method by its measured downstream score, not by intuition | pretraining |

---

## Rules

### QF1: Heuristic Gate Runs First (cheap before expensive)

Run computationally inexpensive statistical heuristics BEFORE any model-based filtering. The early-stage gate has four checks:

| Check | Threshold / Method | Rejects |
|-------|--------------------|---------|
| Length | discard < 5 tokens or > 2000 tokens | boilerplate stubs, runaway gibberish |
| Symbol / char ratio | regex + char-frequency analysis | excessive non-alphabetic strings, symbol clutter, emoji spam |
| Language ID | `fastText` langid | documents in the wrong target language |
| Shannon entropy `H(x) = -Σ p(xᵢ) log p(xᵢ)` | flag extreme low / high | low → repetitive boilerplate; high → garbled random tokens |

N-gram diversity score `diversity_n(x) = |unique n-grams(x)| / total n-grams(x)` — low diversity = repetitive template-like text that degrades training efficiency.

**Rule**: A pipeline that opens with an expensive model-based filter is mis-ordered. Statistical heuristics are near-free and remove the worst documents first.

> Source: findings.md "Heuristic and Statistical Quality Metrics" [1] — length <5 / >2000 tokens, fastText langID, Shannon entropy, n-gram diversity formulas.

**stage**: pretraining.

### QF2: Perplexity Filtering Has In-Distribution Bias — Never Use It Alone

Perplexity `PPL(x) = exp(-1/n Σ log p_θ(xᵢ | x_<i))` over a small auxiliary model is the classic model-based pruner, but it has a strong in-distribution bias. It fails in three documented ways:

1. **Contextual deficits** — selects highly predictable but low-information fragments (e.g. lists of questions with no answers).
2. **Nonsense repetition** — documents with endless phrase repetition get a LOW perplexity (the repeating combinations stay highly probable), so they survive filtering.
3. **Penalization of niche knowledge** — well-structured long-tail/specialized documents are discarded because their uncommon-but-valid word combinations surprise the scoring model → artificially high PPL.

**Rule**: Perplexity filters select data that mirrors the scoring model's own training corpus, not the optimal training distribution. If you must use perplexity, note that model-free token-frequency statistics (corpus-level token priors) match its quality while running up to **1000× faster**.

> Source: findings.md "Perplexity-Based Curation and Its Biases" [1,3,5,6] — three failure modes; model-free token-frequency alternative up to 1000× faster [3].

**stage**: pretraining.

### QF3: Ask-LLM Captures a Different Signal Than Perplexity

The Ask-LLM framework prompts an instruction-tuned model to explicitly score each candidate's informativeness and coherence. Empirically there is **almost no ranking correlation between Ask-LLM scores and perplexity scores** — Ask-LLM captures a fundamentally different, more valuable semantic signal, recovering high-quality niche-topic documents that perplexity discards.

**Rule**: Do not treat Ask-LLM as a faster perplexity. If your pipeline already perplexity-filters, Ask-LLM is additive, not redundant — the near-zero correlation is the whole point.

> Source: findings.md "Zero-Shot Quality Evaluation via Ask-LLM" [5,6] — "almost no ranking correlation between Ask-LLM scores and perplexity scores".

**stage**: pretraining / post-training.

### QF4: Pair Quality Scoring With Density Sampling for Coverage

Quality scoring alone collapses diversity. Combine it with coverage-maximizing **density sampling**: project documents into an embedding space, estimate local data density nonparametrically, then apply Inverse Propensity Sampling (IPS):

`Selection Probability ∝ 1 / Density(x)`

This uniformizes the representation space so the model trains on a diverse, coverage-maximizing subset — and can exceed full-data performance using only a fraction of the token volume.

**Rule**: Quality without coverage over-samples dense, redundant regions. The recommended protocol is hybrid Ask-LLM (quality) + latent density sampling (coverage).

> Source: findings.md "Latent Density Sampling" + Conclusion #2 "Deploy Dual Quality-Coverage Filtering" [5,6] — IPS selection probability ∝ 1/Density(x).

**stage**: pretraining / post-training.

### QF5: Complexity Gap (CG) Score Detects Label Noise Without Training

For post-training (input, label) pairs, estimate label noise WITHOUT running full model training using the Complexity Gap score:

`CG(x,y) = C(x, ỹ) − C(x, y)`

where `C` is a Kolmogorov complexity estimate and `ỹ` is a randomly permuted label. A **high CG score → label is likely correct**; a **low or negative CG score → high probability of label noise**. The formulation is adaptable across text, code, math, and serialized multimodal inputs.

**Rule**: Before SFT on a labeled set, screen for label noise with CG rather than assuming generated labels are clean.

> Source: findings.md "Complexity Gap (CG) Score" [1] — CG(x,y) = C(x,ỹ) − C(x,y); high = correct, low/negative = noisy.

**stage**: post-training.

### QF6: Pick the Selection Method by Measured Downstream Score

Data-selection methods have measured downstream averages across benchmarks — choose by evidence, not intuition:

| Method | Stage | Downstream Avg | Known Downside |
|--------|-------|----------------|----------------|
| Random Selection (500B) | pretraining | 32.3% | ingests noise + redundancy |
| DSIR (72B) | pretraining | 32.7% | vulnerable to domain-label errors |
| RegMix (500B) | pretraining | 33.6% | expensive tuning phase |
| Ask-LLM (30B) | pretrain/SFT | 35.5% | high initial inference overhead |
| DCLM (30B) | pretraining | 36.7% | depends on reference-model quality |
| Criteria Mix (74B) | pretrain/SFT | 36.0% | manual weight engineering |
| Fineweb-edu (30B) | pretrain/SFT | 37.4% | biased toward academic formatting |
| QuaDMix-OH (30B) | pretrain/SFT | 39.0% | sensitive to optimization hyperparams |
| QuaDMix-BMK (30B) | pretrain/SFT | 39.5% | risk of benchmark-specific overfitting |

**Rule**: QuaDMix (optimized joint quality-proportion selection) tops the table at 39.0–39.5%, but note its benchmark-overfitting risk. A method's headline score is meaningless without its downside column.

> Source: findings.md "data sampling methodologies" comparison table [7,8] — downstream average scores across benchmarks.

**stage**: pretraining.

---

## Anti-Patterns

- **Perplexity-only filtering**: discards niche knowledge, keeps repetitive boilerplate (QF2).
- **Quality without coverage**: over-samples dense regions, kills diversity (QF4).
- **Model-based filter first**: wasteful — heuristics remove the worst docs near-free (QF1).
- **Trusting generated labels**: run CG-score noise screening before SFT (QF5).
- **Picking a selection method by name**: every method has a measured downside; read the column (QF6).
