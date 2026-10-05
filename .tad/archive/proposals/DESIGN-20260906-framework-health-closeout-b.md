# Technical Design: Framework-Health Close-out B — 1b 搬运 + SC2 + SC3 Re-slim

**Design ID**: `DESIGN-20260906-framework-health-closeout-b`  
**Epic**: `.tad/active/epics/EPIC-20260816-framework-health-repair.md` (Phase 1b + Phase 4 re-slim remainder)  
**Execution**: Single Handoff, Full TAD (Human confirmed 2026-09-06)  
**Track**: Track B (Follow-up to Track A `f61c1892`+`1a256534` Gate 4 PASS)  
**Date**: 2026-09-06  
**Author**: Alex (Solution Lead)

---

## 0. Socratic Record (Gate 1 Clarification)

- **R1 Scope & Mandate (Human Ruled & Confirmed 2026-09-06)**:
  - Human decision ①: 最小集搬运（O1/O2/G1 进正文，O3/O4 不重复，因 `*skillify` 已退役）。
  - Human decision ②: 纯删除 sweep（orphan `maintainer-evidence` 先补齐 134 个未同步文件，再在 `main` 执行 `git rm --cached`，E2b 走 orphan 取）。
  - Delivery Form: 单张工单（single handoff，1b 搬运 + SC3 瘦身合并执行）。
- **R2 SC2 禁令锚点清晰化**:
  - `alex/SKILL.md` frontmatter 的 `constraints:` 和 `migration:` 块完全退休，消除 9 处 `deny_ref`。
  - 在正文义务句（`## ⚠️ 义务型祈使句`）中明确写入 O1、O2、G1 以及 `gate4_delta`、`step1d_ac_dryrun`、`step0_graph` 对应约束，确保 SC2 无论针对单文件还是全目录检测均 100% 达标。
- **R3 孤儿分支同步与 Push 约束**:
  - 严格遵守“无显式授权不 push”原则。所有 git 操作（`maintainer-evidence` 分支更新、`main` 的 `git rm --cached`）全部在本地完成，严禁执行 `git push`。
- **R4 运行时与物理文件安全**:
  - 物理文件在工作区严格保留（利用现有 `.gitignore:124-125`），严禁执行 `git clean -x`。
  - 确认 `tad.sh` 与 `release-verify.sh` 对 `.tad/evidence` 和 `.tad/archive` 为零运行时读取（仅 `mkdir -p` 脚手架与 zero-touch 保护）。

---

## 1. Gate 1 — Requirements Clarity: ✅ PASS

- **需求来源**: `EPIC-20260816-framework-health-repair.md` 剩余未达标准则 SC2 与 SC3，以及 `CARRIER-MAP-alex-constraints.md` 第五轮更正结论。
- **目标可量化**:
  - SC2: `grep -c 'deny_ref' .claude/skills/alex/SKILL.md` == `0`，且正文中 `gate4_delta` / `step1d_ac_dryrun` / `step0_graph` 各出现 ≥ 1 次。
  - SC3 主判据: `git ls-files '.tad/evidence/*'` == `0`，`git ls-files '.tad/archive/*'` == `0`。
  - SC3 辅助度量: `git archive --format=tar HEAD | gzip -9 | wc -c` 相对审计基线 31,659,251 降幅 ≥ 70%（即体积 `≤ 9,497,775` 字节，实测当前树移出后约为 8.71MB，严格处于 8.7MB ~ 8.9MB 之间）。
  - 完整保留 134 个 evidence/archive 文件在 `maintainer-evidence` 分支中，可随时按需检视取回。
- **验收命令**: 10 条 AC 全部具备字面可执行命令与明确预期输出。

---

## 2. Mandatory Questions (MQ1 - MQ6)

### MQ1: Historical Code Search (搜索已有代码与基线)
1. **Frontmatter `constraints:` 块与 `deny_ref` 基线**:
   - `.claude/skills/alex/SKILL.md:38,48,58,70,81,89,98,107,119` 共 9 处 `deny_ref`。
   - `.agents/skills/alex/SKILL.md` 镜像同样为 9 处。
2. **References 悬空指针（32 处，两侧各 16 处）**:
   - `acceptance-protocol.md`: lines 315, 360, 361
   - `cancel-protocol.md`: lines 103, 108
   - `experiment-path-protocol.md`: lines 109, 110
   - `express-path-protocol.md`: lines 53, 54
   - `handoff-creation-protocol.md`: lines 308, 310, 342, 443, 445, 519
   - `SKILL.md`: line 703
