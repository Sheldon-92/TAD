# ScienceClaw Skill Decoupling — Migration Feasibility Pattern

**Date:** 2026-05-28
**Linked to:** L2 pack-build-rules "Capability Pack: Design and Build Rules"

---

### ScienceClaw Skill Decoupling — Migration Feasibility Pattern - 2026-05-28
- **Context**: Phase 1 deep source study of ScienceClaw (285 skills, 8812 files). Grep scan of all 285 SKILL.md files for runtime dependency references.
- **Discovery**: ScienceClaw skills are architecturally decoupled from the OpenClaw runtime: 0/285 skills import plugin-sdk or context-engine; 37/285 mention "memory" in text (documentation references, not code imports); 8/285 reference other skills/ paths (documentation citations). The skill content (judgment rules, research protocols, API templates) is fully portable as standalone SKILL.md files. The tightly coupled components (context engine, routing, 96-file memory system, plugin SDK) are infrastructure — NOT needed for skill migration. Anti-slop value concentrates in specific thresholds (PRISMA 27-item checklist, DerSimonian-Laird formula, FDR < 0.05) rather than in generic API wrappers.
- **Action**: When porting skill libraries from external agent frameworks, scan for runtime dependency imports before planning migration scope. Zero-import skills can be extracted as judgment rules; import-heavy skills require infrastructure adaptation. Database API wrapper skills (curl templates to public APIs) have lower anti-slop value than domain-specific judgment rules — prioritize the latter.
- **Grounded in**: .tad/evidence/research/scienceclaw/architecture-analysis.md (Section 8), .tad/evidence/research/scienceclaw/skill-taxonomy.md (Runtime Deps column)
