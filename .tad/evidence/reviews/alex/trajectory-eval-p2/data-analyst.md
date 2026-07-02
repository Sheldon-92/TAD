# Measurement-Methodology Review — Trajectory Eval P2 Handoff
## Reviewer: data-analyst
## Date: 2026-07-02
## Scope: §2.1, §4.2, §4.4, §9.1, §10.2 of HANDOFF-20260702-trajectory-eval-p2.md + rubric.md + golden-set INDEX.md

---

## Denominator Grounding (pre-review arithmetic)

Before findings, I verify the baseline numbers the ACs and gate thresholds depend on.

**Golden UNRECOVERABLE breakdown (from INDEX.md):**

| Trajectory | UNRECOVERABLE dims | Numeric dims |
|---|---|---|
| GS-01 | D1,D3,D4,D5 | D2 only (1) |
| GS-02 | D1,D3,D4,D5 | D2 only (1) |
| GS-03 | none | D1-D5 (5) |
| GS-04 | D1,D3,D4,D5 | D2 only (1) |
| GS-05 | D4 | D1,D2,D3,D5 (4) |
| GS-06 | none | D1-D5 (5) |
| GS-07 | none | D1-D5 (5) |
| GS-08 | none | D1-D5 (5) |
| GS-09 | none | D1-D5 (5) |
| GS-10 | none | D1-D5 (5) |
| GS-11 | none | D1-D5 (5) |
| GS-12 | D1,D3,D4,D5 | D2 only (1) |
| **Total** | **17** | **43** |

Confirmed: 43 numeric matches §2.1 statement.

**Gate-eligible dims D1,D2,D3,D5 (D4 excluded):**

| Dim | Golden UNRECOVERABLE | Golden numeric |
|---|---|---|
| D1 | GS-01, GS-02, GS-04, GS-12 | 8 |
| D2 | none | 12 |
| D3 | GS-01, GS-02, GS-04, GS-12 | 8 |
| D5 | GS-01, GS-02, GS-04, GS-12 | 8 |
| **Total** | | **36** |

Confirmed: 36 ceiling pairs matches §2.1 "~36 pairs."

**Denominator sensitivity (one-pair cost):**

At n=36: 80% threshold = need ≥29 correct. Cost per miss = 1/36 = 2.78 pp. From the gate floor (29/36 = 80.6%), one additional miss yields 28/36 = 77.8% — gate FAILS.
At n=30: need ≥24 correct. Cost per miss = 1/30 = 3.33 pp.
At n=25: need ≥20 correct. Cost per miss = 1/25 = 4.0 pp.

**Wilson 95% CI for proportion at n=36, p=0.80 (observed 29/36):** approximately [0.64, 0.91]. An observed 80% on 36 pairs is consistent with a true rate anywhere from 64% to 91% — the gate is a binary screen, not a precise calibration estimate.

---

## 1. Critical Issues (P0)

### P0-1 — No minimum-pairs floor: judge UNRECOVERABLE overuse can game the denominator

**Location:** §4.4 配对规则 + §9.1 (no AC covers this)

The gate metric pools within-1 over D1,D2,D3,D5 pairwise-numeric pairs. The pairwise exclusion rule states: if EITHER golden OR judge is UNRECOVERABLE, the pair is excluded. The denominator ceiling is 36, but it is not bounded from below. There is no AC or constraint requiring a minimum number of valid pairs for the gate result to be considered valid.

**The gameable scenario:** The judge prompt instructs UNRECOVERABLE when "data is insufficient" — a subjective threshold. A judge that over-marks hard or ambiguous trajectories as UNRECOVERABLE on D1,D2,D3,D5 reduces the denominator. Example: if the judge marks 16 extra pairs UNRECOVERABLE (judge-side) on top of golden's existing exclusions, n drops from 36 to 20. At n=20, within-1 ≥80% requires only 16/20 correct — achievable by accurately scoring only the straightforward cases and excluding the difficult ones. The judge could achieve PASS without demonstrating any calibration on the most diagnostically informative trajectories.

The 4 pre-frontmatter trajectories (GS-01, GS-02, GS-04) and 1 YOLO trajectory (GS-12) have 3 dims each already excluded from the gate by golden UNRECOVERABLEs. If the judge additionally marks D2 UNRECOVERABLE on these 4 trajectories, the gate pool drops from 36 to 32. This is expected and legitimate. The risk is the judge marking D2 UNRECOVERABLE on trajectories with full golden coverage (GS-03 through GS-11).

**Required fix:** Add to §4.4 a validity pre-condition:

> Gate pre-condition: valid gate pairs ≥ 27 (= 75% of 36 ceiling). If judge-side UNRECOVERABLEs reduce D1+D2+D3+D5 valid pairs below 27, the gate result is INVALID (not PASS, not PIVOT). Treat as judge-prompt defect: diagnose which trajectories have unexpected UNRECOVERABLE marks, fix the prompt, rerun. This rerun does not consume an iteration round.

