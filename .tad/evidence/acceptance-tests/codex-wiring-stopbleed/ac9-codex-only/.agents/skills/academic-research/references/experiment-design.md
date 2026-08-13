# Experiment Design: Consolidated Judgment Rules

Extracted from ScienceClaw skills. Every rule has a specific threshold or actionable checklist. Generic advice excluded.

---

## 1. RCT Design

### Randomization, Blinding, Controls

| Randomization | Use When |
|---------------|----------|
| Simple | No confounders expected |
| Block | Must ensure equal group sizes per block |
| Stratified | Key covariates (age, sex, severity) must be balanced |
| Cluster | Cannot randomize individuals (schools, clinics) |

**Blinding**: Single (participants), Double (+researchers), Triple (+data analysts).

**Controls**: Positive (validates method works), Negative (validates baseline), Placebo (controls expectation), Active (existing standard treatment for superiority/non-inferiority).

> Source: skills/experiment-design/SKILL.md

### Bias-Mitigation Matrix

| Bias | Mitigation |
|------|-----------|
| Selection | Random sampling + clear inclusion criteria |
| Allocation | Random assignment + concealed allocation |
| Performance | Blinding + standardized protocols |
| Detection | Blinded outcome assessment |
| Attrition | ITT analysis + minimize dropout |
| Reporting | Pre-registration + pre-specified analysis plan |

> Source: skills/experiment-design/SKILL.md

### Study Design Selection

| Design | Best For | Key Weakness |
|--------|----------|-------------|
| RCT | Causal inference | Expensive, ethical limits |
| Factorial | Multiple factors + interactions | Complex analysis |
| Crossover | Within-subject comparison | Carryover effects |
| Quasi-experimental | Randomization impossible | Weaker causal inference |
| Cohort | Long-term outcomes | Confounding |
| Case-control | Rare outcomes | Recall bias |

> Source: skills/experimental-design/SKILL.md

---

## 2. Power Analysis & Sample Size

### Standard Parameters

- **Alpha**: 0.05 (two-sided) | **Power**: 0.80 minimum, 0.90 for well-funded trials
- **Attrition buffer**: Add 10-20% to calculated N

> Source: skills/experiment-design/SKILL.md, skills/experimental-design/SKILL.md

### Cohen's Effect Size Conventions

