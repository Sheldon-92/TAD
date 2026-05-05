# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-31
**Project:** TAD Framework
**Task ID:** TASK-20260331-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260331-tad-v3-hook-native-rebuild.md (Phase 2/5)
**Linear:** N/A

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-03-31

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Based on validated spike + approved blueprint |
| Components Specified | ✅ | 4 hook scripts + settings.json rewrite |
| Functions Verified | ✅ | All mechanisms validated in Phase 0 spike |
| Data Flow Mapped | ✅ | Hook stdin JSON → script → stdout JSON → additionalContext |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] Read complete handoff
- [ ] **Read `.tad/spike-v3/README.md`** — spike findings are your ground truth
- [ ] **Read `.tad/spike-v3/ARCHITECTURE-v3.md`** — architecture blueprint
- [ ] Read `.tad/project-knowledge/architecture.md` — last 2 entries about hooks
- [ ] Understand that hook event keys are **PascalCase** (PostToolUse, not post-tool-use)
- [ ] Understand additionalContext appears as `<system-reminder>` to the model

---

## 1. Task Overview

### 1.1 What We're Building
Hook infrastructure layer for TAD v3.0: 3 hook scripts + native settings.json rewrite. This creates the "framework enforcement layer" that replaces prompt-based rules with shell-script automation.

### 1.2 Why We're Building It
TAD currently relies on LLM to execute mechanical tasks (file state checks, NEXT.md updates, Linear sync, Gate reminders). These cost tokens, waste time, and can be skipped by rationalization. Hooks execute with zero LLM cost, 100% reliability, and millisecond latency.

### 1.3 Intent Statement

**真正要解决的问题**: Make TAD's workflow enforcement deterministic — hooks fire regardless of what the model decides.

**不是要做的**:
- ❌ Not modifying Alex or Blake skill files (that's Phase 3)
- ❌ Not implementing quality gate hooks (that's Phase 4)
- ❌ Not restricting tools via deny (not needed for this phase)

---

## 📚 Project Knowledge

- [x] architecture — 2 entries: "Hook Validation" + "Enforcement Priority Order" (2026-03-31)

**⚠️ Blake 必须注意的历史教训**:
1. **Hook event keys are PascalCase** — `PostToolUse` not `post-tool-use`. Kebab-case silently fails.
2. **additionalContext injects as `<system-reminder>`** — this is system-level authority, model treats it seriously.
3. **permissions.deny > hooks** — don't use deny for tools that hooks need to conditionally allow.
4. **Bypass mode overrides everything** — hooks should work in default permission mode.

---

## 2. Background Context

### 2.1 Previous Work
- Phase 0 spike validated all hook mechanisms (5/7 PASS + 3c supplement)
- Phase 1 blueprint approved: 5-layer architecture with hooks as primary enforcement
- Spike evidence: `.tad/spike-v3/` (8 experiment results + 1 supplement)

### 2.2 Current State
- settings.json: Custom metadata format (not Claude Code native)
- No hook scripts exist
- All automation in prompt instructions

### 2.3 Reference Files
- Spike report: `.tad/spike-v3/README.md`
- Architecture: `.tad/spike-v3/ARCHITECTURE-v3.md`
- Spike Exp 1 (PostToolUse reference): `.tad/spike-v3/exp1-command-hook/`
- Spike Exp 4 (SessionStart reference): `.tad/spike-v3/exp4-session-hook/`

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Create `.tad/hooks/` directory with 3 production hook scripts
- FR2: Rewrite `.claude/settings.json` to Claude Code native format with hooks
- FR3: SessionStart hook injects project health summary on every session start
- FR4: PostToolUse hook detects key file writes and injects workflow reminders
- FR5: Hooks must work in `default` permission mode (not bypass)

### 3.2 Non-Functional Requirements
- NFR1: Each hook script executes in <500ms (no network calls in sync hooks)
- NFR2: Hook scripts must be POSIX-compatible (bash, not zsh-specific)
- NFR3: Scripts must handle missing files gracefully (no crash on fresh project)
- NFR4: All hook output must be valid JSON

---

## 4. Technical Design

### 4.1 Directory Structure

```
.tad/hooks/
├── startup-health.sh           # SessionStart hook
├── post-write-sync.sh          # PostToolUse hook (async)
└── lib/
    └── common.sh               # Shared functions (JSON output, file detection)
```

### 4.2 settings.json (New Format)

Replace entire `.claude/settings.json` with:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .tad/hooks/startup-health.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .tad/hooks/post-write-sync.sh",
            "async": true
          }
        ]
      }
    ]
  }
}
```

**Note**: Old metadata fields (agents, commands, prompts, autoload) are REMOVED — they have no effect in Claude Code.

### 4.3 Hook Script Specifications

---

#### Script 1: startup-health.sh (SessionStart)

**Trigger**: Every session start
**Input**: JSON stdin with `session_id`, `cwd`, `source` (startup/resume/clear/compact)
**Output**: JSON with additionalContext containing health summary

**Logic**:
```
0. Check if jq is available (which jq). If not, output minimal health string via echo.
1. Read stdin JSON. Check if "source" field exists:
   - If source exists and is NOT "startup" → exit 0 with empty JSON (skip)
   - If source doesn't exist or is "startup" → continue
   (source field existence unvalidated in spike — use defensive check)
