# Dogfood Judgment — academic-research pack (CBT/anxiety PRISMA meta-analysis)

## Task
"Conduct a systematic review of CBT interventions for anxiety disorders. PRISMA-compliant meta-analysis covering RCTs 2018-2025."

## Verdict: Answer 1 wins, margin = clear

Both answers make the SAME correct core move: refuse to fabricate a finished meta-analysis (no real search was run → any pooled effect/citation would be hallucinated), and instead deliver an executable protocol + scaffolding. This is the methodologically correct response and neither answer fabricates results. So the contest is decided on (a) correctness of the specific methodology claims and (b) depth/auditability of the protocol — NOT on the refusal itself.

## WebSearch verification of specific claims (both answers)

| Claim | Answer(s) | Verified value | Status |
|---|---|---|---|
| PRISMA 2020 = 27-item checklist | A1 (explicit "27 items") | 27-item checklist, 7 sections, 4-phase flow diagram (prisma-statement.org, PMC8005924) | CORRECT |
| PRISMA 2020 not PRISMA-ScR for pooled focused-question review | A1 | ScR is for scoping reviews; PRISMA 2020 is correct for a meta-analysis | CORRECT |
| RoB 2 = current Cochrane standard for RCTs, replaces old RoB | A1 (5 domains), A2 ("do not use the old RoB tool") | RoB 2 published Aug 2019, 5 mandatory domains, recommended Cochrane tool (methods.cochrane.org) | CORRECT (both) |
| OCD/PTSD reclassified out of anxiety disorders in DSM-5 | A1, A2 | OCD → OCRD chapter, PTSD → trauma/stressor chapter (psychiatryonline, DSM-5) | CORRECT (both) |
| Hedges' g for continuous (small-sample correction over Cohen's d) | A1, A2 | Standard; g applies small-sample bias correction | CORRECT (both) |
| Egger's test needs ≥10 studies | A1, A2 | Cochrane Handbook: funnel-plot asymmetry tests only with ≥10 studies | CORRECT (both) |
| Random-effects DerSimonian-Laird / REML | A1 (DL), A2 (DL or REML) | Both valid random-effects estimators | CORRECT (both) |
| PROSPERO pre-registration before screening | A1, A2 | Standard expectation | CORRECT (both) |
| R metafor/meta, RevMan tooling | A2 | Real, current packages | CORRECT |
| Orientation effect ~g 0.5-0.8 vs waitlist, shrinks vs active controls | A2 (labeled "orientation, not a result to cite") | Consistent with published CBT-anxiety literature; A2 explicitly flags as non-citable | DEFENSIBLE (caveated) |

No specific-but-WRONG claims found in EITHER answer. Both are factually clean — a notable result; verbosity did not introduce errors.

## Why Answer 1 wins (on correct specifics, not verbosity)

Both share identical correct methodology. A1 adds correct, load-bearing specifics that A2 omits:

1. **Kappa paradox / rare-class agreement metric** (A1 §3): "inter-rater agreement must NOT be reported as Cohen's kappa alone — the include class is rare; report κ + Gwet's AC1 + raw % + marginal prevalence." This is a genuine, correct, non-obvious methodological refinement. A2 just says "report κ" — which is exactly the naive practice A1 correctly warns against. This is the single sharpest discriminator and A1 is on the right side of it.
2. **GRADE applied per-outcome** with explicit RCT-starts-HIGH downgrade dimensions (A1 §4). A2 names GRADE but does not operationalize it.
3. **ClinicalTrials.gov registry cross-check for selective reporting** (A1 §2 item 4) — a real PRISMA-relevant step A2 omits.
4. **Dedup key = DOI primary, normalized-title fallback** (A1 §3) — concrete and correct; A2 says "deduplicated" only.
5. **Trim-and-fill + Egger intercept p<0.10** threshold (A1 §5) — A2 stops at "funnel + Egger".

A1's cost: heavy TAD/SKILL-internal framing (anti-rationalization rows, Epic phase table, ScholarEval ≥0.75, Gate mapping). This is process noise to an external researcher and inflates length. But it is not wrong, and the underlying methodology underneath the framing is richer than A2's.

A2's strengths: cleaner prose, more honest about the orientation effect size (with an explicit do-not-cite caveat — good practice), concrete tool offer (metafor script), Rayyan/Covidence named. A2 is the more readable deliverable and arguably better human-facing communication. But on methodological depth and correct specificity — the thing that actually de-risks a PRISMA review — it is a strict subset of A1 (minus the kappa-paradox point, where A2 is actively weaker).

The margin is "clear" not "decisive": A2 is fully correct, well-organized, and an external client might prefer its signal-to-noise. A1 wins on substantive correct specifics (kappa paradox, per-outcome GRADE, registry cross-check, dedup key), not on verbosity — but it pays a real readability tax for its internal-framing bloat, which keeps this short of decisive.

## Scores
- A1: correctness 5, actionability 4, specificity 5, completeness 5
- A2: correctness 5, actionability 4, specificity 4, completeness 4
