# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-25
**Project:** TAD Framework
**Task ID:** TASK-20260325-004
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Sync flow defined: startup full sync + *accept incremental |
| Components Specified | ✅ | 2 files to modify (tad-alex.md, config-platform.yaml) |
| Functions Verified | ✅ | Insertion points in tad-alex.md verified |
| Data Flow Mapped | ✅ | NEXT.md → parse sections → diff Linear → create/update via MCP → write back IDs |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Auto-sync mechanism that keeps Linear in sync with TAD's NEXT.md. Each project's Alex scans its own NEXT.md on startup (full sync) and on *accept (incremental). NEXT.md is the single source of truth; Linear is the display layer.

### 1.2 Why We're Building It
**业务价值**：Human shouldn't have to manually update both NEXT.md and Linear. TAD already maintains NEXT.md — Linear should automatically reflect it.

### 1.3 Intent Statement
**真正要解决的问题**：Eliminate double bookkeeping between TAD docs and Linear.

**不是要做的**：
- ❌ 不是双向同步（Linear → TAD 不回写）
- ❌ 不是同步 Epic（NEXT.md 已间接覆盖 Epic 进度）
- ❌ 不是跨项目同步（每个项目的 Alex 只管自己）

---

## 2. Background Context

### 2.1 Prerequisites (already implemented)
- Linear MCP Server configured (HANDOFF-20260325-linear-kanban-integration)
- `linear_integration` section in config-platform.yaml
- `step4b_linear_sync` in tad-alex.md *accept flow
- `project_mapping` defines local project → Linear project name

### 2.2 Sync Architecture

```
Alex /alex 启动 (on_start)
  ↓
step3.7_linear_sync (NEW):
  1. Read NEXT.md
  2. Parse sections → extract items with status
  3. Query Linear MCP: get all issues for this project
  4. Diff: NEXT.md items vs Linear issues
     - New in NEXT.md (no [XXX-NN] tag) → create Linear issue, write ID back
     - Status changed → update Linear issue status
     - In NEXT.md as [x] completed → Linear issue → Done
     - In Linear but not in NEXT.md → leave alone (human may have created it)
  5. Output brief summary: "Linear sync: 2 created, 1 updated, 0 errors"

Alex *accept:
  step4b_linear_sync (EXISTING, enhanced):
  - Mark the completed task's Linear issue as Done (if linked)
  - Already implemented — just ensure [XXX-NN] tag matching works
```

### 2.3 NEXT.md Section → Linear Status Mapping

| NEXT.md Section | Linear Status | Priority |
|----------------|---------------|----------|
| `## In Progress` | In Progress | High |
| `## Today` | Todo | Urgent |
| `## This Week` | Todo | High |
| `## Pending` | Todo | Medium |
| `## Blocked` | Todo + "blocked" label | High |
| `## Ideas` (unchecked) | Backlog | Low |
| `## Recently Completed` | Done (only for items WITH existing [XXX-NN] tag; skip untagged [x] items) | — |

### 2.4 ID Writeback Format

When a new Linear issue is created, its ID is appended to the NEXT.md line:

```markdown
# Before sync
- [ ] Fix scan tab not returning to homepage

# After sync (ID written back)
- [ ] Fix scan tab not returning to homepage [MENU-42]
```

On subsequent syncs, `[MENU-42]` is used for exact matching — no title comparison needed.

