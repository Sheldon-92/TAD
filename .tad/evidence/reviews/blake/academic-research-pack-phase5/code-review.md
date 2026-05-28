# Code Review: Academic Research Pack Phase 5 — Multimodal + Memory

**Reviewer**: code-reviewer (structural consistency, content quality, domain accuracy)
**Date**: 2026-05-28
**Files reviewed**:
- `.tad/capability-packs/academic-research/references/multimodal-research.md` (NEW, 175 lines)
- `.tad/capability-packs/academic-research/references/pattern-extraction.md` (NEW, 212 lines)
- `.tad/capability-packs/academic-research/CAPABILITY.md` (MODIFIED)
- `.claude/skills/academic-research/SKILL.md` (propagated)

---

## Summary

Two high-quality reference files that teach systematic image analysis and pattern extraction methodology for academic research. The content is specific, actionable, and passes the anti-slop bar (hex codes, mm thresholds, DPI minimums, ΔE values, Munsell notation, wallpaper group count). CAPABILITY.md modifications are structurally sound — Step 6 Memory Integration is well-placed and the Quick Rule Index entries are correct.

**AC verification**: All 8 ACs pass (AC1-AC8 verified via grep/wc/test commands).

**Overall verdict**: PASS with 0 P0, 3 P1, 4 P2.

---

## P0 — Blocking Issues

None.

---

## P1 — Important Issues (Should Fix)

### P1-1: Missing `> Source:` citations in both new reference files

**Files**: `multimodal-research.md` (0 citations), `pattern-extraction.md` (0 citations)

Every other reference file in this pack has `> Source:` citations tracing rules to their origin. The count across existing files:

| File | `> Source:` count |
|------|------------------|
| research-protocol.md | 13 |
| visualization.md | 23 |
| experiment-design.md | 19 |
| statistics.md | 40 |
| fallback-chains.md | 6 |
| **multimodal-research.md** | **0** |
| **pattern-extraction.md** | **0** |

Per architecture.md "Source Citation Integrity for Adapted Values" (2026-05-28), every rule needs provenance. Since these are new rules (not adapted from ScienceClaw SCIENCE.md), the citations should reference the research sources used during Task 1 and Task 2 — e.g., the digital humanities methodology sources and ornamental pattern classification systems that were WebSearched per the handoff implementation steps.

**Fix**: Add `> Source:` after each major section or rule block. For rules derived from standard methodology (e.g., observation-before-interpretation from art history methods, wallpaper groups from crystallography), cite the authoritative source or state "> Source: Standard methodology; no single source". For rules synthesized from WebSearch during implementation, cite the search results used.

### P1-2: Feature matrix / similarity scoring overlap between the two new files

**multimodal-research.md** defines:
- Feature matrix approach (§5.1-5.2, lines 122-139)
- Similarity scoring with 4 types: Structural / Stylistic / Chromatic / Compositional (§5.3, lines 142-151)

**pattern-extraction.md** defines:
- Feature matrix dimensions (§4.1-4.2, lines 124-146)
- Similarity scoring with a 0-5 scale for Structural and Stylistic (§4.3, lines 148-161)

Both files independently define feature matrices and similarity scoring but with **different schemas**:
- multimodal uses 4 similarity types (categorical)
- pattern-extraction uses 2 dimensions on a 0-5 scale (quantitative)

An agent loading both files (as Step 1 directs for multimodal research) will encounter two competing frameworks. The multimodal file's ΔE ≤ 5 chromatic threshold has no counterpart in pattern-extraction.

**Fix**: Add a cross-reference note in each file. In multimodal-research.md §5, add: "For ornamental pattern comparison, use the specialized 5-dimension matrix and 0-5 scoring scale from pattern-extraction.md instead of the general framework below." In pattern-extraction.md §4, add: "This specialized framework supersedes the general cross-image comparison in multimodal-research.md for pattern/motif studies."

### P1-3: Multimodal tier in Step 1 lacks "Multimodal research" example inputs

**File**: `CAPABILITY.md` lines 47-70 (and propagated SKILL.md)

Every other tier (Quick factual, Literature survey, Comprehensive review, Systematic review) has 3 example inputs listed after the table. The new Multimodal research tier has no examples.

**Fix**: Add an example block after the existing examples:

