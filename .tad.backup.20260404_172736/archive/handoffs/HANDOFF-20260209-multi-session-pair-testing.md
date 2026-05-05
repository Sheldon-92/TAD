# Handoff: Multi-Session Pair Testing

**From:** Alex (Solution Lead)
**To:** Blake (Execution Master)
**Date:** 2026-02-09
**Task ID:** TASK-20260209-001
**Priority:** P1
**Complexity:** Medium (Light TAD)
**Status:** Expert Review Complete - Ready for Implementation

---

## Socratic Inquiry Summary

**Complexity**: Light | **Rounds**: 2

| Dimension | Decision |
|-----------|----------|
| Session model | Hybrid: directory isolation + sequential numbering + manifest index |
| Archive strategy | Keep current per-session logic, just support multiple sessions |
| Context inheritance | Auto-inherit previous session's findings summary in new briefs |

---

## Executive Summary

Upgrade TAD's pair testing system from singleton (1 TEST_BRIEF + 1 PAIR_TEST_REPORT at a time) to multi-session support. Real-world usage in the O1 for builder project shows 5+ test sessions per project, but current system assumes "one feature = one test." This causes document chaos, naming conflicts, and inability to track test iteration history.

**Core change**: Replace flat `.tad/pair-testing/` structure with session-based directories (`S01/`, `S02/`, ...) managed by a `SESSIONS.yaml` manifest.

---

## Current State (What Exists)

```
.tad/pair-testing/
  TEST_BRIEF.md          ← singleton (hardcoded)
  PAIR_TEST_REPORT.md    ← singleton (hardcoded)
  screenshots/           ← flat, no session isolation
```

**Singleton constraint** in tad-alex.md line ~1086:
```yaml
constraint: "TEST_BRIEF.md is a singleton - only one exists in .tad/pair-testing/ at any time"
```

**14 hardcoded path references** across:
- `.tad/templates/test-brief-template.md` (lines 7-9, 168, 198, 202, 211, 237, 250, 316, 319, 324, 367, 478, 524, 529)
- `.claude/commands/tad-alex.md` (step_pair_testing_assessment, test_review_protocol, STEP 3.6)
- `.tad/config-workflow.yaml` (pair_testing section)
- `.tad/templates/pair-test-report-template.md` (line 98)

---

## Target State (What We Want)

```
.tad/pair-testing/
  SESSIONS.yaml           ← manifest index (tracks all sessions)
  S01/                    ← session 1
    TEST_BRIEF.md
    PAIR_TEST_REPORT.md
    screenshots/
      R1-01-homepage.png
      R2-01-upload.png
  S02/                    ← session 2 (regression test)
    TEST_BRIEF.md
    PAIR_TEST_REPORT.md
    screenshots/
      R1-01-homepage-fixed.png
  S03/                    ← session 3 (active, no report yet)
    TEST_BRIEF.md
    screenshots/
```

---

## Task Breakdown

### Task 1: Create SESSIONS.yaml Manifest Format

Define the manifest that tracks all pair testing sessions.

**File**: `.tad/pair-testing/SESSIONS.yaml` (created automatically by Alex when generating first brief)

**Format**:
```yaml
# Pair Testing Sessions Manifest
# Auto-managed by TAD. Do not edit manually.
project: {project_name}
total_sessions: 3
active_session: S03

sessions:
  S01:
    created: 2026-02-04
    status: archived          # active | reviewed | archived
    scope: "Upload API Fix"
    brief: S01/TEST_BRIEF.md
    report: S01/PAIR_TEST_REPORT.md
    findings: {P0: 1, P1: 2, P2: 0}
    archived_to: .tad/evidence/pair-tests/20260204-S01-upload-api-fix/

  S02:
    created: 2026-02-08
    status: reviewed
    scope: "V4 Visual Overhaul"
    brief: S02/TEST_BRIEF.md
    report: S02/PAIR_TEST_REPORT.md
    findings: {P0: 7, P1: 8, P2: 5}
    inherits_from: S01        # context inheritance chain

  S03:
    created: 2026-02-09
    status: active
    scope: "V4 Post-Remediation"
    brief: S03/TEST_BRIEF.md
    report: null              # not yet generated
    findings: null
    inherits_from: S02
```

**Session status lifecycle**: `active` → `reviewed` → `archived`

