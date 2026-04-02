# Handoff: Idea Pool (Structured Idea Storage)

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-02-16
**Task ID:** TASK-20260216-003
**Priority:** P1
**Complexity:** Medium (Standard TAD)
**Status:** Expert Review Complete - Ready for Implementation
**Epic:** EPIC-20260216-alex-flexibility-and-project-mgmt.md (Phase 3/5)

---

## Socratic Inquiry Summary

**Complexity**: Medium | **Rounds**: 2

| Dimension | Question | Decision |
|-----------|----------|----------|
| Storage | Each idea as independent file or NEXT.md? | Independent files: IDEA-{date}-{slug}.md in .tad/active/ideas/ |
| Lifecycle | What happens after capture? | Capture → Evaluate → promote/archive |
| *idea scope | Change interaction flow or just storage target? | Just change storage target (step3: NEXT.md → ideas directory) |
| Template | What fields? | Lightweight: Title + Summary + Open Questions + Scope Estimate + Status |
| promote/list | In Phase 3 or Phase 5? | *idea list in Phase 3, *idea promote in Phase 5 |

---

## Executive Summary

Phase 1 introduced the `*idea` path, but it stores ideas as one-line entries in NEXT.md — no structure, no lifecycle, no browsing. Phase 3 upgrades idea storage to structured individual files in `.tad/active/ideas/`, adds a lightweight template, and provides `*idea list` for browsing. The `*idea` interaction flow (step1-4) is unchanged — only the storage target in step3 is swapped.

**Key design decisions**:
- `*idea promote` deferred to Phase 5 (Layer Integration)
- Template is lightweight (5 fields) to keep capture fast
- Lifecycle: captured → evaluated → promoted/archived (status field in each idea file)

---

## Current State (What Exists)

In `tad-alex.md`:
- `idea_path_protocol` step3 writes to NEXT.md: `- [ ] 💡 {title}: {summary} ({date})`
- step3 has placeholder comment: `# FUTURE (Phase 3): Store to .tad/active/ideas/IDEA-{date}-{slug}.md`
- `commands` section has `idea` entry
- No `*idea list` command

In filesystem:
- `.tad/active/ideas/` directory does NOT exist
- No idea template in `.tad/templates/`

---

## Target State (What We Want)

```
*idea step3 (UPDATED)
  ↓
Write IDEA-{date}-{slug}.md to .tad/active/ideas/
  ↓
(Also add one-line reference to NEXT.md for quick visibility)

*idea list (NEW)
  ↓
Scan .tad/active/ideas/ → display table of ideas with status
```

---

## Task Breakdown

### Task 1: Create ideas directory + template

**Create directory**: `.tad/active/ideas/` (with `.gitkeep`)

**Create template**: `.tad/templates/idea-template.md`

```markdown
# Idea: {title}

**ID:** IDEA-{YYYYMMDD}-{slug}
**Date:** {YYYY-MM-DD}
**Status:** captured
**Scope:** {small / medium / large}

---

## Summary & Problem

{2-3 sentences: what is the idea and what problem does it solve?}

## Open Questions

- {Things not yet decided}
- {Unknowns to explore}

## Notes

{Any additional context, links, or references — optional}

---

**Status Values**: captured → evaluated → promoted → archived
**Promoted To**: (filled when *idea promote runs in Phase 5)
```

Template rules:
- All fields except Notes are required
- Status starts as `captured` always
- Scope values: `small` / `medium` / `large` (same as existing step2 output)
- Keep it under 30 lines — idea capture should be FAST

### Task 2: Update idea_path_protocol step3 (storage target)

**File**: `.claude/commands/tad-alex.md`

**Remove** the entire current step3 content (lines ~525-532 of tad-alex.md):
- Remove: `# Phase 3 (Idea Pool) not yet built — use NEXT.md for now`
- Remove: `Append to NEXT.md under a new "## Ideas" section (create if not exists):`
- Remove: `- [ ] 💡 {title}: {summary} ({date})`
- Remove: `# FUTURE (Phase 3): Store to .tad/active/ideas/IDEA-{date}-{slug}.md`

