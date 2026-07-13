---
name: Academic Research Pack Epic Complete
description: First non-software-dev capability pack — ScienceClaw port, 7 phases, food science pilot test, quality gap analysis for v0.2
type: project
originSessionId: be9abc02-3c07-44d0-95d1-3c963c6025eb
---
Academic Research Capability Pack (EPIC-20260527) completed 2026-05-28.

**What**: TAD's first non-software-development capability pack. Ported ScienceClaw (823★, 285 skills) core patterns into TAD format. 7 phases: source study → core build → skill migration → database integration → multimodal → Python CV → pilot test.

**Deliverables**: SKILL.md router + 18 reference files + academic-search.sh (6 DBs) + image-analysis.py (5 CV subcommands). 87 ScienceClaw skills extracted. Installed in Claude Code skill list.

**Pilot test**: Cross-cultural soy sauce usage (CN/JP/TH). ScholarEval 0.626 (Minor Revision). 12 verified citations, zero hallucination. 17 tool calls (below 20 minimum — honest self-report).

**Why:** User wants TAD for academic research (plant ornamental patterns + food science). Proves TAD methodology is domain-agnostic.

**Quality gaps for v0.2**: (1) depth enforcement advisory not blocking, (2) evidence-grade labeling missing (recipe site ≠ USDA data), (3) domain-specific DB fallback chains needed (Thai FDA, JP food composition).

**How to apply:** User says "学术/论文/文献/PRISMA/PubMed" → pack auto-loads. Two research topics pending: 🌿 plant ornamental patterns (纹样), 🍜 food science (食物调味).
