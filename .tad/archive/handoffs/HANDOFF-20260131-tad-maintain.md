# HANDOFF: /tad-maintain Command - Document Health & Sync

**Date**: 2026-01-31
**From**: Alex (Solution Lead)
**To**: Blake (Execution Master)
**Status**: Expert Review Complete - Ready for Implementation
**Handoff Version**: 1.1.0 (post-review revision)

---

## Executive Summary

Create `/tad-maintain` command that keeps all TAD project documents synchronized and healthy. Solves the persistent problem of document state lagging behind actual development progress. Operates in 3 modes: check (read-only), sync (scoped write), and full (comprehensive).

## Problem Statement

After completing development tasks, documents frequently become stale:
- Handoffs remain in `active/` after implementation is done
- NEXT.md accumulates completed tasks without archival
- PROJECT_CONTEXT.md doesn't exist or is outdated
- Version references across files become inconsistent
- No single command to diagnose and fix all these issues

## Design Decisions

### 1. Independent Role
`/tad-maintain` is NOT tied to Alex or Blake. It runs in any terminal. This is an explicit exception to the Terminal Isolation Rules in CLAUDE.md Section 5.

### 2. Explicit Mode via Argument
Mode is passed as a text argument, not inferred from context:
- `/tad-maintain` or `/tad-maintain full` → FULL mode
- When auto-triggered, the calling command includes literal mode text in its instruction

### 3. Three Operating Modes

| Mode | Trigger | Operations | Scope |
|------|---------|------------|-------|
| **check** | Agent activation, `*exit` | Read-only scan, terminal report | All documents |
| **sync** | `*accept` | Write operations | **Only the just-accepted handoff** + NEXT.md |
| **full** | Manual `/tad-maintain` | check + broad sync | All documents |

### 4. Config-Driven Thresholds
All thresholds read from `.tad/config.yaml` `next_md_maintenance.size_limits`:
- `warning_threshold: 400` → report WARNING
- `max_lines: 500` → trigger archival

### 5. Safe Auto-Archive Criteria
Only **deterministic** checks trigger auto-archive (no heuristic file-modification detection):
- Criterion A: Matching COMPLETION report exists in archive
- Criterion B: Higher-version file exists in archive

---

## Task Breakdown

### Task 1: Create `/tad-maintain` Command File

**File to CREATE**: `.claude/commands/tad-maintain.md`

Complete command specification below:

~~~markdown
# TAD Maintain Command

When this command is used, perform document health check and synchronization.

## Mode

- Default (no argument or `full`): FULL mode - comprehensive check + sync
- When called with `check` context from agent activation: CHECK mode - read-only
- When called with `sync` context from *accept: SYNC mode - scoped write operations

**CHECK mode**: MUST NOT modify any files. Read-only scan and report only.
**SYNC mode**: Scoped to the specific handoff being accepted + NEXT.md cleanup.
**FULL mode**: CHECK + broad SYNC across all documents.

## Step 1: Gather Current State

Read these to establish baseline:
1. `.tad/version.txt` → current version string
2. `.tad/config.yaml` (first 10 lines) → config version
3. `ls .tad/active/handoffs/` → list active handoff files
4. `ls .tad/archive/handoffs/` → list archived files
5. `NEXT.md` → count lines, read content
6. `PROJECT_CONTEXT.md` → check if exists

## Step 2: Handoff Lifecycle Audit

For each file in `.tad/active/handoffs/`:

### Step 2a: Extract Canonical Slug

Different naming formats exist. Extract a slug for matching:

| Format | Example | Extracted Slug |
|--------|---------|----------------|
| `HANDOFF-{date}-{slug}.md` | `HANDOFF-20260126-multi-platform-init.md` | `multi-platform-init` |
| `{date}_{time}_{version}_{taskid}_{slug}_{type}.md` | `20260126_0043_v1.0_TASK-20260126-001_blake-ralph-fusion_design.md` | `blake-ralph-fusion` |
| `COMPLETION-{date}-{slug}.md` | `COMPLETION-20260126-blake-ralph-fusion.md` | `blake-ralph-fusion` |

