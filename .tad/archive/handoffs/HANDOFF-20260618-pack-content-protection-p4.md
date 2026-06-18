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
**Task ID:** TASK-20260618-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260617-pack-content-protection.md (Phase 4/4)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-18

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 2 已有 forked 跳过逻辑，只需加命令入口 |
| Components Specified | ✅ | 3 个新命令 + --help 更新 |
| Functions Verified | ✅ | copy_pack_skill_smart Case 2 (line 401-406) 已确认 |
| Data Flow Mapped | ✅ | --fork-pack → 写 meta → 下次 install 跳过 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

---

## 📋 Handoff Checklist (Blake必读)

Blake在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

### 1.1 Executive Summary
为 tad.sh 添加 `--fork-pack`、`--unfork-pack` 和 `--list-packs` 三个独立命令，让用户可以管理单个 pack 的同步策略。Forked pack 在安装/更新时完全跳过（Phase 2 已实现跳过逻辑），这些命令提供用户接口。

### 1.2 Background
Phase 2 的 `copy_pack_skill_smart` Case 2 已经处理 `sync_policy: forked`——读取 meta 发现 forked 就跳过复制。但目前没有办法让用户标记一个 pack 为 forked。Phase 4 补上这个入口。

### 1.3 Intent Statement
这是 Epic 的最后一个 Phase。完成后，用户有完整的 pack 内容保护工具链：哈希检测（P1）→ 智能覆盖（P2）→ 冲突解决（P3）→ 永久 fork（P4）。

---

## 2. Requirements

### 2.1 Functional Requirements

**FR1: `--fork-pack <name>` 命令**
- 在 `.claude/skills/<name>/.tad-pack-meta.yaml` 中将 `sync_policy` 改为 `forked`
- 如果 meta 不存在 → 报错："No meta file found. Run tad.sh --yes first to generate baseline."
- 如果 pack 目录不存在 → 报错："Pack '<name>' not found in .claude/skills/"
- 如果已经是 forked → 提示："'<name>' is already forked"
- 成功后输出："✓ '<name>' forked — will be skipped on future installs"
- 这是独立命令，不触发安装流程

**FR2: `--unfork-pack <name>` 命令**
- 将 `sync_policy` 从 `forked` 改为 `upstream`
- 如果不是 forked → 提示："'<name>' is not forked (current: upstream)"
- 成功后输出："✓ '<name>' unforked — will follow upstream on next install"
- 不重新生成哈希——下次 tad.sh 安装时，Phase 2/3 逻辑会正常比较现有哈希

**FR3: `--list-packs` 命令**
- 扫描 `$TARGET_SKILL_DIR/*/`，对每个 pack skill（`is_pack_skill` 返回 true）显示：
  - Pack 名称
  - sync_policy（upstream / forked）
  - baseline_source（fresh_install / migrated）
  - 文件数量
- 输出格式：
```
Pack                    Policy     Baseline       Files
────────────────────────────────────────────────────────
web-testing             upstream   fresh_install   6
ai-podcast-production   forked     fresh_install   8
rag-retrieval           upstream   migrated        5
────────────────────────────────────────────────────────
25 packs (23 upstream, 2 forked)
```
- 如果 pack 没有 meta → 显示 "no meta" 代替 policy/baseline

**FR4: 命令路由**
这三个命令是**独立操作**，不触发安装流程。在参数解析后、主安装逻辑之前检查：
```bash
if [ -n "$FORK_PACK" ]; then fork_pack "$FORK_PACK"; exit 0; fi
if [ -n "$UNFORK_PACK" ]; then unfork_pack "$UNFORK_PACK"; exit 0; fi
if [ "$LIST_PACKS" = "1" ]; then list_packs; exit 0; fi
```

---

## 3. Technical Design

### 3.1 参数解析

