# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-03
**Project:** TAD Framework
**Task ID:** TASK-20260303-001
**Handoff Version:** 3.1.0
**Epic:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-03-03
**Expert Review**: code-reviewer + backend-architect — 5 P0 identified, ALL fixed

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Two-layer: step3c (commit before Gate 3) + step0_git_check (*accept safety net) |
| Components Specified | ✅ | 4 files, exact line ranges and YAML keys specified |
| Functions Verified | ✅ | All target YAML keys verified to exist in current files |
| Data Flow Mapped | ✅ | step3c commit → Gate 3 verifies hash → completion report → *accept reads → verify |
| Expert Review Complete | ✅ | 2 experts, 5 P0 all resolved (ordering, format, scope, anchor, naming) |
| P0 Issues Resolved | ✅ | All 5 P0 integrated into revised Section 4 |

**Gate 2 结果**: ✅ PASS (post-expert-review)

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。Expert review P0 all resolved.

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 所有"强制问题回答（MQ）"都有证据
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 每个Phase的交付物和证据要求都清楚
- [ ] 确认可以独立使用本文档完成实现

❌ 如果任何部分不清楚，**立即返回Alex要求澄清**，不要开始实现。

---

## 1. Task Overview

### 1.1 What We're Building
Two-layer git commit verification to prevent code loss during TAD workflow:
- **Layer 1 (Primary)**: Blake auto-commits BEFORE Gate 3 (so Gate 3 can verify the commit)
- **Layer 2 (Safety net)**: Alex checks `git status` before `*accept` archives

### 1.2 Why We're Building It
**业务价值**：Prevent code loss — real incident where 9 handoffs passed Gate 3+4, got archived, but code was never committed. 20/56 changes lost.
**用户受益**：Implementation work is always preserved in git history
**成功的样子**：Gate 3 执行前代码自动 commit，Gate 3 验证 commit hash，*accept 时如果有未 commit 变更会被 BLOCK

### 1.3 Intent Statement

**真正要解决的问题**：TAD workflow 完全没有 git commit 检查点 — Gate 3 只检查技术质量，*accept 只做归档。整个流程假设代码已经被 commit，但从不验证。

**不是要做的（避免误解）**：
- ❌ 不是要改 git workflow（不涉及 branching 策略）
- ❌ 不是要添加 CI/CD 集成
- ❌ 不是要修改 Ralph Loop 内部（Layer 1/Layer 2 审查流程不变）

**Blake请确认理解**：
```
在开始实现前，请用你自己的话回答：
1. 这个功能解决什么问题？
2. Gate 3 通过后会发生什么新行为？
3. *accept 命令会增加什么新检查？

只有Human确认你的理解正确后，才能开始实现。
```

---

## 📚 Project Knowledge（Blake 必读）

**⚠️ MANDATORY READ — Blake 在开始实现前，必须执行以下 Read 操作：**
1. Read ALL `.tad/project-knowledge/*.md` files listed below
2. Read the handoff's "⚠️ Blake 必须注意的历史教训" entries carefully
3. This is NOT optional — project knowledge prevents repeated mistakes

### 步骤 1：识别相关类别

本次任务涉及的领域：
- [x] architecture - 架构决策（YAML structure awareness, mode addition checklist）
- [x] code-quality - 代码模式（if exists）

### 步骤 2：历史经验摘录

**已读取的 project-knowledge 文件**：

| 文件 | 相关记录数 | 关键提醒 |
|------|-----------|----------|
| architecture.md | 3 条 | YAML structure awareness, Mode Addition Checklist, Minimal Viable Cross-Cutting |

**⚠️ Blake 必须注意的历史教训**：

1. **YAML structure awareness** (来自 architecture.md - Context Refresh Protocol)
   - 问题：Protocol files mix flat (`step1: "string"`) and nested (`step1: { name, action }`) YAML formats
   - 解决方案：New insertions must match surrounding context exactly

2. **Mode Addition Checklist Pattern** (来自 architecture.md)
   - 问题：Adding a new feature requires multi-layer integration (config + protocol + router + surface)
   - 解决方案：Check all layers: protocol file, config file, gate file, CLAUDE.md routing table

3. **Minimal Viable Cross-Cutting Enhancement** (来自 architecture.md)
   - 问题：Cross-cutting concerns can over-expand (initial 9 nodes trimmed to 2+1)
   - 解决方案：Target the 2 most impactful nodes. Don't over-engineer.

