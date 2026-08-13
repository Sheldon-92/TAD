# Extracted Statistics Rules

Judgment rules with specific thresholds from ScienceClaw statistics skills.
Every rule traced to source. Generic advice excluded.

---

## 1. Statistical Test Selection

### Two-Group Comparisons

| Data | Normal | Non-normal |
|------|--------|------------|
| Independent, continuous | Independent t-test | Mann-Whitney U |
| Paired, continuous | Paired t-test | Wilcoxon signed-rank |
| Binary outcome | Chi-square test | Fisher's exact test |

> Source: skills/statistical-analysis/SKILL.md, skills/data-analysis/SKILL.md

### Three-or-More Group Comparisons

| Data | Normal | Non-normal |
|------|--------|------------|
| Independent, continuous | One-way ANOVA | Kruskal-Wallis |
| Paired, continuous | Repeated measures ANOVA | Friedman test |

> Source: skills/statistical-analysis/SKILL.md, skills/data-analysis/SKILL.md

### Relationship Tests

| Scenario | Normal | Non-normal |
|----------|--------|------------|
| Two continuous variables | Pearson r | Spearman rho |
| Continuous outcome + predictors | Linear regression | — |
| Binary outcome + predictors | Logistic regression | — |

> Source: skills/statistical-analysis/SKILL.md

### Normality Assumption Violation Rules

- Mild violation + n > 30 per group: proceed with parametric test (robust).
- Moderate violation: use non-parametric alternative.
- Severe violation: transform data or use non-parametric test.
- Homogeneity of variance violated for t-test: use Welch's t-test.
- Homogeneity of variance violated for ANOVA: use Welch's ANOVA or Brown-Forsythe.

> Source: skills/statistical-analysis/SKILL.md

### Welch's t-test as Default

