---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex", ".claude/skills/research-github"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff: GitHub Knowledge Integration — Phase 2 (Alex Workflow)

**From:** Alex | **To:** Blake | **Date:** 2026-05-04
**Task ID:** TASK-20260504-005
**Epic:** EPIC-20260504-github-knowledge-integration.md (Phase 2/3)

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | 三个行为变更 + 优先级规则 + 反馈机制，全部明确 |
| Components Specified | ✅ | 修改点在 Alex SKILL 3 处 + research-github SKILL 1 处 |
| Functions Verified | ✅ | 所有 CLI 命令已在 Phase 1 验证 |
| Data Flow Mapped | ✅ | refresh → query → compare → record |

**Gate 2 结果**: ✅ PASS (2 experts, 5 P0 resolved)

---

## 1. Executive Summary

让 Alex 在设计时自动利用 GitHub 开源知识，核心变更三件事：
1. 用 notebook 前先刷新（确保最新）
2. 识别领域 → 提供 GitHub 研究入口
3. 研究结果和 Domain Pack 冲突时，跟研究走，记录矛盾

---

## 2. Background

Phase 1 交付了 GitHub Registry（24 domains, 50 awesome-lists）和 `*research-github` 命令（6 sub-commands）。但这些是**被动工具** — 用户必须手动调用。

Phase 2 让 Alex **主动使用**这些工具：
- *analyze 时自动检查 registry
- 查 notebook 时自动 refresh
- 遇到冲突时自动记录反馈

用户体验变化：从"我要手动调 *research-github"变成"Alex 自己就知道该看什么"。

---

## 3. Requirements

### 三个行为变更

**变更 A：Notebook Auto-Refresh（用之前先刷新）**

当 Alex 要查询一个 Research Notebook（任何场景：*discuss、*analyze、handoff 写作）：
- 先对该 notebook 的所有 web 源执行 `source stale` 检查
- 如果有 stale 源 → 执行 `source refresh`
- 然后再 `ask`

位置：`*research-notebook ask` 命令内部（SKILL.md），在执行 `notebooklm ask` 之前加 refresh 步骤。

**变更 B：GitHub Registry Awareness（*analyze 自动检查）**

当 Alex 进入 *analyze 路径（`adaptive_complexity_protocol` 开始前）：
- 读 `.tad/github-registry/REGISTRY.yaml`
- 从用户描述中提取领域关键词
- 匹配 REGISTRY 中的 domain name/slug
- 如果匹配 → AskUserQuestion: "这个领域有社区精选的 awesome-list。要先看看参考项目吗？"
  - 用户说"看" → 调用 `*research-github explore <domain>`
  - 用户说"不用" → 继续正常流程
- 如果该领域已有 Research Notebook（notebook_id 非 null）→ 自动 refresh + 展示摘要

位置：Alex SKILL.md `adaptive_complexity_protocol` 新增 `step0_github`，在 `step1 Assess` 之前。

**变更 C：Research > Stale Domain Pack 优先级规则 + 矛盾记录**

当 Alex 在 *design 阶段引用 Domain Pack 质量标准时：
- 如果同一个领域有 Research Notebook 且刚 refresh 过
- 且 notebook 的研究发现和 Domain Pack 的某条 quality_criteria 矛盾
- → 跟研究走（最新实践优先）
- → 记录矛盾到 `.tad/github-registry/domain-pack-feedback.yaml`

反馈文件格式：
```yaml
# .tad/github-registry/domain-pack-feedback.yaml
feedback:
  - date: 2026-05-04
    domain_pack: web-backend
    criteria: "API 应使用 REST 设计"
    research_finding: "MCP 领域主流用 JSON-RPC over stdio，不是 REST"
    source_notebook: "mcp-servers-research"
    action: "Domain Pack web-backend 的 api_design criteria 需要加 scope 注释"
```

这个文件在 `*evolve` 或 `*publish` 时被读取，作为 Domain Pack 升级方向的输入。

位置：Alex SKILL.md `design_protocol.step1_5`（Domain Pack Loading）加一段 priority rule。

---

## 4. Technical Design

### 4.1 变更 A 实现位置（CR-P0-2 + BA-P0-3 修复：加上限）

文件：`.claude/skills/research-notebook/SKILL.md`

在 `*research-notebook ask` 命令的执行步骤中，现有 Step 1 是 `notebooklm ask`。改为：

