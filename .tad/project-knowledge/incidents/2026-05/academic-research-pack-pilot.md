# Academic Research Pack Pilot: Quality Gap Analysis

**Date:** 2026-05-28
**Linked to:** L2 pack-evaluation "Capability Pack Quality Bar: Anti-Slop Metrics"

---

### Academic Research Pack Pilot: Quality Gap Analysis - 2026-05-28
- **Context**: Epic EPIC-20260527-academic-research-pack Phase 7 pilot test. Soy sauce cross-cultural usage study. ScholarEval 0.626 (Minor Revision). 12 citations verified, zero hallucination. 17 tool calls (below 20 minimum for literature survey tier).
- **Discovery**: Three structural quality gaps in the pack's first real-world test: (1) **Depth enforcement is advisory, not blocking** — Blake self-reported 17 < 20 tool calls but completed anyway. The pack's minimum tool-call thresholds are self-checked by the agent, not mechanically enforced. This mirrors TAD's "Mechanical Enforcement Rejected on Single-User CLI" principle but means the depth guarantee depends on agent honesty. (2) **Evidence level disambiguation missing** — recipe-website quantities (America's Test Kitchen "2 tbsp per stir-fry") were presented alongside USDA-verified lab data (5493mg Na/100g) without evidence-grade labels. The pack needs a "source quality tier" annotation rule (Tier 1: primary food composition DB / Tier 2: peer-reviewed paper / Tier 3: recipe website / Tier 4: general web). (3) **Database coverage gaps foreseeable but not pre-mitigated** — Thai soy sauce USDA gap was predicted by expert review (architect P0) but the pack's fallback-chains.md only covers academic database fallbacks, not food composition database alternatives (Thai FDA, Japan Standard Tables of Food Composition). Domain-specific fallback chains need to be added to cluster reference files, not just the protocol-level fallback reference.
- **Action**: For academic-research pack v0.2: (a) Add evidence-grade labeling rule to research-protocol.md (Tier 1-4 with visual markers). (b) Add domain-specific database fallback chains to database-apis-life-sciences.md (Thai FDA, JP MEXT food composition, CN CDC nutrition). (c) Consider adding a "depth checkpoint" rule: at 50% of minimum tool calls, agent must self-audit coverage gaps before proceeding.
- **Grounded in**: .tad/evidence/research/food-science-pilot/soy-sauce-cross-cultural-report.md, .tad/evidence/research/food-science-pilot/methodology-log.md
