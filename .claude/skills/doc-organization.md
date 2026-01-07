# Documentation Organization Skill

---
title: "Documentation Organization"
version: "1.1"
last_updated: "2026-01-07"
tags: [documentation, organization, consistency, maintenance, hygiene]
domains: [all]
level: beginner
estimated_time: "15min"
prerequisites: []
sources:
  - "GitHub Folder Structure Conventions"
  - "README Best Practices - Tilburg Science Hub"
  - "SDLC Hygiene - Harness"
  - "TAD Framework"
enforcement: recommended
tad_gates: [handoff, task_completion]

# v1.4 Skill 自动匹配触发条件
triggers:
  when_user_says:
    - "整理文档"
    - "文档混乱"
    - "文档组织"
    - "清理文档"
    - "organize docs"
    - "clean up docs"
    - "document structure"
    - "文档结构"

  when_creating_file:
    - "docs/**/*.md"
    - "README.md"
    - "NEXT.md"

  action: "recommend"
  auto_load: true
  message: |
    💡 检测到文档组织相关任务
    正在加载 doc-organization.md 以确保文档一致性...
---

## TL;DR Quick Checklist

```
1. [ ] README.md reflects current project state
2. [ ] NEXT.md contains accurate next actions
3. [ ] All docs in correct locations (docs/, not scattered)
4. [ ] No conflicting information across documents
5. [ ] Outdated docs archived or updated
```

**Red Flags:**
- Documents scattered in random locations
- README describes features that don't exist
- NEXT.md has stale/completed tasks
- Same information differs between docs
- Agent reads old doc and loses context

---

## Overview

This skill ensures project documentation stays organized, consistent, and current. It provides Alex and Blake with clear rules for when and how to maintain documentation.

**Core Principle:** "Documentation is part of Definition of Done - no task is complete until docs are updated."

**Problem Solved:** Prevents the common pattern where projects become chaotic over time due to scattered, outdated, or conflicting documentation.

---

## Triggers

| Trigger | Agent | Action |
|---------|-------|--------|
| `*handoff` complete | Alex | Run doc update checklist |
| Task/Phase complete | Blake | Update NEXT.md and relevant docs |
| Session ending | Both | Verify NEXT.md reflects current state |
| `*doc-check` command | Both | Full documentation audit |
| New session start | Both | Read README + NEXT.md first |

---

## Inputs

- Current project state
- Recently completed work
- New decisions made
- Changed requirements or designs

---

## Outputs / Evidence / Acceptance

### Required Evidence

| Evidence Type | Description | Location |
|---------------|-------------|----------|
| `doc_update_log` | List of docs updated | Inline in completion message |
| `consistency_check` | Conflicts found/resolved | Inline report |
| `structure_audit` | Doc locations verified | Inline report |

### Acceptance Criteria

```
[ ] Entry documents (README, NEXT.md) are current
[ ] All docs in designated locations
[ ] No conflicting information found
[ ] Outdated docs archived
[ ] Agent can resume work from docs alone
```

---

## Procedure

### Step 1: Understand Document Hierarchy

**Entry Layer (Must Read First)**
```
README.md          - Project overview, setup, stable info
NEXT.md            - Current status, next actions, dynamic info
```

**Project Documentation Layer**
```
docs/
├── design/        - Design documents, architecture
├── handovers/     - Handoff documents (NOT in .tad/)
├── decisions/     - Decision records (ADRs)
└── guides/        - How-to guides, tutorials
```

**Framework Layer (TAD Internal)**
```
.tad/
├── config.yaml    - TAD configuration only
├── agents/        - Agent definitions only
├── tasks/         - Task templates only
├── templates/     - Document templates only
└── evidence/      - Evidence and logs only
```

**Key Rule:** Project-specific documents go in `docs/`, NOT in `.tad/`

### Step 2: Know When to Update

**After Handoff (Alex)**
```
□ Update README if project scope changed
□ Update NEXT.md with Blake's tasks
□ Move handoff to docs/handovers/
□ Archive superseded design docs
```

**After Task Completion (Blake)**
```
□ Mark completed items in NEXT.md
□ Add new discovered tasks to NEXT.md
□ Update README if features added
□ Update CHANGELOG if significant change
```

**Before Session End (Both)**
```
□ NEXT.md reflects true current state
□ No work-in-progress without notes
□ Clear what to do when resuming
```

### Step 3: Maintain Entry Documents

**README.md Structure**
```markdown
# Project Name

## Overview
[What this project does - keep current]

## Quick Start
[How to run - update if changed]

## Current Status
[Link to NEXT.md for details]

## Documentation
[Links to docs/ folder]
```

