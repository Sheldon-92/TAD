# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-23
**Project:** TAD Framework
**Task ID:** TASK-20260323-006
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260323-superpowers-tactical-upgrades.md (Phase 5/5)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Optional worktree step + finishing workflow |
| Components Specified | ✅ | All content pre-written |
| Functions Verified | ✅ | Blake develop_command insertion point verified |
| Data Flow Mapped | ✅ | *develop --worktree → branch → implement → finish options |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Optional git worktree support in Blake's `*develop` command. When invoked with `--worktree`, Blake creates an isolated worktree branch for implementation, keeping main branch clean. On completion, offers 4 finishing options: merge, PR, keep, discard.

### 1.2 Why
**业务价值**：Worktrees provide branch isolation during implementation. If something goes wrong, main is untouched. Complements Terminal Isolation (design/execution separation) with branch isolation (implementation/main separation).

### 1.3 Intent Statement

**不是要做的**：
- ❌ 不是强制所有 *develop 使用 worktree（可选 --worktree 参数）
- ❌ 不是自动检测 .worktrees/ 目录（Superpowers 模式，太侵入）
- ❌ 不是修改 Gate 3/4 流程（worktree 是实现细节，Gate 不需要知道）

---

## 📚 Project Knowledge

Read `.tad/project-knowledge/architecture.md`.

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: `tad-blake.md` develop_command gains optional `--worktree` parameter handling
- FR2: When `--worktree` used: create `tad/{task-id}` branch + worktree before implementation
- FR3: On completion (after Layer 2 pass): offer 4 finishing options via AskUserQuestion
- FR4: Finishing options: merge to current branch / create PR / keep worktree / discard
- FR5: Worktree cleanup on merge or discard
- FR6: config.yaml gains `optional_features.git_worktree` section (enabled: true, default ON since opt-in via parameter)

### 3.2 Non-Functional Requirements
- NFR1: `--worktree` is optional — without it, *develop works exactly as before
- NFR2: Blake file increase ≤40 lines
- NFR3: No external dependencies (git worktree is built-in to git)

---

## 4. Technical Design

### 4.1 develop_command Worktree Steps

Add `1_7_worktree_setup` after `1_6_tdd_check` and `step3d_worktree_finish` after `step3c` (git commit):

```yaml
      1_7_worktree_setup:
        description: "Optional: create git worktree for isolated implementation"
        trigger: "*develop --worktree [task-id]"
        action: |
          1. Only runs if --worktree flag is present. Skip otherwise.
          2. Derive branch name: tad/{task-id} (e.g., tad/TASK-20260323-006)
          3. Create worktree:
             git worktree add .worktrees/tad-{task-id} -b tad/{task-id}
          4. Ensure .worktrees/ is in .gitignore (add if missing)
          5. Announce: "Worktree created at .worktrees/tad-{task-id} on branch tad/{task-id}"
          6. All subsequent implementation happens in the worktree directory
        skip_if: "--worktree flag not present"

      # ... (existing steps 2_layer1_loop through 4_gate3_v2 remain unchanged) ...
      # NOTE: When worktree is active, ALL steps (Layer 1, Layer 2, completion_protocol)
      # run INSIDE the worktree directory. Blake must ensure working directory is
      # .worktrees/tad-{task-id}/ throughout implementation and commit phases.

      5_worktree_finish:
        description: "Worktree finishing workflow — only runs if worktree was created"
        trigger: "After 4_gate3_v2 completes, if worktree is active"
        action: |
          Only runs if 1_7_worktree_setup was executed. Skip otherwise.

          Use AskUserQuestion:
          question: "Implementation complete in worktree. How to proceed?"
          options:
            - "Merge to {original_branch}" → cd to original repo, git merge tad/{task-id}, cleanup
            - "Create PR" → git push -u origin tad/{task-id}, suggest gh pr create
            - "Keep worktree" → leave as-is for manual review
            - "Discard" → cleanup worktree and delete branch

          Cleanup (for merge and discard):
            git worktree remove .worktrees/tad-{task-id}
            git branch -d tad/{task-id}  # -d (safe delete) for merge, -D (force) for discard

          Edge cases:
            - If merge conflicts → PAUSE, ask user to resolve manually
            - If branch tad/{task-id} already exists at setup → ask user: reuse or rename
            - Ensure .gitignore check targets root .gitignore (not subdirectory)
        skip_if: "no worktree active"
```

