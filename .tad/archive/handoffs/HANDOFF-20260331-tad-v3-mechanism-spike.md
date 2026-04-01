# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-31
**Project:** TAD Framework
**Task ID:** TASK-20260331-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260331-tad-v3-hook-native-rebuild.md (Phase 0/5)
**Linear:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-03-31

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Spike scope well-defined: 7 experiments to validate Claude Code mechanisms |
| Components Specified | ✅ | Each experiment has clear input/expected output (expert review: 6 P0 fixed) |
| Functions Verified | ✅ | No existing functions to verify — spike creates new test files |
| Data Flow Mapped | N/A | Spike does not involve data flow |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个 Experiment 的预期结果和验证方法都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
A mechanism validation spike that tests 5 Claude Code native mechanisms to confirm they work as documented in source code analysis. Each experiment creates minimal test artifacts, validates behavior, and documents findings.

### 1.2 Why We're Building It
**业务价值**：This spike de-risks the TAD v3.0 rebuild (the largest upgrade in TAD history). Without validating these mechanisms, we could design an architecture that doesn't actually work.

**成功的样子**：When we have documented evidence that each mechanism works (or doesn't), with specific capabilities and limitations noted, so Phase 1 (Architecture Blueprint) can proceed with confidence.

### 1.3 Intent Statement

**真正要解决的问题**：We've read Claude Code's source code extensively, but reading source ≠ verified behavior. This spike bridges that gap.

**不是要做的（避免误解）**：
- ❌ Not implementing TAD v3.0 — just validating mechanisms
- ❌ Not modifying any existing TAD files — all experiments in a new test directory
- ❌ Not writing permanent hooks — experiments are disposable
- ❌ Not optimizing or performance testing — just "does it work?"

---

## 📚 Project Knowledge（Blake 必读）

### 步骤 1：识别相关类别
- [x] architecture - Architecture decisions (Hook/Skill/Context patterns from Claude Code source study)

### 步骤 2：历史经验摘录

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 2 条 | "Measure Before Optimizing" (spike-driven pivot pattern), "Embed Into Existing Flows" |

**⚠️ Blake 必须注意的历史教训**：

1. **Measure Before Optimizing** (来自 architecture.md, 2026-03-23)
   - 问题：Assumed TAD needed optimization, but spike found context footprint was only 8.5%
   - 解决方案：Always measure actual baseline. Include explicit pivot thresholds.
   - **应用到本次**：Each experiment must have explicit PASS/FAIL criteria. If a mechanism doesn't work as expected, document the actual behavior — don't force it.

---

## 2. Background Context

### 2.1 Previous Work
Deep analysis of Claude Code leaked source code (2026-03-31). Key files studied:
- `src/hooks/` — Hook system (26 events, 4 types)
- `src/skills/loadSkillsDir.ts` — Skill loading and frontmatter
- `src/context.ts` + `src/utils/claudemd.ts` — Context assembly
- `src/constants/prompts.ts` — System prompt structure

### 2.2 Current State
TAD v2.6.0 uses prompt-based constraints exclusively. No hooks, no skill frontmatter optimization, no settings-based permissions. This spike validates the mechanisms needed for v3.0.

### 2.3 Dependencies
- Claude Code CLI (current installed version)
- The TAD project directory (experiments run here)

### 2.4 Source Reference
Claude Code leaked source at: `/Users/sheldonzhao/01-on progress programs/claude-code-leaked/src/`
You can reference this for implementation details, but the goal is to TEST behavior, not just read code.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Validate 7 Claude Code mechanisms via isolated experiments
- FR2: Document actual behavior for each mechanism (not just "it works")
- FR3: Record any discrepancies between source code reading and actual behavior
- FR4: Produce a spike report with Mechanism Capability Matrix for Phase 1 consumption

---

## 4. Technical Design

### 4.1 Experiment Directory Structure
```
.tad/spike-v3/
├── README.md                    # Spike report (final output)
├── exp1-command-hook/           # Experiment 1
│   ├── setup.md                 # How to configure
│   ├── hook-script.sh           # The hook script
│   └── result.md                # What happened
├── exp2-prompt-hook/            # Experiment 2
│   ├── setup.md
│   └── result.md
├── exp3-skill-frontmatter/      # Experiment 3
│   ├── test-skill/
│   │   └── SKILL.md
│   └── result.md
├── exp4-posttool-context/       # Experiment 4
│   ├── hook-script.sh
│   └── result.md
└── exp5-parallel-agents/        # Experiment 5
    └── result.md
```

### 4.2 Pre-flight Checklist (MANDATORY before any experiment)

```bash
# 1. Verify jq installed
which jq || echo "INSTALL jq: brew install jq"

# 2. Backup settings.json
cp .claude/settings.json .claude/settings.json.spike-backup

# 3. Record Claude Code version
claude --version > .tad/spike-v3/claude-version.txt

# 4. Create spike directory
mkdir -p .tad/spike-v3/{exp1-command-hook,exp2-prompt-hook,exp3-skill-frontmatter,exp3b-skill-fork,exp4-session-hook,exp5-parallel-agents,exp6-skill-hooks,exp7-hook-if-condition}
```

### 4.3 Settings.json Backup/Restore Protocol (MANDATORY)

```bash
# BEFORE each experiment:
cp .claude/settings.json.spike-backup .claude/settings.json

# AFTER each experiment (verify clean state):
diff .claude/settings.json .claude/settings.json.spike-backup
# If diff shows changes → restore: cp .claude/settings.json.spike-backup .claude/settings.json

# FINAL cleanup:
cp .claude/settings.json.spike-backup .claude/settings.json
rm .claude/settings.json.spike-backup
```

### 4.4 Hook Event Key Format Note

⚠️ **CRITICAL**: Source code analysis shows hook events are defined as PascalCase (`PreToolUse`, `PostToolUse`, `SessionStart`). However, the settings parser MAY accept kebab-case (`pre-tool-use`). **Test PascalCase first. If it fails, try kebab-case. Document which format works.**

### 4.5 Seven Experiments

---

#### Experiment 1: Command Hook — PostToolUse Side Effects

**Goal**: Confirm PostToolUse command hook can (a) execute shell script, (b) read tool output from stdin, (c) write files as side effect, (d) inject additionalContext that model sees.

**Setup**:
1. Create `.tad/spike-v3/exp1-command-hook/hook-script.sh`:
```bash
#!/bin/bash
# Read JSON input from stdin
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name')
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Side effect: append to a log file
echo "[$TIMESTAMP] Tool used: $TOOL_NAME" >> .tad/spike-v3/exp1-command-hook/tool-log.txt

# Output JSON with additionalContext
cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Hook executed: logged $TOOL_NAME to tool-log.txt"
  }
}
EOF
exit 0
```

2. Add hooks to `.claude/settings.json` (MERGE into existing file, don't replace):
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash .tad/spike-v3/exp1-command-hook/hook-script.sh"
          }
        ]
      }
    ]
  }
}
```
**If PascalCase fails**: Try `"post-tool-use"` as key. Document which works.

3. Test: Read any file. Check if tool-log.txt was created. Check if model mentions the additionalContext.

**PASS Criteria**:
- [ ] hook-script.sh executes on Read tool call
- [ ] tool-log.txt contains the logged entry
- [ ] Model's response references or acknowledges the additionalContext
- [ ] JSON stdin contains tool_name and tool_input fields

**FAIL Criteria**:
- Hook doesn't execute → document error
- additionalContext not visible to model → document what happens instead

---

#### Experiment 2: Prompt Hook — Intelligent Gating with Haiku

**Goal**: Confirm a prompt-type hook can use Haiku to make context-aware allow/deny decisions.

**Setup**:
1. Add hooks to `.claude/settings.json` (MERGE):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "A tool is about to modify a file. Details:\n$ARGUMENTS\n\nRules:\n- If the file is in .tad/spike-v3/ → ALLOW (test directory)\n- If the file is a .md documentation file → ALLOW\n- If the file is a .ts or .py source file → DENY with reason 'Source files protected during spike'\n\nRespond with JSON only: {\"ok\": true} or {\"ok\": false, \"reason\": \"...\"}",
            "model": "claude-haiku-4-5-20251001",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```
