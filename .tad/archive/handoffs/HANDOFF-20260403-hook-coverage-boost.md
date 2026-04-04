---
task_type: code
e2e_required: no
research_required: no
---

# Mini-Handoff: Hook 覆盖率提升 — 内容级验证

**From:** Alex | **To:** Blake | **Date:** 2026-04-03
**Task ID:** TASK-20260403-013
**Type:** Express Enhancement (skip Socratic, streamlined review)
**Priority:** P1

## Problem

Phase 4 的 Hook 只做文件存在性检查（15% 覆盖率）。很多规则可以用 grep/stat/wc 做确定性内容验证，但没有做。目标：把 Hook 覆盖率从 15% 提升到 ~35-40%。

## 修改文件

只改一个文件：`.tad/hooks/pre-gate-check.sh`

## 具体新增检查（全部在 Gate 3 现有检查之后追加）

在现有 `# 输出结果` 部分之前，追加以下检查。每个检查独立，失败不互相影响。全部用 WARNING 或 BLOCK（按标注）。

### 检查 5: Evidence 文件非空验证

```bash
# 检查 5: Evidence 文件内容有效（非空/非模板 stub）
MIN_SIZE=100  # bytes — 低于此阈值视为空文件/模板
if [ -d ".tad/evidence/reviews" ]; then
  EMPTY_EVIDENCE=0
  for f in .tad/evidence/reviews/*.md; do
    [ -f "$f" ] || continue
    FSIZE=$(stat -f%z "$f" 2>/dev/null || stat -c%s "$f" 2>/dev/null || echo "0")
    if [ "$FSIZE" -lt "$MIN_SIZE" ]; then
      EMPTY_EVIDENCE=$((EMPTY_EVIDENCE + 1))
    fi
  done
  if [ "$EMPTY_EVIDENCE" -gt 0 ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: ${EMPTY_EVIDENCE} evidence file(s) in .tad/evidence/reviews/ are under ${MIN_SIZE} bytes — possibly empty stubs."
  fi
fi
```

### 检查 6: Completion Report Knowledge Assessment 已填写

```bash
# 检查 6: Knowledge Assessment 已填写（不是模板默认 "✅ Yes / ❌ No" 原文）
# 模板默认行是 "**是否有新发现？** ✅ Yes / ❌ No"（同时含 Yes 和 No）
# 填写后只保留一个（如 "**是否有新发现？** ❌ No"）
# 策略：如果同一行同时出现 Yes 和 No → 未填写（模板原文）
if [ -n "$COMPLETION_FILE" ]; then
  KA_LINE=$(grep '是否有新发现' "$COMPLETION_FILE" 2>/dev/null | head -1)
  if [ -n "$KA_LINE" ]; then
    HAS_YES=$(echo "$KA_LINE" | grep -c 'Yes' || echo "0")
    HAS_NO=$(echo "$KA_LINE" | grep -c 'No' || echo "0")
    if [ "$HAS_YES" -gt 0 ] && [ "$HAS_NO" -gt 0 ]; then
      WARNINGS="${WARNINGS}"$'\n'"WARNING: Knowledge Assessment appears unfilled (template default detected). Gate 3 requires choosing Yes or No."
    fi
  else
    WARNINGS="${WARNINGS}"$'\n'"WARNING: Knowledge Assessment section not found in completion report."
  fi
fi
```

### 检查 7: Completion Report Evidence Checklist 勾选率

```bash
# 检查 7: Evidence Checklist 有勾选项（不全是 [ ]）
if [ -n "$COMPLETION_FILE" ]; then
  CHECKED=$(grep -c '\[x\]' "$COMPLETION_FILE" 2>/dev/null || echo "0")
  UNCHECKED=$(grep -c '\[ \]' "$COMPLETION_FILE" 2>/dev/null || echo "0")
  TOTAL=$((CHECKED + UNCHECKED))
  if [ "$TOTAL" -gt 0 ] && [ "$CHECKED" = "0" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: Evidence Checklist has ${UNCHECKED} unchecked items and 0 checked items. Did you complete the checklist?"
  fi
fi
```

### 检查 8: Gate 3 v2 结果行含 PASS

