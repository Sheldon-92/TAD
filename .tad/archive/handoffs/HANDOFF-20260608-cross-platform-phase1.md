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
**Task ID:** TASK-20260608-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260608-cross-platform-unification.md (Phase 1/3)

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-06-08

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 统一 SKILL 路由 + 平台注释方案完整 |
| Components Specified | ✅ | tad.sh、platform-codes.yaml、AGENTS.md、SKILL.md 改动点明确 |
| Functions Verified | ✅ | copy_framework_files()、resolve_platform()、parse_platform_extra_deny() 已读 |
| Data Flow Mapped | ✅ | --platform → resolve_platform → platform_deny → skill 路由 → AGENTS.md 生成 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，Blake可以独立根据本文档完成实现。

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

**目标**: 修改 tad.sh 安装器，让它根据 `--platform` 参数将同一套 SKILL.md 文件安装到 Claude Code (`.claude/skills/`) 或 Codex (`.agents/skills/`) 的正确路径。消除压缩版双版本体系的第一步。

**背景**: 2026-06-08 深度研究发现 Codex CLI 现已具备 hooks (10 events)、skills (`.agents/skills/`)、subagent (GA, max 6)、`ask_user_question` 工具——与 Claude Code 功能对等。之前的压缩版 SKILL（丢失 72-85% 内容）不再必要。

**业务价值**: 安装完成后，用户在 Codex 里说"当 Alex"或用 `$alex`，能获得与 Claude Code `/alex` 完全相同的完整体验。

---

## 2. Requirements

### Functional Requirements

**FR1**: `--platform codex` 时，将 `.claude/skills/*/SKILL.md` 及其 `references/` 子目录复制到 `.agents/skills/*/SKILL.md` 路径
**FR2**: `--platform codex` 时，生成/更新项目根目录 `AGENTS.md`，其中 skill 路径指向 `.agents/skills/`
**FR3**: `--platform claude-code` 时，行为完全不变（零回归）
**FR4**: SKILL.md 中关键工具引用处添加 HTML 注释格式的平台注释
**FR5**: platform-codes.yaml 更新：Codex 不再排除 `.claude/skills/alex` 和 `.claude/skills/blake`
**FR6**: 安装时检测 Codex CLI 版本，若 skills 系统不可用则输出警告（不阻塞）

### Non-Functional Requirements

**NFR1**: tad.sh 修改必须保持 `set -euo pipefail` 下的鲁棒性
**NFR2**: 所有新增 shell 逻辑必须兼容 macOS BSD 工具链（无 GNU-only 语法）

---

## 3. Technical Design

### 3.1 tad.sh 修改：Skill 路由

在 `copy_framework_files()` (行 423-484) 中，当前逻辑将所有 skill 复制到 `.claude/skills/`。修改为：

```
if platform == codex:
    target_skill_dir = ".agents/skills"
else:
    target_skill_dir = ".claude/skills"

mkdir -p "$target_skill_dir"
for skill_dir in "$src"/.claude/skills/*/; do
    skill_name=$(basename "$skill_dir")
    # Platform deny check (codex 不再 deny alex/blake)
    if is_denied ".claude/skills/$skill_name" "$platform_deny"; then
        continue
    fi
    cp -r "$skill_dir" "$target_skill_dir/$skill_name"
done
```

核心改动：
- 添加变量 `target_skill_dir`，根据 `$PLATFORM` 决定目标路径
- Codex 平台：复制到 `.agents/skills/` 而非 `.claude/skills/`
- Claude Code 平台：行为完全不变

### 3.2 platform-codes.yaml 修改

```yaml
platforms:
  codex:
    label: "Codex CLI"
    extra_deny:
      - ".claude/settings.json"
      - ".claude/workflows"
      # 删除这两行：
      # - ".claude/skills/alex"
      # - ".claude/skills/blake"
    extra_root_files:
      - "AGENTS.md"
```

移除 `.claude/skills/alex` 和 `.claude/skills/blake` 的 deny——因为现在 Codex 安装时 skill 会被路由到 `.agents/skills/`，而非从 `.claude/skills/` 复制后再 deny。

