# Architecture Review: codebase-memory-mcp Integration

**Reviewer:** backend-architect (Layer 2)
**Date:** 2026-06-02
**Handoff:** HANDOFF-20260602-codebase-memory-mcp-integration

## Findings

### P0 (Fixed)

**P0-1: Migrate path missing install hint**
- tad.sh had 3 case arms (install/upgrade/migrate) but hint only in 2
- Fix: Added hint to migrate path

**P0-2: Documentation conflated shell injection and Cypher injection defenses**
- jq --arg prevents shell/JSON injection; regex prevents Cypher injection
- Fix: Updated SKILL.md comment and integration guide to clarify two-layer defense

**P0-3: list_projects projects[0] assumed current project**
- On multi-project machines, first project may not be current directory
- Fix: Updated integration guide to use path-based project matching

### P1 (Addressed)

**P1-1: Pinned v0.7.0 will go stale**
- Accepted: Intentional conservative pinning per supply-chain safety

**P1-2: Graph probe timeout not mechanically enforced**
- Accepted: Consistent with existing LSP provision protocol pattern

**P1-3: detect_changes returns empty on clean working tree**
- Fixed: Added fallthrough to LSP path when detect_changes returns empty

**P1-4: curl|bash in guide without security caveat**
- Accepted: Guide documents the manual install command users will run. tad.sh is hint-only.

### P2

- P2-1: 7-day threshold could be configurable
- P2-2: OPTIONAL TOOLS block lacks dynamic status
- P2-3: No telemetry for graph path usage
- P2-4: Downstream sync boundary could be more explicit

## Architecture Assessment

- **Coupling:** Properly decoupled. Removing codebase-memory-mcp leaves TAD fully functional.
- **Sync risk:** Minimal. Only printf hints added to tad.sh. No executable changes.
- **Supply-chain:** Correctly hint-only with pinned version tag.
- **Fallback:** Three-tier properly degrades. Empty detect_changes now falls through to LSP.

## Verdict: PASS (after P0 fixes applied)