**Extraction rules:**
1. Strip file extension `.md`
2. If starts with `HANDOFF-` or `COMPLETION-`: remove prefix and date, remaining = slug
3. If long format: extract the segment between task-id and type (e.g., between `TASK-YYYYMMDD-NNN_` and `_design`)
4. Normalize: lowercase, keep hyphens

### Step 2b: Match Against Archive

For each active handoff's slug, search `.tad/archive/handoffs/` for:

**Criterion A (COMPLETED)**: A file matching `COMPLETION-*{slug}*` exists in archive.
→ Action: Mark as COMPLETED.

**Criterion B (SUPERSEDED)**: A file with the same slug but higher version number exists in archive.
→ Action: Mark as STALE.

**No match found**: Keep as ACTIVE (in progress).

### Step 2c: Actions (SYNC/FULL mode only)

**Write safety - two-phase approach:**
1. First: Verify destination in `.tad/archive/handoffs/` does not already have a file with the same name
2. If name conflict: append `-dup-{timestamp}` suffix to avoid overwrite
3. Move file: copy to archive first, then delete from active
4. If copy fails: abort, report error, do NOT delete source

Actions by status:
- COMPLETED → move to `.tad/archive/handoffs/`
- STALE → delete from active (archive already has newer version)
- ACTIVE → no action (leave in place)

### Step 2d: Idempotency Check

Before any move/delete, verify the source file still exists in `active/`. If already moved (e.g., by a concurrent run), skip silently.

## Step 3: NEXT.md Maintenance

### Step 3a: Read Thresholds from Config

Read `.tad/config.yaml` section `next_md_maintenance.size_limits`:
- `warning_threshold` (default 400)
- `max_lines` (default 500)

### Step 3b: Check

1. Count total lines in NEXT.md
2. Parse sections by `## ` headers
3. Classify each section:

| Section Pattern | Classification | Archive? |
|-----------------|---------------|----------|
| `## 已完成 (DATE)` or `## Completed (DATE)` | Completed | Yes, if DATE > 7 days ago |
| `## 今天` or `## Today` | Active | Never |
| `## 本周` or `## This Week` | Active | Never |
| `## In Progress` | Active | Never |
| `## 待定` or `## Pending` | Active | Never |
| `## 阻塞` or `## Blocked` | Active | Never |
| `## vX.X 变更摘要` | Reference | Archive with its parent completed section |
| Any other `## ` section | Unknown | Flag in report, don't auto-archive |

4. Check if total lines > `warning_threshold`

### Step 3c: Actions (SYNC/FULL mode only)

Only if total lines > `max_lines` (from config):
1. Identify archivable sections (completed > 7 days + their reference tables)
2. Read `.tad/templates/history-md-template.md` for archive format
3. Create or append to `docs/HISTORY.md`:
   - If `docs/HISTORY.md` doesn't exist, create it with template header
   - Append archived sections under `## Week of {date}` heading
4. **Write HISTORY.md first, verify write succeeded**
5. Only then: remove archived sections from NEXT.md
6. Update any stale version references in NEXT.md

If between `warning_threshold` and `max_lines`: report WARNING but do not auto-archive.

## Step 4: PROJECT_CONTEXT.md Sync

### Check:
- File exists?
- If exists: version matches `.tad/version.txt`?

### Actions (SYNC/FULL mode only):

If missing, create with this template (use actual project values):

```markdown
# Project Context - {project_name}

## Current State
- **Version**: {from .tad/version.txt}
- **Last Updated**: {today}
- **Framework**: TAD v{version}

## Active Work
{list each file in .tad/active/handoffs/ with status}

## Recent Decisions
{from last 3 archived handoffs - 1 line summary each}

## Known Issues
{any flagged items from health check}

## Next Direction
{from NEXT.md active sections - top 3 items}
```

If exists but outdated: update version and Active Work section only.
Keep under 150 lines.

## Step 5: Document Consistency Check

