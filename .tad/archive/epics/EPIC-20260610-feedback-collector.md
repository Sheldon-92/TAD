# Epic: TAD Feedback Collector — Structured Human Judgment Interface

**Epic ID**: EPIC-20260610-feedback-collector
**Created**: 2026-06-10
**Owner**: Alex

---

## Objective
Replace Playground with a universal Feedback Collector pattern: when TAD handles non-code deliverables (frontend pages, audio, video, design, brands), Blake generates a self-contained feedback HTML alongside the artifact. Humans give structured feedback via the HTML, export JSON, and Alex uses the JSON to generate targeted modification handoffs. The core principle is "见机行事" — HTML is disposable and zero-cost to regenerate.

## Success Criteria
- [ ] Blake can auto-determine decomposition dimensions and generate usable feedback HTML for non-code artifacts
- [ ] End-to-end loop runs at least once: Blake generates HTML → human fills → JSON → Alex parses → new handoff → Blake modifies
- [ ] Playground marked as deprecated, Feedback Collector is the recommended path for design iteration

---

## Phase Map

| # | Phase | Status | Handoff | Key Deliverable |
|---|-------|--------|---------|-----------------|
| 1 | Core Pattern + Blake Protocol | ✅ Done | HANDOFF-20260610-feedback-collector-phase1.md (archived) | Blake SKILL protocol + feedback HTML guidelines + JSON schema + handoff §8.5 template |
| 2 | Alex Integration + E2E Loop | ✅ Done | HANDOFF-20260610-feedback-collector-phase2.md (archived) | Alex read_feedback_protocol + Gate 4 soft check + E2E dogfood (tad-intro.html) |
| 3 | Overlay Model + Playground Deprecation | ✅ Done | HANDOFF-20260610-feedback-collector-phase3.md (archived) | Overlay for spatial artifacts + /playground deprecated + Gate4 BLOCKING |

### Phase Dependencies
All phases are sequential. Phase 2 requires Phase 1 outputs. Phase 3 requires Phase 2 E2E validation pass.

### Derived Status
Status and progress are computed from the Phase Map:
- **Status**: If all ⬚ → Planning | If any 🔄 or ✅ → In Progress | If all ✅ → Complete
- **Progress**: Count of ✅ Done / Total phases

---

## Phase Details

### Phase 1: Core Pattern + Blake Protocol

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Define the Feedback Collector as a TAD concept and implement Blake's side of the protocol. Blake learns when and how to generate feedback HTML alongside non-code artifacts. This phase also defines the feedback JSON schema and adds §8.5 to the handoff template for Alex to mark feedback-required tasks. NOT in scope: Alex-side JSON parsing, Gate 4 integration, Playground deprecation, or E2E validation.

#### Input
- Colin voice project prototypes (3 working HTML feedback interfaces) as design reference
- Research findings (66 sources in NotebookLM notebook 8c456e11)
- Thariq's "Unreasonable Effectiveness of HTML" as media validation
- Existing Playground SKILL.md for understanding current design iteration workflow

#### Output
- Blake SKILL.md: new `feedback_collector_protocol` section with HTML generation guidelines
- Handoff template: new §8.5 "Feedback Collection" section (feedback_required flag + suggested dimensions)
- Feedback JSON schema v1.0 documented (in handoff template or separate reference)
- Config-workflow.yaml: feedback_collector section (lifecycle thresholds, artifact types)

#### Acceptance Criteria
- [ ] Blake SKILL.md contains `feedback_collector_protocol` with: trigger conditions, HTML generation guidelines (self-contained, export button, card layout, structured + free input), dimension auto-detection heuristics
- [ ] Handoff template has §8.5 with `feedback_required: true|false`, `artifact_type`, `suggested_dimensions[]` fields
- [ ] JSON schema is defined with: version, artifact_type, artifact_path, timestamp, elements[], global_notes, meta.iteration
- [ ] Each element in schema has: id, label, selector, verdict (ok|modify|delete|replace), structured_feedback, free_text, priority
- [ ] Config-workflow.yaml has `feedback_collector` section with artifact_type enum and default dimension heuristics
- [ ] No changes to Alex SKILL.md, Gate SKILL.md, or Playground SKILL.md in this phase

