---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development (Full TAD)

**From:** Alex (Agent A - Solution Lead)  
**To:** Blake (Agent B - Execution Master)  
**Date:** 2026-09-06  
**Project:** TAD Framework (upstream)  
**Task ID:** TASK-20260906-FWHEALTH-B  
**Handoff Version:** 3.1.0  
**Epic:** `.tad/active/epics/EPIC-20260816-framework-health-repair.md` (Close-out Track B: 1b 搬运 + SC2 + SC3 瘦身)  
**Design:** `.tad/active/designs/DESIGN-20260906-framework-health-closeout-b.md`  
**Priority:** P1  

---

## 🔴 Gate 2: Design Completeness (Alex 必填)

**执行时间**: 2026-09-06

### Gate 2 检查结果

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ PASS | 完整涵盖 1b 约束退休与 SC3 瘦身两大模块，且设计了隔离 worktree 同步与前置对比门控 |
| Components Specified | ✅ PASS | 精确覆盖 `.claude/skills/alex/`、`.agents/skills/alex/` 12 个文件、worktree 同步脚本、`comm -23` 门控及 `main` 分支清理 |
| Functions Verified | ✅ PASS | 复用 `release-verify.sh parity .`、`git worktree`、`git rm --cached`，命令在当前环境经验证完全可行 |
| Data Flow Mapped | ✅ PASS | 1b 约束迁移 → parity 校验 → commit 1 → worktree 强制同步 orphan → pre-removal gate 检验 → rm --cached → commit 2 |
| Expert Review Complete | ✅ PASS | `code-reviewer` + `security-auditor` 双专家独立审查全通过，5 个 P0 缺陷已全部闭环修复与验证 |

**Gate 2 结果**: ✅ PASS

**Alex 确认**: 我已验证所有设计要素与审查意见，Blake 可以独立根据本文档完成实现与验证。

---

## 📋 Handoff Checklist (Blake 必读)

Blake 在开始实现前，请确认：
- [ ] 阅读了所有章节
- [ ] 理解了核心意图：
  - **1b 目标**: 退休 `alex/SKILL.md` frontmatter 约束块，将 O1/O2/G1 写入正文义务句，清理 16 处悬空引用，双树 parity 达标。
  - **SC3 目标**: 零数据损失地将 134 个 evidence/archive 文件同步入 `maintainer-evidence` 分支（覆盖 `.log` 忽略规则），并通过 `comm -23` 门控后，从 `main` 索引移除跟踪，tarball 降幅 ≥ 70%。
- [ ] 理解关键禁令：
  - 严禁执行 `git clean -x` 或 `rm -rf` 物理删除 evidence/archive（必须保留在工作区磁盘）。
  - 严禁执行 `git push`（所有提交保持本地）。
  - 严禁附加 pathspec 提交 `main` 上的 cached removal（避免 partial commit 旁路暂存区）。
  - 严禁删除 `.tad/evidence` 与 `.tad/archive` 之外的任何文件。

---

## 1. Task Overview

### 1.1 What We're Building
本任务是 Framework-Health 框架健康修复 Epic 的最终收口工单（Track B），包含两部分：
1. **1b 搬运 (SC2)**: 移除 `alex/SKILL.md` frontmatter 中从未被机械解析的 `constraints:` 与 `migration:` 块，消除 9 处 `deny_ref`；将真孤儿禁令（O1 hook_scripts, O2 tool_blocking, G1 hook_registration）及 SC2 锚点（`gate4_delta`, `step1d_ac_dryrun`, `step0_graph`）搬入正文义务句；清理 references 目录中 16 处悬空引用（`.claude` 与 `.agents` 两侧共 32 处），保持双树 100% 字节一致。
2. **SC3 发行瘦身 (SC3)**: 将 2026-08-16 之后引入但未被 orphan 分支收录的 134 个维护凭证与归档文件安全备份至 `maintainer-evidence` 分支；在通过机械化零缺失门控后，从 `main` 分支的 git 跟踪中移除（物理文件完好保留在工作区），使 `main` 分支打包体积相对 31.6MB 审计基线降幅达到 72.5%（tarball 体积降至 8.71MB，严格达标 SC3）。

