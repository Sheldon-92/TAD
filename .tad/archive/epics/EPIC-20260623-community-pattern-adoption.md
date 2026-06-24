# Epic: Community Pattern Adoption — Absorb Proven Agent Orchestration Patterns

**Epic ID**: EPIC-20260623-community-pattern-adoption
**Created**: 2026-06-23
**Owner**: Alex
**Source**: AI Tinkerers #32 research (decision brief: .tad/evidence/research/agent-orchestration-patterns/2026-06-23-decision-brief-community-orchestration.md)

---

## Objective
Absorb three independently-validated agent orchestration patterns from the community (SPEAR, Inhabited-design, Maestro) into TAD, strengthening Gate quality, design precision, and architectural clarity. Each pattern addresses a real gap: Gate checklists lack MECE structure, *design lacks user-anchoring, and the skill-vs-MCP boundary is implicit.

## Success Criteria
- [ ] Gate checklists restructured to be MECE (mutually exclusive, collectively exhaustive) with measurable improvement in fault isolation
- [ ] *design flow includes ICP (Ideal Customer Profile) anchoring step that prevents "generic slop" in design decisions
- [ ] Skill file vs MCP tool boundary formalized as a documented architecture principle with audit of current capability packs

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Socratic Inquiry Redesign (Co-Definition) | ✅ Done | HANDOFF-20260623-socratic-redesign-p1.md | 3-phase co-definition model + ICP anchor + Alex-led risk/AC |
| 2 | MECE Gate Restructure | ✅ Done | HANDOFF-20260623-mece-gate-p2.md | Gate 4: 6→4 MECE items. G1 +edge cases. G2 +Why ME. G3 verified. |
| 3 | Skill-MCP Complementarity Model | ✅ Done | — (Alex direct, no handoff) | Architecture principle + 26-pack audit + 5-rule decision framework |

### Phase Dependencies
P1 → P2 → P3 (sequential). P1 is smallest/fastest, validates the "absorb external pattern" approach. P2 builds on P1's experience. P3 is architecture-level and benefits from P1+P2 having exercised the SKILL.md edit pattern.

### Derived Status
- **Status**: Complete (all ✅)
- **Progress**: 3 / 3

---

## Phase Details

### Phase 1: Socratic Inquiry Redesign (Co-Definition Model)

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Redesign Socratic Inquiry from "interrogation" (Alex asks open questions, user answers) to "co-definition" (Alex does analytical work, user provides direction and validates). Three structural changes: (1) Add ICP anchor question (who is this for?). (2) Shift risk/AC/tech-constraints from user-facing questions to Alex-led analysis that user confirms. (3) Improve problem definition quality by referencing product-thinking /define patterns for collaborative problem framing. NOT in scope: changing Feedback Collector, modifying Blake's protocols, or altering Gate definitions.

#### Input
- Current Socratic Inquiry protocol: .claude/skills/alex/references/socratic-inquiry-protocol.md
- User feedback: 4 pain points (too abstract, task mismatch, missing ICP dimension, wrong Q&A format)
- Inhabited-design ICP pattern from research brief
- product-thinking /define approach for structured problem definition
- Design protocol: .claude/skills/alex/references/design-protocol.md (for ICP downstream integration)

#### Output
- Redesigned socratic-inquiry-protocol.md with 3-phase co-definition model:
  - Phase 1 UNDERSTAND (user leads): ICP + problem co-definition
  - Phase 2 SCOPE (co-creation): Alex proposes scope, user validates
  - Phase 3 VALIDATE (Alex leads): Alex presents risk analysis + draft ACs, user confirms
- Updated design-protocol.md step3 with ICP anchor reference
- Tech constraints removed as user-facing question (Alex handles internally)

#### Acceptance Criteria
- [ ] socratic-inquiry-protocol.md restructured into 3-phase co-definition model (understand → scope → validate)
- [ ] Phase 1 includes ICP question with 4 options (define / TAD-internal-default / infer / skip)
- [ ] Phase 1 problem definition uses collaborative framing, not just open "what problem does this solve?"
- [ ] Phase 3 risk + AC questions are Alex-led (Alex presents analysis, user confirms/supplements) — NOT open questions to user
- [ ] Technical constraints removed as user-facing question — Alex researches internally
- [ ] design-protocol.md step3 references ICP: "Would [ICP] understand/value this?"
- [ ] All question_dimensions use AskUserQuestion with options where applicable (not only open-ended)

#### Files Likely Affected
- .claude/skills/alex/references/socratic-inquiry-protocol.md (MODIFY — full restructure)
- .claude/skills/alex/references/design-protocol.md (MODIFY — step3 ICP reference)
- .claude/skills/alex/SKILL.md (MODIFY — update socratic_inquiry_protocol description if needed)

#### Dependencies
None (can execute independently)

#### Notes
- Core insight: current Socratic asks users things they can't answer (risk, AC, tech constraints). These should be Alex's homework presented for user confirmation.
- ICP for TAD internal: "Solo developer returning after 3+ months with no session context"
- Reference product-thinking /define for problem framing structure (co-creation, not interrogation)
- Ceremony tracking: handoff §11 Decision Summary "ICP influenced?" column — if all "no" after 5 uses, remove
- Risk: redesign must preserve the core Socratic value (surfacing blindspots) while changing the interaction format
- For TAD internal: ICP = "Solo developer returning after 3+ months with no session context"
- Ceremony test: after 5 handoffs, if "ICP influenced?" is always "no" → remove the question
- Risk: minimal — upgrading an existing question, not adding new ceremony

