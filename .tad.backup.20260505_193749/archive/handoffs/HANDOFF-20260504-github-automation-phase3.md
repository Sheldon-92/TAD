---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/research-github", ".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: GitHub Knowledge Integration — Phase 3 (Automation Pipeline)

**From:** Alex | **To:** Blake | **Date:** 2026-05-04
**Task ID:** TASK-20260504-006
**Epic:** EPIC-20260504-github-knowledge-integration.md (Phase 3/3)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | Scheduled routine + SKILL automation commands + notification mechanism |
| Components Specified | ✅ | routine prompt + SKILL additions + REGISTRY scan_log field |
| Functions Verified | ✅ | `gh search repos`, `gh api commits?per_page=1`, `notebooklm source refresh` — all verified in Phase 1 |
| Data Flow Mapped | ✅ | routine → refresh + search → update REGISTRY → Alex reports on next session |

**Gate 2 结果**: ✅ PASS (pending expert review)

---

## 1. Executive Summary

创建 Claude Code scheduled routine，每周自动：
1. 检查已有 awesome-lists 是否有新内容（通过 last commit 比较）
2. 搜索各领域是否出现新的高 star awesome-list
3. 更新 REGISTRY.yaml + 记录发现日志
4. Alex 下次启动时在 STEP 3.8 位置报告新发现

---

## 2. Requirements

**自动化行为 A：Weekly Refresh（已有 awesome-lists 是否更新了）**
- 对 REGISTRY 中每个 awesome-list，用 `gh api repos/{owner}/{repo}/commits?per_page=1` 查 last commit date
- 如果 last commit > last_checked → 标记为 "updated" 写入 **scan-log.yaml**
- ���️ 单写者原则 (BA-P0-1)：routine 只写 scan-log.yaml，REGISTRY.yaml 的 `last_checked` 只在 step3_9 消费 scan-log 时由 Alex 更新

**自动化行为 B：Weekly Discovery（有没有新的 awesome-list）**
- 对 REGISTRY 中每个 domain，执行 `gh search repos "awesome {slug}" --sort stars --limit 3`
- 如果结果中有 repo 不在当前 domain 的 awesome_lists 里 → 标记为 "new_candidate"
- 写入 scan report（不自动添加到 REGISTRY — 等用户确认）

**通知行为 C：Alex SessionStart Report**
- Alex 在 STEP 3.8（Research Landscape Scan）位置
- 读 scan report：如果有 updates 或 new_candidates → 报告给用户
- "📡 GitHub Registry weekly scan (上次: {date}): {N} lists 有更新, {M} 个新发现的 awesome-list"

---

## 3. Technical Design

### 3.1 Scheduled Routine

使用 Claude Code `/schedule` 创建 weekly routine。

**Routine prompt:**
```
Read .tad/github-registry/REGISTRY.yaml.

For each domain in domains:
  For each awesome_list in domain.awesome_lists:
    Run: gh api repos/{awesome_list.repo}/commits?per_page=1 --jq '.[0].commit.committer.date'
    Compare with awesome_list.last_checked.
    If newer: record as "updated" in scan log.
    Update last_checked in REGISTRY.yaml.

  Run: gh search repos "awesome {domain.slug}" --sort stars --limit 3 --json fullName,stargazersCount
  For each result NOT already in domain.awesome_lists:
    If stargazersCount > 500: record as "new_candidate" in scan log.

Write scan results to .tad/github-registry/scan-log.yaml.
```

**Schedule:** Weekly (Sunday night / Monday morning)

### 3.2 Scan Log Format

文件：`.tad/github-registry/scan-log.yaml`

```yaml
last_scan: 2026-05-04
scan_results:
  updates:
    - repo: "punkpeye/awesome-mcp-servers"
      domain: "mcp-servers"
      last_commit: 2026-05-03
      previous_checked: 2026-05-01
  new_candidates:
    - repo: "new-org/awesome-new-thing"
      domain: "ai-agents"
      stars: 2500
      description: "A new curated list of..."
      status: pending  # pending / accepted / rejected
```

### 3.3 Alex SessionStart Integration (CR-P0-1 fix: 独立 STEP 3.9，不嵌套在 3.8 内)

