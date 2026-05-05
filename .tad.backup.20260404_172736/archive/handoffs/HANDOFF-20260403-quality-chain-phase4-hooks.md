---
task_type: code
e2e_required: no
research_required: no
---

# Handoff: 质量链修复 Phase 4 — Hook 验证层升级

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-04-03
**Project:** TAD
**Task ID:** TASK-20260403-012
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260403-quality-chain-full-repair.md (Phase 4/4)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-04-03 (pending expert review)

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Handoff ID 定位 + boolean flag + maxdepth 限制 |
| Components Specified | ✅ | 2 个 hook 脚本，变更点明确 |
| Functions Verified | ✅ | pre-gate-check.sh + post-write-sync.sh 路径已确认 |
| Data Flow Mapped | ✅ | handoff frontmatter → hook 读取 → Gate 3 阻塞/放行 |

**Expert Review**: code-reviewer CONDITIONAL PASS (2 P0 fixed: \n literal + COMPLETION_FILE); backend-architect CONDITIONAL PASS (2 P0 fixed: handoff locating + boolean flag)

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 What We're Building
升级 Hook 脚本，利用 Phase 1 定义的 YAML frontmatter 字段实现 Gate 3 前的综合 evidence 检查。

### 1.2 Why We're Building It
**核心原则**：Prompt 管"必须做什么"（Phase 2/3 已完成），Hook 管"做了没有"（本 Phase）。当前 Hook 只检查 COMPLETION 文件存在性，覆盖不到 evidence、Ralph Loop 状态、Git commit、条件性 E2E/Research。

### 1.3 Intent Statement

**真正要解决的问题**：Hook 验证覆盖面过窄（仅 COMPLETION 存在性），导致 Blake 即使跳过 evidence 产出也能通过 Gate 3。

**不是要做的**：
- ❌ 不是修改 SKILL.md — Phase 2/3 已完成
- ❌ 不是修改模板 — Phase 1 已完成
- ❌ 不是重写 Hook 架构 — 在现有 Hook 脚本中扩展

---

## 📚 Project Knowledge（Blake 必读）

| 文件 | 关键提醒 |
|------|----------|
| architecture.md | "Hook Path Matching: Glob Prefix Must Handle Relative Paths" — `*.tad/` not `*/.tad/` |
| architecture.md | "Claude Code Enforcement Priority Order" — Hook exit 2 = BLOCK, exit 0 = ALLOW |

---

## 2. Background Context

### 2.1 Current Hook 状态

**pre-gate-check.sh**（72 行）：
- Gate 3: 只检查 COMPLETION 文件存在 → 存在则 ALLOW，不存在则 BLOCK
- Gate 4: 只 WARN 如果无 COMPLETION
- Gate 1/2: 直接 ALLOW

**post-write-sync.sh**（102 行）：
- 检测 HANDOFF/COMPLETION/NEXT.md/Epic/knowledge/ralph-loop/evidence 文件写入
- 注入工作流提醒（非阻塞）
- 包含 trace 记录功能

### 2.2 Phase 1 数据契约（Hook 解析依赖）

Phase 1 在 handoff 模板顶部定义了 YAML frontmatter：
```yaml
---
task_type: code
e2e_required: no
research_required: no
---
```

Shell 解析方式：
```bash
grep '^e2e_required:' "$HANDOFF_FILE" | awk '{print $2}'
```

从 completion report 定位 handoff：
```bash
grep -oP '(?<=\*\*Handoff ID:\*\* ).*' "$COMPLETION_FILE"
```

---

## 3. Requirements

### 3.1 Functional Requirements

**FR1: pre-gate-check.sh Gate 3 综合检查**

在现有 Gate 3 检查（COMPLETION 存在性）之后，追加综合 evidence 检查。逻辑：

