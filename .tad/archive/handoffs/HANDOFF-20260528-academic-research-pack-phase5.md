---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/capability-packs/academic-research", ".claude/skills/academic-research"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Academic Research Pack — Phase 5: Multimodal + Memory

**From:** Alex | **To:** Blake | **Date:** 2026-05-28
**Epic:** EPIC-20260527-academic-research-pack.md (Phase 5/6)

---

## 🔴 Gate 2: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Two new reference files for the academic-research pack: (1) multimodal-research.md — image analysis methodology for research contexts, and (2) pattern-extraction.md — visual pattern comparison workflow for cross-cultural artifact studies. Plus verify that the existing TAD memory system (project-knowledge + NotebookLM) works as the research memory layer without new infrastructure.

### 1.2 Why
The user's primary research topics both involve images: plant/artifact ornamental patterns (visual comparison, line extraction, motif classification) and food science (ingredient visual identification, plating analysis). Claude is natively multimodal — the pack needs to teach METHODOLOGY (how to systematically analyze images for research), not add vision capability.

### 1.3 Intent Statement
**不是要做的**:
- ❌ NOT building LanceDB or any new storage backend (blueprint Decision 2: TAD file-based default)
- ❌ NOT adding computer vision code/models (Claude's native vision is sufficient)
- ❌ NOT building a new memory system (existing project-knowledge + NotebookLM = the memory)

---

## 2. Technical Design

### 2.1 Two Reference Files

**A. `multimodal-research.md`** — General image analysis methodology for research:
- When to use image analysis in academic research (documentation, comparison, evidence)
- Structured image description protocol: what to observe, what to record, what to measure
- Image-to-text extraction rules: describe objectively (measurements, colors with hex, spatial relationships) before interpreting
- Cross-image comparison methodology: feature matrix approach (list features × images → similarity scores)
- Image citation rules: provenance (museum, collection, accession number), resolution, license, capture conditions
- Anti-hallucination for images: "describe only what is visible; if resolution is insufficient for a detail, say so"
- Integration with text-based research: how image findings connect to literature (cite both the image source AND supporting papers)

**B. `pattern-extraction.md`** — Specialized workflow for visual pattern/motif research:
- Motif identification protocol: isolate repeating elements, classify by geometry (spiral, meander, rosette, palmette, etc.)
- Line abstraction methodology: trace dominant contours, simplify to geometric primitives, compare across artifacts
- Cross-cultural comparison framework: feature matrix (motif type × culture × period × material × technique)
- Similarity scoring: structural similarity (same geometry, different scale) vs stylistic similarity (same aesthetic, different geometry)
- Provenance chain: artifact → collection → photograph → digital reproduction → analysis — each step introduces potential distortion
- Domain vocabulary: specific terminology for ornamental patterns (guilloche, arabesque, interlace, fret, scroll, etc.)
- Research output format: comparison plates (side-by-side image grids with annotations), feature extraction tables, similarity dendrograms

### 2.2 Memory Integration Verification

Verify the existing TAD stack works as research memory:

| Memory Need | TAD Solution | Verification |
|------------|-------------|-------------|
| Cross-session findings | `.tad/project-knowledge/` entries via Knowledge Assessment | Write a test entry, verify retrievable |
| Semantic recall across sources | NotebookLM via `*research-notebook ask` | Query existing notebook, verify cross-source synthesis |
| Research pattern retrieval | `.tad/evidence/research/` files | Verify evidence directory structure supports per-topic organization |
| Reflexion Cycle storage | Completion report Knowledge Assessment section | Verify reflexion-cycle.md rules can be applied using existing Gate 3 KA |

No new infrastructure needed — just verify + document the mapping in a "Memory Integration" section added to SKILL.md.

---

## 3. Implementation Steps

### Task 1: Write multimodal-research.md (25 min)
1. Research image analysis methodologies used in digital humanities and food science (WebSearch for 2-3 authoritative sources: digital art history methods, food photography analysis standards)
2. Write reference file following existing reference structure (Quick Reference table → Detailed Rules → Anti-Patterns)
3. Include specific measurement rules (e.g., "record dimensions in mm, color in hex + Munsell notation for artifacts, spatial relationships as compass directions + percentages")
4. Include zero-hallucination adaptation for images: "If image resolution is below X, state 'insufficient resolution for this detail' rather than inferring"
5. Include measurement fallback rule: "If precise measurement (mm, hex color, Munsell notation) is required but tool access is unavailable, record as relative proportions with confidence qualifier (e.g., 'approximately 1/3 of total height, ±10%'). Do NOT output fake precise measurements." — Claude vision cannot reliably extract absolute mm or Munsell codes from photos.

### Task 2: Write pattern-extraction.md (25 min)
1. Research ornamental pattern classification systems (WebSearch: Grammars of Ornament, ICS pattern classification, Getty AAT for pattern terminology)
2. Write reference file with specific pattern vocabulary (geometric types, cultural origin markers)
3. Include cross-cultural comparison framework with concrete feature dimensions
4. Include example feature matrix template (can be used directly in research output)

### Task 3: Memory Integration Verification (15 min)
1. Write a test project-knowledge entry: "Test: academic-research memory integration — [date]"
2. Verify NotebookLM notebook (7779d639 or any active) responds to `*research-notebook ask`
3. Verify `.tad/evidence/research/` directory supports per-topic subdirectories
4. Add "Step 6: Memory & Persistence" section to CAPABILITY.md documenting how TAD's existing systems serve as research memory
5. Remove test entry after verification

### Task 4: Update SKILL.md + Re-install (5 min)
1. Add multimodal-research.md and pattern-extraction.md to Quick Rule Index
2. Add "Multimodal Research" detection signals to Step 1 task type table (e.g., "user uploads image", "pattern analysis", "visual comparison")
3. Re-run install.sh, verify 17 total reference files

---

## 4. Files to Create/Modify

| # | File | Action |
|---|------|--------|
| 1 | .tad/capability-packs/academic-research/references/multimodal-research.md | CREATE |
| 2 | .tad/capability-packs/academic-research/references/pattern-extraction.md | CREATE |
| 3 | .tad/capability-packs/academic-research/CAPABILITY.md | MODIFY (Quick Rule Index + Memory section + multimodal signals) |
| 4 | .tad/capability-packs/academic-research/install.sh | MODIFY (if needed for new files) |
| 5 | .claude/skills/academic-research/ (via re-install) | MODIFY |

---

## 9. Acceptance Criteria

| # | Requirement | Verification |
|---|------------|-------------|
| AC1 | multimodal-research.md created | `test -f .tad/capability-packs/academic-research/references/multimodal-research.md` |
| AC2 | pattern-extraction.md created | `test -f .tad/capability-packs/academic-research/references/pattern-extraction.md` |
| AC3 | Image zero-hallucination rule present | `grep -c 'insufficient resolution' .tad/capability-packs/academic-research/references/multimodal-research.md` ≥ 1 |
| AC4 | All 6 pattern vocabulary terms included | `grep -cE 'guilloche\|arabesque\|interlace\|palmette\|meander\|rosette' .tad/capability-packs/academic-research/references/pattern-extraction.md` = 6 |
| AC5 | Feature matrix template included | `grep -c 'feature.*matrix\|comparison.*matrix' .tad/capability-packs/academic-research/references/pattern-extraction.md` ≥ 1 |
| AC6 | Memory integration section added to CAPABILITY.md and propagated | `grep -c 'Research Memory\|Memory.*Integration\|Memory.*Persistence' .tad/capability-packs/academic-research/CAPABILITY.md` ≥ 1 AND `grep -c 'Research Memory\|Memory.*Integration\|Memory.*Persistence' .claude/skills/academic-research/SKILL.md` ≥ 1 |
| AC7 | 17 total reference files installed | `ls .claude/skills/academic-research/references/*.md \| wc -l` = 17 |
| AC8 | Each new reference ≤ 400 lines | `wc -l .tad/capability-packs/academic-research/references/multimodal-research.md .tad/capability-packs/academic-research/references/pattern-extraction.md \| grep -v total \| awk '{if($1>400) print "FAIL: "$2}'` = empty |

---

## 10. Important Notes

### 10.1 Anti-Slop for Image Analysis
Image analysis rules are high risk for generic AI-generated content ("observe the colors and shapes"). Every rule must specify WHAT to measure and HOW to record it. Examples:
- ✅ "Record color as hex value + nearest Munsell notation; record dimensions in mm relative to artifact total height"
- ❌ "Carefully observe the colors and proportions of the pattern"

### 10.2 Sub-Agent Suggestions
- code-reviewer: verify reference file structure consistency
- ux-expert-reviewer: verify the pattern comparison framework is practically usable (not just theoretically complete)

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | Memory approach | Verify existing TAD stack, no new infra | Blueprint Decision 2: TAD file-based default; NotebookLM already available |
| 2 | Image analysis scope | Methodology only, not CV code | Claude is natively multimodal; pack teaches judgment, not capability |
| 3 | Pattern extraction depth | Specialized reference for ornamental patterns | User's primary research topic; generic image analysis insufficient |
