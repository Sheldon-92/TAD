# Scoring Rubrics in Reference Files Need Methodology Review

**Date:** 2026-05-28
**Linked to:** L2 pack-evaluation "Anti-AI-Slop as Cross-Pack Quality Bar"

---

### Scoring Rubrics in Reference Files Need Methodology Review - 2026-05-28
- **Context**: Phase 5 academic-research pack. UX-expert-reviewer found 2 P0 issues in pattern-extraction.md's similarity scoring rubric that code-reviewer missed entirely.
- **Discovery**: When capability pack reference files contain scoring/rating systems (0-5 scales, pass/fail rubrics, classification schemes), code-reviewer checks structural consistency and anti-slop but does NOT check inter-rater reliability — whether two independent raters would assign the same score. The UX-expert-reviewer caught: (1) overlapping score definitions (Score 2 "2-3 shared features" vs Score 3 "same symmetry group" were simultaneously satisfiable), (2) undefined terms in rubric ("rhythm" had no glossary entry). These are invisible to code review but critical for research output reproducibility.
- **Action**: Any capability pack reference file containing a scoring rubric, rating scale, or classification scheme should trigger ux-expert-reviewer (or equivalent methodology review) in Layer 2, not just code-reviewer. Add to Blake's Layer 2 trigger heuristic: if reference file contains "|.*Score.*|" or "0-5 scale" or "rating" patterns, include ux-expert-reviewer in Group 2.
- **Grounded in**: .tad/evidence/reviews/blake/academic-research-pack-phase5/ux-review.md (P0-1, P0-2)
