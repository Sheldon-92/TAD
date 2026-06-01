# Phase 3 Grounding — AC CONFLICT (honest_partial, SAFETY)

**Conductor Y2 grounding, 2026-05-31.** P3 hit a structural AC conflict; honest_partial exit per
architecture.md "honest_partial_protocol: Real-Use Validation" + "AC Conflict Matrix" + v2.7 quality-chain lesson.

## Grounded facts (alex/SKILL.md = 6441 lines)
Extractable mode/path/command protocols, with AC3.2 constraint-token counts
(`MUST NOT|VIOLATION|MANDATORY|forbidden_implementations|NOT_via_alex_auto`):

| block | start-end | lines | constraint tokens |
|-------|-----------|-------|-------------------|
| bug_path_protocol | 754-837 | 84 | 0 |
| discuss_path_protocol | 838-975 | 138 | 0 |
| update_roadmap_protocol | 976-1012 | 37 | 0 |
| status_panoramic_protocol | 1013-1085 | 73 | 0 |
| research_plan_protocol | 1086-1809 | 724 | **5** |
| research_review_protocol | 1810-1886 | 77 | 0 |
| idea_path_protocol | 1887-1938 | 52 | 0 |
| idea_list_protocol | 1939-1984 | 46 | 0 |
| idea_promote_protocol | 1985-2035 | 51 | 0 |
| learn_path_protocol | 2036-2132 | 97 | 0 |
| express_path_protocol | 2133-2222 | 90 | **10** |
| experiment_path_protocol | 2223-2335 | 113 | **8** |

Whole-file baseline: **131** constraint tokens.
Constraint-token-FREE extractable total: **655 lines** → 6441→~5786 (~10%).

## The conflict
- AC3.1: always-loaded ≤3,500 lines (need to extract ~2,941).
- AC3.2 (SAFETY): always-loaded constraint-token count UNCHANGED (131).
- Only 655 lines are token-free. The blocks that would get us to ≤3,500 (research_plan 724, express, experiment)
  ALL carry constraint tokens → extracting them drops the always-loaded count → FAILS AC3.2.
- ⇒ AC3.1 and AC3.2 are mutually exclusive by construction. The Epic Detail Block predicted ≤3,500 BEFORE
  grounding the token distribution.

## Options (human decides — NOT silently reframed under full-auto, per the lessons)
- **A. SAFE-only:** extract the 655 token-free lines (bug/discuss/update_roadmap/status_panoramic/research_review/
  idea/idea_list/idea_promote/learn) → 6441→~5786 (~10%). AC3.2 trivially holds (0 tokens moved). Reframe AC3.1
  to the achievable ~5,786. Lowest risk; modest win.
- **B. Reframe AC3.2 to MOVED-not-deleted:** redefine the SAFETY invariant as "total constraint tokens across
  always-loaded SKILL.md + ALL references = unchanged (131), each moved block byte-identical in its reference,
  AND a 1-line inline constraint summary stays at the intent_router for express/experiment/AR-001." Then extract
  research_plan + express + experiment too → ~45% reduction (≤~3,500 feasible). Higher value, but reframes a
  SAFETY AC — needs explicit human sign-off (this is the v2.7 / honest_partial guardrail).
- **C. Defer P3:** keep alex/SKILL.md as-is; judge the lean-down not worth touching the agent's own constraint
  surface. Proceed to P4/P5.

## Recommendation
B is the right end-state (move ≠ delete; the reference loads exactly when that path runs, so constraints stay in
force; AR-001 rationalization is caught by the inline router summary). But because it reframes a SAFETY AC, it
needs your explicit OK. A is a safe partial if you'd rather not touch the constraint-bearing blocks.
