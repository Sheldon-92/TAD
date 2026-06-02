---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".claude/skills/blake", ".tad/project-knowledge"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Knowledge Lifecycle Phase 2 — Organize Engine + TAD Migration

**From:** Alex | **To:** Blake | **Date:** 2026-06-02
**Epic:** EPIC-20260602-knowledge-layering.md (Phase 2/3)

---

## 1. Task Overview

**Title:** Organize Engine + TAD Project Knowledge Migration

**Summary:** Move all 116 classified entries from the flat knowledge files into the three-layer structure using the P1 classification spreadsheet as the migration map. Update CLAUDE.md @import to load only principles.md. Update Blake and Alex SKILL loading logic to use patterns/_index.md matching.

**Input from Phase 1:**
- Classification spreadsheet: `.tad/evidence/knowledge-migration/classification-spreadsheet.md` (L1:13, L2:76, L3:25, DISCARD:2)
- Directory structure: `principles.md`, `patterns/`, `incidents/` (empty templates)
- README with lifecycle rules

---

## 2. Implementation Steps

### Task 1: Populate `principles.md` with 13 L1 entries

Read the classification spreadsheet. For every entry with `| L1 |`:
1. Read the full entry from its source file (architecture.md, code-quality.md, etc.)
2. Copy the entry verbatim (preserve ⚠️ SAFETY ENTRY markers, Grounded in lines, Revalidated dates)
3. Write to `.tad/project-knowledge/principles.md` under `## Principles`

Format: keep the existing `### Title - Date` format with Context/Discovery/Action structure.

### Task 2: Create L2 pattern files and populate

For each unique Theme Group in the spreadsheet, create a pattern file:
```
.tad/project-knowledge/patterns/{theme-group}.md
```

Expected files (from P1 spreadsheet):
- `gate-design.md`
- `handoff-design.md`
- `shell-portability.md`
- `ac-verification.md`
- `hook-contracts.md`
- `pack-build-rules.md`
- `pack-evaluation.md`
- `research-methodology.md`
- `memory-and-learning.md`

For each file:
1. Add a header: `# {Theme Name} Patterns (Layer 2)`
2. Copy all L2 entries belonging to that theme from their source files
3. Preserve full entry content (Context/Discovery/Action/Grounded in)

### Task 3: Populate `patterns/_index.md`

For each pattern file created in Task 2, add an index entry:
```markdown
- [Gate Design](gate-design.md) — Gate responsibility, honest_partial, verification integrity, Layer 2 audit
```
One line per file, max 120 chars, keywords that Blake's context_refresh can match against.

### Task 4: Create L3 incident files

For each L3 entry:
1. Create `incidents/2026-{MM}/{slug}.md` (derive month from entry date, slug from title)
2. Copy full entry content
3. Ensure "Linked L1/L2" from spreadsheet appears in the file as a `Linked to:` line

### Task 5: Populate `incidents/_index.md`

For each incident file:
```markdown
- [Dream Scanner Value Loss](2026-05/dream-scanner-value-loss.md) — 2026-05-31, linked: pack-build-rules "Parser must propagate value fields"
```

### Task 6: Clean source files

For each source file (architecture.md, code-quality.md, security.md, frontend-design.md):
1. Keep the `## Foundational` section INTACT (those entries are ALSO in principles.md now, but the Foundational section stays as legacy reference)
2. Replace `## Accumulated Learnings` section content with:
```markdown
## Accumulated Learnings

> ⚠️ Migrated to three-layer knowledge structure (2026-06-02, Knowledge Lifecycle Epic Phase 2).
> - Principles: `.tad/project-knowledge/principles.md`
> - Patterns: `.tad/project-knowledge/patterns/`
> - Incidents: `.tad/project-knowledge/incidents/`
> See `.tad/project-knowledge/README.md` for the Knowledge Lifecycle System documentation.
```
3. Do NOT delete the file — it stays as a pointer for backward compatibility

### Task 7: Update CLAUDE.md @import