在现有参数解析块中增加：
```bash
FORK_PACK=""
UNFORK_PACK=""
LIST_PACKS=0
# ... in the case block:
--fork-pack)
    [ -z "${2:-}" ] && echo "tad.sh: --fork-pack requires a pack name" >&2 && exit 1
    FORK_PACK="$2"; shift 2 ;;
--unfork-pack)
    [ -z "${2:-}" ] && echo "tad.sh: --unfork-pack requires a pack name" >&2 && exit 1
    UNFORK_PACK="$2"; shift 2 ;;
--list-packs) LIST_PACKS=1; shift ;;
```

### 3.2 `fork_pack` 函数

```bash
# resolve_pack_dir <name> — find the skill dir across both platforms
resolve_pack_dir() {
    local name="$1"
    # Probe both platform dirs — use whichever exists
    if [ -d ".claude/skills/$name" ]; then echo ".claude/skills/$name"
    elif [ -d ".agents/skills/$name" ]; then echo ".agents/skills/$name"
    else return 1
    fi
}

fork_pack() {
    local name="$1"
    # ⚠️ P1 fix: validate pack name (no directory traversal)
    case "$name" in */*) echo "tad.sh: pack name must not contain '/'" >&2; exit 1 ;; esac

    local skill_dir
    skill_dir="$(resolve_pack_dir "$name")" || {
        echo "tad.sh: pack '$name' not found in .claude/skills/ or .agents/skills/" >&2; exit 1
    }
    local meta_file="$skill_dir/.tad-pack-meta.yaml"

    if [ ! -d "$skill_dir" ]; then
        echo "tad.sh: pack '$name' not found" >&2; exit 1
    fi
    if [ ! -f "$meta_file" ]; then
        echo "tad.sh: no meta file for '$name'. Run 'tad.sh --yes' first to generate baseline." >&2; exit 1
    fi

    local current
    current="$(grep '^sync_policy:' "$meta_file" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
    if [ "$current" = "forked" ]; then
        echo "'$name' is already forked"; exit 0
    fi

    # In-place update: replace sync_policy line
    sed -i.bak "s/^sync_policy:.*/sync_policy: forked/" "$meta_file" && rm -f "$meta_file.bak"
    echo "✓ '$name' forked — will be skipped on future installs"
}
```

### 3.3 `unfork_pack` 函数

```bash
unfork_pack() {
    local name="$1"
    case "$name" in */*) echo "tad.sh: pack name must not contain '/'" >&2; exit 1 ;; esac

    local skill_dir
    skill_dir="$(resolve_pack_dir "$name")" || {
        echo "tad.sh: pack '$name' not found in .claude/skills/ or .agents/skills/" >&2; exit 1
    }
    local meta_file="$skill_dir/.tad-pack-meta.yaml"

    if [ ! -d "$skill_dir" ]; then
        echo "tad.sh: pack '$name' not found" >&2; exit 1
    fi
    if [ ! -f "$meta_file" ]; then
        echo "tad.sh: no meta file for '$name'." >&2; exit 1
    fi

    local current
    current="$(grep '^sync_policy:' "$meta_file" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
    if [ "$current" != "forked" ]; then
        echo "'$name' is not forked (current: ${current:-upstream})"; exit 0
    fi

    sed -i.bak "s/^sync_policy:.*/sync_policy: upstream/" "$meta_file" && rm -f "$meta_file.bak"
    echo "✓ '$name' unforked — will follow upstream on next install"
}
```

### 3.4 `list_packs` 函数

