# Social Sciences Domain Judgment Rules

Extracted from ScienceClaw economics, social science, psychology, education, and political science skills.
Rules with specific thresholds, method selection criteria, and numeric standards only.

---

## 1. Causal Inference Method Selection

**R-SOC-001: Method-Assumption Matrix**
| Method | When to use | Key assumption | Diagnostic |
|---|---|---|---|
| RCT | Can randomize treatment | Random assignment | Balance tests |
| IV / 2SLS | Endogeneity, have instrument | Exclusion restriction | First-stage F > 10 |
| DiD | Policy change, panel data | Parallel trends | Pre-trend test |
| RDD | Treatment at threshold | Continuity at cutoff | McCrary density test |
| PSM / Matching | Observational, rich covariates | Selection on observables | Balance after matching |
| Synthetic Control | Aggregate intervention, few treated | Parallel trends (weighted) | Placebo tests |

> Source: skills/economics-analysis/SKILL.md

**R-SOC-002: Instrumental Variables Diagnostics**
- First-stage F-statistic must exceed 10 (Staiger-Stock rule of thumb)
- Weak instruments bias 2SLS toward OLS
- Report first-stage regression alongside second-stage results
- Implementation: `linearmodels.iv.IV2SLS`

> Source: skills/economics-analysis/SKILL.md

**R-SOC-003: Difference-in-Differences Requirements**
- MUST test parallel trends assumption before analysis
- Cluster standard errors at treatment level
- Include unit and time fixed effects
- DiD estimate = coefficient on `treated * post` interaction term
- Implementation: `smf.ols('outcome ~ treated * post + C(unit) + C(time)', data=df).fit(cov_type='cluster', cov_kwds={'groups': df['unit']})`

> Source: skills/economics-analysis/SKILL.md

**R-SOC-004: Regression Discontinuity**
- Local linear regression around cutoff with appropriate bandwidth
- Bandwidth selection: Imbens-Kalyanaraman optimal or cross-validation
- RDD estimate = discontinuity in predicted outcome at cutoff
- Sensitivity: test multiple bandwidths, polynomial orders
- McCrary density test: verify no manipulation at cutoff

> Source: skills/economics-analysis/SKILL.md

---

## 2. Panel Data Analysis

**R-SOC-010: Fixed vs. Random Effects**
- Fixed effects (FE): controls for time-invariant unobservables
- Random effects (RE): more efficient but assumes no correlation with regressors
- Hausman test: if significant, use fixed effects
- Cluster standard errors at entity level for FE
- Implementation: `PanelOLS.from_formula('y ~ x1 + x2 + EntityEffects + TimeEffects', data=df).fit(cov_type='clustered', cluster_entity=True)`

> Source: skills/economics-analysis/SKILL.md

---

## 3. Standard Error Rules

**R-SOC-020: Default Standard Error Selection**
- Use robust (heteroskedasticity-consistent) standard errors by default
- Cluster standard errors at the level of treatment assignment
- For panel data: cluster at entity level
- For DiD: cluster at treatment group level
- HAC (Newey-West) for time series with autocorrelation
- NEVER report unclustered SEs when data has group structure

> Source: skills/economics-analysis/SKILL.md, skills/social-science-research/SKILL.md

---

## 4. Survey Design and Psychometrics

**R-SOC-030: Likert Scale Design**
- Use 5 or 7 points (odd number for neutral option)
- Mix positively and negatively worded items (reverse-code in analysis)
- Avoid double-barreled questions
- Pilot test with 10-20 respondents before full deployment

> Source: skills/social-science-analysis/SKILL.md

**R-SOC-031: Sampling Method Selection**
| Method | Use case | Key trade-off |
|---|---|---|
| Simple random | Known population, sampling frame available | Unbiased but needs frame |
| Stratified | Subgroup comparisons needed | Precise per stratum, complex |
| Cluster | Geographic spread | Cost-effective, higher design effect |
| Convenience | Exploratory only | Easy but NOT generalizable |
| Snowball | Hard-to-reach populations | Access hidden groups, selection bias |
| Quota | Ensure representation | Practical, not truly random |

> Source: skills/social-science-analysis/SKILL.md