### 3.3 AGENTS.md 更新

更新 AGENTS.md 模板中的 skill 路径引用：
- `当 Alex` → Read `.agents/skills/alex/SKILL.md`（而非 `.tad/codex/codex-alex-skill.md`）
- `当 Blake` → Read `.agents/skills/blake/SKILL.md`（而非 `.tad/codex/codex-blake-skill.md`）

保留触发词表和 Capability Pack 表（路径也改为 `.agents/skills/`）。

### 3.4 SKILL.md 平台注释

在 Alex 和 Blake SKILL.md 中，首次出现工具名的位置添加 HTML 注释：

<!-- Claude Code: AskUserQuestion / Codex: ask_user_question -->
<!-- Claude Code: Agent tool / Codex: subagent spawn -->
<!-- Claude Code: Skill tool / Codex: $skill-name or /skills -->
<!-- Claude Code: .claude/settings.json hooks / Codex: .codex/hooks.json -->
<!-- Claude Code: CLAUDE.md / Codex: AGENTS.md -->

只在首次出现处加注释，后续出现不重复。预计 Alex SKILL ≥5 处，Blake SKILL ≥3 处。

### 3.5 Codex CLI 版本检测

在 `resolve_platform()` 之后，当 `$PLATFORM == codex` 时：

```bash
if [ "$PLATFORM" = "codex" ]; then
    if command -v codex >/dev/null 2>&1; then
        codex_version=$(codex --version 2>/dev/null | head -1 || echo "unknown")
        log_info "Codex CLI detected: $codex_version"
        # Check if .agents/skills path is recognized (v0.130+)
        if ! codex --help 2>/dev/null | grep -q 'skills\|\.agents'; then
            log_warn "Codex CLI may not support skills system. TAD skills will be installed but may not auto-load. Consider upgrading Codex CLI."
        fi
    else
        log_warn "Codex CLI not found. Installing TAD files for Codex layout, but codex command unavailable."
    fi
fi
```

### 3.6 verify_install_complete() 适配（⚠️ P0 — 专家审查修复）

`verify_install_complete()` (行 ~560-600) 有 3 处硬编码 `.claude/skills/` 必须全部修改：

```bash
# 在 verify 函数开头设置目标路径变量
if [ "$PLATFORM" = "codex" ]; then
    skill_check_dir=".agents/skills"
else
    skill_check_dir=".claude/skills"
fi
```

**必须修改的 3 处**（deny 检查用 SOURCE 路径，存在性检查用 TARGET 路径）：

| 行号 | 当前代码 | 修改为 | 原因 |
|------|---------|--------|------|
| ~579 | `is_denied ".claude/skills/$skill_name" "$platform_deny"` | **保持不变** | deny-list 条目用 SOURCE 路径（`.claude/skills/`），匹配也必须用 SOURCE 路径 |
| ~589 | `if [ ! -d ".claude/skills/$skill_name" ]` | `if [ ! -d "$skill_check_dir/$skill_name" ]` | 存在性检查必须用 TARGET 路径 |
| ~590 | `log_warn "... MISSING skill: .claude/skills/$skill_name/"` | `log_warn "... MISSING skill: $skill_check_dir/$skill_name/"` | 错误信息用 TARGET 路径 |

### 3.7 tad.sh 其他 `.claude/skills` 引用的处理（⚠️ P1 — 专家审查补充）

tad.sh 中共有 ~18 处 `.claude/skills` 引用。除 copy_framework_files 和 verify 外，以下引用也需处理：

| 行号 | 代码 | 处理方式 |
|------|------|---------|
| ~430 | `mkdir -p .claude/skills` | **替换**为 `mkdir -p "$target_skill_dir"`（P0-3 修复）|
| ~717-718 | `if [ ! -d ".claude/skills" ]` validate_config 检查 | **平台条件化**：`if [ ! -d "$skill_check_dir" ]` |
| ~873-878 | Echo 消息 "Create .claude/skills/" | **平台条件化**：显示 `$target_skill_dir` |
| ~946 | `mkdir -p .claude/skills` (fresh install) | **替换**为 `mkdir -p "$target_skill_dir"` |
| ~1034-1041 | Archive old skills from `.claude/skills` | **保持不变**（迁移旧安装的清理逻辑，只在 `.claude/skills` 存在时执行）|