```
Step 0 (NEW): Auto-refresh stale sources (with latency cap)
  Guard: if last_refreshed field in REGISTRY < 24h ago → SKIP entire Step 0
         (last_refreshed is a NEW field, distinct from last_queried)

  → ~/.tad-notebooklm-venv/bin/notebooklm source list --json -n <notebook_id>
  → Filter: only type == "SourceType.WEB_PAGE" sources
  → Cap: check at most 10 sources, refresh at most 5 stale ones
  → Total timeout: 30s — if exceeded, stop refresh, proceed with partial data
  → For each source (up to cap):
      # Note: exit 0 = stale (inverted convention, shell-if-compatible)
      if ~/.tad-notebooklm-venv/bin/notebooklm source stale <source_id> -n <notebook_id>; then
        ~/.tad-notebooklm-venv/bin/notebooklm source refresh <source_id> -n <notebook_id>
      fi
  → On any CLI failure (auth expired, network) → skip silently, proceed to ask
  → After refresh: update REGISTRY.yaml field last_refreshed: <today>
  → Then proceed to ask
```

### 4.2 变更 B 实现位置（CR-P0-1 修复：移到 step2 之后）

文件：`.claude/skills/alex/SKILL.md`

位置：`adaptive_complexity_protocol.execution` 中，**step2（Suggest）之后、step3（Proceed/Socratic）之前**。
命名为 `step2c_github`（用户已确认要走 TAD 流程，不浪费 Skip TAD 的场景）。

```yaml
step2c_github:
  name: "GitHub Registry Check"
  trigger: "User confirmed process depth (step2 done), before Socratic Inquiry starts"
  error_blocking: false   # registry failure does not block
  user_interaction: conditional  # AskUserQuestion only if match found AND no notebook
  action: |
    1. Read .tad/github-registry/REGISTRY.yaml (if not found → skip silently)
    2. Extract keywords from user's task description (LLM semantic match against domain name/slug)
    3. Match against domain names/slugs in REGISTRY

    4. If match found AND domain has notebook_id (notebook exists):
       a. Cross-check: Read .tad/research-notebooks/REGISTRY.yaml (BA-P0-1)
          → Find entry by notebook_id
          → If status == "archived" → skip, clear notebook_id in github-registry
          → If entry not found → skip, clear notebook_id (stale reference)
          → If status == "active" or "dormant" → proceed to refresh
       b. Auto-refresh notebook (变更 A, with caps)
       c. Output: "📦 Found research notebook for '{domain}' ({source_count} sources, refreshed). Key findings available during design."
       d. No AskUserQuestion — passively available for Socratic + design

    5. If match found AND no notebook_id (no notebook yet):
       → AskUserQuestion: "'{domain}' 领域有 {N} 个 awesome-list。要先研究参考项目再开始设计吗？"
         Options: "研究一下 (Recommended)" / "跳过，直接设计"
       → "研究一下" → delegate to *research-github explore <slug> + notebook <slug>
         → After delegation completes: announce "Research complete. 回到你的任务。" (CR-P1-2)
       → "跳过" → continue
    6. If no match → skip silently

    → ALWAYS proceed to step3 (Socratic Inquiry) after this step completes
```

### 4.3 变更 C 实现位置（BA-P0-2 修复：明确冲突定义 + 不可覆盖列表）

文件：`.claude/skills/alex/SKILL.md`

在 `design_protocol.step1_5`（Domain Pack Loading）末尾追加。
**范围声明（CR-P0-3）**：此规则仅在 *design 路径生效。*discuss 中 domain_pack_awareness 是建议性的，不存在"覆盖"语义。

