# Project Context - TAD Framework

## Current State
- **Version**: 2.2.1
- **Last Updated**: 2026-02-01
- **Framework**: TAD v2.2.1 - Epic/Roadmap + Pair Testing + Modular Config + Bidirectional Messages + Adaptive Complexity

## Active Work
(none)

## Recent Decisions
- Epic/Roadmap: Multi-phase task tracking with derived status, sequential constraint, error resilience (2026-02-01)
- Pair Testing Redesign: Human-initiated, Alex-owned (Gate 4 trigger, not Gate 3) (2026-02-01)
- Pair Testing Protocol: Cross-tool E2E testing via TEST_BRIEF.md bridge (v2.2.1)
- Modular Config: config.yaml split into 6 focused modules with per-command binding (v2.2.0)
- Bidirectional Messages: Structured copy-pasteable messages between agents (v2.2.0)

## Known Issues
- tad-maintain Criterion D common-words list diverges from config (P0 tracked)
- tad-maintain SYNC mode lacks target_slug parameter (P0 tracked)

## Next Direction
- Test Epic flow end-to-end on next multi-phase task
- Verify tad-maintain Epic health checks (7 check types)
- Fix tad-maintain P0 issues (common-words, SYNC scoping)
