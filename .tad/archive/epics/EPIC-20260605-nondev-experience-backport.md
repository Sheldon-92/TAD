# Epic: Non-Dev Experience Backport (Colin声音项目 → TAD Framework)

**Epic ID**: EPIC-20260605-nondev-experience-backport
**Created**: 2026-06-05
**Owner**: Alex

---

## Objective
Backport learnings from Colin声音项目 (TAD's deepest non-dev field deployment: 2 podcast episodes, 23 handoffs, 13 architecture entries, 2 custom packs) into the TAD framework. Three improvements: (1) pack architecture rules for content production domains, (2) Gate 3 deliverable-type branching so non-code projects stop failing at 50%, (3) promote ai-podcast-production pack to TAD main repo for distribution.

## Success Criteria
- [ ] pack-build-rules.md has 3 new entries (cross-cutting rules, iteration history, quality delta)
- [ ] Gate 3 branches on task_type: code→build/test/lint, deliverable→pack rubric
- [ ] ai-podcast-production pack exists in TAD main repo with install.sh and registry entry
- [ ] Non-dev project gate failure rate should drop (verifiable on next Colin声音项目 session)

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Pack Architecture Knowledge | ✅ Done | HANDOFF-20260605-nondev-pack-knowledge.md | 3 new pack-build-rules entries (14 total) |
| 2 | Gate 3 Deliverable Branch | ✅ Done | HANDOFF-20260605-podcast-rubric-entry.md | ai-podcast-production rubric added to deliverable-rubrics.yaml (6 dims, weighted) |
| 3 | Pack Promotion & Distribution | ✅ Done | — | ai-podcast-production copied, registered, install.sh created |

### Phase Dependencies
All phases are sequential. P2 references P1's quality delta pattern. P3 can run independently but benefits from P2's rubric infrastructure.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Pack Architecture Knowledge

**Status:** ✅ Done
**Execution:** pending

#### Scope
Write 3 new entries to pack-build-rules.md based on Colin声音项目 patterns: (1) cross-cutting rules layer, (2) iteration history tables, (3) quality delta pattern for content packs. Also extract Colab platform failure modes into ml-training pack references.

NOT in scope: Gate SKILL changes (Phase 2), pack file copying (Phase 3).

#### Input
- Colin声音项目 ai-podcast-production/SKILL.md (cross-cutting rules section)
- Colin声音项目 music-arrangement.md (iteration history table)
- Colin声音项目 architecture.md (Colab failure modes)
- Existing .tad/project-knowledge/patterns/pack-build-rules.md

#### Output
- pack-build-rules.md with 3 new entries
- ml-training pack colab-execution.md updated with Colin failure modes (if not already there)

#### Acceptance Criteria
- [ ] pack-build-rules.md contains entry "Cross-Cutting Rules Layer" with SKILL.md placement guidance
- [ ] pack-build-rules.md contains entry "Iteration History Table" with template format
- [ ] pack-build-rules.md contains entry "Content Production Quality Delta" with 85-to-95 pattern
- [ ] grep -c '^### ' .tad/project-knowledge/patterns/pack-build-rules.md >= 13 (currently 10 + 3 new)

#### Files Likely Affected
- .tad/project-knowledge/patterns/pack-build-rules.md (MODIFY)
- .tad/project-knowledge/patterns/_index.md (MODIFY — update hook for pack-build-rules)

#### Dependencies
None (can execute independently)

#### Notes
These are knowledge writes — Blake executes but content is derived from Alex analysis above.

### Phase 2: Gate 3 Deliverable Branch

**Status:** ✅ Done
**Execution:** pending

#### Scope
Add task_type branching to Gate 3 Layer 1 in gate/SKILL.md. When task_type=deliverable, skip build/test/lint and instead load pack-specific rubric from deliverable-rubrics.yaml (or pack's own quality criteria). Create the deliverable-rubrics.yaml template.

NOT in scope: Changing Gate 4 (already simplified). NOT changing existing code/yaml/research paths.

#### Input
- Phase 1 quality delta pattern (how rubrics should be structured)
- Colin声音项目 gate failure data (50% failure rate on deliverables)
- Existing gate/SKILL.md Gate 3 v2 Layer 1

#### Output
- gate/SKILL.md with task_type branching in Gate 3 Layer 1
- .tad/capability-packs/deliverable-rubrics.yaml (template with example rubric from ai-podcast-production)
- Handoff template updated: task_type enum includes "deliverable"

#### Acceptance Criteria
- [ ] gate/SKILL.md Gate 3 Layer 1 has explicit branch: if task_type==deliverable → load rubric path
- [ ] deliverable-rubrics.yaml exists with at least 1 example rubric (podcast quality)
- [ ] Handoff template task_type comment includes "deliverable" option
- [ ] Existing code/yaml/research paths unchanged (no regression)

#### Files Likely Affected
- .claude/skills/gate/SKILL.md (MODIFY)
- .tad/capability-packs/deliverable-rubrics.yaml (CREATE)
- .tad/templates/handoff-a-to-b.md (MODIFY — task_type comment)

#### Dependencies
Phase 1 (quality delta pattern informs rubric structure)

#### Notes
Core technical change. The rubric loading mechanism should mirror how pack-registry.yaml works: gate reads the rubric file, finds the matching pack entry, evaluates criteria.

### Phase 3: Pack Promotion & Distribution

**Status:** ✅ Done
**Execution:** pending

#### Scope
Copy ai-podcast-production pack from Colin声音项目 to TAD main repo. Register in pack-registry.yaml. Create install.sh. Verify byte-identity after copy. Next *sync will distribute.

NOT in scope: Modifying pack content (copy as-is per user decision). NOT running *sync (separate operation).

#### Input
- /Users/sheldonzhao/Downloads/Colin声音项目/.claude/skills/ai-podcast-production/ (complete pack)
- Existing .tad/capability-packs/pack-registry.yaml

#### Output
- .tad/capability-packs/ai-podcast-production/ with CAPABILITY.md + references/
- .tad/capability-packs/ai-podcast-production/install.sh
- .claude/skills/ai-podcast-production/ (installed skill)
- Updated pack-registry.yaml with ai-podcast-production entry

#### Acceptance Criteria
- [ ] diff -rq Colin声音项目/.claude/skills/ai-podcast-production/ TAD/.claude/skills/ai-podcast-production/ shows no differences
- [ ] pack-registry.yaml contains ai-podcast-production entry with keywords
- [ ] install.sh exists and runs successfully (exit 0)
- [ ] head -3 .claude/skills/ai-podcast-production/SKILL.md | grep -q '^name:'

#### Files Likely Affected
- .tad/capability-packs/ai-podcast-production/CAPABILITY.md (CREATE)
- .tad/capability-packs/ai-podcast-production/references/*.md (CREATE)
- .tad/capability-packs/ai-podcast-production/install.sh (CREATE)
- .claude/skills/ai-podcast-production/SKILL.md (CREATE)
- .claude/skills/ai-podcast-production/references/*.md (CREATE)
- .tad/capability-packs/pack-registry.yaml (MODIFY)

#### Dependencies
None (can execute independently, but runs after P1+P2 in YOLO sequence)

#### Notes
Straightforward copy + registration. The pack is mature (2 episodes, 1437 lines, 6 references).

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
- Phase 1: 3 new entries added to pack-build-rules.md (cross-cutting rules layer, iteration history table, content production quality delta). Entry count 11→14. 2 reviewer P0s fixed (placement description, line count). Gate 3 PASS.
- Phase 2: Rubric added to deliverable-rubrics.yaml (6 weighted dimensions, not 5 — reviewer P0 added Oral Naturalness). Gate 3 Deliverable Branch already existed! Scope shrank to rubric registration only. Gate 3 PASS.
- Phase 3: ai-podcast-production pack copied from Colin声音项目 (7 files, byte-identical). CAPABILITY.md + install.sh + registry entry created. P2 rubric preserved. Gate 3 PASS.

### Decisions Made So Far
- Gate 3 deliverable branch uses pack-specific rubric (not generic checklist)
- ai-podcast-production copied as-is including Colin/Sheldon specific details (reference cases)
- YOLO execution mode

### Known Issues / Carry-forward
- 3 active Epics already at limit — need cleanup after this one completes
- Colin声音项目 50% gate failure rate is the motivating metric for P2

### Next Phase Scope
Phase 1: Write 3 new pack-build-rules entries

---

## Notes
Motivated by *optimize/*evolve analysis session (2026-06-05). Colin声音项目 is TAD's deepest non-dev deployment.