State transitions:
- `active`: Session created, brief written, testing in progress
- `reviewed`: PAIR_TEST_REPORT.md exists and *test-review has been run
- `archived`: Session directory moved to evidence/pair-tests/

**Session ID overflow**: S01-S99 use zero-padding. If S99 exists, next is S100 (no padding). Practical limit is sufficient — projects with 100+ test sessions should consolidate.

**Manifest recovery**: If SESSIONS.yaml is corrupted or missing:
1. Rename corrupt file to `SESSIONS.yaml.corrupt.{timestamp}`
2. Scan `S*/` directories to rebuild manifest (directories are source of truth)
3. Infer status from file presence: has report → `reviewed`, no report → `active`
4. Log recovery action

**Active session guard**: Before creating a new session, check if any session has status `active`. If so, prompt user: "Session {id} ({scope}) is still active. Archive it first or resume?"

---

### Task 2: Update test-brief-template.md

**File**: `.tad/templates/test-brief-template.md`

**Changes**:

1. **Update header** (lines 7-9): Replace hardcoded singleton paths with session-relative paths

Replace:
```markdown
> **File location**: `.tad/pair-testing/TEST_BRIEF.md`
> **Screenshots**: `.tad/pair-testing/screenshots/`
> **Report output**: `.tad/pair-testing/PAIR_TEST_REPORT.md`
```

With:
```markdown
> **Session**: `{session_id}` (e.g., S01, S02, ...)
> **File location**: `.tad/pair-testing/{session_id}/TEST_BRIEF.md`
> **Screenshots**: `.tad/pair-testing/{session_id}/screenshots/`
> **Report output**: `.tad/pair-testing/{session_id}/PAIR_TEST_REPORT.md`
> **Manifest**: `.tad/pair-testing/SESSIONS.yaml`
```

2. **Add Session Context section** after Section 4 (Known Issues). New **Section 4b**:

```markdown
## 4b. Previous Session Context

> Auto-populated from SESSIONS.yaml when this session inherits from a previous one.
> If this is the first session (S01), this section is omitted.

**Inherits from**: {previous_session_id}
**Previous scope**: {previous_scope}
**Previous findings summary**:

| # | Finding | Severity | Status |
|---|---------|----------|--------|
| {prev_finding_1} | {desc} | P0 | Fixed / Open / Deferred |

**Regression focus**: The following items from the previous session should be re-verified:
- {regression_item_1}
- {regression_item_2}
```

3. **Update screenshot paths** (lines 198, 202, 211, 250, 524): Replace all `.tad/pair-testing/screenshots/` with `.tad/pair-testing/{session_id}/screenshots/`

4. **Update report output path** (lines 316, 319, 324, 529): Replace `.tad/pair-testing/PAIR_TEST_REPORT.md` with `.tad/pair-testing/{session_id}/PAIR_TEST_REPORT.md`

5. **Update screenshot confirm** (line 168): Replace `.tad/pair-testing/screenshots/` with `.tad/pair-testing/{session_id}/screenshots/`

6. **Update Playwright controller** SCREENSHOT_DIR (line 367):
Replace:
```javascript
const SCREENSHOT_DIR = '{project_dir}/.tad/pair-testing/screenshots';
```
With:
```javascript
const SCREENSHOT_DIR = '{project_dir}/.tad/pair-testing/{session_id}/screenshots';
```

---

### Task 3: Update pair-test-report-template.md

**File**: `.tad/templates/pair-test-report-template.md`

**Changes**:

1. **Add session header** at top of the report template, after the blockquote intro:
```markdown
## 0. Session Info

| Item | Detail |
|------|--------|
| **Session ID** | {session_id} |
| **Inherits from** | {previous_session_id or "None (first session)"} |
| **Session manifest** | `.tad/pair-testing/SESSIONS.yaml` |
```

2. **Update screenshot directory reference** (line 98):
Replace:
```markdown
**Screenshot directory**: `.tad/pair-testing/screenshots/`
```
With:
```markdown
**Screenshot directory**: `.tad/pair-testing/{session_id}/screenshots/`
```

3. **Add regression verification section** (new Section 2b, after Results Summary):
```markdown
## 2b. Regression Verification (from Previous Session)

> Only present when inheriting from a previous session.

| Previous Finding | Previous Severity | Re-tested | Result |
|------------------|-------------------|-----------|--------|
| {prev_finding} | P0 | Yes/No | Fixed / Still present / Regressed |
```

