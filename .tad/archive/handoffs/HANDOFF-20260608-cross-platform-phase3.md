---
task_type: mixed
e2e_required: yes
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
**Task ID:** TASK-20260608-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260608-cross-platform-unification.md (Phase 3/3)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Phase 1+2 已完成所有代码改动，Phase 3 是验证 + 文档 |
| Components Specified | ✅ | 验证步骤和文档更新范围明确 |
| Functions Verified | ✅ | tad.sh --platform codex 路径已就绪 (commit 3f3dca5 + 8743546) |
| Data Flow Mapped | ✅ | 安装 → 激活 → 苏格拉底 → handoff → 实现 → Gate 3/4 全流程 |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

**目标**: 在 Codex CLI 中完成一次完整的 TAD 闭环验证（dogfood），确认 Phase 1+2 的改动在真实场景下正常工作。同时验证 YOLO subagent 并行。更新文档反映新的统一架构。

**背景**: Phase 1 实现了 skill 路由（.agents/skills/），Phase 2 完成了 hooks + sync + 旧代码清理。现在需要验证这一切在 Codex 里实际能用。

**本 Phase 特殊性**: 这是一个 E2E 验证任务，大部分工作在 Codex 终端执行，Blake 在本终端（Claude Code）负责记录结果和更新文档。

---

## 2. Requirements

**FR0**: tad.sh 添加 `--platform both` 选项，同时安装到 `.claude/skills/` 和 `.agents/skills/`，生成 settings.json + hooks.json + CLAUDE.md + AGENTS.md
**FR1**: 在一个测试目录中用 `tad.sh --platform both` 完成双平台安装
**FR2**: 在 Codex 中用 `$alex` 或 "当 Alex" 激活 Alex，完成苏格拉底提问
**FR3**: Alex 在 Codex 中创建一个简单 handoff
**FR4**: 在 Codex 中用 `$blake` 或 "当 Blake" 激活 Blake，读取 handoff 并执行
**FR5**: Blake 在 Codex 中完成 Gate 3（hooks 触发 + Layer 2 expert review）
**FR6**: Alex 在 Codex 中完成 Gate 4 验收
**FR7**: 验证 YOLO subagent 并行能力（≥2 并发）
**FR8**: 更新 INSTALLATION_GUIDE.md、CHANGELOG.md、README.md

---

## 3. Technical Design

### 3.0 tad.sh `--platform both` 实现

在 tad.sh 的 `resolve_platform()` 和 `copy_framework_files()` 中添加 `both` 平台支持：

```bash
# resolve_platform() 添加 both 到 KNOWN_PLATFORMS
KNOWN_PLATFORMS="claude-code codex both"

# copy_framework_files() 中，当 PLATFORM=both 时两套都装
if [ "$PLATFORM" = "both" ]; then
    # Claude Code 路径
    TARGET_SKILL_DIR=".claude/skills"
    # ... 复制 skills + settings.json + workflows
    # Codex 路径
    mkdir -p .agents/skills
    for skill_dir in "$src"/.claude/skills/*/; do
        skill_name="$(basename "$skill_dir")"
        cp -r "$skill_dir" ".agents/skills/$skill_name"
    done
    # 生成 hooks.json
    mkdir -p .codex
    cat > .codex/hooks.json << 'HOOKS_EOF'
    ... (Phase 2 的 heredoc 模板)
    HOOKS_EOF
    # AGENTS.md 也装
fi
```

关键：`both` 不是简单跑两次——Claude Code 路径走正常流程（含 platform_deny 检查），Codex 路径额外复制一份到 `.agents/skills/` + 生成 `.codex/hooks.json` + 复制 `AGENTS.md`。

**verify_install_complete()** 适配：当 `PLATFORM=both` 时，两个路径都检查。

### 3.1 Dogfood 测试计划

**测试环境**: 创建临时目录 `/tmp/tad-codex-dogfood-$(date +%Y%m%d)/`

**Step 1: 双平台安装验证**
```bash
mkdir -p /tmp/tad-codex-dogfood && cd /tmp/tad-codex-dogfood
git init
bash /path/to/TAD/tad.sh --platform both --yes
```
验证：
- `.claude/skills/alex/SKILL.md` 存在且 ≥340KB（Claude Code 路径）
- `.agents/skills/alex/SKILL.md` 存在且 ≥340KB（Codex 路径）
- `diff .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` 无差异（同一内容）
- `.claude/settings.json` 存在（Claude Code hooks）
- `.codex/hooks.json` 存在且 JSON 合法（Codex hooks）
- `CLAUDE.md` 存在（Claude Code 项目指令）
- `AGENTS.md` 存在且包含 `.agents/skills/` 路径（Codex 项目指令）

