# UX Review — Pattern Comparison Framework (Researcher Usability)

**Reviewer**: UX Expert (methodology/reference document usability)
**Date**: 2026-05-28
**Files reviewed**:
- `.tad/capability-packs/academic-research/references/pattern-extraction.md`
- `.tad/capability-packs/academic-research/references/multimodal-research.md`
**Review scope**: Practical usability for researchers and AI agents assisting researchers — NOT a UI review.

---

## Overall Assessment

Both documents are structurally sound and show genuine domain expertise. The table-driven format is appropriate for reference use. However, several specific sections will cause real-world workflow failures: the similarity scoring rubric has ambiguity that breaks inter-rater reliability, the feature matrix template has a column that requires a tool not described anywhere, the vocabulary section has coverage gaps for non-Western and textile/fiber traditions, and the L3 abstraction step assumes geometric software access that many humanities researchers do not have.

---

## P0 — Blocking Issues

### P0-1: L3 Geometric Overlay Requires Undefined Tooling (pattern-extraction.md §4.2, §4.3)

**Location**: Feature matrix row "L3 overlay match" (§4.2, last row) + Similarity Score 5 definition ("Geometric overlay match ≥ 90% area", §4.3).

**Problem**: The matrix instructs the user to record "% area overlap of geometric primitives" for Artifact A while leaving Artifact B and C cells blank (showing "—"). This implies an asymmetric, non-parallel measurement — it is unclear whether this is intentional (A is the reference) or a template authoring error. More critically, computing "% area overlap" of L3 abstractions requires either: (a) digital overlay in vector software (Illustrator, Inkscape) or (b) a computational geometry tool. Neither is mentioned anywhere in the document. A researcher reading only this reference will have no actionable path to compute Score 5. Score 5 is therefore unreachable for anyone without software not described here.

**Impact**: Any research output citing a Score 5 is unreproducible. Two raters cannot independently compute geometric overlay if no shared method is specified. This breaks the core promise of the scoring rubric.

**Fix required**:
- Either define the overlay procedure (e.g., "superimpose L3 SVG files at matched scale; compute overlapping polygon area as % of union area using Inkscape's Boolean union, or ImageJ pixel count") or
- Rewrite Score 5 as an approximation with explicit caveats ("visual overlay alignment judged by two independent raters; agreement required"). If a computational method is intended, name the tool and provide minimum version.
- Clarify the "—" cells in the matrix template: either require all three artifacts to be scored against each other (pairwise), or state explicitly "column A = reference artifact; B and C are compared to A."

---

### P0-2: Similarity Scoring Rubric — Score 2 and Score 3 Are Ambiguous and Will Produce Divergent Ratings (pattern-extraction.md §4.3)

**Location**: §4.3 similarity scoring table, Structural column, Scores 2 and 3.

**Problem**: Score 2 Structural = "2-3 shared features". Score 3 Structural = "Same symmetry group + repeat unit type". These two criteria use different logical structures: Score 2 uses a feature count, Score 3 uses a specific feature conjunction. The critical failure: a pattern pair sharing (a) motif type, (b) symmetry group, and (c) repeat unit type scores 3 because it satisfies the Score 3 definition — but it ALSO satisfies the Score 2 definition (3 shared features). Two raters can legitimately choose different scores for the same pattern pair. When a researcher has a Score 2 pair and wants to determine if it qualifies for Score 3, the rubric gives no guidance on whether the 2-3 features counted in Score 2 must INCLUDE symmetry group and repeat unit for Score 3 to apply, or whether Score 3 simply overrides Score 2 whenever its specific criteria are met.

Additionally, Score 2 Stylistic = "Similar proportions or rhythm." "Rhythm" is undefined in the glossary (§3) and is not a term from the AAT or Owen Jones typology cited in the source declaration. Two raters will apply this differently.