2. Count active handoffs: ls .tad/active/handoffs/HANDOFF-*.md 2>/dev/null | wc -l
3. Count active epics: ls .tad/active/epics/EPIC-*.md 2>/dev/null | wc -l  
4. Count pending ideas: ls .tad/active/ideas/IDEA-*.md 2>/dev/null | wc -l
5. Check NEXT.md for blocked items: grep -q "## Blocked" NEXT.md && echo "has blocked"
6. Read .tad/version.txt for current version
7. Output JSON:
   {
     "hookSpecificOutput": {
       "hookEventName": "SessionStart",
       "additionalContext": "TAD v{version} | {N} handoffs | {M} epics | {K} ideas | Hooks: active"
     }
   }
```

**Output JSON MUST use `hookSpecificOutput` wrapper** (validated in spike Exp 1/4):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "TAD v3.0 | 1 handoffs | 1 epics | 0 ideas | Hooks: active"
  }
}
```

**Exit code**: 0 (always — startup must not block)

**Edge cases**:
- `.tad/` doesn't exist → output "TAD not initialized"
- Files missing → default to 0 counts
- jq missing → use basic echo fallback for minimal output
- `source` field missing in stdin → treat as "startup" (run anyway)

---

#### Script 2: post-write-sync.sh (PostToolUse, async)

**Trigger**: After any Write or Edit tool completes
**Input**: JSON stdin with `tool_name`, `tool_input` (contains file path), `tool_response`
**Output**: JSON with additionalContext (workflow reminders)

