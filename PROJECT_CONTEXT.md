# Project Context - TAD Framework

## Current State
- **Version**: 2.3.0 (Multi-Platform Cleanup + Intent Router + *learn + Idea Pool + Roadmap + *idea promote + *status + Standby + experimental Agent Teams + Cognitive Firewall)
- **Last Updated**: 2026-02-17
- **Framework**: TAD v2.3.0 + Knowledge Auto-loading + Agent Teams + Cognitive Firewall + Playground v2 + Multi-Session Pair Testing + Intent Router + Learning Path + Idea Pool + Roadmap + Layer Integration

## Active Work
- (none — next task TBD)

## Recently Completed
- **Multi-Platform Cleanup** — ✅ COMPLETE (2026-02-17) v2.2.1 → v2.3.0
  - Removed full TAD runtime for Codex/Gemini (~1100 lines, 20 files)
  - Codex/Gemini repositioned as specialized tools via existing Handoff mechanism
  - Archived: .tad/archive/handoffs/HANDOFF-20260217-multi-platform-cleanup.md
- **EPIC: Alex Flexibility + Learning + Project Management** — ✅ ALL 5/5 PHASES COMPLETE (2026-02-16)
  - Archived: .tad/archive/epics/EPIC-20260216-alex-flexibility-and-project-mgmt.md
  - Phase 1: Intent Router | Phase 2: *learn | Phase 3: Idea Pool | Phase 4: Roadmap | Phase 5: *idea promote + *status

## Recent Decisions
- Multi-Platform Cleanup: Removed full TAD runtime for Codex/Gemini, simplified to specialized tool model via existing Handoff mechanism. ~1100 lines removed, 20 files affected, version bumped v2.2.1 → v2.3.0 (2026-02-17)
- Layer Integration Phase 5 DONE (EPIC COMPLETE): *idea promote (upgrade to Epic/Handoff via *analyze), *status panoramic view (4-layer scan), standby + path_transitions updated (2026-02-16)
- Roadmap Phase 4 DONE: ROADMAP.md theme-driven aggregation view, Alex STEP 3.4 startup loading, *discuss exit gains "Update ROADMAP" option with propose→confirm flow (2026-02-16)
- Idea Pool Phase 3 DONE: *idea stores to .tad/active/ideas/ structured files, *idea-list for browsing, forward-only status lifecycle, NEXT.md cross-reference pattern (2026-02-16)
- Learning Opportunity Phase 2 DONE: *learn (Socratic teaching) as 5th Intent Router mode, standby state defined, idle detection added, post-handoff invite removed (user self-initiates) (2026-02-16)
- Intent Router Phase 1 DONE: Alex supports *bug/*discuss/*idea/*analyze, "route before process" pattern, Alex never codes even for bugs (2026-02-16)
- Alex Flexibility Epic: Hybrid intent detection (Option C), local-first project mgmt (no MCP dependency), multi-model cross-review hypothesis rejected in favor of existing gate system (2026-02-16)
- Multi-Session Pair Testing: Singleton → session directories (S01/, S02/) + SESSIONS.yaml manifest + context inheritance (2026-02-09)
- Design Playground v2: Pivot from curation tokens → full HTML page generation, independent command (2026-02-08)
- Cognitive Firewall: 3-pillar human empowerment system — research-first, decision transparency, fatal operation protection (2026-02-06)
- Agent Teams: Experimental parallel review (Alex) and implementation (Blake) with auto-fallback to subagent (2026-02-06)
- Coexistence Strategy: Full + Standard TAD → Agent Team, Light → subagent, min_tasks_for_team 3→2 (2026-02-07)

## Known Issues
- Playground v1: Archived to .tad/archive/playground/legacy-v1/ — replaced by standalone /playground command
- Agent Teams: Experimental, requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

## Next Direction
- Consider renaming config-platform.yaml → config-mcp.yaml (follow-up from multi-platform cleanup)
- Validate multi-session pair testing on next real project E2E test cycle
- Validate Cognitive Firewall (research_decision_protocol) on next real feature
- Test Agent Teams on next Full or Standard TAD task (now default for both)
- Iterate on Playground based on user feedback
- Address 3 P2 suggestions from pair testing review (Section 4b rendering, SESSIONS.yaml schema, session count warning)