### Blake 确认

- [ ] 我已阅读上述历史经验
- [ ] 我理解 YAML 格式一致性要求
- [ ] 我会匹配现有 step 格式插入新步骤

---

## 2. Background Context

### 2.1 Previous Work
- Gate 3 v2 defined in `tad-blake.md:524-547` (my_gates) and `tad-blake.md:463-469` (4_gate3_v2 in Ralph Loop)
- *accept command defined in `tad-alex.md:1662-1741` (accept_command)
- Gate 3 checks in `tad-gate.md:89-188` (Gate 3 section)
- Gate quality config in `config-quality.yaml:113-184` (gate3_v2_implementation_integration)

### 2.2 Current State
- Gate 3 checks: Layer 1 verification, Layer 2 verification, evidence, knowledge assessment — **no git check**
- *accept steps: archive handoff, archive completion report, epic update, update docs — **no git check**
- Completion protocol: step1-step9 — **no git commit step**

### 2.3 Dependencies
- No external dependencies. All changes are to TAD framework protocol files (YAML-in-markdown).

---

## 3. Requirements

### 3.1 Functional Requirements
- **FR1**: BEFORE Gate 3 v2 executes, Blake MUST commit all implementation changes to git (so Gate 3 can verify)
- **FR2**: Commit message auto-generated: `feat(TAD): implement {handoff-slug} [Gate 3 passed]`
- **FR3**: Before *accept archives a handoff, Alex MUST check `git status` for uncommitted changes
- **FR4**: If uncommitted changes exist at *accept time, BLOCK archiving with clear error message

### 3.2 Non-Functional Requirements
- **NFR1**: Git commit step must not break existing completion protocol flow
- **NFR2**: *accept git check must not false-positive on .gitignore'd files or unrelated changes
- **NFR3**: Both layers must be clearly documented as BLOCKING checks

---

## 4. Technical Design

### 4.1 Architecture Overview

```
Blake Flow (tad-blake.md):
  Ralph Loop (Layer 1 + Layer 2) → Acceptance Verification (step3b)
    → NEW: step3c_git_commit (auto-commit BEFORE Gate 3)
    → step4: Gate 3 v2 (can now verify commit hash)
    → step5: completion-report.md (records commit hash)
    → step8: message to Alex (includes commit hash)

Alex Flow (tad-alex.md):
  *accept invoked
    → NEW: step0_git_check (verify no uncommitted changes)
    → step1: archive handoff (existing)
    → step2-5: remaining steps (existing)
```

**Key ordering**: Commit (step3c) happens BEFORE Gate 3 (step4), so Gate 3 can verify the commit exists. This resolves the chicken-and-egg problem identified in expert review.

### 4.2 Layer 1: Blake Git Commit (BEFORE Gate 3)

**Insert location**: `completion_protocol` — new `step3c` between existing step3b and step4

The `completion_protocol` section uses **flat string format** (e.g., `step4: "description"`). The new step MUST match this format.

**New step to insert**:
```yaml
step3c: "Git commit: 执行 git add（opt-out 策略：包含所有变更，排除 .tad/active/handoffs/ 和 .tad/logs/）→ 自动生成 commit message（格式：feat(TAD): implement {handoff-slug} [Gate 3 pending]）→ git commit → 记录 commit hash。如果无变更（doc-only handoff）→ WARN 并记录 commit_hash: NONE。如果 git 命令失败（pre-commit hook、权限等）→ 修复并重试，3 次失败后 escalate to human。"
```

**Commit scope design (opt-out strategy — P0-1 fix from expert review)**:
- `git add` ALL modified and untracked files by default
- Explicitly EXCLUDE only: `.tad/active/handoffs/` (managed by *accept) and `.tad/logs/`
- This is safer than opt-in (listing specific files) because it catches new files Blake created during implementation that weren't in the original handoff file list
- `.gitignore` rules still apply automatically

**Commit message format**:
- Format: `feat(TAD): implement {handoff-slug} [Gate 3 pending]`
- `{handoff-slug}` = filename slug extracted from `HANDOFF-{date}-{slug}.md` (e.g., `git-commit-verification`)
- Body: brief list of key changes (3-5 items from implementation summary)

**No-changes case**:
- If `git status` shows no changes after opt-out filtering → WARN, do not block
- Record in completion report: `commit_hash: "NONE - no implementation changes (doc-only or already committed)"`
- Gate 3 Git_Commit_Verification will accept `NONE` for doc-only handoffs

