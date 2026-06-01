# Contamination Detection Rules
<!-- capability: contamination_detection -->

## Quick Rule Index

| # | Rule | stage |
|---|------|-------|
| CON1 | Contamination is a spectrum, not binary — up to 90% of SQuADv2/DROP is contaminated | eval |
| CON2 | Quantify inflation: GSM1k −13%, SWE-bench Verified→Pro −35pp | eval |
| CON3 | ConTAM token-level metrics: TOKEN-MATCH, NGRAM-MATCH, TOKEN-EXTEND, LONGEST-MATCH | eval |
| CON4 | ConTAM optimal config: mincount 1, skip_budget 0, n < 8 | eval |
| CON5 | CoDeC: in-context learning dynamics reveal memorized datasets | eval |
| CON6 | Transition to dynamic, contamination-resistant benchmarks | eval |

---

## Rules

### CON1: Contamination Is a Spectrum, Not Binary

Public evaluation benchmarks leak into pretraining corpora and artificially inflate scores. Contamination exists on a **spectrum** that severely distorts leaderboard comparisons. Up to **90% of examples in datasets like SQuADv2 and DROP have been flagged as contaminated**, leading to rapid metric saturation.

**Rule**: Never treat a benchmark as "clean" or "dirty." Estimate a contamination RATE and report it alongside the score. A high score on a 90%-contaminated benchmark measures memorization, not generalization.

> Source: findings.md "Data Leakage and Saturation Spectrum" [37,39,40] — spectrum not binary; up to 90% of SQuADv2/DROP flagged contaminated.

**stage**: eval.

### CON2: Quantify the Inflation (GSM1k, SWE-bench)

Contamination's impact is measurable by comparing contaminated vs uncontaminated versions of the same task:

- **GSM1k study**: popular families (Phi, Mistral) suffered downstream accuracy drops of **up to 13%** on new, uncontaminated math problems.
- **SWE-bench**: Claude Opus 4.5 scored **80.9% on SWE-bench Verified** (high contamination risk — gold patches recoverable from task IDs) but dropped **35 percentage points to 45.9% on SWE-bench Pro** (contamination-resistant, multi-language).

**Rule**: When you report a benchmark number, report what it drops to on the contamination-resistant variant. A 35pp gap is the difference between a real and an imagined capability.

> Source: findings.md "Data Leakage and Saturation Spectrum" [39,40] — GSM1k −13%; SWE-bench Verified 80.9% → Pro 45.9% (−35pp).

**stage**: eval.

### CON3: ConTAM Token-Level Metrics

To detect leaked data without access to the training corpus, use post-hoc statistical analysis. ConTAM defines four overlap metrics:

| Metric | Diagnostic Focus |
|--------|------------------|
| `TOKEN-MATCH` | total fraction of eval tokens seen during pretraining |
| `NGRAM-MATCH` | fraction of matching n-grams between eval and pretraining corpora |
| `TOKEN-EXTEND` | approximate match with a flexible skip budget (tolerates minor punctuation changes) |
| `LONGEST-MATCH` | isolates only the longest contiguous matching span (avoids false positives from many short matches) |

**Rule**: A single token-overlap metric is fragile. Use `LONGEST-MATCH` to suppress false positives from incidental short overlaps, and `NGRAM-MATCH` for sequence-level leakage.

> Source: findings.md "Contamination Detection Frameworks" ConTAM table [42] — TOKEN-MATCH, NGRAM-MATCH, TOKEN-EXTEND, LONGEST-MATCH.

**stage**: eval.

### CON4: ConTAM Optimal Configuration

The empirically optimal ConTAM configuration:

- **`mincount: 1`** — count even a single occurrence.
- **`skip_budget: 0`** — no skips for TOKEN-MATCH / NGRAM-MATCH / LONGEST-MATCH.
- **`n < 8`** — for NGRAM-MATCH and LONGEST-MATCH, n-gram length below 8.

**Rule**: Use `mincount: 1, skip_budget: 0` as the default; raising `mincount` or `skip_budget` understates contamination. Keep `n < 8` for the n-gram and longest-match metrics.

> Source: findings.md ConTAM table "Optimal Configuration" column [42] — mincount 1, skip_budget 0, n < 8.

**stage**: eval.

### CON5: CoDeC — In-Context Learning Dynamics

The Contamination Detection via Context (CoDeC) framework uses in-context learning dynamics:

- For an **unseen** dataset, adding context (few-shot examples from that dataset) **improves** the model's confidence and accuracy.
- For a **contaminated** dataset, adding context provides **no new information** (the model already memorized the distribution) → confidence stays static or **decreases**.

CoDeC estimates the dataset-level contamination rate as the percentage of samples for which added context **reduces** logit confidence.

**Rule**: If few-shot context fails to lift (or lowers) confidence on a dataset, treat that dataset as contaminated. Complement token-overlap metrics with CoDeC's behavioral signal.

> Source: findings.md "In-Context Diagnostics (CoDeC)" [41] — added context raises confidence on unseen, static/decreasing on contaminated; rate = % samples where context reduces confidence.

**stage**: eval.

### CON6: Transition to Dynamic, Contamination-Resistant Benchmarks

Static public benchmarks saturate as they leak. The recommended mitigation is to move to **dynamic, regularly-refreshed evaluation suites** and harder contamination-resistant variants (e.g. **SWE-bench Pro instead of SWE-bench Verified**). Note that standard memorization-based detectors (minK%, CDD) struggle to isolate incidental contamination — e.g. MathCONTA shows this for math — so dynamic eval sets are needed, not just better detectors.

**Rule**: Do not chase a perfect static-benchmark detector. The durable fix is a refreshed/dynamic eval set plus a contamination-resistant variant. Add CoDeC as an ongoing diagnostic.

> Source: findings.md "MathCONTA" + Conclusion #4 [38,39,40,41] — minK%/CDD struggle with incidental contamination; transition to dynamic suites + SWE-bench Pro-style variants.

**stage**: eval.

---

## Anti-Patterns

- **Treating a benchmark as binary clean/dirty**: contamination is a rate on a spectrum (CON1).
- **Reporting only the high (contaminated) score**: report the contamination-resistant drop too (CON2).
- **Single token-overlap metric**: use LONGEST-MATCH + NGRAM-MATCH together (CON3).
- **Raising mincount / skip_budget**: understates contamination — keep 1 / 0 (CON4).
- **Token metrics only**: add CoDeC's in-context behavioral signal (CON5).
- **Chasing a perfect static detector**: switch to dynamic/refreshed benchmarks (CON6).