### 3.8 平台切换场景（⚠️ P1 — 专家审查补充）

用户可能先用 `--platform claude-code` 安装，后来改 `--platform codex`（或反过来）。需要处理旧平台遗留物：

```bash
# 在 copy_framework_files 开头，检测另一个平台的 skill 目录
if [ "$PLATFORM" = "codex" ] && [ -d ".claude/skills/alex" ]; then
    log_warn "Detected Claude Code skills from previous install. Codex skills will be installed to .agents/skills/. Old .claude/skills/ left intact — remove manually if no longer needed."
elif [ "$PLATFORM" = "claude-code" ] && [ -d ".agents/skills/alex" ]; then
    log_warn "Detected Codex skills from previous install. Claude Code skills will be installed to .claude/skills/. Old .agents/skills/ left intact — remove manually if no longer needed."
fi
```

Phase 1 只做警告，不做自动清理（避免意外删除用户文件）。

---

## 4. Data Flow

```
User runs: bash tad.sh --platform codex --yes

  → resolve_platform() → PLATFORM="codex"
  → Codex version check (warn if outdated)
  → Download TAD source
  → copy_framework_files():
      → .tad/* (unchanged — all platform share)
      → Determine target_skill_dir = ".agents/skills"
      → Read platform_deny from platform-codes.yaml (codex: no longer denies alex/blake)
      → Copy skills: src/.claude/skills/* → .agents/skills/*
      → Skip .claude/settings.json (still denied for codex)
      → Skip .claude/workflows (still denied for codex)
      → Copy AGENTS.md (extra_root_files)
  → verify_install_complete():
      → Check .agents/skills/alex/SKILL.md exists
      → Check .agents/skills/blake/SKILL.md exists
      → Check AGENTS.md exists
  → DONE
```

---

## 5. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | Claude Code 安装不变 | `bash tad.sh --platform claude-code --yes && test -f .claude/skills/alex/SKILL.md && wc -c < .claude/skills/alex/SKILL.md` | exit 0, ≥340000 bytes |
| AC2 | Codex Alex SKILL 一致 | 在临时目录做两次安装（`--platform claude-code` 和 `--platform codex`），然后 `diff cc-dir/.claude/skills/alex/SKILL.md codex-dir/.agents/skills/alex/SKILL.md` | exit 0, 无差异（⚠️ P0 fix: 不能在单次安装后 diff 两个路径——Codex 安装只写 .agents/） |
| AC2b | Codex Blake SKILL 一致 | 同上方法：`diff cc-dir/.claude/skills/blake/SKILL.md codex-dir/.agents/skills/blake/SKILL.md` | exit 0, 无差异 |
| AC2c | references 文件一致 | `diff -r cc-dir/.claude/skills/alex/references codex-dir/.agents/skills/alex/references && diff -r cc-dir/.claude/skills/blake/references codex-dir/.agents/skills/blake/references` | exit 0, 无差异 |
| AC3 | AGENTS.md 路径正确 | `grep '.agents/skills/alex/SKILL.md' AGENTS.md && grep '.agents/skills/blake/SKILL.md' AGENTS.md` | exit 0 |
| AC4 | Alex 平台注释 ≥5 | `grep -c '<!-- Claude Code:.*Codex:' .claude/skills/alex/SKILL.md` | ≥5 |
| AC4b | Blake 平台注释 ≥3 | `grep -c '<!-- Claude Code:.*Codex:' .claude/skills/blake/SKILL.md` | ≥3 |
| AC5 | platform-codes 更新 | `grep -A5 'codex:' .tad/platform-codes.yaml` | extra_deny 不含 .claude/skills/alex 和 .claude/skills/blake |
| AC6 | 非交互安装 | `bash tad.sh --platform codex --yes` in non-TTY | exit 0 |
| AC7 | Codex 版本检测 | `bash tad.sh --platform codex --yes 2>&1` | 输出含 "Codex CLI" 检测信息（或 "not found" 警告） |

