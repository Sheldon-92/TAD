# Epic: Superpowers-Inspired Tactical Upgrades

**Epic ID**: EPIC-20260323-superpowers-tactical-upgrades
**Created**: 2026-03-23
**Owner**: Alex
**Target Version**: v2.5.0

---

## Objective
Absorb key execution innovations from the Superpowers methodology into TAD — session hook optimization, spec compliance separation, anti-rationalization defense, and optional TDD enforcement. Focused on execution quality improvements without changing TAD's core philosophy (Beneficial Friction, Terminal Isolation, Human as Value Guardian).

## Success Criteria
- [x] Phase 0 spike complete — baseline measured, pivot decision made
- [ ] Remaining Phases (1-5) pass Gate 3 + Gate 4
- [ ] TAD v2.5.0 published via *publish
- [ ] No regression in existing TAD workflows (all commands functional)
- [ ] Spec Compliance Reviewer operational in Ralph Loop
- [ ] Anti-rationalization tables integrated into agent command files
- [ ] TDD Skill available as opt-in via config.yaml

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 0 | Session Hook Technical Spike | ✅ Done | [Archived](../../archive/handoffs/HANDOFF-20260323-session-hook-spike.md) | Verdict: ⚠️ PARTIAL — hooks work but target <10%, PIVOT to value features |
| 1 | Spec Compliance Reviewer | ✅ Done | [Archived](../../archive/handoffs/HANDOFF-20260323-spec-compliance-reviewer.md) | Group 0 added: spec-compliance → code-reviewer → parallel experts |
| 2 | Anti-Rationalization Tables | ✅ Done | [Archived](../../archive/handoffs/HANDOFF-20260323-anti-rationalization-tables.md) | 12 entries in guide + 8 inline embeds across 3 files |
| 3 | TDD Enforcement Skill | ✅ Done | [Archived](../../archive/handoffs/HANDOFF-20260323-tdd-enforcement-skill.md) | Opt-in SKILL.md + config toggle + Blake 1_6_tdd_check step |
| 4 | Micro-Tasks + Pressure Testing | ✅ Done | [Archived](../../archive/handoffs/HANDOFF-20260323-microtasks-pressure-testing.md) | §6.1 Micro-Tasks + pressure testing guide (77 lines) |
| 5 | Git Worktree Integration | ✅ Done | [Archived](../../archive/handoffs/HANDOFF-20260323-git-worktree-integration.md) | Optional --worktree flag + 4-option finishing workflow |

### Phase Dependencies
- Phase 0 ✅ → PIVOT: Context optimization unnecessary. Phase 1-5 add to on-demand files, not CLAUDE.md.
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
- Phase 0: Session Hook Spike — Verdict ⚠️ PARTIAL. Hooks work but ~8.5% overhead → pivot to value features.
- Phase 1: Spec Compliance Reviewer — Group 0 added to Ralph Loop Layer 2. 7 files modified, 1 created. 16/16 AC passed.
- Phase 2: Anti-Rationalization Tables — 12 entries in guide + 8 inline embeds. 10/10 AC passed.
- Phase 3: TDD Enforcement Skill — opt-in SKILL.md + config toggle + Blake integration. 9/9 AC passed.
- Phase 4: Micro-Tasks + Pressure Testing — §6.1 template + guide. 9/9 AC passed.
- Phase 5: Git Worktree Integration — optional --worktree + finishing workflow. 10/10 AC passed.

### Decisions Made So Far
- Session Hook spike first (was P2, upgraded to Phase 0 based on architectural dependency analysis)
- **PIVOT (Phase 0 result)**: Context optimization unnecessary — TAD architecture already well-optimized (agent files + config on-demand). Phases 1-5 add to on-demand files, not CLAUDE.md.
- Anti-rationalization scope: full 12+ entries from research note (not trimmed to top 3)
- TDD opt-in via config.yaml global toggle (not per-handoff or per-session)
- v2.5.0 one-shot release after all phases complete
- Out of scope: Superpowers coexistence integration, multi-platform, distribution/marketing
- Revisit context optimization when project-knowledge grows to 5+ files with content

### Known Issues / Carry-forward
- Spec Compliance Reviewer implementation (independent subagent vs prompt-layered code-reviewer) to be decided in Phase 1
- When project-knowledge files grow to 5+, consider removing @imports and relying on Context Refresh Protocol only

### Next Phase Scope
ALL PHASES COMPLETE. Epic ready for archive + v2.5.0 publish.

---

## Notes
- Source research: /thoughts/discoveries/2026-03-23-claude-superpowers.md (3-layer analysis)
- ROADMAP.md updated with "Superpowers-Inspired Tactical Upgrades" theme
- This Epic focuses on TAD execution quality, not philosophy change
- Phase 0 spike validated "measure before optimizing" principle — added to project-knowledge/architecture.md