---

### Task 4: Update tad-alex.md

**File**: `.claude/commands/tad-alex.md`

**4 specific changes**:

#### 4a. Remove singleton constraint in `step_pair_testing_assessment`

Find and replace the constraint line:
```yaml
constraint: "TEST_BRIEF.md is a singleton - only one exists in .tad/pair-testing/ at any time"
```
With:
```yaml
constraint: "Each TEST_BRIEF.md lives in its own session directory .tad/pair-testing/S{NN}/"
```

Update the brief generation logic inside `step_pair_testing_assessment`:
- Before writing TEST_BRIEF.md, read `SESSIONS.yaml` to determine next session ID
- If `SESSIONS.yaml` doesn't exist, create it and start with S01
- Create session directory: `.tad/pair-testing/S{NN}/` and `.tad/pair-testing/S{NN}/screenshots/`
- If inheriting, read previous session's report findings and populate Section 4b
- Update `SESSIONS.yaml` with new session entry (status: active)
- Write brief to `.tad/pair-testing/S{NN}/TEST_BRIEF.md`

Replace the reminder message:
```
".tad/pair-testing/TEST_BRIEF.md 已生成（所有 Section 已填充）
 请将 .tad/pair-testing/TEST_BRIEF.md 拖入 Claude Desktop Cowork 进行配对 E2E 测试。
```
With:
```
".tad/pair-testing/{session_id}/TEST_BRIEF.md 已生成（所有 Section 已填充）
 Session ID: {session_id} | 继承自: {prev_session or 'None'}
 请将 .tad/pair-testing/{session_id}/TEST_BRIEF.md 拖入 Claude Desktop Cowork 进行配对 E2E 测试。
 测试完成后，PAIR_TEST_REPORT.md 保存到 .tad/pair-testing/{session_id}/，
 下次启动 /alex 时我会自动检测并处理。"
```

#### 4b. Update STEP 3.6 (pair test report detection)

Replace the scan logic:
```yaml
action: |
  Scan .tad/pair-testing/ for PAIR_TEST_REPORT*.md files.
```
With:
```yaml
action: |
  1. Read .tad/pair-testing/SESSIONS.yaml (if exists)
  2. For each session with status "active":
     Check if .tad/pair-testing/{session_id}/PAIR_TEST_REPORT.md exists
  3. Also scan .tad/pair-testing/S*/PAIR_TEST_REPORT.md as fallback
  4. If reports found:
     a. List them with session ID, scope, and creation date
     b. Use AskUserQuestion:
        "检测到 {N} 个配对测试报告，要现在审阅吗？"
        Options per report: "审阅 {session_id}: {scope}" / "稍后处理"
     c. If review → execute *test-review for selected session
```

#### 4c. Update `test_review_protocol`

Update the archive step (step 5) to use session directories:

Replace:
```yaml
a. Copy & rename .tad/pair-testing/TEST_BRIEF.md → .tad/evidence/pair-tests/{date}-test-brief-{slug}.md
b. Copy & rename .tad/pair-testing/PAIR_TEST_REPORT.md → .tad/evidence/pair-tests/{date}-pair-test-report-{slug}.md
c. Copy .tad/pair-testing/screenshots/ → .tad/evidence/pair-tests/{date}-screenshots-{slug}/
```
With:
```yaml
archive_protocol:
  strategy: "atomic move (mv) when same filesystem, fallback to copy-verify-delete"
  prerequisite: "Ensure .tad/evidence/pair-tests/ exists (create if missing)"
  steps:
    a. Move entire session directory (atomic):
       mv .tad/pair-testing/{session_id}/ → .tad/evidence/pair-tests/{date}-{session_id}-{slug}/
       Fallback (cross-filesystem): cp -r, verify file count + sizes match, then rm -rf source
    b. Verification (only for copy fallback):
       - Count files in source and destination match
       - For TEST_BRIEF.md and PAIR_TEST_REPORT.md, verify content readable
       - On mismatch: abort, log error, keep source intact, delete partial destination
    c. Update SESSIONS.yaml: set session status to "archived", add archived_to path
    d. If this was the active_session, set active_session to null in manifest
    e. Backup SESSIONS.yaml to SESSIONS.yaml.bak before any write
```

#### 4d. Update `step_pair_testing_assessment` session creation logic

