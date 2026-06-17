---
task_type: code
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: Installer Audit Fixes (5 bugs)

**From:** Alex
**To:** Blake
**Date:** 2026-06-17
**Task ID:** TASK-20260617-004
**Priority:** P0+P1 bundle

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 5 个具体 bug，修复路径明确 |
| Components Specified | ✅ | 涉及 3 个文件 (package.json, tad.sh, README) |
| Functions Verified | ✅ | detect_state, main, copy_framework_files 已审查 |
| Data Flow Mapped | ✅ | npx 路径 + curl 路径都已走查 |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
修复安装器（tad.sh + npx installer）审查中发现的 5 个 bug。用户决定废弃 `*sync` 推送模式，改为下游项目各自通过 GitHub 安装命令拉取更新。这让安装器成为唯一的分发路径——必须可靠。

### 1.2 Why We're Building It
**业务价值**：安装器现在是 TAD 唯一的下游分发渠道（`*sync` 已废弃），任何 bug 都直接影响所有 14 个下游项目的更新体验。
**最严重问题**：CLAUDE.md 在升级时被无条件覆盖——用户跑一次更新命令就丢失了项目自定义规则。

### 1.3 Intent Statement

**真正要解决的问题**：让 `npx github:Sheldon-92/TAD` 和 `curl ... | bash` 两条路径在下游项目可靠地升级 TAD，不破坏用户数据。

**不是要做的**：
- ❌ 不是重写安装器
- ❌ 不是加新功能
- ❌ 不是改安装流程

---

## 📚 Project Knowledge

**⚠️ Blake 必须注意的历史教训：**

1. **Deny-List Must Be Applied at EVERY Copy Granularity** (principles.md) — tad.sh 已有完善的 deny-list 系统，CLAUDE.md 的修复必须复用已有模式，不引入新的 hardcoded 逻辑。
2. **Shell Portability** (patterns/shell-portability.md) — tad.sh 必须兼容 bash 3.2（macOS 默认）+ BSD 工具链。
3. **Sync downgrade bug** (patterns/pack-build-rules.md) — v2.30.0 sync 因执行顺序导致包降级。同类问题：CLAUDE.md 覆盖也是"顺序问题"（copy 在 merge 之前）。

---

## 2. Bug Details & Fix Specifications

### Bug 1 (P0): package.json 版本漂移

**文件**: `package.json` line 3
**现状**: `"version": "2.30.0"` — 被 v2.31.0 release 遗漏
**修复**: 改为 `"version": "2.31.0"`

**根因**: release handoff 列了 3 个版本文件（version.txt / config.yaml / tad.sh），遗漏了 package.json。
**预防**: 在 release-runbook 的版本 bump 文件清单中加入 `package.json`。

---

### Bug 2 (P1): CLAUDE.md 升级时无条件覆盖

**文件**: `tad.sh` line 1113, 1209, 1287（三处 `cp "$TAD_SRC"/CLAUDE.md ./`）
**现状**: install / upgrade / migrate 三条路径都是 `cp` 直接覆盖，无 merge、无备份、无 marker。
**影响**: 下游项目在 CLAUDE.md 中添加的项目特定规则（如 API key 说明、团队规范）在升级时被静默覆盖。

**修复方案（Marker-Based Merge — Expert Review P0 integrated）**:

1. 使用**已有** marker `<!-- TAD:PROJECT-CONTENT-BELOW -->`（已在 CHANGELOG.md, README.md, NEXT.md, sync 脚本中使用）。
   ⚠️ 不要发明新 marker 名（expert review P0-1: 新名字让下游项目 fallback 到 legacy 覆盖分支）。
   在 TAD 源 CLAUDE.md 末尾添加此 marker。

