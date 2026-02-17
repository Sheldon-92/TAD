# Handoff: Roadmap — ROADMAP.md + Alex Startup Loading

**From:** Alex | **To:** Blake | **Date:** 2026-02-16
**Epic:** EPIC-20260216-alex-flexibility-and-project-mgmt.md (Phase 4/5)
**Type:** Standard TAD
**Priority:** P1
**Status:** Expert Review Complete - Ready for Implementation

## Executive Summary

Create ROADMAP.md as an upper-layer aggregation view that sits above PROJECT_CONTEXT.md, NEXT.md, and Epic files. ROADMAP.md uses a theme-driven structure (e.g., "Alex Flexibility", "Quality System") where each theme lists related Epics, Ideas, and directional goals. Alex reads ROADMAP.md on startup for strategic context, and *discuss exit_protocol gains a new option to update it.

**Key principle**: ROADMAP.md aggregates and organizes — it does NOT replace PROJECT_CONTEXT.md, NEXT.md, or Epic files. Those three remain the sources of truth for their respective scopes.

## Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | ROADMAP.md positioning | (A) Replace PROJECT_CONTEXT, (B) Coexist as peer, (C) Upper-layer aggregation | (C) Upper-layer aggregation | Each file has distinct scope; ROADMAP adds strategic layer without duplicating |
| 2 | Structure | (A) Timeline-driven, (B) Theme-driven, (C) Priority matrix | (B) Theme-driven | Themes group related work logically; timelines are unreliable for evolving projects |
| 3 | Startup loading | (A) Read on startup, (B) On-demand only | (A) Read on startup | Provides strategic context for *discuss and *analyze from session start |
| 4 | Update mechanism | (A) Manual only, (B) Auto-sync, (C) *discuss suggest | (C) *discuss exit suggests | Keeps human in control; auto-sync risks stale/incorrect aggregation |

## Task Breakdown

### Task 1: Create ROADMAP.md Template + Initial Content
**File:** `ROADMAP.md` (project root)
**Action:** Create new file

Create ROADMAP.md with theme-driven structure. Initial content should be populated from current Epic and project state.

**Template structure:**
```markdown
# Roadmap

> Strategic themes and direction for the project.
> This is an upper-layer aggregation view — see PROJECT_CONTEXT.md for current state,
> NEXT.md for tactical tasks, and .tad/active/epics/ for multi-phase tracking.

---

## Themes

### {Theme Name}
**Status:** Active / Planned / Complete
**Description:** {1-2 sentence theme description}

| Item | Type | Status | Reference |
|------|------|--------|-----------|
| {name} | Epic / Idea / Direction | {status} | {link to file} |

---

## Archive

Completed themes move here with completion date.

### {Completed Theme} — {YYYY-MM-DD}
{1-line summary of what was achieved}
```

**Initial content to populate:**
- **Theme: Alex Flexibility & Learning** (Active) — link to EPIC-20260216-alex-flexibility-and-project-mgmt.md, list Phase 1-5 status
- **Theme: Quality System** (Active) — reference Gate system, Cognitive Firewall, Ralph Loop
- **Theme: Developer Experience** (Active) — reference Playground v2, Pair Testing, Knowledge Auto-loading

**Constraints:**
- Max ~100 lines initially (can grow, but keep concise)
- Theme names should be human-readable, not slugs
- Each theme must have at least a Status and Description
- Items table is optional for themes without specific trackable items

### Task 2: Add ROADMAP.md to Alex Activation Protocol
**File:** `.claude/commands/tad-alex.md`
**Action:** Modify existing file

Add ROADMAP.md loading to Alex's activation protocol. Insert a new sub-step between STEP 3 (config loading) and STEP 3.5 (health check).

**Location:** Insert AFTER the closing of STEP 3's `note:` line (the line reading `note: "Do NOT load config-v1.1.yaml (archived). Module files contain all config sections."`), BEFORE the line `- STEP 3.5: Document health check`.

**Add:**
```yaml
  - STEP 3.4: Load roadmap context
    action: |
      Read ROADMAP.md (project root) if it exists.
      This provides strategic context for *discuss and *analyze paths.
      If file doesn't exist or is empty, skip silently (not blocking).
    blocking: false
    suppress_if: "File not found or empty - skip silently"
```

**Important:** This is a READ-ONLY step. Alex does not modify ROADMAP.md during startup. Loading it provides context for subsequent *discuss conversations and *analyze assessments. If ROADMAP.md exists but has invalid structure, load it anyway (partial context is better than none).

### Task 3: Update *discuss exit_protocol with "Update ROADMAP" Option
**File:** `.claude/commands/tad-alex.md`
**Action:** Modify existing file

**Location:** `discuss_path_protocol.exit_protocol.action` block — replace the Options list inside the `action: |` scalar.

**Exact content to find and replace:**

Remove:
```
      Options:
      - "Record conclusions to NEXT.md" → append summary to NEXT.md
      - "Create an idea from this" → switch to idea_path_protocol
      - "This needs proper design — start *analyze" → switch to adaptive_complexity_protocol
      - "No need to record, just a chat" → end, return to Alex standby
```

Replace with:
```
      Options:
      - "Record conclusions to NEXT.md" → append summary to NEXT.md
      - "Update ROADMAP" → enter update_roadmap_protocol
      - "This needs proper design — start *analyze" → switch to adaptive_complexity_protocol
      - "No need to record, just a chat" → end, return to Alex standby
```

Note: "Create an idea from this" is REMOVED (users can use *idea command directly at any time). "No need to record, just a chat" is KEPT — it's the most common exit path and should remain one-click accessible.

**New section to add — `update_roadmap_protocol`:**

Add as a new top-level section AFTER `discuss_path_protocol` (after the `exit_protocol.note` line) and BEFORE `# *idea Path Protocol`:

