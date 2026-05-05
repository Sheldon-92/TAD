# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-03-25
**Project:** TAD Framework
**Task ID:** TASK-20260325-003
**Handoff Version:** 3.1.0

---

## 🔴 Gate 2: Design Completeness

| 检查项 | 状态 | 说明 |
|--------|------|------|
| Architecture Complete | ✅ | MCP integration + Alex protocol changes defined |
| Components Specified | ✅ | MCP setup + tad-alex.md changes + config |
| Functions Verified | ✅ | Linear MCP Server confirmed available |
| Data Flow Mapped | ✅ | Alex *accept → MCP → Linear API → issue updated |

**Gate 2 结果**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Integrate Linear as a cross-project kanban board for human time/energy management. Use Linear's official MCP Server so Alex can automatically sync task status to Linear during *accept workflow. Set up 4 Linear projects matching active development projects.

### 1.2 Why We're Building It
**业务价值**：Human has 4+ active projects and no cross-project view for time/energy allocation. Linear provides visual kanban + cycles for weekly planning.
**成功的样子**：Human opens Linear, sees all active work blocks across 4 projects, can plan their week using Cycles and Priority.

### 1.3 Intent Statement

**真正要解决的问题**：Human needs a cross-project dashboard to decide "what should I work on today/this week" — TAD's per-project NEXT.md doesn't give this view.

**不是要做的**：
- ❌ 不是替代 NEXT.md（per-project task tracking stays in TAD）
- ❌ 不是跟踪 handoff 细节（Linear issues are feature/work-block level）
- ❌ 不是团队协作工具（single user only）

---

## 📚 Project Knowledge

✅ 已检查，无相关历史记录。这是新的外部工具集成。

---

## 2. Background Context

### 2.1 Linear MCP Server
- **Official**: Linear provides an MCP server at `https://mcp.linear.app/mcp`
- **Install**: `claude mcp add --transport http linear-server https://mcp.linear.app/mcp`
- **Auth**: OAuth 2.1 (one-time browser flow)
- **Capabilities**: Create issues, update status, query projects/cycles — all via MCP tools in Claude Code

### 2.2 Integration Architecture

```
Human decides what to work on
        ↓
    Linear (kanban)  ←──── Alex *accept auto-updates status
        ↓
    TAD (/alex → /blake)
        ↓
    Code committed
        ↓
    Alex *accept → Linear issue marked Done (via MCP)
```

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Install Linear MCP Server in Claude Code settings
- FR2: Create Linear workspace + team + 4 projects (menu-snap, TAD, my-openclaw-agents, Sober Creator)
- FR3: Configure default workflow states: Backlog → Todo → In Progress → Done → Cancelled
- FR4: Add Linear sync step to Alex's `*accept` flow in tad-alex.md
- FR5: Add `linear_integration` section to config.yaml
- FR6: Seed initial issues from each project's NEXT.md (active/pending items only)