**Parsing rules**:
- Only parse lines matching `^- \[([ x])\] (.+)$` (checkbox items only, skip sub-bullets)
- Linear ID pattern: `\[([A-Z]{2,10}-\d{1,5})\]$` at absolute end of line
- Only match known project prefixes from `project_mapping`
- `[x]` items without tag → skip (don't retroactively create)

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Add `step3.7_linear_sync` to Alex's activation protocol (after step3.6, before step4)
- FR2: Parse NEXT.md sections and extract task items with their section context
- FR3: Query Linear MCP for existing issues in the mapped project
- FR4: Create new Linear issues for NEXT.md items without `[XXX-NN]` tags
- FR5: Update Linear issue status when NEXT.md section changes
- FR6: Write Linear issue ID back to NEXT.md after creation `[XXX-NN]`
- FR7: Mark completed items ([x]) as Done in Linear
- FR8: Update config-platform.yaml with sync settings (section_mapping, id_pattern)

### 3.2 Non-Functional Requirements
- NFR1: Sync must be non-blocking (failure → WARN, continue startup)
- NFR2: Sync should complete in < 30 seconds for typical NEXT.md (< 100 items)
- NFR3: Never delete Linear issues (items removed from NEXT.md stay in Linear)
- NFR4: Never modify NEXT.md content — only append `[XXX-NN]` tags

---

## 4. Technical Design

### 4.1 Files to Modify

```
2 files to modify:
├── .claude/commands/tad-alex.md        ← Add step3.7_linear_sync to activation
└── .tad/config-platform.yaml           ← Add sync settings (section_mapping, id_pattern)
```

### 4.2 tad-alex.md — step3.7_linear_sync

Insert after `step3.6` (pair test report detection), before `step4` (greet user):

```yaml
  - STEP 3.7: Linear sync (startup full sync)
    action: |
      1. Check config-platform.yaml → linear_integration.enabled
         If false → skip silently
      2. Check if Linear MCP tools are available
         If not → skip with note: "Linear MCP not available, skipping sync"
      3. Determine current project name from config-platform.yaml project_mapping
         Match current working directory basename to project_mapping keys
         If no match → skip: "Current project not in Linear project_mapping"
      4. Read NEXT.md (full file), record file modification time for conflict detection
      5. Parse NEXT.md with these rules:
         LINE PARSING:
         - Only lines matching `^- \[([ x])\] (.+)$` are parsed as items
         - Sub-bullets (indented `  - `) are SKIPPED (belong to parent item)
         - Non-checkbox lines, headers, blank lines → SKIPPED
         - Extract from each matching line: text, section_name, is_completed, linear_id
         LINEAR ID EXTRACTION:
         - Pattern: `\[([A-Z]{2,10}-\d{1,5})\]$` at absolute end of line (after trimming whitespace)
         - Only matches known project prefixes from project_mapping (e.g., MENU, TAD)
         - Mid-line brackets like `[See RFC-12]` do NOT match (not at end)
         SECTION HANDLING:
         - Track current section by most recent `## {name}` header
         - Duplicate section headers → merge items into same logical group (both treated as same status)
         - Sections NOT in section_mapping → SKIP all items with WARN: "Unmapped section: {name}"
      6. Query Linear MCP: list all issues for this project
      7. Diff and sync:
         a. Items WITH [XXX-NN] tag (existing tracked items):
            - Find matching Linear issue by identifier
            - If NEXT.md section changed → update Linear status per section_mapping
            - If NEXT.md item is [x] → update Linear to Done
            - If Linear issue not found → WARN (orphaned tag), skip
         b. Items WITHOUT [XXX-NN] tag AND unchecked `[ ]` (new untracked items):
            - Create new Linear issue via MCP
            - IMMEDIATELY write back ID to NEXT.md (not batched — prevents duplicates on crash)
            - Max 10 creations per startup (if more → WARN "10 created, {N} remaining for next sync")
            - Title: item text without checkbox prefix, trimmed
         c. Items WITHOUT [XXX-NN] tag AND checked `[x]` (completed before sync existed):
            - SKIP — do not retroactively create Done issues (adds noise, not value)
         d. Linear issues not in NEXT.md:
            - Do nothing (human may have created them directly in Linear)
      8. CONFLICT CHECK before final write:
         - Re-check NEXT.md modification time
         - If changed since step 4 → WARN "NEXT.md modified during sync, skipping remaining writebacks"
         - If unchanged → write is safe (individual writes already happened in step 7b)
      9. Output summary: "Linear sync: {N} created, {M} updated, {K} skipped, {E} errors"
    blocking: false
    suppress_if: "linear_integration.enabled is false OR Linear MCP unavailable"
    on_failure: "WARN and continue startup — Linear sync failure never blocks Alex activation"
```

### 4.3 config-platform.yaml — Sync Settings

Add to existing `linear_integration:` section:

```yaml
  # Auto-sync settings (added for TASK-20260325-004)
  auto_sync:
    startup_sync: true        # Full sync on Alex startup
    accept_sync: true         # Incremental sync on *accept (existing step4b)
    id_pattern: "\\[([A-Z]{2,10}-\\d{1,5})\\]$"  # Regex to extract Linear ID from NEXT.md lines
    max_creations_per_sync: 10  # Cap new issue creation per startup to limit MCP calls
    skip_completed_untagged: true  # Don't retroactively create issues for [x] items without tags
    section_mapping:
      "In Progress":
        status: "In Progress"
        priority: 2  # High
      "Today":
        status: "Todo"
        priority: 1  # Urgent
      "This Week":
        status: "Todo"
        priority: 2  # High
      "Pending":
        status: "Todo"
        priority: 3  # Medium
      "Blocked":
        status: "Todo"
        priority: 2  # High
        label: "blocked"
      "Ideas":
        status: "Backlog"
        priority: 4  # Low
      "Recently Completed":
        status: "Done"
        priority: null  # Keep existing
```

### 4.4 Enhanced step4b_linear_sync

The existing step4b already handles *accept sync. Enhancement needed:

```yaml
# Current step4b uses handoff's **Linear:** field for matching
# Enhancement: also check NEXT.md for [XXX-NN] tag on the completed item
# This closes the loop: startup creates issue → *accept marks it Done
```

Update step4b detection logic:
1. First: check handoff `**Linear:**` field (existing, unchanged)
2. If not found: check NEXT.md for the just-completed task, look for `[XXX-NN]` tag
3. If found via either method: mark Done
4. If not found: skip

---

## 6. Implementation Steps

### Phase 1: Config Update (~5 min)

#### 交付物
- [ ] config-platform.yaml has `auto_sync` section under `linear_integration`

#### 实施步骤
1. Add `auto_sync` section with `section_mapping`, `id_pattern`, `startup_sync`, `accept_sync`, `max_creations_per_sync`, `skip_completed_untagged`
2. Update existing `linking_strategy` from `"explicit"` to `"auto"` (auto-sync supersedes explicit-only)

#### 验证方法
- `grep "auto_sync" .tad/config-platform.yaml` → present
- `grep "section_mapping" .tad/config-platform.yaml` → present

### Phase 2: tad-alex.md Step 3.7 (~20 min)

#### 交付物
- [ ] `step3.7_linear_sync` added to activation protocol
- [ ] Positioned after step3.6, before step4
- [ ] Non-blocking with on_failure handling

#### 实施步骤
1. Insert step3.7 after step3.6 in activation-instructions
2. Full sync logic: parse NEXT.md → query Linear → diff → create/update → writeback

#### 验证方法
- `grep "step3.7" .claude/commands/tad-alex.md` → present
- `grep "linear_sync" .claude/commands/tad-alex.md` → present
- Step order: 3.6 → 3.7 → step4

### Phase 3: Enhanced step4b (~10 min)

#### 交付物
- [ ] step4b also checks NEXT.md `[XXX-NN]` tag as fallback matching

#### 实施步骤
1. Update step4b detection logic: add NEXT.md tag check as step 2

#### 验证方法
- step4b has two detection paths: handoff field + NEXT.md tag

---

## 9. Acceptance Criteria

- [ ] AC1: config-platform.yaml has `auto_sync` with `section_mapping` and `id_pattern`
- [ ] AC2: tad-alex.md has `step3.7_linear_sync` in activation protocol
- [ ] AC3: step3.7 is non-blocking (`blocking: false`, `on_failure: WARN`)
- [ ] AC4: step3.7 skips silently when `linear_integration.enabled: false`
- [ ] AC5: step3.7 skips when Linear MCP not available
- [ ] AC6: step3.7 creates new issues for items without `[XXX-NN]` tag
- [ ] AC7: step3.7 writes back Linear ID as `[XXX-NN]` to NEXT.md
- [ ] AC8: step3.7 updates status for items whose NEXT.md section changed
- [ ] AC9: step3.7 never deletes Linear issues
- [ ] AC10: step4b enhanced to check NEXT.md `[XXX-NN]` as fallback
- [ ] AC11: NEXT.md content never modified except appending `[XXX-NN]` tags

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected |
|---|---------------------|--------------------|--------------------|
| 1 | Config auto_sync | grep "auto_sync" config-platform.yaml | Present |
| 2 | Step 3.7 exists | grep "step3.7" tad-alex.md | Present |
| 3 | Non-blocking | grep "blocking: false" near step3.7 | Present |
| 4 | Enabled check | grep "linear_integration.enabled" in step3.7 | Present |
| 5 | MCP check | grep "MCP.*available" in step3.7 | Present |
| 6 | ID writeback | grep "XXX-NN" in step3.7 | Referenced |
| 7 | No delete | grep "Do nothing" or "leave alone" in step3.7 | Present |
| 8 | step4b enhanced | step4b has NEXT.md tag check | Present |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ NEVER delete Linear issues — items removed from NEXT.md stay in Linear
- ⚠️ NEVER modify NEXT.md content — only append `[XXX-NN]` tags at end of lines
- ⚠️ step3.7 runs BEFORE greeting — must be fast and non-blocking
- ⚠️ If Linear MCP not available, skip silently (don't error, don't prompt user)

### 10.2 Design Decisions

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Sync direction | Bidirectional / One-way | One-way (TAD → Linear) | TAD is source of truth, Linear is display layer |
| 2 | Matching | Title match / ID writeback / Hash | ID writeback [XXX-NN] | Reliable, no ambiguity, minimal NEXT.md change |
| 3 | Epic sync | Sync / Don't sync | Don't sync | NEXT.md already reflects Epic progress |
| 4 | Cross-project | Sync all / Own project only | Own project only | Each Alex instance manages its own project |
| 5 | Item removal | Delete from Linear / Keep | Keep in Linear | Never delete — human may want to keep for reference |

---

---

## Expert Review Status

| Expert | Assessment | P0 Found | P0 Fixed | Result |
|--------|-----------|----------|----------|--------|
| code-reviewer | CONDITIONAL PASS → PASS | 4 | 4 ✅ | All P0 addressed |
| backend-architect | CONDITIONAL PASS → PASS | 3 | 3 ✅ | All P0 addressed |

**P0 Issues Fixed:**
1. ✅ Duplicate sections — merge behavior defined, unmapped sections → skip with WARN
2. ✅ Multi-line parsing — only `^- \[([ x])\]` lines parsed, sub-bullets skipped
3. ✅ Crash-safe writeback — write ID back immediately after each creation (not batched)
4. ✅ Conflict detection — check NEXT.md modification time before/after sync

**P1 Issues Addressed:**
- ✅ Completed untagged items → skip (no retroactive creation)
- ✅ linking_strategy → updated from "explicit" to "auto"
- ✅ Max 10 creations per startup (performance cap)
- ✅ Stricter regex pattern: `[A-Z]{2,10}-\d{1,5}` with known prefix check

**Final Status: Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-25
**Version**: 3.1.0