**Note**: `$ARGUMENTS` substitution is assumed from source. If Haiku receives literal `$ARGUMENTS`, document this as a finding and try alternative (pipe JSON via command hook instead).

2. Test three scenarios:
   a. Write to `.tad/spike-v3/exp2-prompt-hook/test.md` → should ALLOW
   b. Write to `test-source.ts` → should DENY
   c. Edit an existing `.md` file → should ALLOW

**PASS Criteria**:
- [ ] Haiku correctly allows writes to spike directory
- [ ] Haiku correctly denies writes to .ts files
- [ ] Deny reason is shown to the model/user
- [ ] Response time < 15 seconds

**FAIL Criteria**:
- Prompt hook doesn't trigger → document
- Haiku makes wrong decision → document the prompt/response
- Timeout → increase timeout and retry

---

#### Experiment 3: Skill Frontmatter — allowedTools + model Override

**Goal**: Confirm skill frontmatter `allowed-tools` restricts available tools, and `model` overrides the active model.

**Setup**:
1. Create `.claude/skills/spike-test/SKILL.md`:
```yaml
---
description: Test skill for TAD v3.0 mechanism spike — read-only research assistant
allowed-tools:
  - Read
  - Glob
  - Grep
model: claude-haiku-4-5-20251001
context: fork
---

# Spike Test Skill

You are a read-only research assistant running in a forked context.

TASK: Test tool restrictions and model override.

1. Try to use the Write tool to create a file at .tad/spike-v3/exp3-skill-frontmatter/write-test.txt
   - If allowedTools works correctly, you should NOT be able to use Write.
2. Use the Read tool to read .tad/version.txt (should work)
3. Report:
   a. Which tools are available to you?
   b. Were you able to use Write? (expected: NO)
   c. What model are you? Try to identify yourself.
```

