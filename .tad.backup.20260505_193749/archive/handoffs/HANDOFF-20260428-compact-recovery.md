---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".tad/hooks", ".tad/templates", ".claude/skills/blake", ".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD Compact Recovery Protocol — Session State Persistence

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-28
**Priority:** P1
**Handoff:** HANDOFF-20260428-compact-recovery.md

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-04-28 (v2 — Post Expert Review)

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 两层设计 + Status 字段 + stale 检测 |
| Components Specified | ✅ | 7 个文件，每个改动点含行锚/缩进规格 |
| Functions Verified | ✅ | sed 转义方案 + fallback + .bak 清理已验证 |
| Data Flow Mapped | ✅ | Agent 写语义 → hook 写 metadata → CLAUDE.md 触发读取 |

**Gate 2 结果**: ✅ PASS (v2)

### 专家审查 Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|--------------------|--------|
| code-reviewer | P0-1: sed $FILE_PATH escaping | §6 Task 4 重写，含 ESCAPED_PATH | Resolved |
| code-reviewer | P0-2: Last File Written fallback missing | §6 Task 4 加 grep-q append fallback | Resolved |
| code-reviewer | P0-3: && → ; for bak cleanup | §6 Task 4 全部改 ; | Resolved |
| code-reviewer | P0-4: AC8 threshold ≥1 → ≥2 | §9.1 AC8 修正 | Resolved |
| code-reviewer | P0-5: AC9 threshold 太宽松 | §9.1 AC9 改为 grep sed 行 | Resolved |
| code-reviewer | P0-6: Task 2c 无行锚无缩进 | §6 Task 2c 重写 | Resolved |
| code-reviewer | P1-4: Required Evidence Manifest 缺 self-review/feedback | §12 补充 | Resolved |
| backend-architect | P0-1: stale session-state 无检测 | §4.2 加 Status 字段；Task 3a 加 stale 检测 | Resolved |
| backend-architect | P0-3: Alex STEP 3.7 缺 Blake-DONE 分支 | Task 3a 重写 | Resolved |
| backend-architect | P0-4: *complete trigger 仅声明未实现 | 新增 Task 2d | Resolved |
| backend-architect | P1-1: Big Picture 缺 Why Now | §4.2 加第 4 字段 | Resolved |
| backend-architect | P1-2: STEP 3.7/3.6 UX 交互问题 | Task 3a 加 suppress_help 说明 | Resolved |

---

## 1. Executive Summary

**问题**：用 Sonnet 4.6 时 context compact 后，Blake/Alex 丢失身份（忘了自己是 Blake）和任务状态（忘了在执行哪个 handoff、做到哪一步），还容易陷入细节忘记大局。

**解法**：两层机制：
- **Layer 1（触发层）**：CLAUDE.md 加 post-compact self-check 规则，compact 后模型仍能读到并触发恢复
- **Layer 2（持久层）**：`.tad/active/session-state.md` 在每个关键节点写入语义状态；hook 补充 metadata

---

## 2. Background

- Sonnet 4.6 context 较短，auto-compact 后对话历史被压缩成摘要
- SKILL 文件内容在 compact 后从详细规则变成一句话摘要
- CLAUDE.md 是**唯一**保证在 compact 后仍在 context 中的系统级内容
- 需要一个"每轮自检"机制，让 agent 在发现状态不对时立即恢复

---

## 3. Requirements

| # | 需求 | 说明 |
|---|------|------|
| R1 | Compact 后 Blake 能恢复身份 + handoff 路径 | 核心痛点 |
| R2 | Compact 后 Alex 能恢复当前 mode + 草稿路径 | 同等重要 |
| R3 | session-state.md 包含 Big Picture 字段（含 Why Now） | 对抗"陷入细节"问题 |
| R4 | hook 写 metadata，agent SKILL 写语义 | 分工明确，互补不依赖 |
| R5 | session-state.md 不 commit 到 git | 运行时文件 |
| R6 | 改动通过 *sync 推到所有下游项目 | 框架级改动 |
| R7 | stale session-state 不触发错误 resume | 上一个 handoff 完成后不应干扰下次启动 |