#### Files Likely Affected
- `.claude/skills/blake/SKILL.md` (MODIFY — add feedback_collector_protocol section)
- `.tad/templates/handoff-a-to-b.md` (MODIFY — add §8.5, renumber existing §8.5 to §8.6)
- `.tad/config-workflow.yaml` (MODIFY — add feedback_collector section)
- `.tad/templates/feedback-json-schema.md` (CREATE — JSON schema reference doc)

#### Dependencies
None (can execute independently)

#### Notes
- "见机行事" is the core design principle — Blake should NOT use a rigid HTML template but generate contextually appropriate HTML per task
- Colin project HTMLs serve as EXAMPLES of good feedback interfaces, not as templates to copy
- The dimension auto-detection heuristic is the hardest part — start with task-type-based defaults (frontend → DOM elements, audio → segments, video → timeline slices) and let Blake use LLM judgment for novel types

### Phase 2: Alex Integration + E2E Loop

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Implement Alex's side: protocol for reading feedback JSON, generating targeted modification handoffs, and integrating with Gate 4 acceptance. Validate end-to-end on a real non-code task. NOT in scope: Playground deprecation, universal template library, or multi-iteration automated testing.

#### Input
- Phase 1 outputs (Blake protocol, JSON schema, §8.5 template)
- A real non-code task to dogfood the full loop

#### Output
- Alex SKILL.md: new `read_feedback_protocol` section
- Gate 4 (gate SKILL.md): feedback collection verification step
- E2E validation evidence (at least one full cycle: generate → feedback → modify)
- Session state integration (track feedback iteration count)

#### Acceptance Criteria
- [ ] Alex SKILL.md contains `read_feedback_protocol` with: JSON parsing, verdict grouping (ok/modify/delete/replace), targeted handoff generation
- [ ] Gate 4 checks: if handoff had `feedback_required: true`, verify feedback JSON was collected and processed
- [ ] E2E loop demonstrated: Blake generates artifact + HTML → human fills → JSON exported → Alex reads → new handoff → Blake modifies → result improved
- [ ] Feedback iteration number tracked in session state and completion report
- [ ] Alex's targeted handoff references specific element IDs from feedback JSON (not vague descriptions)

#### Files Likely Affected
- `.claude/skills/alex/SKILL.md` (MODIFY — add read_feedback_protocol, update acceptance_protocol)
- `.claude/skills/gate/SKILL.md` (MODIFY — Gate 4 feedback verification step)
- `.tad/active/session-state.md` (MODIFY at runtime — track feedback iteration)
- `.tad/evidence/` (CREATE — E2E validation evidence)

#### Dependencies
Phase 1

#### Notes
- The E2E dogfood task will be found naturally — user said "等做完再找"
- Alex's handoff should reference element IDs from JSON, not re-describe what the human already pointed at
- Consider: should Alex auto-merge consecutive modify verdicts on adjacent elements into one handoff task?

### Phase 3: Overlay Model + Playground Deprecation

**Status:** ⬚ Planned
**Execution:** pending

#### Scope
Two deliverables: (1) Update Blake's feedback_collector_protocol to differentiate by artifact_type — frontend pages get an OVERLAY model (embed actual page + click-to-annotate layer) instead of the card model that failed in Phase 2 dogfood. (2) Deprecate /playground, update cross-references. NOT in scope: card-to-overlay conversion for all artifact types (audio/video stay card/timeline); building a universal cross-media coordinate protocol.

#### Input
- Phase 2 dogfood evidence: card model fails for spatial artifacts — user couldn't see the actual page, couldn't judge layout/visual relationships
- Phase 2 user feedback (global_notes): wants to click on elements ON the page to annotate, like taking notes
- Existing Playground references (config-workflow.yaml, Alex SKILL.md)

#### Output
- Blake SKILL.md: feedback_collector_protocol updated with artifact_type routing (overlay for frontend_page/design, cards for audio/video/brand)
- Overlay HTML guidelines: embed/iframe the artifact + transparent click-to-annotate layer + same JSON export
- /playground SKILL.md marked deprecated
- All cross-references updated
- E2E re-validation with tad-intro.html using overlay model