Add corresponding AC between AC6 and AC7: `jq` count of valid pairs per round, asserted ≥27 before gate computation is reported.

---

### P0-2 — Per-trajectory minimum-dims requirement missing for contrast-pair and anti-anchoring metrics

**Location:** §4.4 (对比对判别 + 反锚定 definitions)

The contrast-pair gate computes judge(GS-11 pooled mean) − judge(GS-03 pooled mean). The anti-anchoring gate computes judge(GS-06 pooled mean). All three trajectories have 5 eligible dims in golden (no golden UNRECOVERABLE). However, if the judge marks dims UNRECOVERABLE on these specific trajectories, the mean is computed over fewer dims.

**Instability example:** If the judge marks 3/5 dims UNRECOVERABLE on GS-11, the pooled mean is computed over 2 integer scores in {1,...,5}. For GS-11 (golden mean 5.00, all dims = 5), both remaining dims must score ≥4 to maintain mean ≥4.0. A judge that marks D1 and D3 UNRECOVERABLE on GS-11 and scores D2=5, D5=4 gets mean = 4.5 — contrast gap still likely passes — but the mean is computed over 2 scores, and neither AC nor §4.4 validates whether this mean is a reliable estimate.

More critically: if the judge marks 4/5 dims UNRECOVERABLE on GS-03 (known-bad, golden mean 2.80), the mean is a single score. If that single score happens to be high (e.g., D2=4), the judge-side GS-03 mean is 4.0 — collapsing the contrast gap to near zero. This would correctly trigger a PIVOT (contrast gap < 1.5), but the PIVOT is based on an artifact of UNRECOVERABLE over-use, not genuine discrimination failure.

**Required fix:** Add to §4.4 contrast-pair and anti-anchoring definitions:

> Trajectory mean validity: a trajectory's pooled mean is computed only if ≥3 dims are numeric on the judge side. If judge-side UNRECOVERABLE reduces a specific trajectory (GS-11, GS-03, or GS-06) to < 3 scoreable dims, treat as judge-prompt defect (not gate failure), diagnose, fix prompt, rerun without consuming an iteration round.

This should appear as a note in the §4.4 table and as a condition in the calibration report template.

---

## 2. Recommendations (P1)

### P1-1 — Rubric wording changes between rounds contaminate round-over-round comparability: require explicit audit trail

**Location:** §4.2C (运行协议), §4.4, AC8

The iteration protocol allows rubric wording clarifications in rounds 2 and 3 while keeping golden scores frozen. Golden was scored under rubric v1.0 + the D2 first-submission clarification added at Phase 1 Gate 4. If wording changes in round 2 alter the interpretation of a dimension — even subtly — the judge in round 2 is calibrating to a rubric that has drifted from the basis under which golden was scored. Within-1 against frozen golden then conflates two effects: (a) genuine improvement in judge calibration through better prompting, and (b) alignment to a rubric whose intent has shifted relative to golden.

AC8 currently checks only: `grep -cE '^calibration_verdict: (PASS|PIVOT)$'` + round count ≤3. It does not require any rubric-version declaration or diff documentation. A Blake who achieves PASS in round 3 after two wording changes has no current obligation to document what changed, making Gate 4 verification of "was this a real PASS?" impossible.

**Required fix:**

(a) Add to the calibration report template: a mandatory "FINAL SCORING BASIS" section declaring the final round number and any rubric diffs applied between rounds (verbatim changed lines, formatted as diff). If no wording changes were made, state explicitly: "rubric wording: unchanged from Phase 1 frozen version."

(b) Add to AC8: if the report contains rubric wording changes, Gate 4 must additionally verify that the changed wording does not alter the scoring intent for any golden trajectory (spot-check 2 affected dims against golden rationale).

(c) If PASS is achieved only in a round where wording changed (i.e., round 1 and 2 both failed, round 3 passed with wording change), require a note in the calibration report acknowledging this sequence.

---

### P1-2 — Single-eval stochasticity at n=12 creates gate-margin risk: mandate minimal variance probe

**Location:** §8.1-8.3, §4.4, §10.2

LLM Likert-scale scoring shows typical ±1 variation on 20-30% of dims across independent reruns for Sonnet-class models. With 36 gate pairs, if 8 pairs are borderline (|diff| = 1 exactly at first eval), stochastic re-scoring could move 3-5 of these to |diff| = 2 (misses) or vice versa, swinging the gate metric by ±8-14 percentage points. A gate result of 83% on one run could be 72% on the next — or vice versa — with no change in underlying judge quality.