---

## 4. Technical Design

### 4.1 Layer 1：CLAUDE.md Post-Compact Recovery Section

在项目 CLAUDE.md 的 **Section 4（Terminal 隔离）之后**新增 Section 4.5：

```markdown
## 4.5 Post-Compact Recovery ⚠️

**每次回复前自检（强制）：**
- **Blake**：我知道当前 handoff 的完整文件路径吗？
- **Alex**：我知道当前工作模式 + 正在处理的 handoff/草稿吗？

**如果答案是 NO（或不确定）：**
1. Read `.tad/active/session-state.md`（如果存在）
2. 重新运行 `/blake` 或 `/alex` 重载完整协议
3. 从 session-state.md 的 `Current Position` 继续

如果 self-check 没触发（Layer 1 失效），用户可手动说：
"Read .tad/active/session-state.md" 触发 Layer 2 恢复。
```

### 4.2 Layer 2：session-state.md 格式

位置：`.tad/active/session-state.md`（`.gitignore` 排除）

```markdown
# TAD Session State
<!-- Auto-maintained by TAD agents. See .tad/templates/session-state-template.md -->
Last Updated: YYYY-MM-DDTHH:MM:SSZ
Hook Last Touched: YYYY-MM-DDTHH:MM:SSZ   <!-- Updated by post-write-sync.sh hook -->
Last File Written: <none>                  <!-- Updated by post-write-sync.sh hook -->

## Active Agent
**Role**: Blake | Alex
**SKILL**: .claude/skills/blake/SKILL.md | .claude/skills/alex/SKILL.md

## Active Task
**Status**: ACTIVE | COMPLETE | ABANDONED
**Handoff**: .tad/active/handoffs/HANDOFF-*.md | none
**Priority**: P0 | P1 | P2 | P3 | N/A
**Mode** (Alex only): analyze | bug | discuss | idea | learn | express | experiment | N/A

## Current Position
(One line: e.g. "Ralph Loop → Layer 1 → Step 3/5 (lint)" or "Socratic Inquiry Round 3/5")

## Completed ✅
(Brief bullets of what's done)

## Next Action
(One line: what to do next)

## Big Picture (不要忘记)
**Goal**: (one-sentence task objective)
**Why Now**: (one-sentence user pain or strategic driver — from handoff §1)
**Key Constraint**: (most important constraint)
**Success When**: (completion criteria summary — copy from handoff ACs)
```

### 4.3 写入时机 + Stale 检测

**Blake 写 session-state.md 的时机：**
1. `*develop` 启动时（`develop_command.1_init`）：从模板创建，Status=ACTIVE
2. Layer 1 全部 PASS 后：更新 Current Position → "Layer 2 pending"
3. 每轮 Layer 2 完成后：更新 Current Position + Completed 列表
4. `*complete` / `completion_protocol` 完成后：Status → COMPLETE（**必须**）

**Alex 写 session-state.md 的时机：**
1. `handoff_creation_protocol.step1` 开始草稿时：Status=ACTIVE，Mode=analyze
2. 进入 Socratic Inquiry 时：更新 Current Position

**hook 写 session-state.md（`post-write-sync.sh`）：**
- HANDOFF-*.md 或 COMPLETION-*.md 被写入时 → 更新 `Hook Last Touched` + `Last File Written`
- 仅当 session-state.md 已存在时操作（agent 负责创建）

**Stale 检测规则（STEP 3.7 + on_start）：**
- 若 `Status != ACTIVE` → 不触发 resume（Blake=COMPLETE/ABANDONED）
- 若 `Status = ACTIVE` 但 handoff 文件不存在（被 archive 了） → 视为 stale，忽略
- 若 status=ACTIVE 且文件存在 → 正常 resume

---

## 5. Files to Modify / Create

