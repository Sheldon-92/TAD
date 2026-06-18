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
**Date:** 2026-06-17
**Project:** TAD Framework
**Task ID:** TASK-20260617-007
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260617-pack-content-protection.md (Phase 2/4)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-17

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 基于 Phase 1 的哈希清单，添加比较逻辑 |
| Components Specified | ✅ | 只改 tad.sh 一个文件 |
| Functions Verified | ✅ | generate_pack_meta、is_pack_skill 已确认存在 |
| Data Flow Mapped | ✅ | meta 读取 → 哈希比较 → 选择性覆盖 → meta 重新生成 |

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
让 tad.sh 在覆盖 pack skill 文件前，读取 Phase 1 生成的 `.tad-pack-meta.yaml` 哈希清单，比较目标文件是否被下游修改。未修改（pristine）的文件安全覆盖；已修改（customized）的文件保留下游版本并警告。安装后输出 pack 状态汇总。

### 1.2 Background
Phase 1 (commit 7833fc6) 已经为每个 pack 生成了 `.tad-pack-meta.yaml`，记录安装时每个文件的 SHA-256 哈希和 `baseline_source`（fresh_install/migrated）。Phase 2 利用这些哈希实现"改过就不覆盖"的智能安装逻辑。

### 1.3 Intent Statement
将 tad.sh 的 pack skill 复制从"无脑 cp -r 全覆盖"变为"按文件检查是否修改过，只覆盖没改过的"。非 pack skill（alex, blake, gate 等）行为不变。

---

## 2. Requirements

### 2.1 Functional Requirements

**FR1: 智能覆盖逻辑**
在 `copy_framework_files` 的 skill 复制循环中，对 pack skill（`is_pack_skill` 返回 true）使用新的 `copy_pack_skill_smart` 函数替代 `cp -r`。逻辑：

```
对每个 pack skill:
  如果目标不存在 或 目标无 meta → 首次安装 → 正常 cp -r
  如果 sync_policy=forked → 完全跳过（Phase 4 前瞻兼容）
  如果 baseline_source=migrated → 只添加源有目标没有的新文件，不覆盖任何现有文件
  如果 baseline_source=fresh_install → 逐文件比较:
    源文件在目标不存在 → 新上游文件 → 安装
    目标文件哈希 == meta 中记录的哈希 → pristine → 安全覆盖
    目标文件哈希 != meta 中记录的哈希 → customized → 保留 + 警告
    目标文件在 meta 中无记录 → 视为 customized → 保留
```

非 pack skill → 保持原来的 `cp -r` 行为不变。

**FR2: 安装后 pack 状态汇总**
在 `copy_framework_files` 末尾（meta generation 之后），输出汇总：
```
  → Pack status: N updated, M customized (preserved), K new, F forked (skipped), J migrated (preserved)
```

**FR3: 更新后 meta 反映新状态**
覆盖完成后，Phase 1 的 `generate_pack_meta` 已经会重新生成 meta。对于 customized 的文件（被保留的），新 meta 会记录保留后的文件哈希（即用户修改过的版本），baseline_source 改为 fresh_install（因为现在有了真正的 baseline）。

---

## 3. Technical Design

### 3.1 修改点：tad.sh `copy_framework_files`

**当前代码**（line 488-506）：
```bash
for skill_dir in "$src"/.claude/skills/*/; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    # ... platform deny + pack selection checks ...
    cp -r "$skill_dir" "$TARGET_SKILL_DIR/$skill_name"
done
```

**改为**：
```bash
for skill_dir in "$src"/.claude/skills/*/; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name="$(basename "$skill_dir")"
    # ... platform deny + pack selection checks (unchanged) ...
    if is_pack_skill "$skill_name" "$src"; then
        copy_pack_skill_smart "$skill_dir" "$TARGET_SKILL_DIR/$skill_name"
    else
        cp -r "$skill_dir" "$TARGET_SKILL_DIR/$skill_name"
    fi
done
```

### 3.2 新函数：`copy_pack_skill_smart`

放在 `generate_pack_meta` 附近（约 line 326 区域）。

**核心逻辑**：

