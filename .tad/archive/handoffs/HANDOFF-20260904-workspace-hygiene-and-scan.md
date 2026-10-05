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
**Date:** 2026-09-04
**Project:** TAD Framework (upstream, self-hosted)
**Task ID:** TASK-20260904-002
**Handoff Version:** 3.1.0
**Epic:** N/A
**Supersedes:** N/A

---

## 🔴 Gate 2: Design Completeness (Alex必填)

**执行时间**: 2026-09-04

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Expert review complete (min 2) | ✅ | code-reviewer 与 security-auditor 双专家完成审查，均提报 2 个 P0 与 2 个 P1；全部完成针对性修复 |
| All P0 resolved | ✅ | P0-1 (driver.mjs:36 遗留 /Users/ 路径) & P0-2 (明确 git add 显式 pathspec 防污染) 已全部闭环修复 |
| Architecture complete | ✅ | 单一维护与卫生收尾事务；边界清晰，含 worktrees 保护与 safe rm 守卫 |
| Components specified | ✅ | 包含 `.gitignore` 规则、带守卫的临时目录删除、路径彻底脱敏、扫描刷新与严格限定的单 commit 规程 |
| Functions verified | ✅ | 仅使用 git, rm, 及 `*research-github scan` 现有协议，无调用缺失 |
| Data flow mapped | ✅ | 工作树状态变更 → 扫描日志更新 → 显式 pathspec 暂存 → 单一 Git 提交闭环 |

**Gate 2 结果**: ✅ PASS

**Alex确认**: 我已验证所有设计要素，所有 P0 均已彻底修复，Blake 可以独立根据本文档完成实现。

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

## 0. Socratic Inquiry Summary & Gate 1

**Task**: 清理当前工作区未跟踪噪音（`.worktrees/` 忽略，带守卫删除测试残留 `progress/`），固化已验证的有效修改（`phase2-pair-driver.mjs` 彻底路径脱敏、`release-sync.md` 发布经验沉淀、`NEXT.md` 任务状态更新），并恢复已停滞 53 天的 GitHub Registry 扫描。

**Complexity**: Small（配置与卫生清理任务，Light TAD 流程）。

**Questions Asked & Decisions**:
1. **代码与配置组织**：用户确认合并为一个清晰的维护提交（Single Commit），将 `.gitignore`、路径脱敏、知识沉淀与 `NEXT.md` 统一提交，避免碎片化 commit。
2. **例行扫描**：用户确认在本次任务中一并执行 GitHub Registry 全量扫描刷新，恢复 `.tad/github-registry/scan-log.yaml` 的感知能力。

### Gate 1: Requirements Clarity

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Problem defined | ✅ | 工作区存在未跟踪杂质、路径硬编码隐患、知识未提交，且生态扫描停滞 53 天 |
| User identified | ✅ | TAD 开发者与维护者 |
| Scope bounded | ✅ | 明确限于：.gitignore, rm progress/, driver 路径动态化, release-sync 知识入库, NEXT.md 更新, github scan 刷新, 单 commit |
| Acceptance criteria verifiable | ✅ | §9.1 提供了逐行可独立运行且适配 BSD/POSIX 与自动化 assertion 的验证命令 |

**Gate 1 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 Intent Statement
彻底清洁当前 TAD 主工作树，消除未跟踪文件噪音，彻底消除本地绝对路径泄漏，闭环沉淀 v2.44 发布模式经验，并重启生态感知扫描。

### 1.2 Non-Goals
- 不修改 TAD 核心运行协议（alex/blake SKILL 逻辑）
- 不删除或修改 `.worktrees/` 内部的任何活跃分支与未提交变更（仅在 `.gitignore` 中将其忽略）
- **严禁执行 `git clean -xfd` 或 `git clean -x`**（这会摧毁 `.worktrees/` 中的分支与工作区）
- 不向外部 GitHub 远程仓库推送（git commit 仅在本地生效）
- 不暂存 `.tad/active/handoffs/` 下的未提交在飞 handoff

---

## 2. Architecture & File Changes

### 2.1 变更清单
1. **`.gitignore`**:
   - 在 `# Claude Code local session/memory + sub-agent worktree artifacts` 段落追加 `.worktrees/`，使根目录下的 worktrees 目录被 git 忽略。
2. **`progress/`**:
   - 彻底删除未跟踪的临时测试文件夹 `progress/`。必须带 cwd 与内容守卫：
     ```bash
     cd "$(git rev-parse --show-toplevel)"
     test -f progress/fast-installer.sh && rm -rf -- ./progress
     ```