| Test | Small | Medium | Large |
|------|-------|--------|-------|
| t-test (Cohen's d) | 0.2 | 0.5 | 0.8 |
| Chi-square (Cohen's w) | 0.1 | 0.3 | 0.5 |

**Reference sample sizes** (two-sample t-test, alpha=0.05, power=0.80):
d=0.5 -> ~64/group | d=0.3 -> ~176/group

**Correlation** (Fisher's z): n = ((z_a + z_b) / z_r)^2 + 3, where z_r = 0.5*ln((1+r)/(1-r))

**Replication**: Use safeguard power (assume smaller effect than original). Apply equivalence testing or Bayesian replication factors.

> Source: skills/experiment-design/SKILL.md, skills/reproducibility/SKILL.md

---

## 3. GRADE Evidence Framework

**Starting levels**: RCT = HIGH, Observational = LOW.

**Downgrade** (each by 1-2 levels): (1) Risk of bias, (2) Inconsistency, (3) Indirectness, (4) Imprecision, (5) Publication bias.

**Upgrade** (observational only, each by 1 level): (1) Large effect (RR > 2 or < 0.5), (2) Dose-response, (3) Confounders would reduce effect.

| Final Rating | Confidence |
|-------------|-----------|
| HIGH | True effect close to estimate |
| MODERATE | Likely close |
| LOW | May differ substantially |
| VERY LOW | Very little confidence |

> Source: skills/scientific-critical-thinking/SKILL.md

---

## 4. Evidence Hierarchy

1. Systematic reviews / meta-analyses
2. RCTs
3. Cohort studies
4. Case-control studies
5. Cross-sectional studies
6. Case series / reports
7. Expert opinion

**Caveat**: Well-designed observational > poorly-conducted RCT. Quality within type matters.
**Medical topics**: Prefer sources within **5 years**. Distinguish mechanistic (lab/animal) from clinical (human) evidence. Depth: Quick (3-5 sources), Standard (8-15), Comprehensive (20+ with grading).

> Source: skills/scientific-critical-thinking/SKILL.md, skills/deep-research/SKILL.md

---

## 5. Cochrane Risk of Bias (7 Domains)

Each rated LOW / HIGH / UNCLEAR risk per study:

1. **Random sequence generation** (selection bias)
2. **Allocation concealment** (selection bias)
3. **Blinding of participants/personnel** (performance bias)
4. **Blinding of outcome assessment** (detection bias)
5. **Incomplete outcome data** (attrition bias)
6. **Selective reporting** (reporting bias)
7. **Other bias** (funding conflicts, baseline imbalances, contamination)

> Source: skills/scientific-critical-thinking/SKILL.md

---

## 6. Statistical Evaluation Rules

### P-Value Rules

- P = probability of data given H0 is true; NOT probability H0 is true
- Non-significance != "no effect"
- Statistical significance != practical importance
- Report exact p-values, not just "p < .05"
- Clustering just below .05 = red flag for p-hacking

### Mandatory Reporting

- Effect sizes + confidence intervals alongside all significance tests
- Multiple comparison correction (Bonferroni, FDR) when testing multiple hypotheses
- Primary vs. secondary/exploratory outcomes distinguished

### Missing Data

- Classify: MCAR / MAR / MNAR
- Document proportion, justify handling method (deletion/imputation/ML)

> Source: skills/scientific-critical-thinking/SKILL.md

---

## 7. Reproducibility Checklist (Merged)

### Pre-Registration

- [ ] Hypotheses registered (OSF / AsPredicted / ClinicalTrials.gov / PROSPERO)
- [ ] Analysis plan pre-specified; confirmatory vs. exploratory distinguished
- [ ] Deviations documented and justified

### Open Data (FAIR)

- [ ] Findable: DOI + metadata | Accessible: clear access process
- [ ] Interoperable: standard formats | Reusable: license (CC-BY/CC0) + provenance

### Code & Environment

- [ ] Code in public repository with DOI (GitHub/Zenodo)
- [ ] Dependencies documented (requirements.txt / renv.lock / conda yml)
- [ ] Containerized (Docker/Binder) for full reproducibility
- [ ] Tested on clean environment with README

### Experimental Materials

- [ ] All materials/reagents specified with catalog numbers
- [ ] Step-by-step procedure written
- [ ] Randomization method + blinding procedures documented
- [ ] Inclusion/exclusion criteria + primary endpoint pre-specified
- [ ] Sample size justified with power analysis

### Reporting

- [ ] Guideline followed: CONSORT (RCT) / STROBE (observational) / ARRIVE (animal) / PRISMA (systematic review)
- [ ] All pre-specified analyses reported regardless of significance
- [ ] Exploratory analyses clearly labeled

> Source: skills/reproducibility/SKILL.md, skills/experimental-design/SKILL.md

---

## 8. IRB Protocol Requirements

### Risk Classification

| Level | Process |
|-------|---------|
| Exempt | Minimal review |
| Expedited | Subcommittee review (minimal risk) |
| Full board | Convened IRB (greater than minimal risk) |

### Regulatory Frameworks

Common Rule (45 CFR 46), FDA regs, Declaration of Helsinki, ICH-GCP, IACUC (animal).

### Informed Consent

- Written at **8th grade reading level** for general populations
- Required elements: purpose, procedures, risks, benefits, alternatives, confidentiality, voluntary participation, contact info
- Children: assent + parental consent. Additional protections: prisoners, cognitively impaired.

### Data Protection

- HIPAA (US health data) / GDPR (EU participants)
- Encryption, access controls, retention period, de-identification documented

### Ongoing

Annual continuing review, adverse event reporting, protocol amendments, audit readiness.

> Source: skills/research-ethics/SKILL.md

---

## 9. Hypothesis Formulation

### Seven Quality Criteria

| Criterion | Test |
|-----------|------|
| Testability | Empirically testable with available methods? |
| Falsifiability | What observations would disprove it? |
| Parsimony | Simplest explanation fitting evidence? |
| Explanatory Power | How much of the phenomenon explained? |
| Scope | Range of observations covered? |
| Consistency | Aligns with established principles? |
| Novelty | Offers insights beyond existing explanations? |

### Protocol

1. Generate **3-5 distinct competing hypotheses** per phenomenon
2. Each must be mechanistic (how/why, not just what)
3. Must be distinguishable by different predictions
4. Quantitative predictions with direction + magnitude
5. Specify falsification conditions per hypothesis

### Citation Targets

Main text: 10-15 citations. Appendices: 40-70+. Total: 50+ references.

> Source: skills/hypothesis-generation/SKILL.md

---

## 10. Peer Review Protocol

### Seven Steps

1. **Initial**: Full read. Identify question, design, findings, conclusions. Scope fit.
2. **Novelty**: Incremental vs. substantial. Citation completeness.
3. **Methods**: Design appropriateness. Controls, sample size, blinding, randomization. Replication detail.
4. **Statistics**: Appropriate tests, multiple comparison corrections, effect sizes, p-hacking signs, assumption checks.
5. **Results**: Address stated aims. Figures/tables accurate. No cherry-picking.
6. **Discussion**: Conclusions supported. Limitations acknowledged. Alternatives considered.
7. **Output**: Summary + major/minor concerns + questions + recommendation.

### Quality Gates

- [ ] Full manuscript read before review | Summary accurate
- [ ] Major concerns are validity-threatening, not stylistic
- [ ] Statistical methods evaluated | Constructive tone maintained
- [ ] Specific section/figure/table references provided
- [ ] Alternatives suggested where methods criticized
- [ ] COI self-assessed | Recommendation matches concern severity

**Scale**: Accept / Minor revision / Major revision / Reject (justified).

> Source: skills/peer-review/SKILL.md

---

## 11. Richardson Extrapolation & GCI

### Richardson Extrapolation

```
f_exact ~ f_h1 + (f_h1 - f_h2) / (r^p - 1)
r = h2/h1 (refinement ratio), p = formal order
```

### Observed Convergence Order (requires 3+ levels)

```
p_obs = ln((f3 - f2) / (f2 - f1)) / ln(r)
```
f1 = finest, f3 = coarsest.

### GCI (Roache's Method)

- Requires exactly **3 refinement levels**
- Safety factor **Fs = 1.25** (3+ grids with order verification)
- Safety factor **Fs = 3.0** (2 grids, no order verification)
- **GCI_fine = Fs * |epsilon| / (r^p - 1)**, epsilon = (f2-f1)/f1

### Diagnostics

| Observation | Meaning | Action |
|-------------|---------|--------|
| Order matches expected | Asymptotic range | Report GCI |
| Order too low | Pre-asymptotic or bug | Refine or debug |
| Negative order | Diverging | Check implementation |
| Asymptotic ratio ~ 1.0 | Reliable | Proceed |
| Asymptotic ratio far from 1.0 | Not converged | Refine further |

> Source: skills/convergence-study/SKILL.md

---

## 12. Fact Verification Scale

| Verdict | Criteria |
|---------|----------|
| VERIFIED | Multiple independent high-quality sources confirm |
| LIKELY TRUE | Evidence supports, limited independent confirmation |
| MIXED | Partially true with important caveats |
| LIKELY FALSE | Evidence contradicts, some ambiguity |
| FALSE | Clear contradicting evidence |
| UNVERIFIABLE | Insufficient evidence |

> Source: skills/fact-verification/SKILL.md

---

## 13. NIH Review Scoring

**1-9 scale** (1 = exceptional, 9 = poor): Significance, Investigator(s), Innovation, Approach, Environment.

R01: 1-page Specific Aims + 12-page Research Strategy. Modular budgets at **$250K** direct cost increments. Salary cap **~$221,900** (2024).

> Source: skills/research-grants/SKILL.md

---

## 14. Problem Selection Framework

**Axes**: X = likelihood of success, Y = impact if successful.

- No risk = incremental (low impact)
- Multiple miracles = avoid or decompose
- **Fix ONE constraint**, let others float (parameter paradox)
- Scientists spend **days** choosing, **years** solving. Problem choice >> execution quality.

> Source: skills/scientific-problem-selection/SKILL.md

---

## 15. Convergence of Evidence

**Stronger**: Multiple replications, different groups/settings, different methods converge, mechanistic + empirical align.
**Weaker**: Single study/group, contradictions, publication bias, no replication.

> Source: skills/scientific-critical-thinking/SKILL.md

---

## 16. Adjacent Possible Timing

- Requires non-existent tech -> park it
- Could have been done 5 years ago -> check literature (probably done)
- **Sweet spot**: feasible in last **6-18 months**

> Source: skills/creative-thinking-for-research/SKILL.md
