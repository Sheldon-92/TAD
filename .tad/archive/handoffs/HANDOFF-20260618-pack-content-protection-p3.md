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
**Date:** 2026-06-18
**Project:** TAD Framework
**Task ID:** TASK-20260618-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260617-pack-content-protection.md (Phase 3/4)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-18

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 基于 Phase 2 Case 4 的精确扩展点 |
| Components Specified | ✅ | 只改 tad.sh 一个文件，修改点在 line 464-472 |
| Functions Verified | ✅ | copy_pack_skill_smart 已确认（line 377-480） |
| Data Flow Mapped | ✅ | installed_hash vs current_hash vs source_hash 三方比较 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史经验**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 Executive Summary
在 Phase 2 的"customized → preserve"基础上，增加三方冲突检测：当下游修改了文件 **且** 上游也更新了同一文件时，展示 diff 让用户逐文件决定（保留本地/用上游）。非交互模式（`--yes`）默认保留本地并输出 CONFLICT 日志。同时增加 `--resolve` 参数让用户预先指定冲突策略。

### 1.2 Background
Phase 2 (commit 70ea84e) 的 `copy_pack_skill_smart` Case 4 在检测到 `current_hash != installed_hash` 时一律 preserve。但这里有两种情况：
1. **只有本地改了**（upstream 没变）→ preserve 是正确的
2. **双方都改了**（upstream 也更新了）→ preserve 会错过上游的修复/改进

Phase 3 区分这两种情况，对情况 2 提供交互式冲突解决。

### 1.3 Intent Statement
将 Phase 2 的"customized → 一律 preserve"细化为"customized + upstream unchanged → preserve"和"customized + upstream ALSO changed → CONFLICT → 用户决定"。

---

## 2. Requirements

### 2.1 Functional Requirements

**FR1: 三方冲突检测**
在 Case 4 的 "customized" 分支（current line 468-471），增加 source hash 比较：
```
当 current_hash != installed_hash（本地被修改）:
  计算 source_hash = hash(新上游文件)
  如果 source_hash == installed_hash → 上游没变，只有本地改了 → preserve（Phase 2 行为不变）
  如果 source_hash != installed_hash → 双方都改了 → CONFLICT
```

**FR2: 交互式冲突解决**
当检测到 CONFLICT 且为交互模式（`AUTO_YES=0`）：
1. 输出冲突提示和 diff 前 30 行
2. 用 `read -p` 提示用户选择：
   - `l`（默认）: 保留本地
   - `u`: 用上游版本
   - `d`: 显示完整 diff 后再选

**FR3: 非交互模式（--yes）**
当 `AUTO_YES=1` 时：
- 不 `read`，默认保留本地
- 输出 CONFLICT 日志：`log_warn "    $skill_name/$rel: CONFLICT (both changed, local preserved)"`

**FR4: `--resolve` 参数**
新增命令行参数 `--resolve=local|upstream|ask`：
- `local`: 冲突时始终保留本地（与 `--yes` 组合时的默认行为）
- `upstream`: 冲突时始终用上游版本（"重置到上游"场景）
- `ask`: 逐文件交互（默认行为，无 `--yes` 时）
- 未指定时：有 `--yes` → `local`，无 `--yes` → `ask`

**FR5: PACK_STATS_CONFLICTS 计数器**
在 PACK_STATS 系列中增加 CONFLICTS 计数，汇总输出中包含："C conflicts (local preserved)" 或 "C conflicts (resolved)"。

---

## 3. Technical Design

### 3.1 修改点：`copy_pack_skill_smart` Case 4

**当前代码**（line 464-472）：
```bash
if [ "$current_hash" = "$installed_hash" ]; then
    # Pristine → safe to overwrite
    cp "$src_file" "$tgt_dir/$rel"
    updated=$((updated + 1))
else
    # Customized → preserve + warn
    modified=$((modified + 1))
    log_warn "    $skill_name/$rel: customized (preserved)"
fi
```

**改为**：
```bash
if [ "$current_hash" = "$installed_hash" ]; then
    # Pristine → safe to overwrite
    cp "$src_file" "$tgt_dir/$rel"
    updated=$((updated + 1))
else
    # Local was modified. Check if upstream also changed.
    local source_hash
    source_hash="$($sha_cmd "$src_file" 2>/dev/null | cut -d' ' -f1)" || { log_warn "    $skill_name/$rel: hash failed, preserving local"; modified=$((modified + 1)); continue; }

    if [ "$source_hash" = "$installed_hash" ]; then
        # Only local changed → preserve (Phase 2 behavior)
        modified=$((modified + 1))
        log_warn "    $skill_name/$rel: customized (preserved)"
    else
        # CONFLICT: both local AND upstream changed
        resolve_conflict "$skill_name" "$rel" "$tgt_dir/$rel" "$src_file"
    fi
fi
```