**Also add to `my_gates.gate3_v2.items`** — new section after `knowledge_assessment`, BEFORE `blocking: true`:

```yaml
      git_commit_verification:
        - "Implementation changes committed to git (or NONE for doc-only)"
        - "Commit hash recorded in completion report"
```

**Also add to Ralph Loop `4_gate3_v2.items`**:

```yaml
- "Implementation changes committed to git (step3c)"
```

**Update `step8_generate_message` template** — add after the `Status:` line:

```
    Git Commit: {commit_hash}
```

### 4.3 Layer 2: Alex *accept Git Safety Net

**Insert location**: `accept_command.steps` — new `step0_git_check` before existing step1

The `accept_command.steps` uses **nested format** with `action:` strings. Match this style.

```yaml
    step0_git_check:
      action: "Git status safety net — 检查是否有未 commit 的变更"
      details: |
        Before archiving, verify implementation code is committed:
        1. Run `git status --porcelain`
        2. If output is empty → PASS, proceed to step1
        3. If output is non-empty:
           a. Display the list of uncommitted changes
           b. BLOCK: "⚠️ 发现未 commit 的变更。归档前必须先 commit 代码。"
           c. Use AskUserQuestion:
              question: "检测到未 commit 的文件变更，无法归档。请先处理："
              options:
                - "我去 Terminal 2 让 Blake commit" → BLOCK, remain in *accept (user returns after commit)
                - "这些变更与本次 handoff 无关，继续归档" → proceed with WARNING in completion report
                - "取消 *accept" → Abort entirely
           d. If user chooses "无关":
              → Log WARNING to completion report: "User override: uncommitted changes deemed unrelated"
              → List the specific files that were overridden
              → Proceed to step1
           e. Otherwise → remain BLOCKED until resolved
      blocking: true
      purpose: "Safety net — catches cases where Blake's step3c was skipped or failed"
```

### 4.4 Gate 3 Protocol Update (tad-gate.md)

**Insert location**: AFTER `Risk_Translation` block (line ~194), BEFORE the code fence closes

Rationale for ordering: Risk Translation assesses what was changed; Git Commit Verification confirms those changes are persisted. Logically, assess first, then verify persistence.

Use the **same field naming pattern** as existing blocks (`if_missing` / `if_exists`):

```yaml
# ⚠️ GIT COMMIT VERIFICATION CHECK (BLOCKING)
Git_Commit_Verification:
  check: "Implementation changes committed to git?"
  method: "Check completion report for commit hash, AND verify via git log"

  if_missing:
    action: "BLOCK Gate 3"
    message: |
      ⚠️ Gate 3 无法通过 - 实现代码未 commit

      Blake 必须在 Gate 3 之前执行 git commit (step3c)。
      请执行 step3c (Git Commit Implementation) 然后重新执行 Gate 3。

  if_exists:
    checks:
      - "commit_hash is not empty and not 'NONE' (unless doc-only handoff)"
      - "If commit_hash is a real hash: verify via `git log --oneline -1 {hash}` returns valid output"
      - "If commit_hash is 'NONE': verify handoff has no 'Files to Create/Modify' entries (truly doc-only)"
    on_valid: "PASS"
    on_invalid: "BLOCK - commit hash not found in git history or doc-only claim invalid"
```

### 4.5 Config Quality Update (config-quality.yaml)

**Insert location**: `gate3_v2_implementation_integration` — add after `knowledge_assessment` (line ~183), BEFORE `human_trigger` (line ~185)

Note: The key `evidence_verification` does NOT exist in this file. The correct anchor is `knowledge_assessment`.

```yaml
    git_commit_verification:
      required: true
      checks:
        - "Implementation changes committed (commit hash in completion report)"
        - "Commit verified via git log (or NONE accepted for doc-only)"
```

---

## 5. 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
- [x] 是 — 搜索了现有 git 相关逻辑
- **搜索命令**: `Grep "git" tad-blake.md, tad-alex.md, tad-gate.md`
- **结果**: 零 git commit 验证逻辑存在于任何 Gate 或 *accept 流程中
- **决定**: ✅ 创建新的 — 无现有实现可复用

### MQ2: 函数存在性验证