| # | 文件 | 操作 | 描述 |
|---|------|------|------|
| F1 | `CLAUDE.md` | Edit | Section 4 之后新增 Section 4.5 |
| F2 | `.claude/skills/blake/SKILL.md` | Edit | 新增 `session_state_protocol` section + `develop_command.1_init` step 4 + `on_start` + `completion_protocol` step |
| F3 | `.claude/skills/alex/SKILL.md` | Edit | 新增 activation_protocol `STEP 3.7` + `handoff_creation_protocol.step1` output 字段追加 |
| F4 | `.tad/hooks/post-write-sync.sh` | Edit | HANDOFF/COMPLETION case 各加 session-state metadata 更新 |
| F5 | `.tad/templates/session-state-template.md` | Create | 含所有字段的模板 |
| F6 | `.gitignore` | Edit | 新增 `.tad/active/session-state.md` 排除 |

**Grounded Against**:
- `CLAUDE.md` (head 70, read 2026-04-28) — 70 行，Section 4 在行 38-42
- `.claude/skills/blake/SKILL.md` (structure scan) — 1483 行，on_start at 1382, develop_command.1_init at 406, completion_protocol at ~1061, state_management at 686
- `.claude/skills/alex/SKILL.md` (structure scan) — STEP 3.6 存在，handoff_creation_protocol.step1 output 字段已有多条
- `.tad/hooks/post-write-sync.sh` (full read) — HANDOFF case at 65, COMPLETION case at 69
- `.gitignore` (head 30) — 无 session-state 条目，有 `*.bak` 排除（行 18）

---

## 6. Implementation Steps

### Task 1：CLAUDE.md — 新增 Section 4.5

**插入位置**：在 `## 5. 违规处理` 之前（即 `## 4. Terminal 隔离` section 结束后），作为新 section。

```markdown

## 4.5 Post-Compact Recovery ⚠️

**每次回复前自检（强制）：**
- **Blake**：我知道当前 handoff 的完整文件路径吗？
- **Alex**：我知道当前工作模式 + 正在处理的 handoff/草稿吗？

**如果答案是 NO（或不确定）：**
1. Read `.tad/active/session-state.md`（如果存在）
2. 重新运行 `/blake` 或 `/alex` 重载完整协议
3. 从 session-state.md 的 `Current Position` 继续

如果 self-check 没触发（Layer 1 失效），用户可手动说：
"Read .tad/active/session-state.md" 触发 Layer 2 恢复。

```

---

### Task 2：Blake SKILL — 四处修改

**2a. 新增 `session_state_protocol` section（在 `state_management:` section 之后，缩进 2 空格与 `state_management` 同级）：**

```yaml
  # Session State for Compact Recovery (v2.8.5)
  session_state_protocol:
    description: "人类可读的 session 状态快照，用于 compact 后恢复身份 + 任务进度"
    file: ".tad/active/session-state.md"
    template: ".tad/templates/session-state-template.md"

    stale_detection: |
      读取 session-state.md 时先检查：
      1. Status 字段 != ACTIVE → 不 resume（旧 handoff 已完成）
      2. Status = ACTIVE 但 Active Task.Handoff 路径文件不存在（已归档） → 视为 stale，忽略
      3. Status = ACTIVE 且 handoff 文件存在 → 正常 resume

    write_triggers:
      - "develop_command.1_init — 启动时从模板创建，Status=ACTIVE"
      - "After Layer 1 ALL PASS — 更新 Current Position + Status=ACTIVE"
      - "After each Layer 2 round — 更新 Completed + Current Position"
      - "completion_protocol 写完 COMPLETION 报告后 — Status=COMPLETE（必须）"

    compact_recovery_self_check: |
      ⚠️ 每次回复前自检：我知道当前 handoff 的完整文件路径吗？
      如果 NO：
        1. Read .tad/active/session-state.md
        2. 检查 Status = ACTIVE 且 handoff 路径文件存在（stale_detection）
        3. Re-run /blake to reload full SKILL
        4. Resume from Current Position
```

**2b. 修改 `develop_command.1_init`（在现有 3 条 steps 之后添加第 4 条）：**

