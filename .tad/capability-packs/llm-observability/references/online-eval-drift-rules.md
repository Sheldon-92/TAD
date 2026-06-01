# Online Eval, Groundedness & Drift Detection Rules
<!-- capability: online_eval_drift -->

## Quick Rule Index

| # | Rule | determinismLevel |
|---|------|-----------------|
| OE1 | Dual-layer eval: LLM-as-Judge (Layer 1) routes uncertain cases to humans (Layer 2) | semi-deterministic |
| OE2 | Groundedness = supported claims / total claims (0.0–1.0); flag below threshold | semi-deterministic |
| OE3 | Embedding drift: Wasserstein distance on PCA-reduced (95% variance) vectors, NOT KS test | non-deterministic |
| OE4 | Track inertia (↑ = dispersion) and silhouette (↓ = topic broadening) on K-Means clusters | non-deterministic |
| OE5 | Layer-2 drift: a judge LLM classifies the drift driver into action categories | non-deterministic |
| OE6 | SORE: embedding + ANN outlier removal at a fraction of LLM-judge cost | semi-deterministic |

---

## Rules

### OE1: Dual-Layer Evaluation Pipeline

Traditional software testing fails on probabilistic LLM outputs. Use a **dual-layer** online evaluation pipeline:

- **Layer 1 — LLM-as-a-Judge**: an independent judge model scores production outputs against structured rubrics on semantic dimensions (correctness, safety, helpfulness), emitting a structured rating AND a written justification. Runs continuously at scale.
- **Layer 2 — Human-in-the-Loop**: if the judge's evaluation is marked **uncertain or borderline**, route that trace to a human review queue. Human feedback then refines the judge's prompts and rubrics over time.

**Rule**: Do NOT human-review every trace (does not scale) and do NOT auto-trust every judge verdict (misses high-stakes cases). Route only the judge's uncertain/borderline outputs to humans, and feed their decisions back to improve the rubric. The judge MUST output a justification, not just a number, so humans can audit it.

> Source: findings.md "Layer 1 (LLM-as-a-Judge)... outputting a structured rating and a written justification. Layer 2 (Human-in-the-Loop): If the judge model's evaluation is marked as uncertain or borderline, the trace is routed to a human review queue" [26, 27, 29, 30]

**determinismLevel**: semi-deterministic — judge scores vary; routing logic is fixed.

### OE2: Groundedness Score = Supported Claims / Total Claims

To detect hallucination, deploy an LLM-as-a-Judge for a groundedness check that verifies the output is strictly supported by retrieved context:

```
Groundedness Score = (Number of claims supported by retrieved context)
                     / (Total number of claims in generated output)
```

The score ranges **0.0 to 1.0**. If it falls below a predefined threshold, flag the output for revision.

**Rule**: Groundedness is a claim-decomposition ratio, not a vibe check. The judge must enumerate claims and check each against the retrieved context. A response with 8 of 10 claims supported scores 0.8 — set the revision threshold explicitly rather than treating groundedness as binary.

> Source: findings.md "Groundedness Score = Number of Claims Supported by Retrieved Context / Total Number of Claims in Generated Output... If this score falls below a predefined threshold, the output is flagged for revision" [24, 27]

**determinismLevel**: semi-deterministic — judge-derived ratio.

### OE3: Embedding Drift via Wasserstein on PCA-Reduced Vectors

Semantic drift (shifts in data distribution / user behavior) is masked in high-dimensional embeddings. Traditional univariate tests (Kolmogorov–Smirnov) are **ineffective** for high-dimensional vectors. Instead:

1. **PCA**: reduce high-dimensional embeddings (e.g., 4096-dim) to a lower space retaining **95% of variance** (≈ two standard deviations).
2. Compute **Wasserstein distance** between live-production and reference embedding distributions.
3. If the distance exceeds a predefined threshold → trigger a statistical drift alert (Layer 1).

**Rule**: Do NOT apply a univariate KS test to raw high-dimensional embeddings — it cannot detect multivariate distribution shift. Reduce with PCA (95% variance) first, then measure Wasserstein distance.