3. **`.tad/scripts/phase2-pair-driver.mjs` (MODIFY)**:
   - 引入 `os` 模块：`import os from 'node:os';`
   - Line 14（已改）：`const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');`
   - **Line 36（必须修复，P0-1）**：将硬编码的 `'/Users/sheldonzhao/.opencode/bin/opencode'` 改为动态解析：
     `const OPENCODE = process.env.TAD_JUDGE_BIN || path.join(os.homedir(), '.opencode/bin/opencode');`
   - 确保全文件 `grep "/Users/"` 严格为 0。
4. **`.tad/project-knowledge/patterns/release-sync.md`**:
   - 确认包含 v2.44.0 沉淀的 `A Version-Staleness Grep Gate Without a Maintained Exclusion Contract Ends Every Release in Override - 2026-09-04` 条目。
5. **`NEXT.md`**:
   - 确认已记录 Public-facade cleanup 与 Publish v2.44.0 bundle 的 Gate 4 验收状态。
6. **`.tad/github-registry/scan-log.yaml`**:
   - 依据 `.claude/skills/research-github/SKILL.md` 的 scan 协议执行扫描：
     执行 `gh api` 检查 freshness，刷新 `.tad/github-registry/scan-log.yaml` 的 `last_scan` 为当前日期（2026-09-04）。
7. **Git 提交 (P0-2 显式 Pathspec)**:
   - 严禁 `git add .` 或 `git add -A`！
   - 严格执行显式文件列表暂存：
     ```bash
     git add .gitignore \
             .tad/scripts/phase2-pair-driver.mjs \
             .tad/project-knowledge/patterns/release-sync.md \
             NEXT.md \
             .tad/github-registry/scan-log.yaml
     ```
   - 暂存区泄漏前置防御检查：
     ```bash
     git diff --cached | grep -n "/Users/" && { echo "ABORT: personal path staged"; exit 1; }
     ```
   - 执行单一 commit：
     `git commit -m "chore: workspace hygiene, portable driver path & v2.44 release sync knowledge"`

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
- 检查 `.gitignore` 中是否已有根 `.worktrees/`：
  `grep -n "\.worktrees" .gitignore` → 目前只有 `.claude/worktrees/`，根目录 `.worktrees/` 缺失。
- 检查 `phase2-pair-driver.mjs` 中的硬编码：
  `grep -n "/Users/" .tad/scripts/phase2-pair-driver.mjs` → 发现 Line 36 残留 `'/Users/sheldonzhao/.opencode/bin/opencode'`，已明确要求用 `os.homedir()` 消除。

### MQ2: 函数与命令存在性验证
- `rm -rf -- ./progress` 位于当前根目录，被 `test -f progress/fast-installer.sh` 守卫保护。
- `git commit` 工具与 git 环境有效。
- `gh` CLI 工具已登录验证有效。

---

## 7. 详细文件清单

| 文件路径 | 变更类型 | 说明 |
|----------|----------|------|
| `.gitignore` | MODIFY | 增加 `.worktrees/` 忽略项 |
| `progress/` | DELETE | 安全守卫删除测试残留临时目录 |
| `.tad/scripts/phase2-pair-driver.mjs` | MODIFY | 彻底动态解析根路径与 OPENCODE 路径，消除所有 `/Users/` |
| `.tad/project-knowledge/patterns/release-sync.md` | VERIFY/COMMIT | 记录版本门排除契约经验 |
| `NEXT.md` | VERIFY/COMMIT | 记录完成事项 |
| `.tad/github-registry/scan-log.yaml` | MODIFY | 扫描日志刷新 |

---

## 8. Quality Checklist & Pre-flight