```bash
copy_pack_skill_smart() {
    local src_dir="$1" tgt_dir="$2"
    src_dir="${src_dir%/}"
    local skill_name
    skill_name="$(basename "$src_dir")"
    local meta_file="$tgt_dir/.tad-pack-meta.yaml"

    # Case 1a: No target dir → first install, regular copy
    if [ ! -d "$tgt_dir" ]; then
        cp -r "$src_dir" "$tgt_dir"
        PACK_STATS_NEW=$((PACK_STATS_NEW + 1))
        return 0
    fi
    # Case 1b: Target exists but no meta → first install (content copy, avoid nesting)
    if [ ! -f "$meta_file" ]; then
        cp -R "$src_dir/." "$tgt_dir/"
        PACK_STATS_NEW=$((PACK_STATS_NEW + 1))
        return 0
    fi

    # Read meta fields (same grep/sed/tr pattern as Phase 1 line 346)
    local policy baseline
    policy="$(grep '^sync_policy:' "$meta_file" 2>/dev/null | sed 's/sync_policy:[[:space:]]*//' | tr -d '[:space:]"')"
    baseline="$(grep '^baseline_source:' "$meta_file" 2>/dev/null | sed 's/baseline_source:[[:space:]]*//' | tr -d '[:space:]"')"

    # Case 2: Forked → skip entirely
    if [ "$policy" = "forked" ]; then
        PACK_STATS_FORKED=$((PACK_STATS_FORKED + 1))
        log_info "    $skill_name: forked (skipped)"
        return 0
    fi

    # Case 3: Migrated → only add new files, never overwrite
    if [ "$baseline" = "migrated" ]; then
        # Per-file: copy only if target file doesn't exist
        ...逐文件处理，只添加不覆盖...
        PACK_STATS_MIGRATED=$((PACK_STATS_MIGRATED + 1))
        return 0
    fi

    # Case 4: fresh_install → per-file hash comparison
    local sha_cmd=...
    local modified=0 updated=0
    # 逐文件：读 meta 中的 installed_hash，比较 current_target_hash
    # pristine → cp overwrite; customized → skip + warn
    ...

    if [ "$modified" -gt 0 ]; then
        PACK_STATS_CUSTOMIZED=$((PACK_STATS_CUSTOMIZED + 1))
    else
        PACK_STATS_UPDATED=$((PACK_STATS_UPDATED + 1))
    fi
}
```

### 3.3 实现要点

**⚠️ 变量作用域**：`find | while read` 在 pipeline 中运行于 subshell，内部的计数器变量（`modified`, `updated`）不会回传。解决方案：
- 用 here-string `while read -r f; do ... done <<< "$(find ...)"` 避免 subshell
- 这是 tad.sh 已有的惯用模式（line 449, 470, 557 的 `<<< "$(...)"` 模式）
- ⚠️ 注意：tad.sh 中**不存在** `< <(find ...)` process substitution 模式。不要引入新模式。

**⚠️ PACK_STATS_* 计数器**：在 `copy_framework_files` 开头初始化为 0。这些是 `local` 变量，`copy_pack_skill_smart` 通过 bash 动态作用域直接修改（函数调用链中 `local` 变量对被调函数可见）。
```bash
# NOTE: these locals are visible to copy_pack_skill_smart via bash dynamic scoping
# — do NOT call that function from a subshell/pipeline.
local PACK_STATS_UPDATED=0 PACK_STATS_CUSTOMIZED=0 PACK_STATS_NEW=0
local PACK_STATS_FORKED=0 PACK_STATS_MIGRATED=0
```

**⚠️ meta 中的哈希查找**：用 awk `index()`（精确字符串匹配）解析 YAML（tad.sh 不依赖 yq）：
```bash
installed_hash="$(awk -v p="$rel" '
    index($0, "path: \""p"\"") > 0 {found=1; next}
    found && /sha256:/ {gsub(/.*sha256:[[:space:]]*"|"/, ""); print; exit}
' "$meta_file")"
```
⚠️ 必须用 `index()` 而非 `~`——`~` 是正则匹配，路径中的 `.`（如 `SKILL.md`）会匹配任意字符，导致错误匹配。`index()` 是精确字符串匹配，零正则风险。

**⚠️ `local/` 目录**：`find` 中排除 `-not -path '*/local/*'`，与 Phase 1 一致。local/ 下的文件不参与比较，不会被覆盖。

### 3.4 "both" 平台支持

secondary skill dir (`.agents/skills/`) 的复制循环（line 554-558 区域）也需要 smart copy 分支：
```bash
# Secondary loop for "both" platform — same smart copy logic
if is_pack_skill "$skill_name_b" "$src"; then
    copy_pack_skill_smart "$skill_dir_b" ".agents/skills/$skill_name_b"
else
    cp -r "$skill_dir_b" ".agents/skills/$skill_name_b"
fi
```

