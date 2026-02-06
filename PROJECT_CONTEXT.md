# Project Context - TAD Framework

## Current State
- **Version**: 2.3.0 (experimental Agent Teams + Cognitive Firewall)
- **Last Updated**: 2026-02-06
- **Framework**: TAD v2.2.1 + Knowledge Auto-loading + Agent Teams + Cognitive Firewall

## Active Work
(none)

## Recent Decisions
- Cognitive Firewall: 3-pillar human empowerment system — research-first, decision transparency, fatal operation protection (2026-02-06)
- Knowledge Auto-loading: CLAUDE.md Section 7 with 9 @import statements for project-knowledge (2026-02-06)
- Agent Teams: Experimental parallel review (Alex) and implementation (Blake) with auto-fallback to subagent (2026-02-06)
- Coexistence Strategy: Full TAD → Agent Team, Standard/Light → subagent (2026-02-06)
- CLAUDE.md Router Architecture: 657→109 lines, router vs execution separation (2026-02-01)

## Known Issues
- Playground: Running suboptimally, Alex doesn't fully understand user intent — needs iteration
- Agent Teams: Experimental, requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1

## Next Direction
- Validate Cognitive Firewall (research_decision_protocol) on next real feature
- Test Agent Teams on next Full TAD task
- Iterate on Playground based on user feedback