### 3.2 新函数：`resolve_conflict`

```bash
# Modifies caller's local: modified, updated. Requires PACK_STATS_CONFLICTS in outer scope.
resolve_conflict() {
    local skill_name="$1" rel="$2" tgt_file="$3" src_file="$4"
    PACK_STATS_CONFLICTS=$((PACK_STATS_CONFLICTS + 1))

    # Determine resolution strategy
    local strategy="$RESOLVE_STRATEGY"
    if [ -z "$strategy" ] && [ "$AUTO_YES" = "1" ]; then
        strategy="local"
    fi

    case "$strategy" in
        local)
            log_warn "    $skill_name/$rel: CONFLICT (both changed, local preserved)"
            modified=$((modified + 1))
            ;;
        upstream)
            # ⚠️ P0 fix: backup before overwrite (irreversible data loss prevention)
            cp "$tgt_file" "$tgt_file.tad-conflict-backup" 2>/dev/null || true
            log_warn "    $skill_name/$rel: CONFLICT (both changed, upstream applied; backup: ${rel}.tad-conflict-backup)"
            cp "$src_file" "$tgt_file"
            updated=$((updated + 1))
            ;;
        *)
            # ask (default interactive)
            log_warn "    $skill_name/$rel: CONFLICT — both local and upstream changed"
            echo "    --- diff (first 30 lines) ---"
            # ⚠️ P0 fix: --label for clear LOCAL/UPSTREAM identification
            diff -u --label "LOCAL: $skill_name/$rel" --label "UPSTREAM: $skill_name/$rel" \
                "$tgt_file" "$src_file" 2>/dev/null | head -30 || true
            echo "    ---"
            local choice=""
            # ⚠️ P0 fix: fallback MUST be in code, not just prose notes
            read -p "    Keep YOUR version (l) / Use NEW upstream (u) / Full diff (d)? [l]: " choice </dev/tty 2>/dev/null || { choice="l"; log_warn "    (non-TTY: defaulting to local)"; }
            case "$choice" in
                u|U)
                    cp "$tgt_file" "$tgt_file.tad-conflict-backup" 2>/dev/null || true
                    cp "$src_file" "$tgt_file"
                    updated=$((updated + 1))
                    log_info "    (backup saved: ${rel}.tad-conflict-backup)"
                    ;;
                d|D)
                    diff -u --label "LOCAL: $skill_name/$rel" --label "UPSTREAM: $skill_name/$rel" \
                        "$tgt_file" "$src_file" 2>/dev/null || true
                    echo "    File: $skill_name/$rel"
                    local choice2=""
                    read -p "    Keep YOUR version (l) / Use NEW upstream (u)? [l]: " choice2 </dev/tty 2>/dev/null || { choice2="l"; log_warn "    (non-TTY: defaulting to local)"; }
                    if [ "$choice2" = "u" ] || [ "$choice2" = "U" ]; then
                        cp "$tgt_file" "$tgt_file.tad-conflict-backup" 2>/dev/null || true
                        cp "$src_file" "$tgt_file"
                        updated=$((updated + 1))
                        log_info "    (backup saved: ${rel}.tad-conflict-backup)"
                    else
                        modified=$((modified + 1))
                    fi
                    ;;
                *)
                    modified=$((modified + 1))
                    ;;
            esac
            ;;
    esac
}
```

### 3.3 参数解析

在 tad.sh 开头的参数解析循环中（line 46-70 区域），增加：
```bash
RESOLVE_STRATEGY=""
# ... in the case block:
--resolve=*) RESOLVE_STRATEGY="${1#--resolve=}"; shift ;;
```

**⚠️ P1 fix: 参数验证**（匹配 `--platform` 的验证模式，line 147）：
```bash
# After arg parsing loop, before main logic:
if [ -n "$RESOLVE_STRATEGY" ]; then
    case "$RESOLVE_STRATEGY" in
        local|upstream|ask) ;;
        *) echo "tad.sh: --resolve must be local, upstream, or ask" >&2; exit 1 ;;
    esac
fi
```

在 `--help` 输出中增加：
```bash
echo "  --resolve=MODE     conflict strategy: local (keep yours), upstream (take new), ask (interactive)"
echo "                     default: ask, or local with --yes"
```

### 3.4 汇总输出更新