**Replace with**:

```yaml
    step3:
      name: "Store"
      action: |
        1. Generate slug from title (lowercase, hyphens, max 40 chars)
        2. Check if .tad/active/ideas/IDEA-{YYYYMMDD}-{slug}.md already exists
           If exists: append sequence number (e.g., IDEA-{date}-{slug}-2.md)
        3. Create .tad/active/ideas/IDEA-{YYYYMMDD}-{slug}.md using idea-template.md
           - Fill: title, date, status (captured), scope (from step2)
           - Fill: summary, open questions (from step2 structured output)
           - "Problem It Solves" comes from step1 clarifying questions (if asked) or summary context
        4. Append one-line cross-reference to NEXT.md:
           - If "## Ideas" section exists: append under it
           - If not: create "## Ideas" section AFTER "## Pending" (before "## Blocked")
           - Format: `- [ ] IDEA-{date}-{slug}: {title}`
        5. Confirm to user: "Idea saved to .tad/active/ideas/IDEA-{date}-{slug}.md"
```

Note: The NEXT.md one-liner is a cross-reference, not the primary storage. Full content lives in the idea file.

### Task 3: Add `*idea list` command

**File**: `.claude/commands/tad-alex.md`

**Add to `commands` section** after `idea` (use hyphen form for consistency with TAD conventions):

```yaml
  idea-list: Browse saved ideas — show all ideas with status and scope
```

**Add protocol** after `idea_path_protocol`:

```yaml
# *idea-list Protocol
idea_list_protocol:
  description: "Browse and manage saved ideas"
  trigger: "User types *idea-list"

  # Status lifecycle reference:
  # captured  — just logged, initial state
  # evaluated — user reviewed and decided it's worth keeping
  # promoted  — (Phase 5) converted to Epic/Handoff
  # archived  — decided not to pursue

  execution:
    step1:
      name: "Scan Ideas"
      action: |
        Read all files in .tad/active/ideas/ matching IDEA-*.md
        For each file, extract: ID, Title, Status, Scope, Date
        If no ideas found → "No ideas captured yet. Use *idea to capture one." → exit to standby

    step2:
      name: "Display"
      action: |
        Show table:
        | # | Title | Scope | Status | Date | File |
        |---|-------|-------|--------|------|------|
        | 1 | {title} | {scope} | {status} | {date} | IDEA-{date}-{slug}.md |

        Sort by date (newest first).
        Filter: show only non-archived ideas by default.

    step3:
      name: "Action"
      action: |
        Use AskUserQuestion:
        "What would you like to do?"
        Options:
        - "View details of an idea" → read and display the full idea file, then return to step3
        - "Update status" → change status (captured → evaluated, or → archived)
        - "Done browsing" → exit to standby

        On "Update status":
        - Ask which idea (by number from table)
        - Ask new status: captured / evaluated / archived (forward only, no backwards)
        - Update the Status field in the idea .md file
        - If status → archived: also mark NEXT.md cross-reference as [x] (if exists)
```

### Task 4: Update on_start, Quick Reference

**File**: `.claude/commands/tad-alex.md`

No change needed to on_start (already lists `*idea`).

**Add to Quick Reference Key Commands** after `*idea`:

```
- `*idea-list` - Browse saved ideas with status and scope
```

### Task 5: Create ideas directory structure

**Blake action**: Create the actual directory:
- `.tad/active/ideas/.gitkeep`

---

## Files to Modify

| File | Change Type | Scope |
|------|-------------|-------|
| `.claude/commands/tad-alex.md` | Medium | Update step3, add idea_list_protocol, add command, update Quick Reference |
| `.tad/templates/idea-template.md` | New | Lightweight idea template (~25 lines) |
| `.tad/active/ideas/.gitkeep` | New | Empty directory marker |

---

## Acceptance Criteria