```yaml
      1_init:
        - "Load/create state file: .tad/evidence/ralph-loops/{task_id}_state.yaml"
        - "Check for existing state (resume vs fresh start)"
        - "Initialize iteration counter"
        - "Create/overwrite .tad/active/session-state.md from .tad/templates/session-state-template.md:
           substitute ALL {placeholders} with actual values:
           - Status = ACTIVE
           - Active Agent.Role = Blake
           - Active Task.Handoff = <full path of current handoff>
           - Big Picture.Goal = <from handoff §1 Executive Summary — one sentence>
           - Big Picture.Why Now = <from handoff §1 problem description>
           - Big Picture.Key Constraint = <most important constraint from handoff §10>
           - Big Picture.Success When = <copy key ACs summary>
           - Current Position = 'Ralph Loop → start'
           - Last Updated = <current ISO timestamp>"
```

**2c. 修改 `on_start`（在 `on_start: |` 的 block-scalar 内容中，精确插入位置）：**

Blake SKILL `on_start:` 的 block-scalar 内容中，在这一行之后：
```
  Use `*develop` to start the Ralph Loop development cycle.
```
（该行是 on_start 内容倒数第二行，之后是空行和 `  *help`）

**在该行之后、空行之前**，用 **2 空格缩进**（与周围 block-scalar 内容一致）插入：

```
  If .tad/active/session-state.md exists, read it (stale_detection rules apply).
  If Status=ACTIVE and handoff file exists: proceed to *develop to resume.
```

**2d. 修改 `completion_protocol`（在 completion report 写完之后，写 Status=COMPLETE）：**

找到 Blake SKILL 的 `completion_protocol` 章节（约第 1061 行附近）。在最后一个写操作（写 COMPLETION-*.md）之后，添加一个新 step：

```yaml
      step_session_state_complete:
        name: "Update session-state.md Status to COMPLETE"
        action: |
          Read .tad/active/session-state.md (if exists).
          Write: update Status field → COMPLETE, Current Position → "Completion report written — awaiting Alex Gate 4"
          This enables Alex STEP 3.7 to detect the handoff is done and suggest *review/*accept.
        trigger: "After COMPLETION-*.md is written successfully"
```

---

### Task 3：Alex SKILL — 两处修改

**3a. 新增 activation_protocol `STEP 3.7`（在 STEP 3.6 之后）：**

STEP 3.6 结构包含 `action`, `blocking: false`, `suppress_if` 字段。STEP 3.7 使用相同格式，**2 空格缩进**，列表项 `- STEP 3.7:`：

```yaml
  - STEP 3.7: Session State Check
    action: |
      Read .tad/active/session-state.md (if exists).
      Apply stale_detection (mirror Blake session_state_protocol.stale_detection):
        1. File not found → skip silently
        2. Status != ACTIVE → skip (print nothing, old completed session)
        3. Active Agent = Blake AND Status = ACTIVE AND handoff file exists:
           → Announce: "⚠️ Blake is mid-task on {handoff}. Are you in Terminal 2? Or proceed as Alex?"
           → Use AskUserQuestion: options "Switch to Terminal 2 (Blake)" / "Continue as Alex"
        4. Active Agent = Blake AND Status = COMPLETE:
           → Announce: "🟢 Blake completed {handoff}. Ready for Gate 4 acceptance."
           → Suggest: *review or *accept
        5. Active Agent = Alex AND Status = ACTIVE AND handoff_path exists:
           → Announce: "🔄 Resuming: {mode} — {handoff_or_draft_path}. Position: {Current Position}"
           → Load the draft path or re-enter the mode
    output: "Brief resume announcement (cases 3/4/5 only) or silent skip (cases 1/2)"
    blocking: false
    suppress_if: "session-state.md not found OR Status != ACTIVE (cases 1 and 2)"
    interacts_with: |
      STEP 3.6 (pair test detection) runs first (narrower scope).
      STEP 3.7 runs second.
      If STEP 3.7 announces resume (cases 3/4/5): suppress STEP 4's *help autorun
      (user just got context, the command menu is noise).
```

**3b. 修改 `handoff_creation_protocol.step1`（在 `output:` 字段的 content 列表末尾追加）：**