### 1.2 Why We're Building It
- **SC2 合规**: 消除失效的 frontmatter 治理层，使规则回归直观的 prompt 层义务句，消除悬空指针与无用元数据。
- **SC3 达标**: 解决后发特性对 `main` 分支引入的体积膨胀，保证下载 TAD 发行包的用户无需拉取维护者调试记录，重新满足 Epic 发行标准。

---

## 2. Proposed Changes & Implementation Steps

### 2.1 Step 1: 1b 文档修改与悬空引用清理 (Commit 1)

#### 1. 精简 `alex/SKILL.md` Frontmatter
同时修改 `.claude/skills/alex/SKILL.md` 和 `.agents/skills/alex/SKILL.md`，将 frontmatter 替换为标准头：
```yaml
---
name: alex
description: "TAD Solution Lead (Agent A). Use for new features (>3 files), architecture changes, complex multi-step requirements, multi-module refactoring. Supports modes: *bug, *discuss, *idea, *learn, *publish."
---
```
（移除原 lines 4–147 的 `constraints_schema`, `constraints:`, `section_overrides:`, `migration:` 块）。

#### 2. 在正文义务句中补齐 O1/O2/G1 与 SC2 锚点
在 `.claude/skills/alex/SKILL.md` 与 `.agents/skills/alex/SKILL.md` 的 `## ⚠️ 义务型祈使句（常驻层最低保障：忘记 = 跳过 = v2.7）` 列表中追加/确认以下条款：
```markdown
- Alex 不得向 .claude/settings.json 或 .codex/hooks.json 注册任何运行时钩子（PreToolUse, PostToolUse, UserPromptSubmit, SessionStart）
- Alex 不得创建或修改 hook 脚本（.tad/hooks/*.sh，由 Blake 实现）
- Alex 协议机制不得阻断 Write、Edit、Read 基础工具（never_block）
- Gate 4 验收时若发现预期与实际偏差，通过 gate4_delta 记录审计偏差，不得通过脚本自动注入或以此阻塞
- 设计交接前必须执行 step1d_ac_dryrun 空跑，不得以小 handoff 为由跳过，亦不得将其提升为阻塞门
- 通过 step0_graph 探测代码图谱，必须遵守 500ms 预算且不得触发自动建索
```

#### 3. 清理 16 处悬空引用（`.claude` 与 `.agents` 两侧共 32 处）
在两侧对应的 protocol 文件中做如下修改：
1. `references/acceptance-protocol.md`:
   - 移除 line 315 的注释行 `# Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.skip_knowledge_assessment`
   - 将 line 360 的 `enforcement: "prompt-level-only"  # See constraints.enforcement (global)` 改为自足声明 `enforcement: "prompt-level-only"`
   - 移除 line 361 的注释行 `# Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.gate4_delta`
2. `references/cancel-protocol.md`:
   - 将 line 103 改为自足声明 `enforcement: "prompt-level-only"`
   - 移除 line 108 的注释行 `# Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.cancel_protocol`
3. `references/experiment-path-protocol.md`:
   - 将 line 109 改为自足声明 `enforcement: "prompt-level-only"`
   - 移除 line 110 的注释行 `# Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.experiment_path`
4. `references/express-path-protocol.md`:
   - 将 line 53 改为自足声明 `enforcement: "prompt-level-only"`
   - 移除 line 54 的注释行 `# Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.express_path`
5. `references/handoff-creation-protocol.md`:
   - 移除 line 308 与 443 的注释行 `# Mechanical deny: see constraints.deny (global) + constraints.section_overrides...`
   - 将 line 310 与 445 的 `- "MUST NOT register hooks or modify settings — see constraints.deny (global)"` 改为 `- "MUST NOT register hooks or modify settings"`
   - 移除 line 342 与 519 的注释行 `# Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides...`
6. `SKILL.md`:
   - 移除 line 703 的注释行 `# Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.cross_model_awareness`