**NEXT.md Structure**
```markdown
# Next Actions

## In Progress
- [ ] Current task being worked on

## Today
- [ ] Urgent tasks

## This Week
- [ ] Important tasks

## Blocked
- [ ] Tasks waiting on something

## Recently Completed
- [x] Task done (date)
```

### Step 4: Handle Document Placement

**Where Documents Should Go:**

| Document Type | Correct Location | Wrong Location |
|---------------|------------------|----------------|
| Handoff documents | `docs/handovers/` | `.tad/handovers/` |
| Design documents | `docs/design/` | root folder |
| Architecture docs | `docs/design/` | `.tad/` |
| Meeting notes | `docs/notes/` | random folders |
| Decision records | `docs/decisions/` | scattered |
| API documentation | `docs/api/` | code comments only |

**Migration Rule:** If you find docs in wrong places, move them:
```bash
# Example: Move handoff from .tad to docs
mv .tad/handoffs/*.md docs/handovers/
```

### Step 5: Detect and Resolve Conflicts

**Common Conflict Patterns:**

| Pattern | Detection | Resolution |
|---------|-----------|------------|
| Version mismatch | Same info differs between docs | Update older doc to match newer |
| Stale references | Doc references deleted feature | Remove or update reference |
| Duplicate info | Same content in multiple places | Single source, link from others |
| Outdated status | NEXT.md shows done task as pending | Update status |

**Conflict Resolution Process:**
```
1. Identify the "source of truth" (usually most recent)
2. Update conflicting documents
3. Add timestamp to show currency
4. Consider consolidating if duplicated
```

### Step 6: Archive Outdated Documents

**When to Archive:**
- Design doc superseded by newer version
- Handoff fully implemented
- Decision reversed or obsolete

**How to Archive:**
```
docs/
├── archive/
│   └── 2024-01/           # By month
│       ├── old-design.md
│       └── completed-handoff.md
```

**Archive Naming:**
```
Original: design-v1.md
Archived: archive/2024-01/design-v1-archived.md
```

### Step 7: Run Documentation Audit

**Quick Audit (5 min)**
```
[ ] README.md last updated < 1 week ago
[ ] NEXT.md matches actual current state
[ ] No docs in root folder (except README, NEXT, CHANGELOG)
[ ] docs/ folder exists and organized
```

**Full Audit (15 min)**
```
[ ] All docs in correct locations
[ ] No conflicting information
[ ] No outdated docs (> 1 month without update)
[ ] Cross-references are valid
[ ] Archive folder organized
```

---

## Checklists

### Post-Handoff Checklist (Alex)

```
[ ] NEXT.md updated with implementation tasks
[ ] Handoff saved to docs/handovers/
[ ] README updated if scope changed
[ ] Old design docs archived if superseded
[ ] No implementation details left in .tad/
```

### Post-Task Checklist (Blake)

```
[ ] Completed tasks marked [x] in NEXT.md
[ ] New tasks added to NEXT.md
[ ] README updated if features added
[ ] CHANGELOG updated if significant
[ ] Code and docs in sync
```

### Session End Checklist (Both)

```
[ ] NEXT.md is accurate and current
[ ] No undocumented work in progress
[ ] Clear resumption path documented
[ ] README still accurate
```

### New Session Start Checklist (Both)

```
[ ] Read README.md first (project overview)
[ ] Read NEXT.md second (current state)
[ ] Check docs/handovers/ for pending work
[ ] Verify understanding before acting
```

### Project Cleanup Checklist

```
[ ] All docs moved to docs/ folder
[ ] .tad/ contains only framework files
[ ] Archive folder created for old docs
[ ] README reflects current reality
[ ] NEXT.md is actionable and current
[ ] No duplicate information
[ ] No conflicting information
```

---

## Anti-patterns

| Anti-pattern | Why Bad | Fix |
|--------------|---------|-----|
| Docs in root folder | Hard to find, messy | Move to docs/ |
| Handoffs in .tad/ | Mixes project with framework | Move to docs/handovers/ |
| Never updating README | New sessions start confused | Update after changes |
| Stale NEXT.md | Agent works on wrong things | Update after every task |
| Duplicate info | Conflicts inevitable | Single source + links |
| No archive | Old docs pollute current | Archive monthly |
| "I'll update later" | Never happens | Update immediately |
| Confusing version numbers | Human misjudges which is current | Use dates or clear deprecation |
| Old versions not deleted | Agent may read wrong file | Delete or mark DEPRECATED |

### Real Case: Version Number Confusion (Resolved)

