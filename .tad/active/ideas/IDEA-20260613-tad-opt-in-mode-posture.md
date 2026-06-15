# Idea: TAD as Opt-In Mode (CLAUDE.md posture flip)

**ID:** IDEA-20260613-tad-opt-in-mode-posture
**Date:** 2026-06-13
**Status:** captured
**Scope:** medium

---

## Summary & Problem

Today CLAUDE.md frames TAD as the project's "constitution" — every interaction is
nudged toward the heavyweight Alex→Blake→Gate flow via probabilistic auto-routing
("complex feature → 必须用 /alex"). That auto-detection is unreliable and, per earlier
analysis, fails exactly in casual/"just do it" mode while imposing posture overhead
everywhere.

Proposed alternative posture: **TAD becomes a mode you deliberately enter, not an
ambient law.**
- Explicit `/alex` `/blake` `/gate` → strict TAD discipline (deterministic, 100% reliable).
- No invocation → free-form chat is fine; capability packs still auto-load on description
  match (they are standard skills, independent of TAD discipline).
- CLAUDE.md shrinks from "mandatory router" to "opt-in mode + one safety rail".

Capability packs are already fully decoupled (all 22 packs are now `.claude/skills/*/SKILL.md`
since YAML domain packs retired 2026-06-11), so skill auto-loading needs no TAD machinery.

## Open Questions

- **⚠️ User's blocking concern (reason this is PARKED, not pursued):** if the default
  posture is loosened to "very free", then when the user *does* want to strictly follow
  Alex/Blake, the agent may have drifted toward a loose/divergent ("发散") behavior and
  not hold the discipline tightly even after explicit invocation. I.e. loosening the
  ambient default might erode strictness *inside* the explicitly-invoked mode too.
  Need a design that guarantees explicit-invoke strictness is NOT weakened by a loose
  default. Until that's resolved, do not change CLAUDE.md. **先不走。**
- How thick should the one surviving safety rail be? (the "pending handoff bypass" guard)
  - A. Hard block — any implementation in a project with a pending handoff must go through Blake (current; too naggy).
  - B. Scope-matched — only block when the request matches a pending handoff's scope; unrelated ad-hoc work stays free (leaning B).
  - C. No rail — full trust; re-opens the documented handoff-bypass disaster (rejected).
- Does this posture differ by project type? Friend/non-dev projects never have a handoff,
  so they are purely "free + packs". The rail only matters in projects actively running TAD.
- Is the parked concern actually real, or does explicit `/alex` re-loading the full SKILL.md
  (1547 lines) already re-establish strictness regardless of ambient default? (needs testing)

## Notes

- Relates to the "skills-only bundle for friends" direction (Option B from the 2026-06-13
  discuss): ship the ~22 capability packs WITHOUT alex/blake/gate/tad-* and without TAD's
  CLAUDE.md. That sub-idea has no blocking concern and could move independently.
- Surplus-plan 2026-06-13 backlog already carries adjacent ideas: "Unified Agent Detection +
  Invocation Protocol" and "Automated TAD Behavior Validation Agent" — both touch the
  "does the agent reliably honor the intended mode" question.
- Grounded in: 2026-06-13 *discuss session (intent recognition / token-tax measurement /
  pack-as-skills confirmation).