### 3.2 Non-Functional Requirements
- NFR1: Linear sync in *accept must be non-blocking (failure doesn't block archiving)
- NFR2: Linear API key stored via MCP OAuth, NOT in config files

---

## 4. Technical Design

### 4.1 Files to Modify/Create

```
4 files to modify + MCP setup:
├── MCP setup (user scope)                    ← `claude mcp add --scope user` (cross-project)
├── .claude/commands/tad-alex.md              ← Add step4b_linear_sync to *accept
├── .tad/config-platform.yaml                 ← Add linear_integration section
├── .tad/config.yaml                          ← Update config-platform.yaml.contains list
└── .tad/templates/handoff-a-to-b.md          ← Add optional linear_issue field to header
```

### 4.2 MCP Server Setup

```bash
# One-time setup (--scope user for cross-project access)
claude mcp add --transport http --scope user linear-server https://mcp.linear.app/mcp

# Then in Claude Code, run /mcp and follow OAuth flow
# This gives Claude Code access to Linear MCP tools
```

### 4.3 Linear Workspace Structure

```
Workspace: Sheldon Dev
└── Team: Dev (or Personal)
    ├── Project: Menu Snap (Menu Tales)
    ├── Project: TAD Framework
    ├── Project: OpenClaw Agents
    └── Project: Sober Creator
```

**Issue granularity**: Each issue = one feature/work block. Examples:
- "Menu Snap: Fix Scan tab not returning to homepage" (from S06)
- "TAD: Clean up stale Claude Desktop references in docs"
- "Menu Snap: S06 pair test fixes (2 P1 + 4 P2)"

**NOT Linear issues**: Individual handoffs, individual bug fixes within a handoff.

### 4.4 config-platform.yaml — linear_integration section

Add to config-platform.yaml (not master config.yaml — follows modular config pattern):

```yaml
# ==================== Linear Integration ====================
linear_integration:
  enabled: true
  description: "Cross-project kanban for human time/energy management"
  mcp_server: "linear-server"
  linking_strategy: "explicit"  # Only sync when handoff has linear_issue field
  sync_points:
    - trigger: "*accept"
      action: "Mark linked Linear issue as Done (if linear_issue field present)"
  project_mapping:
    menu-snap: "Menu Snap"
    TAD: "TAD Framework"
    my-openclaw-agents: "OpenClaw Agents"
    sober-creator: "Sober Creator"
  issue_granularity: "feature/work-block (NOT handoff-level)"
```

Also update config.yaml `config-platform.yaml.contains` to include `linear_integration`.

### 4.5 handoff-a-to-b.md — Optional linear_issue field

Add to the handoff header (after **Epic:** line):

```markdown
**Linear:** N/A <!-- Optional: TAD-42 or MENU-15 — links to Linear issue for auto-sync on *accept -->
```

Alex fills this when creating handoffs if the work corresponds to a tracked Linear issue. If not, leave as N/A. This is the ONLY linking mechanism — no auto-search by title.

### 4.6 tad-alex.md — *accept Flow Addition

Add to `accept_command.steps`, after `step4` (NEXT.md update), before `step5` (active count check):

```yaml
step4b_linear_sync:
  action: "Sync completion to Linear (if linked issue exists)"
  details: |
    1. Check config-platform.yaml → linear_integration.enabled
       If false → skip silently
    2. Check if the archived handoff has a `linear_issue:` field in its header
       (e.g., `**Linear:** TAD-42`)
       If not present → skip: "Linear: no linked issue (manual update if needed)"
    3. If present: use Linear MCP tools to update issue status to "Done"
    4. Output: "Linear: {issue_id} → Done" or "Linear: no linked issue"
  blocking: false
  error_handling: |
    - MCP server unreachable / timeout (10s): WARN "Linear sync skipped: MCP timeout", continue
    - OAuth token expired: WARN "Linear auth expired, run /mcp to re-authenticate", continue
    - Issue already Done: skip silently (idempotent)
    - Issue not found by ID: WARN "Linear issue {id} not found", continue
    - Any other error: WARN with error message, continue
    Principle: Linear sync NEVER blocks *accept. All errors are warnings.
```

### 4.6 Initial Issue Seeding

For each of the 4 projects, scan NEXT.md for active/pending items and create Linear issues:

**menu-snap**:
- Read menu-snap/NEXT.md → extract In Progress and pending items
- Also check: .tad/pair-testing/S06 findings (2 P1 + 4 P2)

**TAD**:
- P1 follow-up: Clean stale "Claude Desktop" refs in docs/ files
- Any other pending items in NEXT.md

**my-openclaw-agents** and **Sober Creator**:
- Read their NEXT.md for active items

---

## 6. Implementation Steps

### Phase 1: MCP Setup + Linear Workspace (~15 min)

#### 交付物
- [ ] Linear MCP Server installed in Claude Code
- [ ] OAuth authenticated
- [ ] Linear workspace created with 4 projects

#### 实施步骤
1. Run `claude mcp add --transport http linear-server https://mcp.linear.app/mcp`
2. Human completes OAuth flow in browser
3. Verify MCP connection: use Linear MCP tools to query workspace
4. Create team + 4 projects in Linear (via MCP or web UI)
5. Configure workflow states if needed (default should work)

#### 验证方法
- Linear MCP tools are accessible in Claude Code
- 4 projects visible in Linear

### Phase 2: TAD Config + Protocol Update (~15 min)

#### 交付物
- [ ] config.yaml has `linear_integration` section
- [ ] tad-alex.md has `step4b_linear_sync` in *accept flow

#### 实施步骤
1. Add `linear_integration` section to config.yaml
2. Add `step4b_linear_sync` to tad-alex.md accept_command.steps (after step4, before step5)

#### 验证方法
- `grep "linear_integration" .tad/config.yaml` → present
- `grep "step4b_linear_sync" .claude/commands/tad-alex.md` → present

### Phase 3: Seed Initial Issues (~20 min)

#### 交付物
- [ ] Each project has 2-5 initial issues in Linear from NEXT.md
- [ ] Issues have appropriate priority (Urgent/High/Medium/Low)

#### 实施步骤
1. Read menu-snap/NEXT.md → create issues for active items
2. Read TAD/NEXT.md → create issues for pending items
3. Read my-openclaw-agents and Sober Creator NEXT.md → create issues
4. Assign priorities based on task urgency

#### 验证方法
- Linear shows issues across 4 projects
- Human can see cross-project view in "My Issues"

---

## 8. Testing Requirements

- [ ] Linear MCP tools work (can create an issue, can update status, can query)
- [ ] config.yaml has linear_integration section
- [ ] tad-alex.md has step4b in *accept flow
- [ ] 4 projects exist in Linear with initial issues

---

## 9. Acceptance Criteria

- [ ] AC1: Linear MCP Server installed and authenticated
- [ ] AC2: 4 Linear projects created (menu-snap, TAD, OpenClaw Agents, Sober Creator)
- [ ] AC3: config.yaml has `linear_integration` section with project_mapping
- [ ] AC4: tad-alex.md *accept flow has `step4b_linear_sync` (non-blocking)
- [ ] AC5: Initial issues seeded from NEXT.md (at least 2 per project)
- [ ] AC6: Human can open Linear and see cross-project kanban view
- [ ] AC7: Linear sync failure does NOT block *accept archiving

---

## 10. Important Notes

### 10.1 Critical Warnings
- ⚠️ Linear API key lives in MCP OAuth — NEVER store in config.yaml or .env
- ⚠️ step4b_linear_sync must be `blocking: false` — Linear downtime cannot block TAD workflow
- ⚠️ Issue granularity is feature/work-block — do NOT auto-create issues for every handoff

### 10.2 Design Decisions

| # | Decision | Options | Chosen | Rationale |
|---|----------|---------|--------|-----------|
| 1 | Integration method | CLI tool / GraphQL API / MCP Server | MCP Server | Official, OAuth built-in, native Claude Code support |
| 2 | Sync trigger | Manual / *exit / *accept / Every handoff | *accept only | Natural checkpoint; handoff creation is too early (might not finish) |
| 3 | Issue linking | Explicit ID / Auto-search by title / Hybrid | Explicit ID (linear_issue field) | Reliable, no ambiguity; auto-search by title is fragile (expert review P0) |
| 4 | Failure handling | Block / Warn / Silent | Warn and continue with full error_handling | Linear is nice-to-have, never blocks core TAD workflow |
| 5 | Config location | config.yaml / config-platform.yaml / new module | config-platform.yaml | Follows modular config pattern; platform.yaml already handles MCP tools |

---

## Expert Review Status

| Expert | Assessment | P0 Found | P0 Fixed | Result |
|--------|-----------|----------|----------|--------|
| code-reviewer | CONDITIONAL PASS → PASS | 2 | 2 ✅ | All P0 addressed |
| backend-architect | CONDITIONAL PASS → PASS | 1 | 1 ✅ | All P0 addressed |

**P0 Issues Fixed:**
1. ✅ Issue linking strategy — changed from auto-search-by-title to explicit `linear_issue` field in handoff header
2. ✅ Insertion point — step4b positioned after step4 in *accept flow (consistent with step2b naming pattern)

**P1 Issues Addressed:**
- ✅ MCP scope — specified `--scope user` for cross-project access
- ✅ Config location — moved to config-platform.yaml (follows modular pattern)
- ✅ Error handling — added full error_handling block with 5 scenarios
- ✅ Handoff template — added optional `linear_issue` field

**Final Status: Expert Review Complete — Ready for Implementation**

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-03-25
**Version**: 3.1.0