在 step1 的 `output:` 字段最后一条 content 项之后，**同等缩进**添加：

```yaml
        - "Write .tad/active/session-state.md: Status=ACTIVE, Active Agent=Alex, Mode={current_mode}, Active Task.Handoff=<draft_path>, Current Position='handoff_creation step1 — drafting', Big Picture.Goal/Why Now/Key Constraint/Success When from task requirements"
```

---

### Task 4：post-write-sync.sh — HANDOFF 和 COMPLETION case 各加 session-state 更新

**在 `*.tad/active/handoffs/HANDOFF-*.md)` case 的 `record_trace` 行之前**，添加以下函数调用 + 函数定义。

**在文件顶部（`read_stdin_json` 调用之前）添加函数定义：**

```bash
# Update session-state.md metadata (compact recovery support)
# Only runs if session-state.md already exists (agent creates it; hook only updates)
update_session_state_metadata() {
  local written_file="$1"
  local state_file=".tad/active/session-state.md"

  [ -f "$state_file" ] || return 0   # agent creates; hook only updates existing

  local ts
  ts=$(date -u +%Y-%m-%dT%H:%M:%SZ)

  # Escape sed metacharacters (& \ |) in the replacement string
  local escaped_file
  escaped_file=$(printf '%s' "$written_file" | sed 's/[\\&|]/\\&/g')

  # Update Hook Last Touched — BSD-portable sed -i with .bak; always rm (use ; not &&)
  sed -i.bak "s|^Hook Last Touched:.*|Hook Last Touched: $ts|" "$state_file"; rm -f "${state_file}.bak"

  # Update Last File Written — append if line missing (fallback for partial files)
  if grep -q "^Last File Written:" "$state_file"; then
    sed -i.bak "s|^Last File Written:.*|Last File Written: $escaped_file|" "$state_file"; rm -f "${state_file}.bak"
  else
    echo "Last File Written: $escaped_file" >> "$state_file"
  fi
}
```

**在 HANDOFF case 的 `record_trace` 行之前**调用：

```bash
    update_session_state_metadata "$FILE_PATH"
```

**在 COMPLETION case 的 `record_trace` 行之前**同样调用：

```bash
    update_session_state_metadata "$FILE_PATH"
```

注意：`.bak` 文件已被 `.gitignore` 第 18 行 `*.bak` 规则覆盖，无需额外处理。

---

### Task 5：新建 `.tad/templates/session-state-template.md`

用 §4.2 的完整格式定义创建模板。所有 `{placeholder}` 用大括号标注，Blake/Alex 在创建时必须替换。

### Task 6：`.gitignore` — 新增排除

**在 `# TAD Framework - 全部纳入版本控制，不忽略` 注释行处**，将注释修改为：

```
# TAD Framework - 默认全部纳入版本控制，运行时快照除外
.tad/active/session-state.md
```

---

## 7. 📚 Project Knowledge — Blake 必须注意的历史教训

| 教训 | 来源 | 与本任务的关联 |
|------|------|--------------|
| **Hook Shell Portability: No grep -P on macOS** | architecture.md | Task 4 使用 `grep -q` + `sed -i.bak`，BSD 兼容 |
| **Hook Path Matching: Glob Prefix** | architecture.md | post-write-sync.sh 的 `*.tad/` 已正确，新增代码不改 case 结构 |
| **Mechanical Enforcement Rejected on Single-User CLI** | architecture.md | session-state 是 advisory，不加 PreToolUse deny |
| **Minimal Viable Cross-Cutting Enhancement** | architecture.md | 只加 2 个最关键节点，不扩展到所有可能节点 |
| **AC Verification Commands Need Pre-Ship Smoke Test** | architecture.md | AC drift 已发生 5 次；本次 step1d 对现有文件实际 dry-run |
| **Hook Data Integrity** | architecture.md | sed 替换必须转义 & 和 \ — Task 4 的 ESCAPED_PATH 模式 |

---

## 8. Anti-Patterns to Avoid