| YAML Key | 文件位置 | 验证 |
|----------|---------|------|
| `completion_protocol.step3b` | tad-blake.md:637 | ✅ 存在 — 新 step3c 插入其后 |
| `completion_protocol.step4` | tad-blake.md:638 | ✅ 存在 — step3c 在其前，不影响 |
| `my_gates.gate3_v2.items.knowledge_assessment` | tad-blake.md:543-546 | ✅ 存在 — 新 git_commit section 插入其后，`blocking: true` 之前 |
| `4_gate3_v2.items` | tad-blake.md:465-469 | ✅ 存在 — 追加一行 |
| `step8_generate_message` | tad-blake.md:643-679 | ✅ 存在 — Status 行后追加 Git Commit 行 |
| `accept_command.steps.step1` | tad-alex.md:1671 | ✅ 存在 — 新 step0 插入其前 |
| `Risk_Translation` (end) | tad-gate.md:163-194 | ✅ 存在 — 新 block 插入其后 |
| `gate3_v2.knowledge_assessment` | config-quality.yaml:176-183 | ✅ 存在 — 新 git section 插入其后，`human_trigger` 之前 |

### MQ3: 数据流完整性

不涉及前后端数据流。这是框架协议修改，数据流为：
```
Gate 3 PASS → commit hash → completion report → *accept reads → verify
```

### MQ5: 状态同步

**单一状态**: commit hash 只存储在 completion report 中。
Gate 3 写入 → *accept 读取验证。无同步问题。

---

## 6. Implementation Steps

### Phase 1: Blake Git Commit + Gate 3 Update (tad-blake.md)

#### 交付物
- [ ] `completion_protocol.step3c` added (git commit step — BEFORE Gate 3)
- [ ] `my_gates.gate3_v2.items.git_commit_verification` added
- [ ] `4_gate3_v2.items` updated with git commit line
- [ ] `step8_generate_message` format updated to include commit hash

#### 实施步骤
1. Read `tad-blake.md` — locate `completion_protocol` section (~line 632)
2. Insert `step3c` between existing step3b (line 637) and step4 (line 638)
   - Match YAML format: `step3c: "描述"` (flat string, matching step3b/step4 style)
   - IMPORTANT: completion_protocol uses flat format (`step4: "string"`), not nested format
3. Read `my_gates.gate3_v2.items` section (~line 529)
4. Add `git_commit_verification` subsection after `knowledge_assessment` (line 546), BEFORE `blocking: true` (line 547)
   - Match YAML format: nested with list items (matching surrounding style)
5. Read Ralph Loop `4_gate3_v2.items` (~line 465)
6. Add one line: `- "Implementation changes committed to git (step3c)"`
7. Update `step8_generate_message` template to include `Git Commit: {hash}` line after `Status:` line

#### 验证方法
- Read the modified file — verify YAML structure is valid
- Verify step ordering: step3b → step3c → step4 (commit BEFORE Gate 3)
- Verify no existing steps were accidentally modified

### Phase 2: Alex *accept Safety Net (tad-alex.md)

#### 交付物
- [ ] `accept_command.steps.step0_git_check` added
- [ ] `accept_command.prerequisite` updated to mention git check

#### 实施步骤
1. Read `tad-alex.md` — locate `accept_command.steps` (~line 1670)
2. Insert `step0_git_check` BEFORE existing step1 (line 1671)
   - Match YAML format: nested with name/action (matching step1/step2 style)
   - IMPORTANT: accept_command steps use `action: "string"` format
3. Update prerequisite section to include git check mention
4. Add "verify git status" to `accept_command` output template

#### 验证方法
- Read the modified file — verify YAML structure
- Verify step0 appears before step1
- Verify step0 references AskUserQuestion for user override

### Phase 3: Gate Protocol & Config (tad-gate.md + config-quality.yaml)

#### 交付物
- [ ] `Git_Commit_Verification` block added to tad-gate.md Gate 3 section
- [ ] `git_commit_verification` added to config-quality.yaml gate3_v2 items

#### 实施步骤
1. Read `tad-gate.md` — locate Gate 3 section, `Acceptance_Verification` block (~line 138)
2. Insert `Git_Commit_Verification` block AFTER `Risk_Translation` (~line 194)
   - Match YAML format: same pattern as existing check blocks (check/if_missing/if_exists)
3. Read `config-quality.yaml` — locate `gate3_v2_implementation_integration` (~line 113)
4. Add `git_commit_verification` section after `knowledge_assessment` (~line 183), BEFORE `human_trigger` (~line 185)
   - Match format: `required: true` + `checks:` list