3. **Evidence 与 Archive 跟踪状态基线**:
   - `git ls-files '.tad/evidence/*' | wc -l` = 112
   - `git ls-files '.tad/archive/*' | wc -l` = 22
   - 合计 134 个文件。全部为 2026-08-16 之后引入，目前在 `maintainer-evidence` 分支中均缺失（经 Python 集合比对，缺失 134/134）。
   - 当前 tarball 体积：9,427,444 字节（~9.43MB）。
   - 包含两个特殊 `.log` 文件被 `maintainer-evidence` 的 `.gitignore` 规则（`*.log`）匹配：
     - `.tad/evidence/yolo/local-wiki-browser-ingest/external/rollback-replay.log`
     - `.tad/evidence/yolo/yolo2-verified-orchestration/phase2/scope-proof/scope-proof.log`
     必须使用 `git add -f` 强制添加，否则会被静默漏掉！

### MQ2: Existing Function Verification (现有机制与命令复用)
- `release-verify.sh parity .`：用于校验 `.claude/skills` 与 `.agents/skills` 字节级一致性（当前基线 PASS，exit 0）。
- `git worktree`：用于安全隔离检出 `maintainer-evidence` 分支并同步 134 个文件，不污染主工作树。
- `git rm --cached`：仅从 git index 移除跟踪，不破坏磁盘物理文件。

### MQ3: Data Flow Completeness (数据流与流转完整性)
1. **1b 约束流**:
   - 删除 frontmatter `constraints:` 和 `migration:` 块 →
   - 提取 O1/O2/G1 禁令写入 `alex/SKILL.md` 正文 `## ⚠️ 义务型祈使句` →
   - 将 `gate4_delta`、`step1d_ac_dryrun`、`step0_graph` 对应约束显式写入正文 →
   - 清理 `references/` 下 16 处指向 `constraints.*` 的无用注释与引用 →
   - 同步至 `.agents/skills/alex/` 保证 parity pass。
2. **SC3 瘦身数据流**:
   - 检查 `main` 分支工作区为 clean 状态（使用 `git status --porcelain --untracked-files=no`，避开 BSD grep 转义陷阱）→
   - 在临时目录 `/tmp/evidence-sync` 创建 `maintainer-evidence` 的 worktree →
   - 将当前工作树中的 134 个 evidence 及 archive 文件复制到 worktree 对应目录 →
   - 在 worktree 中使用 `git add -f` 强制添加（确保覆盖 `.log` 忽略规则）并 commit →
   - 运行双向全集合比对（`comm -23`），必须 100% 确认 134 个文件完整存在于 `maintainer-evidence` 分支树中，否则立即 abort 退出 →
   - 使用 `git worktree remove --force` 清理临时 worktree →
   - 在 `main` 分支执行 `git rm --cached -r .tad/evidence .tad/archive` →
   - 执行 `git commit -m "chore(framework): stop tracking .tad/evidence and .tad/archive on main (SC3)"`（无 pathspec，避免 partial commit 模式忽略 cached removal）→
   - 验证 tarball 大小（降幅 ≥ 70%）与 `git ls-files` 为 0。

### MQ4: Visual Hierarchy (视觉/交互层)
- N/A（纯内部治理文档、Skill 规范与 Git 仓库瘦身）。

### MQ5: Failure Handling & Safety (失败处理与防灾)
- **防数据丢失 (P0-1 闭环)**: 在 worktree 内同步必须使用 `git add -f`，显式解除 `maintainer-evidence` 自身 `.gitignore` 对两个 `.log` 文件的静默忽略。
- **强制前置门控 (P0-2 闭环)**: 在 `main` 上执行 `git rm --cached` 之前，必须执行机械化集合对比脚本，若有任一文件缺失立即终止流程。
- **防误删物理文件**: 严禁执行 `git clean -x` 或 `rm -rf`。仅使用 `git rm --cached`。磁盘物理文件 100% 保持在工作区中。
- **防工作区污染与回滚预案 (P1-1 闭环)**: 使用独立 `git worktree` 操作，退出时 `--force` 清理。若 `main` 上的 commit 需要撤销，可通过 `git reset --soft HEAD~1 && git restore --staged .tad/evidence .tad/archive` 零损回滚。
- **防泄露与违规 Push (P1-2 闭环)**: 任何步骤均不调用 `git push`，AC10 显式断言 `origin/maintainer-evidence` 与 `origin/main` 的 remote tracking ref 未发生变动。
- **本地凭据保护声明 (P1-3 闭环)**: 本次变更后，134 个文件作为未跟踪物理文件存在于本地工作区，且已被纳入本地 `maintainer-evidence` 分支。在用户显式授权 push 该 orphan 分支前，严禁执行 `git clean -xdf`。