- ❌ 不要用 `&&` 来 rm .bak（用 `;`，确保无论 sed 成败都清理）
- ❌ 不要直接把 `$FILE_PATH` 放入 sed 替换字符串（必须先 ESCAPED_PATH 转义）
- ❌ 不要让 hook 创建 session-state.md（只更新已存在的）
- ❌ 不要在 Status != ACTIVE 时触发 resume（stale 检测）
- ❌ 不要用 `grep -P`（BSD grep 不支持）
- ❌ 不要把 session-state.md 加入 git tracked
- ❌ 不要把 {placeholder} 留在写入的 session-state.md 里（必须替换）

---

## 9. Acceptance Criteria

### §9.1 Spec Compliance Checklist

| AC# | 验证项 | Verification Method | Verified Output |
|-----|--------|--------------------|--------------:|
| AC1 | CLAUDE.md 包含 Post-Compact Recovery section | `grep -c "Post-Compact Recovery" CLAUDE.md` | (post-impl, expect 1) |
| AC2 | CLAUDE.md 含 Blake 自检语句 | `grep -c "handoff 的完整文件路径" CLAUDE.md` | (post-impl, expect 1) |
| AC3 | CLAUDE.md 含 Alex 自检语句 | `grep -c "当前工作模式" CLAUDE.md` | (post-impl, expect 1) |
| AC4 | Blake SKILL 有 session_state_protocol section | `grep -c "session_state_protocol:" .claude/skills/blake/SKILL.md` | (post-impl, expect ≥1) |
| AC5 | Blake develop_command.1_init 有 session-state 创建步骤 | `grep -c "session-state-template" .claude/skills/blake/SKILL.md` | (post-impl, expect ≥1) |
| AC6 | Blake on_start 提及 session-state.md | `grep -c "session-state.md" .claude/skills/blake/SKILL.md` | (post-impl, expect ≥3: 2a+2b+2c) |
| AC7 | Alex SKILL 有 STEP 3.7 | `grep -c "STEP 3.7" .claude/skills/alex/SKILL.md` | (post-impl, expect ≥1) |
| AC8 | Alex SKILL 含 session-state.md 引用（STEP 3.7 + step1 各 1 处） | `grep -c "session-state.md" .claude/skills/alex/SKILL.md` | (post-impl, expect ≥2) |
| AC9 | post-write-sync.sh 含 session-state sed 更新行 | `grep -c "sed -i.bak.*Last Updated\|sed -i.bak.*Hook Last Touched" .tad/hooks/post-write-sync.sh` | (post-impl, expect ≥1) |
| AC10 | post-write-sync.sh 含 sed 转义逻辑 | `grep -c "ESCAPED_PATH\|escaped_file" .tad/hooks/post-write-sync.sh` | (post-impl, expect ≥1) |
| AC11 | session-state-template.md 含 Big Picture + Why Now | `grep -c "Why Now" .tad/templates/session-state-template.md` | (post-impl, expect ≥1) |
| AC12 | session-state-template.md 含 Status 字段 | `grep -c "Status:" .tad/templates/session-state-template.md` | (post-impl, expect ≥1) |
| AC13 | .gitignore 含 session-state.md 排除 | `grep -c "session-state.md" .gitignore` | (post-impl, expect ≥1) |
| AC14 | 恢复行为验证（manual） | 见 §9.2 manual test procedure | (post-impl, manual) |

**AC Dry-Run Log** (Alex step1d, 2026-04-28):

Pre-impl baseline (files exist, features not yet added):
- AC1: `grep -c "Post-Compact Recovery" CLAUDE.md` → 0 ✅ (confirms clean pre-state, regex valid)
- AC4: `grep -c "session_state_protocol:" .claude/skills/blake/SKILL.md` → 0 ✅ (clean, regex valid)
- AC7: `grep -c "STEP 3.7" .claude/skills/alex/SKILL.md` → 0 ✅ (clean)
- AC9 (pattern): `grep -c "sed -i.bak.*Last Updated\|sed -i.bak.*Hook Last Touched" .tad/hooks/post-write-sync.sh` → 0 ✅ (clean)
- AC10: `grep -c "ESCAPED_PATH\|escaped_file" .tad/hooks/post-write-sync.sh` → 0 ✅ (clean)
- AC13: `grep -c "session-state.md" .gitignore` → 0 ✅ (clean)