### 4.2 config.yaml Addition

Add under `optional_features` (after the existing `tdd_enforcement`):

```yaml
  git_worktree:
    enabled: true  # Worktree support available (triggered by --worktree flag)
    description: "When *develop --worktree is used, creates isolated branch for implementation"
    worktree_dir: ".worktrees"
    branch_prefix: "tad/"
```

### 4.3 Blake Commands Update

Update the commands section to document the --worktree option:

```yaml
  develop: "Execute implementation using Ralph Loop (add --worktree for branch isolation)"
```

---

## 6. Implementation Steps（分Phase）

### Phase 1: Config (预计 5 分钟)
1. Search for `tdd_enforcement` in `config.yaml` → add `git_worktree` section after it (from Section 4.2)

### Phase 2: Blake develop_command (预计 25 分钟)
1. Search for `1_6_tdd_check` in `develop_command.steps` → add `1_7_worktree_setup` after it (from Section 4.1)
2. Search for `4_gate3_v2` in `develop_command.steps` → add `5_worktree_finish` after it (from Section 4.1)
3. Add a note in `completion_protocol` that when worktree is active, all steps run inside the worktree directory
4. Search for `develop:` in the top-level `commands:` section (near line ~201, NOT `develop_command` or `agent_team_develop`) → update description to mention `--worktree`
4. Search for Blake's Quick Reference `*develop` entry → add `--worktree` option note

---

## 7. File Structure

### 7.1 Files to Modify
```
.tad/config.yaml                    # Add optional_features.git_worktree
.claude/commands/tad-blake.md       # Add worktree setup + finish steps + command docs
```

---

## 9. Acceptance Criteria

- [ ] AC1: `config.yaml` has `optional_features.git_worktree` section with `enabled: true`
- [ ] AC2: `tad-blake.md` has `1_7_worktree_setup` step after `1_6_tdd_check`
- [ ] AC3: `tad-blake.md` has `5_worktree_finish` step after `4_gate3_v2` in `develop_command.steps`
- [ ] AC4: Worktree setup only triggers with `--worktree` flag (skip_if documented)
- [ ] AC5: Finish workflow offers 4 options (merge/PR/keep/discard) via AskUserQuestion
- [ ] AC6: Cleanup logic specified for merge and discard options
- [ ] AC7: `.worktrees/` added to `.gitignore` check in setup step
- [ ] AC8: Blake commands section documents `--worktree` option
- [ ] AC9: All modified YAML files valid
- [ ] AC10: Without `--worktree`, existing *develop flow is completely unchanged

---

## 10. Important Notes

- ⚠️ `--worktree` is OPT-IN per invocation. Not a config toggle (config just enables the capability).
- ⚠️ Do NOT change Layer 1, Layer 2, or Gate 3 logic. Worktree is transparent to quality checks.
- ⚠️ Use `-d` (safe delete) for merge cleanup, `-D` (force delete) only for discard.
- ⚠️ If the repo is not a git repo, worktree setup should gracefully skip with a warning.

---

## Expert Review Status

| Expert | Verdict | P0 | P0 Fixed | P1 Integrated | Overall |
|--------|---------|----|----|---------|---------|
| code-reviewer | CONDITIONAL PASS | 2 | 2 ✅ | 3/4 | PASS |

### P0 Fixed
1. **step3c doesn't exist in develop_command.steps** → Changed to `5_worktree_finish` after `4_gate3_v2`
2. **Working directory context** → Added note that all steps run inside worktree directory when active

### P1 Integrated
- Branch already exists → edge case added (ask user: reuse or rename)
- Merge conflicts → PAUSE and ask user
- `.gitignore` check → specified root .gitignore

**Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-23
**Version**: 3.1.0 (post-expert-review)
