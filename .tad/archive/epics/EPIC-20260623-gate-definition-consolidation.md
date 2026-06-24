# Epic: Gate Definition Consolidation — Single Source of Truth

**Epic ID**: EPIC-20260623-gate-definition-consolidation
**Created**: 2026-06-23
**Owner**: Alex
**Source**: P2 MECE Gate Restructure expert review findings (EPIC-20260623-community-pattern-adoption)

---

## Objective
Establish a single source of truth (SSOT) for Gate 1-4 checklist definitions. Currently 8+ files each maintain their own Gate checklist items with different content. After consolidation, one canonical file defines all Gate checklists; all other files reference it instead of duplicating.

## Success Criteria
- [ ] One canonical file contains Gate 1-4 checklist definitions (THE source of truth)
- [ ] At least 5 files that previously had independent Gate definitions now reference the canonical file
- [ ] Gate execution can resolve references and read checklist items (no dead links)
- [ ] Semantic distinctions preserved (ownership vs execution vs self-check)

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Audit + SSOT Design | ✅ Done | HANDOFF-20260623-gate-ssot-p1.md | Canonical file + inline-derived pattern + reconciliation + all files migrated |
| 2 | Migration | ✅ Done | (included in P1 — Blake implemented full migration in one pass) | All 7 files updated + 3 mirrors |

### Phase Dependencies
P1 → P2 (sequential). P1 designed AND implemented; P2 was small enough to include.

### Derived Status
- **Status**: Complete (all ✅)
- **Progress**: 2 / 2

---

## Phase Details

### Phase 1: Audit + SSOT Design

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Create the canonical Gate checklist definitions file. Map all 8+ files that currently have Gate definitions. Design the reference pattern (how other files point to the canonical source without duplicating). Determine which Gate items are the "correct" ones when files disagree. NOT in scope: actually migrating all files (that's P2), MECE restructuring (separate Epic), changing Gate execution protocols.

#### Input
- P2 audit results: .tad/evidence/research/agent-orchestration-patterns/2026-06-23-gate-mece-audit.md
- Code reviewer findings: 8+ files identified with divergent Gate definitions
- Current files: alex/SKILL.md, gate/SKILL.md, blake/SKILL.md, config-quality.yaml, quality-gate-checklist.md, acceptance-protocol.md

#### Output
- New canonical file (e.g., .tad/gates/gate-canonical-checklist.md) with Gate 1-4 definitions
- Migration plan: per-file table showing current state → target state
- Reference pattern definition (how files reference instead of duplicate)

#### Acceptance Criteria
- [ ] Canonical file exists with Gate 1-4 checklist items (reconciled from all sources)
- [ ] Migration plan table covers all 8+ files with specific action per file
- [ ] Reference pattern documented (comment syntax or include mechanism)
- [ ] For each Gate, resolved which items from which file are "correct" when sources disagree

#### Files Likely Affected
- .tad/gates/gate-canonical-checklist.md (CREATE — the new canonical file)

#### Dependencies
None

#### Notes
- Key risk (user's concern): references must be resolvable — dead links = silent failure
- Key risk (architect's concern): some files serve different purposes (ownership vs execution) — don't blindly merge
- Use P2 audit data: the audit already mapped which files have which Gate definitions

### Phase 2: Migration

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Update all 8+ files to reference the canonical source instead of maintaining independent Gate checklist definitions. Each file gets a reference comment pointing to the canonical file, and its inline checklist items are replaced with a reference note. NOT in scope: changing checklist items themselves, MECE restructuring, changing Gate execution flow.

#### Input
- P1 canonical file
- P1 migration plan

#### Output
- All 8+ files updated with references
- .agents/ mirrors synced
- Verification: Gate execution dry-run with new reference pattern

#### Acceptance Criteria
- [ ] At least 5 files updated from independent definitions to references
- [ ] .agents/ mirrors byte-identical
- [ ] Gate execution dry-run: gate/SKILL.md can resolve references to canonical file
- [ ] No file still contains an independent Gate checklist definition that contradicts the canonical source

#### Files Likely Affected
- .claude/skills/alex/SKILL.md (MODIFY — my_gates + gate4_v2 sections)
- .claude/skills/gate/SKILL.md (MODIFY — Gate 1/2/3/4 checklist sections)
- .claude/skills/blake/SKILL.md (MODIFY — my_gates.gate4_v2)
- .claude/skills/alex/references/acceptance-protocol.md (MODIFY — gate4_v2_checklist)
- .tad/config-quality.yaml (MODIFY — gate checks: lists)
- .tad/gates/quality-gate-checklist.md (MODIFY or DELETE — superseded by canonical)
- .agents/ mirrors (SYNC)

#### Dependencies
Phase 1

#### Notes
- Blast radius is large (8+ files) — Blake should use worktree or careful staging
- Test after each file change, not batch-then-test

---

## Context for Next Phase
{Alex updates after each *accept}

### Completed Work Summary
(none yet)

### Decisions Made So Far
- 2026-06-23: Canonical file as SSOT (not extending an existing file)
- 2026-06-23: Reference pattern (not git submodule or symlink — too complex)
- 2026-06-23: P2 of Community Pattern Epic paused until this Epic completes

### Known Issues / Carry-forward
- P2 MECE audit results available: .tad/evidence/research/agent-orchestration-patterns/2026-06-23-gate-mece-audit.md
- After this Epic: return to Community Pattern Epic P2 (MECE restructure on the now-consolidated SSOT)

---

## Notes
- This Epic is the prerequisite for Community Pattern Adoption Epic Phase 2 (MECE Gate Restructure)
- Triggered by code reviewer P0 findings during P2 handoff review