**Scenario (TAD Framework, 2026-01):**
```
# BEFORE (confusing - 6 files):
.tad/agents/
├── agent-a-architect.md       (Sep 27) - old base
├── agent-a-architect-v3.md    (Sep 28) - untracked, referenced non-existent config
├── agent-a-architect-v1.1.md  (Jan 6)  - actual current version
├── agent-b-executor.md        (Sep 27) - old base
├── agent-b-executor-v3.md     (Sep 28) - untracked
├── agent-b-executor-v1.1.md   (Jan 6)  - actual current version

# AFTER (clean - 2 files):
.tad/agents/
├── agent-a-architect.md       (22KB) - consolidated current version
├── agent-b-executor.md        (24KB) - consolidated current version
```

**Problem:**
- v1.1 is numerically smaller than v3, but v1.1 was the actual current version
- v3 files were never committed to git, referenced non-existent config-v3.yaml
- Multiple versions caused confusion about which file to use

**Resolution Applied:**
1. Merged v1.1 content into base filenames (agent-a-architect.md)
2. Deleted all versioned files (v1.1, v3)
3. Updated all references in active files
4. Archived old scripts that referenced v1.1

**Lesson:** Consolidate to single canonical files without version suffixes. Archive old versions, don't keep them alongside current files.

---

## Recovery: Fixing a Messy Project

**When you find documentation chaos:**

### Step 1: Create Structure
```bash
mkdir -p docs/{design,handovers,decisions,guides,archive}
```

### Step 2: Inventory All Docs
```bash
find . -name "*.md" -not -path "./.tad/*" -not -path "./node_modules/*"
```

### Step 3: Categorize and Move
```
For each document:
1. Is it current or outdated?
   - Current → Move to appropriate docs/ subfolder
   - Outdated → Move to docs/archive/

2. What type is it?
   - Design → docs/design/
   - Handoff → docs/handovers/
   - Decision → docs/decisions/
   - Guide → docs/guides/
```

### Step 4: Update Entry Documents
```
1. Rewrite README.md to reflect current reality
2. Clear NEXT.md and add only true next actions
3. Add links from README to docs/ structure
```

### Step 5: Verify Consistency
```
1. Read all current docs
2. Note any conflicts
3. Resolve conflicts (newer wins)
4. Remove duplicates
```

---

## TAD Integration

### Gate Mapping

```yaml
doc_organization:
  skill: doc-organization.md
  enforcement: RECOMMENDED
  triggers:
    - "*handoff complete"
    - "task completion"
    - "session end"
    - "*doc-check command"
```

### Agent Responsibilities

**Alex (Solution Lead)**
```yaml
responsibilities:
  - Update README when scope changes
  - Update NEXT.md after handoff
  - Place handoffs in docs/handovers/
  - Archive superseded designs

trigger: After *handoff command
```

**Blake (Execution Master)**
```yaml
responsibilities:
  - Update NEXT.md after each task
  - Update README when features added
  - Update CHANGELOG for releases
  - Keep code and docs in sync

trigger: After task completion
```

### Evidence Template

```markdown
## Documentation Update Report

### Documents Updated
- [ ] README.md - [what changed]
- [ ] NEXT.md - [tasks added/completed]
- [ ] docs/... - [specific files]

### Consistency Check
- Conflicts found: [number]
- Conflicts resolved: [number]

### Structure Audit
- Docs in wrong location: [list]
- Docs relocated: [list]
- Docs archived: [list]
```

---

## Commands

### *doc-check

Run full documentation audit:
```
1. Check README currency
2. Check NEXT.md accuracy
3. Verify doc locations
4. Detect conflicts
5. Identify outdated docs
6. Report findings
```

### *doc-fix

Auto-fix common issues:
```
1. Move misplaced docs
2. Create missing folders
3. Update timestamps
4. Archive old docs
```

---

## Related Skills

- `verification.md` - Verify before claiming done
- `git-workflow.md` - Commit docs with code
- `writing-skills.md` - Write clear documentation

---

## References

- [Folder Structure Conventions](https://github.com/kriasoft/Folder-Structure-Conventions)
- [README Best Practices](https://tilburgsciencehub.com/topics/collaborate-share/share-your-work/content-creation/readme-best-practices/)
- [SDLC Hygiene](https://www.harness.io/blog/hygiene-in-sdlc-a-key-to-engineering-efficiency)
- [Technical Documentation Checklist](https://www.manifest.ly/use-cases/software-development/technical-documentation-checklist)

---

## Key Mindset

> "A project is only as organized as its documentation. If an agent can't resume from docs alone, the docs have failed."

**Why this matters:**
- Prevents context loss on session crash
- Enables seamless handoffs between agents
- Reduces time spent "figuring out where we are"
- Makes projects maintainable long-term

---

## The Bottom Line

```
After every significant action:
1. Is NEXT.md current?
2. Is README still accurate?
3. Are docs in the right place?

If any answer is "no" → Fix it NOW, not later.
```

This is not optional cleanup - it's core workflow hygiene.

---

*This skill ensures Alex and Blake maintain organized, consistent documentation throughout the project lifecycle.*