#### 4. 提交 Commit 1
运行双树一致性验证并提交：
```bash
bash .tad/hooks/lib/release-verify.sh parity .
git add .claude/skills/alex/ .agents/skills/alex/
git commit -m "feat(skills): retire alex constraints frontmatter and drop dangling references (1b/SC2)"
```

---

### 2.2 Step 2: SC3 纯删除 Sweep 与 Orphan 分支同步 (Commit 2)

#### 1. 前置条件检查（Precondition）
```bash
test -z "$(git status --porcelain --untracked-files=no)" || { echo "ERROR: Main working tree dirty"; exit 1; }
```

#### 2. 在临时 worktree 中同步并强制暂存
```bash
WT_DIR="$(mktemp -d /tmp/evidence-sync.XXXXXX)"
git worktree add "$WT_DIR" maintainer-evidence

# 复制当前跟踪的 134 个文件至 worktree
git ls-files -z '.tad/evidence/*' '.tad/archive/*' | while IFS= read -r -d '' f; do
  mkdir -p "$WT_DIR/$(dirname "$f")"
  cp -p "$f" "$WT_DIR/$f"
done

# 在 worktree 内强制暂存（使用 -f 覆盖 *.log 规则）并提交
(
  cd "$WT_DIR"
  git add -f .tad/evidence .tad/archive
  git commit -m "chore(evidence): sync 134 post-phase4 evidence and archive records to maintainer-evidence"
)

# 强制清理临时 worktree
git worktree remove --force "$WT_DIR"
```

#### 3. 强制前置阻塞门控（Pre-Removal Gate）
在对 `main` 进行任何修改前，运行全量集合对比：
```bash
git ls-files '.tad/evidence/*' '.tad/archive/*' | sort > /tmp/expected_evidence.txt
git -c core.quotePath=false ls-tree -r maintainer-evidence --name-only | grep -E '^\.tad/(evidence|archive)/' | sort > /tmp/actual_orphan.txt
MISSING_FILES=$(comm -23 /tmp/expected_evidence.txt /tmp/actual_orphan.txt)

if [ -n "$MISSING_FILES" ]; then
  echo "ABORT: Data safety gate failed! Following files missing from maintainer-evidence:"
  echo "$MISSING_FILES"
  rm -f /tmp/expected_evidence.txt /tmp/actual_orphan.txt
  exit 1
fi
rm -f /tmp/expected_evidence.txt /tmp/actual_orphan.txt
echo "PRE-REMOVAL GATE PASS: All 134 files verified in maintainer-evidence."
```

#### 4. 从 `main` 移除索引并提交 Commit 2
```bash
git rm --cached -r .tad/evidence .tad/archive
git commit -m "chore(framework): stop tracking .tad/evidence and .tad/archive on main (SC3)"
```
⚠️ **严禁附加 pathspec**（如 `-- .tad/evidence`），避免触发 partial commit 旁路暂存区 cached removal。

同时更新 `.gitignore` 中 lines 124–125 的前导注释，明确注明本地与远端分支的取回说明。

---

## 5. 🆕 强制问题回答（Evidence Required）

### MQ1: 历史代码搜索
- 确认 `deny_ref` 在两树各有 9 处，`constraints.*` 悬空引用各有 16 处。
- 确认 134 个待瘦身文件（112 evidence + 22 archive），包含 2 个特殊 `.log` 文件。
- 确认当前 tarball 大小为 9,427,444 字节。

### MQ2: 函数与命令存在性
- `release-verify.sh parity .` 存在并可用。
- `git worktree`、`git rm --cached`、`comm -23` 在 macOS 环境原生可用。

---

## 7. 详细文件清单