```bash
if [ "$GATE_NUM" = "3" ]; then
  # === 现有检查（保留）===
  # COMPLETION 文件存在性检查 → 不存在则 BLOCK (exit 2)
  # 现有代码已经定义了 COMPLETION count 检查并在此之前 exit 2
  
  # === 新增：综合 evidence 检查 ===
  # 设计原则：
  # - 一般 evidence 缺失 = WARNING（提醒但不阻塞）
  # - frontmatter 标记的条件 evidence 缺失 = BLOCK（exit 2）
  # - 使用 boolean flag 控制 BLOCK，不靠 grep 字符串内容
  
  WARNINGS=""
  HAS_BLOCK=0
  
  # 解析 COMPLETION 文件路径（用于 -newer 比较）
  COMPLETION_FILE=$(ls .tad/active/handoffs/COMPLETION-*.md 2>/dev/null | head -1)
  
  # 检查 1: evidence 目录有最近文件
  if [ -n "$COMPLETION_FILE" ]; then
    EVIDENCE_COUNT=$(find .tad/evidence -maxdepth 2 -name "*.md" -newer "$COMPLETION_FILE" 2>/dev/null | wc -l | tr -d ' ')
  else
    EVIDENCE_COUNT=0
  fi
  if [ "$EVIDENCE_COUNT" = "0" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: No recent evidence files found in .tad/evidence/. Did you complete expert review and acceptance verification?"
  fi
  
  # 检查 2: Ralph Loop 状态文件
  RALPH_COUNT=$(find .tad/evidence/ralph-loops -maxdepth 1 -name "*_state.yaml" 2>/dev/null | wc -l | tr -d ' ')
  if [ "$RALPH_COUNT" = "0" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: No Ralph Loop state file found. Did you run *develop with Ralph Loop?"
  fi
  
  # 检查 3: 读取 handoff frontmatter 的条件字段
  # 定位 handoff 文件：从 COMPLETION report 的 Handoff ID 字段提取
  HANDOFF_FILE=""
  if [ -n "$COMPLETION_FILE" ]; then
    HANDOFF_ID=$(grep -oP '(?<=\*\*Handoff ID:\*\* ).*' "$COMPLETION_FILE" 2>/dev/null | tr -d '[:space:]')
    if [ -n "$HANDOFF_ID" ] && [ -f ".tad/active/handoffs/${HANDOFF_ID}" ]; then
      HANDOFF_FILE=".tad/active/handoffs/${HANDOFF_ID}"
    fi
  fi
  # Fallback: 如果 COMPLETION 没有 Handoff ID 字段，扫描目录
  if [ -z "$HANDOFF_FILE" ]; then
    HANDOFF_FILE=$(ls .tad/active/handoffs/HANDOFF-*.md 2>/dev/null | head -1)
  fi
  
  if [ -n "$HANDOFF_FILE" ]; then
    # 只从 frontmatter 区域解析（前 10 行，避免匹配正文中的示例）
    E2E_REQ=$(head -10 "$HANDOFF_FILE" | grep '^e2e_required:' | awk '{print $2}')
    RESEARCH_REQ=$(head -10 "$HANDOFF_FILE" | grep '^research_required:' | awk '{print $2}')
    
    # 检查 3a: E2E evidence（条件性 — BLOCK）
    if [ "$E2E_REQ" = "yes" ]; then
      E2E_EVIDENCE=$(find .tad/evidence -maxdepth 2 -name "*e2e*" -o -name "*E2E*" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$E2E_EVIDENCE" = "0" ]; then
        WARNINGS="${WARNINGS}"$'\n'"BLOCKED: Handoff requires E2E (e2e_required: yes) but no E2E evidence found. Gate 3 cannot pass."
        HAS_BLOCK=1
      fi
    fi
    
    # 检查 3b: Research 文件（条件性 — BLOCK）
    if [ "$RESEARCH_REQ" = "yes" ]; then
      RESEARCH_EVIDENCE=$(find .tad/evidence -maxdepth 2 -name "*research*" -o -name "*best-practices*" 2>/dev/null | wc -l | tr -d ' ')
      if [ "$RESEARCH_EVIDENCE" = "0" ]; then
        WARNINGS="${WARNINGS}"$'\n'"BLOCKED: Handoff requires research (research_required: yes) but no research evidence found. Gate 3 cannot pass."
        HAS_BLOCK=1
      fi
    fi
  fi
  
  # 检查 4: Git commit（检查工作区是否干净）
  GIT_DIRTY=$(git status --porcelain -- ':!.tad/' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$GIT_DIRTY" != "0" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: Uncommitted changes detected outside .tad/. Did you commit implementation code?"
  fi
  
  # 输出结果
  if [ "$HAS_BLOCK" = "1" ]; then
    echo "Gate 3 BLOCKED: Required evidence missing.${WARNINGS}" >&2
    exit 2
  elif [ -n "$WARNINGS" ]; then
    output_response "PreToolUse" "Gate 3 prerequisites met (COMPLETION found). Please review these warnings before proceeding:${WARNINGS}"
  else
    output_response "PreToolUse" "Gate 3 prerequisites met. COMPLETION report and evidence checks passed."
  fi
  exit 0
fi
```

**关键设计决策**：
- 一般 evidence 缺失 = WARNING（提醒但不阻塞）
- e2e_required: yes 但无 E2E evidence = **BLOCK**（exit 2）
- research_required: yes 但无 research evidence = **BLOCK**（exit 2）
- 这实现了我们讨论的原则："设计时决策，执行时不判断"

**FR2: post-write-sync.sh Domain Pack 研究文件检测**

在现有 `case` 语句中，在 `*.tad/active/research/*` 之前新增 domain pack 检测：

