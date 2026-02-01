# Project Context - TAD Framework

## Current State
- **Version**: 2.2.1
- **Last Updated**: 2026-02-01
- **Framework**: TAD v2.2.1 - Router Architecture + Epic/Roadmap + Pair Testing + Modular Config

## Active Work
(none)

## Recent Decisions
- CLAUDE.md Router Architecture: 657→109 lines, router vs execution separation, enforcement markers preserved (2026-02-01)
- Alex Config Optimization: 5→4 modules (dropped config-execution, kept config-platform for MCP) (2026-02-01)
- Epic/Roadmap: Multi-phase task tracking with derived status, sequential constraint, error resilience (2026-02-01)
- Pair Testing Redesign: Human-initiated, Alex-owned (Gate 4 trigger, not Gate 3) (2026-02-01)

## Known Issues
- tad-maintain Criterion D common-words list diverges from config (P0 tracked)
- tad-maintain SYNC mode lacks target_slug parameter (P0 tracked)
- tad-maintain: 2 explicit prohibition statements need adding (P1, behavior correct)

## Next Direction
- Test Epic flow end-to-end on next multi-phase task
- Fix tad-maintain P0 issues (common-words, SYNC scoping)
- Add explicit prohibition statements to tad-maintain.md (P1 from router refactoring)
