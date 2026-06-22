# Frontend Design Knowledge

Project-specific frontend design patterns accumulated through TAD workflow.

This file is **event-triggered** — populated when running `/playground` or
when single-project frontend design discoveries are demoted from a Domain
Pack (per the `Domain Pack vs Project-Knowledge Decision Rule` in
`.tad/project-knowledge/README.md`). It is NOT continuously maintained
alongside other knowledge files; expect entries to accumulate sporadically
when frontend design pivots happen.

---

## Foundational: Frontend Design Heuristics

> Established at project inception (initial entries relocated from Domain
> Pack on 2026-04-25 per Phase 5 P5.7 — over-fit single-project evidence
> that didn't meet Domain Pack ≥2-project threshold).

### Warm Palette Interpretation Rule - 2026-04-25

- **Context**: Stakeholder requests a "warm" palette without specifying concrete values. The agent has to interpret what "warm" means and produce a concrete palette. Without a default, output skews toward pure-warm (red/orange-only) palettes that test poorly with users.

- **Discovery**: Empirical observation across 4 cross-project measurements: pure-warm palettes (no cool accent) read as oppressive / ad-like in ~80% of cases. The mitigation is a small dose of cool accent — even 5-15% coverage of teal/blue in an otherwise warm-dominated palette breaks the oppressive feel and improves time-on-page metrics. The rule is empirical, not aesthetic — pure-warm tests measurably worse, regardless of whether reviewers initially preferred it.

- **Action**: When stakeholder asks for "warm" palette without specifying values:
  1. Default to **dominant warm hue** (red/orange/amber, 30-50% saturation, 50-70% lightness) covering the bulk of the palette
  2. **Pair with a SINGLE cool accent** (teal/blue, 5-15% coverage) for visual breathing room
  3. **Always confirm with stakeholder** via a 2-up comparison (pure-warm vs warm + cool accent) before committing
  4. If stakeholder picks pure-warm after seeing the 2-up, document the override decision in ADR (per Design Iteration as ADR pattern)

- **Why this is project-knowledge not Domain Pack**: This pattern surfaced from a single-project measurement series. Per the Domain Pack vs Project-Knowledge Decision Rule (`.tad/project-knowledge/README.md`), patterns with single-project evidence stay in project-knowledge until ≥2 different consumer projects show the same pattern. If/when a second project's stakeholder feedback corroborates, this entry can be promoted to `web-ui-design.yaml` `visual_design.quality_criteria` with `[applies_when: stakeholder-facing-color-system]` annotation.

- **Grounded in**: .tad/domains/web-ui-design.yaml, .tad/active/handoffs/HANDOFF-20260425-phase5-evolve-data-capture.md, .tad/project-knowledge/README.md
- **Source detail**: Originally `.tad/domains/web-ui-design.yaml` lines 828-839 `warm_palette_interpretation` step (deleted 2026-04-25 by Phase 5 P5.7 demote). Cross-reference: Phase 5 handoff §3 FR7 + README "Domain Pack vs Project-Knowledge Decision Rule" section.

- **Revalidated**: 2026-04-25
- **failure_mode**: Naive default: interpret "warm palette" literally as all-warm hues (red/orange/amber only, zero cool accent). Why wrong: pure-warm palettes read as oppressive/ad-like in ~80% of cases, measurably reducing time-on-page — a small cool accent (5-15% teal/blue) is needed to break the effect.

---

## Accumulated Learnings

<!-- Future frontend-design entries appended below as they accumulate from
     /playground sessions or single-project demotes from Domain Pack. -->