```bash
# 检查 8: Gate 3 v2 结果不是 FAIL 或模板默认值
if [ -n "$COMPLETION_FILE" ]; then
  GATE3_RESULT=$(grep 'Gate 3 v2.*结果' "$COMPLETION_FILE" 2>/dev/null | head -1)
  if [ -n "$GATE3_RESULT" ]; then
    if echo "$GATE3_RESULT" | grep -q "FAIL"; then
      WARNINGS="${WARNINGS}"$'\n'"BLOCKED: Completion report shows Gate 3 v2 FAIL. Cannot proceed."
      HAS_BLOCK=1
    elif echo "$GATE3_RESULT" | grep -q "PASS"; then
      : # OK
    else
      WARNINGS="${WARNINGS}"$'\n'"WARNING: Gate 3 v2 result line found but doesn't contain PASS or FAIL — may be unfilled template."
    fi
  fi
fi
```

### 检查 9: AC 数量 vs 验证脚本数量

```bash
# 检查 9: Acceptance criteria count vs verification script count
if [ -n "$HANDOFF_FILE" ]; then
  # 数 handoff 中 AC 行数（以 "- [ ]" 开头的在 "Acceptance Criteria" 节下的行）
  AC_COUNT=$(sed -n '/## .*Acceptance Criteria/,/^## /p' "$HANDOFF_FILE" 2>/dev/null | grep -c '^\- \[' || echo "0")
  
  # 数 acceptance-tests 目录中 AC-* 文件数
  SCRIPT_COUNT=$(find .tad/evidence/acceptance-tests -name "AC-*" 2>/dev/null | wc -l | tr -d ' ')
  
  if [ "$AC_COUNT" -gt 0 ] && [ "$SCRIPT_COUNT" -gt 0 ] && [ "$SCRIPT_COUNT" -lt "$AC_COUNT" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: Handoff has ${AC_COUNT} acceptance criteria but only ${SCRIPT_COUNT} verification scripts found. Some ACs may not have been verified."
  fi
fi
```

### 检查 10: Ralph Loop state 显示 layer2 completed

```bash
# 检查 10: Ralph Loop state 显示完成状态（不只是文件存在）
RALPH_STATE=$(ls .tad/evidence/ralph-loops/*_state.yaml 2>/dev/null | head -1)
if [ -n "$RALPH_STATE" ]; then
  L2_DONE=$(grep 'last_completed_layer' "$RALPH_STATE" 2>/dev/null | grep -c 'layer2' || echo "0")
  if [ "$L2_DONE" = "0" ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: Ralph Loop state exists but last_completed_layer is not layer2. Did Layer 2 expert review complete?"
  fi
fi
```

### 检查 11: Expert review evidence ≥ 2 文件

```bash
# 检查 11: Expert review 文件数 ≥ 2（code-reviewer 必选 + 1 domain）
if [ -d ".tad/evidence/reviews" ]; then
  REVIEW_COUNT=$(find .tad/evidence/reviews -maxdepth 1 -name "*.md" -size +100c 2>/dev/null | wc -l | tr -d ' ')
  if [ "$REVIEW_COUNT" -lt 2 ]; then
    WARNINGS="${WARNINGS}"$'\n'"WARNING: Only ${REVIEW_COUNT} expert review file(s) found (≥2 required: code-reviewer + domain expert)."
  fi
fi
```

### 检查 12: Git commit hash 在 completion report 中非占位符

```bash
# 检查 12: Commit hash 不是占位符
if [ -n "$COMPLETION_FILE" ]; then
  COMMIT_LINE=$(grep -i 'commit.*hash\|changes committed' "$COMPLETION_FILE" 2>/dev/null | head -1)
  if [ -n "$COMMIT_LINE" ]; then
    if echo "$COMMIT_LINE" | grep -qE '\[hash\]|\[NONE\]|\[commit'; then
      WARNINGS="${WARNINGS}"$'\n'"WARNING: Commit hash in completion report appears to be a placeholder. Did you commit implementation changes?"
    fi
  fi
fi
```

## AC

- [ ] AC1: pre-gate-check.sh 有检查 5-12（8 个新增检查）
- [ ] AC2: `bash -n pre-gate-check.sh` 无语法错误
- [ ] AC3: 现有检查 1-4 不受影响（无回归）
- [ ] AC4: 所有新增检查用 defensive coding（2>/dev/null + 默认值 + 文件存在判断）
- [ ] AC5: Gate 3 v2 结果 FAIL 时 HAS_BLOCK=1（唯一新增的 BLOCK 项）
- [ ] AC6 (BLOCKING): 必须走 Ralph Loop + Gate 3

## Notes

- 每个检查独立封装，一个 check 失败不影响其他 check
- macOS 兼容：stat 用 `-f%z` fallback `-c%s`，grep 不用 `-P`
- 500ms 预算：全部是 grep/stat/find -maxdepth，无网络调用

**Handoff Created By**: Alex