### MQ6: Research Priority
- 完全基于仓库内部审计结论（`AUDIT-20260816-framework-health.md`）与承载者地图（`CARRIER-MAP-alex-constraints.md`），无外部依赖。

---

## 3. Technical Design

### 3.1 1b: 退休 frontmatter 并落地 O1/O2/G1 与 SC2 锚点

#### 1. `alex/SKILL.md` Frontmatter 瘦身
将 `.claude/skills/alex/SKILL.md` 和 `.agents/skills/alex/SKILL.md` 的 frontmatter 由 147 行精简为标准头：
```yaml
---
name: alex
description: "TAD Solution Lead (Agent A). Use for new features (>3 files), architecture changes, complex multi-step requirements, multi-module refactoring. Supports modes: *bug, *discuss, *idea, *learn, *publish."
---
```
完全移除 `constraints_schema`、`constraints:`、`section_overrides:` 及 `migration:` 块。

#### 2. 正文义务句补齐（O1/O2/G1 与 SC2 锚点）
在 `.claude/skills/alex/SKILL.md` 与 `.agents/skills/alex/SKILL.md` 两侧的 `## ⚠️ 义务型祈使句（常驻层最低保障：忘记 = 跳过 = v2.7）` 中同步追加/规范以下核心条款：
- **G1 (hook registration)**: `Alex 不得向 .claude/settings.json 或 .codex/hooks.json 注册任何运行时钩子（PreToolUse, PostToolUse, UserPromptSubmit, SessionStart）`
- **O1 (hook scripts)**: `Alex 不得创建或修改 hook 脚本（.tad/hooks/*.sh，由 Blake 实现）`
- **O2 (tool blocking)**: `Alex 协议机制不得阻断 Write、Edit、Read 基础工具（never_block）`
- **gate4_delta 锚点**: `Gate 4 验收时若发现预期与实际偏差，通过 gate4_delta 记录审计偏差，不得通过脚本自动注入或以此阻塞`
- **step1d_ac_dryrun 锚点**: `设计交接前必须执行 step1d_ac_dryrun 空跑，不得以小 handoff 为由跳过，亦不得将其提升为阻塞门`
- **step0_graph 锚点**: `通过 step0_graph 探测代码图谱，必须遵守 500ms 预算且不得触发自动建索`

#### 3. 清理 `alex/references/` 中的 16 处悬空引用（两侧合计 32 处）
- `acceptance-protocol.md`:
  - 移除 line 315 的 `# Mechanical deny migrated to frontmatter...`
  - 将 line 360 的 `enforcement: "prompt-level-only"  # See constraints.enforcement (global)` 改为自足声明 `enforcement: "prompt-level-only"`
  - 移除 line 361 的 `# Mechanical deny migrated to frontmatter...`
- `cancel-protocol.md`:
  - 将 line 103 改为自足声明 `enforcement: "prompt-level-only"`
  - 移除 line 108 的 `# Mechanical deny migrated to frontmatter...`
- `experiment-path-protocol.md`:
  - 将 line 109 改为自足声明 `enforcement: "prompt-level-only"`
  - 移除 line 110 的 `# Mechanical deny migrated to frontmatter...`
- `express-path-protocol.md`:
  - 将 line 53 改为自足声明 `enforcement: "prompt-level-only"`
  - 移除 line 54 的 `# Mechanical deny migrated to frontmatter...`
- `handoff-creation-protocol.md`:
  - 移除 line 308 与 443 的 `# Mechanical deny: see constraints.deny (global)...`
  - 将 line 310 与 445 的 `- "MUST NOT register hooks or modify settings — see constraints.deny (global)"` 改为 `- "MUST NOT register hooks or modify settings"`
  - 移除 line 342 与 519 的 `# Mechanical deny migrated to frontmatter...`
- `alex/SKILL.md`:
  - 移除 line 703 的 `# Mechanical deny migrated to frontmatter...`

### 3.2 SC3: Evidence & Archive 纯删除 Sweep 与 Orphan 分支同步

> **执行次序约束**: §3.1 的 1b 文档修改与 parity 验证完成后，先在 `main` 提交独立 commit (`feat(skills): retire alex constraints frontmatter and drop dangling references (1b/SC2)`)，使工作区回归干净状态，然后再执行本节的 SC3 操作。

#### 1. 前置条件检查（Preconditions，NEW-P0-2 修复）
在执行任何 SC3 操作前，确认主分支处于干净状态（不使用 grep，使用原生参数避免 BSD grep 转义陷阱）：
```bash
test -z "$(git status --porcelain --untracked-files=no)" || { echo "ERROR: Main working tree dirty"; exit 1; }
```

