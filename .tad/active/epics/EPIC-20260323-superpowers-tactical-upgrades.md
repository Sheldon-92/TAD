# Epic: Superpowers-Inspired Tactical Upgrades

**Epic ID**: EPIC-20260323-superpowers-tactical-upgrades
**Created**: 2026-03-23
**Owner**: Alex
**Target Version**: v2.5.0

---

## Objective
Absorb key execution innovations from the Superpowers methodology into TAD — session hook optimization, spec compliance separation, anti-rationalization defense, and optional TDD enforcement. Focused on execution quality improvements without changing TAD's core philosophy (Beneficial Friction, Terminal Isolation, Human as Value Guardian).

## Success Criteria
- [ ] All 6 Phases pass Gate 3 + Gate 4
- [ ] TAD v2.5.0 published via *publish
- [ ] No regression in existing TAD workflows (all commands functional)
- [ ] Spec Compliance Reviewer operational in Ralph Loop
- [ ] Anti-rationalization tables integrated into agent command files
- [ ] TDD Skill available as opt-in via config.yaml

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Session Hook Technical Spike | 🔄 Active | HANDOFF-20260323-session-hook-spike.md | Feasibility verdict + architecture decision for context optimization |
| 1 | Spec Compliance Reviewer | ⬚ Planned | — | New Ralph Loop Group 0 subagent, separating "built right thing" from "built it right" |
| 2 | Anti-Rationalization Tables | ⬚ Planned | — | Full coverage tables (12+ entries) embedded in agent commands + standalone guide |
| 3 | TDD Enforcement Skill | ⬚ Planned | — | Opt-in .tad/skills/tdd-enforcement/SKILL.md with config.yaml global toggle |
| 4 | Micro-Tasks + Pressure Testing | ⬚ Planned | — | Optional handoff micro-task section + skill pressure testing methodology |
| 5 | Git Worktree Integration | ⬚ Planned | — | Optional Blake *develop --worktree with branch isolation |

### Phase Dependencies
- Phase 0 → Phase 1: Spike result determines whether context optimization is available for Phase 1+
- Phase 1 is independent of Phase 2-5
- Phase 2 is independent of all others
- Phase 3 is independent of all others
- Phase 4 depends on Phase 1 (micro-tasks benefit from spec compliance) and Phase 3 (pressure testing validates TDD skill)
- Phase 5 is independent

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
(none yet)

### Decisions Made So Far
- Session Hook spike first (was P2, upgraded to Phase 0 based on architectural dependency analysis)
- Anti-rationalization scope: full 12+ entries from research note (not trimmed to top 3)
- TDD opt-in via config.yaml global toggle (not per-handoff or per-session)
- v2.5.0 one-shot release after all phases complete
- Out of scope: Superpowers coexistence integration, multi-platform, distribution/marketing

### Known Issues / Carry-forward
- CLAUDE.md + agent command files are already context-heavy; Phase 0 spike will determine if hook-based optimization is feasible
- Spec Compliance Reviewer implementation (independent subagent vs prompt-layered code-reviewer) deferred to Phase 1 spike

### Next Phase Scope
Phase 0: Validate that Claude Code hooks mechanism can be used to optimize TAD's context footprint. Determine if session hooks can replace full CLAUDE.md loading with on-demand skill loading.

---

## Notes
- Source research: /thoughts/discoveries/2026-03-23-claude-superpowers.md (3-layer analysis)
- ROADMAP.md updated with "Superpowers-Inspired Tactical Upgrades" theme
- This Epic focuses on TAD execution quality, not philosophy change