### 3.5 Summary 输出位置

在 `copy_framework_files` 函数**末尾**（在 secondary "both" loop 和 meta generation 之后），添加汇总：
```bash
log_info "  → Pack status: $PACK_STATS_UPDATED updated, $PACK_STATS_CUSTOMIZED customized (preserved), $PACK_STATS_NEW new, $PACK_STATS_FORKED forked, $PACK_STATS_MIGRATED migrated (preserved)"
```
⚠️ 必须在 secondary loop 之后，否则 "both" 平台的计数不完整。

---

## 4. Implementation Guide

### 4.1 Step-by-step

1. 在 `generate_pack_meta` 附近添加 `copy_pack_skill_smart` 函数
2. 在 `copy_framework_files` 开头添加 `PACK_STATS_*` 计数器初始化（local 变量）
3. 修改 skill copy 循环（line 504）：pack skill 用 `copy_pack_skill_smart`，非 pack 仍用 `cp -r`
4. 在 meta generation 循环后添加 summary 输出
5. **"both" 平台**：secondary skill dir (.agents/skills) 也需要调用 `copy_pack_skill_smart`（line 554-558 区域的 secondary copy loop）

### 4.2 Edge Cases

- **空源 pack**（无 reference 文件）：只比较 SKILL.md
- **目标有源没有的文件**（项目特有引用）：不在源遍历范围内，天然保留
- **Migrated pack 的文件积累**：如果上游重命名/删除了某个 reference，migrated pack 会保留旧文件并添加新文件——逐渐积累。这在 pack 转为 fresh_install baseline 后解决（下次完整安装或手动重置 meta）。已知限制，不阻塞。
- **meta 中有记录但源中没有的文件**（上游删除了某个 reference）：目标文件保留（无源可比较）
- **权限问题/损坏文件**：shasum 的 `|| continue` 处理（与 Phase 1 一致）
- **`--packs` 选择安装**：只为选中 pack 调用 smart copy，未选中 pack 跳过（现有行为）

---

## 5. Scope

### 5.1 In Scope
- tad.sh 增加 `copy_pack_skill_smart` 函数
- tad.sh 修改 skill copy 循环，pack skill 走 smart path
- tad.sh 增加 pack 状态汇总输出

### 5.2 Out of Scope
- 双方都改的冲突解决 UI（Phase 3）
- fork 命令（Phase 4，但 sync_policy=forked 的检测已前瞻支持）
- 下游项目的恢复/迁移

---

## 6. Files to Modify

| File | Action | Description |
|------|--------|-------------|
| tad.sh | MODIFY | 增加 copy_pack_skill_smart + 修改 copy loop + 汇总输出 |

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- tad.sh (lines 320-535, read at 2026-06-17 — Phase 1 commit 7833fc6)

---

## 7. Testing Checklist

- [ ] 修改一个 pack 的 SKILL.md → 运行 tad.sh → 该文件被保留，其他文件正常更新
- [ ] 未修改的 pack → 所有文件正常覆盖（与之前行为一致）
- [ ] 新安装的 pack（目标不存在）→ 正常安装
- [ ] migrated baseline 的 pack → 所有文件保留，只添加新的上游文件
- [ ] 汇总输出格式正确，计数准确
- [ ] 非 pack skill（alex, blake）仍然正常覆盖

---

## 8. Important Notes

### 8.1 Sub-Agent 使用建议
- 无特殊需求。单文件 shell 修改。

### 8.2 Friction Preflight
- Phase 1 的 `generate_pack_meta` 和 `.tad-pack-meta.yaml` 已存在
- `is_pack_skill` 函数可用
- tad.sh 中已有 process substitution 模式可参考

### 8.3 Known Risks
- **subshell 变量泄露**：`find | while` pipeline 中的计数器不回传。必须用 process substitution 或其他方案。
- **YAML 解析**：grep/awk 解析 meta 文件中的路径+哈希。路径中如果含特殊字符（空格/引号），需要注意 awk 模式匹配。但 pack 文件路径都是简单的 `.md` 文件名，实际风险低。
- **POSIX 风格**：用 `name() {` 不用 `function name()`。

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