---

## 6. Implementation Steps

### Task 1: platform-codes.yaml 修改 (~5 min)

移除 Codex extra_deny 中的 `.claude/skills/alex` 和 `.claude/skills/blake`。

**文件**: `.tad/platform-codes.yaml`
**改动**: 删除 2 行

### Task 2: tad.sh — skill 路由逻辑 (~30 min)

在 `copy_framework_files()` 中添加平台感知的 skill 目标路径。

**文件**: `tad.sh` (行 ~423-450)
**关键改动**:
1. 在 skill 复制循环前，根据 `$PLATFORM` 设置 `target_skill_dir`
2. `mkdir -p "$target_skill_dir"` 替代固定的 `mkdir -p .claude/skills`
3. `cp -r "$skill_dir" "$target_skill_dir/$skill_name"` 替代固定路径
4. 保持 `platform_deny` 和 `PACKS` 选择逻辑不变

### Task 3: tad.sh — verify_install_complete() 适配 (~15 min)

让安装验证检查正确的 skill 路径。

**文件**: `tad.sh` (行 ~560-600)
**关键改动**: 根据 `$PLATFORM` 检查 `.claude/skills/` 或 `.agents/skills/`

### Task 4: tad.sh — Codex 版本检测 (~15 min)

在 `resolve_platform()` 后添加 Codex CLI 检测逻辑。

**文件**: `tad.sh` (行 ~149-161)
**关键改动**: 添加 `codex --version` 检测 + skills 支持检查

### Task 5: AGENTS.md 路径更新 (~10 min)

更新 AGENTS.md 模板中所有 `.tad/codex/codex-*-skill.md` 引用为 `.agents/skills/*/SKILL.md`。

**文件**: `AGENTS.md`
**关键改动**: 替换 skill 路径引用（~10 处）

### Task 6: SKILL.md 平台注释 (~20 min)

在 Alex 和 Blake SKILL.md 中添加平台工具名注释。

**文件**:
- `.claude/skills/alex/SKILL.md` — 至少 5 处注释
- `.claude/skills/alex/references/*.md` — 有 AskUserQuestion 引用的文件
- `.claude/skills/blake/SKILL.md` — 至少 3 处注释

**注释格式**: `<!-- Claude Code: {CC工具名} / Codex: {Codex工具名} -->`
**注释位置**: 每个工具名首次出现处（不重复）

**Grounded Against** (Alex step1c 实际 Read 过的源文件):
- tad.sh (行 130-161, 230-280, 386-484, read at 2026-06-08)
- .tad/platform-codes.yaml (full, read at 2026-06-08)
- AGENTS.md (head 80, read at 2026-06-08)
- .claude/skills/alex/SKILL.md (loaded in session)
- .tad/codex/README.md (full, read at 2026-06-08)

---

## 7. Files to Modify / Create

| File | Action | Scope |
|------|--------|-------|
| `tad.sh` | MODIFY | skill 路由 + verify 适配 + Codex 版本检测 |
| `.tad/platform-codes.yaml` | MODIFY | 移除 2 行 extra_deny |
| `AGENTS.md` | MODIFY | skill 路径引用更新 |
| `.claude/skills/alex/SKILL.md` | MODIFY | 添加 ≥5 处平台注释 |
| `.claude/skills/alex/references/*.md` | MODIFY | 有工具引用的文件加注释 |
| `.claude/skills/blake/SKILL.md` | MODIFY | 添加 ≥3 处平台注释 |
| `.claude/skills/blake/references/*.md` | MODIFY | 有工具引用的文件加注释 |

---

## 8. Testing Checklist

