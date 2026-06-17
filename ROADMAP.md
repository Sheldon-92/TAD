# Roadmap

> Strategic themes and direction for the project.
> This is an upper-layer aggregation view — see PROJECT_CONTEXT.md for current state,
> NEXT.md for tactical tasks, and .tad/active/epics/ for multi-phase tracking.

---

## Themes

### Codex CLI Adaptation
**Status:** Active
**Description:** Enable TAD to run on Codex CLI as a fallback channel when Claude Code quota is exhausted. Static SKILL files + AGENTS.md native role switching.

| Item | Type | Status | Reference |
|------|------|--------|-----------|
| Feasibility Spike (6-test matrix) | Epic Phase 0 | Complete | [Epic](./.tad/archive/epics/EPIC-20260427-codex-cli-adaptation.md) |
| Build (launchers + static SKILLs) | Epic Phase 1 | Complete | [Epic](./.tad/archive/epics/EPIC-20260427-codex-cli-adaptation.md) |
| Dogfood + AGENTS.md | Epic Phase 2 | Complete | [Epic](./.tad/archive/epics/EPIC-20260427-codex-cli-adaptation.md) |

### Quality System
**Status:** Active
**Description:** Maintain and evolve the multi-layer quality assurance system including Gates, Ralph Loop, Cognitive Firewall, and expert review patterns.

| Item | Type | Status | Reference |
|------|------|--------|-----------|
| Four-Gate quality system (v2.0) | Direction | Stable | [Gate protocol](./.claude/skills/gate/SKILL.md) |
| Ralph Loop two-layer architecture | Direction | Stable | [Blake protocol](./.claude/skills/blake/SKILL.md) |
| Cognitive Firewall (human empowerment) | Direction | Active — needs real-feature validation | [config-cognitive.yaml](./.tad/config-cognitive.yaml) |
| Agent Teams (experimental parallel review) | Direction | Experimental — needs real-task validation | [config-agents.yaml](./.tad/config-agents.yaml) |

### Developer Experience
**Status:** Active
**Description:** Improve the day-to-day experience of using TAD — design exploration, testing workflows, knowledge management, and onboarding.

| Item | Type | Status | Reference |
|------|------|--------|-----------|
| Design Playground v2 (standalone command) | Direction | Stable | [/playground](./.claude/skills/playground/SKILL.md) |
| Multi-Session Pair Testing | Direction | Stable — needs real E2E validation | [Test brief](./.claude/skills/tad-test-brief/SKILL.md) |
| Knowledge Auto-loading (@import) | Direction | Stable | [project-knowledge/](./.tad/project-knowledge/) |
| Iterate on Playground based on user feedback | Idea | Pending | — |

### Dynamic Workflow Integration
**Status:** Active (2026-06-03)
**Description:** Adopt Claude Code dynamic workflow patterns to evolve TAD from static prompt-based orchestration to deterministic JS-based orchestration. Judgment rules stay in SKILL.md, orchestration logic moves to workflow scripts. Validated by 3 experiments (23 agents, ~1.2M tokens) on 2026-06-03.
**Source:** [Thariq article](./.tad/evidence/research/2026-06-03-dynamic-workflows-thariq.md) + [measurement](./.tad/evidence/research/2026-06-03-workflow-pattern-measurement.md)

| Item | Type | Status | Reference |
|------|------|--------|-----------|
| Tournament for *design + pack builds | Direction | Validated — experiment proved ~30% richer output vs single-agent | [Tournament result](./.tad/evidence/research/2026-06-03-tournament-declarative-constraints-result.md) |
| Rule Adherence (per-AC verifier + skeptic) | Direction | Measured — 2 real false-negative incidents found | [Measurement](./.tad/evidence/research/2026-06-03-workflow-pattern-measurement.md) |
| Declarative Constraints schema v0.1 | Deliverable | Schema designed (tournament output), ready for *analyze | [Schema](./.tad/evidence/research/2026-06-03-tournament-declarative-constraints-result.md) |
| Dual-Platform Orchestration Adapter | Direction | Researched — Codex has subagents (2026-03 GA), needs adapter layer | [Idea](./.tad/active/ideas/IDEA-20260603-dual-platform-orchestration-adapter.md) |
| Token Budget observability for YOLO | Direction | Blind spot confirmed — 0 token data in traces | [Measurement](./.tad/evidence/research/2026-06-03-workflow-pattern-measurement.md) |
| Quarantine (reader/actor isolation) | Idea | Documented for future non-dev use, not urgent now | [Measurement](./.tad/evidence/research/2026-06-03-workflow-pattern-measurement.md) |
| Research System Consolidation | Epic | Complete | [Epic](./.tad/active/epics/EPIC-20260616-research-system-consolidation.md) |

---

## Archive

### Alex Flexibility & Learning — Complete (2026-02-16)
All 5 phases complete: Intent Router, *learn, Idea Pool, Roadmap, Layer Integration. [Epic](./.tad/archive/epics/EPIC-20260216-alex-flexibility-and-project-mgmt.md)

### Superpowers-Inspired Tactical Upgrades — Complete (2026-03-23)
All 6 phases: Session Hook Spike (pivot), Spec Compliance, Anti-Rationalization, TDD, Micro-Tasks, Worktree. [Epic](./.tad/archive/epics/EPIC-20260323-superpowers-tactical-upgrades.md)

### Multi-Platform Cleanup — Complete (2026-02-17)
Codex/Gemini removed as full TAD runtimes (~1100 lines), repositioned as specialized tools. Superseded by Codex CLI Adaptation (v2.9.0).
