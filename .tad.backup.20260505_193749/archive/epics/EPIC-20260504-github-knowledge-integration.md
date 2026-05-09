# Epic: GitHub Open-Source Knowledge Integration

**Epic ID**: EPIC-20260504-github-knowledge-integration
**Created**: 2026-05-04
**Owner**: Alex

---

## Objective
将 GitHub 开源知识（awesome-list 注册表 + repo 深度研究）集成为 TAD 的内置能力，使 Alex 在设计时自动引用最佳开源实践，用户只需关注业务价值。

## Success Criteria
- [ ] GitHub Awesome Registry（书单注册表）已建立，包含 30+ 领域的 awesome-list
- [ ] Alex *analyze/*design 时自动从注册表推荐相关 repo
- [ ] 一键从 repo 建立 NotebookLM 深度研究 notebook（子页面 URL 自动展开）
- [ ] 定期自动刷新 awesome-list 注册表

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | GitHub Registry Foundation | ✅ Done | [HANDOFF](../../archive/handoffs/HANDOFF-20260504-github-registry-phase1.md) | YAML 注册表 + `*research-github` 命令 + 50+ awesome-list 数据 |
| 2 | Alex Workflow Integration | ✅ Done | [HANDOFF](../../archive/handoffs/HANDOFF-20260504-github-integration-phase2.md) | *analyze/*design 自动推荐 + 一键建 notebook |
| 3 | Automation Pipeline | ✅ Done | [HANDOFF](../../archive/handoffs/HANDOFF-20260504-github-automation-phase3.md) | 定期刷新 + 新 repo 自动发现 + trending 检测 |

### Phase Dependencies
All phases are sequential: Phase 1 → Phase 2 → Phase 3.
Phase 2 depends on Phase 1 registry existing.
Phase 3 depends on Phase 2 workflow to verify automation targets.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Context for Next Phase

### Research Findings (from *discuss 2026-05-04)
Experiment results validating the technical approach:
- **T1 (GitHub main URL)**: NotebookLM only reads README + page metadata, cannot access sub-directories
- **T4 (GitHub sub-page URLs)**: Full code-level understanding — class names, function signatures, design patterns ✅
- **Code files**: Work with `--type text` flag ✅
- **Source management**: `source stale` + `source refresh` handle updates ✅
- **Awesome-lists collected**: 50+ lists across 20 domains (AI, Web, Architecture, Security, Mobile, IoT, Finance, NLP, CV, etc.)

### Key Design Decisions
- Two-layer architecture: 书单 (awesome-list registry) → 深度研究 (per-topic NotebookLM notebook)
- GitHub sub-page URLs fed directly to NotebookLM (no local download needed)
- Awesome-lists as community-curated "book lists" — leverage existing curation, don't reinvent
- NotebookLM for persistent cross-session knowledge; Claude direct read for in-session analysis

### Risks Identified
- Awesome-list quality varies (some stale/abandoned) — need freshness scoring
- NotebookLM source limits per notebook — need smart source selection
- NotebookLM query latency (23-43s) — not for real-time use, research-phase only

### Phase 1 Completion (2026-05-04)
- Delivered: 24 domains, 50 awesome-lists, 6 commands, entry template
- Blake discoveries: `gh api` snake_case vs `gh search` camelCase; `git/trees?recursive=1` for file enumeration
- Carry-forward: entry count at 50 floor; `auto_query_keywords` deferred to Phase 2

### Next Phase Scope
Phase 2: Alex *analyze/*design auto-recommends repos from registry. When user describes a task, Alex matches domain → queries registry → suggests top repos → one-click creates notebook.

---

## Notes
- Inspired by user's observation: "GitHub has the world's richest open-source resources, but finding relevant repos during projects is hard"
- Core principle: user only cares about business value, TAD handles technical knowledge acquisition
- NotebookLM integration (v2.9.1) provides the "deep understanding" layer; this Epic adds the "discovery" layer
