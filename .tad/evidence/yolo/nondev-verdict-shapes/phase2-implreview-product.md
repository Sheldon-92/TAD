# Gate 3 Independent Review — Pressure-Test Rigor Rubric

**Reviewer role**: Independent product expert (not the rubric author).  
**Artifact under review**: `.claude/skills/product-thinking/references/pressure-test-rubric.md`  
**Reference pack mechanics**: `skills/pressure-test.md`, `checklists/fatal-flaws.md`  
**Review date**: 2026-06-06  
**Review mandate**: Judge the rubric as a DISCRIMINATION INSTRUMENT across 6 axes.

---

## 1. DISCRIMINATION — Can a thin/sycophantic analysis sneak a PASS?

**Trace of a minimal-effort, single-encouraging-answer pressure-test through the band tree:**

- D1 (Adversarial Rigor): The rubric's `superficial` criterion reads: "≤2 rounds, OR no genuine adversarial pushback at all (a single encouraging pass, 'that could work' / 'interesting approach' tone — the exact phrasings the anti-sycophancy rules forbid at L16–20), OR every founder answer is accepted at face value. A thin, agreeable single-answer analysis lands here." A single-pass sycophantic analysis maps squarely to `superficial`.

- D2 (Evidence Grounding): "0–1 real searches; claims rest on opinion / 'I think'" → `superficial`.

- D3 (Fatal-Flaw Analysis): "No fatal-flaw scan at all" → `superficial`.

- Band Decision Tree Rule 1: `IF D1 == superficial OR (count == superficial) >= 2` → band `superficial` → verdict FAIL.

In the described thin case, D1 alone triggers Rule 1. D2 and D3 each independently also trigger Rule 1 via the count clause. The discriminant is robust: three independent firing paths, any one sufficient.

**The rubric also embeds the worked discrimination check inline (§B, final paragraph)**, which is a deliberate self-documentation of exactly this trace. That is good practice.

**Verdict on this axis: NO sneaking possible. Discrimination is sound.**

---

## 2. DECOUPLING — Do band criteria reference the BUILD/PIVOT/KILL conclusion?

**Searched all §A dimension criteria for conclusion-leaking language:**

- D1: all criteria reference rounds, pushback, challenge stance. No reference to BUILD/PIVOT/KILL.
- D2: all criteria reference search evidence, FACT/ASSUMPTION labeling. No reference to conclusion.
- D3: all criteria reference scan coverage and rule application. No reference to conclusion.
- D4: The `rigorous` criterion reads: "A named BUILD/PIVOT/KILL verdict that is explicitly tied to the round evidence and fatal-flaw count, carries a confidence score consistent with the FACT/ASSUMPTION tally, names the core unvalidated assumption, AND gives a concrete, type-specific 2-week validation plan with an explicit success signal."

  The phrase "A named BUILD/PIVOT/KILL verdict" is NOT a conclusion leak — it requires a verdict to exist and be rigorously justified, not that it be any particular verdict. A rigorously-justified KILL satisfies this criterion identically to a rigorously-justified BUILD.

- D5: criteria reference type detection and adapter application. No reference to conclusion.

**D4 warning note**: the criterion is written neutrally, but a sloppy judge could misread "A named BUILD/PIVOT/KILL verdict that is explicitly tied to the evidence" as implying BUILD is the expected outcome. This is a latent misread risk, not a definitional conclusion leak.

  The §D judge output contract partially mitigates this: "band: (with justification) MUST appear ABOVE content_verdict:" prevents the conclusion from anchoring the band assignment. The D4 note box reinforces: "It does NOT score which verdict was reached. A well-justified KILL scores rigorous here exactly like a well-justified BUILD."

**Swap Test**: The swap test (§C) is present, unambiguous, and mandatory. It requires the judge to flip BUILD↔KILL and re-read all per-dimension scores. If any score moves, the judge must re-score. This is the correct and sufficient self-audit mechanism.

**Finding**: No criterion is a hard conclusion leak. D4 carries latent misread risk for an inattentive judge. The swap test and D4 note box mitigate this — but see P1 finding below.

**Verdict on this axis: DECOUPLING holds. One P1 latent risk noted.**

---

## 3. CEILING — Can a rigorous KILL reach `rigorous`/PASS?

