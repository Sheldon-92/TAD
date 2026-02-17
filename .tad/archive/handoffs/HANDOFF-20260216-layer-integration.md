# Handoff: Layer Integration — *idea promote + *status Panoramic View

**From:** Alex | **To:** Blake | **Date:** 2026-02-16
**Epic:** EPIC-20260216-alex-flexibility-and-project-mgmt.md (Phase 5/5)
**Type:** Standard TAD
**Priority:** P1
**Status:** Expert Review Complete - Ready for Implementation

## Executive Summary

Final phase of the Alex Flexibility Epic. Add two new commands to Alex:

1. **\*idea promote** — Upgrade an idea from .tad/active/ideas/ to either an Epic (large scope) or Handoff (small scope). Updates the idea's status to "promoted" and transitions into *analyze flow.
2. **\*status** — Panoramic view scanning ROADMAP.md, active Epics, active Handoffs, and Ideas to show a one-screen project overview.

These complete the Idea → Roadmap → Epic → Handoff lifecycle chain, closing the management loop.

## Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Promote targets | (A) Epic+Handoff, (B) +ROADMAP item, (C) Handoff only | (A) Epic+Handoff | User selects based on scope; ROADMAP updates happen via *discuss |
| 2 | Status display | (A) Summary, (B) Expanded, (C) Interactive | (A) Summary | Quick scan is the primary use case; details available via specific commands |
| 3 | Data sources | (A) All 4, (B) ROADMAP+Epics, (C) +PROJECT_CONTEXT | (A) ROADMAP+Epics+Handoffs+Ideas | Complete panoramic view without redundant file scanning |
| 4 | Promote trigger | (A) Independent cmd, (B) In idea-list, (C) Both | (A) Independent *idea promote | Clean separation; idea-list stays read-only |
| 5 | Promote→Epic flow | (A) Enter *analyze, (B) Direct create, (C) User choice | (A) Enter *analyze | Respects existing Socratic/Epic workflow; promote only changes status |

## Task Breakdown

### Task 1: Add *idea promote Protocol
**File:** `.claude/commands/tad-alex.md`
**Action:** Modify existing file

Add `idea_promote_protocol` as a new top-level section. Insert AFTER `idea_list_protocol` (after line ~641, before `# *learn Path Protocol`).

**Protocol definition:**
```yaml
# *idea promote Protocol
idea_promote_protocol:
  description: "Upgrade an idea to Epic or Handoff — changes status and enters *analyze"
  trigger: "User types *idea promote"

  execution:
    step1:
      name: "Select Idea"
      action: |
        1. Scan .tad/active/ideas/ for IDEA-*.md files
        2. Filter: show only ideas with status "captured" or "evaluated" (not already promoted/archived)
        3. If no promotable ideas → "No ideas available to promote. Use *idea to capture one." → exit to standby
        4. Display table (same format as *idea-list step2)
        5. Ask user to select an idea by number

    step2:
      name: "Choose Target"
      action: |
        Read the selected idea file to get scope and summary.
        Use AskUserQuestion:
        "How would you like to promote this idea?"
        Options:
        - "Start as Epic (multi-phase)" → for medium/large scope ideas
        - "Start as Handoff (single task)" → for small scope ideas
        - "Cancel" → return to standby

    step3:
      name: "Update Idea Status"
      action: |
        1. Update the idea file's Status field: → "promoted"
        2. Fill the "Promoted To" field at bottom of idea file:
           - If Epic: "Promoted To: Epic (via *analyze — {date})"
           - If Handoff: "Promoted To: Handoff (via *analyze — {date})"
        3. Update NEXT.md cross-reference:
           - Search for "IDEA-{id}" in NEXT.md
           - If found: mark as [x] with note "(promoted)"
           - If not found: no action needed (idea may predate cross-reference system)

    step4:
      name: "Transition to *analyze"
      action: |
        1. Announce: "Idea promoted. Entering *analyze with idea context pre-loaded."
        2. Call adaptive_complexity_protocol with idea context:
           - Title → becomes the task description for complexity assessment
           - Scope → informs initial complexity guess (small→light, medium→standard, large→full)
           - Summary & Problem → Alex presents this context at start of Socratic Inquiry
           - Open Questions → Alex uses these as early Socratic discussion seed points
        3. The *analyze flow runs normally from step1 (Assess) onward.
           If user chose "Epic": Alex's step2b Epic Assessment will naturally trigger.
        (Context transfer is via conversation memory — no special persistence mechanism needed)
```

### Task 2: Add *status Protocol
**File:** `.claude/commands/tad-alex.md`
**Action:** Modify existing file