#### 2. 使用安全隔离的 `git worktree` 同步 orphan 分支
```bash
WT_DIR="$(mktemp -d /tmp/evidence-sync.XXXXXX)"
git worktree add "$WT_DIR" maintainer-evidence

# 复制当前跟踪的 134 个文件至 worktree
git ls-files -z '.tad/evidence/*' '.tad/archive/*' | while IFS= read -r -d '' f; do
  mkdir -p "$WT_DIR/$(dirname "$f")"
  cp -p "$f" "$WT_DIR/$f"
done

# 在 worktree 内强制暂存（P0-1: 覆盖 *.log 规则）并提交
(
  cd "$WT_DIR"
  git add -f .tad/evidence .tad/archive
  git commit -m "chore(evidence): sync 134 post-phase4 evidence and archive records to maintainer-evidence"
)

# 强制清理临时 worktree（避免因临时元数据残留报错）
git worktree remove --force "$WT_DIR"
```

#### 3. 强制前置阻塞门控（Pre-Removal Gate, P0-2）
在 `main` 上执行 `git rm --cached` 之前，必须运行全量集合对比（使用 `-c core.quotePath=false` 避免非 ASCII 路径被引号包裹）：
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

#### 4. 在 `main` 分支移除索引并提交（NEW-P0-1 修复）
仅在第 3 步通过后，执行索引移除。**严禁附加 pathspec**（避免进入 partial commit 模式而旁路暂存区中的 cached removal）：
```bash
git rm --cached -r .tad/evidence .tad/archive
git commit -m "chore(framework): stop tracking .tad/evidence and .tad/archive on main (SC3)"
```
由于 `.gitignore:124-125` 已包含 `.tad/evidence/` 与 `.tad/archive/`，移除索引后工作区状态完全 clean，磁盘物理文件完好无损。
同时更新 `.gitignore:124-125` 前导注释，将单称 `origin/maintainer-evidence` 修正为包含本地与远端分支的完整追溯说明。

---

## 4. Acceptance Criteria (§9.1 Spec Compliance Checklist)

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence |
|---|---------------------|-------------------|--------------------|-------------------|
| AC1 | SC2: `.claude/skills/alex/SKILL.md` 中 `deny_ref` 计数为 0（带退出码保护） | post-impl | `[ "$(grep -c 'deny_ref' .claude/skills/alex/SKILL.md \|\| true)" -eq 0 ] && echo "0"` | `0` |
| AC2 | SC2: 正文义务句中包含 `gate4_delta`、`step1d_ac_dryrun`、`step0_graph` 锚点各 ≥ 1 | post-impl | `grep -cF 'gate4_delta' .claude/skills/alex/SKILL.md && grep -cF 'step1d_ac_dryrun' .claude/skills/alex/SKILL.md && grep -cF 'step0_graph' .claude/skills/alex/SKILL.md` | 输出三行均 `>= 1` |
| AC3 | O1/O2/G1 禁令在 `alex/SKILL.md` 正文明确存在 | post-impl | `grep -cF "Alex 不得创建或修改 hook 脚本" .claude/skills/alex/SKILL.md && grep -cF "never_block" .claude/skills/alex/SKILL.md && grep -cF "Alex 不得向 .claude/settings.json 或 .codex/hooks.json 注册任何运行时钩子" .claude/skills/alex/SKILL.md` | 输出三行 `1` |
| AC4 | `alex/` 协议文件内零 `constraints.deny` 与 `constraints.enforcement` 悬空指针 | post-impl | `(grep -rn -e 'constraints\.deny' -e 'constraints\.enforcement' -e 'section_overrides' .claude/skills/alex/ \|\| true) \| wc -l \| tr -d ' '` | `0` |
| AC5 | `.claude/skills` 与 `.agents/skills` 保持完全字节一致 | post-impl | `bash .tad/hooks/lib/release-verify.sh parity .` | `VERDICT: parity PASS (exit 0)` |
| AC6 | SC3 主判据: `main` 分支中 evidence 与 archive 跟踪数清零 | post-impl | `echo -n "evidence: " && git ls-files '.tad/evidence/*' \| wc -l \| tr -d ' ' && echo -n "archive: " && git ls-files '.tad/archive/*' \| wc -l \| tr -d ' '` | `evidence: 0` 且 `archive: 0` |
| AC7 | SC3 可追溯性: `maintainer-evidence` 分支持有全部新旧文件（数量 ≥ 4377，包含两个 .log 文件） | post-impl | `[ "$(git -c core.quotePath=false ls-tree -r --name-only maintainer-evidence .tad/evidence .tad/archive \| wc -l \| tr -d ' ')" -ge 4377 ] && git cat-file -e maintainer-evidence:.tad/evidence/yolo/local-wiki-browser-ingest/external/rollback-replay.log && echo "ORPHAN_SYNC_PASS"` | `ORPHAN_SYNC_PASS` |
| AC8 | SC3 辅助度量: `git archive` tarball 相对审计基线 31.6MB 降幅 ≥ 70%（体积 ≤ 8.9MB，实测约 8.71MB） | post-impl | `tar_size=$(git archive --format=tar HEAD \| gzip -9 \| wc -c) && echo "tarball: $tar_size" && [ "$tar_size" -lt 8900000 ] && [ "$tar_size" -le 9497775 ] && echo "SIZE_PASS"` | `SIZE_PASS` |
| AC9 | 磁盘物理文件零损失：本地工作区 `.tad/evidence` 与 `.tad/archive` 目录及 134 个文件依然存在 | post-impl | `[ -d .tad/evidence ] && [ -d .tad/archive ] && [ "$(find .tad/evidence .tad/archive -type f \| wc -l \| tr -d ' ')" -ge 134 ] && echo "PHYSICAL_FILES_PRESERVED"` | `PHYSICAL_FILES_PRESERVED` |
| AC10 | 严格无 push：本地提交完备，`origin/maintainer-evidence` 与 `origin/main` 保持原状未推送 | post-impl | `[ "$(git rev-parse origin/maintainer-evidence)" = "b695660661fd8ee210061cfd0de04b77cf61c020" ] && [ "$(git rev-parse maintainer-evidence)" != "b695660661fd8ee210061cfd0de04b77cf61c020" ] && echo "NO_PUSH_PASS"` | `NO_PUSH_PASS` |

