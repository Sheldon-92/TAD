# Expert Review: Trajectory Eval Harness Phase 1
## Reviewer: data-analyst
## Focus: Measurement Methodology
## Date: 2026-07-02
## Handoff: HANDOFF-20260702-trajectory-eval-p1.md

---

## Overall Assessment

**CONDITIONAL PASS**

The handoff is structurally sound and reflects genuine care about measurement integrity (Anti-Goodhart NFR, honest-coverage NFR, Claims-Need-Carriers enforcement). However, four measurement-methodology issues exist that, if unaddressed, will undermine the golden set's fitness as calibration ground truth for Phase 2. Three of these are P0 (must fix before Blake implements). One is a boundary condition that needs an explicit protocol.

---

## 1. Critical Issues (P0 — must fix before implementation)

### P0-1: n=10 is statistically underpowered for a Spearman ≥0.7 pivot threshold

**The problem.** At n=10, the 95% confidence interval for a measured Spearman r=0.7 spans roughly ±0.28 (Fisher z-transform). This means a true population correlation of 0.42 is statistically indistinguishable from 0.70 at this sample size. The Phase 2 pivot threshold ("Spearman ≥0.7 or within-1 ≥80%") cannot be evaluated with any reliability against a 10-entry golden set — you cannot know if the judge passed because it genuinely correlates well or because the sample happened to rank the 10 items conveniently.

**What makes it worse.** The handoff's proposed composition — ≥4 known-good, ≥2 known-bad, rest mixed — will likely produce a bimodal score distribution (good cluster near 4-5, bad cluster near 1-2). Spearman applied to a bimodal distribution at n=10 with few middling ranks effectively becomes a group comparison, not a rank correlation. Measured r will be artificially inflated relative to what it would be on a uniformly distributed set.

**Required fix options (Alex must choose one).**
- Option A (preferred): Raise minimum to n=25. At n=25 with r=0.7, the 95% CI narrows to approximately ±0.15 — sufficient to distinguish a useful judge from a chance one. Adjust Phase C to "≥25 trajectories" and update AC6.
- Option B (acceptable): Keep n=10 but document the CI explicitly in the handoff's §9 preamble and lower the Phase 2 go/no-go threshold accordingly. At n=10, a ρ≥0.75 measured value corresponds roughly to a lower-bound CI of ~0.47 at α=0.05 — that is still not strong evidence. If n=10 is hard-constrained, the Phase 2 claim should be framed as "pilot calibration" with explicit uncertainty language, not a binary pivot gate.
- Option C (minimum bar): Add a mandatory score-variance pre-check before computing Spearman: the golden set must span at least 3 distinct score levels per dimension (e.g., at least one trajectory scoring ≤2, at least one scoring 3, at least one scoring ≥4 per dimension). If any dimension is degenerate (only 2 levels), that dimension's Spearman is undefined for Phase 2 purposes and must be flagged.

**AC implication.** AC6 currently reads ≥10. If Option A is chosen, update to ≥25. If Options B or C, add an AC for score-variance pre-check (e.g., `for each dimension, count distinct score values across golden set ≥ 3`).

---

### P0-2: Draft-then-confirm labeling introduces anchoring bias that invalidates "ground truth" status

**The problem.** The labeling protocol is: Blake drafts per-dimension scores → human confirms. This is a classic anchoring setup. The cognitive-science literature on anchoring (Tversky & Kahneman 1974, Mussweiler & Strack 1999) consistently shows confirmation rates for pre-existing numerical estimates exceed 70-80% even when the anchor is known to be unreliable. The handoff's own §1.3 prohibits "agent 自己确认标注就算数" — but the draft-then-confirm workflow is structurally identical to agent confirmation with a human rubber stamp. The human is not scoring independently; they are reviewing a draft, which primes their judgment.

With a single labeler and no blinding protocol, inter-rater reliability (IRR) cannot be computed. A golden set with uncomputable IRR is not demonstrably "golden" — it is "whatever Blake said, with human non-objection."

