---
task_type: mixed
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
**Task ID:** TASK-20260608-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260608-cross-platform-unification.md (Phase 2/3)

---

## 🔴 Gate 2: Design Completeness

**执行时间**: 2026-06-08

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | hooks 转换 + sync 适配 + 删除清单完整 |
| Components Specified | ✅ | 每个文件的改动点明确列出 |
| Functions Verified | ✅ | settings.json 结构已读、sync-registry 已读、.tad/codex/ 已列 |
| Data Flow Mapped | ✅ | hooks 转换流 + sync 平台检测流已映射 |

**Gate 2 结果**: ✅ PASS

---

## 📋 Handoff Checklist (Blake必读)

- [ ] 阅读了所有章节
- [ ] **阅读了「📚 Project Knowledge」章节中的历史教训**
- [ ] 理解了真正意图（不只是字面需求）
- [ ] 确认可以独立使用本文档完成实现

---

## 1. Task Overview

**目标**: 三件事——(1) 为 Codex 安装生成 hooks.json 配置文件；(2) 修改 *sync 支持多平台目标项目；(3) 删除整个 `.tad/codex/` 压缩版体系及相关脚本/引用。

**背景**: Phase 1 已完成 tad.sh skill 路由（commit 3f3dca5）。现在同一套 SKILL.md 可以安装到 `.agents/skills/`。Phase 2 处理配套设施：hooks 配置、sync 流程、和旧代码清理。

---

## 2. Requirements

**FR1**: `tad.sh --platform codex` 时生成 `.codex/hooks.json`，格式符合 Codex 官方 schema
**FR2**: hooks.json 中每个 handler 的 command 路径指向实际存在的 `.tad/hooks/lib/*.sh`
**FR3**: hooks 转换 spec 文档化为 `.tad/guides/hooks-platform-mapping.md`
**FR4**: *sync 协议中的 skill 复制路径根据目标项目 platform 决定
**FR5**: sync-registry.yaml 添加 platform 字段，现有项目默认 `claude-code`
**FR6**: 删除 `.tad/codex/` 目录及 `codex-parity-check.sh`
**FR7**: 更新所有活跃文件中的 `.tad/codex/` 引用
**FR8**: Alex SKILL.md 中删除 publish_protocol.step3b codex parity gate
**FR9**: deprecation.yaml 添加 v2.26.0 条目，列出所有被删的 `.tad/codex/` 文件（确保下游项目 sync 时自动清理）— P0-5 fix
**FR10**: release-runbook/SKILL.md 清理所有 `.tad/codex/` 引用（Codex Smoke Test、Parity Gate、version bump 表）— P0-3 fix

---

## 3. Technical Design

### 3.1 Hooks 转换：settings.json → hooks.json

当前 `.claude/settings.json` 结构：

```json
{
  "hooks": {
    "SessionStart": [{ "matcher": "", "hooks": [{ "type": "command", "command": "bash .tad/hooks/startup-health.sh" }, { "type": "command", "command": "bash .tad/hooks/notebook-dormant-sync.sh" }] }],
    "PreToolUse": [
      { "matcher": "Write|Edit", "hooks": [{ "type": "prompt", "prompt": "...", "model": "...", "timeout": 10 }] },
      { "matcher": "Skill", "hooks": [{ "type": "command", "command": "bash .tad/hooks/pre-accept-check.sh" }] },
      { "matcher": "Skill", "hooks": [{ "type": "command", "command": "bash .tad/hooks/pre-gate-check.sh" }] }
    ],
    "PostToolUse": [
      { "matcher": "Write|Edit", "hooks": [{ "type": "command", "command": "bash .tad/hooks/post-write-sync.sh" }] },
      { "matcher": "AskUserQuestion", "hooks": [{ "type": "command", "command": "bash .tad/hooks/lib/askuser-capture.sh" }] }
    ]
  }
}
```

Codex hooks.json 目标格式（根据 Codex 官方文档）：