### Checks (all modes):
1. `.tad/version.txt` value == `config.yaml` `version:` field
2. No orphaned design files in `.tad/active/designs/` (designs whose slug has no matching active handoff)
3. Evidence check (FULL mode only): `.tad/evidence/reviews/` files reference existing archived gates

### Actions (FULL mode only):
- Report all inconsistencies
- Auto-fix: if version.txt and config.yaml disagree, report which is newer (by file modification date) and suggest fix, but do NOT auto-fix version mismatches

## Step 6: Health Report Output (Terminal)

**CHECK mode output:**

```
=== TAD Health Check | {date} ===

HANDOFFS
  [icon] {N} active | {N} completed (not archived) | {N} stale

DOCUMENTS
  [icon] NEXT.md: {lines} lines {status}
  [icon] PROJECT_CONTEXT.md: {exists/missing}
  [icon] Version: {version.txt} / config: {config version}

{if issues found:}
RECOMMENDED ACTIONS
  1. Run `/tad-maintain` to sync documents
  2. {specific recommendations}

HEALTH: {OK/WARNING/CRITICAL}
===
```

**SYNC/FULL mode output:**

```
=== TAD Maintain Report | {date} | MODE: {sync/full} ===

HANDOFFS
  [icon] {N} properly archived
  [icon] {N} completed -> archived (this run)
  [icon] {N} stale -> cleaned (this run)
  [icon] {N} active (in progress)

DOCUMENTS
  [icon] config.yaml: v{version}
  [icon] version.txt: v{version}
  [icon] NEXT.md: {lines} lines ({action taken or status})
  [icon] PROJECT_CONTEXT.md: {created/updated/ok}

CONSISTENCY
  [icon] Version alignment: {pass/fail}
  [icon] Active directory: {clean/N orphans}

ACTIONS TAKEN
  1. {description}
  2. {description}
  ...

{if any errors:}
ERRORS
  1. {what failed and why}

HEALTH: {OK/WARNING/CRITICAL} - {summary}
===
```

Icons: use text markers `[OK]` `[WARN]` `[ERR]` `[INFO]` for terminal compatibility.
~~~

### Acceptance Criteria for Task 1:
- [ ] Command file created at `.claude/commands/tad-maintain.md`
- [ ] CHECK mode is strictly read-only (no file write/move/delete)
- [ ] SYNC mode only operates on scoped handoff + NEXT.md
- [ ] FULL mode performs all checks and all sync operations
- [ ] Handoff slug extraction handles both naming formats
- [ ] Auto-archive uses only deterministic criteria (A and B)
- [ ] Write operations follow two-phase approach (write dest first, then remove source)
- [ ] Health report outputs in correct format per mode
- [ ] Thresholds read from config.yaml, not hardcoded

---

### Task 2: Integrate Auto-Trigger into Alex/Blake

**Files to MODIFY**:
- `.claude/commands/tad-alex.md`
- `.claude/commands/tad-blake.md`

### Changes for tad-alex.md:

**A. In `activation-instructions` section, add after STEP 3 (Load config):**

```yaml
  - STEP 3.5: Document health check
    action: |
      Run document health check in CHECK mode.
      Scan .tad/active/handoffs/, NEXT.md, PROJECT_CONTEXT.md.
      Output a brief health summary (the CHECK mode report from /tad-maintain).
      This is READ-ONLY - do not modify any files.
    output: "Display health summary before greeting"
    blocking: false
    suppress_if: "No issues found - show one-line: 'TAD Health: OK'"
```

**B. In `accept_command.steps` section, add as final step:**

```yaml
    step_final:
      action: |
        Run document sync in SYNC mode - scoped to the just-accepted handoff.
        1. Archive the specific handoff that was just accepted
        2. Check NEXT.md line count against config thresholds
        3. If over max_lines: archive old completed sections
        4. Update PROJECT_CONTEXT.md active work section
      trigger: "After all other *accept steps complete"
      purpose: "Keep documents synchronized after task completion"
```

**C. In `exit_protocol.steps`, add as first step:**