```yaml
# Update ROADMAP Protocol (triggered from *discuss exit)
update_roadmap_protocol:
  description: "Propose and apply ROADMAP.md updates based on discussion conclusions"
  trigger: "User selects 'Update ROADMAP' from *discuss exit_protocol"

  execution:
    step1:
      name: "Read Current State"
      action: |
        Read ROADMAP.md (project root).
        If not found: create from template (same as Task 1 template structure).

    step2:
      name: "Propose Changes"
      action: |
        Based on discussion conclusions, Alex proposes specific changes:
        - Add new theme?
        - Update existing theme status (Active → Complete)?
        - Add/remove items in a theme's table?
        - Move completed theme to Archive section?
        Present proposed changes as a bulleted summary to user.

    step3:
      name: "Confirm & Apply"
      action: |
        Use AskUserQuestion:
        "Here are the proposed ROADMAP changes. Confirm?"
        Options:
        - "Apply all changes" → write to ROADMAP.md
        - "Modify first" → user specifies adjustments, then re-confirm
        After applying, return to Alex standby.

  constraints:
    - "Alex proposes, human confirms — no auto-updates"
    - "Changes must be concise — ROADMAP stays under ~150 lines"
    - "Only update based on discussion content — no speculative additions"
```

### Task 4: Update Surface References
**File:** `.claude/commands/tad-alex.md`
**Action:** Modify existing file

Update the following sections to reflect ROADMAP.md awareness:

**4a. on_start greeting** (around line 1923)
No change needed — on_start already lists modes, ROADMAP loading happens silently in STEP 3.3.

**4b. discuss_path_protocol.behavior.allowed** (around line 460-466)
Append to the end of the `allowed:` list (after the last existing `- "..."` item):
```
- "Proposing updates to ROADMAP.md (with user confirmation)"
```

**4c. Quick Reference "Key Commands" section** (around line 1952)
No new command needed — ROADMAP is accessed through *discuss, not a separate command.

**4d. `commands` section** (around line 103-112)
No new command needed — ROADMAP management is part of *discuss exit flow.

## Files to Modify

| File | Action | Lines (approx) |
|------|--------|-----------------|
| `ROADMAP.md` | Create new | ~60-80 lines |
| `.claude/commands/tad-alex.md` | Modify | ~25 lines added |

## Acceptance Criteria

### ROADMAP.md Content
- [ ] AC1: ROADMAP.md exists at project root with theme-driven structure
- [ ] AC2: At least 3 themes populated from current project state (Alex Flexibility, Quality System, Developer Experience)
- [ ] AC3: Each theme has Status + Description fields
- [ ] AC4: Active Epic is cross-referenced with correct file path
- [ ] AC5: Header clearly states ROADMAP's role as aggregation view (not replacement)
- [ ] AC6: Archive section exists for completed themes

### Alex Activation
- [ ] AC7: STEP 3.4 exists in activation protocol with ROADMAP.md loading
- [ ] AC8: STEP 3.4 is non-blocking (skip silently if file not found or empty)
- [ ] AC9: STEP 3.4 is positioned after STEP 3 config note, before STEP 3.5 health check

### *discuss Integration
- [ ] AC10: *discuss exit_protocol has "Update ROADMAP" as option 2 (replacing "Create an idea")
- [ ] AC11: "No need to record, just a chat" remains as option 4
- [ ] AC12: update_roadmap_protocol exists as a standalone section (after discuss_path_protocol, before idea_path_protocol)
- [ ] AC13: update_roadmap_protocol has 3 steps: read → propose → confirm
- [ ] AC14: discuss_path_protocol.behavior.allowed includes ROADMAP.md updates

### Structural Integrity
- [ ] AC15: ROADMAP.md does NOT duplicate content from PROJECT_CONTEXT.md
- [ ] AC16: ROADMAP.md does NOT duplicate content from NEXT.md
- [ ] AC17: No new commands added (ROADMAP accessed through existing *discuss flow)

## Blake Instructions

- This is a Standard TAD task — follow Ralph Loop Layer 1 (self-check) for each task
- Task 1 creates a new file — populate with real current project data, not placeholders
- Task 2 modifies activation protocol — insert STEP 3.4 after STEP 3's `note:` line, before STEP 3.5
- Task 3 replaces "Create an idea from this" with "Update ROADMAP" in exit_protocol options — keep "No need to record" as option 4
- Task 3 also adds a new top-level `update_roadmap_protocol` section between discuss_path_protocol and idea_path_protocol
- Task 4 is minor surface updates — only touch what's specified
- If anything is unclear, escalate to user

## Expert Review Status

| Expert | Status | P0 | P1 | P2 |
|--------|--------|----|----|-----|
| code-reviewer | ✅ Complete | 3 (all fixed) | 4 (P1-1 fixed, P1-2/3/4 addressed) | 3 (noted) |

### P0 Issues Fixed
- **P0-1**: STEP 3.3 → STEP 3.4 (correct numbering between 3 and 3.5) ✅
- **P0-2**: Added exact before/after anchors for exit_protocol modification ✅
- **P0-3**: Specified update_roadmap_protocol as standalone section with placement instructions ✅

### P1 Resolutions
- **P1-1 (UX regression)**: FIXED — Kept "No need to record, just a chat"; removed "Create an idea" instead (users have *idea command)
- **P1-2 (Unassigned ideas section)**: Deferred to Phase 5 (*idea promote handles theme assignment)
- **P1-3 (Error handling)**: Added empty/invalid handling to STEP 3.4 spec
- **P1-4 (Insertion point)**: Added "append to allowed list" instruction in Task 4b

---

*Generated by Alex (Solution Lead) — Phase 4 of EPIC-20260216-alex-flexibility-and-project-mgmt*