**Note**: Skill name derived from directory name (`spike-test`), NOT from frontmatter.
**Note**: `context: fork` is REQUIRED for `allowed-tools` to enforce tool restrictions (per expert review: inline mode uses parent's tool set).

2. Test: Invoke `/spike-test` and observe behavior.

**PASS Criteria**:
- [ ] Skill invokable via `/spike-test`
- [ ] Write tool is NOT available (blocked by allowedTools in fork mode)
- [ ] Read, Glob, Grep ARE available
- [ ] Model override takes effect (response pattern suggests Haiku, not Opus)

**FAIL Criteria**:
- Skill not discovered → check path and frontmatter format
- Write tool still available → allowedTools not enforced even in fork mode
- Model not overridden → model field doesn't work

---

#### Experiment 3b: Skill Frontmatter — inline vs fork context

**Goal**: Test the DIFFERENCE between `context: inline` and `context: fork` for tool restriction.

**Setup**:
1. Create `.claude/skills/spike-inline/SKILL.md`:
```yaml
---
description: Test inline skill — does allowedTools work without fork?
allowed-tools:
  - Read
context: inline
---

# Spike Inline Test

Try to use Write tool. Report if it works.
```

2. Test: Invoke `/spike-inline`. Does Write work?

**PASS Criteria**:
- [ ] Documented whether `allowed-tools` restricts tools in `inline` mode
- [ ] Clear comparison: fork mode behavior vs inline mode behavior

This experiment documents behavior — both outcomes are valid findings.

**FAIL Criteria**:
- Skill not discovered or errors → document the error

---

#### Experiment 4: SessionStart Hook — Startup Automation

**Goal**: Confirm SessionStart hook can run on startup, execute shell checks, and inject initialUserMessage.

**Setup**:
1. Create `.tad/spike-v3/exp4-session-hook/startup-check.sh`:
```bash
#!/bin/bash
# Quick health check
HANDOFF_COUNT=$(ls .tad/active/handoffs/HANDOFF-*.md 2>/dev/null | wc -l | tr -d ' ')
EPIC_COUNT=$(ls .tad/active/epics/EPIC-*.md 2>/dev/null | wc -l | tr -d ' ')

cat << EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "TAD Health: ${HANDOFF_COUNT} active handoffs, ${EPIC_COUNT} active epics",
    "watchPaths": [".tad/active/handoffs/", ".tad/active/epics/"]
  }
}
EOF
exit 0
```

2. Add hooks to `.claude/settings.json` (MERGE):
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .tad/spike-v3/exp4-session-hook/startup-check.sh"
          }
        ]
      }
    ]
  }
}
```

3. **⚠️ HUMAN-ASSISTED TEST**: Blake configures the hook, then instructs the user:
   - Save settings.json with the hook
   - Start a NEW Claude Code session (new terminal window, run `claude`)
   - Check if health info appears in the session
   - Report back what happened

**PASS Criteria**:
- [ ] Hook executes on session start (health info appears)
- [ ] additionalContext visible to model OR initialUserMessage delivered
- [ ] Shell script executes in < 1 second

**FAIL Criteria**:
- Hook doesn't execute → check event key format (PascalCase vs kebab-case)
- additionalContext not visible → test initialUserMessage field instead
- Script errors → check shell path and jq availability

**Note**: watchPaths testing REMOVED from this experiment (requires absolute paths and separate FileChanged verification — out of scope for spike).

---

#### Experiment 5: Parallel Agent Spawning

**Goal**: Confirm multiple Agent tool calls in a single message execute in parallel (not sequential).

**Setup**:
1. No configuration needed — use built-in Agent tool.
2. In a session, send a message that triggers multiple Agent calls:

Prompt to test:
```
I need you to research three things IN PARALLEL (use three separate Agent tool calls in a single message):
1. Agent 1: Count .md files in .tad/templates/ directory
2. Agent 2: Count .yaml files in .tad/ directory (top-level only)
3. Agent 3: Read the first 5 lines of CHANGELOG.md

