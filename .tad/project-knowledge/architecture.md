# Architecture Knowledge

Project-specific architecture learnings accumulated through TAD workflow.

---

## Foundational: TAD Framework Architecture

> Established at project inception.

### Two-Agent System
- **Alex (Solution Lead)**: Design, planning, requirements, business acceptance
- **Blake (Execution Master)**: Implementation, testing, technical quality
- **failure_mode**: Naive default: one agent does both design and implementation in a single pass. Why wrong: the designer rationalizes implementation shortcuts, and the implementer makes unreviewed design decisions — no separation of concerns means quality drift goes undetected.

### Four-Gate Quality System
- Gate 1: Requirements Clarity
- Gate 2: Design Completeness
- Gate 3: Implementation Quality (v2.0: expanded)
- Gate 4: Integration/Acceptance (v2.0: simplified)
- **failure_mode**: Naive default: review only at the end (ship-time gate or no gate at all). Why wrong: defects caught late (post-implementation) cost 10-100x more to fix than defects caught at requirements or design stage; a single final gate misses requirement ambiguity and design incompleteness entirely.

---

## Accumulated Learnings

> ⚠️ Migrated to three-layer knowledge structure (2026-06-02, Knowledge Lifecycle Epic Phase 2).
> - Principles: `.tad/project-knowledge/principles.md`
> - Patterns: `.tad/project-knowledge/patterns/`
> - Incidents: `.tad/project-knowledge/incidents/`
> See `.tad/project-knowledge/README.md` for the Knowledge Lifecycle System documentation.