### Storage (Tasks 1-2)
- [ ] **AC1**: `.tad/active/ideas/` directory exists with `.gitkeep`
- [ ] **AC2**: `.tad/templates/idea-template.md` exists with required fields (Title, Summary & Problem, Open Questions, Scope, Status) and is under 30 lines
- [ ] **AC3**: `*idea` step3 creates IDEA-{date}-{slug}.md in `.tad/active/ideas/`
- [ ] **AC4**: `*idea` step3 appends cross-reference to NEXT.md under `## Ideas` section (creates section if not exists, after `## Pending`)
- [ ] **AC5**: Idea file uses template format with all required fields filled
- [ ] **AC6**: Status defaults to `captured` on creation
- [ ] **AC7**: Duplicate slug handled (sequence number appended if file already exists)
- [ ] **AC8**: Old step3 code fully removed (no `# FUTURE` or `# Phase 3` comments remain)

### Browsing (Task 3)
- [ ] **AC9**: `*idea-list` command scans `.tad/active/ideas/` and displays table
- [ ] **AC10**: `*idea-list` shows Title, Scope, Status, Date for each idea
- [ ] **AC11**: `*idea-list` handles empty directory gracefully ("No ideas captured yet")
- [ ] **AC12**: `*idea-list` offers actions: view details, update status, done
- [ ] **AC13**: Status can be updated forward only (captured → evaluated → archived)
- [ ] **AC14**: Archiving an idea also marks NEXT.md cross-reference as `[x]`

### No Regression (Task 4)
- [ ] **AC15**: `*idea` step1/step2/step4 unchanged (no regression in capture flow)
- [ ] **AC16**: Quick Reference updated with `*idea-list`
- [ ] **AC17**: *analyze path behavior unchanged (no regression)

---

## Important Notes

### Critical Warnings
- ⚠️ step3 change is a REPLACEMENT not addition — remove the NEXT.md-only logic and the `# FUTURE` comment
- ⚠️ Keep the NEXT.md one-liner as cross-reference (not primary storage)
- ⚠️ `*idea promote` is NOT in scope — deferred to Phase 5
- ⚠️ Template must be lightweight (<30 lines) to keep capture fast

### Known Constraints
- No `*idea promote` in Phase 3 (Phase 5 will add promote to Epic/Handoff)
- No tagging/categorization system (keep it simple)
- Status lifecycle is manual (user changes via *idea list)

### Sub-Agent Usage
Blake should consider using:
- [ ] **code-reviewer** — review protocol consistency with existing path patterns

---

## Expert Review Status

| Expert | Status | P0 Issues | P1 Issues |
|--------|--------|-----------|-----------|
| code-reviewer | CONDITIONAL PASS → **PASS (P0 resolved)** | 3 P0 (all resolved) | 5 P1 (3 addressed) |

### P0 Resolution Summary

| P0 | Issue | Resolution |
|----|-------|------------|
| P0-1 | step3 replacement not explicit | **Fixed**: Added explicit "Remove" list + "Replace with" block |
| P0-2 | NEXT.md "## Ideas" section creation logic missing | **Fixed**: Added section creation logic (after ## Pending, before ## Blocked) |
| P0-3 | Template "Problem It Solves" has no source in step2 | **Fixed**: Merged into "Summary & Problem" single section |

### P1 Addressed

| P1 | Issue | Resolution |
|----|-------|------------|
| P1-1 | Duplicate slug detection | **Fixed**: Added sequence number logic to step3 |
| P1-2 | Command trigger `*idea list` vs `*idea-list` | **Fixed**: Standardized to `*idea-list` (hyphen, TAD convention) |
| P1-4 | NEXT.md cleanup on archive | **Fixed**: Archive status marks NEXT.md cross-ref as [x] |

### P1 Deferred (acceptable for Gate 3)

| P1 | Issue | Reason |
|----|-------|--------|
| P1-3 | Status lifecycle documentation | Added to idea_list_protocol as comment block |
| P1-5 | AC for template field validation | Covered by expanded AC2 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-02-16
**Status**: Expert Review Complete - Ready for Implementation
**Version**: 3.1.0
