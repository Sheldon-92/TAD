---
task_type: doc-only
express: true
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta:
  - "Line-pointer drift in discipline-floor-budget.md/discipline-floor.md due to header/role switching compression; text anchors survive, line number reconciliation deferred to doc sync."
---

# Mini-Handoff: Bugfix — Full 通道 Lite 触发词消音（保留显式可用）
## TAD v3.1 - Evidence-Based Development (Express Path)

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-09-06
**Project:** TAD Framework (upstream)
**Task ID:** TASK-20260903-LITEMUTE
**Handoff Version:** 3.1.0
**Priority:** P2
**Type:** Express Bugfix (Docs-only)

---

## 🔴 Gate 2: Design Completeness (Alex 必填)

**执行时间**: 2026-09-06

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert review complete (min 2) | ✅ PASS | `code-reviewer` + `security-auditor` 双专家独立审查完成 |
| All P0 resolved | ✅ PASS | 3 个 P0（CR-P0-1/SEC-P0-2, CR-P0-2/SEC-P0-3, CR-P0-3/SEC-P0-1）全部在本版本中解决闭环 |
| Architecture complete | ✅ PASS | 消音（mute-only）修改，仅改动 `AGENTS.md` 与 `CLAUDE.md` 两处路由文档 |
| Components specified | ✅ PASS | 包含激活句、触发词表精简、角色定义保留、文末显式映射及页眉 1 行压缩的字面 diff |
| Functions verified | ✅ PASS | 仅 grep / diff / 文档更新，无代码与 hook 依赖 |
| Data flow mapped | ✅ PASS | 路由文档更新 → 默认行为不输出 Lite 噪音 → 显式调用仍可索引 |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 Bug Description
用户反馈：TAD Lite 通道已于 2026-08-13 冻结，但在 Full 通道的日常 session 中（尤其是新会话激活或角色选择时），仍频繁出现与 Lite 相关的提醒（如 `$alex-lite` / `$blake-lite`、"当 Blake Lite" 等触发词），造成持续的心智干扰与噪音。
用户裁定：**只做消音（Mute-only），显式调用 "当 Blake Lite" / "当 Alex Lite" 仍须完全可用。**

### 1.2 Root Cause Analysis
每 session 必载的路由根文件把 Lite 触发词并列放在默认路径上：
- `AGENTS.md:18`：激活句并列 `$alex-lite` / `$blake-lite`；`:24-25` 触发词表含两行 Lite 行；`:29` 独立冻结段落。
- `CLAUDE.md:3-4`：页眉冻结声明占 2 行；`:8` §1 指针；`:48-58` §2.5 重复段；`:105` 协议表格行。
- 真正的“当 LITE 文件存在才提示”分支（`AGENTS.md:100`）：当前休眠（`active/handoffs/` 下 0 个 `LITE-*.md`），不是噪音源，**必须原样保留**。

### 1.3 Non-Goals（一律不动）
- **禁止修改 4 个 lite SKILL 文件**（`.claude/skills/alex-lite/`、`blake-lite/`，`.agents/skills/alex-lite/`、`blake-lite/`）
- **禁止修改 `CLAUDE.md` §1、§2.5（保持 byte-identical，保留"通道由人裁定"及"方向互斥"等全部治理条款）**
- **禁止修改 hooks、templates、`NEXT.md`、`tad.sh`、README、brain-index**
- **禁止删除 Lite 的显式可用性与互斥路由规则**

---

## 2. Proposed Changes (Mute-only)

### 2.1 `AGENTS.md`
1. **Line 18 激活句**：
   - 原文：
     ```markdown
     Use `$alex` / `$blake` (full TAD — **the default**) or `$alex-lite` / `$blake-lite` (Lite — **frozen experiment** since 2026-08-13; still fully usable when invoked explicitly) to activate a role. Alternatively, say any trigger phrase:
     ```
   - 修改为：
     ```markdown
     Use `$alex` / `$blake` (full TAD — **the default**) to activate a role (Lite channel is frozen; see note at bottom). Alternatively, say any trigger phrase:
     ```
2. **Line 24-25 触发词表**：
   - 从表格中删除 `"当 Alex Lite"` 和 `"当 Blake Lite"` 两行，仅保留 Alex 与 Blake 两行：
     ```markdown
     | Trigger phrases | Role |
     |----------------|------|
     | "当 Alex" / "Alex 模式" / "$alex" / "/alex" | Alex (Solution Lead) |
     | "当 Blake" / "Blake 模式" / "$blake" / "/blake" | Blake (Execution Master) |
     ```