#### 验证方法
- Read both modified files — verify YAML structure
- Verify new blocks follow existing naming pattern
- Verify blocking behavior is correctly specified

---

## 7. File Structure

### 7.1 Files to Create
```
(none — all modifications to existing files)
```

### 7.2 Files to Modify
```
.claude/commands/tad-blake.md    # Phase 1: step3c commit (before Gate 3), gate3 items, ralph loop items
.claude/commands/tad-alex.md     # Phase 2: step0_git_check in *accept
.claude/commands/tad-gate.md     # Phase 3: Git_Commit_Verification block
.tad/config-quality.yaml         # Phase 3: gate3_v2 git_commit item
```

---

## 8. Testing Requirements

### 8.1 Scenario Test: Reproduce the Bug
Simulate the original failure scenario:
1. Start with uncommitted changes in working directory
2. Run `/gate 3` — should now require commit hash in completion report
3. Run `*accept` — should BLOCK with "未 commit" warning
4. Commit the changes
5. Run `*accept` again — should PASS

### 8.2 Edge Cases
- **No changes to commit** (doc-only handoff): step3c should WARN but not block, record commit_hash: NONE
- **User override at *accept**: "与本次无关" option should allow proceeding with WARNING
- **Pre-commit hook failure**: step3c should handle and retry (3 attempts max)

### 8.3 YAML Validation
- All 4 modified files must remain valid YAML-in-markdown
- No existing functionality broken (compare step counts before/after)

---

## 9. Acceptance Criteria

Blake的实现被认为完成，当且仅当：
- [ ] AC1: `tad-blake.md` contains `step3c` in completion_protocol (git commit BEFORE Gate 3)
- [ ] AC2: `tad-blake.md` gate3_v2 items include `git_commit_verification`
- [ ] AC3: `tad-alex.md` accept_command has `step0_git_check` before step1
- [ ] AC4: `tad-alex.md` step0_git_check BLOCKs when uncommitted changes detected
- [ ] AC5: `tad-gate.md` Gate 3 section includes `Git_Commit_Verification` check block (after Risk_Translation)
- [ ] AC6: `config-quality.yaml` gate3_v2 includes `git_commit_verification` section (after knowledge_assessment)
- [ ] AC7: All 4 files maintain valid YAML-in-markdown structure
- [ ] AC8: Auto-generated commit message format: `feat(TAD): implement {slug} [Gate 3 pending]`
- [ ] AC9: User override exists in *accept (for changes unrelated to handoff)
- [ ] AC10: No existing steps/checks removed or reordered

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ YAML format consistency: completion_protocol uses FLAT format (`step4: "string"`), my_gates uses NESTED format. Match each section's style exactly.
- ⚠️ Do NOT renumber existing steps (step1→step9). Insert as step3c and step0 to avoid breaking references.
- ⚠️ tad-gate.md uses markdown code blocks with YAML inside — insertions must be within the correct code fence.

### 10.2 Known Constraints
- Blake operates in Terminal 2 — git commands are available
- `git status --porcelain` is the canonical way to check for changes (machine-readable output)
- Alex operates in Terminal 1 — also has git access for the safety net check

### 10.3 Sub-Agent使用建議
- [ ] **code-reviewer** — after all changes, review YAML structure consistency
- [ ] **test-runner** — verify no syntax errors in modified files

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Commit scope | All changes / Handoff files only / Opt-out (all minus exclusions) | Opt-out (exclude .tad/active/handoffs/ and .tad/logs/) | Catches new files Blake created; safer than opt-in |
| 2 | *accept failure | BLOCK / WARN / AskUser | BLOCK + AskUser override | Safest default with escape hatch for false positives |
| 3 | Commit message | Auto-generate / User edit / Fixed format | Auto-generate | No human input needed, consistent format |

---

## Expert Review Status

| Expert | Status | P0 Issues | Findings |
|--------|--------|-----------|----------|
| code-reviewer | ✅ CONDITIONAL PASS → P0 Fixed | 3 P0 (ordering paradox, YAML format, config anchor) | 4 P1, 4 P2 — all P0 integrated into revised Section 4 |
| backend-architect | ✅ CONDITIONAL PASS → P0 Fixed | 3 P0 (ordering paradox, opt-in scope, field naming) | 4 P1, 3 P2 — all P0 integrated into revised Section 4 |

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-03
**Version**: 3.1.0