Add the full session creation flow:
```yaml
session_creation_flow: |
  1. Read .tad/pair-testing/SESSIONS.yaml
     - If not exists → create with empty sessions, total_sessions: 0
  2. Determine next session ID:
     - Count existing S{NN} directories → next = S{NN+1} (zero-padded: S01, S02, ..., S99)
  3. Check for inheritable context:
     - Find most recent session with status "reviewed" or "archived"
     - If found → read its PAIR_TEST_REPORT.md for findings summary
     - Use AskUserQuestion: "上一次测试 ({prev_scope}) 发现了 {N} 个问题。要在新 brief 中包含回归验证项吗？"
       Options: "包含回归验证 (Recommended)" / "全新独立测试"
  4. Create directory: .tad/pair-testing/{session_id}/screenshots/
  5. Generate TEST_BRIEF.md with session header and optional Section 4b
  6. Update SESSIONS.yaml: add new session entry, set as active_session
```

---

### Task 5: Update config-workflow.yaml

**File**: `.tad/config-workflow.yaml`

**Update the `pair_testing` section** (around line 196-231):

Replace:
```yaml
pair_testing:
  description: "Cross-tool E2E pair testing protocol (TAD CLI → Claude Desktop Cowork)"
  ownership: "Alex generates brief, human decides, Claude Desktop executes with human"
  base_dir: ".tad/pair-testing/"

  brief:
    template: ".tad/templates/test-brief-template.md"
    output: ".tad/pair-testing/TEST_BRIEF.md"
```

With:
```yaml
pair_testing:
  description: "Cross-tool E2E pair testing protocol with multi-session support"
  ownership: "Alex generates brief, human decides, Claude Desktop executes with human"
  base_dir: ".tad/pair-testing/"
  version: "2.0"

  # Multi-session management
  sessions:
    manifest: ".tad/pair-testing/SESSIONS.yaml"
    directory_pattern: ".tad/pair-testing/S{NN}/"
    max_active_sessions: 1        # Only 1 session can be "active" at a time
    session_id_format: "S{NN}"    # S01, S02, ..., S99
    context_inheritance: true      # New sessions auto-inherit previous findings

  brief:
    template: ".tad/templates/test-brief-template.md"
    output: ".tad/pair-testing/{session_id}/TEST_BRIEF.md"
```

Also update:
```yaml
  report:
    template: ".tad/templates/pair-test-report-template.md"
    expected_pattern: ".tad/pair-testing/S*/PAIR_TEST_REPORT.md"
    location: ".tad/pair-testing/{session_id}/"
    archive_to: ".tad/evidence/pair-tests/{date}-{session_id}-{slug}/"
    auto_detect_on_alex_start: true
```

And:
```yaml
  screenshot:
    output_dir: ".tad/pair-testing/{session_id}/screenshots/"
    naming: "R{N}-{NN}-{description}.png"
```

---

### Task 6: Update tad-test-brief.md

**File**: `.claude/commands/tad-test-brief.md`

**4 hardcoded references to update** (lines 15, 38, 43, 55):

All occurrences of `.tad/pair-testing/TEST_BRIEF.md` → `.tad/pair-testing/{session_id}/TEST_BRIEF.md`

Specifically:
- Line 15: Existence check → check `SESSIONS.yaml` for active session, then check `{session_id}/TEST_BRIEF.md`
- Line 38: Write path → write to `.tad/pair-testing/{session_id}/TEST_BRIEF.md`
- Line 43: Success message → include session ID
- Line 55: Drag instruction → reference session-specific path

Also add session creation logic (same as Task 4d) if this command is invoked standalone (without /alex context):
- Read SESSIONS.yaml → determine next session ID → create directory → write brief

---

### Task 7: Update tad-help.md

**File**: `.claude/commands/tad-help.md`

**2 references to update** (lines 187-188):

Replace:
```markdown
| Gate 4 后 | Alex 评估建议，人类决定 | `.tad/pair-testing/TEST_BRIEF.md` |
| 配对测试 | 用户 + Claude Desktop Cowork | `.tad/pair-testing/PAIR_TEST_REPORT.md` |
```
With:
```markdown
| Gate 4 后 | Alex 评估建议，人类决定 | `.tad/pair-testing/{session_id}/TEST_BRIEF.md` |
| 配对测试 | 用户 + Claude Desktop Cowork | `.tad/pair-testing/{session_id}/PAIR_TEST_REPORT.md` |
```