```yaml
  steps:
    - "Run document health check (CHECK mode) - report any stale documents"
    - "Check NEXT.md is updated"  # existing
    - "Confirm handoffs are properly managed"  # existing
    - "Confirm后续任务清晰可继续"  # existing
```

### Changes for tad-blake.md:

**A. In `activation-instructions`, add after config load:**

```yaml
  - STEP 3.5: Document health check
    action: |
      Run document health check in CHECK mode.
      Scan .tad/active/handoffs/, NEXT.md.
      Output a brief health summary.
      This is READ-ONLY - do not modify any files.
    output: "Display health summary"
    blocking: false
    suppress_if: "No issues found - show one-line: 'TAD Health: OK'"
```

**B. In Blake's `exit_protocol.steps`, add as first step:**

```yaml
  steps:
    - "Run document health check (CHECK mode) - report document status"
    - "Check NEXT.md is updated"  # existing
    - "Verify all implementation changes are committed"  # existing
```

**Note**: Blake does NOT have `*accept`, so no SYNC trigger in Blake. Only Alex's `*accept` triggers SYNC.

### Acceptance Criteria for Task 2:
- [ ] Alex activation runs CHECK (read-only, shows summary)
- [ ] Blake activation runs CHECK (read-only, shows summary)
- [ ] Alex `*accept` runs scoped SYNC after archival steps
- [ ] Alex `*exit` runs CHECK before exit
- [ ] Blake `*exit` runs CHECK before exit
- [ ] When no issues found, output is one-line "TAD Health: OK"
- [ ] Auto-triggers never block normal workflow

---

### Task 3: Update CLAUDE.md with Maintain Rules

**File to MODIFY**: `CLAUDE.md`

**Important**: Current section 8 is "8. 违规处理". Renumber it to section 9. Insert new section 8 before it.

Add after "7. 学习记录规则", before the current "8. 违规处理":

```markdown
## 8. 文档维护规则 (/tad-maintain)

`/tad-maintain` 是独立于 Alex/Blake 的维护命令，可在任何 Terminal 运行（Terminal 隔离规则的显式例外）。

### 三种模式
| 模式 | 触发时机 | 操作范围 |
|------|----------|----------|
| CHECK | Agent 激活时、`*exit` 时 | 只读扫描，终端报告 |
| SYNC | `*accept` 完成后 | 归档当前 handoff + NEXT.md 清理 |
| FULL | 手动 `/tad-maintain` | 全面检查 + 全面同步 |

### Handoff 自动归档条件
满足以下**任一**条件的 active handoff 将被自动归档（仅 SYNC/FULL 模式）:
1. archive 中已有对应的 COMPLETION 报告（slug 匹配）
2. archive 中已有更高版本的同名文件（slug + version 匹配）

**禁止**: 不得基于文件修改时间推测 handoff 是否完成。

### NEXT.md 清理规则（阈值来自 config.yaml）
- 超过 `warning_threshold`（默认 400 行）→ 报告 WARNING
- 超过 `max_lines`（默认 500 行）→ 触发自动归档到 `docs/HISTORY.md`
- 归档对象: 完成超过 7 天的 `## 已完成` 段落
- 保留: In Progress / Today / This Week / Blocked / 近 7 天完成

### 写操作安全规则
- 先写目标文件，确认成功后再删除源文件
- 文件名冲突时添加 `-dup-{timestamp}` 后缀
- 操作前检查源文件是否仍存在（幂等性）
```

Then renumber the original "8. 违规处理" to:

```markdown
## 9. 违规处理
```

### Acceptance Criteria for Task 3:
- [ ] New section 8 added with maintain rules
- [ ] Original section 8 renumbered to section 9
- [ ] Archive criteria match Task 1 (only deterministic, no heuristic)
- [ ] Thresholds reference config.yaml, not hardcoded values
- [ ] Terminal isolation exception explicitly stated

---

### Task 4: Register Command in TAD System

**Files to MODIFY**:
- `.tad/config.yaml`
- `.claude/commands/tad-help.md`

### config.yaml changes:

Add a new section after `document_management` (or within it):

```yaml
# Document Maintenance Command
tad_maintain:
  description: "Document health check and synchronization"
  command_file: ".claude/commands/tad-maintain.md"
  modes:
    check:
      description: "Read-only health scan"
      triggers: ["agent_activation", "exit_command"]
    sync:
      description: "Scoped write operations"
      triggers: ["accept_command"]
    full:
      description: "Comprehensive check + sync"
      triggers: ["manual"]
  auto_archive_criteria:
    - "matching_completion_report"
    - "superseded_by_newer_version"
  safety:
    write_strategy: "copy-then-delete"
    idempotent: true
    name_conflict_resolution: "append-timestamp-suffix"
