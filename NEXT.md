# Next Steps

## In Progress

- [x] **Capability Pack Auto-Awareness + Sync Install** — Gate 4 PASS + ARCHIVED 2026-05-14
  - *sync step b2 installs all 8 packs to downstream projects
  - Alex step4_5 pack awareness scan across 6 modes
  - Blake 1_5a auto-detection in *develop
  - Commit: baf5618 + e28acbf

- [ ] **Domain Pack Freeze + Rebuild** (TAD Depth-First Phase 2)
  - Remove 13 frozen packs from keywords.yaml (keep 8 active)
  - Archive tools-registry.yaml
  - Rebuild strategy: on-demand SKILL.md, not upfront YAML
  - Key insight: SKILL.md (action-ready) > YAML (informational)

- [ ] **EPIC: Agent Capability Packs** — 6/9 Phases Done
  - Epic: `.tad/active/epics/EPIC-20260507-agent-capability-packs.md`
  - 8 packs built (web-ui-design, product-thinking, web-backend, ai-agent-arch, web-frontend, video-creation, ai-prompt-eng, research-methodology)
  - Phase 2: Real project validation (use packs in menu-snap, measure quality delta)
  - Phase 3: Cross-agent validation (same pack on Codex)
  - Phase 4: Template extraction (CONSUMES/PRODUCES standard)

- [x] **\*dream Knowledge Consolidation** — Gate 4 PASS + PROMOTED 2026-05-14
  - architecture.md: 1125→262 lines (76% reduction), 120→60 entries
  - Safety keywords: 15→15 preserved. Foundational section byte-identical.
  - Snapshot: `.tad/archive/knowledge-snapshots/2026-05-14/`

- [ ] **EPIC: Goal-Driven Research Director** — 3/4 Phases Done
  - Epic: `.tad/active/epics/EPIC-20260504-goal-driven-research.md`
  - Phase 3: Research-Decision Loop (decision traceability + --caller flag)

- [ ] **EPIC: Security Domain Pack Chain** — 2/5 Phases Done (paused)
  - Epic: `.tad/active/epics/EPIC-20260403-security-domain-pack-chain.md`
  - Phase 2-4: Paused — run real-project security audit first to validate value

## Pending

- [ ] Run *optimize on menu-snap (14 trace files) to analyze execution patterns
- [ ] Run *evolve cross-project (5 projects with traces, 50+ trace files total)
- [ ] Test Agent Teams on next Full or Standard TAD task
- [ ] Add Bash command deny patterns to PreToolUse hook (rm -rf, DROP TABLE etc.)

## Ideas (11 active — 8 archived 2026-05-14)

Domain Pack related (input for Freeze + Rebuild):
- [ ] IDEA-20260508-deprecate-domain-pack-yaml: Deprecate YAML format entirely
- [ ] IDEA-20260427-domain-pack-taxonomy-reorg: Horizontal vs vertical reorganization
- [ ] IDEA-20260402-domain-pack-monthly-refresh: Monthly tool freshness refresh
- [ ] IDEA-20260402-self-evolving-domain-pack: Auto-improvement from traces

Framework infrastructure:
- [ ] IDEA-20260401-tad-self-test-agent: Automated TAD behavior validation
- [ ] IDEA-20260402-deerflow-patterns: Borrow patterns from DeerFlow 2.0
- [ ] IDEA-20260403-config-env-override: Environment variable config override
- [ ] IDEA-20260403-hook-timeout-config: Hook timeout control
- [ ] IDEA-20260403-session-health-check: Framework component integrity check

Skill ecosystem:
- [ ] IDEA-20260407-local-skill-capture: Local skill capture mechanism
- [ ] IDEA-20260407-cross-project-skill-harvest: Cross-project skill promotion

## Recently Completed

- [x] **Research Adversarial Challenge Layer** — Gate 4 PASS 2026-05-14, commit 8ea1eed
  - 3 challenge points (0c plan / 4c findings / 5b actions) with Codex+Gemini dual-model review
  - AskUserQuestion gate per challenge, CHALLENGE_INSTRUCTION constant, fail-closed rating extraction
  - Experiment mode: first 3 runs compare both models

### 2026-05-14 cleanup

- [x] **EPIC: Cross-Model Orchestration — ALL 4/4 PHASES COMPLETE** — Archived 2026-05-14 (validated via menu-snap 4 notebooks, 646 sources)
- [x] **v2.14.0 released + synced to 14 projects** — YOLO Mode + LSP Code Understanding (2026-05-14)
- [x] **EPIC: YOLO Mode — ALL 3 PHASES COMPLETE** — Dogfood 39/39 PASS on menu-snap
- [x] **LSP Code Understanding Integration** — 12-language plugin map, auto-provision
- [x] **NotebookLM Research Upgrade (5 tasks)** — add-smart, dynamic research, methodology upgrade
- [x] **8 Capability Packs built** — web-ui-design, product-thinking, web-backend, ai-agent-arch, web-frontend, video-creation, ai-prompt-eng, research-methodology
- [x] **Pack Integration & Migration** — 7 packs to .tad/capability-packs/ + pack-registry.yaml
- [x] **EPIC: Codex CLI Adaptation — ALL 3 PHASES** — launchers + AGENTS.md + dogfood
- [x] **EPIC: GitHub Knowledge Integration — ALL 3 PHASES** — 24 domains, 50 awesome-lists, weekly scan
- [x] **EPIC: NotebookLM Research Director — ALL 4 PHASES** — 19 commands, E2E 6/6 PASS
- [x] **EPIC: TAD Self-Upgrade from Cross-Project Learning — ALL 6 PHASES**
- [x] Earlier: see [docs/HISTORY.md](docs/HISTORY.md)

## Blocked

(none)

---

> 8 Ideas archived 2026-05-14: linear-auto-sync, linear-kanban, domain-pack-framework, tad-universal-method (promoted), cross-model-orchestration (promoted), goal-driven-research-director (promoted), research-methodology-upgrade (done), epic-auto-conductor (done as YOLO)
> Archived history: see [docs/HISTORY.md](docs/HISTORY.md)
