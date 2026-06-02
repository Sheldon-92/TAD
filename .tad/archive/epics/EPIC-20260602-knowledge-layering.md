# Epic: Knowledge Lifecycle System — TAD's Fourth Core Subsystem

**Epic ID**: EPIC-20260602-knowledge-layering
**Created**: 2026-06-02
**Owner**: Alex

---

## Objective
Build TAD's fourth core subsystem (alongside Gates, Ralph Loop, and Trace/Optimize) — a **Knowledge Lifecycle System** that gives Alex the ability to autonomously sense, organize, maintain, and distribute project knowledge across any TAD project. The three-layer structure (principles / patterns / incidents) is an OUTPUT of this mechanism, not the goal itself. The goal is: **knowledge that stays alive, stays accurate, and stays useful without human maintenance effort.**

## Why This Is a Subsystem, Not a File Restructuring
TAD currently has three core subsystems that run continuously:
- **Gate System**: Quality checkpoints at design/implementation/acceptance boundaries
- **Ralph Loop**: Iterative self-check + expert review during implementation
- **Trace + Optimize**: Cross-session learning via trace aggregation + proposal generation

Knowledge management is NOT currently a subsystem — it's a passive storage mechanism (flat markdown files) with one manual cleanup command (*dream). This Epic transforms it into an active subsystem with four capabilities:

| Capability | What It Does | How It's Triggered |
|------------|-------------|-------------------|
| **Sense** | Alex detects knowledge health issues | Automatic at session start (STEP 3.5 health check) |
| **Organize** | Classify + restructure knowledge into layers | Alex proposes when Sense detects issues; human confirms |
| **Maintain** | Auto-classify new entries, graduate patterns, expire incidents | Embedded in Gate 4 KA + *dream scan cycle |

Distribution is NOT a separate capability — it's TAD's existing `*sync` mechanism. Once Sense/Organize/Maintain are embedded in Alex's SKILL.md and Gate/dream protocols, `*sync` automatically distributes the mechanism to all downstream projects. Downstream Alex starts up → STEP 3.5 Sense fires → detects old structure → proposes Organize → done.

## Success Criteria
- [ ] Alex in ANY TAD project can detect knowledge health issues at session start (>50 entries per file, flat structure, stale content)
- [ ] Alex can propose and execute knowledge restructuring with human confirmation (new AND old projects)
- [ ] Gate 4 KA auto-classifies new entries into the correct layer (L1-candidate / L2 / L3) — no post-hoc sorting needed
- [ ] *dream detects graduation candidates (L3 → L2 when ≥2 incidents share a pattern) and proposes them
- [ ] L3 incidents >90 days with stable linked L2 pattern are auto-archived
- [ ] principles.md modification requires Epic-level TAD flow (mechanical protection, not just convention)
- [ ] Token consumption for Blake session startup drops ≥70% (measured)
- [ ] After normal `*sync`, downstream Alex detects old structure and proposes Organize (verified on 1 pilot project)

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Sense Engine + Three-Layer Schema | ✅ Done | HANDOFF-20260602-knowledge-lifecycle-phase1.md | Sense in STEP 3.5 + schema + 116 entries classified (L1:13, L2:76, L3:25, DISCARD:2) |
| 2 | Organize Engine + TAD Migration | ✅ Done | HANDOFF-20260602-knowledge-lifecycle-phase2.md | 116 entries migrated: L1(13) + L2(75 across 9 files) + L3(25) + DISCARD(2) + CLAUDE.md + SKILL loading |
| 3 | Maintain Engine (Gate 4 + *dream) | ✅ Done | HANDOFF-20260602-knowledge-lifecycle-phase3.md | Gate 4 auto-classify + *dream graduation/expiration + L1 Epic protection + blame scope fix |

### Phase Dependencies
Sequential. Each phase builds on the previous.
- P1 defines the schema + detection → P2 uses the schema to organize + migrate
- P2 produces the layered structure → P3 maintains it with Gate 4 + *dream
- After P3: normal `*publish` + `*sync` distributes the mechanism to all downstream projects

### Derived Status
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Sense Engine + Three-Layer Schema

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Build the **Sense** capability: Alex's STEP 3.5 health check gains the ability to detect knowledge system issues and propose action. Also define the three-layer schema (directory structure + README with classification rules + lifecycle documentation) that all subsequent phases build on.

NOT in scope: actually migrating entries (P2), modifying Gate 4/dream (P3), downstream sync is handled by existing *sync after Epic completes.