Use `equal_var=False` (Welch's) for two-sample t-tests unless equal variance is confirmed.

> Source: skills/scipy-analysis/SKILL.md

### Normality Test Selection

- Shapiro-Wilk: small samples.
- Kolmogorov-Smirnov: larger samples.

> Source: skills/scipy-analysis/SKILL.md

---

## 2. Effect Size Thresholds

### Cohen's Conventions

| Test | Effect Size Metric | Small | Medium | Large |
|------|-------------------|-------|--------|-------|
| t-test | Cohen's d | 0.2 | 0.5 | 0.8 |
| ANOVA | eta-squared (partial) | 0.01 | 0.06 | 0.14 |
| Correlation | r | 0.1 | 0.3 | 0.5 |
| Chi-square | Cramer's V | 0.1 | 0.3 | 0.5 |
| Regression | R-squared | 0.02 | 0.13 | 0.26 |

> Source: skills/statistical-testing/SKILL.md, skills/statistical-analysis/SKILL.md

Note: Cramer's V thresholds are df-dependent. For df=1: 0.1/0.3/0.5 (table above). For df≥2: 0.07/0.21/0.35. For df≥3: consult Cohen (1988) table.

> Source: skills/statistical-analysis/SKILL.md (df-dependent variant)

---

## 3. Power Analysis

### Standard Parameters

- Default power target: 0.80 (80%).
- Default alpha: 0.05.
- Standard effect sizes for sample size planning: d=0.5 (medium) for t-test, f=0.25 for ANOVA.

> Source: skills/statistical-analysis/SKILL.md

Use `tt_ind_solve_power()` and `FTestAnovaPower().solve_power()` from `statsmodels.stats.power`.
Post-hoc power analysis is not recommended. Use sensitivity analysis instead.

> Source: skills/statistical-analysis/SKILL.md

---

## 4. Multiple Comparison Corrections

- Bonferroni: most conservative, controls family-wise error rate.
- Benjamini-Hochberg (FDR): controls false discovery rate at FDR < 0.05. Use `multipletests(p_values, method='fdr_bh', alpha=0.05)`.
- Holm: step-down Bonferroni (less conservative).

> Source: skills/statistical-testing/SKILL.md

### Post-Hoc Tests for ANOVA

When ANOVA is significant (p < 0.05), conduct pairwise comparisons with Tukey's HSD.

> Source: skills/statistical-analysis/SKILL.md, skills/statsmodels/SKILL.md

---

## 5. Meta-Analysis

### DerSimonian-Laird Random-Effects Model

Default model: random-effects (studies rarely share a true common effect).

Core formula:
- Fixed-effect weights: w_i = 1 / v_i (inverse variance)
- Cochran's Q = sum(w_i * (effect_i - pooled_fe)^2)
- tau-squared = max(0, (Q - df) / C) where C = sum(w) - sum(w^2)/sum(w)
- Random-effects weights: w_re_i = 1 / (v_i + tau^2)
- 95% CI: pooled +/- 1.96 * SE

> Source: skills/meta-analysis/SKILL.md

### Heterogeneity Assessment

| I-squared | Interpretation |
|-----------|---------------|
| 0-25% | Low heterogeneity |
| 25-50% | Moderate heterogeneity |
| 50-75% | Substantial heterogeneity |
| 75-100% | Considerable heterogeneity |

When I-squared > 50%, investigate sources via:
1. Subgroup analysis (by study design, population, dose).
2. Meta-regression (effect as function of study-level covariates).
3. Sensitivity analysis (leave-one-out, exclude high risk-of-bias).

> Source: skills/meta-analysis/SKILL.md

### Publication Bias Detection

- **Egger's regression test**: intercept p < 0.10 indicates significant funnel asymmetry.
- **Begg's rank correlation test**: Kendall's tau of effect sizes vs. variances.
- **Trim-and-fill**: imputes missing studies, re-estimates pooled effect.
- **Funnel plot**: minimum 5-10 studies for reliable interpretation.

> Source: skills/meta-analysis/SKILL.md

### Effect Size Types by Outcome

| Outcome | Metric | Use When |
|---------|--------|----------|
| Continuous (different scales) | SMD (Hedges' g preferred over Cohen's d) | Comparing means, small-sample correction |
| Continuous (same scale) | Mean Difference (MD) | Same measure across studies |
| Binary | Odds Ratio (OR) | Case-control, binary outcomes |
| Binary | Risk Ratio (RR) | Cohort, clinical trials |
| Binary | Risk Difference (RD) | Absolute risk reduction |
| Time-to-event | Hazard Ratio (HR) | Survival analysis |
| Correlation | Fisher's z = 0.5*ln((1+r)/(1-r)) | Correlation studies |

Use Hedges' g rather than Cohen's d for small-sample correction. Log-transform ORs and RRs before pooling; back-transform for reporting.

> Source: skills/meta-analysis/SKILL.md

### Meta-Analysis Reporting (PRISMA 2020)

Must include:
1. Number of studies (k) and total participants (N).
2. Pooled effect size with 95% CI.
3. Heterogeneity: Q statistic (df, p), I-squared, tau-squared.
4. Model type (fixed vs. random) with justification.
5. Publication bias assessment results.
6. Forest plot and funnel plot as figures.

> Source: skills/meta-analysis/SKILL.md

---

## 6. Biostatistics: Clinical Research Rules

### Cox Regression

- Events per variable (EPV) >= 10 for Cox proportional hazards.
- Check proportional hazards assumption with Schoenfeld residuals or log-log plots.
- If violated: use time-varying coefficients, stratified Cox, or RMST.
- Report hazard ratios with 95% CIs.

> Source: skills/biostatistics/SKILL.md

### Competing Risks

When multiple event types exist: use cumulative incidence functions (NOT 1-KM). Apply Fine-Gray subdistribution hazard model.

> Source: skills/biostatistics/SKILL.md

### Diagnostic Test Evaluation

- Compute sensitivity, specificity, PPV, NPV at defined cutoffs.
- ROC curve with AUC and DeLong confidence intervals.
- For biomarker discovery: apply cross-validation to avoid overoptimism.

> Source: skills/biostatistics/SKILL.md

### Missing Data

- Classify mechanism: MCAR, MAR, MNAR.
- For MAR: multiple imputation with m >= 20 imputations, pool via Rubin's rules.
- Conduct sensitivity analysis under MNAR assumptions.

> Source: skills/biostatistics/SKILL.md

### Survival Analysis Log-Rank Variants

- Standard log-rank: proportional hazards assumed.
- Wilcoxon or Tarone-Ware weighted variants: for non-proportional hazards.

> Source: skills/biostatistics/SKILL.md

---

## 7. Regression Diagnostics

### Multicollinearity

VIF (Variance Inflation Factor): concern when VIF > 5-10. Report "all VIF < X" in results.

> Source: skills/statistical-analysis/SKILL.md, skills/statsmodels/SKILL.md

### Heteroskedasticity

- Breusch-Pagan test: p < 0.05 indicates heteroskedasticity.
- Remedy: use robust standard errors (HC0-HC3) or weighted least squares.

> Source: skills/statsmodels/SKILL.md

### Overdispersion (Count Data)

Pearson chi-squared / residual df > 1.5: use Negative Binomial instead of Poisson.

> Source: skills/statsmodels/SKILL.md

### Model Comparison

- Nested models: Likelihood Ratio test (chi-squared).
- Non-nested models: AIC/BIC (lower is better). Do NOT use LR test for non-nested.

> Source: skills/statsmodels/SKILL.md

### Time Series Stationarity

ADF (Augmented Dickey-Fuller) test: p > 0.05 means non-stationary, must difference.

> Source: skills/statsmodels/SKILL.md

---

## 8. APA Reporting Format

### Required Elements

1. Descriptive statistics: M, SD, n for all groups.
2. Test statistic with degrees of freedom.
3. Exact p-value (not "p < .05" unless p < .001).
4. Effect size with confidence interval.
5. Assumption checks performed and results.

> Source: skills/statistical-analysis/SKILL.md, skills/statistical-testing/SKILL.md

### Templates

**t-test**: `t(df) = X.XX, p = .XXX, d = X.XX, 95% CI [X.XX, X.XX]`

**ANOVA**: `F(df1, df2) = X.XX, p < .001, partial eta-squared = .XX`

**Regression**: `F(df1, df2) = X.XX, p < .001, R-squared = .XX, adjusted R-squared = .XX`
Per predictor: `B = X.XX, SE = X.XX, beta = .XX, t = X.XX, p = .XXX, 95% CI [X.XX, X.XX]`

**Bayesian**: Report BF10 with interpretation, posterior mean, 95% credible interval, convergence (R-hat < 1.01, ESS > 1000).

> Source: skills/statistical-analysis/SKILL.md, skills/statistical-testing/SKILL.md

### Bayesian BF10 Scale

BF > 100 extreme | 30-100 very strong | 10-30 strong | 3-10 moderate | 1-3 anecdotal | < 1 favors null.

> Source: skills/statistical-testing/SKILL.md

---

## 9. ML Evaluation Metrics

### Classification

- **Balanced data**: Accuracy, F1-score.
- **Imbalanced data**: Precision, Recall, ROC AUC, Balanced Accuracy.
- Always use `stratify=y` in train/test split to preserve class distribution.

> Source: skills/scikit-learn/SKILL.md

### Clustering

- Silhouette score (higher is better, range -1 to 1).
- Calinski-Harabasz index (higher is better).
- Davies-Bouldin index (lower is better).

> Source: skills/scikit-learn/SKILL.md

### Regression

- MSE, RMSE, MAE, R-squared, MAPE.

> Source: skills/scikit-learn/SKILL.md

### Cross-Validation

- Default: 5-fold (`cv=5`).
- Classification: use `StratifiedKFold`.
- Temporal data: use `TimeSeriesSplit`.
- Grouped samples: use `GroupKFold`.

> Source: skills/scikit-learn/SKILL.md

### Feature Scaling Required For

SVM, KNN, Neural Networks, PCA, regularized Linear/Logistic Regression, K-Means.

NOT required for: Tree-based models (Decision Trees, Random Forest, Gradient Boosting), Naive Bayes.

> Source: skills/scikit-learn/SKILL.md

---

## 10. Data Quality Rules

### Outlier Detection (IQR Method)

Q1, Q3 = 25th, 75th percentiles. IQR = Q3 - Q1.
Outlier if value < Q1 - 1.5*IQR or > Q3 + 1.5*IQR.

> Source: skills/data-analysis/SKILL.md, skills/scipy-analysis/SKILL.md

### Sample Standard Deviation

Always use `ddof=1` for sample standard deviation (`np.std(arr, ddof=1)`).

> Source: skills/scipy-analysis/SKILL.md

### Bootstrap Confidence Intervals

Default: n_boot = 10000 resamples for bootstrap CI.

> Source: skills/statistical-testing/SKILL.md

### Permutation Test

Default: n_perm = 10000 permutations. Two-sided p = count(|perm_diff| >= |observed|) / n_perm.

> Source: skills/statistical-testing/SKILL.md

---

## 11. Zero-Hallucination Rules

- NEVER generate fictional study names, sample sizes, effect sizes, DOIs, or citation details.
- If insufficient data for meta-analysis, say so explicitly.

> Source: skills/meta-analysis/SKILL.md, skills/data-extractor/SKILL.md
