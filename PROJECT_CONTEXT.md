# Project Context - TAD Framework

## Current State
- **Version**: 2.15.1 (Capability Pack Auto-Awareness)
- **Last Updated**: 2026-05-27
- **Framework**: TAD v2.15.1 + Self-Evolving + Domain Packs + Capability Packs + Codex CLI + NotebookLM Research + Compact Recovery

## Active Work
- **EPIC: Agent Capability Packs** — 6/9 Phases Done
  - 8 packs built; Phase 2-4 remaining (real project validation, cross-agent, template)
- **EPIC: Goal-Driven Research Director** — 3/4 Phases Done
  - Phase 3: Research-Decision Loop (--caller flag)
- **EPIC: Security Domain Pack Chain** — 2/5 Phases (paused)
  - Needs real-project security audit to validate value
- **Domain Pack Freeze + Rebuild** — in progress
  - Rebuild 13 frozen YAML packs as SKILL.md capability packs

## Recently Completed

- **video-creation Pack ViMax Upgrade** (2026-05-27)
  - 4 ViMax patterns + Photo-to-Beat-Sync integration (309 lines, 77% of 400 cap)
  - Pre/post upgrade behavioral comparison: AI correctly classifies montage intent + applies first/last frame decomposition
  - Research notebook `79b4c4a9` (38 sources: 9 TAD pack + 29 ViMax)
  - Commit 0cc4d8b; Gate 4 PASS with 3 gate4_delta (AC grep-count + verification command bugs caught + Layer 2 reviewer naming drift)

- **v2.15.1 — Capability Pack Auto-Awareness** (2026-05-14)
  - *sync auto-installs 8 packs to 14 downstream projects
  - Alex step4_5 pack scan across all 6 modes
  - Blake 1_5a auto-detection in *develop

- **v2.15.0 — *dream Knowledge Consolidation** (2026-05-14)
  - architecture.md: 1125→262 lines (76% reduction)
  - dream-validator.sh, candidate-only model, --promote/--rollback

- **v2.14.1 — Research Adversarial Challenge** (2026-05-14)
  - 3 challenge points with Codex+Gemini dual-model review

- **v2.14.0 — YOLO Mode + LSP Code Understanding** (2026-05-14)
  - Auto-conductor for Epic execution; 12-language LSP plugin map

- **8 Capability Packs built** (2026-05-07~08)
  - web-ui-design, product-thinking, web-backend, ai-agent-arch, web-frontend, video-creation, ai-prompt-eng, research-methodology

- **EPIC: Cross-Model Orchestration — ALL 4/4 PHASES** (archived 2026-05-14)

## Recent Decisions
- Capability Pack Reference Files: Patterns borrowed from external repos must be grounded by NotebookLM source verification (38 sources for ViMax) not WebFetch README skimming — README-only analysis missed 3 of 4 key patterns (2026-05-27)
- Pack rule bloat control: 400-line hard cap per new reference file; narrow Context Detection signals (no "motion"/"animation" overlap with existing GSAP rules); negative routing test mandatory (2026-05-27)
- Capability Pack Auto-Awareness: All 8 packs installed to all projects (no smart matching); TAD flow only, not ambient Claude Code; max 2 packs per session (2026-05-14)
- *dream as offline batch consolidation, not runtime memory (Gemini pivot, 2026-05-14)
- Mechanical Enforcement Rejected: soft SKILL reminders over hooks for single-user CLI (2026-04-15)

## Known Issues
- Agent Teams: Experimental, requires CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
- Security Domain Pack Chain: paused — needs real-project validation
- 10 active research notebooks — some may be dormant (run *research-review)

## Next Direction
- Run *sync to install packs across 14 projects, then validate pack awareness in real tasks
- Capability Packs Phase 2: real project validation (menu-snap)
- Run *optimize on menu-snap (14 trace files)
- Run *evolve cross-project (50+ traces)
- Domain Pack Freeze + Rebuild (13 packs → SKILL.md)
