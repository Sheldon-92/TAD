# Project Context - TAD Framework

## Current State
- **Version**: 2.9.0 (Codex CLI Support + Cross-Platform TAD)
- **Last Updated**: 2026-05-02
- **Framework**: TAD v2.9.0 + Self-Evolving + Domain Packs + Codex CLI Adapter + Compact Recovery

## Active Work
- **EPIC: Security Domain Pack Chain** — Phase 0+1 done, evaluating before Phase 2
  - Epic: `.tad/active/epics/EPIC-20260403-security-domain-pack-chain.md`
  - ✅ Phase 0+1 complete; ⏸️ Phase 2-4 paused pending real-project validation

## Recently Completed

- **EPIC: Cross-Model Orchestration Phase 0/0b/1** — ✅ Phase 1 Gate 4 PASS (2026-05-03)
  - Phase 0: Spike A SKIP | Spike B DEFER | Spike C INTEGRATE
  - Phase 0b: NotebookLM INTEGRATE (6 video-exclusive attack techniques)
  - Phase 1: `*research-notebook` SKILL (8 commands) + capabilities.yaml + Alex SKILL integration
  - Phase 2 planned: real-project validation

- **v2.9.0 Release + Sync** — ✅ COMPLETE (2026-05-02)
  - Codex CLI Adapter: launcher scripts, static SKILL files, AGENTS.md native role switching
  - Synced to 12 registered projects
  - Commits: c0ecc9c (release) + 0d5a1a3 (sync)

- **EPIC: Codex CLI Adaptation** — ✅ ALL 3/3 PHASES COMPLETE (2026-05-02)
  - Phase 0: Feasibility spike (5/6 GO) | Phase 1: Build (13/13 AC) | Phase 2: Dogfood (8/8 AC)
  - AGENTS.md: Codex auto-loads on startup, native role switching without launcher scripts
  - Archived: `.tad/archive/epics/EPIC-20260427-codex-cli-adaptation.md`

- **Compact Recovery Protocol** — ✅ COMPLETE (2026-04-28)
  - Two-layer session state persistence: CLAUDE.md §4.5 self-check + session-state.md on-disk
  - Commit 028974c

- **v2.8.4 Bundle** — ✅ COMPLETE (2026-04-27), superseded by v2.9.0
  - Token efficiency (L1 tier + L2 lazy knowledge + L4 *express ≤5 + L6 narrow-scope prompts)
  - Pre-publish cleanup, dangling refs migration, BUSINESS-VALUE-FIRST rule

- **EPIC: TAD Self-Upgrade from Cross-Project Learning** — ✅ ALL 6/6 PHASES (2026-04-27)
  - Archived: `.tad/archive/epics/EPIC-20260424-tad-self-upgrade-from-consumers.md`

## Recent Decisions
- Codex CLI Adaptation: static SKILL files (strip-only from Claude Code source) + AGENTS.md for native role switching + launcher scripts for non-interactive use (2026-05-02)
- Mechanical Enforcement Rejected: single-user CLI context, LLM alignment ≠ tool interception. Soft SKILL reminders kept, hooks archived (2026-04-15)
- Compact Recovery: Two-layer (CLAUDE.md trigger + session-state.md on-disk). Hook writes metadata, SKILL writes semantics (2026-04-28)
- Token Efficiency: L1 tiered Layer 2 (yaml/research → ≥1 reviewer), L2 lazy knowledge load (~30-50K saved), L6 narrow-scope expert prompts (~50% per review) (2026-04-27)
- Git Commit Verification: Two-layer protection — step3c + step0_git_check (2026-03-03)

## Known Issues
- Agent Teams: Experimental, requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
- Security Domain Pack Chain: Phase 2-4 paused — needs real-project security audit to validate value

## Next Direction
- Run real-project security audit to decide Security Domain Pack Phase 2
- Validate Cognitive Firewall (research_decision_protocol) on next real feature
- Test Agent Teams on next Full or Standard TAD task
- Consider Domain Pack taxonomy reorg (IDEA-20260427)
- Explore TAD Universal Method for non-dev use cases (IDEA-20260502)
- Cross-Model Orchestration: design protocol for Codex review + Gemini research in TAD workflow (IDEA-20260503, spike GO)