#### Acceptance Criteria
- [ ] Blake's feedback_collector_protocol routes by artifact_type: frontend_page/design → overlay model; audio/video/brand → card model
- [ ] Overlay HTML: embeds the actual artifact (iframe or inline), user clicks elements to annotate, exports same JSON schema
- [ ] E2E re-test: tad-intro.html with overlay feedback HTML → user can see full page and annotate specific elements
- [ ] /playground SKILL.md has deprecation notice, redirects to Feedback Collector
- [ ] Alex SKILL.md playground_reference updated to feedback_collector_reference
- [ ] Config-workflow.yaml playground section marked deprecated: true
- [ ] deprecation.yaml has playground → feedback-collector entry
- [ ] No broken /playground references in active SKILL/config files

#### Files Likely Affected
- `.claude/skills/blake/SKILL.md` (MODIFY — update feedback_collector_protocol with overlay routing)
- `.claude/skills/playground/SKILL.md` (MODIFY — deprecation notice)
- `.claude/skills/alex/SKILL.md` (MODIFY — update playground_reference)
- `.tad/config-workflow.yaml` (MODIFY — mark playground deprecated, add overlay guidelines)
- `.tad/deprecation.yaml` (MODIFY — add entry)

#### Dependencies
Phase 2 (dogfood discovery is the design input)

#### Notes
- The overlay model for frontend pages: generate a feedback HTML that iframes the actual artifact, overlays a transparent annotation layer. Clicking any element on the page opens a floating annotation panel (verdict + free text). Same JSON export schema — element IDs mapped to CSS selectors.
- Gate4_Feedback_Check should be upgraded from SOFT to BLOCKING in this phase.
- Risk: iframe same-origin restrictions may require the feedback HTML and artifact to be in the same directory. Plan for this.
- `.tad/deprecation.yaml` (MODIFY — add playground deprecation entry)

#### Dependencies
Phase 2 (need E2E validation before deprecating Playground)

#### Notes
- Don't delete Playground files — mark deprecated. Users may still have active playground sessions.
- Dimension heuristics should be learned from Phase 2 dogfood, not designed in advance.

---

## Context for Next Phase
{Alex updates this section after each *accept}

### Completed Work Summary
- Phase 1: Blake SKILL.md gains `feedback_collector_protocol` (~78 lines, body not references/). Handoff template §8.5 added. JSON schema v1.0 (213 lines). Config-workflow.yaml `feedback_collector` section. Commit da9cabb. Gate 4 PASS 11/11 AC.
- Phase 2: Alex SKILL.md gains `read_feedback_protocol` (5-step: load→summarize→group→generate→confirm). acceptance-protocol.md gains step4e_feedback. Gate 4 soft check added. E2E dogfood: tad-intro.html + feedback HTML → JSON → Alex parses → modification notes. Commit 5306964. Gate 4 PASS 11/11 AC. **Critical dogfood discovery: card model fails for spatial artifacts (frontend pages) — overlay model needed.**
- Phase 3: Blake protocol updated with overlay routing (frontend_page/design → inline overlay; audio/video → cards). Overlay HTML inlines artifact body + hover-highlight + click-to-annotate + coverage nudge. /playground deprecated (11 Alex refs updated, config deprecated, deprecation.yaml 2.28.0). Gate4_Feedback_Check: SOFT→BLOCKING. phase1_guard removed. Commit 9446efb. Gate 4 PASS 12/12 AC.

### Decisions Made So Far
- Trigger: only non-code artifacts (not all outputs)
- Feedback flow: human → JSON → Alex → new handoff → Blake (not Blake direct)
- Playground: will be replaced (先并存，验证后废弃)
- Fallback: small adjustments in HTML free text, big issues back to Alex
- Core principle: 见机行事 — HTML is disposable, regenerate as needed
- Thariq's "HTML is the new Markdown" validates the medium; our insight goes deeper (feedback interface, not just output format)

### Known Issues / Carry-forward
- AI auto-decomposition accuracy is the key risk — Phase 1 starts with task-type defaults, LLM judgment for novel types
- Colin project base64-embedded audio made HTML files tens of MB — Phase 1 should address file size (link to files vs embed)

### Next Phase Scope
Phase 1: Core Pattern + Blake Protocol

---

## Notes
- Research: 66 sources in NotebookLM (8c456e11-9ef3-4d28-8b06-6efd2cbf0639)
- Evidence: .tad/evidence/research/structured-feedback-collector/
- Idea: .tad/active/ideas/IDEA-20260610-structured-feedback-collector.md
- Origin: 2026-06-10 Alex *discuss session, inspired by Colin voice project prototypes + friend TAD onboarding pain