**Traced a rigorous KILL through the rubric:**

- D1: A genuinely adversarial analysis that ran all 6 rounds, pushed back on weak answers, challenged the strongest claim, and refused category-level answers — even if it concludes KILL — scores `rigorous`. The D1 criteria are purely about the interrogation quality, not the conclusion.

- D2: Real data searched across rounds, FACT/ASSUMPTION labeled, behavior over opinion privileged — regardless of whether the facts support BUILD or KILL — scores `rigorous`.

- D3: Scanned 15 killers, named the 3 most relevant with idea-specific reasons, correctly applied the "2+ = KILL" rule → `rigorous`. Notably, *correctly applying the 2+ KILL rule is itself evidence of rigor* — a KILL verdict where two flaws are correctly identified and the decision rule properly applied scores `rigorous` on D3.

- D4: A KILL verdict tied to the evidence (e.g. "confidence 2/10 from 1 FACT and 5 ASSUMPTIONs + 3 fatal flaws") + type-specific 2-week validation plan + explicit success signal scores `rigorous`. The note box in D4 explicitly states this.

- D5: Product type correctly detected and adapter applied regardless of verdict → `rigorous`.

**Band Tree**: D1 rigorous AND all 5 rigorous AND 0 superficial → Rule 2 fires → `rigorous` → PASS.

**No ceiling exists.** A rigorously-argued KILL can reach `rigorous`/PASS without any rubric mechanism blocking it.

**Verdict on this axis: PASS. Locked design rule is fully honored.**

---

## 4. DIMENSION QUALITY — Are criteria concrete and judge-actionable?

Assessed each dimension for specificity and actionability:

**D1 (Adversarial Rigor)**: Criteria are strongly concrete. The `rigorous` band specifies "~6 forcing rounds actually run (Demand → Future-Fit)", "pushes back on at least one weak answer", "refuses category-level answers — when a demographic is offered it demands a real named person." These are observable, verifiable behaviors. The `superficial` band names the exact forbidden phrases from the anti-sycophancy rules ("that could work" / "interesting approach"). A judge can tally rounds and check for pushback instances directly from the artifact.

**D2 (Evidence Grounding)**: The `rigorous` band gives concrete source types: "named Reddit/HN threads, competitor names + pricing, Product Hunt counts, real persona evidence." FACT/ASSUMPTION labeling is observable. The behavior-over-opinion distinction is operationalized: "counts 'actively tried to solve / pre-paid / waitlisted' as demand; discounts 'would be interested / friends liked it' as politeness." Actionable.

**D3 (Fatal-Flaw Analysis)**: Concrete but with one ambiguity. The `rigorous` band requires "the 15 killers were scanned against this specific idea." However, a judge reading a pressure-test artifact cannot verify whether the producer actually ran through all 15 or merely identified 2-3 obvious ones. The rubric addresses this with "or a defensible 'no structural killers found' with the scan shown" — the requirement that the scan be shown is a check on this, but it may not be honored if the artifact only reports the final 3 named flaws without showing the scan.

  **P2 finding**: The D3 `rigorous` criterion requires the full 15-killer scan, but a pressure-test that only outputs ≤3 most relevant (as the skill instructs) leaves the judge with no direct evidence the other 12 were considered. The rubric should instruct the judge to infer scan completeness from the plausibility of the selection (i.e., the named flaws are the most structurally relevant, not just the most obvious), not require the artifact to enumerate all 15.