The handoff places repeat evals as P2 (suggestion). Given that this gate is a binary go/no-go for Phase 3 (a non-trivial investment), the cost-benefit of a variance probe is strongly favorable: 2 additional fresh spawns (17% overhead over the 12-trajectory run) provides direct stochasticity data. Section 10.2 already acknowledges a ±0.05 carry-forward condition, but by the time you know the result is in the ±0.05 band, you have already used iteration rounds you might have preserved.

**Required fix:** Upgrade repeat-eval to P1 (mandatory) for a minimal probe: rerun 2 trajectories as fresh spawns — recommend GS-11 (top anchor, should be stable) and one of GS-09 or GS-06 (harder cases with ambiguous dims). This generates a "stochasticity signal" at negligible cost.

Report requirement: present the per-dim scores for the 2 rerun trajectories alongside original scores. If any dim changes by ≥2 points across evals, flag as "judge instability on [dim]" and require a diagnostic note before issuing PASS. If near the ±0.05 band (§10.2), the probe data feeds directly into the carry-forward decision at Gate 4.

---

### P1-3 — D2 first-submission anchor is systematically ambiguous in bundles: needs explicit bundle signal

**Location:** rubric.md D2 scoring-basis clarification, §4.2B (assemble-bundle.sh spec)

The D2 rubric clarification states: "Evidence repaired only after an external gate bounce does NOT lift the score above 3." This requires the judge to determine the temporal sequence of evidence production relative to gate submission. The assemble-bundle.sh spec includes "gate reports head 80" and "trace events by slug grep" — but trace events may not reliably establish whether specific review files or evidence artifacts were produced before or after a gate bounce, unless the trace timestamps are explicitly interleaved with file-creation timestamps in the bundle.

GS-09 was precisely the Phase 1 divergence case on D2 (rater 3 vs draft 5). The Phase 1 blind raters had access to the same artifacts and diverged by 2 points on this dimension. The Phase 2 judge, without any explicit temporal sequencing in the bundle, is likely to reproduce this divergence — not because of a rubric problem, but because the bundle does not make the first-submission sequence visible.

D2 has 12 golden numeric pairs — the highest of any gate dim — making it the single largest contributor to the within-1 pool. Systematic D2 divergence (e.g., 3 of 12 D2 pairs as |diff| = 2) directly costs ~8 pp from the gate metric (3/36 = 8.3 pp at n=36 full denominator).

**Required fix:** Add to §4.2B assemble-bundle.sh spec: "If trace events for this slug include gate_result events, include them in chronological order with ISO timestamps. If the trace includes multiple evidence-production events (expert_review_finding, acceptance_test_result), include their timestamps so the judge can establish the sequence relative to gate_result." Add a note in judge-prompt.md: "For D2, assess evidence based on what was demonstrably produced before the first gate submission. If bundle sequencing is ambiguous, state this in the D2 rationale and score conservatively per the rubric's anchor 3 definition."

---

## 3. Suggestions (P2)

### P2-1 — Spearman advisory at n=12 is statistically uninterpretable: add explicit caveat in report template

The §4.4 spec already notes "n=12 CI ±~0.28, 不作 gate" — this is correct. However, the CI note understates the practical problem. At n=12, an observed Spearman of r=0.5 has a 95% CI of approximately [0.06, 0.78], spanning from nearly zero to strong. No conclusion is possible.

Additionally, the class-mean inversion (known-good 2.94 < known-bad 3.30 in golden) guarantees that trajectory-level means are not monotonically ordered by label_class. A low or negative Spearman is therefore expected by construction, not evidence of judge failure. A reader not aware of the inversion might misinterpret a low Spearman as calibration failure.

**Suggestion:** Add a mandatory note in the calibration report template adjacent to the Spearman metric: "Spearman is reported for reference only. At n=12, no inference is possible (95% CI ±~0.28). The known class-mean inversion in golden (known-good 2.94 < known-bad 3.30) further makes a low Spearman expected by construction. This metric does not inform the PASS/PIVOT decision."

---

### P2-2 — The ±0.05 carry-forward condition (§10.2) is not machine-verifiable in AC8: add a trigger flag

Section 10.2 states: "若最终 gate 指标落在门槛 ±0.05 内：报告必须注明同族模型评审员 caveat，Gate 4 将按 Epic carry-forward #4 考虑加一轮 Codex 交叉评分再定 PASS/PIVOT." This is an important secondary decision path, but it appears only in the constraints section. AC8 currently checks only for `calibration_verdict: PASS|PIVOT` and round count ≤3. There is no AC that verifies the carry-forward caveat was documented when the condition is triggered.

If within-1 = 0.81 or 0.79 (within the ±0.05 band), Blake must add the caveat. But a Blake who reads AC8 without carefully reading §10.2 will check only the verdict line and miss the caveat requirement.