**Output JSON MUST use `hookSpecificOutput` wrapper**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Handoff detected. Expert review (2+ experts) is MANDATORY."
  }
}
```

**Field extraction**: Both Write and Edit tools use `.tool_input.file_path` (confirmed flat structure, not nested). Use: `jq -r '.tool_input.file_path'`. If jq unavailable, fallback: `grep -o '"file_path":"[^"]*"' | cut -d'"' -f4`.

**Logic**:
```
0. Check jq availability. Set extraction method accordingly.
1. Extract file_path: jq -r '.tool_input.file_path' (or grep fallback)
2. Match against patterns:

   Case: HANDOFF-*.md created/modified in .tad/active/handoffs/
   → additionalContext: "Handoff detected. Remember: Expert review (2+ experts) is MANDATORY before sending to Blake."

   Case: COMPLETION-*.md created in .tad/active/handoffs/  
   → additionalContext: "Completion report detected. Gate 4 (business acceptance) should be executed."

   Case: NEXT.md modified
   → additionalContext: "NEXT.md updated. Linear sync may be needed if items changed."

   Case: EPIC-*.md modified in .tad/active/epics/
   → additionalContext: "Epic updated. Check if phase status changed."

   Case: .tad/project-knowledge/*.md modified
   → additionalContext: "Knowledge file updated."

   Default: no output (exit 0 with empty JSON)
```

**Exit code**: 0 (always — async, never blocks)

**Key**: This script runs on EVERY Write/Edit, so it must be FAST. No network calls, no complex parsing. Just file path matching + canned messages.

---

#### Script 3: lib/common.sh (Shared utilities)

**Functions**:
```bash
# Read JSON from stdin into variable
read_stdin_json() { ... }

# Extract field from JSON using jq
get_json_field() { ... }

# Output hook response JSON
output_response() {
  # Args: additionalContext string
  # Returns valid JSON with hookSpecificOutput
}

# Safe file count (returns 0 if dir doesn't exist)
safe_count() { ... }
```

---

## 5. Evidence Required

### MQ1: Historical Code Search
- [x] Triggered: Searched for existing hook scripts or settings patterns
- **Finding**: No existing hooks. settings.json is custom metadata, not Claude Code native.

### MQ2: Function Existence
- N/A: Creating new files, not calling existing functions

---

## 6. Implementation Steps

### Phase 1: Foundation (lib + settings.json)

#### 交付物
- [ ] jq availability verified (or fallback strategy documented)
- [ ] `.tad/hooks/lib/common.sh` created with utility functions
- [ ] `.claude/settings.json` rewritten to native format (with `permissions` section)
- [ ] Verify hooks section is recognized (test with a simple echo hook)

#### 实施步骤
0. **PRE-FLIGHT**: Verify `which jq`. If missing, document in result and use grep/sed fallback in scripts.
1. Create `.tad/hooks/lib/common.sh` with JSON utilities (jq-primary, grep-fallback)
2. **BACKUP** `.claude/settings.json` to `.claude/settings.json.v2-backup`
3. Write new settings.json: `{ "permissions": { "deny": [] }, "hooks": {} }` (validate format)
4. Add a minimal test hook (echo) to verify hooks execute
5. Remove test hook, proceed to Phase 2

### Phase 2: startup-health.sh

#### 交付物
- [ ] `.tad/hooks/startup-health.sh` created and executable
- [ ] SessionStart hook registered in settings.json
- [ ] Verified: health summary appears on session start

#### 实施步骤
1. Write startup-health.sh following spec in Section 4.3
2. Make executable: `chmod +x .tad/hooks/startup-health.sh`
3. Add SessionStart hook to settings.json
4. **USER VERIFICATION**: Ask user to start new session to verify

### Phase 3: post-write-sync.sh

#### 交付物
- [ ] `.tad/hooks/post-write-sync.sh` created and executable
- [ ] PostToolUse hook registered in settings.json
- [ ] Verified: writing to NEXT.md triggers workflow reminder

#### 实施步骤
1. Write post-write-sync.sh following spec in Section 4.3
2. Make executable: `chmod +x .tad/hooks/post-write-sync.sh`
3. Add PostToolUse hook to settings.json
4. Test: Edit NEXT.md → verify additionalContext appears
5. Test: Create dummy HANDOFF-test.md → verify reminder appears → delete test file
6. **IMPORTANT**: Verify async hook's additionalContext actually reaches the model. If async delivery is unreliable, change to synchronous (remove `"async": true` — pattern matching is fast enough)

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/hooks/lib/common.sh          # Shared utilities
.tad/hooks/startup-health.sh      # SessionStart hook
.tad/hooks/post-write-sync.sh     # PostToolUse hook
```

### 7.2 Files to Modify
```
.claude/settings.json              # Complete rewrite to native format
```

### 7.3 Files to Backup
```
.claude/settings.json → .claude/settings.json.v2-backup
```

---

## 8. Testing

### 8.1 Unit Testing (per script)
- startup-health.sh: Pipe test JSON → verify output is valid JSON with additionalContext
- post-write-sync.sh: Pipe test JSON with various tool_input paths → verify correct pattern matching
- common.sh: Test each utility function

### 8.2 Integration Testing
- Start new session → verify health summary appears
- Write to NEXT.md → verify workflow reminder
- Write to non-TAD file → verify no output (silent)

### 8.3 Edge Cases
- Run in project without `.tad/` → no crash
- Run with NEXT.md missing → no crash
- Hook JSON output malformed → Claude Code ignores gracefully

---

## 9. Acceptance Criteria

- [ ] AC1: `.tad/hooks/` directory exists with 3 scripts (2 hooks + 1 lib)
- [ ] AC2: settings.json is Claude Code native format (hooks section, no custom metadata)
- [ ] AC3: SessionStart hook outputs health summary (verified in new session)
- [ ] AC4: PostToolUse hook detects HANDOFF-*.md writes and injects reminder
- [ ] AC5: PostToolUse hook detects NEXT.md writes and injects sync reminder
- [ ] AC6: Hooks execute in <500ms each (no network calls in sync path)
- [ ] AC7: Scripts handle missing files gracefully (no errors in fresh project)
- [ ] AC8: Old settings.json backed up as .claude/settings.json.v2-backup
- [ ] AC9: All hook output is valid JSON (tested with `jq .`)
- [ ] AC10: Hooks work in default permission mode

## 9.1 Spec Compliance Checklist

| # | AC | Verification | Expected |
|---|---|---|---|
| 1 | Hook dir exists | `ls .tad/hooks/` | 2 .sh files + lib/ |
| 2 | settings.json native | `jq .hooks .claude/settings.json` | Non-null |
| 3 | Startup hook works | Start new session, check for health output | Health summary visible |
| 4 | HANDOFF detection | Write test HANDOFF → check reminder | "Expert review MANDATORY" |
| 5 | NEXT.md detection | Edit NEXT.md → check reminder | "Linear sync may be needed" |
| 6 | Performance | `time bash .tad/hooks/startup-health.sh < test.json` | <500ms |
| 7 | Missing files | Run in empty dir | No errors, graceful defaults |
| 8 | Backup exists | `ls .claude/settings.json.v2-backup` | File exists |
| 9 | JSON valid | Pipe each script output to `jq .` | Valid JSON |
| 10 | Default mode | Run hooks without bypass | Hooks fire |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **Hook keys are PascalCase**: `PostToolUse`, `PreToolUse`, `SessionStart`
- ⚠️ **Backup settings.json FIRST**: Old format is not recoverable from hooks format
- ⚠️ **async: true on PostToolUse**: Non-blocking — don't wait for script completion
- ⚠️ **jq is required**: Verify `which jq` before starting
- ⚠️ **SessionStart test requires new session**: Blake must ask user to start new terminal

### 10.2 ⚠️ SYNC WARNING
**Do NOT run `*sync` until Phase 5.** Hook scripts in `.tad/hooks/` and settings.json in `.claude/` are both in sync scope. Syncing before all hooks are tested will push untested hooks to downstream projects.

### 10.3 Rollback Plan
If hooks cause session issues: `cp .claude/settings.json.v2-backup .claude/settings.json`
Kill switch: Add `exit 0` as first line of any problematic hook script.

### 10.4 Known Constraints
- PostToolUse hook receives tool_input as JSON → file path may be nested (e.g., `tool_input.file_path` or `tool_input.content`)
- Exact field names depend on tool (Write vs Edit have different schemas) — check spike evidence in `.tad/spike-v3/exp1-command-hook/stdin-dump.txt`
- Linear sync NOT in this phase (network call would violate <500ms requirement) — will be added in Phase 4 or as separate async hook

---

---

## Expert Review Status

| Expert | Assessment | P0 Found | P0 Fixed |
|--------|-----------|----------|----------|
| code-reviewer | CONDITIONAL PASS → PASS | 3 | 3 |
| backend-architect | CONDITIONAL PASS → PASS | 3 | 3 |

### P0 Issues Fixed
1. `hookSpecificOutput` wrapper added to all output specs (was missing)
2. `tool_input.file_path` extraction path clarified for Write/Edit
3. SessionStart `source` field made defensive (check exists, fallback to always-run)
4. jq dependency: pre-flight check + grep/sed fallback strategy
5. Sync warning added: no `*sync` before Phase 5

### P1 Issues Addressed
- `permissions` section added to settings.json
- Rollback plan documented
- Async additionalContext verification added to test plan
- Wording clarified (2 hooks + 1 lib, not "3 hook scripts")

**Final Status**: Expert Review Complete — Ready for Implementation

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-31
**Version**: 3.1.0