**D4 (Verdict Justification)**: Concrete. Observable elements: named BUILD/PIVOT/KILL, confidence score tied to FACT count, core assumption named, 2-week plan with success signal. Each is either present or absent. The confidence-consistency check (does the score match the FACT/ASSUMPTION tally from the skill's formula?) is a quantitative gate, not subjective.

**D5 (Product-Type Adapter Use)**: Moderately concrete. The `rigorous` band requires "type-appropriate data sources in the searches, adapter-flavored wedge wording in Q4, and a type-appropriate 2-week validation definition." This is actionable if the judge also reads the relevant adapter file. However, the rubric does not specify which adapter files to reference, only noting `adapters/*.md` in the source citation. A judge who has never read the adapters cannot verify adapter compliance from the rubric alone.

  **P1 finding**: The rubric claims to be "self-contained: a judge can score an artifact given ONLY this rubric path plus the artifact path." This claim is false for D5. Scoring D5 `rigorous` vs `partial` requires knowing what the adapter specifies for data sources, Q4 wording, and 2-week validation definition. Without reading `adapters/{type}.md`, the judge cannot tell whether the analysis is "adapter-tuned" or "generic boilerplate." The self-containment claim must be amended, or D5 must be restructured to embed the differentiating adapter specifics for each type directly in the rubric.

---

## 5. JUDGE USABILITY — Can an independent judge apply this from rubric + artifact alone?

**Strengths:**
- The How to Use section (five numbered steps) is unambiguous.
- D1, D2, D4 criteria are fully self-contained: everything a judge needs is in the rubric text or directly observable in a properly-formatted pressure-test artifact.
- The Band Decision Tree is expressed in pseudo-code with explicit rule precedence ("first matching rule wins"). No ambiguity in aggregation.
- The judge output contract (§D) specifies exact output format and order, including the order firewall.
- The swap test procedure is clear and mandatory.
- The worked discrimination check in §B guides judges unfamiliar with the degenerate case.

**Weaknesses:**
- D5 requires external adapter files to score, contradicting the self-containment claim (see P1 above).
- D3's "scan shown" requirement depends on artifact format compliance, not enforced by the rubric.
- The source citations table at the end references line numbers (L8, L14–28, L86, etc.) in `pressure-test.md`. These are useful for rubric validation but create a version-coupling risk: if `pressure-test.md` is edited and line numbers shift, the citations silently degrade. This is a maintenance P2, not a current usability failure.

**Overall usability**: High for D1/D2/D4. Moderate for D3. Low for D5 without adapter access.

---

## 6. OVER/UNDER-FIT — Degenerate cases in the band tree

**Can you always PASS?**

Rule 2 requires: D1 rigorous AND ≥4 of 5 rigorous AND 0 superficial. The requirement for D1 specifically to be `rigorous` (not merely not-superficial) prevents a degenerate path where all other dimensions are rigorous but D1 is partial. This is deliberate and correctly load-bearing.

**Can you never reach `rigorous`?**

Tested: is there any combination of individually-rigorous dimension scores that the band tree would block from `rigorous`? Rule 2: D1=rigorous, D2=rigorous, D3=rigorous, D4=rigorous, D5=rigorous → 5/5 rigorous, 0 superficial → PASS. No blockage.

What if D5 is partial (adapter not followed) but D1-D4 are all rigorous? Rule 2 requires ≥4 rigorous. With D5 partial: D1+D2+D3+D4 rigorous = 4 rigorous, 0 superficial, D1 rigorous → Rule 2 fires → PASS. This means an analysis that correctly runs all 6 adversarial rounds with real evidence, scans fatal flaws, and justifies its verdict rigorously — but fails to use the product-type adapter — can still PASS. This may be the correct design (adapter is a refinement, not a core), but it means D5 carries low load-bearing weight in the decision tree.

**One structural concern (P2)**: The band tree has an asymmetry in how it handles D1 partial vs D1 rigorous with mixed other scores. If D1=partial, D2=rigorous, D3=rigorous, D4=rigorous, D5=rigorous → Rule 2 fails (requires D1 rigorous) → falls to Rule 3 → `partial`. But if D1=partial, D2=superficial, D3=rigorous, D4=rigorous, D5=rigorous → Rule 1 fires (count superficial ≥ 2? No, only 1) → does Rule 1 fire? Only if D1==superficial OR count(superficial)>=2. D1=partial, count(superficial)=1 → Rule 1 does NOT fire. Falls to Rule 3 → `partial`. So D2=superficial doesn't worsen the outcome vs D2=rigorous when D1=partial. This means D2 through D5 individually carry no additional downgrade weight if D1 is partial and at most 1 other dimension is superficial. This is defensible (D1 is load-bearing; partial is partial) but could allow a genuinely weak D2 analysis (0 searches, no FACT/ASSUMPTION) to be masked as `partial` rather than something worse when D1 happens to be partial. Not a blocker, but a nuance.

**Verdict on this axis: No degenerate always-PASS or never-rigorous path. One asymmetry worth documenting.**

---

## Findings Summary

### P0 Findings (blocking)

None identified.

The rubric correctly fails sycophantic analyses, does not leak the BUILD/PIVOT/KILL conclusion into any band criteria, does not cap rigorous KILL verdicts, and has a working band decision tree.

---

### P1 Findings (significant — should fix before production use)

**P1-1: Self-containment claim is false for D5**

The rubric header states: "This rubric is self-contained: a judge can score an artifact given ONLY this rubric path plus the artifact path."

D5's `rigorous` criterion requires verifying "type-appropriate data sources in the searches, adapter-flavored wedge wording in Q4, and a type-appropriate 2-week validation definition." This cannot be judged without reading `adapters/{type}.md` — a file the rubric does not embed or summarize.

Fix options: (a) embed the per-type differentiators in a D5 appendix table within the rubric, or (b) amend the self-containment claim to read "self-contained for D1–D4; D5 requires also reading `adapters/{type}.md`", or (c) lower D5's bar to "type is identified and analysis is not generically boilerplate" — verifiable without adapter access.

Until fixed, a judge scoring D5 from the rubric alone will produce unreliable results for that dimension.

**P1-2: D4 latent misread risk (minor but real)**

The D4 criterion opens with "A named BUILD/PIVOT/KILL verdict that is explicitly tied to the round evidence" — a judge who reads this as "verdict = BUILD is the expected form" would penalize a KILL verdict. The D4 note box ("A well-justified KILL scores rigorous here exactly like a well-justified BUILD") and §C swap test provide mitigation. However, the note box is rendered as a blockquote warning after the table, not inside the table cell where the criterion lives. A skim-reader can miss it.

Fix: move the "does NOT score which verdict was reached" language into the `rigorous` band cell itself, not only into the warning box.

---

### P2 Findings (low severity — should address in a future revision)

**P2-1: D3 scan-completeness is unverifiable from artifact alone**

The `rigorous` criterion requires "the 15 killers were scanned against this specific idea." The skill instructs the producer to output only ≤3 most relevant flaws, not to list all 15 with pass/fail. A properly-formatted pressure-test artifact will not show the full scan — only its output. The rubric says "or a defensible 'no structural killers found' with the scan shown," which conflicts with the skill's instruction to include only ≤3.

Fix: replace "with the scan shown" with "with a defensible selection — the named flaws are the most structurally relevant, not just the most obvious, AND the judge's own background scan of the 15-item list does not surface an obvious unconsidered killer."

**P2-2: Source citation line numbers create version-coupling risk**

The source citations table references specific line numbers (L8, L14–28, L86, L117, L147, L180, L212, L242, L246–303, L31–50, L139, L453–479). If `pressure-test.md` or `gate/SKILL.md` are edited and line numbers shift, citations silently degrade into false anchors. The rubric should use section headers or anchor text rather than line numbers for durability.

**P2-3: D5 carries low decision-tree weight — worth documenting as intentional**

An analysis that scores D1–D4 rigorous and D5 partial still PASSes (4 rigorous, 0 superficial, D1 rigorous → Rule 2 fires). This may be correct design (adapter use is a refinement), but it means D5 `superficial` only matters as a FAIL trigger if D1 is also superficial or there is already 1 other superficial dimension. Recommend adding a design note in §B clarifying this is intentional: "D5 is a quality amplifier, not a blocking gate — the pack's core value is adversarial interrogation (D1), not type-tuning."

---

## Overall

**P0 count: 0**  
**P1 count: 2**  
**P2 count: 3**  

**Overall: CONDITIONAL PASS**

The rubric correctly discriminates thin/sycophantic analyses from rigorous ones, preserves full decoupling between rigor and conclusion, does not cap rigorous KILL verdicts, and has an unambiguous band decision tree. The two P1 issues — the false self-containment claim for D5, and the D4 misread risk — should be resolved before the rubric is used in an automated Gate 3/4 pipeline. Neither breaks the core scoring logic; both create judge-reliability gaps for specific scenarios (D5 scoring without adapter access; a skim-reader penalizing a KILL verdict on D4). Fix time is low (D5: add adapter summary table or amend claim; D4: move one sentence into the table cell).