```

### tad-help.md changes:

1. Update version reference from `v1.4` to `v2.1.1` in the header
2. Add to command reference:

```
/tad-maintain  → Document health check, sync, and cleanup (3 modes: check/sync/full)
```

### Acceptance Criteria for Task 4:
- [ ] config.yaml includes tad_maintain section
- [ ] tad-help.md includes /tad-maintain
- [ ] tad-help.md version updated to v2.1.1
- [ ] Config matches actual implementation behavior

---

## Implementation Order

```
Task 1 (core command) → Task 2 + Task 3 + Task 4 (parallel after Task 1)
```

Task 1 is the foundation. Tasks 2, 3, and 4 are independent of each other and can be done in parallel.

## Files Summary

| Action | File | Task |
|--------|------|------|
| CREATE | `.claude/commands/tad-maintain.md` | 1 |
| MODIFY | `.claude/commands/tad-alex.md` | 2 |
| MODIFY | `.claude/commands/tad-blake.md` | 2 |
| MODIFY | `CLAUDE.md` | 3 |
| MODIFY | `.tad/config.yaml` | 4 |
| MODIFY | `.claude/commands/tad-help.md` | 4 |

## Testing Checklist

- [ ] `/tad-maintain` manual run → full mode health report
- [ ] `/tad-maintain` CHECK mode → read-only, no files modified
- [ ] `/tad-maintain` SYNC mode → only scoped handoff archived
- [ ] Handoff slug extraction: test both naming formats
- [ ] Auto-archive: only triggers on Criterion A or B, never on file timestamps
- [ ] NEXT.md cleanup: preserves active sections, only archives old completed
- [ ] NEXT.md thresholds: reads from config.yaml, not hardcoded
- [ ] PROJECT_CONTEXT.md: creates if missing, updates if outdated
- [ ] Two-phase write: if copy fails, source is NOT deleted
- [ ] Idempotency: running twice produces same result
- [ ] Alex activation → one-line health or CHECK report
- [ ] Blake activation → one-line health or CHECK report
- [ ] Alex `*accept` → SYNC triggers after archival

---

## Expert Review Status

| Expert | Status | P0 Found | P0 Fixed |
|--------|--------|----------|----------|
| code-reviewer | COMPLETE | 3 | 3 |
| backend-architect | COMPLETE | 3 | 3 |

### P0 Issues Resolved:

1. **Mode detection undefined** → Fixed: explicit mode argument in calling text
2. **Threshold contradiction (300 vs 500)** → Fixed: read from config.yaml
3. **Heuristic #2 unsafe** → Fixed: removed file-modification detection, only deterministic criteria
4. **Naming convention matching** → Fixed: added slug extraction algorithm with format table
5. **No atomicity/rollback** → Fixed: two-phase write (copy-then-delete) + idempotency check
6. **CLAUDE.md section numbering** → Fixed: renumber section 8→9, insert new section 8

### P1 Issues Addressed:

- NEXT.md section parsing rules: added classification table
- Blake integration under-specified: added full YAML for both activation and exit
- Scoped sync after *accept: SYNC only operates on the just-accepted handoff
- Idempotency: source-exists check before operations
- Terminal isolation exception: explicitly stated in CLAUDE.md addition
- Auto-trigger noise: suppress to one-line when no issues

---

*Handoff created by Alex (Solution Lead) - TAD v2.1.1*
*Expert review: 2 experts, 6 P0 issues found and resolved, CONDITIONAL PASS → PASS*
