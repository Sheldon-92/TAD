---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-08
**Project:** TAD Framework
**Task ID:** TASK-20260608-004
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260608-skill-progressive-loading.md (Phase 1/3)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | "移动不删除"模式，reference stub 已有 9 个先例 |
| Components Specified | ✅ | 精确行范围 2784-3629 (846 行)，stub 格式明确 |
| Functions Verified | ✅ | 已有 bug/discuss/idea 等 9 个成功提取的 reference |
| Data Flow Mapped | ✅ | SKILL body → reference stub → references/ file |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**目标**: 从 Alex SKILL.md body 中提取 handoff_creation_protocol（行 2784-3629，846 行）到 references/handoff-creation-protocol.md，在原位留下 reference stub。验证 Claude Code 和 Codex 均正常工作。

**业务价值**: 这是 SKILL 瘦身 Epic 的 spike——验证"移动不删除"模式对最大最复杂的协议是否可行。成功后 Phase 2 将全量执行。

**⚠️ 安全基线（CRITICAL — 必须在改动前记录）**:
- Body 安全关键词: 139
- References 安全关键词: 3
- **总计: 142** ← 改动后此数不允许下降

---

## 2. Requirements

**FR1**: 将 SKILL.md 行 2784-3629 的 handoff_creation_protocol 完整内容移到 `.claude/skills/alex/references/handoff-creation-protocol.md`
**FR2**: 原位替换为 reference stub（与已有的 bug_path_protocol stub 格式一致）
**FR3**: 安全关键词计数 (body + references) ≥ 142
**FR4**: Claude Code `/alex` 后 `*handoff` 命令仍可用
**FR5**: Codex `$alex` 激活正常

---

## 3. Technical Design

### 3.1 提取操作

**Step 1**: 创建 `.claude/skills/alex/references/handoff-creation-protocol.md`

将 SKILL.md 行 2784-3629 的完整内容复制到新文件。文件开头加一行注释标识来源：

```markdown
# Handoff Creation Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md lines 2784-3629
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 1)
```

**Step 2**: 替换 SKILL.md 行 2784-3629 为 reference stub

```yaml
handoff_creation_protocol:
  # Extracted for progressive loading — full protocol in the reference below.
  reference: ".claude/skills/alex/references/handoff-creation-protocol.md"
  load_when: "When *handoff is invoked or handoff_creation_protocol is entered, Read the reference and follow it verbatim."
```

### 3.2 reference stub 格式

必须与已有的 9 个 stub 格式一致（3 行：注释 + reference 路径 + load_when 说明）。参考 bug_path_protocol (SKILL.md 行 ~964-967)。

### 3.3 安全验证

改动完成后立即执行：

```bash
# 新 body 安全计数
body_after=$(grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden' .claude/skills/alex/SKILL.md)

# 新 references 安全计数（含所有 reference 文件）
refs_after=$(cat .claude/skills/alex/references/*.md | grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden')

# 总计必须 ≥ 142
total_after=$((body_after + refs_after))
echo "Safety: body=$body_after refs=$refs_after total=$total_after (baseline=142)"
```

如果 total_after < 142 → **STOP，不要 commit**，检查哪些安全规则丢失了。

---

## 5. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | reference 文件存在 | `test -f .claude/skills/alex/references/handoff-creation-protocol.md && wc -l < .claude/skills/alex/references/handoff-creation-protocol.md` | ≥700 行 |
| AC2 | body 行数减少 | `wc -l < .claude/skills/alex/SKILL.md` | ≤5400（6202 - ~800） |
| AC3 | reference stub 格式 | `grep -A3 'handoff_creation_protocol:' .claude/skills/alex/SKILL.md` | 3 行 stub（reference + load_when） |
| AC4 | 安全计数不下降 | `{ cat .claude/skills/alex/SKILL.md .claude/skills/alex/references/*.md; } \| grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden'` | ≥142 |
| AC5 | Claude Code 验证 | 在本 terminal 运行 `/alex`，确认 *help 显示 + *handoff 可用 | 激活成功 |
| AC6 | Codex 验证 | 在 /tmp/tad-codex-dogfood 重新安装 (`--platform both`)，`$alex` 激活 | 激活成功 |
| AC7 | 跨引用完整 | `grep -n 'handoff_creation_protocol\|expert_prompt_template\|step0_5b\|step1c_lsp' .claude/skills/alex/SKILL.md \| grep -v '^#'` — 所有引用处要么在 stub 内、要么在流程中会触发 reference Read | 无孤立引用 (P0 fix: arch review) |

