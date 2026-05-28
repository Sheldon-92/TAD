# Research Quality Review — Academic Research Pack Phase 7

**Reviewer**: code-review (adapted for task_type=research)
**Handoff**: HANDOFF-20260528-academic-research-pack-phase7.md
**Date**: 2026-05-28
**Verdict**: PASS with 0 P0, 2 P1, 4 P2

---

## Overall Assessment

This is a well-executed pilot test. The report contains specific, verifiable data (USDA FDC IDs, exact mg/100g values, DOIs with citation counts), follows the pack's 6-phase protocol, and honestly documents its limitations (Thai data gap, single-review dependency, cuisine generalization). The methodology log provides full tool-call provenance for every citation. The README is thorough with 7 specific limitations discovered during the pilot.

---

## P0 Findings (Critical)

None.

---

## P1 Findings (Should Fix)

### P1-1: Citation Count Provenance Mismatch for Key Paper

**Location**: soy-sauce-cross-cultural-report.md lines 40, 135, 181, 191

The Diez-Simon et al. 2020 paper — the single most important reference in the report (described as the primary dependency in Limitations section 4.3 item 3) — has two different citation counts used in the report:

- Line 40 (Methodology table): "275 cit" — sourced from OpenAlex (methodology log Tool Call 2)
- Line 135 (in-text): "216 citations on Semantic Scholar"
- Line 181 (Limitations): "216 citations"
- Line 191 (References [1]): "216 citations, Semantic Scholar via OpenAlex search"

The attribution in Reference [1] is self-contradictory: "216 citations, Semantic Scholar via OpenAlex search" — was the count from Semantic Scholar (216) or OpenAlex (275)? The methodology log only records the OpenAlex result (275). The 216 figure has no documented tool-call provenance, which technically violates the zero-hallucination rule. It may have come from the Semantic Scholar API during citation chain analysis (Tool Calls 10-11), but if so, that should be documented.

**Recommendation**: Standardize on one count per database with explicit attribution: "275 citations (OpenAlex)" or "216 citations (Semantic Scholar)". If both counts were obtained from tool results, document both in the methodology log.

### P1-2: Reflexion Self-Assessment Contains Factual Error

**Location**: soy-sauce-cross-cultural-report.md line 249

The Efficiency dimension states: "17 tool calls for a literature survey (within 20-40 range)."

17 is below the 20-40 range, not within it. This is a factual error in a self-assessment section. While the 17 tool calls are adequate for the actual research conducted (and the pack's tier classification is a guideline, not a hard requirement), the self-assessment should accurately characterize the result relative to the declared tier.

**Recommendation**: Correct to "17 tool calls for a literature survey (below the 20-40 expected range; sufficient for the scope achieved)".

---

## P2 Findings (Consider)

### P2-1: Abstract Claims "20 papers" from Semantic Scholar — Ambiguous

**Location**: soy-sauce-cross-cultural-report.md line 5

The abstract states "Data was collected from Semantic Scholar (20 papers)". This is technically the raw result count (10 from Tool Call 1 + 10 from Tool Call 3). However, the report only uses 5 of these 20 papers in its References. Stating "20 papers" in the abstract implies all 20 contributed to the analysis. Consider: "Data was collected from Semantic Scholar (20 results screened, 5 included)".

### P2-2: Sodium Calculation in Section 3.2 Uses Mixed Data Sources

**Location**: soy-sauce-cross-cultural-report.md lines 80-84

The sodium per stir-fry estimates mix USDA data (Japanese: "54.93mg/ml" derived from 5493mg/100g) with unattributed estimates (Chinese: "~1760mg Na" for 2 tbsp light, "~800mg" for 1 tbsp dark). The Chinese light soy sauce sodium figure has no tool-call provenance — USDA does not have a specific "Chinese light soy sauce" entry. The calculation methodology (which USDA entry was used, what volume-to-weight conversion was applied) is not documented.

**Recommendation**: Either cite the specific USDA entry and conversion factor used for the Chinese estimates, or explicitly mark them as "estimated by extrapolation from generic soy sauce data — not directly verified via USDA API."

### P2-3: Reference [8] (Yamasa FDC 2288941) Appears in References but Not in Report Body

**Location**: soy-sauce-cross-cultural-report.md line 205

Reference [8] — USDA FoodData Central branded entry for Yamasa Shoyu (FDC 2288941, 6130mg Na/100g) — is listed in the References section but never cited in the report body. It appears in the methodology log (Tool Call 4 result), so it has tool-call provenance. However, an uncited reference is unusual in academic writing.

**Recommendation**: Either cite it in Section 3.4 (e.g., "Branded products show sodium variation: Yamasa shoyu at 6,130mg/100g [8] vs generic shoyu at 5,493mg/100g [7]") or remove it from the References.

### P2-4: README Limitations Section Is Strong but Missing One Observed Gap

**Location**: README.md lines 96-111

The README documents 7 limitations — an impressively thorough set. However, it does not mention the observed gap where the pilot produced 17 tool calls against a declared tier minimum of 20. This is relevant pack feedback: the tier classification thresholds may need recalibration if a complete literature survey naturally finishes under 20 calls.

**Recommendation**: Add an 8th limitation noting the tier threshold observation, or adjust the tier ranges in research-protocol.md.

---

## Positive Observations

1. **Specific data throughout**: The report consistently provides exact values with units and provenance (e.g., "5,493mg sodium per 100g (USDA FoodData #174277)") rather than vague claims. This is exactly what the handoff's anti-slop note (section 10.2) required.

2. **Honest limitations section**: Five specific, substantive limitations — including acknowledging the single-review dependency (Diez-Simon 2020) and the cuisine generalization problem. The report does not oversell its findings.

3. **Thai data gap handled correctly**: USDA lacks Thai-specific entries. Blake correctly used kecap manis as a proxy, clearly labeled it as approximate/non-identical, and documented the gap in both the report body and the Limitations section. This follows the handoff's section 10.3 guidance exactly.

4. **Methodology log as audit trail**: Every tool call has command, results summary, and key findings extracted. The 4-point self-check in Phase 6 demonstrates systematic verification against the zero-hallucination rule.

5. **README quality**: 7 specific limitations discovered during pilot testing, not generic boilerplate. Limitation #2 (ScholarEval calibration question) and #7 (cross-session citation persistence) are particularly insightful pack improvement observations.

---

## Summary

| Severity | Count | Items |
|----------|-------|-------|
| P0 | 0 | — |
| P1 | 2 | Citation count mismatch (Diez-Simon 275 vs 216); Reflexion range claim factual error |
| P2 | 4 | Abstract paper count ambiguity; mixed-source sodium calculation; uncited Reference [8]; README missing tier threshold observation |

The research deliverables are of good quality for a pilot validation test. The pack protocol was followed, citations trace to tool results, and the report contains specific verifiable data. The P1 findings are internal consistency issues that do not affect the structural validity of the research or the pack validation conclusion.