---

## Files to Modify

| # | File | Action | Scope |
|---|------|--------|-------|
| 1 | `.tad/templates/test-brief-template.md` | Edit | Session header, paths, new Section 4b |
| 2 | `.tad/templates/pair-test-report-template.md` | Edit | Session info, regression section |
| 3 | `.claude/commands/tad-alex.md` | Edit | 4 sections: constraint, STEP 3.6, test-review, assessment |
| 4 | `.tad/config-workflow.yaml` | Edit | pair_testing section upgrade |
| 5 | `.claude/commands/tad-test-brief.md` | Edit | 4 hardcoded paths + session creation logic |
| 6 | `.claude/commands/tad-help.md` | Edit | 2 path references in pair testing table |

No new files need to be created by Blake — `SESSIONS.yaml` is created at runtime by Alex.

---

## Acceptance Criteria

- [ ] AC1: Alex can generate TEST_BRIEF for session S01 (first session, no inheritance)
- [ ] AC2: Alex can generate TEST_BRIEF for session S02+ with automatic context inheritance from previous session
- [ ] AC3: Each session has isolated directory with own brief, report, and screenshots
- [ ] AC4: SESSIONS.yaml is created/updated correctly when new sessions are generated
- [ ] AC5: Alex STEP 3.6 detects reports across multiple session directories
- [ ] AC6: `*test-review` archives a single session directory (not the whole pair-testing dir)
- [ ] AC7: No singleton constraint references remain in tad-alex.md
- [ ] AC8: All hardcoded `.tad/pair-testing/TEST_BRIEF.md` paths updated to session-relative (across ALL 6 files)
- [ ] AC9: All hardcoded `.tad/pair-testing/screenshots/` paths updated to session-relative
- [ ] AC10: config-workflow.yaml pair_testing section reflects multi-session config
- [ ] AC11: Report template includes session ID and regression verification section
- [ ] AC12: Brief template includes session header and Section 4b (Previous Session Context)
- [ ] AC13: Session status lifecycle is `active → reviewed → archived` (no `pending` state)
- [ ] AC14: Only one session can have status "active" at a time (active guard enforced)
- [ ] AC15: SESSIONS.yaml corruption recovery protocol defined (scan S*/ dirs to rebuild)
- [ ] AC16: Archive uses atomic move (mv) by default, with copy-verify-delete fallback
- [ ] AC17: tad-test-brief.md paths updated (4 references)
- [ ] AC18: tad-help.md paths updated (2 references)

---

## Testing Checklist

- [ ] Verify no hardcoded singleton paths remain (grep for `.tad/pair-testing/TEST_BRIEF.md` — expect 0 matches)
- [ ] Verify no hardcoded singleton paths remain (grep for `.tad/pair-testing/PAIR_TEST_REPORT.md` — expect 0 matches)
- [ ] Verify no hardcoded flat screenshot paths remain (grep for `.tad/pair-testing/screenshots/` without `{session_id}`)
- [ ] Verify SESSIONS.yaml format matches the specification (3-state lifecycle, no `pending`)
- [ ] Verify tad-alex.md singleton constraint is removed/replaced
- [ ] Verify tad-test-brief.md all 4 paths updated (lines 15, 38, 43, 55)
- [ ] Verify tad-help.md both paths updated (lines 187-188)
- [ ] Verify archive uses `mv` by default (not `cp` then `rm`)

---

## Expert Review Status

| Expert | Verdict | P0 Issues | P1 Issues |
|--------|---------|-----------|-----------|
| code-reviewer | CONDITIONAL PASS → RESOLVED | 3 (all fixed: missing files, ID overflow, corruption recovery) | 4 (key items addressed) |
| backend-architect | CONDITIONAL PASS → RESOLVED | 2 (all fixed: state machine, archive strategy) | 4 (key items addressed) |

**P0 Fixes Applied**:
1. Added Task 6 (tad-test-brief.md) and Task 7 (tad-help.md) — missing file references
2. Added session ID overflow handling (S99 → S100, no padding)
3. Added SESSIONS.yaml corruption recovery protocol (scan dirs to rebuild)
4. Removed `pending` state — lifecycle is now `active → reviewed → archived`
5. Changed archive from copy-then-delete to atomic move (mv) with copy-verify fallback
6. Added active session guard (prevent creating new session while one is active)
7. Added SESSIONS.yaml backup before writes