- [ ] **路径安全性 (Zero Leak)**：`phase2-pair-driver.mjs` 中无任何明文硬编码个人目录（`/Users/sheldonzhao`）
- [ ] **暂存区安全防御**：`git diff --cached | grep "/Users/"` 必须 0 命中
- [ ] **工作树安全边界**：`.tad/active/handoffs/` 下的在飞文件保持独立，严禁被误 stage
- [ ] **单一提交原则**：必须遵循用户决策，只产生一个干净且包含且仅包含上述 5 个目标文件的 commit

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output (Alex step1d) |
|---|---------------------|-------------------|--------------------|-------------------|-------------------------------|
| AC1 | `.gitignore` 包含 `.worktrees/` | post-impl | `grep -cE '^/?\.worktrees/' .gitignore` | `>= 1` | (post-impl) |
| AC2 | `progress/` 目录已被完全清除 | post-impl | `test ! -d progress && echo "DELETED"` | `DELETED` | (post-impl) |
| AC3 | `phase2-pair-driver.mjs` 彻底消除 `/Users/` 路径 | post-impl | `(grep -c "/Users/" .tad/scripts/phase2-pair-driver.mjs \|\| true)` | `0` | (post-impl) |
| AC4 | `scan-log.yaml` 上次扫描日期已刷新为今日 | post-impl | `grep "last_scan:" .tad/github-registry/scan-log.yaml` | 包含 `2026-09-04` | (post-impl) |
| AC5 | 工作区中指定的未跟踪项已彻底清理 | post-impl | `test -z "$(git status --porcelain \| grep -E '(\.worktrees/\|progress/)')" && echo "CLEAN"` | `CLEAN` | (post-impl) |
| AC6 | 所有变更已成功作为单个提交入库 | post-impl | `git log -1 --oneline` | 包含 `chore: workspace hygiene` | (post-impl) |
| AC7 | 提交的文件范围精准无任何越界 | post-impl | `git show --stat --name-only HEAD \| grep -cE '(\.gitignore\|phase2-pair-driver\.mjs\|release-sync\.md\|NEXT\.md\|scan-log\.yaml)'` | `5` | (post-impl) |

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| code-reviewer | P0-1: `phase2-pair-driver.mjs:36` 仍残留 `/Users/sheldonzhao`，MQ1 错误且 AC3 必挂 | §2.1 item 3, §5 MQ1, §7 改为 MODIFY 并引入 `os.homedir()` | Resolved |
| code-reviewer | P0-2: 缺少显式 pathspec，`git add .` 会误将活跃 handoff 卷入提交 | §2.1 item 7 & §8 增加显式 5 文件 pathspec 与防御断言 | Resolved |
| code-reviewer | P1-1: AC5 负向自然语言检查无法自动化运行 | §9.1 AC5 重写为基于 `test -z` 的自动化可判别命令 | Resolved |
| code-reviewer | P1-2: `grep -c` 0 命中时退出码为 1 破坏执行流 | §9.1 AC3 补齐 `\|\| true` 保证管道健全 | Resolved |
| security-auditor | P0-1: 同 code-reviewer P0-1，未完全消除个人路径隐私隐患 | 同上，Line 36 彻底动态化 | Resolved |
| security-auditor | P0-2: 同 code-reviewer P0-2，无范围 git add 导致公共库发布意外敏感文件 | 同上，显式 pathspec + `git diff --cached` 防御 | Resolved |
| security-auditor | P1-1: `.worktrees/` 含有真实活跃分支，`git clean -xfd` 会导致致命数据丢失 | §1.2 & §10 增加严正警告：严禁执行 `git clean -x` | Resolved |
| security-auditor | P1-2: `rm -rf progress` 缺少目录与内容守卫 | §2.1 item 2 补充 `git rev-parse` 与文件指纹守卫 | Resolved |

### Gate 2 最终结论
- **Gate 2: ✅ PASS**（所有 P0/P1 已在文档与 AC 中闭环解决）

---

## 10. Critical Warnings
- ⚠️ **严禁使用 `git clean -xfd` 或 `git clean -x`**：`.worktrees/` 包含 4 个活跃的 git worktrees（包括未提交的 `tad-yolo2-candidate`），ignore 后如果盲目执行 clean 将导致真实代码丢失！
- ⚠️ **严禁盲目执行 `git add .` 或 `git add -A`**：当前工作树包含正在编辑/未归档的 handoff 文件，必须使用显式 pathspec 提交。
- ⚠️ 提交前必须使用 `git diff --cached` 进行 staged 审查，核对无越界文件后方可 commit。

---

## 📚 Project Knowledge

### ⚠️ Blake 必须注意的历史教训
1. **Never Hand-Write What an Existing Tool Already Does (2026-05-28)**：
   运行 GitHub Registry 扫描时，直接遵循 `.claude/skills/research-github/SKILL.md` 中现有的 scan 规程，不要自创扫描逻辑。
2. **Deny-List Beats Allow-List for Sync Sets (2026-06-01)**：
   在 `.gitignore` 中正确配置目录排除，避免本地测试与工作树文件污染版本历史。
3. **Shell Env-Var and Path Portability (2026-05-19 & 2026-04-03)**：
   确保脚本使用 `import.meta.url` 和 `path.resolve` / `os.homedir()` 动态定位仓库与工具路径，保证跨机器可移植性与隐私安全。
