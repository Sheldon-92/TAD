# Mitigating Self-Enhancement / Self-Preference Bias in LLM-as-a-Judge

## 1. Research question + scope

**Question:** What evidence-based techniques mitigate self-enhancement / self-preference bias when an LLM is used as an evaluator (LLM-as-a-judge)?

**Scope:** This is a focused literature survey of the peer-reviewed and arXiv literature on self-preference bias in pairwise and pointwise LLM evaluation. It covers (a) what the bias is and its measured magnitude, and (b) four distinct mitigation families with their supporting evidence and limitations. It excludes general hallucination/factuality evaluation and human-only evaluation methods except where they serve as calibration baselines.

**Methodology.** Sources were gathered by web search (WebSearch) over arXiv and academic indexes, seeded from the foundational MT-Bench study and expanded along its bias-mitigation threads (self-preference, position bias, juries, reference-guided grading, calibration). Each candidate was retrieved (WebFetch) to verify authors, venue, year, and the cited quantitative claim — nothing is cited from memory. **Inclusion criteria:** peer-reviewed/arXiv papers were preferred and supply every load-bearing magnitude here; one vendor source (ref [7]) is included only for an operational calibration procedure and is labeled non-peer-reviewed where used. **Scope boundary:** the review covers bias of the LLM *evaluator itself* (self-preference, and the position bias entangled with it), not biases of the systems being evaluated.

## 2. Background: what the bias is, and how large it is

**Self-enhancement bias** (also "self-preference bias") is the tendency of an LLM judge to assign higher scores to outputs that it — or a model in its own family — generated, relative to how human annotators would rate the same outputs [1]. The term was imported from social-cognition literature by Zheng et al. in the foundational MT-Bench / Chatbot Arena study, which first systematically documented LLM-judge biases [1].

**Measured magnitude.** In MT-Bench, GPT-4 favored its own answers with a roughly **10% higher win rate**, and Claude-v1 favored its own answers with a **25% higher win rate**, relative to human judgments; GPT-3.5 did not favor itself, and the authors note the effect is confounded with genuine quality differences [1]. Panickssery et al. later isolated the mechanism: an LLM judge scores its own outputs higher than others' even when human annotators rate them equal, and there is a **linear correlation between a model's self-recognition ability and the strength of its self-preference** — fine-tuning a model to better recognize its own text increased its self-preference [2]. Wataoka et al. trace the analytic origin to **perplexity**: judges assign significantly higher scores than humans to low-perplexity (more "familiar") text regardless of authorship, so self-preference is partly a familiarity artifact [3]. Self-enhancement rarely appears alone — it co-occurs with **position bias**, where GPT-4 changed its verdict on roughly a third of cases when answer order was swapped (default-prompt position consistency ~65%; Claude-v1 ~23.8%; GPT-3.5 ~46.2%) [1][4].

## 3. Mitigation techniques

### Technique A — Multi-judge panels / jury of diverse models (PoLL)
**What it does:** Replace one large judge with a *Panel of LLM evaluators* drawn from disjoint model families and aggregate (e.g., vote/average), so no single model's self-preference dominates [5].
**Evidence:** Verga et al. show a panel of smaller, diverse models correlates better with human judgments than a single GPT-4 judge, **reduces intra-model bias** (because the family that produced a candidate is outvoted), and is **over 7× cheaper** [5].
**Limitations:** It reduces but does not eliminate bias — if a candidate's family is *on* the panel, that member still self-favors; panels also add orchestration complexity and can share correlated biases when members come from similar pre-training data [5].

### Technique B — Position-swapping / order randomization with consistency gating
**What it does:** Run each pairwise comparison twice with the two answers in both orders; only declare a winner if it wins in both orders, otherwise call a tie. This neutralizes position bias, which is entangled with self-preference [1][4].
**Evidence:** Zheng et al. propose swapping as a standard control [1]; Shi et al.'s systematic study of position bias across 15 judges and >150,000 instances introduces position-consistency / preference-fairness metrics and confirms position bias is systematic (not random), strongest when the two answers are close in quality [4].
**Limitations:** Doubles inference cost; converts many genuine wins into ties when the judge is inconsistent, lowering resolution; addresses *position* bias directly but only indirectly the self-preference component [1][4].

### Technique C — Reference-guided grading and chain-of-thought
**What it does:** Give the judge a reference/gold answer (or have it solve the problem itself first) and require step-by-step reasoning before the verdict, so scoring anchors on correctness rather than surface familiarity [1].
**Evidence:** In MT-Bench, reference-guided grading cut GPT-4's failure rate on math problems from **70% to 15%** [1].
**Limitations:** Requires a trusted reference, which is unavailable for open-ended/subjective tasks; the judge can still be *misled by a provided wrong answer* and make arithmetic errors despite being able to solve the problem alone [1]; CoT adds tokens/latency and does not by itself remove the perplexity-driven familiarity preference [1][3].