In the project's `CLAUDE.md`, find the `@import` section (§7 Project Knowledge):
1. Replace `@.tad/project-knowledge/architecture.md` with `@.tad/project-knowledge/principles.md`
2. Remove: `@.tad/project-knowledge/code-quality.md`, `@.tad/project-knowledge/security.md`, etc.
3. Add: `@.tad/project-knowledge/patterns/_index.md` (index only, not full pattern files)
4. Keep: `@.tad/project-knowledge/ux.md`, `@.tad/project-knowledge/performance.md`, etc. IF they have content (these weren't migrated — they may have Foundational sections only)

### Task 8: Update Blake `1_5_context_refresh`

In `.claude/skills/blake/SKILL.md` at `1_5_context_refresh` (~line 503):

Change step 3 from:
```
3. Read matched .tad/project-knowledge/*.md files
```
To:
```
3. Read .tad/project-knowledge/principles.md (always — L1 methodology rules)
4. Read .tad/project-knowledge/patterns/_index.md → match task keywords against index entries
5. For each matched pattern file (max 3): Read .tad/project-knowledge/patterns/{matched}.md
6. L3 incidents are NOT loaded — use knowledge-blame.sh on demand (see 1_5_knowledge_provenance)
```

### Task 9: Update Alex `step0_5` context refresh

In `.claude/skills/alex/SKILL.md` at `step0_5` Context Refresh:

Update the knowledge loading logic similarly:
1. Always read `principles.md`
2. Read `patterns/_index.md` → match against task keywords
3. Load matched pattern files (max 3)
4. L3 incidents queried on demand, not pre-loaded

### Task 10: Handle DISCARD entries

For the 2 DISCARD entries from the spreadsheet:
1. Do NOT copy them to any layer
2. Record in a migration log what was discarded and why

---

## 3. Acceptance Criteria

| # | AC | Verification |
|---|-----|-------------|
| AC1 | principles.md has exactly 13 entries | `grep -c '^### ' .tad/project-knowledge/principles.md` = 13 |
| AC2 | ≥5 pattern files exist | `ls .tad/project-knowledge/patterns/*.md \| grep -vc _index` ≥ 5 |
| AC3 | patterns/_index.md has one line per pattern file | lines in _index.md = count of pattern files |
| AC4 | incidents/_index.md has entries | `grep -c '^\- \[' .tad/project-knowledge/incidents/_index.md` ≥ 20 |
| AC5 | CLAUDE.md @import references principles.md | `grep -c 'principles.md' CLAUDE.md` ≥ 1 |
| AC6 | CLAUDE.md @import does NOT reference architecture.md | `grep -c '@.tad/project-knowledge/architecture.md' CLAUDE.md` = 0 |
| AC7 | architecture.md has migration pointer | `grep -c 'Migrated to three-layer' .tad/project-knowledge/architecture.md` ≥ 1 |
| AC8 | SAFETY ENTRY count preserved | `grep -rc 'SAFETY ENTRY' .tad/project-knowledge/` ≥ original count from source files |
| AC9 | Zero entries lost | Total entries in principles + patterns + incidents + discards = 116 |
| AC10 | Blake SKILL has _index.md matching | `grep -c '_index.md' .claude/skills/blake/SKILL.md` ≥ 1 |
| AC11 | Alex SKILL has _index.md matching | `grep -c '_index.md' .claude/skills/alex/SKILL.md` ≥ 1 |

---

## 4. Important Notes

- Preserve ALL ⚠️ SAFETY ENTRY markers verbatim — these are methodology-critical
- Keep Foundational sections in source files (they are ALSO in principles.md, dual presence is intentional for backward compat)
- Pattern files should be 15-25 entries max each. If pack-build-rules exceeds 20, it was pre-split in P1 classification
- knowledge-blame.sh scope guard uses `.tad/project-knowledge/*` glob which only matches one level deep. Files in `patterns/` and `incidents/` subdirectories will NOT match. This is a KNOWN forward-compat issue — note it in completion report for P3 to fix
- L3 incident files: use kebab-case slugs derived from entry titles, max 50 chars

## 5. Required Evidence

```yaml
completion: .tad/active/handoffs/COMPLETION-20260602-knowledge-lifecycle-phase2.md
```