2. tad.sh 的 upgrade/migrate 路径改为 merge 逻辑:
```bash
merge_claude_md() {
    local src="$1"
    local marker="<!-- TAD:PROJECT-CONTENT-BELOW -->"
    
    if [ ! -f "CLAUDE.md" ]; then
        cp "$src/CLAUDE.md" ./
        return
    fi
    
    # Always backup first — eliminates TOCTOU data loss window (expert review P0-5)
    cp "CLAUDE.md" "CLAUDE.md.bak"
    
    # Use grep -nF (fixed string, no regex injection — expert review P0-4)
    local marker_line
    marker_line=$(grep -nF "$marker" "CLAUDE.md" | head -1 | cut -d: -f1)
    
    if [ -n "$marker_line" ]; then
        # Has marker: extract project content below it (tail, not sed — BSD safe)
        local total_lines
        total_lines=$(wc -l < "CLAUDE.md" | tr -d ' ')
        local content_start=$((marker_line + 1))
        
        # Atomic write: build in temp file, then mv (expert review P0-5)
        local tmpfile
        tmpfile=$(mktemp "CLAUDE.md.merge.XXXXXX")
        
        # TAD framework section (from source)
        cat "$src/CLAUDE.md" > "$tmpfile"
        
        # Append project content (if any lines exist below marker)
        if [ "$content_start" -le "$total_lines" ]; then
            tail -n +"$content_start" "CLAUDE.md" >> "$tmpfile"
        fi
        
        mv "$tmpfile" "CLAUDE.md"
        log_success "  → CLAUDE.md merged (project content preserved below marker)"
        rm -f "CLAUDE.md.bak"  # backup no longer needed
    else
        # No marker (legacy): overwrite + keep backup + warn
        cp "$src/CLAUDE.md" ./
        log_warn "CLAUDE.md backed up to CLAUDE.md.bak (no merge marker found)"
        log_warn "If you had project-specific rules, restore them from the backup"
    fi
}
```

   参考 `migration-engine.sh execute_merge_entry()` 的模式（grep -F, mktemp 原子写, 幂等性），
   但不直接调用它（merge_entry 处理的是 YAML manifest 驱动的单行插入，不是"保留 marker 以下全部内容"的语义）。
   Expert review P0-2 指出不该重写，此版本复用了 migration-engine 的**模式**（grep -nF + mktemp + mv），
   而非重写其**功能**。

3. 三处 `cp "$TAD_SRC"/CLAUDE.md ./` 改为:
   - **install** (line 1113): 保持 `cp`（新项目无自定义内容）
   - **upgrade** (line 1209): 改为 `merge_claude_md "$TAD_SRC"`
   - **migrate** (line 1287): 改为 `merge_claude_md "$TAD_SRC"`

---

### Bug 3 (P1): 无 --force 重装同版本

**文件**: `tad.sh` argument parsing (~line 50) + `detect_state` (~line 895) + main (~line 1012)
**现状**: `detect_state` 返回 "current" 时直接退出，无法重新安装/修复。
**影响**: 
- 安装中断后无法重跑
- main 分支的 hotfix 推送后，同版本项目无法拉取

**修复**:

1. 参数解析加 `--force` flag:
```bash
FORCE=0
# In the while loop:
--force)  FORCE=1; shift ;;
```

2. `--help` 输出加一行:
```
  --force              reinstall even if already on the same version
```

3. main 函数中 `ACTION="none"` 处改为（⚠️ Expert Review P0-3: 必须区分 "same version" vs "installed NEWER"）:
```bash
if [ "$ACTION" = "none" ]; then
    if [ "$FORCE" = "1" ]; then
        # P0-3 fix: only force-reinstall when SAME version, never downgrade
        local cmp_result
        cmp_result="$(_tad_ver_cmp "$CURRENT_VERSION" "$TARGET_VERSION")"
        if [ "$cmp_result" = "0" ]; then
            log_info "Force reinstall requested (same version: $CURRENT_VERSION)"
            ACTION="upgrade"
        else
            # cmp_result = "1" means installed > target — REFUSE downgrade even with --force
            log_warn "Installed v${CURRENT_VERSION} is NEWER than target v${TARGET_VERSION}. --force does not downgrade."
            exit 0
        fi
    else
        echo -e "${GREEN}✅ Nothing to do. TAD v${TARGET_VERSION} is already installed.${NC}"
        # ... existing exit logic
    fi
fi
```

4. npx installer (bin/tad-install.mjs) 也需要透传 `--force`:
   - parseArgs 加 `case '--force': force = true; break;`
   - runInstall 的 args 加 `if (force) args.push('--force');`

---

### Bug 4 (P2): curl | bash 需 --yes 但未文档化

**文件**: README.md（或 INSTALLATION_GUIDE.md）
**现状**: 文档可能写的是 `curl ... | bash`，但实际在非 TTY 环境（Claude Code Bash tool）会静默退出。
**修复**: 确保所有文档中的 curl 命令都包含 `--yes`:
```bash
curl -sSL https://raw.githubusercontent.com/Sheldon-92/TAD/main/tad.sh | bash -s -- --yes
```
检查并更新: README.md, INSTALLATION_GUIDE.md, tad-help skill。

---

### Bug 5 (P2): package.json files 缺 .agents/

**文件**: `package.json` → `files` array
**现状**: 列了 `.tad/`, `.claude/`, `bin/` 等，但没有 `.agents/`。
**影响**: 功能上不影响（tad.sh 从 tarball 安装），但 npm pack 不完整。
**修复**: 在 files 数组中加 `".agents/"`:
```json
"files": [
    ".tad/",
    ".claude/",
    ".agents/",
    "bin/",
    "tad.sh",
    "AGENTS.md",
    "CLAUDE.md",
    "*.md",
    "scripts/"
]
```