3. **Line 27-29 角色定义与冻结段（CR-P0-1 & SEC-P0-2 修复）**：
   - **绝对保留**原 Line 27-28 以及第 29 行开头：
     ```markdown
     Alex is the Solution Lead: requirements, design, Socratic inquiry, handoffs, Gate 4.
     Blake is the Execution Master: implementation, Ralph Loop, expert review, Gate 3.
     Alex / Blake are the default.
     ```
   - **仅删除**原 Line 29 紧跟其后的 Lite 句子：
     `Alex Lite / Blake Lite are a frozen experiment (2026-08-13): no new work is started there, in-flight \`LITE-*.md\` runs to completion, and explicit invocation still works exactly as before.`
4. **文末新增节（CR-P1-2 修复，明确触发词到角色映射）**：
   - 在 `AGENTS.md` 尾部追加独立节：
     ```markdown
     ---

     ## Frozen Channel: TAD Lite (Explicit Invocation Only)

     TAD Lite is a frozen experiment since 2026-08-13: no new work is started there, in-flight `LITE-*.md` contracts run to completion, and explicit invocation remains fully available:
     - **Alex Lite** (Lite design lead): `$alex-lite`, `/alex-lite`, "当 Alex Lite", "Alex Lite 模式"
     - **Blake Lite** (Lite implementation): `$blake-lite`, `/blake-lite`, "当 Blake Lite", "Blake Lite 模式"
     ```
