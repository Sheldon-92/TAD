# Epic: NotebookLM Research Director

**Epic ID**: EPIC-20260504-notebooklm-research-director
**Created**: 2026-05-04
**Owner**: Alex

---

## Objective
Transform Alex into a proactive Research Director that leverages NotebookLM's full CLI capabilities (generate report, add-research, note create, configure --persona, summary --topics, artifact suggestions) as a persistent knowledge asset — not a one-shot Q&A tool. Enable Blake read-only + note access for implementation context.

## Success Criteria
- [ ] Alex proactively identifies research gaps and suggests notebook creation/consolidation when entering a project
- [ ] Single research session produces complete structured reports via `generate report` (not manual Claude-assembled Q&A)
- [ ] Research findings automatically flow back into notebooks via `note create`, creating a knowledge loop
- [ ] Blake can query existing notebooks for implementation context (read-only + note create)
- [ ] Validated end-to-end on 内容副业 project with measurable improvement over current scattered-notebook pattern

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Spike: NotebookLM CLI Capability Validation | ✅ Done | HANDOFF-20260504-notebooklm-spike | 24-row capability matrix, 13 commands tested, key: notes≠knowledge, deep=64 sources+AI report |
| 1 | *research-notebook SKILL v2 (base) | ✅ Done | HANDOFF-20260504-notebooklm-skill-v2 | 14 commands (329→607 lines), C6 knowledge loop GO, setup 0.3.4 fixed |
| 2 | Research Director + Advanced CLI | ✅ Done | HANDOFF-20260504-research-director-phase2 | Alex SKILL +155 lines (Director behavior + *research-review + *status portfolio) + research-notebook +173 lines (19 commands) + *learn quiz |
| 3 | Blake Integration + E2E Validation | ✅ Done | HANDOFF-20260504-phase3-blake-e2e | Blake access (10 allowed/9 forbidden) + E2E 6/6 PASS + cross-project gap analysis (29 vs 1) |

### Phase Dependencies
All phases are sequential. Phase 0 spike results determine which capabilities Phase 1 can include. Phase 2 depends on Phase 1's expanded SKILL. Phase 3 depends on both Phase 1 and Phase 2.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Context for Next Phase

### Completed Work Summary
- Phase 0: Spike validated 13 NotebookLM CLI commands (24-row capability matrix). Key findings: `source add-research --mode deep` = 64 sources + AI synthesis report (killer feature); notes do NOT participate in ask context (knowledge loop NEGATIVE); notebooklm-py 0.1.1 deprecated → 0.3.4 required; `artifact get` returns metadata only but `download report` works (2s markdown).
- Phase 1: SKILL expanded 329→607 lines, 14 commands. 6 new: research, report, guide, configure, topics, ingest. Curate enhanced with source stale. C6 knowledge loop CONFIRMED GO (source add local .md → queryable in ~30s). Setup script fixed 0.1.1→0.3.4. All 12 ACs PASS.

### Decisions Made So Far
- Alex Research Director: proactive suggestions with user confirmation (not fully autonomous)
- Notebook management: suggest consolidation + user confirms (not auto-merge)
- Blake access: read-only queries + can add notes (write findings back)
- Technical risk: Phase 0 spike first to validate CLI capabilities before designing SKILL
- Phase 2 scope expanded (2026-05-04): full CLI research found 15+ additional capabilities (fulltext, --source targeting, --save-as-note, --retry, language, auth check, quiz/flashcards, etc.) — all folded into Phase 2 alongside Alex behavior design. Reference: .tad/evidence/spikes/SPIKE-20260504-notebooklm-capabilities/FULL-CLI-RESEARCH.md

### Known Issues / Carry-forward
- NotebookLM CLI auth requires periodic storage_state.json refresh (Playwright export)
- CLI latency 23-43s per query — research-only, not real-time
- All CLI invocations must use absolute path ~/.tad-notebooklm-venv/bin/notebooklm

### Next Phase Scope
Phase 2: Two tracks in one phase — (A) Alex Research Director behavior in Alex SKILL.md (proactive research suggestions, notebook consolidation, knowledge loop management) + (B) Advanced CLI capabilities from full research (fulltext, --source targeting, --save-as-note, --retry, language set, auth check --test, quiz/flashcards, delete-by-title). Reference: .tad/evidence/spikes/SPIKE-20260504-notebooklm-capabilities/FULL-CLI-RESEARCH.md

---

## Notes
- Origin: *discuss session 2026-05-04 — user observed that 内容副业 project created 10 scattered notebooks with shallow usage, identified that current *research-notebook SKILL uses ~20% of NotebookLM CLI capabilities
- Two parallel improvement tracks identified: (1) full CLI capability utilization, (2) Alex Research Director behavior
- User's account has 100+ notebooks total; 内容副业 has ~10 project-relevant ones created 2026-05-03/04