#### Input
- Research findings: `.tad/evidence/research/newsletter-29-inspiration/2026-06-02-knowledge-layering-research.md`
- Current Alex SKILL.md STEP 3.5 health check logic
- Current `.tad/project-knowledge/` file list and entry counts

#### Output
1. **Three-layer directory schema** (created but empty — P2 populates):
   - `principles.md` (template with section headers)
   - `patterns/` + `patterns/_index.md` (template)
   - `incidents/` + `incidents/_index.md` (template)
   - `README.md` updated with: classification criteria, lifecycle rules (graduation ≥2, expiration 90d, L1 Epic-protection), loading strategy per layer

2. **Sense Engine** in Alex STEP 3.5:
   - Detect: total entry count across all knowledge files (>30 → suggest organize)
   - Detect: flat structure (no `patterns/` dir) → suggest initial layering
   - Detect: stale content (existing stale-knowledge-check.sh integration)
   - Detect: mixed layers in single file (entries with ⚠️ SAFETY vs entries about shell grep tricks in same file)
   - Output: knowledge health score + specific recommendations
   - Trigger: AskUserQuestion "知识系统需要整理，要现在执行吗？" with options

3. **Classification spreadsheet for TAD project** (P2 input):
   - Every entry from architecture.md, code-quality.md, security.md, frontend-design.md
   - Proposed layer (L1/L2/L3/DISCARD) + rationale
   - Human confirmation column

#### Acceptance Criteria
- [ ] Directory structure template exists (all dirs + files created, empty content OK)
- [ ] README.md documents 3-layer model + 5 lifecycle rules (classify/graduate/expire/protect/load)
- [ ] Alex STEP 3.5 detects >50 entries per file → outputs knowledge health warning (tested on TAD project: architecture.md has 93)
- [ ] Alex STEP 3.5 detects flat structure (no `patterns/` dir) → suggests initial layering
- [ ] Classification spreadsheet covers ALL entries (count matches `grep -c '^### '` across all files)
- [ ] L1 candidates ≤ 15
- [ ] Human has confirmed every L1 classification individually

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` — STEP 3.5 (MODIFY — add knowledge health sensing)
- `.tad/project-knowledge/principles.md` (CREATE — template)
- `.tad/project-knowledge/patterns/` (CREATE dir)
- `.tad/project-knowledge/patterns/_index.md` (CREATE — template)
- `.tad/project-knowledge/incidents/` (CREATE dir)
- `.tad/project-knowledge/incidents/_index.md` (CREATE — template)
- `.tad/project-knowledge/README.md` (MODIFY — classification rules + lifecycle)
- `.tad/evidence/knowledge-migration/classification-spreadsheet.md` (CREATE)

#### Dependencies
None (first phase)

---

### Phase 2: Organize Engine + TAD Migration

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Build the **Organize** capability: a new Alex command (`*knowledge-organize` or integrated into `*dream`) that can scan a project's knowledge files, classify entries, and restructure them into the three-layer schema with human confirmation. Then **dogfood** it on TAD's own 60+ entries as the first real migration.

Also update CLAUDE.md @import and Blake/Alex SKILL loading logic to use the new structure.

NOT in scope: auto-classification of NEW entries (that's P3 Maintain).

#### Input
- P1 output: directory schema + classification spreadsheet + Sense engine
- Current knowledge file contents

#### Output
1. **Organize Engine**: Alex can execute a knowledge restructuring workflow:
   - Scan all `*.md` files under `project-knowledge/`
   - For each `### Title - Date` entry: propose L1/L2/L3 classification
   - Present to human in batches (L1 individually, L2/L3 batch)
   - Move entries to correct location
   - Update `_index.md` files
   - Verify: entry count before = entry count after (minus DISCARDs)
   - Update old files: replace `## Accumulated Learnings` with migration pointer

2. **TAD migration complete**: all 60+ entries in new locations

3. **Loading logic updated**:
   - CLAUDE.md @import → `principles.md` only
   - Blake `1_5_context_refresh` → reads `_index.md`, matches task keywords, loads relevant pattern files
   - Alex `step0_5` → same matching logic
   - knowledge-blame.sh → already covers correct paths (verified in P1)