All post-impl ACs: syntax-validated (grep -c single-file returns count, no multi-file colon prefix issue).

### §9.2 Manual Recovery Test (AC14)

```bash
# Setup
cp .tad/templates/session-state-template.md .tad/active/session-state.md
# Edit session-state.md: set Status=ACTIVE, Active Agent.Role=Blake,
#   Active Task.Handoff=.tad/active/handoffs/HANDOFF-20260428-compact-recovery.md
#   Current Position=Ralph Loop → Layer 1 → Step 2/5

# Test
# Open new /blake session → on_start should announce:
# "Session state found. Status=ACTIVE. Handoff: HANDOFF-20260428-compact-recovery.md. Position: Layer 1 Step 2."

# Cleanup
rm .tad/active/session-state.md
```

Expected: Blake `on_start` reads the file and announces resume context.

---

## 10. Important Notes

### 10.1 核心假设

本方案依赖 **CLAUDE.md 在 compact 后仍在 context 中**（系统级内容特性，多次观察确认）。如果该假设失效，Layer 1 机制失效，但 Layer 2 仍可通过用户手动说 "Read .tad/active/session-state.md" 触发。

### 10.2 hook 写失败不阻塞

`update_session_state_metadata` 是 best-effort：
- session-state.md 不存在 → `return 0` 跳过
- sed 失败 → `;` 保证 .bak 清理；hook exit 0 不受影响

### 10.3 与现有 state_management 的关系

Blake 已有 `.tad/evidence/ralph-loops/{task_id}_state.yaml`（崩溃恢复）。`session-state.md` 是补充（更人类可读，compact 恢复专用），不替换现有机制。

### 10.4 Sub-Agent 使用建议（Phase 6-A 规则：≥2 distinct reviewers，self-review.md 不算）

Layer 2 per hard_requirement_distinct_reviewers:
- code-reviewer（REQUIRED — KNOWN_REVIEWERS canonical）
- backend-architect（REQUIRED — second distinct reviewer; self-review.md 不计）

---

## 11. Decision Summary

| # | 决策 | 选项 | 选择 | 理由 |
|---|------|------|------|------|
| D1 | 恢复触发 | 检测阈值 vs 每轮自检 | 每轮自检 | 无法从 agent 内部检测 context 使用率 |
| D2 | 写入机制 | hook only / SKILL only / 双写 | 双写 | hook 写 metadata，SKILL 写语义 |
| D3 | 存储 | .tad/active/, .gitignored | .tad/active/, .gitignored | 运行时文件 |
| D4 | 同步 | TAD 主项目 / 所有项目 | 通过 *sync 推所有 | 框架级改动 |
| D5 | 保护范围 | Blake only / 两个 | Alex + Blake 都做 | 两个都会 compact |
| D6 | Stale 检测 | 无 / Status 字段 | Status 字段 + handoff 存在检查 | 防止旧 session 触发错误 resume |
| D7 | Hook Last Touched vs Last Updated | 同一字段 / 分离 | 分离 | agent 写语义时间戳，hook 写文件活动时间戳 |

---

## 12. Required Evidence Manifest

```yaml
required_evidence:
  expert_reviews:
    - .tad/evidence/reviews/blake/compact-recovery/code-reviewer.md
    - .tad/evidence/reviews/blake/compact-recovery/backend-architect.md
  blake_layer2_internal:
    - .tad/evidence/reviews/blake/compact-recovery/self-review.md
    - .tad/evidence/reviews/blake/compact-recovery/feedback-integration.md
  gate_verdicts:
    - .tad/evidence/completions/compact-recovery/GATE3-REPORT.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260428-compact-recovery.md
  knowledge_updates:
    - .tad/project-knowledge/architecture.md (new entry: Two-Layer Compact Recovery Pattern)
```

---

*Handoff v2 — P0 issues resolved, Expert Review Integrated, Gate 2 PASS*