**Additional issue: single labeler.** One human reviewer means systematic personal biases (e.g., leniency bias on recent well-known trajectories, severity bias on notorious incidents) cannot be detected or corrected. The Phase 2 Spearman will measure judge-vs-human-Blake-confirmed-draft, not judge-vs-ground-truth.

**Required fix.** Add a blinding step to the Phase C protocol:
1. Blake drafts rationale only (no numeric score) for each dimension.
2. Human reviewer reads bundle independently and assigns their own scores (blind to Blake's).
3. Human and Blake scores are compared. Where |human - Blake| ≤ 1, use human score. Where |human - Blake| ≥ 2, that entry is flagged for discussion before finalizing.
4. Record both scores in the GS file under separate fields (`blake_score` / `human_score` / `final_score`) so Phase 2 can analyze labeler agreement.

Alternatively, if a two-pass process is operationally infeasible, add a minimum requirement: human reviewer must provide at least 3 score overrides (changes from Blake's draft) across the 10 entries. If zero overrides occur, the golden set is flagged as potentially anchoring-contaminated.

**AC implication.** Add AC: `grep -c 'human_score:' .tad/eval/golden-set/GS-*.md` or equivalent to verify the labeling protocol was executed.

---

### P0-3: Selection-on-notoriety bias in known-bad candidates inflates Phase 2 discriminative gap

**The problem.** All three known-bad candidates (§4.2D) are famous incidents that became principles.md entries — they are notable precisely because they were extreme enough to generate institutional learning. They represent the far tail of the "bad" distribution, not the bulk of it.

The Phase 2 discriminative gap threshold (≥1.5 between known-good and known-bad group means) will be trivially satisfied by extreme outliers. Express plain-language (self-caught 4 P0), sep-phase2 claims-without-carriers (zero evidence files), and surplus-scan validation theater (4 expert reviews PASS then 2 live bugs) are all catastrophic failures — any reasonable rubric will score them near 1-2. A gap of ≥1.5 against these cases only proves the judge can detect catastrophic failures, not that it can discriminate mediocre-from-good trajectories, which is where the real operational value lies.

**Required fix.** Replace at least one of the three known-bad candidates with a "quietly bad" trajectory: a handoff that passed all Gates at the time but was later identified as having quality problems (e.g., a trajectory where the completion was superficially valid but a subsequent phase exposed a design gap). If no such trajectory is identifiable from the archive, this is itself a gap worth noting — it means the TAD archive has no documented record of "passes-Gates-but-still-bad" trajectories, which is a useful audit finding.

Additionally, add a label-class distribution constraint to §6 Phase C step 1: "at least 1 known-bad entry must score 2-3 (not 1) on at least two dimensions — to test the judge's middle-range discrimination, not just floor-detection."

**AC implication.** No mechanical AC possible for this, but add a note to Phase C step 1 requiring explicit justification for each known-bad selection: "why is this trajectory representative of the bad distribution rather than just the most extreme case?"

---

### P0-4: No explicit UNRECOVERABLE dimension handling — golden set may have incomparable entries

**The problem.** §8.3 Edge Cases correctly notes that older trajectories lack trace events (UNRECOVERABLE). But the golden set format (§4.2C) has no mechanism for recording UNRECOVERABLE at the per-dimension level. This creates a silent incomparability problem: an older GS entry might score D1-D3 (handoff/completion-derived) but have UNRECOVERABLE for D4 (trace-dependent). A newer entry scores all 5 dimensions. Phase 2's Spearman will be computed over these incomparable vectors — or the Phase 2 implementer will have to make an ad-hoc decision about how to handle NaN values.

**Required fix.** Extend the GS file format (§4.2C) to support an explicit UNRECOVERABLE token:

```markdown
scores:
  D1: 3
  D2: UNRECOVERABLE
  ...
```

And add a Phase 2 pre-commitment rule in the handoff: "Spearman will be computed only over entries where all dimensions are RECOVERABLE. UNRECOVERABLE entries are excluded from correlation computation but included in the discriminative gap analysis if ≥3 dimensions are scoreable."

This decision must be made in Phase 1 (here), not left to Phase 2 — otherwise Phase 2 inherits an ambiguous golden set.

**AC implication.** Add AC: for each GS entry, dimensions are either integer 1-5 or the string "UNRECOVERABLE" — no blank cells. Example: `grep -E '^  D[0-9]+: ([1-5]|UNRECOVERABLE)$'`.

---

## 2. Recommendations (P1 — should address)

### P1-1: MECE self-check (§6 Phase B step 3) is not mechanically operationalizable

The MECE check is defined as "no two dimensions describe the same artifact's same attribute." This is semantically correct but requires judgment to apply — there is no grep/awk command that can verify it. Dimensions can have different data sources yet measure correlated constructs (e.g., "verification completeness" and "constraint compliance" are likely highly correlated because conscientious executions tend to be strong on both). The handoff's MECE test catches operational redundancy (same data source) but not conceptual redundancy (correlated constructs).

**Recommendation.** After Blake drafts rubric and before starting golden set scoring, add a step: compute pairwise Spearman correlation between dimension scores across the golden set. If any pair has r > 0.75, flag for dimension redesign before Phase 2. This is a post-scoring check — document it as a Phase C exit criterion, not just Phase B. Add to §6 Phase C: "After scoring all 10 entries, compute D×D score correlation matrix. Any pair r > 0.75 is a MECE violation at the construct level — return to Phase B."

### P1-2: "Within-1 ≥80%" pivot metric has no golden-set-level specification

The Phase 2 pivot threshold includes "within-1 ≥80% vs golden labels." This metric requires knowing what "within 1" means for each label — specifically, whether a judge score of 3 is "within 1" of a ground truth of 4 or 2. This is well-defined for integer scores, but the golden set format has no uncertainty band. If a labeler was genuinely uncertain between 3 and 4 for a dimension, only one value gets recorded, and a judge that scores 3 when ground truth is recorded as 4 gets a "1 apart" demerit even though the label itself was uncertain.

**Recommendation.** Add an optional `score_confidence: high/medium` field to the GS frontmatter's per-dimension scores. Medium confidence scores should be counted as within-1 if the judge scores ±1, and not penalized at the boundary. At minimum, the format should allow recording labeler uncertainty so Phase 2 can apply a confidence-weighted within-1 metric.

### P1-3: Stratification missing gate-outcome dimension

The stratification is code/yaml/research × early/mid/late. Gate outcome (PASS/FAIL/PARTIAL) is a strong predictor of trajectory quality and is one of the most relevant stratification variables for a rubric designed around gate quality. If all 10 sampled trajectories happen to be PASSes (likely, since PASS trajectories are more common), the golden set will under-represent the failure modes the rubric is designed to detect.

**Recommendation.** Add gate-outcome (PASS/at-least-one-FAIL/PARTIAL) as a third stratification dimension, even informally. At minimum, require that at least 3 of the 10 audit-sampled trajectories have a non-PASS gate history.

### P1-4: Trace event asymmetry will constrain rubric dimensions to existence-level scoring

The trace event distribution (1179 evidence_created / 922 handoff_created / 66 gate_result / 72 expert_review_finding) is heavily weighted toward existence events rather than quality-content events. A rubric dimension that relies on trace data for scoring will effectively be a binary existence dimension masquerading as a 1-5 quality dimension. For example, "expert_review_finding" events may record that a review occurred but not its depth or findings.

**Recommendation.** Explicitly classify rubric dimensions in §4.2B into two groups: (a) existence-anchored dimensions (1 = absent, 5 = fully present with specific attributes — driven by trace events), and (b) quality-anchored dimensions (1-5 describes quality gradient independent of existence — driven by artifact content). Phase 2's judge architecture should use different evidence sources for each group. Avoid designing existence-anchored dimensions that look quality-anchored in the anchor text.

---

## 3. Suggestions (P2 — nice to have)

### P2-1: Epoch-stratification should explicitly guard against confounding trace completeness with quality class

If known-good trajectories are recent (trace-complete) and known-bad trajectories are old (trace-incomplete), then any rubric dimension dependent on trace data will score known-good higher for a confounding reason (data exists) rather than a quality reason (execution was better). The Phase 2 judge will then learn "recent = good" rather than "high-quality execution = good."

Suggestion: record the mean trajectory age for known-good vs known-bad in the INDEX.md metadata. Flag if the age gap is > 6 months.

### P2-2: Add a modal score concentration check as a rubric health metric

After scoring all golden set entries per dimension, check whether any single score value accounts for > 50% of labels on that dimension. A dimension where 8/10 trajectories score 4 is not calibrating anything — it has near-zero variance and will contribute near-zero information to Spearman. This check requires only a count operation and can be automated.

Suggestion: add to Phase C exit criteria: "No dimension may have > 50% of golden set entries at the same integer value." If violated, the anchor descriptions for that dimension need revision before proceeding to Phase 2.

### P2-3: At least one "quietly bad" trajectory — passed Gates but had downstream quality problems

The three known-bad candidates are all notable post-mortems. Consider whether there are trajectories that passed all four Gates but were later recognized as weak (e.g., a feature that required revisit within 2 sprints, a handoff whose architecture was superseded by a follow-on phase). These "quietly bad" entries test whether the rubric captures subtle quality signals, not just catastrophic failure patterns.

### P2-4: Document the Phase 2 Spearman calculation details in Phase 1

Phase 1 should pre-commit to the exact Spearman computation method for Phase 2: (a) are per-dimension Spearman values averaged, or is a composite score computed and then correlated? (b) how are ties in the golden set human labels handled (average rank, ordinal)? Leaving this to Phase 2 risks post-hoc optimization of the computation to pass the threshold.

---

## Summary Table

| ID | Category | Issue | Severity | AC Impact |
|----|----------|-------|----------|-----------|
| P0-1 | Golden set composition | n=10 underpowered; bimodal distribution degrades Spearman | P0 | AC6: raise minimum or add variance AC |
| P0-2 | Labeling methodology | Draft-then-confirm anchoring; single labeler; no IRR | P0 | Add blinding step or override-count AC |
| P0-3 | Sampling (known-bad) | Selection-on-notoriety bias; extreme cases inflate discriminative gap | P0 | Phase C step 1: require non-extreme known-bad |
| P0-4 | UNRECOVERABLE handling | No per-dimension UNRECOVERABLE token; incomparable GS entries | P0 | Extend §4.2C format; add token AC |
| P1-1 | Rubric MECE | Conceptual correlation not detected by data-source MECE check | P1 | Add post-scoring D×D correlation check |
| P1-2 | Within-1 metric | No uncertainty band on labels; boundary cases penalized unfairly | P1 | Add score_confidence field |
| P1-3 | Stratification | Gate-outcome missing from stratification dimensions | P1 | Require ≥3 non-PASS trajectories in sample |
| P1-4 | Rubric dimension design | Trace events → existence-level scoring disguised as quality scale | P1 | Classify dimensions as existence vs quality |
| P2-1 | Confounding | Age correlation with trace completeness may confound judge | P2 | Record mean age per label class |
| P2-2 | Rubric health | Modal score concentration check missing | P2 | Add >50% concentration exit criterion |
| P2-3 | Known-bad coverage | No "quietly bad" trajectory in known-bad candidates | P2 | Add 1 non-notorious known-bad |
| P2-4 | Phase 2 pre-commitment | Spearman computation method not specified in Phase 1 | P2 | Document correlation method in Phase 1 |

---

*Reviewer: data-analyst | Scope: measurement methodology only | Does not cover AC command correctness (code-reviewer scope)*