Add `status_panoramic_protocol` as a new section. Insert AFTER the existing `status` command in the commands section. For the protocol body, place it AFTER `update_roadmap_protocol` (after line ~543) and BEFORE `# *idea Path Protocol`.

**First, update the commands section** (around line 148-153, in the `# Utility commands` area):

Find the existing line:
```
  status: Show current project status
```
Replace with:
```
  status: Panoramic project view — Roadmap themes, Epics, Handoffs, Ideas at a glance
```

**Protocol definition:**
```yaml
# *status Panoramic Protocol
status_panoramic_protocol:
  description: "One-screen project overview scanning all management layers"
  trigger: "User types *status"

  execution:
    step1:
      name: "Scan All Layers"
      action: |
        Scan these sources (read-only, no modifications):
        1. ROADMAP.md → extract themes with status
           - If not found: show "No ROADMAP.md yet — use *discuss to create one"
        2. .tad/active/epics/EPIC-*.md → extract name, derived status, progress (N/M phases)
        3. .tad/active/handoffs/HANDOFF-*.md → extract name, date, priority
        4. .tad/active/ideas/IDEA-*.md → count by status (captured/evaluated/promoted/archived)

    step2:
      name: "Display Summary"
      action: |
        Output a compact panoramic view:

        ```
        ## 📊 Project Status

        ### Roadmap Themes
        | Theme | Status |
        |-------|--------|
        | {name} | {Active/Planned/Complete} |

        ### Active Epics
        | Epic | Progress | Current Phase |
        |------|----------|---------------|
        | {name} | {N}/{M} phases | {current phase name} |
        (or: "No active Epics" if .tad/active/epics/ is empty)

        ### Active Handoffs
        | Handoff | Date | Priority |
        |---------|------|----------|
        | {name} | {date} | {P0-P3} |
        (or: "No active Handoffs" if .tad/active/handoffs/ is empty)

        ### Ideas
        | Status | Count |
        |--------|-------|
        | captured | {N} |
        | evaluated | {N} |
        | promoted | {N} |
        (only show statuses with count > 0, exclude archived)
        (or: "No ideas captured yet" if empty)
        ```

    step3:
      name: "Next Action"
      action: |
        After displaying, return to standby.
        No AskUserQuestion needed — *status is a read-only command.
```

### Task 3: Update Commands Section + Quick Reference
**File:** `.claude/commands/tad-alex.md`
**Action:** Modify existing file

**3a. Add to commands section** (around line 110-119):

After the existing `idea-list` line, add:
```
  idea-promote: Promote an idea to Epic or Handoff — enters *analyze with idea context
```

**3b. Update Quick Reference "Key Commands"** (around line 1956-1960):

After the `*idea-list` line, add:
```
- `*idea-promote` - Promote an idea → Epic or Handoff (enters *analyze)
- `*status` - Panoramic project view (Roadmap, Epics, Handoffs, Ideas)
```

### Task 4: Update Idea Template "Promoted To" Field
**File:** `.tad/templates/idea-template.md`
**Action:** Modify existing file

The template already has `**Promoted To**: (filled when *idea promote runs in Phase 5)`. Update to remove the Phase 5 reference:

Find:
```
**Promoted To**: (filled when *idea promote runs in Phase 5)
```
Replace with:
```
**Promoted To**: (filled by *idea promote)
```

### Task 5: Update ROADMAP.md Phase 4 Status
**File:** `ROADMAP.md`
**Action:** Modify existing file

Update the "Alex Flexibility & Learning" theme's items table:

Find:
```
| Roadmap (ROADMAP.md + Alex startup loading) | Epic Phase 4 | In Progress |
```
Replace with:
```
| Roadmap (ROADMAP.md + Alex startup loading) | Epic Phase 4 | Complete |
```

Also update Phase 5:
Find:
```
| Layer Integration (*idea promote + *status) | Epic Phase 5 | Planned |
```
Replace with:
```
| Layer Integration (*idea promote + *status) | Epic Phase 5 | In Progress |
```

### Task 6: Update Standby Definition + Path Transitions
**File:** `.claude/commands/tad-alex.md`
**Action:** Modify existing file

**6a. Update `enters_standby` list** (around line 320-327):

After the last entry `"After any path transition fails or is cancelled → Enter standby"`, add:
```
- "After *idea-promote step2: user selects 'Cancel' → Enter standby"
- "After *idea-promote step1: no promotable ideas → Enter standby"
- "After *status step3 completes → Enter standby"
```

Note: `*idea-promote step4` transitions to *analyze (not standby) — so it is NOT listed here.

**6b. Update `path_transitions.allowed` list** (around line 337-358):