5. **明确保持不变的行（SEC-P0-1 核心保障）**：
   - Line 60（`Full roles ignore \`LITE-*\`; \`blake-lite\` accepts only \`LITE-*`.`）**一字不改**。
   - Line 100（`4. If a LITE-*.md file is present: prompt the user to say "当 Blake Lite" — do NOT read the handoff content yourself`）**一字不改**。
   - Line 101（`5. Otherwise: suggest "Say '当 Alex' to design, '当 Blake' to implement" (Lite is frozen — only offer it if the user names it)`）**一字不改**。

### 2.2 `CLAUDE.md`
1. **Line 3-4 页眉声明压缩为 1 行（CR-P2-3 修复保留反引号代码格式）**：
   - 原文：
     ```markdown
     > 路由层：什么时候做什么。**默认 = full（`/alex`, `/blake`, `/gate`）**。lite
     > （`/alex-lite`, `/blake-lite`）自 2026-08-13 起为**🧊 已冻结的实验**：不接新工作，仅为在飞的 `LITE-*.md` 与历史对照保留，**显式调用仍完全可用**。执行协议在各自 skill 文件内。
     ```
   - 修改为单行 blockquote：
     ```markdown
     > 路由层：什么时候做什么。**默认 = full（`/alex`, `/blake`, `/gate`）**。Lite 通道（`/alex-lite`, `/blake-lite`）已于 2026-08-13 冻结，不接新工作，显式调用仍完全可用（协议见 §2.5 与对应 skill）。
     ```
2. **CR-P0-2 & SEC-P0-3 修复：其余所有治理条款 byte-identical 不动**：
   - Line 8 指针与 Line 12 豁免 2（`豁免 2：LITE-*.md（TAD Lite 通道，见 §2.5）→ 本节规则不适用，含"跳过 Gate/不通过 Blake"禁令。`）**保持不变**。
   - §2.5（Line 48-58，含"通道由人裁定"、"修改框架自身"、"方向互斥"）**保持不变**。
   - Line 105 表格（`| lite 全流程（🧊 已冻结，仅在飞单） | /alex-lite, /blake-lite |`）**保持不变**。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索（SEC-P0-1 修正）
- 检查 `AGENTS.md` 中 Lite 触发词基线（精确共 5 处）：
  ```bash
  grep -n "当 .* Lite\|alex-lite\|blake-lite" AGENTS.md
  ```
  基线 5 行：
  1. Line 18: 激活句并列
  2. Line 24: "当 Alex Lite" 触发词行
  3. Line 25: "当 Blake Lite" 触发词行
  4. Line 60: 路由隔离规则 (`Full roles ignore LITE-*; blake-lite accepts only LITE-*.`)
  5. Line 100: Default Behavior 条件分支 (`prompt the user to say "当 Blake Lite"`)

### MQ2: 函数与命令存在性验证
- `grep`, `sed`, `awk`, `git` 命令在 macOS BSD / Linux 环境下均可稳定运行。

---

## 7. 详细文件清单

| 文件路径 | 变更类型 | 说明 |
|----------|----------|------|
| `AGENTS.md` | MODIFY | 激活句去 Lite、触发词表去 Lite 行、Lite 迁移至文末注，严格保留 Alex/Blake 角色定义及 Line 60 隔离规则 |
| `CLAUDE.md` | MODIFY | 压缩页眉声明至单行 blockquote，§1、§2.5 及所有治理条款保持 byte-identical |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|-------------------|-------------------------------|
| AC1 | `AGENTS.md` 中 `## Role Switching` 节（修改后约 16-30 行）零 Lite 触发词提及，且 Alex/Blake 角色与 Gate 3/4 定义完好 | post-impl | `awk '/## Role Switching/,/## Knowledge Ingress/' AGENTS.md \| grep -E "当 .* Lite\|alex-lite\|blake-lite" \| tr -d ' ' && grep -cF "Alex is the Solution Lead" AGENTS.md && grep -cF "Blake is the Execution Master" AGENTS.md` | `0` 紧随两行 `1` | (post-impl) |
| AC2 | `AGENTS.md` 的 Lite 命中恰好 4 行：(1) 隔离规则、(2) 条件分支、(3-4) 文末新增节的两行映射列表 | post-impl | `grep -n "当 .* Lite\|alex-lite\|blake-lite" AGENTS.md \| cut -d: -f2- && grep -cF "Full roles ignore" AGENTS.md` | 输出恰好为：(1) 隔离规则、(2) 条件分支、(3-4) 文末映射两行，紧随 `1` | (post-impl) |
| AC3 | `CLAUDE.md` 页眉声明恰好 1 行 blockquote，且方向互斥条款完整存在 | post-impl | `sed -n '3,5p' CLAUDE.md \| grep -c "^>" && grep -cF "方向互斥：full" CLAUDE.md` | `1` 紧随 `1` | (post-impl) |
| AC4 | 4 个 lite SKILL 文件零 diff（对 index 及 HEAD 均无修改），显式可用性不受影响（提交前执行） | post-impl | `git status --porcelain .claude/skills/*lite* .agents/skills/*lite* && git diff HEAD -- .claude/skills/*lite* .agents/skills/*lite*` | 空输出 | (post-impl) |
| AC5 | 工作区中仅 `AGENTS.md` 与 `CLAUDE.md` 两文件有改动，且文末成功追加 `Frozen Channel: TAD Lite` 节（提交前执行） | post-impl | `git status --porcelain \| grep -v "^\?\?" \| awk '{print $2}' && grep -cF "## Frozen Channel: TAD Lite" AGENTS.md` | 恰好为两文件路径紧随 `1` | (post-impl) |

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | CR-P0-1: §2.1.3 迁移 27-29 行会误删 Alex/Blake 角色与 Gate 定义 | §2.1.3 明确保留 Lines 27-28，仅删除 Line 29 的 Lite 句子；AC1 增加角色定义断言 | ✅ RESOLVED |
| code-reviewer | CR-P0-2: §2.2.3 "仅做字句精简" 过于模糊 | §1.3 与 §2.2.2 明确声明 §2.5 保持 byte-identical，完全不改动 | ✅ RESOLVED |
| code-reviewer | CR-P0-3: AC1 预期行号范围与 Line 60 隔离规则冲突 | §9.1 重新设计 AC1/AC2 为范围与精准语义过滤，彻底消除误伤 | ✅ RESOLVED |
| code-reviewer | CR-P1-1: AC2 缺乏区分度 | §9.1 AC3 改为直接检验行 3-5 的 blockquote 行数及互斥条款 | ✅ RESOLVED |
| code-reviewer | CR-P1-2: 文末注缺少 trigger 到 role 的结构化映射 | §2.1.4 补全完整的 trigger 映射列表（Alex Lite / Blake Lite） | ✅ RESOLVED |
| security-auditor | SEC-P0-1: Line 60 路由隔离规则在 MQ1 基线遗漏且被 AC1 误伤 | §5 MQ1 更新为 5 行基线，AC2 将 Line 60 列为合法白名单 | ✅ RESOLVED |
| security-auditor | SEC-P0-2: 角色定义与 Gate 3/4 权属丢失风险 | §2.1.3 严格保留 Lines 27-28；AC1 加入 positive 断言 | ✅ RESOLVED |
| security-auditor | SEC-P0-3: §2.5 精简可能削弱“通道由人裁定”与“修改框架自身”等核心条款 | §2.2.2 声明 §2.5 byte-identical，AC3 验证核心互斥条款存活 | ✅ RESOLVED |
| security-auditor | SEC-P1: 治理台账行号漂移风险 | frontmatter gate4_delta 明确记录漂移，文本锚点保持不变 | ✅ RESOLVED |

---

## 10. Critical Warnings
- ⚠️ **消音 ≠ 破坏显式可用**：文末必须有清晰的 `## Frozen Channel: TAD Lite (Explicit Invocation Only)` 注释，保留全部触发词供显式查阅。
- ⚠️ **严禁触碰 `.claude/skills/*lite*` 或 `.agents/skills/*lite*`**：这是冻结资产，必须保持 byte-identical。
- ⚠️ **严禁修改 `CLAUDE.md` §2.5**：治理条款必须原封不动。
- ⚠️ **提交规范**：仅提交 `AGENTS.md` 与 `CLAUDE.md`，使用显式 pathspec：`git add AGENTS.md CLAUDE.md`。
