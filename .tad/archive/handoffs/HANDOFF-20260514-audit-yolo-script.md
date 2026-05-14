# Handoff: audit-yolo.sh — YOLO Execution Audit Script

**From:** Alex | **To:** Blake | **Date:** 2026-05-14
**Priority:** P1
**Type:** Tool Creation
**Epic:** EPIC-20260514-yolo-mode.md (Phase 3/3 — Part A)

---
task_type: code
e2e_required: no
research_required: no
skip_knowledge_assessment: no
git_tracked_dirs:
  - .tad/hooks/lib/
---

## 1. Executive Summary

创建 audit-yolo.sh 审计脚本——在 YOLO 模式执行完 Epic 后、人类验收前运行，验证所有 TAD 过程文件真实存在且内容合理。4 个维度：产物链完整性、内容真实性、代码验证、时序合理性。

## 2. Technical Design

### 2.1 脚本规范

```
文件: .tad/hooks/lib/audit-yolo.sh
用法: bash .tad/hooks/lib/audit-yolo.sh <epic-slug>
输入: epic-slug（对应 .tad/evidence/yolo/{epic-slug}/ 目录）
输出: stdout 逐项检查结果（✅ / ❌），stderr 错误详情
退出: 0 = 全部通过 | 1 = 有失败项 | 2 = 用法错误
模式: 遵循 layer2-audit.sh 模式（纯 bash + set -euo pipefail + ANSI color）
依赖: 只用 bash 内建 + find + grep + stat + wc + git（无 jq/yq/python）
```

### 2.2 四维度检查

**维度 1: 产物链完整性 — "文件都在吗？"**

```bash
# 1. 确定 Phase 数量: 扫描 evidence 目录
phases=$(ls -d .tad/evidence/yolo/${slug}/phase*-grounding.md 2>/dev/null | 
         sed 's/.*phase\([0-9]*\)-.*/\1/' | sort -un)

# 2. 对每个 Phase N 检查 6 类 evidence 文件:
for n in $phases; do
  check_exists "phase${n}-grounding.md"
  check_exists "phase${n}-design-review-cr.md"
  check_exists_pattern "phase${n}-design-review-*.md" 2   # ≥2 files (cr + domain)
  check_exists "phase${n}-impl-review-cr.md"
  check_exists_pattern "phase${n}-impl-review-*.md" 2     # ≥2 files
  check_exists "phase${n}-gate-report.md"
done

# 3. 检查 handoff + completion 在 archive (Gate 通过后归档) 或 active:
for n in $phases; do
  check_handoff_exists "${slug}-phase${n}"    # 搜索 active/ 和 archive/
  check_completion_exists "${slug}-phase${n}"
done

# 4. 检查 Epic 级文件:
check_exists "EPIC-COMPLETION.md"

# 5. Git commits:
for n in $phases; do
  git log --oneline --grep="YOLO Phase ${n}" | grep -q . || fail "No git commit for Phase ${n}"
done
```

**维度 2: 内容真实性 — "不是空壳吗？"**

```bash
for n in $phases; do
  # Review 文件引用了具体代码位置 (file:line 或 line N 模式)
  # (file:line grep 已替换为 minimum-lines + P0/P1/P2 classification — see below)
  
  # Completion 有 AC 对照表
  grep -qE "\| AC" "../../active/handoffs/COMPLETION-*-${slug}-phase${n}.md" 2>/dev/null ||
  grep -qE "\| AC" "../../archive/handoffs/COMPLETION-*-${slug}-phase${n}.md" 2>/dev/null ||
    fail "Completion missing AC table"
  
  # Gate report 有 verdict
  grep -qiE "PASS|FAIL|PARTIAL" "phase${n}-gate-report.md" || 
    fail "Gate report missing verdict"
  
  # Gate report 有 Knowledge Assessment 声明 (BA P0-1: step_Y8 contract)
  grep -qiE "Knowledge Assessment|KA:|no new discover" "phase${n}-gate-report.md" ||
    fail "Gate report missing Knowledge Assessment section"
  
  # Review 内容真实性: 最小行数 + 结构化分类 (BA P1-2: 替代 file:line grep)
  review_lines=$(wc -l < "phase${n}-design-review-cr.md" 2>/dev/null || echo 0)
  [ "$review_lines" -ge 20 ] || fail "Design review too short (${review_lines} lines, need ≥20)"
  grep -qE "P0|P1|P2|PASS|no issues|no critical" "phase${n}-design-review-cr.md" ||
    fail "Design review missing P0/P1/P2 classification"
  
  # Handoff AC 数量 ≈ Completion AC 数量 (允许 ±2 偏差)
  # (handoff 可能在 active 或 archive)
  handoff_acs=$(grep -cE "^\- \[ \]" handoff_file 2>/dev/null || echo 0)
  completion_acs=$(grep -cE "\| AC" completion_file 2>/dev/null || echo 0)
  diff=$((handoff_acs - completion_acs)); diff=${diff#-}
  [ "$diff" -le 2 ] || warn "AC count mismatch: handoff=${handoff_acs} completion=${completion_acs}"
done
```

**维度 3: 代码验证 — "客观重跑"**

```bash
# tsc (如果项目有 tsconfig.json)
if [ -f "tsconfig.json" ]; then
  npx tsc --noEmit 2>&1 || fail "tsc --noEmit failed"
fi

# npm test (如果 package.json 有 test script)
if grep -q '"test"' package.json 2>/dev/null; then
  npm test 2>&1 || warn "npm test failed (may be pre-existing)"
fi
```