> Source: findings.md "Traditional univariate tests (like the Kolmogorov-Smirnov test) are ineffective for high-dimensional vectors. Instead, systems apply Wasserstein distance calculations on dimensionality-reduced embeddings... reduce... down to a lower-dimensional space while retaining 95% of the variance" [28]

**determinismLevel**: non-deterministic — depends on live embedding distribution.

### OE4: K-Means Cluster Metrics — Inertia & Silhouette

After PCA reduction, group vectors with K-Means and track clustering metrics over time:

| Metric | Range / Meaning | Drift Signal |
|--------|-----------------|--------------|
| **Inertia** | Sum of squared distances of samples to their closest cluster center | **Rising** inertia = production prompts dispersing farther from historical centroids |
| **Silhouette Score** | −1 to 1; cluster definition quality | **Declining** score = prompts covering a broader, less-defined topic range |
| **Distance stats** (mean/median/std) | Via AWS Glue ETL job `embedding-distance-analysis` mapping production prompts to baseline clusters | **Rising** distance = queries shifting away from reference coverage |

**Rule**: A single drift number hides the shape of the shift. Track inertia (dispersion) AND silhouette (topic definition) together — rising inertia with falling silhouette means the user base is asking broader, less-coherent questions than your reference data covers.

> Source: findings.md "Inertia: ... Rising inertia indicates that production prompts are dispersing... Silhouette Score: Evaluates cluster definition on a scale from −1 to 1... Distance Analysis: ... AWS Glue ETL job (embedding-distance-analysis)" [28]

**determinismLevel**: non-deterministic — metric values depend on live data.

### OE5: Layer-2 Semantic Drift Classification

When a Layer-1 statistical alert (OE3) fires, a **judge LLM** evaluates a sample of drifted prompts against baseline reference samples and classifies the primary **driver** of drift into action-oriented categories (e.g., emergence of new topics, changes in query complexity, formatting shifts).

**Rule**: A statistical drift alert tells you THAT distribution shifted, not WHY. Always run the Layer-2 classifier to label the driver, because the remediation differs: new topics → update retrieval index; complexity shift → adjust prompts; formatting shift → re-template. An unclassified alert is not actionable.

> Source: findings.md "When a Layer 1 statistical alert is triggered, a judge LLM evaluates a sample of drifted prompts against baseline reference samples... classify the primary driver of the drift into action-oriented categories (e.g., emergence of new topics, changes in query complexity, or formatting shifts)" [28]

**determinismLevel**: non-deterministic — judge classification.

### OE6: Semantic Outlier Removal (SORE)

To protect reliability under changing workloads, deploy a **Semantic Outlier Removal (SORE)** pipeline: it uses multilingual sentence embeddings + approximate nearest-neighbor (ANN) search to identify core content and filter boilerplate, structural noise, or irrelevant queries **before** they reach downstream generation — achieving extraction precision comparable to LLM judges at a fraction of the computational cost.

**Rule**: When LLM-judge filtering is too expensive for high-volume input cleaning, use SORE (embedding + ANN) as a cheap pre-filter. It is a cost optimization, not a replacement for the dual-layer eval (OE1) on outputs.

> Source: findings.md "Semantic Outlier Removal (SORE)... leverages multilingual sentence embeddings and approximate nearest-neighbor search... achieving extraction precision comparable to LLM judges at a fraction of the computational cost" [32]

**determinismLevel**: semi-deterministic — embedding-based filtering.

---

## Anti-Patterns

- **Human-reviewing everything**: Does not scale; route only judge-uncertain cases to humans.
- **Binary groundedness**: Groundedness is a supported/total claim ratio (0.0–1.0) with an explicit threshold, not yes/no.
- **KS test on raw embeddings**: Univariate tests miss multivariate drift; use Wasserstein on PCA-reduced (95% variance) vectors.
- **Single drift metric**: Track inertia AND silhouette together to see the shape of the shift.
- **Unclassified drift alerts**: A statistical alert without a Layer-2 driver classification is not actionable.