**Step 2: Alex 激活测试**
在 Codex 中：
```
codex
# 说 "当 Alex" 或使用 $alex
# 验证：Alex 完成 4 步激活协议，显示 *help 菜单
```
测试任务：让 Alex 对一个简单需求做苏格拉底提问（如"给这个项目添加一个 README.md"）。

**Step 3: Handoff 创建测试**
让 Alex 在 Codex 中完成设计并创建 handoff。验证 handoff 格式正确。

**Step 4: Blake 激活 + 执行测试**
切换到 Blake（"当 Blake"），读取 handoff，执行实现。验证 Ralph Loop 运行。

**Step 5: Gate 3/4 测试**
Blake 完成 Gate 3（检查 hooks 是否触发）。Alex 完成 Gate 4。

**Step 6: YOLO subagent 测试**
```
codex
# 让 Alex 或 Blake 启动一个需要 ≥2 subagent 的任务
# 验证 subagent 并行启动
```
如果 subagent 无法并行，记录具体失败原因和错误信息。

### 3.2 文档更新

**INSTALLATION_GUIDE.md**: 重写 Codex 章节
- 删除旧的 launcher 脚本说明
- 添加统一 SKILL 安装说明
- 添加 `$alex` / `$blake` / "当 Alex" 激活方式
- 添加 hooks.json 说明
- 更新"已知限制"为当前实际限制（type:prompt hooks 不转换、Skill matcher 不转换）

**CHANGELOG.md**: 添加 v2.26.0 条目
- 统一架构变更说明
- 删除压缩版体系说明
- 新增 hooks.json 生成说明
- 新增 sync 多平台支持说明

**README.md**: 更新 Codex 使用说明
- 替换 launcher 脚本引用为 $skill 和 AGENTS.md 触发词

---

## 5. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|--------------------|--------------------|
| AC0 | `--platform both` 实现 | `grep -q 'both' tad.sh` + `bash tad.sh --platform both --yes` 在测试目录成功 | exit 0 + 两套路径都存在 |
| AC0b | 双平台文件一致 | `diff .claude/skills/alex/SKILL.md .agents/skills/alex/SKILL.md` (测试目录内) | exit 0, 无差异 |
| AC1 | 双平台安装成功 | dogfood 报告 Step 1 | .claude/skills/ + .agents/skills/ + settings.json + hooks.json + CLAUDE.md + AGENTS.md 全存在 |
| AC2 | Alex 在 Codex 激活 | dogfood 报告 Step 2 截图/日志 | 4 步激活 + *help 显示 |
| AC3 | Handoff 在 Codex 创建 | dogfood 报告 Step 3 | handoff 文件存在且格式正确 |
| AC4 | Blake 在 Codex 执行 | dogfood 报告 Step 4 | handoff 被读取 + 实现完成 |
| AC5 | YOLO subagent ≥2 并发 | dogfood 报告 Step 6：让 Codex 做两个独立文件任务（如同时创建 A.md 和 B.md），截取 subagent 启动日志，确认时间戳重叠证明并行 | ≥2 subagent 时间戳重叠。若失败：记录错误 + 创建回退 ticket → Phase 3 判定 FAIL，回 P1/P2 修复 |
| AC6 | INSTALLATION_GUIDE 更新 | `grep -c 'agents/skills\|\$alex\|\$blake' INSTALLATION_GUIDE.md` | ≥3 |
| AC7 | CHANGELOG v2.26.0 | `grep -q 'v2.26.0\|2.26.0' CHANGELOG.md` | exit 0 |
| AC8 | README Codex 说明 | `grep -c 'agents/skills\|\$alex\|\$blake\|当 Alex' README.md` | ≥2 |
| AC9 | dogfood 报告完整 | `test -f .tad/evidence/dogfood/codex-unification-dogfood.md` | 文件存在且 ≥50 行 |

---

## 6. Implementation Steps

### Task 1: 准备测试环境 (~5 min)
创建临时目录，git init，运行 `tad.sh --platform codex --yes`。