**R-SOC-032: Reliability Standards (Cronbach's Alpha)**
- alpha > 0.9: excellent
- alpha > 0.8: good
- alpha > 0.7: acceptable (minimum threshold)
- alpha < 0.7: problematic — review items
- Report alpha for ALL scales used

> Source: skills/social-science-analysis/SKILL.md

**R-SOC-033: Factor Analysis Thresholds**
- Exploratory FA: items loading > 0.4 on a factor belong to that construct
- Determine number of factors: parallel analysis or scree plot
- Rotation: varimax (orthogonal) or promax (oblique)
- CFA/SEM fit indices:
  - CFI > 0.95 (good fit)
  - RMSEA < 0.06 (good fit)
  - SRMR < 0.08 (good fit)

> Source: skills/social-science-analysis/SKILL.md

**R-SOC-034: Inter-Coder Reliability (Cohen's Kappa)**
- kappa > 0.8: excellent agreement
- kappa 0.6-0.8: substantial agreement
- kappa 0.4-0.6: moderate agreement
- kappa < 0.4: poor — retrain coders
- **Rare-class caveat (kappa paradox):** these Landis-Koch bands assume roughly balanced categories. When one code is RARE (e.g. include/exclude in systematic-review screening, or a low-base-rate annotation), kappa collapses toward 0 even at high raw agreement. In that case report **Gwet's AC1** (designed for skewed marginals) **+ raw % agreement + marginal prevalence** alongside kappa, not kappa alone. (Retrieved 2026-06-13, https://mappedresearch.com/blog/inter-rater-reliability-screening.)

> Source: skills/social-science-analysis/SKILL.md; rare-class / Gwet's AC1 addition retrieved 2026-06-13

---

## 5. Qualitative Research Methods

**R-SOC-040: Thematic Analysis Protocol (Braun & Clarke)**
1. Familiarization: read and re-read data
2. Initial coding: generate codes systematically
3. Theme search: collate codes into potential themes
4. Theme review: check themes against coded extracts AND full dataset
5. Theme definition: name and define each theme
6. Report: select vivid examples, relate to research question

> Source: skills/social-science-analysis/SKILL.md

**R-SOC-041: Grounded Theory Stages**
1. Open coding
2. Axial coding
3. Selective coding
- Constant comparison method throughout
- Theoretical sampling until saturation
- Memo writing throughout all stages

> Source: skills/social-science-analysis/SKILL.md

---

## 6. Psychology Research

**R-SOC-050: Validated Assessment Instruments**
- Depression: PHQ-9, BDI-II
- Anxiety: GAD-7
- Cognitive screening: MMSE
- Must use validated scales with established psychometric properties
- Distinguish statistical significance from clinical significance

> Source: skills/psychology-research/SKILL.md

**R-SOC-051: Psychology Study Protocol**
1. Study design: identify variables, choose design (experimental, correlational, longitudinal)
2. Instrument selection: choose validated scales
3. Sample size: power analysis required
4. Analysis: appropriate statistics (t-test, ANOVA, regression, SEM)
5. Interpretation: report effect sizes alongside p-values

> Source: skills/psychology-research/SKILL.md

**R-SOC-052: APA Reporting Requirements**
- Report effect sizes alongside p-values (mandatory)
- Address potential confounds and biases
- Follow APA Ethics Code for human subjects
- Pre-register hypotheses and analysis plans (OSF, AsPredicted)

> Source: skills/psychology-research/SKILL.md, skills/social-science-analysis/SKILL.md

---

## 7. Education Research

**R-SOC-060: Effect Size Standards for Education**
- Cohen's d or Hedges' g for group comparisons
- Education-specific benchmarks:
  - d = 0.2: small effect
  - d = 0.4: medium effect
  - d = 0.6: large effect
- Translate to months of learning gain for K-12 (What Works Clearinghouse approach)

> Source: skills/education-research/SKILL.md

**R-SOC-061: Multilevel Modeling (HLM)**
- Required for nested data: students within classrooms within schools
- Report ICC (intraclass correlation) to justify multilevel approach
- Include covariates: prior achievement, demographics
- Report: fixed effects, random effects, ICC, variance explained
- Tools: R lme4, HLM software

> Source: skills/education-research/SKILL.md

**R-SOC-062: Assessment Item Analysis**
- Difficulty index: proportion answering correctly
- Discrimination index: correlation with total score
- Point-biserial correlation for each item
- Reliability: Cronbach's alpha, test-retest, inter-rater

> Source: skills/education-research/SKILL.md

**R-SOC-063: Bloom's Taxonomy for Learning Objectives**
- Six levels (low to high): Remember, Understand, Apply, Analyze, Evaluate, Create
- Assessment items must align with stated learning objectives
- Document implementation fidelity (did intervention happen as planned?)

> Source: skills/education-research/SKILL.md

**R-SOC-064: Evidence Synthesis Sources**
- What Works Clearinghouse (WWC): US education evidence reviews
- EPPI-Centre: UK evidence synthesis
- Campbell Collaboration: social science systematic reviews
- Compare findings against existing evidence base

> Source: skills/education-research/SKILL.md

---

## 8. Political Science

**R-SOC-070: Key Datasets**
- VoteView (DW-NOMINATE): Congressional ideology scores
- V-Dem: 400+ democracy indicators, 202 countries, since 1789
- PolitiFact: 6-level truth ratings for political statements

> Source: skills/political-science/SKILL.md

**R-SOC-071: Political Analysis Rules**
- Maintain political neutrality — analyze evidence, do NOT advocate positions
- Distinguish descriptive claims from normative claims
- Report confidence intervals and uncertainty in all predictions
- Cite primary data sources (government statistics, peer-reviewed research)
- Acknowledge when evidence is insufficient to draw conclusions

> Source: skills/political-science/SKILL.md

---

## 9. Social Network Analysis

**R-SOC-080: Network Metrics**
- Centrality measures: degree, betweenness, closeness, eigenvector
- Network statistics: density, clustering coefficient
- Community detection: greedy modularity or Louvain
- Implementation: NetworkX (`nx.degree_centrality`, `nx.betweenness_centrality`)

> Source: skills/social-science-analysis/SKILL.md

---

## 10. Research Integrity Standards

**R-SOC-090: Mandatory Practices**
- Pre-register hypotheses and analysis plans for confirmatory research
- IRB / ethics approval is mandatory for human subjects research
- Report ALL specifications tested, not only significant ones
- Distinguish correlation from causation in all interpretive text
- Multiple imputation or bounds analysis for missing data sensitivity
- Document positionality for qualitative research
- Mixed methods: clearly state the integration strategy

> Source: skills/social-science-research/SKILL.md, skills/social-science-analysis/SKILL.md

**R-SOC-091: Reporting Standards by Discipline**
| Discipline | Standard |
|---|---|
| Psychology | APA 7th edition |
| Economics | AER style |
| Political Science | APSR style |
| Clinical trials | CONSORT |
| Observational studies | STROBE |
| Education | APA + WWC standards |

> Source: skills/social-science-research/SKILL.md, skills/psychology-research/SKILL.md

**R-SOC-092: Statistical Reporting Minimums**
- Always report: effect sizes alongside p-values
- Always report: 95% confidence intervals
- Always report: sample sizes
- Always report: economic significance alongside statistical significance (for economics)
- Use power analysis for sample size determination
- Report both absolute and relative measures

> Source: skills/economics-analysis/SKILL.md, skills/psychology-research/SKILL.md

---

## 11. Economic Data Sources

**R-SOC-095: Public Data APIs**
| Source | Data coverage | Access |
|---|---|---|
| FRED (St. Louis Fed) | US macro data | REST API (key required) |
| World Bank | Global development indicators | REST API (open) |
| IMF | International finance | REST API |
| BLS | US labor statistics | REST API |
| OECD | OECD country data | REST API |
| Penn World Table | Cross-country GDP | Download |
| CNKI / CSMAR | Chinese economic data | Institutional access |

> Source: skills/economics-analysis/SKILL.md

---

## 12. Game Theory

**R-SOC-098: Nash Equilibrium**
- Pure strategy: check all strategy profiles where each player's choice is best response to other
- Identify: dominant strategies, Pareto optimal outcomes
- Implementation: exhaustive search for finite games; `scipy.optimize.linprog` for mixed strategies

> Source: skills/economics-analysis/SKILL.md