```json
{
  "SessionStart": [
    { "matcher": "startup|resume", "hooks": [
      { "type": "command", "command": "bash .tad/hooks/startup-health.sh", "timeout": 30 },
      { "type": "command", "command": "bash .tad/hooks/notebook-dormant-sync.sh", "timeout": 30 }
    ]}
  ],
  "PostToolUse": [
    { "matcher": "^apply_patch$", "hooks": [{ "type": "command", "command": "bash .tad/hooks/post-write-sync.sh", "timeout": 10 }] },
    { "matcher": "^ask_user_question$", "hooks": [{ "type": "command", "command": "bash .tad/hooks/lib/askuser-capture.sh", "timeout": 10 }] }
  ]
}
```

**转换规则**（写入 hooks-platform-mapping.md）：

| Claude Code | Codex | 说明 |
|-------------|-------|------|
| Event: `SessionStart` | Event: `SessionStart` | 相同。Codex matcher 加 `startup\|resume` |
| Event: `PreToolUse` | Event: `PreToolUse` | 相同 |
| Event: `PostToolUse` | Event: `PostToolUse` | 相同 |
| Matcher: `Write\|Edit` | Matcher: `^apply_patch$` | Codex 用 `apply_patch` 做文件修改 |
| Matcher: `Skill` (pre-accept-check.sh) | Matcher: 不转换 | Codex skill 调用无等价 PreToolUse matcher。`pre-accept-check.sh` 检查 COMPLETION 报告是否存在——Codex 用户需手动确认。已知 limitation。 |
| Matcher: `Skill` (pre-gate-check.sh) | Matcher: 不转换 | 同上。`pre-gate-check.sh` 检查 gate 前置条件。Codex 用户需手动运行 `bash .tad/hooks/pre-gate-check.sh`。 |
| Matcher: `AskUserQuestion` | Matcher: `^ask_user_question$` | 工具名不同 |
| type: `prompt` | ⚠️ 不转换 | Codex hooks 不支持 `type: prompt`（LLM 内联判断）。跳过，记录为 limitation |
| type: `command` | type: `command` | 相同 |
| model / timeout | timeout only | Codex command hooks 支持 timeout，不支持 model |

**关键决策**: `type: prompt` hooks（如 PreToolUse Write|Edit 的 LLM 安全检查）在 Codex 中**不转换**。原因：Codex hooks 不支持 `type: prompt`。这是已知 limitation，记录在 hooks-platform-mapping.md 中。

### 3.2 tad.sh hooks.json 生成

在 `copy_framework_files()` 末尾（AGENTS.md 复制之后），添加 Codex hooks 生成：

```bash
if [ "$PLATFORM" = "codex" ]; then
    mkdir -p .codex
    # Generate hooks.json for Codex from hardcoded template
    # (settings.json type:prompt hooks NOT convertible — omitted)
    cat > .codex/hooks.json << 'HOOKS_EOF'
{
  "SessionStart": [
    {
      "matcher": "startup|resume",
      "hooks": [
        { "type": "command", "command": "bash .tad/hooks/startup-health.sh", "timeout": 30 },
        { "type": "command", "command": "bash .tad/hooks/notebook-dormant-sync.sh", "timeout": 30 }
      ]
    }
  ],
  "PostToolUse": [
    {
      "matcher": "^apply_patch$",
      "hooks": [
        { "type": "command", "command": "bash .tad/hooks/post-write-sync.sh", "timeout": 10 }
      ]
    },
    {
      "matcher": "^ask_user_question$",
      "hooks": [
        { "type": "command", "command": "bash .tad/hooks/lib/askuser-capture.sh", "timeout": 10 }
      ]
    }
  ]
}
HOOKS_EOF
    log_info "  → Generated .codex/hooks.json (Codex lifecycle hooks)"
fi
```

用 heredoc 模板而非 JSON 转换脚本。原因：settings.json 结构简单稳定，手写模板比解析+转换更可靠，避免 jq 依赖。

### 3.3 *sync 多平台支持

**sync-registry.yaml 修改**：为每个项目添加 `platform` 字段：