### Task 2: Codex 闭环测试 (~30 min)
按 §3.1 步骤在 Codex 中执行 Alex 激活 → 苏格拉底 → handoff → Blake 执行 → Gate 3/4。
记录每步结果到 dogfood 报告。

### Task 3: YOLO subagent 测试 (~15 min)
在 Codex 中测试 subagent 并行。记录结果。

### Task 4: 文档更新 (~20 min)
按 §3.2 更新 INSTALLATION_GUIDE.md、CHANGELOG.md、README.md。

### Task 5: Dogfood 报告 (~10 min)
汇总所有测试结果写入 `.tad/evidence/dogfood/codex-unification-dogfood.md`。

**Grounded Against**:
- tad.sh (Phase 1+2 commits: 3f3dca5, 8743546)
- AGENTS.md (Phase 1 更新后版本)
- .codex/hooks.json (Phase 2 heredoc 模板)

---

## 7. Files to Modify / Create

| File | Action | Scope |
|------|--------|-------|
| `tad.sh` | MODIFY | 添加 `--platform both` 支持（KNOWN_PLATFORMS + copy 双路径 + verify 双路径） |
| `.tad/platform-codes.yaml` | MODIFY | 添加 `both` 平台定义 |
| `INSTALLATION_GUIDE.md` | MODIFY | Codex 章节重写 + `--platform both` 说明 |
| `CHANGELOG.md` | MODIFY | v2.26.0 条目 |
| `README.md` | MODIFY | Codex 使用说明 + 双平台安装推荐 |
| `.tad/evidence/dogfood/codex-unification-dogfood.md` | CREATE | dogfood 报告 |

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
- **Platform Capability Assumptions Decay Fast** (patterns/handoff-design.md): 本 dogfood 的目的就是验证研究结论是否成立——Codex 真的能跑完整 TAD。如果发现不行，记录具体原因，不要编造成功。

---

## 9.2 Expert Review Status

| Expert | Focus | Result | Key Findings |
|--------|-------|--------|-------------|
| code-reviewer | AC 可验证性、测试计划完整性 | CONDITIONAL PASS (0 P0) | P1: AC5 定义不够具体（已修复：加并发任务定义 + 时间戳证据 + 失败回退）、Steps 2-5 验证标准偏模糊 |
| backend-architect | 架构验证充分性、边界测试 | CONDITIONAL PASS (0 P0) | P1: YOLO 任务需具体化（已修复）、执行模式需明确人工 vs 自动（已修复：§10.1 改为人工操作+Blake记录）、建议加负面测试路径 |

---

## 10. Important Notes

### 10.1 Codex 终端操作（执行模式：人工操作 + Blake 记录）
Phase 3 的 dogfood 步骤（Step 2-5）是**人工在 Codex 终端执行**的，不是 Blake 通过 Bash 自动化的。原因：Codex 交互模式需要实时人机对话，无法通过 Claude Code Bash 工具管道化。

**流程**：
1. Blake 准备测试环境（Step 1 — 可自动化）
2. **人类**在 Codex 终端执行 Step 2-5，截图/复制关键输出
3. 人类把结果粘贴回 Claude Code 终端
4. Blake 汇总为 dogfood 报告 + 更新文档

### 10.2 YOLO 可能失败
如果 Codex subagent 行为与 Claude Code Agent tool 差异太大导致 YOLO 无法运行，记录具体失败原因（错误信息、行为差异），回到 Phase 1/2 修复。这是 Epic AC5 的硬性 gate。

### 10.3 文档先验证后写
先完成 dogfood 验证（Task 1-3），再更新文档（Task 4）。不为没验证的东西写文档。

---

## 11. Decision Summary

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | dogfood 任务选择 | 真实 TAD 改进 / 人造测试任务 | 人造简单任务（添加 README） | 最小化 dogfood 本身的复杂度，聚焦验证框架能力 |
| 2 | 专家审查时机 | handoff 阶段 / dogfood 后 | dogfood 后（Gate 3 Layer 2） | Phase 3 无架构设计，专家在验证结果上审查更有价值 |

---

## Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/cross-platform-phase3/code-reviewer.md
gate_verdicts:
  - .tad/evidence/gates/gate3-cross-platform-phase3.md
completion:
  - .tad/active/handoffs/COMPLETION-20260608-cross-platform-phase3.md
dogfood:
  - .tad/evidence/dogfood/codex-unification-dogfood.md
```