| 文件路径 | 变更类型 | 说明 |
|----------|----------|------|
| `.claude/skills/alex/SKILL.md` | MODIFY | 退休 frontmatter，补齐 O1/O2/G1 与 SC2 锚点义务句，清理 line 703 引用 |
| `.agents/skills/alex/SKILL.md` | MODIFY | 镜像同步 |
| `.claude/skills/alex/references/*.md` (5个文件) | MODIFY | 清理 15 处悬空引用，使 enforcement 成为自足声明 |
| `.agents/skills/alex/references/*.md` (5个文件) | MODIFY | 镜像同步 |
| `.tad/evidence/` 与 `.tad/archive/` (134个文件) | UNTRACK (git rm --cached) | 从 `main` 索引移除跟踪，物理文件保留 |
| `maintainer-evidence` (git branch) | SYNC | 通过 worktree 强行提交纳入 134 个文件 |
| `.gitignore` | MODIFY | 更新 lines 124-125 前导注释 |

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence |
|---|---------------------|-------------------|--------------------|-------------------|
| AC1 | SC2: `.claude/skills/alex/SKILL.md` 中 `deny_ref` 计数为 0（带判空保护） | post-impl | `[ "$(grep -c 'deny_ref' .claude/skills/alex/SKILL.md \|\| true)" -eq 0 ] && echo "0"` | `0` |
| AC2 | SC2: 正文义务句中包含 `gate4_delta`、`step1d_ac_dryrun`、`step0_graph` 锚点各 ≥ 1 | post-impl | `grep -cF 'gate4_delta' .claude/skills/alex/SKILL.md && grep -cF 'step1d_ac_dryrun' .claude/skills/alex/SKILL.md && grep -cF 'step0_graph' .claude/skills/alex/SKILL.md` | 输出三行均 `>= 1` |
| AC3 | O1/O2/G1 禁令在 `alex/SKILL.md` 正文明确存在 | post-impl | `grep -cF "Alex 不得创建或修改 hook 脚本" .claude/skills/alex/SKILL.md && grep -cF "never_block" .claude/skills/alex/SKILL.md && grep -cF "Alex 不得向 .claude/settings.json 或 .codex/hooks.json 注册任何运行时钩子" .claude/skills/alex/SKILL.md` | 输出三行 `1` |
| AC4 | `alex/` 协议文件内零 `constraints.deny` 与 `constraints.enforcement` 悬空指针 | post-impl | `(grep -rn -e 'constraints\.deny' -e 'constraints\.enforcement' -e 'section_overrides' .claude/skills/alex/ \|\| true) \| wc -l \| tr -d ' '` | `0` |
| AC5 | `.claude/skills` 与 `.agents/skills` 保持完全字节一致 | post-impl | `bash .tad/hooks/lib/release-verify.sh parity .` | `VERDICT: parity PASS (exit 0)` |
| AC6 | SC3 主判据: `main` 分支中 evidence 与 archive 跟踪数清零 | post-impl | `echo -n "evidence: " && git ls-files '.tad/evidence/*' \| wc -l \| tr -d ' ' && echo -n "archive: " && git ls-files '.tad/archive/*' \| wc -l \| tr -d ' '` | `evidence: 0` 且 `archive: 0` |
| AC7 | SC3 可追溯性: `maintainer-evidence` 分支持有全部新旧文件（数量 ≥ 4377，包含两个 .log 文件） | post-impl | `[ "$(git -c core.quotePath=false ls-tree -r --name-only maintainer-evidence .tad/evidence .tad/archive \| wc -l \| tr -d ' ')" -ge 4377 ] && git cat-file -e maintainer-evidence:.tad/evidence/yolo/local-wiki-browser-ingest/external/rollback-replay.log && echo "ORPHAN_SYNC_PASS"` | `ORPHAN_SYNC_PASS` |
| AC8 | SC3 辅助度量: `git archive` tarball 压缩包体积降至 8.9MB 以下（相对基线 31.6MB 降幅 ≥ 70%） | post-impl | `tar_size=$(git archive --format=tar HEAD \| gzip -9 \| wc -c) && echo "tarball: $tar_size" && [ "$tar_size" -lt 8900000 ] && [ "$tar_size" -le 9497775 ] && echo "SIZE_PASS"` | `SIZE_PASS` |
| AC9 | 磁盘物理文件零损失：本地工作区 `.tad/evidence` 与 `.tad/archive` 目录及 134 个文件依然存在 | post-impl | `[ -d .tad/evidence ] && [ -d .tad/archive ] && [ "$(find .tad/evidence .tad/archive -type f \| wc -l \| tr -d ' ')" -ge 134 ] && echo "PHYSICAL_FILES_PRESERVED"` | `PHYSICAL_FILES_PRESERVED` |
| AC10 | 严格无 push：本地提交完备，`origin/maintainer-evidence` 与 `origin/main` 保持原状未推送 | post-impl | `[ "$(git rev-parse origin/maintainer-evidence)" = "b695660661fd8ee210061cfd0de04b77cf61c020" ] && [ "$(git rev-parse maintainer-evidence)" != "b695660661fd8ee210061cfd0de04b77cf61c020" ] && echo "NO_PUSH_PASS"` | `NO_PUSH_PASS` |