### Phase 2: MECE Gate Restructure

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Audit and restructure Gate 1-4 checklists to be MECE (Mutually Exclusive, Collectively Exhaustive), inspired by SPEAR's rubric-based Assess phase. Each checklist item should be independently scorable with no overlap, and the full set should cover all relevant dimensions. NOT in scope: changing Gate ownership (Alex vs Blake), modifying the 4-gate structure itself, or adding SPEAR's inner loop (TAD already has Ralph Loop).

#### Input
- Current Gate definitions in .claude/skills/gate/SKILL.md and .tad/config-quality.yaml
- SPEAR article's MECE rubric description
- P1 experience with SKILL.md modification pattern

#### Output
- Restructured Gate checklists (each item independently assessable, no overlap)
- MECE validation: documentation showing each item is ME and set is CE
- Updated config-quality.yaml

#### Acceptance Criteria
- [ ] Each Gate's checklist items are demonstrably mutually exclusive (no two items check the same dimension)
- [ ] Each Gate's checklist is collectively exhaustive (a pre/post comparison shows no removed coverage dimension)
- [ ] gate/SKILL.md updated with restructured checklists
- [ ] At least one real Gate execution uses the new structure (dry-run on existing handoff or live)

#### Files Likely Affected
- .claude/skills/gate/SKILL.md (MODIFY)
- .tad/config-quality.yaml (MODIFY)

#### Dependencies
Phase 1 (P1 validates the SKILL.md edit pattern)

#### Notes
- The 4-gate structure already provides SOME MECE at the macro level (each gate checks a different lifecycle phase)
- The question is whether items WITHIN each gate overlap — that's the audit target
- SPEAR uses a single rubric; TAD has 4 rubrics — might be MECE across gates already

### Phase 3: Skill-MCP Complementarity Model

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Formalize the boundary between skill files (judgment: when/why to do X) and MCP tools (capability: how to do X) as a documented architecture principle. Audit current 25 capability packs to classify which rules are judgment (keep in skill) vs tool-wrapping (candidate for MCP). NOT in scope: actually converting any skill to MCP (that's a future decision), building new MCP servers, or changing existing MCP integrations.

#### Input
- Current capability packs in .claude/skills/
- Existing MCP usage (codebase-memory-mcp, claude-in-chrome, NotebookLM CLI)
- Maestro pattern description from research brief
- L1 principle: "Mechanical Enforcement Rejected on Single-User CLI"

#### Output
- New L1 or L2 principle: "Skill = Judgment, MCP = Capability"
- Audit table: each capability pack classified as judgment-only / tool-wrapping / mixed
- Decision framework: when to use skill file vs MCP tool vs both
- Recommendations for any packs that should consider MCP migration (future work)

#### Acceptance Criteria
- [ ] Architecture principle documented in .tad/project-knowledge/principles.md or patterns/
- [ ] Audit table covers all 25 capability packs with judgment/tool/mixed classification
- [ ] Decision framework has ≥3 decision rules with examples
- [ ] Framework explicitly addresses L1 "Mechanical Enforcement Rejected" constraint

#### Files Likely Affected
- .tad/project-knowledge/principles.md or patterns/ (CREATE or MODIFY)
- .tad/evidence/research/agent-orchestration-patterns/ (CREATE — audit results)

#### Dependencies
Phase 2 (P2 exercises the config/SKILL edit pattern at scale)

#### Notes
- This phase is research + documentation, not implementation
- Risk: MCP overhead on single-user CLI may not justify the hot-swap benefit
- Maestro's context is multi-user product (voice UI); TAD is single-user framework — different tradeoffs
- The L1 principle about mechanical enforcement could argue against MCP for enforcement purposes

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
- Phase 1: Socratic Inquiry redesigned from 6-dimension Q&A to 3-phase co-definition (Understand/Scope/Validate). ICP anchor, two-step anti-anchoring risk, vague detection triggers. 6 files changed, commit b5547a8.
- Phase 2: PAUSED — expert review discovered Gate definitions scattered across 8+ files with no SSOT. MECE restructuring blocked until consolidation. Audit saved as evidence. IDEA created for prerequisite.
- Phase 3: Skill-MCP Complementarity Model completed (Alex direct). 26 packs audited (14 judgment / 10 mixed / 2 tool-wrapping). 5-rule decision framework + L2 pattern entry. Verdict: current split correct for single-user CLI.

### Decisions Made So Far
- 2026-06-23: Three ideas from AI Tinkerers #32 research merged into single Epic (user chose)
- 2026-06-23: Phase order: ICP (small/quick win) → MECE (medium) → Skill-MCP (large/research)

### Known Issues / Carry-forward
- NotebookLM API currently broken (RPC errors) — if research needed, use WebSearch fallback
- Source material limited: only SPEAR has public article; Gryter/Inhabited-design/Maestro are meetup-only demos

### Next Phase Scope
P1: ICP-Anchored Design — add ICP definition step to *design protocol

---

## Notes
- Origin: AI Tinkerers Issue #32 (2026-06-22), curated by Joe Heitzeberg
- Research brief: .tad/evidence/research/agent-orchestration-patterns/2026-06-23-decision-brief-community-orchestration.md
- Key finding: community is independently converging on same patterns as TAD (skill files, gate loops, adversarial self-check)