**Impact**: Any comparative study using this rubric as a basis for inter-rater reliability calculations (ICC > 0.92 is the pack's own stated threshold per architecture.md) will fail if raters systematically diverge at Score 2 vs. 3. The rubric cannot be used for publishable inter-rater agreement without clarification.

**Fix required**:
- Rewrite Score 2 and Score 3 as mutually exclusive: Score 2 = "2 shared features, where neither is a full symmetry group match"; Score 3 = "Symmetry group and repeat unit type both match (regardless of other features)."
- Define "rhythm" in §3 or replace with a defined term (e.g., "repetition interval" with a measurement basis).
- Add a worked example: show one pattern pair scored at 2, one at 3, with the differentiating criterion explicitly called out.

---

## P1 — Important Issues

### P1-1: Domain Vocabulary Gaps — Non-Western and Textile Traditions Underrepresented (pattern-extraction.md §3)

**Location**: §3.1 Essential Pattern Terms (6 entries) + §3.2 Extended Vocabulary (13 entries).

**Problem**: The vocabulary covers Greco-Roman, Islamic, Celtic, and Gothic traditions well. It is significantly thinner for:

- **East Asian traditions**: No term for karakusa (Japanese arabesque variant), sayagata (geometric interlocking swastika-derived ground), seigaiha (overlapping wave/scale), or qingwen (Chinese cloud pattern). A researcher comparing Tang dynasty textiles to Sassanian silks — a common comparative research problem — will lack vocabulary for half the comparison.
- **Textile-specific structures**: No term for "tessellation" (as a pattern type distinct from repeat), "supplementary weft" (a structural category affecting pattern appearance), or "twill" (structural constraint on geometry). Pattern geometry in woven textiles is constrained by the loom in ways that have no equivalent in ceramic or stone carving; a researcher using the material/technique column (§4.1) will record "woven textile" but have no vocabulary to capture what loom type implies for achievable geometry.
- **Pre-Columbian traditions**: The Anti-Pattern section (§5) mentions "Mesoamerican (stepped fret)" in the meander entry — but this is the only Pre-Columbian reference, and "stepped fret" has no dedicated entry despite being structurally distinct from the Greek meander.

**Impact**: Researchers working outside the Mediterranean-Islamic-European axis will be forced to invent ad hoc terminology, defeating the precision purpose of §3. AI agents assisting with cross-cultural comparison will default to generic descriptions ("geometric border") in the absence of specific terms.

**Fix**: Add a minimum of 6-8 terms from East Asian and Pre-Columbian traditions with the same morphological definition format used in §3.1. Note which terms come from non-AAT sources (e.g., Japanese textile terminology standards) so users can trace provenance. For textile-specific terms, add a note flagging that material/technique interaction with pattern geometry requires specialist consultation if the researcher's own background is object-based rather than textile-based.

---

### P1-2: L2 → L3 Abstraction Step — R² ≥ 0.95 Criterion Assumes Computational Curve-Fitting (pattern-extraction.md §2.2)

**Location**: §2.2 Abstraction Rules, row "L2 → L3 threshold."

**Problem**: "Replace curves with best-fit arcs (R² ≥ 0.95)" is a quantitative criterion that requires numerical curve-fitting. This is straightforwardly achievable for a researcher using MATLAB, Python (scipy.optimize), or vector software with curve-fit plugins. It is not achievable for a humanities researcher tracing by hand or using basic image editing software. The document provides no fallback for this step, unlike multimodal-research.md which has an explicit Measurement Fallback Rules table (§2.2) for situations where calibrated tools are unavailable.

**Impact**: A significant fraction of art history and archaeology researchers working with pattern analysis do not have computational curve-fitting tools in their workflow. They will either skip the R² check (undocumented deviation from methodology) or produce L3 output they cannot validate against the 0.95 threshold. This creates a silent methodological inconsistency between research groups that do and do not have software access.

**Fix**: Add a fallback row to the §2.2 table: "If curve-fitting software is unavailable: replace curves by visual judgment of 'nearest simple arc'; note 'manual approximation, R² not computed' in methods. Findings based on manual L3 should not be compared directly with computationally derived L3 without additional validation step."

---

### P1-3: Provenance Chain Step 5 — "Document Decisions" Is Too Vague to Operationalize (pattern-extraction.md §5)

**Location**: §5 Provenance and Distortion Chain, Step 5 "Analysis processing."

**Problem**: The Distortion Risk column reads "Each abstraction step is an interpretation — document decisions." This is the correct principle but provides no structure for what to document. In contrast, Steps 1-4 have specific, observable distortion risks (perspective distortion, compression artifacts, color shift). Step 5 gives only a general instruction. A researcher completing the provenance chain table will write different things here — some will document only that they performed L3 abstraction; others will list every tracing decision. The result is non-comparable provenance records across research groups.

**Fix**: Rewrite Step 5 with a minimum required documentation set: "(a) which abstraction levels were produced (L1/L2/L3); (b) the L1→L2 features removed and the 5% area threshold applied; (c) the curve-fitting method and software used for L2→L3 (or 'manual approximation' with rater name); (d) any intentional deviation from §2.2 rules with reason stated." This transforms an open-ended instruction into an auditable checklist item.

---

### P1-4: Feature Matrix "L3 Overlay Match" Row — Asymmetric Fill Pattern Contradicts Matrix Logic (pattern-extraction.md §4.2)

**Location**: §4.2 Comparison Feature Matrix Template, final row.

**Problem**: Every other row in the feature matrix has entries for Artifact A, Artifact B, and Artifact C independently, with a Comparison column synthesizing them. The "L3 overlay match" row has a value only for Artifact A and "—" for B and C. This implies overlay is computed once (A as reference) rather than pairwise. If this is intentional, the matrix is measuring "similarity to a chosen reference" rather than pairwise similarity across all artifacts — which is a meaningful methodological choice that should be stated explicitly. If this is a template oversight, it should be corrected to show that all three pairwise comparisons (A-B, A-C, B-C) are required or explain why A is privileged.

**Fix**: Either (a) restructure the row as three pairwise columns ("A-B overlap %", "A-C overlap %", "B-C overlap %") with a Comparison column showing the range, or (b) add a footnote: "L3 overlay is computed against a designated reference artifact (Artifact A). Select the reference before beginning analysis and document the selection rationale."

---

### P1-5: Observation Checklist "Capture Conditions" — No Protocol for Inherited Images (multimodal-research.md §2.1)

**Location**: §2.1 Observation Checklist, "Capture conditions" field.

**Problem**: The "Capture conditions" field instructs researchers to record "Lighting, angle, background, visible color reference." This is actionable when the researcher controls or witnessed the photography. It is not actionable — and not acknowledged — for the most common research situation: analyzing images from museum databases, published books, or online repositories where capture conditions are unknown. The only guidance for unknown information is "write 'not determinable'" but the document does not acknowledge that this field will frequently be "not determinable" for secondary sources, nor does it address whether a study built entirely on museum-database images with unknown capture conditions is methodologically sound.

**Fix**: Add a row to §2.2 Measurement Fallback Rules: "Capture conditions unknown (museum database, publication scan): Record as 'Capture conditions: unknown — secondary source [institution, accession #]'. Flag this artifact in comparative analysis; structural comparisons remain valid, chromatic comparisons are unreliable without known lighting conditions."

---

### P1-6: Quick Reference Table Thresholds — "≥ 3×3 for publishable comparison" Is Not Grounded (pattern-extraction.md Quick Reference)

**Location**: Quick Reference Table, row "Feature matrix minimum."

**Problem**: The threshold "≥ 3×3 for publishable comparison" (3 features × 3 artifacts) appears in the Quick Reference but has no explanation or citation in the body of the document. The body (§4.1) says "minimum 5 dimensions" for comparing across cultures, contradicting the Quick Reference table which implies 3 features minimum is sufficient for publication. These two numbers (3 and 5) are inconsistent, and neither has a citation or methodological basis given.

**Fix**: Reconcile the two numbers. If 5 dimensions is the requirement for cross-cultural work (as stated in §4.1), the Quick Reference table should read "≥ 5×3 for cross-cultural publishable comparison (see §4.1)." The "3×3" threshold may be appropriate for a narrower scope (same-culture, same-period comparisons) — if so, add a scope qualifier. Cite the source of either threshold or acknowledge it as a methodological convention derived from the framework authors' judgment.

---

## P2 — Suggestions

### P2-1: No Guidance on Sequence — Should Multimodal Protocol Run Before or Alongside Pattern Extraction?

Both documents reference each other (pattern-extraction.md §intro references multimodal-research.md; multimodal-research.md §intro defers to pattern-extraction.md for ornamental work). Neither document tells a researcher the order in which to apply them. In practice: should a researcher complete the §2.1 Observation Checklist from multimodal-research.md FIRST, and then proceed to the Motif Identification Protocol in pattern-extraction.md? Or are these parallel tracks? For an AI agent, the lack of a sequencing rule risks applying the more general framework after the more specific one, creating duplicate effort or missed steps.

**Suggestion**: Add a two-sentence workflow preamble to pattern-extraction.md: "When analyzing ornamental patterns: (1) complete multimodal-research.md §2.1 Observation Checklist first to document the artifact; (2) then proceed to §1.1 Motif Identification Protocol here. The general image protocol establishes the observational baseline; the pattern extraction protocol builds the comparative analysis on top of it."

---

### P2-2: Anti-Pattern Table Could Link to Corrected Procedures

Both documents have Anti-Pattern tables (pattern-extraction.md §5 anti-patterns, multimodal-research.md §6 anti-patterns). The "Correct Alternative" column gives the corrected output but does not reference the section where the procedure is defined. A researcher who finds themselves doing the anti-pattern has the correct output format but no path back to understanding why or how.

**Suggestion**: Add a "See" column pointing to the relevant section. Example: for the anti-pattern "Tracing only L3 without retaining L1" → "See §2.2 Documentation rule."

---

### P2-3: Geometric Classification "Composite" Category — No Worked Example for Primary/Secondary Assignment

The rule in §1.2 states "record the PRIMARY category (dominant visual property) and up to 2 secondary categories." The Composite category is defined as "Combines ≥ 2 categories above" — but if a motif is Composite, what should its Primary category be? Is Composite itself a valid Primary, or should the researcher identify the dominant component and call that Primary? The examples given ("Interlaced arabesque, scrolling palmette border") suggest Composite is a valid Primary, but this conflicts with the intent of recording a single "dominant visual property."

**Suggestion**: Clarify: "If a motif is visually dominated by one category with secondary categories present, record the dominant category as Primary and the secondary as Secondary (e.g., Primary: Curvilinear; Secondary: Interlacing). Record Primary: Composite only when no single component is dominant."

---

### P2-4: Similarity Dendrogram (pattern-extraction.md §6.3) — No Minimum Artifact Count Stated

The dendrogram output format (§6.3) specifies distance metric, clustering method, bootstrap support values (≥ 70%). It does not state a minimum number of artifacts for dendrogram analysis to be meaningful. A dendrogram of 3 artifacts has no meaningful branching structure; bootstrap support is unreliable below approximately 20-30 samples for most clustering algorithms. A researcher may produce and publish a dendrogram from 4-5 artifacts without realizing this is statistically problematic.

**Suggestion**: Add: "Minimum recommended artifact count: ≥ 10 for exploratory dendrograms; ≥ 30 for bootstrap support values to be reliable. Below 10 artifacts, present as a pairwise similarity table rather than a dendrogram."

---

## Summary Table

| ID | Severity | File | Section | Issue |
|----|----------|------|---------|-------|
| P0-1 | Blocking | pattern-extraction.md | §4.2, §4.3 | Score 5 and L3 overlay require undefined tooling and have asymmetric matrix fill |
| P0-2 | Blocking | pattern-extraction.md | §4.3 | Score 2/3 are not mutually exclusive; "rhythm" undefined; rubric produces divergent ratings |
| P1-1 | Important | pattern-extraction.md | §3 | Vocabulary gap: East Asian, textile-structural, Pre-Columbian terms missing |
| P1-2 | Important | pattern-extraction.md | §2.2 | R² ≥ 0.95 criterion requires curve-fitting software; no fallback for humanities researchers |
| P1-3 | Important | pattern-extraction.md | §5 | Step 5 provenance "document decisions" too vague; no minimum documentation set |
| P1-4 | Important | pattern-extraction.md | §4.2 | Asymmetric "—" in L3 overlay row contradicts matrix logic; reference artifact not declared |
| P1-5 | Important | multimodal-research.md | §2.1 | Capture conditions field unworkable for inherited/secondary-source images |
| P1-6 | Important | pattern-extraction.md | Quick Ref, §4.1 | 3×3 vs 5-dimension thresholds are internally inconsistent; neither cited |
| P2-1 | Suggestion | Both | Intro | No sequencing guidance between the two documents |
| P2-2 | Suggestion | Both | Anti-patterns | Anti-pattern "Correct Alternative" column does not link back to procedure sections |
| P2-3 | Suggestion | pattern-extraction.md | §1.2 | "Composite" as Primary category rule is ambiguous |
| P2-4 | Suggestion | pattern-extraction.md | §6.3 | No minimum artifact count for dendrogram statistical validity |

---

## What Works Well (do not change)

- The three-level abstraction (L1/L2/L3) structure is a strong and actionable framework. The table format with Method/Purpose/Output columns makes it directly usable.
- The Anti-Pattern tables are the most immediately practical section in both documents. The specific wrong-phrasing examples with exact correct alternatives are highly effective.
- The Provenance and Distortion Chain table (§5) is well-constructed for Steps 1-4; Step 5 is the only weak point.
- The Critical Rule callout at the end of §4.3 (high similarity score does not prove historical connection) is correctly placed and phrased precisely. This is the most important epistemic guardrail in the document and should remain exactly as written.
- The cross-reference structure between the two documents is correct: general before specific, with explicit deferral pointers. This avoids duplication while maintaining usability as standalone references.
- multimodal-research.md §2.2 Measurement Fallback Rules is a model for how to handle tool/access constraints gracefully. This pattern should be extended to pattern-extraction.md where equivalent fallbacks are missing.