After the existing entry for `learn → analyze`, add:
```yaml
      - from: "idea-promote"
        to: "analyze"
        trigger: "Automatic after idea status updated to 'promoted' (step4)"
```

## Files to Modify

| File | Action | Lines (approx) |
|------|--------|-----------------|
| `.claude/commands/tad-alex.md` | Modify | ~70 lines added (promote protocol + status protocol + commands + Quick Reference) |
| `.tad/templates/idea-template.md` | Modify | 1 line changed |
| `ROADMAP.md` | Modify | 2 lines changed |

## Acceptance Criteria

### *idea promote
- [ ] AC1: `idea_promote_protocol` exists as a section in tad-alex.md (after idea_list_protocol, before learn_path_protocol)
- [ ] AC2: `*idea-promote` listed in commands section with description
- [ ] AC3: step1 scans .tad/active/ideas/ and filters to captured/evaluated only
- [ ] AC4: step2 offers "Epic" or "Handoff" target choice via AskUserQuestion
- [ ] AC5: step3 updates idea Status → "promoted" and fills "Promoted To" field
- [ ] AC6: step3 marks NEXT.md cross-reference as [x] with "(promoted)" note (gracefully skips if not found)
- [ ] AC7: step4 transitions to adaptive_complexity_protocol with idea content as context
- [ ] AC8: If no promotable ideas exist, shows message and exits to standby

### *status
- [ ] AC9: `status_panoramic_protocol` exists as a section in tad-alex.md
- [ ] AC10: *status command description updated to "Panoramic project view" in commands section
- [ ] AC11: Scans ROADMAP.md + .tad/active/epics/ + .tad/active/handoffs/ + .tad/active/ideas/
- [ ] AC12: Displays summary format: themes table + epics table + handoffs table + ideas count
- [ ] AC13: Gracefully handles empty directories AND missing ROADMAP.md
- [ ] AC14: Returns to standby after display (no AskUserQuestion)

### Standby + Path Transitions
- [ ] AC15: `enters_standby` list updated with promote cancel/empty and status completion entries
- [ ] AC16: `path_transitions.allowed` includes idea-promote → analyze transition
- [ ] AC17: *idea-promote step4 does NOT enter standby (transitions to *analyze)

### Surface Updates
- [ ] AC18: Quick Reference updated with *idea-promote and *status descriptions
- [ ] AC19: idea-template.md "Promoted To" field updated (Phase 5 reference removed)
- [ ] AC20: ROADMAP.md Phase 4 → Complete, Phase 5 → In Progress

## Blake Instructions

- This is a Standard TAD task — follow Ralph Loop Layer 1 (self-check) for each task
- Task 1 (promote protocol): Insert after idea_list_protocol, before learn_path_protocol. The transition to *analyze in step4 is a path_transition (like idea→analyze in step4 options) — reuse the existing mechanism
- Task 2 (status protocol): This is a READ-ONLY command. No file modifications, no AskUserQuestion after display. Place the protocol section after update_roadmap_protocol, before idea_path_protocol
- Task 3 (commands + Quick Reference): Add *idea-promote after *idea-list in both locations
- Task 5 (ROADMAP.md): Note that Phase 4 was already completed — Blake created this file with "In Progress" during Phase 4 implementation, now needs updating
- Task 6 (standby + path_transitions): Append to existing lists — do NOT rewrite the whole section. The idea-promote→analyze transition is automatic (not user-confirmed), unlike other path transitions
- If anything is unclear, escalate to user

## Expert Review Status

| Expert | Status | P0 | P1 | P2 |
|--------|--------|----|----|-----|
| code-reviewer | ✅ Complete | 2 (all fixed) | 5 (P1-1/2/3 fixed, P1-4/5 noted) | 3 (noted) |

### P0 Issues Fixed
- **P0-1**: Added Task 6 — standby definition updates for promote and status ✅
- **P0-2**: Added path_transitions entry for idea-promote → analyze ✅

### P1 Resolutions
- **P1-1 (context transfer)**: Clarified — conversation memory, Title/Scope/Summary/OpenQuestions mapped to *analyze steps ✅
- **P1-2 (NEXT.md edge case)**: Added "If not found: no action needed" handling ✅
- **P1-3 (ROADMAP.md not found)**: Added "show message" fallback in *status step1 ✅
- **P1-4 (line references)**: Blake uses before/after anchors, not line numbers — acceptable
- **P1-5 (Quick Reference line)**: Blake uses content matching, not line numbers — acceptable

---

*Generated by Alex (Solution Lead) — Phase 5 of EPIC-20260216-alex-flexibility-and-project-mgmt*
