# ScholarEval — 8-Dimension Research Quality Rubric

> Extracted from ScienceClaw SCIENCE.md lines 569-583 and skills/scholar-evaluation/SKILL.md. Based on the ScholarEval framework (Moussa et al., 2025, arXiv:2510.16234).

---

## The 8 Dimensions

> **Disambiguation**: This rubric evaluates the quality of a *research artifact* (paper, report, proposal). For evaluating the agent's *research process* (completeness, efficiency, depth), see reflexion-cycle.md.

Every research output is evaluated on these 8 weighted dimensions. Score each 0-1.

| # | Dimension | Weight | Assessment Question |
|---|-----------|--------|-------------------|
| 1 | **Rigor** | 25% | Is the methodology sound and the analysis correct? |
| 2 | **Impact** | 20% | Does this matter for the field? Will it change practice or understanding? |
| 3 | **Novelty** | 15% | Does this advance knowledge beyond existing literature? |
| 4 | **Reproducibility** | 15% | Can others replicate the findings with the information provided? |
| 5 | **Clarity** | 10% | Is the communication clear and well-structured? |
| 6 | **Coherence** | 10% | Do all parts fit together logically (intro → methods → results → discussion)? |
| 7 | **Limitations** | 3% | Are limitations honestly acknowledged? |
| 8 | **Ethics** | 2% | Are ethical standards met (IRB, consent, COI, data privacy)? |

**Total: 100%**

> Source: SCIENCE.md "ScholarEval Rubric" lines 571-582

---

## Decision Thresholds

The weighted average determines the overall verdict:

| Weighted Score | Verdict | Meaning |
|---------------|---------|---------|
| **≥ 0.75** | **Accept** | Research meets publication-quality standards |
| **≥ 0.60** | **Minor Revision** | Solid foundation with specific improvements needed |
| **≥ 0.40** | **Major Revision** | Significant issues requiring substantial rework |
| **< 0.40** | **Reject** | Fundamental problems — needs complete restructuring |

> Source: SCIENCE.md line 583: "accept >= 0.75, minor_revision >= 0.60, major_revision >= 0.40, reject < 0.40"

---

## Scoring Guide Per Dimension

### 1. Rigor (25%)

| Score Range | Criteria |
|------------|---------|
| 0.8-1.0 | Methodology fully appropriate, validated, reproducible. Statistical tests correctly applied with assumptions checked. |
| 0.6-0.8 | Sound methodology with minor gaps. Most assumptions verified. |
| 0.4-0.6 | Methodology acceptable but with notable limitations. Some assumptions unchecked. |
| 0.2-0.4 | Significant methodological issues. Key assumptions violated. |
| 0.0-0.2 | Fundamentally flawed methodology. Invalid conclusions. |

Key checks:
- Are statistical test assumptions verified?
- Are effect sizes reported alongside p-values?
- Is sample size adequate for the claims made?
- Are confounders addressed?

### 2. Impact (20%)

| Score Range | Criteria |
|------------|---------|
| 0.8-1.0 | Findings could change field practice or open major new direction |
| 0.6-0.8 | Meaningful contribution advancing current understanding |
| 0.4-0.6 | Incremental contribution with limited broader implications |
| 0.2-0.4 | Minimal impact — confirms known findings without new insight |
| 0.0-0.2 | No discernible impact on the field |

### 3. Novelty (15%)

| Score Range | Criteria |
|------------|---------|
| 0.8-1.0 | First to demonstrate/discover this. Opens new research direction. |
| 0.6-0.8 | Novel combination or application of existing methods/ideas |
| 0.4-0.6 | Extends existing work in a meaningful but expected direction |
| 0.2-0.4 | Largely replicates existing work with minor variation |
| 0.0-0.2 | No novelty — duplicates existing findings |

### 4. Reproducibility (15%)

| Score Range | Criteria |
|------------|---------|
| 0.8-1.0 | Complete code, data, and methodology shared. Step-by-step reproducible. |
| 0.6-0.8 | Most materials shared. Minor gaps in documentation. |
| 0.4-0.6 | Methodology described but code/data partially available |
| 0.2-0.4 | Insufficient detail to reproduce. Key parameters missing. |
| 0.0-0.2 | No reproducibility information provided |