```bash
  *.tad/domains/*.yaml)
    DOMAIN_NAME=$(basename "$FILE_PATH" .yaml)
    RESEARCH_FILE=".tad/spike-v3/domain-pack-tools/${DOMAIN_NAME}-skills-best-practices.md"
    
    if [ ! -f "$RESEARCH_FILE" ]; then
      EXTRA_CONTEXT="⚠️ Domain Pack ${DOMAIN_NAME} created WITHOUT Phase 1 research. Research file missing: ${RESEARCH_FILE}. Consider running research before finalizing this domain pack."
    fi
    
    record_trace "domain_pack_created" "$FILE_PATH" "$DOMAIN_NAME"
    
    if [ -n "${EXTRA_CONTEXT:-}" ]; then
      output_response "PostToolUse" "$EXTRA_CONTEXT"
    else
      output_response "PostToolUse" "Domain Pack ${DOMAIN_NAME} updated. Trace recorded."
    fi
    ;;
```

### 3.2 Non-Functional Requirements
- NFR1: 现有 Hook 功能不受影响（COMPLETION 检查、trace 记录等）
- NFR2: Hook 必须在 500ms 内完成（不能有网络调用或大文件扫描）
- NFR3: 使用 common.sh 的 helper 函数（output_response, read_stdin_json 等）
- NFR4: 错误处理要 defensive — find/grep 失败不能导致 Hook 崩溃（用 2>/dev/null + 默认值）

---

## 7. File Structure

### 7.1 Files to Modify
```
.tad/hooks/pre-gate-check.sh    # Gate 3 综合 evidence 检查
.tad/hooks/post-write-sync.sh   # Domain Pack 研究文件检测
```

---

## 8. Testing Requirements

### 8.1 验证方法
- **语法检查**: `bash -n .tad/hooks/pre-gate-check.sh` + `bash -n .tad/hooks/post-write-sync.sh`（无语法错误）
- **现有功能回归**: Gate 3 无 COMPLETION 时仍 BLOCK（exit 2）
- **新增功能**: 有 COMPLETION + 无 evidence → 输出 WARNING
- **条件阻塞**: 有 COMPLETION + e2e_required: yes + 无 E2E evidence → BLOCK（exit 2）

### 8.2 Edge Cases
- .tad/evidence/ 目录不存在（冷启动）→ 不崩溃，输出 WARNING
- handoff 无 YAML frontmatter（旧格式）→ grep 返回空，跳过条件检查
- 多个 HANDOFF-*.md 文件 → 取第一个（head -1）
- git 不可用 → git status 失败，跳过 Git 检查

---

## 9. Acceptance Criteria

- [ ] **AC1**: pre-gate-check.sh Gate 3 检查含 evidence 文件数检查
- [ ] **AC2**: pre-gate-check.sh Gate 3 检查含 Ralph Loop 状态文件检查
- [ ] **AC3**: pre-gate-check.sh Gate 3 检查读取 handoff frontmatter（e2e_required, research_required）
- [ ] **AC4**: e2e_required: yes + 无 E2E evidence → exit 2 BLOCK
- [ ] **AC5**: research_required: yes + 无 research evidence → exit 2 BLOCK
- [ ] **AC6**: pre-gate-check.sh Gate 3 检查含 Git 工作区检查
- [ ] **AC7**: post-write-sync.sh 含 domain pack 研究文件检测（`*.tad/domains/*.yaml` case）
- [ ] **AC8**: `bash -n` 两个脚本无语法错误
- [ ] **AC9**: 现有 COMPLETION 检查功能不受影响（无回归）
- [ ] **AC10 (BLOCKING)**: 必须走 Ralph Loop + Gate 3

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Method | Expected Evidence |
|---|---------------------|--------------------|--------------------|
| 1 | evidence 检查 | `grep 'evidence' .tad/hooks/pre-gate-check.sh` | 3+ matches |
| 2 | Ralph Loop 检查 | `grep 'ralph' .tad/hooks/pre-gate-check.sh` | 1+ matches |
| 3 | frontmatter 解析 | `grep 'e2e_required\|research_required' .tad/hooks/pre-gate-check.sh` | 2+ matches |
| 4 | 条件 BLOCK | `grep 'BLOCKING' .tad/hooks/pre-gate-check.sh` | 2+ matches (E2E + Research) |
| 5 | Git 检查 | `grep 'git status' .tad/hooks/pre-gate-check.sh` | 1+ matches |
| 6 | Domain pack 检测 | `grep 'domains' .tad/hooks/post-write-sync.sh` | 1+ matches |
| 7 | bash -n | `bash -n .tad/hooks/pre-gate-check.sh && bash -n .tad/hooks/post-write-sync.sh` | exit 0 |
| 8 | COMPLETION 回归 | `grep 'COMPLETION' .tad/hooks/pre-gate-check.sh` | 现有检查保留 |

---

## 10. Important Notes

- ⚠️ 这是 Epic 最后一个 Phase — 完成后整条质量链三层防线就位
- ⚠️ 一般 evidence 缺失 = WARNING，条件 evidence（e2e/research）缺失 = BLOCK — 这是有意区分
- ⚠️ Hook 500ms 时间限制 — find 命令用 2>/dev/null 且不做递归深扫描
- ⚠️ 旧格式 handoff（无 frontmatter）→ grep 返回空 → 跳过条件检查（向后兼容）

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-04-03
**Version**: 3.1.0