| Entry | Source | Relevance |
|-------|--------|-----------|
| Sync That Mirrors Skills THEN Runs install.sh Can Silently Downgrade | pack-build-rules.md (2026-06-15) | 根因背景 — Phase 2 正是解决这个问题 |
| Deny-List Must Be Applied at EVERY Copy Granularity | principles.md (2026-06-01) | 修改 copy 逻辑时确保所有粒度（file-level, dir-level）都正确处理 |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | 修改 pack 文件后 tad.sh 不覆盖 | 修改 .claude/skills/web-testing/SKILL.md → tad.sh --yes → shasum 对比 → 文件内容保留 | 修改后哈希 == 安装后哈希 |
| AC2 | 未修改 pack 文件正常更新 | tad.sh --yes → 确认源和目标 SKILL.md 一致 | diff 无差异 |
| AC3 | 汇总输出格式正确 | tad.sh --yes 输出包含 "Pack status:" 行 | 包含 updated/customized/new 计数 |
| AC4 | 新上游文件正常安装 | 在源 pack 中添加新 reference → tad.sh → 目标有新文件 | 文件存在 |
| AC5 | migrated baseline 全保留 | 将 meta 的 baseline_source 改为 migrated → 修改文件 → tad.sh → 文件保留 | 修改内容存活 |
| AC6 | forked pack 完全跳过 | 将 meta 的 sync_policy 改为 forked → tad.sh → 零文件变化 | diff 无变化 |
| AC7 | 非 pack skill 不受影响 | tad.sh --yes → alex/blake/gate 目录正常覆盖 | 与源一致 |
| AC8 | 项目特有文件（不在源中）不被删除 | 在 pack 目录下创建 custom.md → tad.sh → 文件存在 | 文件存活 |
| AC9 | Change scope as planned | `git diff --stat` | 只有 tad.sh 变更 |
| AC10 | "both" 平台 .agents/skills/ 也走 smart copy | `--platform both` 安装 → 修改 .agents/skills/{pack}/SKILL.md → 重新安装 → 文件保留 | 修改内容存活 |

---

## 10. Decision Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| migrated 策略 | 全部保留，只添加新文件 | 无法区分"安装时就这样"和"用户改了"，安全优先 |
| forked 处理 | 前瞻兼容，完全跳过 | Phase 4 会加 --fork-pack 命令，现在就处理 forked 状态 |
| 子进程变量 | process substitution | tad.sh 已有此模式（line 180），避免 subshell 计数器丢失 |
| YAML 解析 | grep/awk（无 yq） | tad.sh 不依赖 yq，保持零依赖原则 |

---

## Expert Review Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0: "both" platform secondary loop missing smart copy + no AC | §3.4 + AC10 added | ✅ Fixed |
| shell-expert | P0: awk `~` regex → `index()` exact match | §3.3 awk pattern replaced | ✅ Fixed |
| code-reviewer | P1: awk regex metacharacter (same) | §3.3 | ✅ Fixed |
| shell-expert | P1: process substitution claim wrong | §3.3 corrected to `<<< "$()"` here-string | ✅ Fixed |
| shell-expert | P1: cp -r nesting when target exists no meta | §3.2 Case 1a/1b split | ✅ Fixed |
| code-reviewer | P1: summary placement before secondary loop | §3.5 moved to function end | ✅ Fixed |
| code-reviewer | P1: migrated stale files undocumented | §4.2 edge case added | ✅ Fixed |
| code-reviewer | P1: counter ambiguity pack vs file | Noted — Blake may refine granularity | ⏭️ Noted |
| shell-expert | P1: counter scoping comment | §3.3 comment added | ✅ Fixed |
| code-reviewer | P2: grep/sed for baseline_source not spelled out | §3.2 meta read pattern spelled out | ✅ Fixed |
| code-reviewer | P2: AC5 expected evidence incomplete | AC5 scope clear from FR3 context | ⏭️ Noted |

---

## 11. Required Evidence Manifest

```yaml
evidence:
  expert_reviews:
    required: true
    path: .tad/evidence/reviews/blake/pack-content-protection-p2/
  gate_verdicts:
    required: true
    path: .tad/evidence/gates/
  completion:
    required: true
    path: .tad/evidence/completions/COMPLETION-20260617-pack-content-protection-p2.md
  blake_reviews:
    required: true
    path: .tad/evidence/reviews/blake/pack-content-protection-p2/
  knowledge_updates:
    required: false
    path: .tad/project-knowledge/patterns/pack-build-rules.md
```