```bash
list_packs() {
    # ⚠️ P0 fix: probe both platform dirs
    local skill_base=".claude/skills"
    [ ! -d "$skill_base" ] && skill_base=".agents/skills"
    [ ! -d "$skill_base" ] && echo "No .claude/skills/ or .agents/skills/ directory found" >&2 && exit 1

    printf '%-24s %-11s %-15s %s\n' "Pack" "Policy" "Baseline" "Files"
    printf '%.0s─' {1..60}; echo

    local total=0 forked_count=0
    local sd
    for sd in "$skill_base"/*/; do
        [ -d "$sd" ] || continue
        local name
        name="$(basename "$sd")"
        # Only list pack skills (skip alex, blake, gate, etc.)
        # Use pack-registry.yaml if available, else check for .tad-pack-meta.yaml
        local meta="$sd/.tad-pack-meta.yaml"
        [ ! -f "$meta" ] && [ ! -f ".tad/capability-packs/pack-registry.yaml" ] && continue
        if [ -f ".tad/capability-packs/pack-registry.yaml" ]; then
            grep -qF "name: \"${name}\"" ".tad/capability-packs/pack-registry.yaml" 2>/dev/null || continue
        elif [ ! -f "$meta" ]; then
            continue
        fi

        total=$((total + 1))
        local policy="—" baseline="—" file_count="—"
        if [ -f "$meta" ]; then
            policy="$(grep '^sync_policy:' "$meta" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
            [ -z "$policy" ] && policy="upstream"
            baseline="$(grep '^baseline_source:' "$meta" 2>/dev/null | sed 's/baseline_source:[[:space:]]*//' | tr -d '[:space:]"')"
            [ -z "$baseline" ] && baseline="—"
            file_count="$(grep -c '^  - path:' "$meta" 2>/dev/null || echo 0)"
            [ "$policy" = "forked" ] && forked_count=$((forked_count + 1))
        else
            policy="no meta"
        fi
        printf '%-24s %-11s %-15s %s\n' "$name" "$policy" "$baseline" "$file_count"
    done

    printf '%.0s─' {1..60}; echo
    local upstream_count=$((total - forked_count))
    echo "$total packs ($upstream_count upstream, $forked_count forked)"
}
```

### 3.5 命令路由

在 `--verify-denylist` exit block（约 line 1154）之后、ERR trap（约 line 1156）之前，增加。⚠️ 必须在 ERR trap 之前——独立命令失败不应触发安装回滚：
```bash
# Standalone commands — exit before install flow
if [ -n "$FORK_PACK" ]; then fork_pack "$FORK_PACK"; exit 0; fi
if [ -n "$UNFORK_PACK" ]; then unfork_pack "$UNFORK_PACK"; exit 0; fi
if [ "$LIST_PACKS" = "1" ]; then list_packs; exit 0; fi
```

### 3.6 实现要点

**⚠️ `sed -i` 移植性**：macOS BSD `sed -i` 需要备份扩展名（`sed -i.bak`），GNU `sed -i` 不需要。用 `sed -i.bak ... && rm -f *.bak` 保证两平台都工作。

**⚠️ 独立命令不需要 source/TARGET_VERSION**：这三个命令直接操作当前目录的 `.claude/skills/`，不依赖 TAD 源或安装流程变量。

**⚠️ `--help` 更新**：增加三行帮助文本。

---

## 4. Implementation Guide

### 4.1 Step-by-step

1. 在参数解析中增加 `--fork-pack`、`--unfork-pack`、`--list-packs`
2. 在 `resolve_conflict` 附近添加 `fork_pack`、`unfork_pack`、`list_packs` 函数
3. 在主流程入口前增加命令路由（`exit 0` 跳过安装）
4. 更新 `--help` 输出

### 4.2 Edge Cases

- **pack 名拼写错误**：`--fork-pack typo` → "not found in .claude/skills/" 报错
- **无 meta 的 pack**（从未运行过带 Phase 1 的 tad.sh）→ 报错提示先运行 `tad.sh --yes`
- **重复 fork/unfork**：幂等——已 forked 提示 "already forked"，已 upstream 提示 "not forked"
- **`--list-packs` 在无 pack-registry.yaml 的项目**：fallback 到检查 meta 文件存在性
- **`--fork-pack` + `--yes` 同时使用**：`--fork-pack` 是独立命令，`--yes` 无效（无确认步骤）

---

## 5. Scope

### 5.1 In Scope
- `--fork-pack <name>` 命令
- `--unfork-pack <name>` 命令
- `--list-packs` 命令
- `--help` 更新