---

## 3. Implementation Order

1. Bug 1 (package.json version) — 1 行改动，先修
2. Bug 5 (package.json files) — 1 行改动，顺便改
3. Bug 4 (文档 curl 命令) — 找到所有位置，更新
4. Bug 3 (--force flag) — tad.sh + tad-install.mjs
5. Bug 2 (CLAUDE.md merge) — 最复杂，最后做
6. release-runbook 更新 — 版本 bump 文件清单加 package.json

---

## 9. Acceptance Criteria

- [ ] **AC1**: `package.json` version = "2.31.0"
- [ ] **AC2**: `package.json` files 包含 `".agents/"`
- [ ] **AC3**: CLAUDE.md 末尾有 `<!-- TAD:PROJECT-CONTENT-BELOW -->` marker（与 CHANGELOG.md, README.md, sync 脚本一致）
- [ ] **AC4**: tad.sh upgrade 路径使用 merge_claude_md（不是 bare cp）
- [ ] **AC5**: tad.sh migrate 路径使用 merge_claude_md（不是 bare cp）
- [ ] **AC6**: tad.sh install 路径保持 bare cp（新项目无需 merge）
- [ ] **AC7**: tad.sh 支持 `--force` flag，能重装同版本
- [ ] **AC8**: bin/tad-install.mjs 透传 `--force` 到 tad.sh
- [ ] **AC9**: 所有文档中的 `curl | bash` 命令包含 `--yes` 参数
- [ ] **AC10**: release-runbook 版本 bump 文件清单包含 `package.json`
- [ ] **AC11**: CLAUDE.md merge 在无 marker 的 legacy 文件上正确 backup + warn
- [ ] **AC12**: 验证：在一个测试目录下 (a) fresh install → CLAUDE.md 有 marker (b) 手动在 marker 下加一行 (c) 再跑 upgrade → 自定义行保留

---

## 11. Decision Summary

| # | Decision | Chosen | Rationale |
|---|----------|--------|-----------|
| D1 | CLAUDE.md merge 策略 | Marker-based（不是 diff-patch） | 简单可靠，marker 是一行注释，不影响 Claude 读取 |
| D2 | Legacy CLAUDE.md 处理 | Backup + overwrite + warn | 无 marker 的文件无法自动 merge，宁可 warn 也不丢 TAD 更新 |
| D3 | --force 行为 | 仅 same-version 走 upgrade 路径 | 复用已有逻辑; NEWER→target 拒绝降级（expert P0-3） |

---

## 12. Expert Review Audit Trail

**Review Date**: 2026-06-17
**Experts**: code-reviewer, security-auditor (2 distinct)

| Reviewer | Issue | Resolution | Status |
|----------|-------|------------|--------|
| code-reviewer | P0-1: Marker 名 `TAD:FRAMEWORK-END` 与已有 `TAD:PROJECT-CONTENT-BELOW` 冲突 | §Bug2 改用已有 marker | ✅ Fixed |
| code-reviewer | P0-2: migration-engine.sh 已有 merge 函数，不该手写 | §Bug2 复用 migration-engine 的模式（grep -nF + mktemp + mv） | ✅ Fixed |
| code-reviewer | P0-3: --force 把 "installed NEWER" 也降级 | §Bug3 用 _tad_ver_cmp 区分 same vs newer | ✅ Fixed |
| security-auditor | P0-1: sed regex 注入 + BSD 不兼容 | §Bug2 改用 grep -nF + tail | ✅ Fixed |
| security-auditor | P0-2: TOCTOU 数据丢失窗口 | §Bug2 always backup + mktemp 原子写 | ✅ Fixed |
| code-reviewer | P1-1: curl --yes 位置列表不完整 | Blake 实现时 grep 全库搜索 | Noted |
| code-reviewer | P1-2: 缺 marker 名一致性 AC | AC3 已更新为 `TAD:PROJECT-CONTENT-BELOW` | ✅ Fixed |
| code-reviewer | P1-3: migration-engine 跳过 same-version | 预期行为（--force 走 upgrade 路径，engine 无 manifest 时 skip） | Noted |
| code-reviewer | P1-4: printf `\n` 导致双空行累积 | §Bug2 重写后不再有此问题（tail 直接追加） | ✅ Fixed |
| security-auditor | P1-1: --force 无审计日志 | §Bug3 已有 log_info "Force reinstall requested" | ✅ Fixed |
| security-auditor | P1-3: curl\|bash 无完整性校验 | 跟进项（超出本 handoff 范围） | Deferred |
| code-reviewer | P2-1~P2-3 + security P2-1~P2-3 | 6 items | Deferred/Noted |

**Gate 2 Post-Review**: ✅ PASS — 5 P0 全部修复，关键 P1 已集成或标注。