```yaml
projects:
  - path: "/Users/sheldonzhao/01-on progress programs/menu-snap"
    name: "menu-snap"
    platform: "claude-code"    # 新增字段
    claude_md_strategy: "overwrite"
    last_synced_version: "2.25.0"
```

现有 13 个项目全部默认 `platform: claude-code`（零行为变更）。

**Alex SKILL.md sync_protocol 修改**：在 step3 execution 的 skill 复制部分，读取目标项目 platform，路由到对应路径。改动范围很小——只需在 `cp -r "$skill_dir" ".claude/skills/$skill_name"` 处使用平台感知的目标路径。

### 3.4 删除清单

| 文件/目录 | 操作 | 大小 |
|-----------|------|------|
| `.tad/codex/codex-alex-skill.md` | DELETE | 53KB |
| `.tad/codex/codex-blake-skill.md` | DELETE | 32KB |
| `.tad/codex/codex-tad-alex.sh` | DELETE | 2KB |
| `.tad/codex/codex-tad-blake.sh` | DELETE | 3KB |
| `.tad/codex/expert-review-sequential.md` | DELETE | 5KB |
| `.tad/codex/manual-gates.md` | DELETE | 3KB |
| `.tad/codex/sequential-review.md` | DELETE | 5KB |
| `.tad/codex/socratic-fallback.md` | DELETE | 3KB |
| `.tad/codex/regen-codex-editions.sh` | DELETE | 4KB |
| `.tad/codex/schemas/` | DELETE | dir |
| `.tad/codex/tournament-codex.sh` | DELETE | 8KB |
| `.tad/codex/.regen-debug-alex` | DELETE | 53KB |
| `.tad/codex/.regen-debug-blake` | DELETE | 32KB |
| `.tad/codex/README.md` | **KEEP — 重写** | 5KB |
| `.tad/hooks/lib/codex-parity-check.sh` | DELETE | 11KB |

**`.tad/codex/README.md` 保留并重写**：改为简短说明"Codex 现在使用统一 SKILL（.agents/skills/），此目录仅保留本 README 作为迁移说明。旧文件已在 v2.26.0 删除。"

### 3.5 活跃引用清理

以下文件引用了 `.tad/codex/`，需要更新：

| 文件 | 行号 | 当前引用 | 处理 |
|------|------|---------|------|
| `AGENTS.md` | 12 | `.tad/codex/README.md` | 更新为"统一 SKILL 架构，详见 `.agents/skills/`" |
| `AGENTS.md` | 88-91 | `.tad/codex/expert-review-sequential.md` 等 | 删除这 4 行（Codex 现在用同一套 SKILL 里的协议） |
| `README.md` | 56-57 | launcher 脚本引用 | 改为 `$alex` / `$blake` 或 AGENTS.md 触发词 |
| `INSTALLATION_GUIDE.md` | 105-109 | launcher 引用 + 限制说明 | 重写 Codex 章节：统一 SKILL + $skill 调用 |
| `.tad/portable-extract.sh` | 53, 97-98 | `.tad/codex/` 引用 | 更新为 `.agents/skills/` 路径 |
| `.tad/portable-rules.md` | 17, 97 | Codex adapters 分类 + regen 引用 | 标记 deprecated 或删除 Transform 规则 |
| `NEXT.md` | 47 | regen-codex-editions.sh 引用 | 删除该条目（已完成/obsolete） |
| `CHANGELOG.md` | 69, 94, 525, 527 | 历史引用 | **不改**（历史记录保留原样） |
| `.claude/skills/release-runbook/SKILL.md` | ~124-127, 436-503 | version bump 表、Codex Smoke Test 节、Parity Gate 节 | ⚠️ P0-3 fix: 删除 version bump 表中 codex SKILL 行、删除或重写 Codex Adapter Smoke Test 节（引用已删文件）、删除 Codex Edition Parity Gate 节 |

### 3.6 Alex SKILL.md publish gate 清理

删除 `publish_protocol.step3b`（行 ~5445-5468）中的 codex parity gate：

