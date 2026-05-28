# Spec Compliance Review — Academic Research Pack Phase 7

**Reviewer**: spec-compliance-review (Gate 3)
**Handoff**: HANDOFF-20260528-academic-research-pack-phase7.md
**Date**: 2026-05-28
**Verdict**: PASS with P1 findings

---

## AC Verification Results

| AC# | Requirement | Command Result | Threshold | Status |
|-----|------------|---------------|-----------|--------|
| AC1 | Report exists | file exists | exists | PASS |
| AC2 | >= 10 citations | 12 | >= 10 | PASS |
| AC3 | Nutritional data mentions | 31 | >= 5 | PASS |
| AC4 | 3 cuisines compared (Chinese 18, Japanese 14, Thai 21) | 31 total | >= 9 (>= 3 each) | PASS |
| AC5 | Methodology documents search strategy | 31 | >= 3 | PASS |
| AC6 | ScholarEval dimensions present | 4 | >= 4 | PASS |
| AC7 | ScholarEval score >= 0.60 | 0.626 (recalculated) | >= 0.60 | PASS |
| AC8 | Zero-hallucination spot-check | 3/3 traced (see below) | 3 random refs | PASS |
| AC9 | README exists | file exists | exists | PASS |
| AC10 | README has install+usage sections | 6 | >= 4 | PASS |
| AC11 | Methodology log exists, >= 20 lines | 151 lines | exists + >= 20 | PASS |
| AC12 | Pack protocol phases documented | 6 | >= 6 | PASS |

**All 12 ACs: PASS**

---

## AC8 Zero-Hallucination Spot-Check Detail

Three references selected for trace verification:

### Reference [2] — Kim et al. 2020
- **Report claim**: DOI: 10.1016/j.fbio.2020.100615, 14 citations, Semantic Scholar
- **Methodology log**: Tool Call 3 records "Kim et al. 2020 'Correlation analysis between alpha-dicarbonyls and flavor compounds in soy sauce' (14 cit)"
- **Verdict**: TRACED — title, DOI, citation count all match tool result

### Reference [6] — USDA FDC 174278 (tamari)
- **Report claim**: Sodium 5586mg/100g, Protein 10.51g/100g, Sugars 1.7g/100g
- **Methodology log**: Tool Call 12 records "Protein 10.51g, Fat 0.1g, Carb 5.57g, Sugars 1.7g, Sodium 5586mg, Iron 2.38mg, Potassium 212mg per 100g"
- **Verdict**: TRACED — all nutrient values match exactly

### Reference [9] — Smit et al. 2016
- **Report claim**: 646 citations, from backward citation chain
- **Methodology log**: Tool Call 10 records "Smit et al. 2016 'Formation of taste-active amino acids in food fermentations' (646 cit)"
- **Verdict**: TRACED — title and citation count match

---

## Pack Protocol Compliance

### 6-Phase Research Protocol — Compliance Check

| Phase | Required | Methodology Log Evidence | Status |
|-------|----------|-------------------------|--------|
| Phase 1: Discovery | Search >= 2 academic databases | Tool Calls 1-6 (Semantic Scholar, OpenAlex, USDA) | PASS |
| Phase 2: Deep Reading | Read 2-3 full-text papers | Tool Calls 7-9 (WebSearch for Diez-Simon, Thai soy, type comparison) | PASS |
| Phase 3: Citation Chain | Forward + backward citations | Tool Calls 10-11 (Semantic Scholar API for Diez-Simon refs) | PASS |
| Phase 4: Database Cross-Verification | Query domain databases | Tool Calls 12-15 (USDA API detailed queries + web verification) | PASS |
| Phase 5: Synthesis | Cross-source findings | Tool Calls 16-17 (Maillard mechanism + usage quantities) | PASS |
| Phase 6: Report | Structured output with methodology | Report follows section 2.3 template; 4-point self-check documented | PASS |

---

## P1 Findings

### P1-1: Diez-Simon Citation Count Inconsistency (275 vs 216)

The same paper (Diez-Simon et al. 2020) is cited with TWO different citation counts:
- **275 citations**: report line 40 (Methodology table), methodology log Tool Call 2
- **216 citations**: report lines 135, 181, 191 (in-text and References section)

The methodology log records 275 (from OpenAlex, Tool Call 2). The report's References section says 216 (attributed to "Semantic Scholar via OpenAlex search"). These numbers likely come from different databases at different query times (OpenAlex vs Semantic Scholar count the same paper differently), but the report does not explain the discrepancy. The zero-hallucination rule requires traceable provenance — using a number from a different database than cited is a provenance mismatch.

**Fix**: Pick one authoritative count and use consistently, OR note that citation counts differ by database (OpenAlex: 275, Semantic Scholar: 216).

### P1-2: Tool Call Count Below Declared Tier Range

The handoff specifies tier classification as "Literature survey (20-40 tool calls expected)". The Reflexion self-assessment (Appendix B) says "17 tool calls for a literature survey (within 20-40 range)". However, 17 is NOT within the 20-40 range — it is below the minimum. The parenthetical "(within 20-40 range)" is factually incorrect.

**Fix**: Change to "17 tool calls for a literature survey (below the 20-40 expected range)" or remove the parenthetical.

---

## Summary

The deliverables meet all 12 acceptance criteria. The 6-phase research protocol was followed in order with documented tool calls for each phase. Zero-hallucination spot-check passed 3/3 references. Two P1 findings relate to internal data consistency, not structural compliance failures.