IMPORTANT: All three Agent calls must be in the SAME message (parallel), not sequential.
After all three complete, report the results.
```

3. Observe: Do agents spawn simultaneously or one after another?

**PASS Criteria**:
- [ ] Three Agent tool calls issued in a single message
- [ ] All three run concurrently (observe overlapping progress indicators)
- [ ] Results from all three collected before proceeding
- [ ] Total time ≈ max(individual times), not sum

**FAIL Criteria**:
- Agents run sequentially → parallel spawning not supported in current version
- Only one Agent call per message → document limitation

---

#### Experiment 6: Per-Skill Hooks in Frontmatter

**Goal**: Confirm that skills can define their OWN hooks via frontmatter `hooks` field. This is critical for TAD v3.0 — each agent skill (alex-analyze, blake-develop) would register its own quality gate hooks.

**Setup**:
1. Create `.claude/skills/spike-hooks/SKILL.md`:
```yaml
---
description: Test per-skill hooks — does the hooks frontmatter field work?
hooks:
  PostToolUse:
    - matcher: "Read"
      hooks:
        - type: command
          command: "echo '{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":\"SKILL HOOK FIRED — this hook came from skill frontmatter, not settings.json\"}}'"
---

# Spike Hooks Test

This skill tests per-skill hooks. Use the Read tool to read any file.
If the skill's PostToolUse hook works, you should see an additionalContext message saying "SKILL HOOK FIRED".
```

2. Test: Invoke `/spike-hooks`, then use Read tool within the skill.

**PASS Criteria**:
- [ ] Skill-defined PostToolUse hook executes when Read is called inside the skill
- [ ] additionalContext from skill hook is visible
- [ ] Hook does NOT fire outside the skill (after skill exits)

**FAIL Criteria**:
- Hook doesn't fire → per-skill hooks may not be implemented in current Claude Code version
- Hook fires outside skill → hooks "leak" beyond skill scope

---

#### Experiment 7: Hook `if` Condition Filter

**Goal**: Confirm the `if` field on hooks filters execution based on tool+argument patterns.

**Setup**:
1. Add hooks to `.claude/settings.json` (MERGE):
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\":{\"hookEventName\":\"PreToolUse\",\"additionalContext\":\"IF-FILTER: git command detected\"}}'",
            "if": "Bash(git *)"
          }
        ]
      }
    ]
  }
}
```