---

## 5. Expert Review Status (Alex 必填)

### Gate 2 Review Audit Trail

| Reviewer | Initial Verdict | P0/P1 Issues | Resolution | Final Verdict |
|----------|-----------------|--------------|------------|---------------|
| `code-reviewer` | ❌ FAIL | P0-1 (AC8 阈值无法通过), P0-2 (AC4 正则反斜杠错误), P1-1 (AC1 退出码), P1-2 (AC10 校验力), P1-3 (worktree 脚本健壮性) | 全部修复闭环：AC8 调整为真实达标阈值 `≤ 8.9MB`（降幅 72.5% ≥ 70%）；AC4 修复为标准多 -e；AC1 增加判空保护；AC10 改用 SHA 精确比对；worktree 增加 `--force` 与预检 | ✅ PASS |
| `security-auditor` | ⚠️ CONDITIONAL PASS | Round 1: P0-1 (两个 `.log` 忽略), P0-2 (缺少机械化前置门控), P0-3 (AC8 阈值). Round 2: NEW-P0-1 (scoped commit 是 no-op), NEW-P0-2 (precondition 在 BSD 下 fail-open) | 全部修复闭环：移除 commit 的 pathspec；预检改用原生 `--untracked-files=no`；AC7 收紧为 `-ge 4377`；明确执行次序（§3.1 commit 1 → §3.2 commit 2）；端到端实测完全通过 | ✅ PASS |

---

## 6. Critical Warnings & Non-Goals

1. ⚠️ **严禁 `git clean -x` 或物理删除**: SC3 仅为 `git rm --cached`（从 git 索引移除跟踪），绝非物理删除！
2. ⚠️ **严禁删除 `.tad/evidence` 与 `.tad/archive` 之外的任何文件**: 不得以追求更小 tarball 为由删除 assets、docs 或 research 资源。
3. ⚠️ **强制执行前置门控**: 必须在 `maintainer-evidence` 完成提交且 `comm -23` 验证零缺失后，方可在 `main` 执行 `git rm --cached`。
4. ⚠️ **强制 `git add -f`**: 同步至 orphan 时必须使用 `-f` 保证两个 `.log` 证据文件不被分支 `.gitignore` 静默丢弃。
5. ⚠️ **必须镜像同步**: 所有对 `.claude/skills/alex/` 的修改必须 1:1 同步到 `.agents/skills/alex/`，并通过 `release-verify.sh parity .`。
6. ⚠️ **严禁 Push**: 仅在本地提交，等待用户明确的发布/同步指令。在 orphan 分支推送前，本地保留的物理文件是唯二副本之一，严禁执行 `git clean -xdf`。
