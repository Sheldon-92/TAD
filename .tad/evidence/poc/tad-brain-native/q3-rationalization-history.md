# Q3: Rationalization History

**Query**: "What rationalizations have TAD agents used to justify skipping quality gates, and what was the outcome each time?"
**Method**: Agent tool (general-purpose) reading brain-index.md → relevant files → synthesized answer
**Phase 1 Result**: ❌ (marker format "ANTI-RATIONALIZATION:" not matched by BM25)

## Agent Answer Summary

7 distinct rationalization patterns documented:
1. "Express means exempt from review" → 4 P0s found on 15-min edit
2. "The work happened; writing the file is just ceremony" → Claims invisible to verification chain
3. "Completion Report is just paperwork" / "Only lint warnings" → Circular trigger failure (Codex dogfood)
4. "13/13 installed = validated" → Validation theater (cross-model audit)
5. "It passed in the browser" → Environment confounding (CSP enforcement gap)
6. "Blake's summary says it passed" → Gate 4 now requires raw-data recompute
7. "Silent compliance is compliance" → honest_partial protocol established

## Sources Cited by Agent

1. principles.md — Express Handoff, YOLO Audit, Execution Discipline
2. patterns/gate-design.md — Claims Need Carriers, Gate 4 Verification
3. patterns/ac-verification.md — Real-Browser E2E Confounding
4. evidence/designs/skill-body-reference-audit.md — Circular trigger audit

## Phase 1 vs Phase 2 Comparison

| Aspect | Phase 1 (gbrain BM25) | Phase 2 (tad-brain) |
|--------|----------------------|---------------------|
| Found answer | ❌ No | ✅ Yes |
| Instances found | 0 (marker mismatch) | 7 distinct patterns |
| Outcomes documented | N/A | Each with specific consequence |
| Cross-document | Failed | 4+ files synthesized |

## Raw Result Quality

Alex judges at Gate 4. Raw answer includes 7 enumerated rationalizations each with specific incident, outcome, and resulting systemic fix.
