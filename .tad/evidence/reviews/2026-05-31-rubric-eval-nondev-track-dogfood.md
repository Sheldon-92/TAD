# Rubric Evaluation — Non-Dev Track Dogfood Artifact

**Artifact:** `.tad/evidence/yolo/nondev-execution-track/dogfood/llm-judge-bias-mitigation-brief.md`
**Rubric:** ScholarEval 8-dimension (`.claude/skills/academic-research/references/scholar-eval.md`)
**Thresholds:** Accept ≥ 0.75 / Minor Revision (PARTIAL) ≥ 0.60 / Major Revision ≥ 0.40 / Reject < 0.40
**Date:** 2026-05-31

Judge: independent sub-agent; producer identity/reasoning not provided.

---

## Scope

Work type: focused literature survey / narrative review of self-preference (self-enhancement) bias in LLM-as-a-judge, plus four mitigation families. This is a review/survey, not an empirical study — so Reproducibility is judged on methodology transparency + traceable citations (not code/data), and Rigor is judged on faithful representation and correct synthesis of primary sources rather than original statistical tests.

---

## Scores

| # | Dimension | Weight | Score | Justification |
|---|-----------|--------|-------|---------------|
| 1 | Rigor | 25% | 0.78 | Faithful, source-grounded synthesis; magnitudes attributed precisely (10%/25% win-rate, position-consistency %); honestly flags Zheng's own caveat that self-enhancement is confounded with quality. Minor gap: no scope/search methodology stated, so "rigor" rests on citation fidelity rather than a defined survey protocol. |
| 2 | Impact | 20% | 0.72 | Directly actionable for any team running LLM-eval; the layered "combine panel + swap + reference + calibration" recommendation is a meaningful practitioner contribution. Not field-changing (synthesis of known results), so upper-mid band. |
| 3 | Novelty | 15% | 0.55 | Novel *organization* (4 mitigation families + a mechanistic "perplexity/self-recognition" through-line) but no new data or method; squarely "extends/recombines existing work in an expected direction." |
| 4 | Reproducibility | 15% | 0.70 | Every claim is numbered-cited to a retrievable source with arXiv/DOI URLs; a reader can re-trace each figure. Held below 0.8 because the survey itself lacks a stated method (databases searched, inclusion criteria, date), so the *review* is not fully reproducible as a survey. |
| 5 | Clarity | 10% | 0.88 | Crystal-clear structure (question→background→techniques→synthesis→refs); each technique uses a consistent What/Evidence/Limitations triplet; numbers in bold for scanability. |
| 6 | Coherence | 10% | 0.88 | Strong logical arc: the bias-magnitude section sets up exactly the four mitigations, and the synthesis ties them back to the mechanistic findings (perplexity/self-recognition) introduced earlier. |
| 7 | Limitations | 3% | 0.85 | Per-technique Limitations subsections plus a dedicated "Open gaps" paragraph stating no single technique removes the bias — honest and specific. |
| 8 | Ethics | 2% | 0.45 | No COI/funding statement and no note on evaluation-fairness/automation-bias risk; acceptable for a short secondary review but the dimension is only lightly addressed. |

---

## Weighted Average (explicit arithmetic)

```
rigor          0.78 × 0.25 = 0.1950
impact         0.72 × 0.20 = 0.1440
novelty        0.55 × 0.15 = 0.0825
reproducibility0.70 × 0.15 = 0.1050
clarity        0.88 × 0.10 = 0.0880
coherence      0.88 × 0.10 = 0.0880
limitations    0.85 × 0.03 = 0.0255
ethics         0.45 × 0.02 = 0.0090
---------------------------------------
weighted_score              = 0.7370
```

weighted_score = **0.737** → between 0.60 and 0.75 → **Minor Revision (PARTIAL)**.

(0.737 is only 0.013 below the Accept threshold; the gap is driven almost entirely by Novelty 0.55 and the missing survey-method, not by any correctness problem.)

---

## Top 3 Strengths (actionable to preserve)

1. **Citation fidelity is excellent.** Spot-checked references resolve to real papers and the attributed mechanisms are accurate (see spot-check below). The numbered, URL-bearing reference list makes every quantitative claim traceable — this is the single biggest driver of the Rigor/Reproducibility scores.
2. **Honest confound handling.** The brief explicitly carries Zheng et al.'s caveat that self-enhancement is "confounded with genuine quality differences," and uses Panickssery [2] / Wataoka [3] to separate the *mechanism* (self-recognition, perplexity) from the raw win-rate gap. This avoids the common over-claim that the 10%/25% numbers are pure bias.
3. **Decision-useful synthesis.** The closing "combine layers" recommendation (diverse panel + order-swap + reference-when-available + periodic human calibration) converts the literature into an operational policy, raising Impact above a pure-summary review.

## Top 3 Weaknesses (actionable to fix)

1. **No survey methodology stated** (raises Rigor + Reproducibility). Add a 2-3 line method: which sources/databases were searched, inclusion/exclusion criteria, and the retrieval date. Without it the "literature survey" claim in §1 is unverifiable as a survey, even though individual citations are solid.
2. **Two headline numbers from [1] are not independently confirmable from the abstract** (10%/25% win-rate; 70%→15% math; 85% vs 81% agreement live in the full paper body, not the abstract). Add a page/section anchor for each [1] figure (e.g., "[1, §3.3]") so a reader can locate them without re-reading the whole paper — this is the highest-priority Rigor fix.
3. **Ethics dimension nearly empty.** Add one sentence on COI/funding (or "none") and one on the fairness/automation-bias risk of deploying biased judges in high-stakes grading. Cheap to add (2% weight) but currently the lowest-scoring dimension.

---

## Citation Spot-Check (integrity)

| Ref | Verified via | Outcome |
|-----|--------------|---------|
| [2] Panickssery, Bowman, Feng — "LLM Evaluators Recognize and Favor Their Own Generations" (arXiv:2404.13076) | WebFetch arXiv abstract | VERIFIED. Real paper; abstract confirms the "linear correlation between self-recognition capability and the strength of self-preference bias" and that fine-tuning to recognize own text strengthens self-preference — exactly as the brief's §2 states. |
| [4] Shi, Ma, Liang, Diao, Ma, Vosoughi — "Judging the Judges: A Systematic Study of Position Bias" (arXiv:2406.07791) | WebFetch arXiv abstract | VERIFIED. Real paper; confirms 15 judges and >150,000 evaluation instances, position bias is "not due to random chance," and is "strongly affected by the quality gap between solutions" (strongest when answers are close in quality) — matches the brief's Technique B and §2 attributions. |
| [1] Zheng et al. — "Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena" (arXiv:2306.05685) | WebFetch arXiv abstract | PARTIALLY VERIFIED. Title/authors/venue correct; abstract confirms GPT-4 judge reaches "over 80% agreement" with humans (consistent with the brief's 85%/81% claim). The specific 10%/25% self-enhancement win-rate and the 70%→15% reference-guided math figures are well-known results from this paper but reside in the body, not the abstract, so they could not be byte-confirmed from the fetched page. No misrepresentation found; these are accurate to the paper as widely cited, but the brief should anchor them to a section number. |

No fabricated or misrepresented citations were found. One source ([6] LangChain calibration guide) is a vendor practitioner article, appropriately used only for the operational sampling-loop claim and not for any empirical magnitude. The mix of NeurIPS/arXiv primary sources with one labeled practitioner guide is reasonable for a deployment-oriented review.

---

verdict: PARTIAL