---

## 6. Implementation Steps

### Task 1: 记录安全基线 (~2 min)

```bash
echo "=== BEFORE ===" 
echo "Body lines: $(wc -l < .claude/skills/alex/SKILL.md)"
echo "Body safety: $(grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden' .claude/skills/alex/SKILL.md)"
echo "Refs safety: $(cat .claude/skills/alex/references/*.md | grep -c 'MUST\|MANDATORY\|VIOLATION\|BLOCKING\|forbidden')"
```

### Task 2: 创建 reference 文件 (~5 min)

从 SKILL.md 行 2784-3629 复制完整内容到 `.claude/skills/alex/references/handoff-creation-protocol.md`，加来源注释头。

### Task 3: 替换为 reference stub (~5 min)

将 SKILL.md 行 2784-3629 替换为 3 行 reference stub。

### Task 4: 安全验证 (~2 min)

运行 §3.3 的 grep 计数，确认 ≥142。

### Task 5: Claude Code 验证 (~3 min)

这一步不需要 Blake 做——Alex 在 Gate 4 时自行验证 `/alex` 激活。Blake 只需确保文件改动正确。

### Task 6: Codex 验证 (~5 min)

在 /tmp/tad-codex-dogfood 重新安装 `--platform both`，验证 `$alex` 能激活。

**Grounded Against**:
- .claude/skills/alex/SKILL.md 行 2784-3629 (read at 2026-06-08)
- .claude/skills/alex/SKILL.md 行 964-967 (bug_path_protocol stub 格式, read at 2026-06-08)
- 安全基线: 142 (grep 计数, measured at 2026-06-08)

---

## 7. Files to Modify / Create

| File | Action | Scope |
|------|--------|-------|
| `.claude/skills/alex/SKILL.md` | MODIFY | 行 2784-3629 替换为 3 行 stub |
| `.claude/skills/alex/references/handoff-creation-protocol.md` | CREATE | ~850 行（846 + 来源注释） |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **Judgment-Only Skill Files** (principles.md): 约束规则不能在精简时丢失。本次用"移动不删除"避免此问题。
- **v2.7 质量链失效**: 精简删除了 forbidden_actions 等约束 → 本次 grep 计数是硬性 gate

---

## 9.2 Expert Review Status

| Expert | Focus | Result | Key Findings |
|--------|-------|--------|-------------|
| code-reviewer | 行范围、跨引用、安全 grep | PASS | 行范围精确，跨引用按名不按行号（安全），grep 模式完整 |
| backend-architect | YAML 结构、dangling references | CONDITIONAL PASS (P0 fix) | 6 处跨引用需确认通过 load_when 可达 → AC7 已加 |

---

## 10. Important Notes

### 10.1 这是机械操作，不是设计决策
提取的模式（reference stub）已有 9 个成功先例。本 handoff 没有新的架构判断——只是对最大的协议执行同样的操作。

### 10.2 安全计数是硬性 gate
如果 grep 计数 < 142，说明移动过程丢了安全规则。这是 STOP 条件——不要 commit，不要继续。

### 10.3 Codex 验证需要重新安装
Codex 的 `.agents/skills/` 是从源复制的。SKILL.md 改了之后需要重新跑 `tad.sh --platform both` 才能反映到 Codex 路径。

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| 1 | 专家审查 | Gate 3 spec-compliance only | 机械操作无架构决策，9 个先例已验证模式 |
| 2 | 安全阈值 | ≥142 (精确基线) | 不用"大概差不多"——用精确数字做硬性 gate |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/skill-slim-phase1/spec-compliance.md
gate_verdicts:
  - .tad/evidence/gates/gate3-skill-slim-phase1.md
completion:
  - .tad/active/handoffs/COMPLETION-20260608-skill-slim-phase1.md
```
