# Project Context - TAD Framework

## Current State
- **Version**: 2.3.0 (experimental Agent Teams + Cognitive Firewall)
- **Last Updated**: 2026-02-08
- **Framework**: TAD v2.2.1 + Knowledge Auto-loading + Agent Teams + Cognitive Firewall + Playground v2

## Active Work
(none — Playground v2 completed, Gate 3 + Gate 4 PASS)

## Recent Decisions
- Design Playground v2: Pivot from curation tokens → full HTML page generation, independent command (2026-02-08)
- Cognitive Firewall: 3-pillar human empowerment system — research-first, decision transparency, fatal operation protection (2026-02-06)
- Knowledge Auto-loading: CLAUDE.md Section 7 with 9 @import statements for project-knowledge (2026-02-06)
- Agent Teams: Experimental parallel review (Alex) and implementation (Blake) with auto-fallback to subagent (2026-02-06)
- Coexistence Strategy: Full + Standard TAD → Agent Team, Light → subagent, min_tasks_for_team 3→2 (2026-02-07)
- CLAUDE.md Router Architecture: 657→109 lines, router vs execution separation (2026-02-01)

## Known Issues
- Playground v1: Archived to .tad/archive/playground/legacy-v1/ — replaced by standalone /playground command
- Agent Teams: Experimental, requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

## Next Direction
- Validate Cognitive Firewall (research_decision_protocol) on next real feature
- Test Agent Teams on next Full or Standard TAD task (now default for both)
- Iterate on Playground based on user feedback (UX backlog: P0-14 style overload, P0-16 escape path timing)
- Run `/playground` end-to-end on a real project to validate workflow