#### Acceptance Criteria
- [ ] `*knowledge-organize` (or *dream organize mode) runs end-to-end on TAD project
- [ ] `principles.md` has ≤15 entries, all methodology rules (not implementation details)
- [ ] `patterns/` has ≥5 themed files
- [ ] `incidents/` has dated subdirectories
- [ ] CLAUDE.md @import references `principles.md` only (old references removed)
- [ ] ⚠️ SAFETY ENTRY count preserved: `grep -r 'SAFETY ENTRY' .tad/project-knowledge/` ≥ original
- [ ] Blake SKILL `1_5_context_refresh` uses `_index.md` matching
- [ ] Zero entries lost (pre-migration count = post-migration count minus documented DISCARDs)

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` — dream_protocol OR new *knowledge-organize command (MODIFY)
- `.tad/project-knowledge/principles.md` (MODIFY — populate)
- `.tad/project-knowledge/patterns/*.md` (CREATE multiple)
- `.tad/project-knowledge/incidents/2026-*/*.md` (CREATE)
- `.tad/project-knowledge/architecture.md` (MODIFY — replace Accumulated Learnings)
- `.tad/project-knowledge/code-quality.md` (MODIFY)
- `.tad/project-knowledge/security.md` (MODIFY)
- `CLAUDE.md` (MODIFY — @import)
- `.claude/skills/blake/SKILL.md` — 1_5_context_refresh (MODIFY)

#### Dependencies
P1 complete

---

### Phase 3: Maintain Engine (Gate 4 KA + *dream Upgrade)

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Build the **Maintain** capability: make the knowledge lifecycle self-sustaining. Gate 4 KA auto-classifies new entries at write time. *dream detects graduation candidates and proposes them. Incident expiration runs automatically. principles.md gets Epic-level protection.

NOT in scope: downstream sync (handled by existing *sync after Epic completes).

#### Input
- P2 output: populated three-layer structure + organize engine

#### Output
1. **Gate 4 KA auto-classification**: When Alex writes a new knowledge entry at acceptance, it's automatically classified:
   - Surprising methodology insight → L1-candidate (flagged: "⚠️ REQUIRES EPIC to promote to principles.md")
   - Reusable pattern from this handoff → L2 (written directly to `patterns/`)
   - One-time incident evidence → L3 (written to `incidents/YYYY-MM/`)
   - Classification uses prediction-error heuristic: "would a senior TAD user already know this?" → yes = L3 or discard; no = L2; fundamentally changes how TAD works = L1-candidate

2. **\*dream graduation detection**: scan L3 incidents, find ≥2 with shared pattern → propose L2 graduation

3. **90-day expiration**: L3 incidents >90 days whose linked L2 pattern hasn't had a new incident in 60 days → propose auto-archive

4. **principles.md protection**: Alex SKILL checks if an edit targets principles.md → requires active Epic context (handoff with Epic field referencing a principles-modification Epic)

#### Acceptance Criteria
- [ ] Gate 4 KA writes new entry with `layer:` field (L1-candidate / L2 / L3)
- [ ] Gate 4 KA L2 entry goes directly to `patterns/` (not flat architecture.md)
- [ ] Gate 4 KA L1-candidate produces ⚠️ REQUIRES EPIC warning
- [ ] *dream detects graduation when ≥2 incidents share a pattern (tested with synthetic data)
- [ ] *dream proposes archival for incidents >90 days with stable linked pattern
- [ ] principles.md edit without active Epic → warning message
- [ ] Backward compatible: Gate 4 on project with old flat structure doesn't crash

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` — acceptance_protocol step7 (MODIFY — auto-classification)
- `.claude/skills/alex/SKILL.md` — dream_protocol (MODIFY — graduation + expiration)
- `.tad/hooks/lib/dream-scanner.sh` (MODIFY — layer awareness)
- `.tad/hooks/lib/dream-validator.sh` (MODIFY — layer validation)

#### Dependencies
P2 complete

---

---

## Context for Next Phase
(Filled after each phase completes)

---

## Research Grounding
- **Findings file**: `.tad/evidence/research/newsletter-29-inspiration/2026-06-02-knowledge-layering-research.md`
- **Key frameworks**: CoALA (episodic/semantic/procedural), GitAgent (RULES/skills/memory), DiffMem (surface/depth), Mem0 (scope-based + prediction-error), Anthropic Dreaming (three-store + human gate)
- **Notebook**: tad-evolution-research (37cfefa5, 53 sources)
- **Origin**: AI Tinkerers #29 → consulting-os/DiffMem → "is our knowledge still a -ology?" discussion → subsystem design