```yaml
# 删除整个 step3b 块：
    step3b:
      name: "Codex Edition Parity Gate..."
      action: |
        Run the parity check on BOTH live Codex editions...
        bash .tad/hooks/lib/codex-parity-check.sh ...
```

同时更新 step3c 中的 "Publish-side source-consistency = step3b (codex parity) + THIS step3c" 引用——移除 step3b 提及。

---

## 5. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC1 | hooks.json schema 正确 | 安装后 `python3 -c "import json; json.load(open('.codex/hooks.json'))"` + 手动验证层级结构 | exit 0 + SessionStart/PostToolUse 键存在 |
| AC1b | handler command 路径有效 | `grep -oE 'bash [^ "]+' .codex/hooks.json \| while read cmd; do test -f "${cmd#bash }"; done` | 所有路径存在 |
| AC1c | hooks-platform-mapping.md 存在 | `test -f .tad/guides/hooks-platform-mapping.md && wc -l < .tad/guides/hooks-platform-mapping.md` | ≥30 行 |
| AC2 | 压缩版 SKILL 已删 | `test ! -f .tad/codex/codex-alex-skill.md && test ! -f .tad/codex/codex-blake-skill.md` | exit 0 |
| AC3 | launcher 脚本已删 | `test ! -f .tad/codex/codex-tad-alex.sh && test ! -f .tad/codex/codex-tad-blake.sh` | exit 0 |
| AC4 | parity-check 已删 | `test ! -f .tad/hooks/lib/codex-parity-check.sh` | exit 0 |
| AC4b | 活跃引用已清理 | `grep -rn '.tad/codex/' --include='*.md' --include='*.yaml' --include='*.sh' \| grep -v archive/ \| grep -v CHANGELOG` | 仅 .tad/codex/README.md 自引用 |
| AC5 | *sync 平台感知 | 检查 Alex SKILL.md sync_protocol step3 包含 platform 路由逻辑 | grep 确认 |
| AC5b | registry 迁移 | `grep -c 'platform:' .tad/sync-registry.yaml` | ≥13（所有项目） |
| AC6 | publish gate 已删 | `grep -c 'codex-parity-check\|step3b.*Codex.*Parity' .claude/skills/alex/SKILL.md` | 0 |
| AC7 | portable-rules.md 更新 | `grep -c 'DEPRECATED\|deprecated' .tad/portable-rules.md` 或 Transform 规则已删 | ≥1 |
| AC8 | deprecation.yaml 条目 | `grep -q 'codex-alex-skill' .tad/deprecation.yaml` | exit 0 |
| AC9 | release-runbook 清理 | `grep -c 'codex-parity-check\|Codex.*Smoke.*Test\|codex-alex-skill\|codex-blake-skill' .claude/skills/release-runbook/SKILL.md` | 0 |

---

## 6. Implementation Steps

### Task 1: hooks-platform-mapping.md (~15 min)

创建 `.tad/guides/hooks-platform-mapping.md`，写入 §3.1 的转换规则表。

### Task 2: tad.sh hooks.json 生成 (~15 min)

在 `copy_framework_files()` 末尾添加 §3.2 的 Codex hooks 生成 heredoc。

### Task 3: sync-registry.yaml 迁移 (~10 min)

为 13 个现有项目添加 `platform: claude-code` 字段。

### Task 4: Alex SKILL.md sync 适配 (~15 min)

在 sync_protocol step3 的 skill 复制逻辑中，读取目标项目 platform，使用对应路径。

### Task 5: Alex SKILL.md publish gate 清理 (~10 min)

删除 step3b codex parity gate 块，更新 step3c 引用。

### Task 6: 删除 .tad/codex/ 文件 (~10 min)

按 §3.4 删除清单执行。保留并重写 README.md。

### Task 7: 活跃引用清理 (~20 min)

按 §3.5 引用表逐个更新 AGENTS.md、README.md、INSTALLATION_GUIDE.md、portable-extract.sh、portable-rules.md、NEXT.md。