修改 line 709 的汇总输出，增加 CONFLICTS：
```bash
log_info "  → Pack status: $PACK_STATS_UPDATED updated, $PACK_STATS_CUSTOMIZED customized (preserved), $PACK_STATS_NEW new, $PACK_STATS_FORKED forked, $PACK_STATS_MIGRATED migrated, $PACK_STATS_CONFLICTS conflicts"
```

**⚠️ P1 fix: --yes 模式下冲突不可见的补救**：当 `AUTO_YES=1` 且 `PACK_STATS_CONFLICTS > 0` 时，汇总后额外输出：
```bash
if [ "$AUTO_YES" = "1" ] && [ "$PACK_STATS_CONFLICTS" -gt 0 ]; then
    log_warn "  ⚠ $PACK_STATS_CONFLICTS conflict(s) auto-preserved. Run 'tad.sh --resolve=ask' to review them."
fi
```

### 3.5 实现要点

**⚠️ `read` fallback 已集成到 §3.2 代码块中**——两个 `read` 调用都有 `|| { choice="l"; log_warn "non-TTY"; }` 保护。不需要额外处理。

**⚠️ `modified` 和 `updated` 变量**：这些是 `copy_pack_skill_smart` 的 local 变量。`resolve_conflict` 通过 bash 动态作用域修改它们（与 PACK_STATS_* 模式一致）。

**⚠️ 备份文件清理**：`.tad-conflict-backup` 文件在当前 Phase 不自动清理。用户手动删除或未来 Phase 添加过期清理。

**⚠️ diff 输出格式**：用 `diff -u`（unified diff），local 用 `---`，upstream 用 `+++`。提示文本要说清楚哪个是哪个。

---

## 4. Implementation Guide

### 4.1 Step-by-step

1. 在参数解析中增加 `--resolve=*` 和 `RESOLVE_STRATEGY` 变量
2. 在 `copy_pack_skill_smart` 附近添加 `resolve_conflict` 函数
3. 修改 Case 4 的 else 分支：增加 source_hash 比较 + 调用 resolve_conflict
4. 在 PACK_STATS 初始化中增加 `PACK_STATS_CONFLICTS=0`
5. 更新汇总输出包含 CONFLICTS 计数
6. 更新 `--help` 输出包含 `--resolve` 说明

### 4.2 Edge Cases

- **非 TTY 环境**（CI/CD, `curl | bash`）：`read </dev/tty` 失败 → fallback to `local`
- **上游文件内容变了但哈希碰撞**：理论上 SHA-256 碰撞概率可忽略
- **`--resolve=upstream` + 已修改文件**：直接覆盖，不再提示——用户明确要重置
- **"both" 平台**：resolve_conflict 在两个 loop 中都生效（通过 copy_pack_skill_smart 调用）

---

## 5. Scope

### 5.1 In Scope
- tad.sh Case 4 增加三方冲突检测
- resolve_conflict 交互式解决函数
- `--resolve` 参数
- PACK_STATS_CONFLICTS 计数

### 5.2 Out of Scope
- fork 命令（Phase 4）
- 三方 merge 工具集成（超出 TAD 框架范围）

---

## 6. Files to Modify

| File | Action | Description |
|------|--------|-------------|
| tad.sh | MODIFY | resolve_conflict 函数 + Case 4 扩展 + --resolve 参数 + 汇总更新 |

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- tad.sh (lines 375-480 copy_pack_skill_smart, lines 44-70 arg parsing, line 709 summary — Phase 2 commit 70ea84e)

---

## 7. Testing Checklist

- [ ] 模拟双方修改（修改目标文件 + 修改源文件）→ 运行 tad.sh → 看到 CONFLICT 提示和 diff
- [ ] 交互模式选 `l` → 本地保留
- [ ] 交互模式选 `u` → 上游版本覆盖
- [ ] 交互模式选 `d` → 完整 diff 展示后再选
- [ ] `--yes` 模式 → 默认保留本地 + CONFLICT 日志
- [ ] `--resolve=upstream` → 冲突时自动用上游
- [ ] 仅本地修改（上游没变）→ Phase 2 行为不变（preserve，无 CONFLICT 提示）
- [ ] 未修改的文件 → 正常覆盖（不受影响）

---

## 8. Important Notes

### 8.1 Friction Preflight
- Phase 2 的 copy_pack_skill_smart 和 sha_cmd 已存在
- AUTO_YES 全局变量已存在（line 46）
- diff 命令是 macOS/Linux 标准工具