2. Test:
   a. Run `git status` via Bash tool → hook SHOULD fire (matches `git *`)
   b. Run `ls` via Bash tool → hook should NOT fire (doesn't match)

**PASS Criteria**:
- [ ] Hook fires for `git status` (additionalContext visible)
- [ ] Hook does NOT fire for `ls`
- [ ] `if` field correctly filters based on tool argument pattern

**FAIL Criteria**:
- Hook fires for both → `if` field not filtering
- Hook fires for neither → `if` syntax wrong (try alternative patterns)

---

## 6. Implementation Steps

### Phase 1: Setup + Experiments 1-2, 7 (Hook Basics)

#### 交付物
- [ ] Pre-flight checklist completed (jq, backup, directory structure)
- [ ] Experiment 1 (command hook + PostToolUse) documented
- [ ] Experiment 2 (prompt hook + Haiku gating) documented
- [ ] Experiment 7 (hook `if` condition filter) documented
- [ ] Hook event key format determined (PascalCase or kebab-case)

#### 实施步骤 (MUST run sequentially)
1. Run pre-flight checklist
2. Experiment 1: Create hook script → configure settings.json → test → **restore settings.json** → document
3. Experiment 2: Configure prompt hook → test 3 scenarios → **restore settings.json** → document
4. Experiment 7: Configure `if` filter hook → test 2 scenarios → **restore settings.json** → document

#### 验证方法
- Each experiment has result.md with PASS/FAIL per criterion
- settings.json restored to backup state after each experiment

### Phase 2: Experiments 3-3b, 6 (Skill System)

#### 交付物
- [ ] Experiment 3 (skill frontmatter: fork + allowedTools) documented
- [ ] Experiment 3b (inline vs fork comparison) documented
- [ ] Experiment 6 (per-skill hooks in frontmatter) documented
- [ ] Test skills cleaned up

#### 实施步骤
1. Experiment 3: Create fork skill → invoke `/spike-test` → document → remove skill
2. Experiment 3b: Create inline skill → invoke `/spike-inline` → document → remove skill
3. Experiment 6: Create hooks skill → invoke `/spike-hooks` → test → document → remove skill

### Phase 3: Experiments 4-5 (SessionStart + Parallel) + Spike Report

#### 交付物
- [ ] Experiment 4 (SessionStart hook) documented (human-assisted)
- [ ] Experiment 5 (parallel agents) documented
- [ ] Spike report (README.md) with Mechanism Capability Matrix

#### 实施步骤
1. Experiment 4: Configure SessionStart hook → instruct user to start new session → document results
2. Experiment 5: Test parallel Agent spawning → document
3. Compile spike report: summary table, capability matrix, recommendation

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/spike-v3/README.md                          # Spike report
.tad/spike-v3/exp1-command-hook/hook-script.sh    # PostToolUse hook
.tad/spike-v3/exp1-command-hook/result.md         # Results
.tad/spike-v3/exp2-prompt-hook/result.md          # Results
.tad/spike-v3/exp3-skill-frontmatter/result.md    # Results
.claude/skills/spike-test/SKILL.md                # Test skill
.tad/spike-v3/exp4-session-hook/startup-check.sh  # SessionStart hook
.tad/spike-v3/exp4-session-hook/result.md         # Results
.tad/spike-v3/exp5-parallel-agents/result.md      # Results
```

### 7.2 Files to Modify (temporarily)
```
.claude/settings.json  # Add/remove test hooks (revert after each experiment)
```

**⚠️ CRITICAL**: Settings.json modifications must be REVERTED after each experiment. The spike must leave no permanent changes to TAD's configuration.

---

## 8. Testing Requirements

### 8.1 Per-Experiment Testing
Each experiment is self-testing — PASS/FAIL criteria defined in Section 4.2.

### 8.2 Cleanup Verification
- [ ] settings.json reverted to original state
- [ ] `.claude/skills/spike-test/` removed after Experiment 3
- [ ] `.tad/spike-v3/` retained as evidence (archived with handoff)

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] AC1: All 7 experiments (1, 2, 3, 3b, 4, 5, 6, 7) executed and documented
- [ ] AC2: Each experiment has clear PASS/FAIL with evidence
- [ ] AC3: Spike report (README.md) includes Mechanism Capability Matrix
- [ ] AC4: Hook event key format determined and documented (PascalCase vs kebab-case)
- [ ] AC5: Any discrepancies between source code reading and actual behavior documented
- [ ] AC6: settings.json reverted to clean state (diff against backup = empty)
- [ ] AC7: All test skills removed (`.claude/skills/spike-*` directories absent)
- [ ] AC8: Spike report includes recommendation: proceed with v3.0 as designed / pivot needed

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | All 7 experiments executed | Check .tad/spike-v3/exp*/result.md exists | 7+ result files |
| 2 | Each has PASS/FAIL | Grep for "PASS" or "FAIL" in each result.md | Clear verdict per experiment |
| 3 | Spike report compiled | Check .tad/spike-v3/README.md exists with Capability Matrix | Table with 7+ rows |
| 4 | Key format documented | Search README.md for "PascalCase" or "kebab-case" | Format determination |
| 5 | Discrepancies documented | Search for "discrepancy" or "unexpected" in README.md | Listed if any |
| 6 | Settings.json clean | `diff .claude/settings.json .claude/settings.json.spike-backup` = empty | No diff |
| 7 | Test skills removed | `ls .claude/skills/spike-*` returns not found | No test skill directories |
| 8 | Recommendation present | Search README.md for "Recommendation:" | Clear proceed/pivot statement |

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ **Do NOT modify existing TAD files** — all experiments in `.tad/spike-v3/`
- ⚠️ **Revert settings.json after EACH experiment** — hooks from one experiment may interfere with another
- ⚠️ **Experiment 4 (SessionStart)**: Requires starting a NEW Claude Code session to test. Document the steps for the user to verify manually if needed.
- ⚠️ **jq dependency**: Hook scripts use `jq` for JSON parsing. Verify `jq` is installed: `which jq`

### 10.2 Known Constraints
- This is a spike — all artifacts are disposable except the spike report
- Some experiments may require user interaction (e.g., starting new session for Exp 4)
- Prompt hook (Exp 2) requires API access to Haiku model

### 10.3 Sub-Agent使用建议
- No sub-agents needed for this spike — Blake executes directly
- Exception: Experiment 5 specifically tests Agent tool spawning

---

## 11. Learning Content

### 11.1 Decision Rationale: Why 5 Experiments, Not More

**选择的方案**：5 targeted experiments covering the most critical mechanisms

**考虑的替代方案**：

| 方案 | 优点 | 缺点 | 为什么没选 |
|------|------|------|-----------|
| 5 experiments (chosen) | Focused, fast, covers essentials | Doesn't test everything | ✅ Sufficient for Phase 1 design |
| 10+ experiments | Comprehensive | Takes too long, delays v3.0 | Overkill for spike |
| 3 experiments (hook only) | Very fast | Misses skill/parallel validation | Insufficient coverage |

**权衡分析**：Speed vs comprehensiveness. The 5 experiments cover the 3 mechanism categories (hooks, skills, agents) that v3.0 depends on.

---

---

## Expert Review Status

| Expert | Assessment | P0 Found | P0 Fixed |
|--------|-----------|----------|----------|
| code-reviewer | CONDITIONAL PASS → PASS | 3 | 3 |
| backend-architect | CONDITIONAL PASS → PASS | 3 | 3 |

### P0 Issues Found & Fixed

| # | Source | Issue | Fix Applied |
|---|--------|-------|-------------|
| 1 | backend-architect | Hook event keys may need PascalCase, not kebab-case | Added format note + "test both" instruction |
| 2 | code-reviewer | No settings.json backup/restore procedure | Added Pre-flight Checklist + Backup/Restore Protocol |
| 3 | code-reviewer | Experiment 4 not self-testable by Blake | Marked as human-assisted with explicit user instructions |
| 4 | backend-architect | `name` field in skill frontmatter doesn't exist | Removed, documented name = directory name |
| 5 | backend-architect | `allowed-tools` may only work with `context: fork` | Added `context: fork` + new Experiment 3b for comparison |
| 6 | backend-architect | Missing per-skill hooks test (critical for v3.0) | Added Experiment 6 |

### P1 Issues Addressed

| # | Source | Issue | Resolution |
|---|--------|-------|------------|
| 1 | backend-architect | Missing `if` condition filter test | Added Experiment 7 |
| 2 | code-reviewer | Exp 2 `$ARGUMENTS` substitution unverified | Added fallback note |
| 3 | backend-architect | Spike report needs capability matrix | Updated AC to require matrix |
| 4 | code-reviewer | Experiment execution order must be sequential | Added "MUST run sequentially" callout |

**Final Status**: Expert Review Complete — Ready for Implementation

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-31
**Version**: 3.1.0
