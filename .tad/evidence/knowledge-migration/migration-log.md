# Knowledge Migration Log — Phase 2

**Date:** 2026-06-02
**Executor:** Blake (Knowledge Lifecycle Epic Phase 2)

## Migration Summary

| Layer | Count | Status |
|-------|-------|--------|
| L1 Principles | 13 | Migrated to principles.md |
| L2 Patterns | 76 | Migrated to 9 pattern files |
| L3 Incidents | 25 | Migrated to 25 incident files (18 in 2026-05/, 7 in 2026-06/) |
| DISCARD | 2 | Not migrated (see below) |
| **Total** | **116** | **Complete** |

## Discarded Entries

### #111: AI Security Hard Gaps (CLI Tooling) — from security.md Foundational
- **Rationale**: Outdated ecosystem snapshot, not actionable methodology. LLM03/LLM08/LLM10 gap list is a point-in-time observation that does not inform future decisions.
- **Note**: The entry remains in security.md Foundational section (which was kept intact per handoff Task 6 rules), but was NOT migrated to any layer.

### #113: Nested output_structure Enhancement — from security.md Accumulated Learnings
- **Rationale**: Superseded. The description+tree nested format is now standard in all packs. This was a one-time format evolution observation that no longer qualifies as a discovery.
- **Note**: Entry removed from active knowledge entirely (security.md Accumulated section replaced with migration pointer).

## Special Cases

### #116: Warm Palette Interpretation Rule — from frontend-design.md Foundational
- **Classification**: L2 (standalone, no theme group)
- **Disposition**: Stays in frontend-design.md which remains in the @import list. Not migrated to patterns/ because it is explicitly single-project evidence (per its own documentation) and frontend-design.md is not part of this migration scope.

## Forward-Compat Note
- knowledge-blame.sh scope guard uses `.tad/project-knowledge/*` glob which only matches one level deep. Files in `patterns/` and `incidents/` subdirectories will NOT match. This is a KNOWN issue — P3 to fix.