### 8.2 Known Risks
- `read </dev/tty` 在 Docker 等无 TTY 环境中失败——已有 fallback
- POSIX 函数语法（`name() {`）
- resolve_conflict 修改 caller 的 `modified`/`updated` local 变量——与 PACK_STATS 模式一致

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

| Entry | Source | Relevance |
|-------|--------|-----------|
| Hash Manifests Must Record SOURCE Hashes | pack-build-rules.md (Phase 2 KA) | source_hash 比较用的是新上游文件哈希，不是 meta 里的——meta 里已经是 SOURCE 哈希（Phase 2 修复） |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | 双方修改时展示 CONFLICT 提示 | 修改目标和源 → tad.sh → 输出包含 "CONFLICT" | CONFLICT 提示 + diff 预览 |
| AC2 | 交互选 l → 本地保留 | CONFLICT → 输入 l → 验证文件 | 本地版本未变 |
| AC3 | 交互选 u → 上游覆盖 | CONFLICT → 输入 u → 验证文件 | 文件 == 上游版本 |
| AC4 | --yes 默认保留本地 | tad.sh --yes → CONFLICT 日志 | "local preserved" 在输出中 |
| AC5 | --resolve=upstream 自动覆盖 | tad.sh --resolve=upstream → 无交互 → 文件被覆盖 | 文件 == 上游版本 |
| AC6 | 仅本地修改（上游没变）→ preserve 不变 | 只改目标 → tad.sh → 无 CONFLICT 提示 | "customized (preserved)" |
| AC7 | 汇总包含 conflicts 计数 | tad.sh 输出 "Pack status:" 行 | 包含 "N conflicts" |
| AC8 | Change scope as planned | `git diff --stat` | 只有 tad.sh 变更 |
| AC9 | 非 TTY 环境冲突不崩溃 | 模拟双方修改 → `echo "" \| tad.sh` (stdin 非 tty) → 不 crash | "non-TTY: defaulting to local" 日志 + 正常退出 |
| AC10 | --resolve 参数验证 | `tad.sh --resolve=bogus` → 报错退出 | "must be local, upstream, or ask" |

---

## 10. Decision Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| 冲突默认策略 | 保留本地（安全优先） | 丢失用户定制比错过上游更新更痛 |
| 交互方式 | read -p </dev/tty | tad.sh 可能通过 curl \| bash 运行，stdin 被管道占用 |
| --resolve 参数 | local\|upstream\|ask | 覆盖所有场景：安全默认/重置/逐文件 |
| diff 格式 | unified diff (diff -u) | 最可读的标准格式 |

---

## Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| UX | P0: diff 标签显示原始路径 | §3.2 `--label LOCAL/UPSTREAM` | ✅ Fixed |
| UX | P0: 覆盖无备份 | §3.2 `.tad-conflict-backup` before cp | ✅ Fixed |
| Code | P0: read fallback 只在注释不在代码 | §3.2 两个 read 都有 `\|\| choice="l"` | ✅ Fixed |
| UX | P1: --yes 冲突不可见 | §3.4 advisory log_warn | ✅ Fixed |
| Code | P1: --resolve 无验证 | §3.3 case 验证 | ✅ Fixed |
| Code | P1: source_hash 失败静默跳过 | §3.1 `\|\| { log_warn; continue }` | ✅ Fixed |
| UX | P1: 提示文本 local→YOUR version | §3.2 prompt reworded | ✅ Fixed |
| Code | P1: resolve_conflict 缺作用域注释 | §3.2 comment added | ✅ Fixed |
| UX | P1: 汇总缺冲突文件列表 | Noted — Blake may collect paths | ⏭️ Noted |
| Code | P1: pre-Phase-2 meta 兼容性 | Noted — Phase 2 meta已是source hash | ⏭️ Noted |
| UX | P2: non-TTY emit log | §3.2 integrated into read fallback | ✅ Fixed |
| UX | P2: full diff 后重印文件名 | §3.2 `echo File:` before 2nd read | ✅ Fixed |
| Code | P2: AC 缺 non-TTY 测试 | §9.1 AC9 added | ✅ Fixed |

---

## 11. Required Evidence Manifest

```yaml
evidence:
  expert_reviews:
    required: true
    path: .tad/evidence/reviews/blake/pack-content-protection-p3/
  gate_verdicts:
    required: true
    path: .tad/evidence/gates/
  completion:
    required: true
    path: .tad/evidence/completions/COMPLETION-20260618-pack-content-protection-p3.md
  blake_reviews:
    required: true
    path: .tad/evidence/reviews/blake/pack-content-protection-p3/
  knowledge_updates:
    required: false
    path: .tad/project-knowledge/patterns/pack-build-rules.md
```