### 5. Clarity (10%)

| Score Range | Criteria |
|------------|---------|
| 0.8-1.0 | Crystal clear writing. Well-organized. Accessible to target audience. |
| 0.6-0.8 | Generally clear with occasional ambiguity |
| 0.4-0.6 | Understandable but requires re-reading for key points |
| 0.2-0.4 | Confusing structure or unclear arguments |
| 0.0-0.2 | Incomprehensible or severely disorganized |

### 6. Coherence (10%)

Does introduction → methods → results → discussion tell a consistent story?

### 7. Limitations (3%)

Are limitations honestly stated? Does the author acknowledge what the study CANNOT claim?

### 8. Ethics (2%)

IRB/ethics approval mentioned? Data privacy addressed? Conflicts of interest declared?

---

## Evaluation Workflow

### Step 1: Scope Definition

Identify work type and evaluation scope:
- Full research paper (empirical, theoretical, review)
- Research proposal or protocol
- Literature review (systematic, narrative, scoping)
- Conference abstract or short paper

> Source: scholar-evaluation/SKILL.md "Step 1: Initial Assessment" lines 66-80

### Step 2: Dimension-by-Dimension Assessment

For each of the 8 dimensions:
1. Read the relevant sections of the work
2. Assess against the scoring guide above
3. Note 2-3 specific strengths
4. Note 2-3 specific areas for improvement
5. Assign a score (0-1)

> Source: scholar-evaluation/SKILL.md "Step 2: Dimension-Based Evaluation" lines 86-88

### Step 3: Calculate Weighted Score

```
weighted_score = (rigor × 0.25) + (impact × 0.20) + (novelty × 0.15) +
                 (reproducibility × 0.15) + (clarity × 0.10) + (coherence × 0.10) +
                 (limitations × 0.03) + (ethics × 0.02)
```

Apply threshold: Accept ≥ 0.75 / Minor Revision ≥ 0.60 / Major Revision ≥ 0.40 / Reject < 0.40

### Step 4: Synthesize Overall Assessment

Provide:
1. Overall quality verdict with weighted score
2. Top 3 strengths across all dimensions
3. Top 3 weaknesses requiring attention
4. Priority recommendations ranked by impact
5. Publication readiness assessment (if applicable)

> Source: scholar-evaluation/SKILL.md "Step 4: Synthesize" lines 167-172

### Step 5: Actionable Feedback

Feedback must be:
- **Specific** — reference exact sections or page numbers
- **Actionable** — concrete suggestions, not vague advice
- **Prioritized** — ranked by importance and feasibility
- **Balanced** — acknowledge strengths alongside weaknesses
- **Evidence-based** — grounded in the scoring criteria above

> Source: scholar-evaluation/SKILL.md "Step 5: Provide Actionable Feedback" lines 179-186

---

## TAD Integration

### When Blake Uses ScholarEval

- **After producing a research report**: Self-evaluate using the 8 dimensions before declaring complete
- **When reviewing external papers**: Apply the rubric to assess source quality during Phase 2 (Deep Reading)
- **In Gate 3**: Spec-compliance reviewer can verify that the research output meets the Accept threshold (≥ 0.75)

### Discipline-Specific Adjustments

| Field | Emphasize More | Emphasize Less |
|-------|---------------|---------------|
| STEM | Reproducibility, Rigor | — |
| Social Sciences | Rigor (causal inference), Impact | — |
| Humanities | Clarity, Coherence, Novelty | Reproducibility (lower weight) |
| Clinical | Ethics, Rigor (RCT standards) | — |

> Source: scholar-evaluation/SKILL.md "Step 6: Contextual Considerations" lines 196-207

---

## Citation

ScholarEval framework: Moussa, H. N. et al. (2025). _ScholarEval: Research Idea Evaluation Grounded in Literature_. arXiv:2510.16234.