- [ ] `bash tad.sh --platform claude-code --yes` 成功 + `.claude/skills/alex/SKILL.md` ≥340KB
- [ ] `bash tad.sh --platform codex --yes` 成功 + `.agents/skills/alex/SKILL.md` 存在
- [ ] `diff` 验证 Codex 和 Claude Code 安装的 SKILL 文件内容一致
- [ ] AGENTS.md 包含 `.agents/skills/` 路径
- [ ] platform-codes.yaml 不含旧 deny 项
- [ ] 非 TTY 模式 (`echo | bash tad.sh --platform codex --yes`) 正常执行

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Never Hand-Write What an Existing Tool Already Does** (principles.md): tad.sh 有现成的 `parse_platform_extra_deny()` 和 `copy_framework_files()`，不要重新实现——在现有函数内修改
- **Shell Portability** (patterns/shell-portability.md): tad.sh 必须兼容 macOS BSD grep/awk/sed，不用 GNU-only 语法
- **Deny-List Beats Allow-List** (principles.md): skill 路由使用 deny-list 机制（platform-codes.yaml），不要改回 allow-list

---

## 9.2 Expert Review Status

| Expert | Focus | Result | Key Findings |
|--------|-------|--------|-------------|
| code-reviewer | Shell 正确性、AC 完整性、回归风险 | CONDITIONAL PASS | 3 P0 (verify 硬编码、AC2 不可执行、空目录), 4 P1 (blast-radius 18处引用、版本检测脆弱、空目录、deprecation) |
| backend-architect | 架构合理性、数据流、扩展性 | CONDITIONAL PASS | 3 P0 (同上), 4 P1 (AGENTS.md 动态生成、path-map 模型、版本检测、平台切换) |

### P0 修复记录

| P0 | 问题 | 修复位置 | 状态 |
|----|------|---------|------|
| P0-1 | verify_install_complete() 3 处硬编码未明确 | §3.6 重写 — 逐行列出 3 处改动 + deny/存在性分离 | ✅ Resolved |
| P0-2 | AC2/AC2b/AC2c 单次安装后无法 diff | §9.1 AC2/2b/2c 改为双安装对比方法 | ✅ Resolved |
| P0-3 | 行 430 `mkdir -p .claude/skills` 在 Codex 留空目录 | §3.7 行 430 替换为 `mkdir -p "$target_skill_dir"` | ✅ Resolved |

### P1 整合记录

| P1 | 问题 | 处理 |
|----|------|------|
| CR P1-1 | 18 处 `.claude/skills` 引用未全部列出 | §3.7 新增：逐行处理表（5 处需改） |
| CR P1-2 / Arch P1-3 | 版本检测 grep --help 脆弱 | 保留，Blake 实现时优先用 `codex --version` 解析版本号 |
| Arch P1-1 | AGENTS.md 应动态生成 | Phase 1 用静态模板（MVP），Phase 2 考虑动态生成 |
| Arch P1-2 | target_skill_dir 对 3+ 平台不够 | 记入 Epic Known Issues，Phase 2 考虑 path-map 模型 |
| Arch P1-4 | 平台切换留旧目录 | §3.8 新增：检测 + 警告（不自动删除） |

---

## 10. Important Notes

### 10.1 Zero-regression for Claude Code
`--platform claude-code` 的行为必须完全不变。所有改动必须在 `if [ "$PLATFORM" = "codex" ]` 条件分支内。

### 10.2 Codex skill 路径约定
Codex 官方文档指定 `.agents/skills/` 为项目级 skill 路径。这是标准路径，不是我们自定义的。

### 10.3 关于 AC2 的验证说明
AC2/AC2b 用 `diff` 验证文件一致性。因为我们复制的是同一套文件，diff 应该为空。如果发现差异，说明复制逻辑有问题。

---

## 11. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Skill 目标路径 | .agents/skills (Codex官方) / .codex/skills (自定义) | .agents/skills | Codex 官方文档指定的路径 |
| 2 | 平台注释格式 | HTML注释 / YAML frontmatter / 内联文本 | HTML注释 | 不影响任何平台的解析，纯可读性注释 |
| 3 | Codex 版本检测 | 阻塞安装 / 警告不阻塞 | 警告不阻塞 | 用户可能在没有 Codex 的机器上预安装 |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/cross-platform-phase1/code-reviewer.md
  - .tad/evidence/reviews/blake/cross-platform-phase1/backend-architect.md
gate_verdicts:
  - .tad/evidence/gates/gate3-cross-platform-phase1.md
completion:
  - .tad/active/handoffs/COMPLETION-20260608-cross-platform-phase1.md
```