```yaml
research_priority_rule:
  scope: "design_protocol.step1_5 ONLY — does NOT apply to *discuss domain_pack_awareness"
  trigger: "Domain Pack loaded AND same domain has a refreshed Research Notebook"
  
  conflict_definition: |  # BA-P0-2 fix
    "Conflict" means: Research finding EXPLICITLY recommends an approach that
    Domain Pack criteria EXPLICITLY prohibits or contradicts.
    ⚠️ Silence from research is NOT conflict. If research doesn't mention a topic,
    Domain Pack criteria applies by default.

  non_overridable_criteria: |  # BA-P0-2 fix — these can NEVER be overridden
    The following Domain Pack criteria types are NON-OVERRIDABLE regardless of research:
    - Security (auth, encryption, input validation, XSS/SQLi prevention)
    - Data integrity (backup, transaction, consistency)
    - Compliance (privacy, GDPR, licensing)
    - Safety (rate limiting, circuit breakers, fail-safe defaults)
    Even if research shows "nobody does this" — these standards hold.

  action: |
    When citing Domain Pack quality_criteria in design:
    1. Check if there's a refreshed Research Notebook for same domain
    2. If yes AND explicit conflict found (per conflict_definition above):
       a. Check: is the conflicting criterion in non_overridable_criteria?
          → YES: follow Domain Pack, ignore research on this point
          → NO: follow research (latest practice wins)
       b. Append entry to .tad/github-registry/domain-pack-feedback.yaml with:
          date, domain_pack, criteria, research_finding, source_notebook,
          conflict_type: "explicit_recommendation | alternative_approach | deprecated_practice"
       c. Note in handoff §11 Decision Summary: "Research overrides Domain Pack: {details}"
    3. If no conflict: Domain Pack criteria apply normally
```

新文件：`.tad/github-registry/domain-pack-feedback.yaml`

```yaml
# Domain Pack Feedback — collected during design when research contradicts Pack criteria.
# Read by *evolve to determine Domain Pack upgrade direction.
# Format: append-only log. Alex appends, *evolve reads + clears after processing.
version: 1.0.0
feedback: []
```

---

## 5. Files to Modify / Create

| # | File | Action | Change |
|---|------|--------|--------|
| 1 | `.claude/skills/alex/SKILL.md` | MODIFY | Add `step0_github` in adaptive_complexity_protocol |
| 2 | `.claude/skills/alex/SKILL.md` | MODIFY | Add `research_priority_rule` in design_protocol.step1_5 |
| 3 | `.claude/skills/research-notebook/SKILL.md` | MODIFY | Add auto-refresh Step 0 in `ask` command |
| 4 | `.tad/github-registry/domain-pack-feedback.yaml` | CREATE | Empty feedback log |
| 5 | `.tad/active/epics/EPIC-20260504-github-knowledge-integration.md` | MODIFY | Phase 2 → 🔄 Active |

---

## 6. Acceptance Criteria

- [ ] AC1: Alex SKILL has `step0_github` before `adaptive_complexity_protocol.step1`
- [ ] AC2: `step0_github` reads REGISTRY.yaml and matches domain by keyword
- [ ] AC3: When notebook exists for domain → auto-refresh + passive announcement (no AskUserQuestion)
- [ ] AC4: When no notebook exists → AskUserQuestion offering to create one
- [ ] AC5: `*research-notebook ask` SKILL has auto-refresh step before query
- [ ] AC6: Auto-refresh skips if last_queried < 24h (optimization)
- [ ] AC7: `research_priority_rule` exists in design_protocol.step1_5
- [ ] AC8: `.tad/github-registry/domain-pack-feedback.yaml` exists with empty feedback list
- [ ] AC9: Priority rule specifies: follow research on conflict + record to feedback.yaml
- [ ] AC10: Epic Phase Map updated: Phase 2 → 🔄 Active

---

## 7. Important Notes

### Design Decisions
1. **Notebook 存在时不问用户** — 直接 refresh + 被动可用。减少 AskUserQuestion 疲劳。
2. **24h 缓存** — 同一天内多次 ask 不重复 refresh。平衡新鲜度和速度。
3. **Feedback 是 append-only log** — Alex 只写不读。*evolve 读后清空。简单可靠。
4. **blocking: false** — Registry 检查失败不阻塞设计流程。

### Anti-Patterns
- ❌ 不要 refresh 所有 notebook — 只 refresh 当前要用的那个
- ❌ 不要自动修改 Domain Pack — 只记录反馈，留给 *evolve 批量处理
- ❌ 不要在每次 *discuss 都查 registry — 只在 *analyze 路径触发

---

## Required Evidence Manifest

```yaml
evidence_manifest:
  expert_reviews:
    - .tad/evidence/reviews/blake/github-integration-phase2/code-reviewer.md
    - .tad/evidence/reviews/blake/github-integration-phase2/backend-architect.md
  gate_verdicts:
    - .tad/evidence/completions/github-integration-phase2/GATE3-REPORT.md
  completion:
    - .tad/active/handoffs/COMPLETION-20260504-github-integration-phase2.md
```