### Task 8: deprecation.yaml 添加条目 (~10 min) — P0-5 fix

在 `.tad/deprecation.yaml` 中添加 v2.26.0 条目，列出所有被删的 `.tad/codex/` 文件：
- `.tad/codex/codex-alex-skill.md`
- `.tad/codex/codex-blake-skill.md`
- `.tad/codex/codex-tad-alex.sh`
- `.tad/codex/codex-tad-blake.sh`
- `.tad/codex/expert-review-sequential.md`
- `.tad/codex/manual-gates.md`
- `.tad/codex/sequential-review.md`
- `.tad/codex/socratic-fallback.md`
- `.tad/codex/regen-codex-editions.sh`
- `.tad/codex/tournament-codex.sh`
- `.tad/codex/schemas/`
- `.tad/hooks/lib/codex-parity-check.sh`

**不含** `.tad/codex/README.md`（保留作为迁移说明）。

### Task 9: release-runbook/SKILL.md 清理 (~15 min) — P0-3 fix

**文件**: `.claude/skills/release-runbook/SKILL.md`
**改动**:
1. 删除 version bump 表中引用 codex SKILL 文件的行（~行 124-127）
2. 删除或重写 "Codex Adapter Smoke Test" 节（~行 436-472）——旧测试命令引用已删文件
3. 删除 "Codex Edition Parity Gate" 节（~行 474-503）
4. 更新三门组合描述（publish-side consistency = step3c version + step3c_structural，不再含 step3b codex parity）

**⚠️ 顺序重要**: 先 Task 6（删除文件），再 Task 7-9（更新引用）。否则 AC4b 的 grep 会在删除前匹配到将被删除的文件本身。

**Grounded Against** (Alex step1c):
- .claude/settings.json (full, read at 2026-06-08)
- .tad/sync-registry.yaml (head 40, read at 2026-06-08)
- .tad/codex/ directory listing (full, read at 2026-06-08)
- .claude/skills/alex/SKILL.md step3b (lines 5445-5468, read at 2026-06-08)
- grep -rn '.tad/codex/' active references (20 matches, read at 2026-06-08)

---

## 7. Files to Modify / Create / Delete

| File | Action | Scope |
|------|--------|-------|
| `tad.sh` | MODIFY | hooks.json 生成 heredoc |
| `.tad/guides/hooks-platform-mapping.md` | CREATE | hooks 转换 spec |
| `.tad/sync-registry.yaml` | MODIFY | 13 项目添加 platform 字段 |
| `.claude/skills/alex/SKILL.md` | MODIFY | 删除 step3b + sync 平台路由 |
| `.tad/codex/codex-{alex,blake}-skill.md` | DELETE | 压缩版 SKILL |
| `.tad/codex/codex-tad-{alex,blake}.sh` | DELETE | launcher 脚本 |
| `.tad/codex/{expert-review-sequential,manual-gates,sequential-review,socratic-fallback}.md` | DELETE | Codex 适配指南 |
| `.tad/codex/regen-codex-editions.sh` | DELETE | 重生成脚本 |
| `.tad/codex/schemas/` | DELETE | tournament schemas |
| `.tad/codex/tournament-codex.sh` | DELETE | tournament 脚本 |
| `.tad/codex/.regen-debug-{alex,blake}` | DELETE | debug 文件 |
| `.tad/codex/README.md` | MODIFY | 重写为迁移说明 |
| `.tad/hooks/lib/codex-parity-check.sh` | DELETE | parity 检查脚本 |
| `AGENTS.md` | MODIFY | 移除 .tad/codex/ 引用 |
| `README.md` | MODIFY | Codex 使用说明更新 |
| `INSTALLATION_GUIDE.md` | MODIFY | Codex 章节重写 |
| `.tad/portable-extract.sh` | MODIFY | 路径更新 |
| `.tad/portable-rules.md` | MODIFY | Transform 规则 deprecated |
| `NEXT.md` | MODIFY | 删除 regen 条目 |
| `.tad/deprecation.yaml` | MODIFY | 添加 v2.26.0 codex 文件删除条目 |
| `.claude/skills/release-runbook/SKILL.md` | MODIFY | 删除 Codex Smoke Test + Parity Gate 节 |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训