### 5.2 Out of Scope
- Pack merge 工具
- 批量 fork/unfork
- 自动 fork 建议

---

## 6. Files to Modify

| File | Action | Description |
|------|--------|-------------|
| tad.sh | MODIFY | 3 个函数 + 参数解析 + 命令路由 + --help |

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- tad.sh (lines 44-70 arg parsing, lines 397-406 Case 2 forked logic — Phase 3 commit 0fd448c)

---

## 7. Testing Checklist

- [ ] `--fork-pack web-testing` → meta 中 sync_policy 变为 forked
- [ ] fork 后 `tad.sh --yes` → web-testing 显示 "forked (skipped)"
- [ ] `--unfork-pack web-testing` → sync_policy 恢复 upstream
- [ ] unfork 后 `tad.sh --yes` → web-testing 正常更新
- [ ] `--list-packs` → 表格输出，计数正确
- [ ] `--fork-pack nonexistent` → 报错退出
- [ ] `--fork-pack` 无参数 → 报错退出

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

无直接相关的历史教训——Phase 4 是全新的用户接口，不涉及已知的 shell 陷阱。

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | --fork-pack 写入 sync_policy: forked | `tad.sh --fork-pack web-testing && grep sync_policy .claude/skills/web-testing/.tad-pack-meta.yaml` | "sync_policy: forked" |
| AC2 | forked pack 被安装跳过 | fork → `tad.sh --yes` → 汇总输出 | "N forked" 在输出中 |
| AC3 | --unfork-pack 恢复 upstream | `tad.sh --unfork-pack web-testing && grep sync_policy ...` | "sync_policy: upstream" |
| AC4 | --list-packs 表格输出 | `tad.sh --list-packs` | 表格含 Pack/Policy/Baseline/Files 列 |
| AC5 | 不存在的 pack 报错 | `tad.sh --fork-pack bogus 2>&1` | 包含 "not found" + exit 非 0 |
| AC6 | 无参数报错 | `tad.sh --fork-pack 2>&1` | 包含 "requires a pack name" + exit 非 0 |
| AC7 | 重复 fork 幂等 | fork 两次 → 第二次 | "already forked" |
| AC8 | Change scope as planned | `git diff --stat` | 只有 tad.sh 变更 |

---

## 10. Decision Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| unfork 不重新生成哈希 | 保留现有哈希 | Phase 2/3 在下次安装时正确处理 |
| 独立命令不触发安装 | exit 0 after command | fork/unfork 是元数据操作，不应触发 file copy |
| sed -i.bak 模式 | 兼顾 macOS + Linux | BSD sed 需要备份扩展名 |

---

## Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0: fork/unfork 硬编码 .claude/skills/ | §3.2 resolve_pack_dir() 探测两平台 | ✅ Fixed |
| code-reviewer | P1: pack 名目录穿越 | §3.2/§3.3 case "$name" in */* 验证 | ✅ Fixed |
| code-reviewer | P1: routing 位置矛盾 (line 72 vs 1155) | §3.5 修正为 line 1154 后 ERR trap 前 | ✅ Fixed |
| code-reviewer | P1: list_packs 跳过无注册但有 meta 的 pack | Noted — Blake may add "(unregistered)" | ⏭️ Noted |
| code-reviewer | P1: 5x grep/sed 重复 | Noted — Blake may extract helper | ⏭️ Noted |
| shell-reviewer | PASS | 所有 shell 模式正确 | ✅ |

---

## 11. Required Evidence Manifest

```yaml
evidence:
  expert_reviews:
    required: true
    path: .tad/evidence/reviews/blake/pack-content-protection-p4/
  gate_verdicts:
    required: true
    path: .tad/evidence/gates/
  completion:
    required: true
    path: .tad/evidence/completions/COMPLETION-20260618-pack-content-protection-p4.md
  blake_reviews:
    required: true
    path: .tad/evidence/reviews/blake/pack-content-protection-p4/
  knowledge_updates:
    required: false
    path: .tad/project-knowledge/patterns/pack-build-rules.md
```
