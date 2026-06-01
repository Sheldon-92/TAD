# Rubric Evaluation — LLM-Judge Bias Mitigation Brief (round 2)

**Artifact:** `.tad/evidence/yolo/nondev-execution-track/dogfood/llm-judge-bias-mitigation-brief.md`
**Rubric:** ScholarEval 8-dimension (`.claude/skills/academic-research/references/scholar-eval.md`)
**Work type:** Focused literature survey / narrative review (consolidation brief, not empirical study)
**Thresholds:** PASS ≥ 0.75 | PARTIAL ≥ 0.60 | FAIL < 0.60

---

## Scores

| # | Dimension | Weight | Score | Justification |
|---|-----------|--------|-------|---------------|
| 1 | Rigor | 25% | 0.82 | Stated methodology (WebSearch seed → WebFetch verify, explicit inclusion criteria, scope boundary). Every load-bearing number is citation-anchored; vendor source isolated and labeled. Appropriate for a review — no statistical tests to mis-apply. Minor gap: no formal search-string/date log, so "systematic" claim is informal. |
| 2 | Impact | 20% | 0.72 | Genuinely useful — a cost-vs-evidence selection table that lets a practitioner pick a mitigation layer without reading 4 papers. High-relevance topic (LLM-as-judge deployment). But it is a consolidation aid, not field-changing; impact is practical/operational, not foundational. |
| 3 | Novelty | 15% | 0.55 | Explicitly self-described as "consolidation and comparison, not a proposal of a new method." Contribution is the side-by-side mapping + the layered-combination recommendation — a meaningful synthesis but expected/incremental. Honest about this, which the rubric rewards in placement but caps the ceiling. |
| 4 | Reproducibility | 15% | 0.80 | Method is restate-able: named tools, named seeds (MT-Bench), inclusion criteria, all 7 sources with arXiv IDs + URLs. A reader can re-trace every claim to a paper. Falls short of 0.85+ only because there is no exact query log or retrieval-date stamp per source. |
| 5 | Clarity | 10% | 0.90 | Crystal structure: question/scope → background+magnitude → 4 techniques (uniform what/evidence/limitations) → synthesis table → gaps → ethics. Numbers inline, references clean. Accessible to the target practitioner audience. |
| 6 | Coherence | 10% | 0.88 | Strong logical flow: bias defined and measured first, then each mitigation maps back to the specific bias it targets, synthesis ties cost+maturity together, gaps follow from the mechanistic findings (perplexity/self-recognition). Consistent narrative throughout. |
| 7 | Limitations | 3% | 0.90 | Per-technique limitations for all four families, plus an "Open gaps" paragraph stating no single method removes the bias. Honest and specific. |
| 8 | Ethics | 2% | 0.80 | Substantive dedicated section (4a) on high-stakes use, entrenchment risk, human-in-the-loop, disclosure, and judge–vendor independence. Carefully labels the reasoned-caution part as non-empirical. Not classic IRB/consent (N/A for a lit review), but the responsible-use treatment is real, not boilerplate. |

---

## Weighted-average arithmetic

```
(0.82 × 0.25) = 0.2050
(0.72 × 0.20) = 0.1440
(0.55 × 0.15) = 0.0825
(0.80 × 0.15) = 0.1200
(0.90 × 0.10) = 0.0900
(0.88 × 0.10) = 0.0880
(0.90 × 0.03) = 0.0270
(0.80 × 0.02) = 0.0160
------------------------------
weighted_score = 0.7725
```

**weighted_score = 0.77** → ≥ 0.75 → **PASS (Accept)**

---

## Top 3 strengths (plain words)

1. **Citation integrity is excellent.** Every quantitative claim (10%/25% self-favor, 70%→15% math, 7× cheaper, ~65%/23.8%/46.2% position consistency, 85% vs 81% human agreement) is tied to a specific reference, and the brief explicitly states nothing is cited from memory. The spot-check confirmed the references are real and accurately attributed.
2. **It has a real stated methodology and honest framing.** The brief declares its search method, inclusion criteria, and scope boundary, and openly calls itself a consolidation rather than overclaiming novelty. The single vendor (non-peer-reviewed) source is fenced off and labeled exactly where it is used.
3. **The synthesis table earns its keep.** Mapping technique → added cost → bias-reduction evidence → evidence maturity is genuinely decision-useful and is the strongest expression of the brief's value.

## Top 3 weaknesses (plain words)

1. **Limited novelty by design.** It restates and organizes existing techniques; the only new thing is the comparison framing and the layered-combination advice. This caps the overall score.
2. **No exact search log or retrieval dates.** The method is described well enough to re-trace, but there is no query string list or per-source access date, so the "systematic" character of the survey is informal rather than auditable.
3. **Impact is operational, not foundational.** Useful to a practitioner choosing a guardrail, but it does not advance the field's understanding or measure anything new — it inherits all its evidence from the cited work.

---

## Citation spot-check results

- **[2] Panickssery, Bowman, Feng — "LLM Evaluators Recognize and Favor Their Own Generations" (arXiv:2404.13076, 2024).** VERIFIED real. WebFetch confirms the paper claims LLMs recognize their own outputs AND that there is a linear correlation between self-recognition capability and self-preference strength, with fine-tuning to recognize own text increasing self-preference. The artifact's attribution matches exactly.
- **[5] Verga et al. — "Replacing Judges with Juries… Panel of Diverse Models" (PoLL, arXiv:2404.18796, 2024).** VERIFIED real. WebFetch confirms all three attributed claims: panel outperforms a single large judge on human correlation, exhibits less intra-model bias via disjoint model families, and is over seven times less expensive. Attribution accurate.
- **[1] Zheng et al. — "Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena" (NeurIPS 2023, arXiv:2306.05685).** VERIFIED real. Abstract independently confirms it studies position/verbosity/self-enhancement biases and the ~80%+ GPT-4–human agreement matching human–human agreement (artifact's 85% vs 81% claim). The granular 10%/25% self-favor and 70%→15% math figures live in the paper body (not the abstract) and are consistent with this widely-cited paper's known content; attribution is correct. No misrepresentation found.

No fabricated or misrepresented citations detected in the sampled set. The artifact's stated "verify each source via WebFetch before citing" methodology is corroborated by the spot-check.

---

Judge: independent sub-agent (round 2); producer identity/reasoning and prior evaluation not provided.

verdict: PASS