- **Deny-List Beats Allow-List** (principles.md): sync 路径使用现有 deny-list 机制，不要硬编码 allow-list
- **Never Hand-Write What an Existing Tool Already Does** (principles.md): hooks.json 用 heredoc 模板生成，不需要写 JSON 转换器
- **Shell Portability** (patterns/shell-portability.md): heredoc 在 bash/zsh 下行为一致，用 `<< 'EOF'` 防止变量展开

---

## 9.2 Expert Review Status

| Expert | Focus | Result | Key Findings |
|--------|-------|--------|-------------|
| code-reviewer | hooks 正确性、删除安全、AC 可验证性 | CONDITIONAL PASS | 3 P0 (notebook-dormant-sync 漏掉、heredoc 与 spec 矛盾、无 deprecation.yaml), 4 P1 |
| backend-architect | 转换完整性、sync 迁移、删除 blast radius | CONDITIONAL PASS | 4 P0 (同 notebook-dormant-sync、pre-accept-check 静默丢弃、release-runbook 15 处引用、PreToolUse 语义错误), 4 P1 |

### P0 修复记录

| P0 | 问题 | 修复 | 状态 |
|----|------|------|------|
| P0-1 | `notebook-dormant-sync.sh` 漏掉 | §3.1 源表示 + Codex 目标格式均已加回 | ✅ Resolved |
| P0-2 | `pre-accept-check.sh` 静默丢弃无说明 | 转换规则表拆为 2 行，逐个说明不转换原因 | ✅ Resolved |
| P0-3 | release-runbook/SKILL.md 15 处引用 | §3.5 + Task 9 + AC9 新增 | ✅ Resolved |
| P0-4 | `post-write-sync.sh` 放 PreToolUse 语义错误 | 目标格式删除 PreToolUse 整节 | ✅ Resolved |
| P0-5 | 无 deprecation.yaml → 下游死文件 | FR9 + Task 8 + AC8 新增 | ✅ Resolved |
| P0-6 | heredoc 模板与 spec 矛盾 | 模板和 spec 统一为无 PreToolUse 版本 | ✅ Resolved |

---

## 10. Important Notes

### 10.1 CHANGELOG.md 历史引用不改
CHANGELOG.md 里的 `.tad/codex/` 引用是历史记录，保留原样。只有活跃文件（README、AGENTS.md 等）需要更新。

### 10.2 type:prompt hooks 的 limitation
Codex hooks 不支持 `type: prompt`（LLM 内联判断）。这意味着 Claude Code 的 PreToolUse Write|Edit 安全检查在 Codex 中没有等价物。这是已知 limitation，记录在 hooks-platform-mapping.md 中，不阻塞 Phase 2。

### 10.3 sync 改动范围
*sync 的改动只在 Alex SKILL.md 的 sync_protocol 中。不改 tad.sh 的 sync 逻辑（tad.sh 只负责安装，不负责 sync）。

---

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | hooks.json 生成方式 | heredoc 模板 / JSON 转换脚本 / 共享源定义 | heredoc 模板 | 简单可靠，无 jq 依赖，settings.json 结构稳定 |
| 2 | type:prompt hooks | 转换为 command / 跳过 / 用 Codex auto_review | 跳过 + 记录 | Codex 不支持，强转会出错 |
| 3 | .tad/codex/README.md | 删除 / 保留重写 | 保留重写 | 作为迁移说明，帮助从旧版本升级的用户理解变化 |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/cross-platform-phase2/code-reviewer.md
  - .tad/evidence/reviews/blake/cross-platform-phase2/spec-compliance.md
gate_verdicts:
  - .tad/evidence/gates/gate3-cross-platform-phase2.md
completion:
  - .tad/active/handoffs/COMPLETION-20260608-cross-platform-phase2.md
```
