---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: yes
gate4_delta: []
---

# Express Handoff: Release v2.10.0 + Sync

**From:** Alex | **To:** Blake | **Date:** 2026-05-04
**Type:** Express Release (per release-runbook 7-phase protocol)
**Priority:** P0 (release)

---

## Task

Execute full TAD release v2.10.0 following `.claude/skills/release-runbook/SKILL.md` 7-phase protocol. Version bump all 16 strings → CHANGELOG → commit → push → tag → sync to all 12 projects → verify.

## Version Info

- **Current**: 2.9.1
- **New**: 2.10.0
- **Tag line**: "Goal-Driven Research Director + NotebookLM Full Integration"

## CHANGELOG Entry

```markdown
## [2.10.0] - 2026-05-04

### New Features
- **NotebookLM Research Director**: Complete research lifecycle integration (19 commands in *research-notebook SKILL). Includes: source add-research (deep mode: 64 sources + AI synthesis), generate report + download as markdown, knowledge loop (source add local .md → queryable in 30s), fulltext extraction, quiz/flashcards for *learn mode, notebook consolidation, language set, and more.
- **Alex Research Director Behavior**: STEP 3.8 research + objective alignment scan at activation. *research-review command for portfolio management (4-category diagnostic: strengthen/maintain/pivot/close). Proactive notebook consolidation suggestions. Research citations in handoffs.
- **`*research-plan` Command**: Autonomous goal-driven research — reads OBJECTIVES.md, identifies gaps, generates research plan, user confirms, Alex executes via NotebookLM. Updates objective coverage status.
- **OBJECTIVES.md (OKR Format)**: Business objective definition template. Alex reads at startup and checks research coverage against Key Results.
- **Blake NotebookLM Access**: Read-only + controlled ingest channel (10 allowed / 9 forbidden commands with default-deny rule).
- **Cross-Model Invocation Guide**: Best practices for calling Gemini/Codex as sub-agents from Claude Code.

### Bug Fixes
- Fixed setup-notebooklm.sh pinning deprecated notebooklm-py 0.1.1 → now pins 0.3.4
- Fixed NotebookLM CLI auth preflight: uses `auth check --test` instead of file-exists check

### Documentation
- New: `.tad/templates/objectives-template.md`
- New: `.tad/guides/cross-model-invocation.md` (Codex/Gemini sub-agent best practices)
- Updated: `.tad/cross-model/capabilities.yaml` (+89 lines — fulltext, quiz, flashcards, language capabilities)
- 3 new architecture.md knowledge entries (version deprecation, capability matrix, knowledge feedback loop)
```

## Key Instructions

1. **Read release-runbook SKILL.md first** (mandatory per protocol)
2. **Phase 2**: Bump ALL 16 version strings (see runbook §Phase 2 table). Quick grep after to confirm no stale refs.
3. **Phase 3**: Use the CHANGELOG entry above
4. **Phase 4**: Commit → push → annotated tag v2.10.0 → push tag
5. **Phase 5+6**: Sync to all 12 registered projects (per sync-registry.yaml)
6. **Phase 7**: Verify each project (version.txt matches, hook works, no deprecated files)
7. **Codex Adapter Smoke Test**: Run the 5-check script from runbook before sync

## AC

- [ ] All 16 version strings updated to 2.10.0
- [ ] CHANGELOG.md has [2.10.0] entry
- [ ] Git tag v2.10.0 created (annotated) and pushed
- [ ] All 12 projects synced and verified
- [ ] sync-registry.yaml updated with new last_synced_version + date