**维度 4: 时序合理性 — "顺序对吗？"**

```bash
for n in $phases; do
  # 文件修改时间应为: grounding < design-review < gate-report
  t_grounding=$(stat_mtime "phase${n}-grounding.md")
  t_review=$(stat_mtime "phase${n}-design-review-cr.md")
  t_gate=$(stat_mtime "phase${n}-gate-report.md")
  
  [ "$t_grounding" -le "$t_review" ] || warn "Phase ${n}: grounding timestamp > review timestamp"
  [ "$t_review" -le "$t_gate" ] || warn "Phase ${n}: review timestamp > gate timestamp"
done

# Epic Phase status 全部 Done
epic_file=$(find .tad/archive/epics .tad/active/epics -name "EPIC-*-${slug}*" 2>/dev/null | head -1)
if [ -n "$epic_file" ]; then
  planned=$(grep -c "⬚ Planned" "$epic_file" 2>/dev/null || echo 0)
  active=$(grep -c "🔄 Active" "$epic_file" 2>/dev/null || echo 0)
  [ "$planned" -eq 0 ] && [ "$active" -eq 0 ] || fail "Epic has non-Done phases: ${planned} planned, ${active} active"
fi
```

### 2.3 输出格式

```
audit-yolo: EPIC-20260514-multilingual-expansion (3 phases detected)

Phase 1:
  ✅ grounding.md exists (142 lines)
  ✅ design-review-cr.md exists (89 lines, has file:line refs)
  ✅ design-review-backend-architect.md exists (76 lines)
  ✅ impl-review-cr.md exists (95 lines, has file:line refs)
  ✅ impl-review-backend-architect.md exists (82 lines)
  ✅ gate-report.md exists (verdict: PASS)
  ✅ HANDOFF found in archive
  ✅ COMPLETION found in archive
  ✅ Git commit found: abc1234

Phase 2:
  ...

Epic-level:
  ✅ EPIC-COMPLETION.md exists
  ✅ All phases Done in Epic file
  ✅ tsc --noEmit passed
  ⚠️ npm test: 1 pre-existing failure (non-blocking)

Timing:
  ✅ Phase 1 file order correct
  ✅ Phase 2 file order correct

━━━━━━━━━━━━━━━━━━━━━
RESULT: PASS (27/27 checks, 1 warning)
```

### 2.4 Helper 函数

参考 layer2-audit.sh 的模式：
- `_err()` — 红色 stderr 输出
- `_warn()` — 黄色 stdout 输出
- `_pass()` — 绿色 stdout 输出（✅）
- `_fail()` — 红色 stdout 输出（❌）+ 累加失败计数
- `_file_size()` — BSD/GNU stat 兼容
- `stat_mtime()` — BSD/GNU stat 获取修改时间（秒级 epoch）

## 3. Files to Create

| # | File | Action | Description |
|---|------|--------|-------------|
| 1 | `.tad/hooks/lib/audit-yolo.sh` | CREATE | 审计脚本，~150-200 行 |

**Grounded Against:**
- `.tad/hooks/lib/layer2-audit.sh` head 30 (模式参考, read at 2026-05-14)
- Alex SKILL.md yolo_evidence_structure (文件命名规范, read at 2026-05-14)
- Alex SKILL.md yolo_execution_protocol step_Y1 (handoff/completion 路径规范, read at 2026-05-14)

## 4. Acceptance Criteria

- [ ] AC1: `audit-yolo.sh` 接受 1 个参数 (epic-slug)，exit 2 on 无参数
- [ ] AC2: 维度 1 检查每个 Phase 的 6 类 evidence 文件 + handoff + completion + git commit
- [ ] AC3: 维度 2 检查 review 最小行数(≥20) + P0/P1/P2 分类 + completion 有 AC 表 + gate 有 verdict + gate 有 KA 声明
- [ ] AC4: 维度 3 重跑 tsc --noEmit（如有 tsconfig.json）
- [ ] AC5: 维度 4 检查文件时序 + Epic Phase status 全部 Done
- [ ] AC6: exit 0 全部通过，exit 1 有任何 ❌ 项
- [ ] AC7: 输出格式匹配 §2.3（per-Phase 分组，最终 RESULT 行）
- [ ] AC8: 无 jq/yq/python 依赖（纯 bash + coreutils）
- [ ] AC9: BSD/GNU stat 兼容（macOS + Linux）

## 5. Implementation Notes

- 参考 `layer2-audit.sh` 的 `set -euo pipefail` + ANSI color + `_file_size()` 模式
- Handoff/completion 文件可能在 `active/handoffs/` 或 `archive/handoffs/`——两个目录都要搜
- 时序检查用 `stat -f%m`（BSD）或 `stat -c%Y`（GNU）获取 epoch 秒
- Phase 数量从 evidence 目录动态检测（不硬编码）
- `npm test` 失败是 warn 不是 fail（可能有 pre-existing 失败）
- 脚本开头加 `# No hook registration. No settings.json. Pure CLI tool.` 注释

## 6. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/audit-yolo-script/code-reviewer.md
completion:
  - .tad/active/handoffs/COMPLETION-20260514-audit-yolo-script.md
```

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Hook Shell Portability: No grep -P on macOS** (architecture.md): BSD grep 没有 -P。用 grep -E 或 grep + sed。
- **Hook Performance: Single-awk vs Per-item grep Loop** (architecture.md): 如果有循环检查，用单次 awk 而不是循环 grep。但 audit-yolo.sh 是一次性工具不是热路径，性能不关键。