---

## 9.2 Expert Review Status (Alex 必填)

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| `code-reviewer` | AC8 阈值 8.5MB 无法达成（HEAD 实测 8.71MB） | §1 与 §9.1 AC8 更新为 `≤ 8.9MB`（降幅 72.5% ≥ 70%） | ✅ RESOLVED |
| `code-reviewer` | AC4 正则转义在 BSD 下失效 | §9.1 AC4 改为标准多 `-e` 形式，彻底杜绝管道与转义冲突 | ✅ RESOLVED |
| `code-reviewer` | AC1 退出码保护缺失 | §9.1 AC1 增加 `|| true` 与整数比较保护 | ✅ RESOLVED |
| `code-reviewer` | AC10 缺乏对远端 orphan 分支的保护校验 | §9.1 AC10 改为锁定 `origin/maintainer-evidence` 字面 SHA 比对 | ✅ RESOLVED |
| `security-auditor` | 两个 `.log` 证据文件被 orphan 分支 `.gitignore` 静默忽略导致丢失 | §2.2.2 强制 `git add -f`；AC7 加入 `rollback-replay.log` 存在性断言 | ✅ RESOLVED |
| `security-auditor` | 缺少机械化前置零缺失校验门控 | §2.2.3 增加强制阻塞脚本 `comm -23`，缺失任何文件立即 abort | ✅ RESOLVED |
| `security-auditor` | scoped commit (`git commit -- <paths>`) 在 `--cached` 下是 no-op | §2.2.4 移除 commit pathspec，避免 partial commit 旁路暂存区 | ✅ RESOLVED |
| `security-auditor` | 前置预检使用 `grep -v '^\?\?'` 在 BSD 下 fail-open | §2.2.1 改为原生参数 `--untracked-files=no`，无 grep 隐患 | ✅ RESOLVED |
| `security-auditor` | 需明确两步执行顺序以保证状态干净 | §2 明确次序：§2.1 提交 Commit 1，然后再执行 §2.2 提交 Commit 2 | ✅ RESOLVED |

---

## 10. Critical Warnings
- ⚠️ **严禁 `git clean -x` 或物理删除**: SC3 仅为 `git rm --cached`（从 git 索引移除跟踪），绝非物理删除！
- ⚠️ **严禁删除 `.tad/evidence` 与 `.tad/archive` 之外的任何文件**: 不得以追求更小 tarball 为由删除 assets、docs 或 research 资源。
- ⚠️ **强制执行前置门控**: 必须在 `maintainer-evidence` 完成提交且 `comm -23` 验证零缺失后，方可在 `main` 执行 `git rm --cached`。
- ⚠️ **强制 `git add -f`**: 同步至 orphan 时必须使用 `-f` 保证两个 `.log` 证据文件不被分支 `.gitignore` 静默丢弃。
- ⚠️ **必须镜像同步**: 所有对 `.claude/skills/alex/` 的修改必须 1:1 同步到 `.agents/skills/alex/`，并通过 `release-verify.sh parity .`。
- ⚠️ **严禁 Push**: 仅在本地提交，等待用户明确的发布/同步指令。在 orphan 分支推送前，本地保留的物理文件是唯二副本之一，严禁执行 `git clean -xdf`。