位置：Alex SKILL.md 新增 **STEP 3.9**（在 STEP 3.8 之后、STEP 4 greeting 之前）。
这是一个**独立的顶级 step**，有自己的 suppress_if 和 blocking 属性，不嵌套在 STEP 3.8 的 action 块内。

```yaml
step3_9_github_scan_report:
  trigger: "After STEP 3.8 completes (regardless of STEP 3.8 outcome)"
  action: |
    1. Read .tad/github-registry/scan-log.yaml (if exists)
    2. If last_scan > 7 days ago → skip (routine hasn't run recently)
    3. Count updates + new_candidates with status "pending"
    4. If any pending:
       Output: "📡 GitHub Registry 周报: {N} 个 awesome-list 有更新, {M} 个新发现"
    5. If new_candidates with status "pending" exist:
       AskUserQuestion: "有 {M} 个新发现的 awesome-list。要查看并决定是否加入 Registry 吗？"
       Options: "查看" / "稍后处理"
       → "查看" → display each candidate, user picks accept/reject
       → Accepted → add to REGISTRY.yaml via *research-github add
       → Rejected → set status: "rejected" in scan-log
  blocking: false
```

### 3.4 `*research-github` SKILL 新增命令

在 Phase 1 SKILL 基础上增加：

```
*research-github scan      — 手动触发一次 weekly scan（不等 scheduled routine）
*research-github scan-log  — 显示最近一次 scan 的结果（updates + candidates）
```

---

## 4. Files to Modify / Create

| # | File | Action | Change |
|---|------|--------|--------|
| 1 | `.tad/github-registry/scan-log.yaml` | CREATE | Empty scan log |
| 2 | `.claude/skills/research-github/SKILL.md` | MODIFY | Add `scan` + `scan-log` commands |
| 3 | `.claude/skills/alex/SKILL.md` | MODIFY | Add `step3_8b_github_scan_report` |
| 4 | `.tad/active/epics/EPIC-20260504-github-knowledge-integration.md` | MODIFY | Phase 3 → 🔄 |

**NOTE on scheduled routine:** Blake should document the routine creation steps in `.claude/skills/research-github/SKILL.md` under a new `## Setup: Scheduled Routine` section (BA-P0-2 fix: explicit location). Blake does NOT create the routine itself (requires user `/schedule` interactive). Deliverable = SKILL documentation section + scan-log schema + Alex STEP 3.9 integration.

---

## 5. Acceptance Criteria

- [ ] AC1: `.tad/github-registry/scan-log.yaml` exists with valid schema
- [ ] AC2: `*research-github scan` command documented in SKILL (manual trigger for weekly scan logic)
- [ ] AC3: `*research-github scan-log` command documented (display latest scan results)
- [ ] AC4: `scan` command uses `gh api commits?per_page=1` for freshness check
- [ ] AC5: `scan` command uses `gh search repos` for new list discovery (>500 stars threshold)
- [ ] AC6: New candidates get `status: pending` (not auto-added to REGISTRY)
- [ ] AC7: Alex SKILL has `step3_8b_github_scan_report` in STEP 3.8 area
- [ ] AC8: step3_8b reads scan-log.yaml and reports pending items
- [ ] AC9: Scheduled routine documentation exists (prompt + schedule + setup instructions)
- [ ] AC10: Epic Phase Map updated: Phase 3 → 🔄 Active

---

## 6. Important Notes

- **不自动添加到 Registry** — 新发现的 awesome-list 需要用户确认。防止低质量列表污染书单。
- **Routine 只记录，不执行** — routine 写 scan-log，不修改 notebook、不建新 notebook。动作留给用户 + Alex。
- **Blake 不创建 routine** — scheduled routine 需要用户交互式 `/schedule`。Blake 只写文档 + 支持代码。
- **500 stars 阈值** — 低于 500 的新 list 不报告。避免噪音。

---

## Required Evidence Manifest

```yaml
evidence_manifest:
  expert_reviews:
    - .tad/evidence/reviews/blake/github-automation-phase3/code-reviewer.md
    - .tad/evidence/reviews/blake/github-automation-phase3/backend-architect.md
  gate_verdicts:
    - .tad/evidence/completions/github-automation-phase3/GATE3-REPORT.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260504-github-automation-phase3.md
```