```
Multimodal research:
- "Analyze this ceramic bowl's decorative pattern and compare with Sasanian metalwork motifs"
- "Extract and classify the ornamental patterns in these 5 manuscript illuminations"
- "Document the visual features of these food plating presentations for a comparative study"
```

---

## P2 — Suggestions (Consider)

### P2-1: No rule ID prefix in new files (non-blocking, format variation is precedented)

Visualization.md uses `R-VIZ-001` style rule IDs; domain-biomedical.md, domain-physical.md, domain-social.md also use rule IDs. Other references (research-protocol.md, fallback-chains.md, experiment-design.md, etc.) do not.

The new files follow the non-rule-ID pattern which is valid — the pack has two conventions. However, if a future consumer needs to reference a specific rule (e.g., "the observation-before-interpretation rule"), there is no stable identifier.

**Suggestion**: Consider adding rule IDs like `R-IMG-001` / `R-PAT-001` in a future pass if these files grow or are referenced by other packs.

### P2-2: multimodal-research.md §2.2 measurement fallback — "tool access" phrasing

Line 60: `"precise measurement requires manual tool access"` — this is slightly ambiguous. "Tool access" could mean the agent's tool permissions or physical measurement instruments.

**Suggestion**: Clarify to: "precise measurement requires physical instrument access or dedicated image measurement software" to remove ambiguity.

### P2-3: pattern-extraction.md §3.1 cultural associations could be more precise on dates

Lines 95-101: Cultural associations list cultures but only some include dates. For example:
- Guilloche: "Greco-Roman architecture, Islamic metalwork, banknote security printing" — no date ranges
- Rosette: "Near Eastern (earliest ~3000 BCE), Gothic tracery, Mughal jali" — has dates

**Suggestion**: For consistency, add approximate date ranges to all cultural associations. This makes the vocabulary table more useful as a quick reference for dating context.

### P2-4: CAPABILITY.md Step 6 references `*research-notebook ask` and `*research-notebook ingest` without fallback

Lines 153, 161: These assume NotebookLM integration is set up. If a project does not have NotebookLM configured, the instructions provide no fallback.

**Suggestion**: Add a one-liner: "If NotebookLM is not configured for this project, skip the notebook-specific rows. Cross-source synthesis falls back to manual comparison of `.tad/evidence/research/` files."

---

## Positive Observations

1. **Anti-slop quality is excellent.** Both files consistently specify WHAT to measure and HOW to record it — hex values, mm with reference objects, compass directions with percentage coverage, Munsell notation, DPI thresholds, ΔE color difference values. The anti-pattern tables are particularly strong with concrete "wrong → right" examples.

2. **The "Absolute rule" on line 62 of multimodal-research.md** is exactly right. Explicitly acknowledging Claude vision's limitation on absolute measurements prevents a high-risk hallucination failure mode. This is the most valuable single rule in the file.

3. **Pattern-extraction.md's 3-level line abstraction** (L1 raw trace → L2 simplified contour → L3 geometric primitive) with explicit thresholds (5% area for L1→L2, R² ≥ 0.95 for L2→L3) is specific and actionable. The requirement to retain all 3 levels prevents evidence loss.

4. **The 17 wallpaper groups reference** (pattern-extraction.md line 83) is mathematically correct and adds real value — an agent without this reference would not know to classify repeat patterns by their symmetry group.

5. **Critical rule consistency**: Both files include the same essential guardrail — visual similarity does NOT prove historical connection (multimodal-research.md line 151, pattern-extraction.md line 161). This redundancy is intentional and correct since either file might be loaded independently.

6. **Step 6 Memory Integration** is well-designed. It maps every research memory need to an existing TAD mechanism without inventing new infrastructure. The "Do NOT duplicate: choose one persistence path per finding" rule prevents the common trap of writing the same finding to multiple locations.

---

## Verdict

**PASS** — 0 P0, 3 P1, 4 P2.

P1-1 (missing source citations) is the most important fix — it is a pack-wide convention that all other 15 reference files follow. P1-2 (overlapping frameworks) is a usability issue that becomes visible only when both files are loaded simultaneously. P1-3 (missing examples) is a straightforward completeness gap.

None of the issues block shipping, but P1-1 should be addressed before the next phase to maintain pack-wide citation integrity standards.