### Technique D — Calibration against human labels
**What it does:** Periodically sample a fraction (≈5–10%) of judge verdicts, have humans re-grade them, and track agreement over time to detect and correct drift or systematic favoritism; verdicts can be re-scaled to the human baseline [7].
**Evidence:** Anchored to the human-agreement baseline Zheng et al. established — GPT-4 reached **85% agreement with humans (no-tie setup), exceeding the 81% human–human agreement** — making human agreement a usable calibration target [1]; practitioner guides operationalize the sampling-and-regrade loop [7].
**Limitations:** Detects/corrects drift but does not fix the underlying model bias; requires ongoing human labeling effort; calibration ages out as the task or rubric shifts and must be repeated [7].

## 4. Synthesis

This brief is a **consolidation and comparison of existing techniques**, not a proposal of a new method; its contribution is the side-by-side mapping below, which lets a practitioner pick a layer by cost and evidence maturity rather than reading four papers separately.

| Technique | Added cost | Bias-reduction evidence | Evidence maturity |
|---|---|---|---|
| A. Diverse multi-judge panel (PoLL) | **>7× cheaper** than 1 GPT-4 judge [5] | Less intra-model bias; better human correlation than single GPT-4 [5] | arXiv, quantified [5] |
| B. Position-swap + consistency gating | ~2× inference (two orders) [1] | Neutralizes position bias (consistency was ~65%/23.8%/46.2%) [1][4] | Foundational + large-scale replication [1][4] |
| C. Reference-guided grading + CoT | Reference authoring + extra tokens [1] | Math failure rate **70% → 15%** [1] | Foundational, quantified [1] |
| D. Calibration vs. human labels | Ongoing ~5–10% human re-grading [7] | Monitors drift against 85% vs 81% human baseline [1][7] | Baseline peer-reviewed [1]; loop = practitioner [7] |

**Best-supported.** The strongest peer-reviewed/empirical support is for (B) position-swapping with consistency gating and (C) reference-guided grading — both are validated with concrete numbers in the foundational MT-Bench study [1], and position bias is independently confirmed at large scale [4]. (A) diverse multi-judge panels has solid, quantified evidence for bias reduction and cost [5]. (D) calibration is well-grounded as a monitoring layer via the human-agreement baseline [1][7] but is the least "mechanistic" fix.

**Open gaps.** No single technique removes self-preference: panels still self-favor when the candidate's family is on the panel [5]; reference-guided grading needs a trusted reference and is foilable by misleading inputs [1]; calibration corrects symptoms, not the perplexity-driven cause [3][7]. The mechanistic finding that self-preference tracks self-recognition and low perplexity [2][3] suggests a still-underexplored direction — perplexity-debiasing or excluding same-family judges — rather than the prompt-level patches that dominate current practice. In deployment, the robust pattern is to *combine* layers: a diverse panel + order-swapping + a reference (when available) + periodic human calibration.

## 4a. Ethical / responsible-use note

The stakes rise sharply when LLM-as-judge is used for high-consequence decisions — hiring screens, automated grading, content moderation, or safety evaluations of other models. In these settings, unmitigated self-preference bias is not merely a measurement error: a model that systematically rates its own (or its family's) outputs higher can **entrench its own generations** — e.g., a safety eval that under-flags failures from the same model family, or a leaderboard that rewards the judge's vendor. Chen et al. demonstrate that both human and LLM judges carry considerable, sometimes exploitable, biases and argue for caution before treating LLM verdicts as ground truth [6]. The responsible-use implication (offered here as reasoned caution, not as a cited empirical finding): the mitigations above reduce but never eliminate the bias, so **human oversight should remain in the loop for any high-stakes decision**, mitigations should be disclosed, and judge–vendor independence (not scoring a model with a same-family judge) should be a default safeguard.

## 5. References

1. Zheng, L., Chiang, W.-L., Sheng, Y., et al. "Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena." NeurIPS 2023. https://arxiv.org/abs/2306.05685
2. Panickssery, A., Bowman, S. R., Feng, S. "LLM Evaluators Recognize and Favor Their Own Generations." arXiv:2404.13076, 2024 (NeurIPS 2024). https://arxiv.org/abs/2404.13076
3. Wataoka, K., Takahashi, T., Ri, R. "Self-Preference Bias in LLM-as-a-Judge." NeurIPS 2024 Safe Generative AI Workshop, arXiv:2410.21819. https://arxiv.org/abs/2410.21819
4. Shi, L., Ma, C., Liang, W., Diao, X., Ma, W., Vosoughi, S. "Judging the Judges: A Systematic Study of Position Bias in LLM-as-a-Judge." arXiv:2406.07791, 2024. https://arxiv.org/abs/2406.07791
5. Verga, P., Hofstatter, S., Althammer, S., et al. "Replacing Judges with Juries: Evaluating LLM Generations with a Panel of Diverse Models." arXiv:2404.18796, 2024. https://arxiv.org/abs/2404.18796
6. Chen, G. H., Chen, S., Liu, Z., Jiang, F., Wang, B. "Humans or LLMs as the Judge? A Study on Judgement Biases." EMNLP 2024, arXiv:2402.10669. https://arxiv.org/abs/2402.10669
7. LangChain. "How to Calibrate LLM-as-a-Judge with Human Corrections" (vendor/practitioner guide, non-peer-reviewed). https://www.langchain.com/articles/llm-as-a-judge