**Suggestion:** Add to AC8 verification method: "If any stop-loss gate metric is within ±0.05 of its threshold (within-1: [0.75, 0.85]; contrast-pair diff: [1.0, 2.0]; anti-anchoring: [3.0, 4.0]), report must contain `same_family_model_caveat: true`. Verify: `grep -c 'same_family_model_caveat: true' calibration-report-*.md`." This makes the condition verifiable by grep at Gate 4.

---

### P2-3 — Bundle line-cap truncation priority unspecified: GS-11 evidence may be cut, biasing contrast-pair anchor

The assemble-bundle.sh spec sets a hard cap of ≤1500 lines per bundle. Complex trajectories (GS-08 YOLO, GS-09 with multiple review files) may approach or exceed this cap. The spec does not define truncation priority — which content is cut first when nearing 1500 lines.

GS-11 is the "exemplary execution" anchor for the contrast-pair gate. Its high golden score (5.00 overall mean) is supported by complete verification evidence. If GS-11's bundle is long and truncates review files (the primary D2 evidence), the judge may score D2 lower than golden, compressing the GS-11 mean and weakening the contrast-pair gate result. This is a systematic directional bias, not random noise.

**Suggestion:** Add to §4.2B: "Truncation priority (when bundle approaches 1500 lines): (1) trace events are truncated first (most redundant), (2) additional review files beyond the first 2 are truncated, (3) the first 2 review files are truncated to head 40 each. The handoff frontmatter + §9.1 AC table + completion report body are never truncated. At least one complete review file must be preserved per bundle." This ensures that the minimum evidence needed for D2 scoring survives the cap.

---

### P2-4 — UNRECOVERABLE marking guidance in judge-prompt is subjective: add calibrating examples

The judge-prompt spec (§4.2A.5) instructs: "数据不足以评该维 → 标 UNRECOVERABLE，禁止猜分." "Insufficient data" is a subjective threshold. Two independent judges may disagree on whether a dim's evidence is "insufficient" — particularly for pre-frontmatter trajectories where standard completion-report fields are absent. This ambiguity directly affects the gate denominator (P0-1) and the per-trajectory means (P0-2).

**Suggestion:** Add to judge-prompt.md a short calibration table, e.g.:

- D1/D3/D5 UNRECOVERABLE: when no handoff document exists (pre-TAD era) or no completion report was produced (pure YOLO without structured output).
- D2 UNRECOVERABLE: when neither review files nor trace events are present in the bundle and the completion report makes no verification claims. A completion report with verification claims but no on-disk evidence is D2=1 (not UNRECOVERABLE).
- D4 UNRECOVERABLE: when no completion report section covers deviations/gate4_delta AND no honest_partial event appears in trace.

This reduces the surface area of subjective UNRECOVERABLE marking, protecting the denominator.

---

## 4. Overall Assessment

**Result: CONDITIONAL PASS**

The handoff's core design decisions are methodologically sound: (a) abandoning class-mean discrimination after empirically verifying the class-mean inversion (§11.1 decision log is well-reasoned and grounded), (b) using contrast-pair + anti-anchoring as stop-loss gates tied to the golden's own observed differences, (c) excluding D4 (data-poor, n=7, pre-declared), (d) the pairwise exclusion rule to handle mixed UNRECOVERABLE patterns.

The P0s are structural gaps, not design errors. P0-1 (no minimum-pairs floor) and P0-2 (no per-trajectory minimum-dims requirement) both need to be closed before Blake implements the calibration computation script — specifically, before the §4.4 formulas are finalized in the report template and the calc script. These are one-line additions to §4.4 and corresponding AC lines.

P1-2 (variance probe upgrade) is the highest-impact recommendation: it is the difference between knowing the gate result is reliable vs knowing only that one run happened to pass or fail. For a gate that blocks Phase 3 of a multi-phase Epic, 2 extra spawns is minimal insurance.

P1-1 and P1-3 are audit-trail and prompt-quality issues that do not block implementation but must be resolved before a PASS verdict at Gate 4 is credible.

The 80% bar on ~30-36 pairs is a defensible binary screen (appropriate sensitivity for a go/no-go decision at n=12 trajectories), and the carry-forward ±0.05 condition already partially addresses the known same-family-model weakness. The design is internally consistent with Phase 1's constraints.

**Blocking conditions before PASS:**
- P0-1 and P0-2 must be resolved in the handoff text (§4.4 additions + 1-2 new ACs)
- P1-1 rubric-diff audit trail requirement must be added to AC8
- P1-2 variance probe must be upgraded from P2 suggestion to P1 mandatory

**Non-blocking but recommended before Gate 4:**
- P1-3 (bundle D2 sequencing)
- P2-2 (machine-verifiable carry-forward caveat)

---

*Reviewer note: this review is scoped to measurement methodology. Code-reviewer assessment of AC command correctness, JSON schema contracts, and script boundary conditions is a separate review (§9.2 Expert 1) and was not assessed here.*
