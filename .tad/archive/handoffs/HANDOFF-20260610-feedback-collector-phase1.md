---
task_type: mixed
e2e_required: no
research_required: no
git_tracked_dirs: []
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-10
**Project:** TAD Framework
**Task ID:** TASK-20260610-001
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260610-feedback-collector.md (Phase 1/3)

---

## Gate 2: Design Completeness

**Execution**: 2026-06-10

### Gate 2 Check Results

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | Feedback Collector pattern fully designed |
| Components Specified | ✅ | 4 files to modify/create, each with clear scope |
| Functions Verified | ✅ | No code functions — SKILL protocol + config + template + schema doc |
| Data Flow Mapped | ✅ | Alex handoff → Blake artifact + HTML → human → JSON → Alex |

**Gate 2 Result**: ✅ PASS

**Alex Confirmation**: I have verified all design elements. Blake can independently complete implementation using this document.

---

## Handoff Checklist (Blake must read)

- [ ] Read all sections
- [ ] Read "Project Knowledge" section for historical lessons
- [ ] Understand the real intent (not just literal requirements)
- [ ] Each deliverable and its evidence requirements are clear
- [ ] Can independently complete implementation using this document

---

## 1. Task Overview

### 1.1 What We're Building
Add the "Feedback Collector" pattern to TAD: when a handoff involves non-code deliverables (frontend pages, audio, video, design, brands), Blake generates a self-contained feedback HTML alongside the artifact. The HTML decomposes the artifact into reviewable atomic elements with structured options + free-form input. On save, it exports a JSON file that Alex can parse for the next iteration.

### 1.2 Why We're Building It
**Business value**: Human judgment is the bottleneck in non-code AI workflows. AI can produce artifacts fast but can't judge quality in creative/design domains. The feedback channel between human judgment and AI execution is currently unstructured (natural language descriptions are ambiguous).
**User benefit**: Users (including non-technical collaborators) can give precise, element-level feedback on AI outputs without needing to describe what they're pointing at.
**Success looks like**: Blake generates a feedback HTML that a human can fill out, export JSON, and the JSON is precise enough for Alex to generate targeted modification instructions.

### 1.3 Intent Statement

**The real problem**: When Blake generates a frontend page or other non-code deliverable, there's no structured way for the user to say "this title is wrong, that button text needs changing, this layout section should move." They have to describe everything in natural language, which is ambiguous and lossy.

**This is NOT**:
- A replacement for Playground in Phase 1 (that's Phase 3)
- A fixed template system (the core principle is "generate on the fly")
- A code review tool (this is for non-code artifacts only)

**Blake please confirm understanding:**
```
Before starting implementation:
1. What does the Feedback Collector do?
2. When does it trigger?
3. What is the core principle ("见机行事")?

Only proceed after Human confirms your understanding is correct.
```

---

## Project Knowledge (Blake must read)

### Step 1: Relevant categories
- [x] architecture - new TAD pattern being introduced
- [x] code-quality - SKILL.md editing conventions

### Step 2: Historical lessons

| File | Relevant entries | Key reminder |
|------|-----------------|--------------|
| patterns/handoff-design.md | 2 | Circular trigger pattern; cognitive firewall embed-into-existing |
| principles.md | 2 | Judgment-Only Skill Files; Execution Discipline Content Must Stay in Body |

**Blake must note these lessons:**

1. **Circular Trigger Pattern** (from patterns/handoff-design.md)
   - Problem: If `load_when` references a concept defined inside the reference itself, the agent never loads it
   - Solution: The feedback_collector_protocol trigger is NON-circular (handoff §8.5 feedback_required flag is set by Alex, Blake knows to check it independently)

2. **Judgment-Only Skill Files** (from principles.md)
   - Problem: v2.7 removed constraint rules alongside mechanical logic, breaking quality chain
   - Solution: Keep the core trigger condition and HTML generation guidelines in Blake's SKILL.md body, not in a reference file

### Blake Confirmation
- [ ] I have read the historical lessons above
- [ ] I understand the circular trigger risk
- [ ] I will keep core protocol in SKILL body

---

## 2. Background Context

### 2.1 Previous Work
- Colin voice project has 3 working HTML feedback prototypes (evaluate_v3.html, bgm/annotate.html, ref-library/annotate.html) — these are design REFERENCES, not templates to copy
- Playground v2 exists as a standalone design exploration tool (/playground) — Feedback Collector will eventually replace it (Phase 3)
- Research: 66 sources in NotebookLM notebook (8c456e11-9ef3-4d28-8b06-6efd2cbf0639)

### 2.2 Current State
- Blake has no protocol for generating feedback interfaces alongside non-code artifacts
- Handoff template has no field for marking feedback-required tasks
- No JSON schema exists for structured feedback

### 2.3 Dependencies
- None — Phase 1 is self-contained

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Blake SKILL.md gains a `feedback_collector_protocol` section that triggers when handoff has `feedback_required: true`
- FR2: Handoff template gains §8.5 "Feedback Collection" with fields: `feedback_required`, `artifact_type`, `suggested_dimensions[]`
- FR3: A feedback JSON schema v1.0 is defined and documented
- FR4: Config-workflow.yaml gains a `feedback_collector` section with artifact type enum and default dimension heuristics

### 3.2 Non-Functional Requirements
- NFR1: The feedback_collector_protocol must be in Blake's SKILL.md body (not a reference file) to avoid circular trigger issues
- NFR2: The protocol must emphasize "generate contextually" not "follow a template" — 见机行事
- NFR3: The JSON schema must be simple enough for Alex to parse without specialized tooling (standard JSON, no custom encoding)

---

## 4. Technical Design

### 4.1 Architecture Overview

The Feedback Collector is a TAD pattern, not a standalone tool. It adds protocol sections to existing SKILL files and templates:

```
Alex handoff §8.5 (feedback_required: true, artifact_type, suggested_dimensions)
    ↓
Blake reads §8.5 → generates artifact → generates feedback HTML
    ↓
Human opens HTML → fills feedback → exports JSON
    ↓
(Phase 2: Alex reads JSON → generates modification handoff)
```

### 4.2 Blake's feedback_collector_protocol

**Location**: Blake SKILL.md body (NOT references/)

**Trigger**: Handoff §8.5 `feedback_required: true`

**Protocol steps**:
1. Complete the main artifact as specified in the handoff
2. Determine reviewable dimensions based on `artifact_type` and `suggested_dimensions` from §8.5
3. If `suggested_dimensions` is empty, auto-detect based on artifact_type:
   - `frontend_page`: text content, images, buttons, sections, layout, colors, typography
   - `audio`: segments (by sentence/natural break), tone, pacing, volume, transitions
   - `video`: timeline slices (per scene/10s), subtitles, effects, transitions, music
   - `design`: components, colors, typography, layout, imagery, spacing
   - `brand`: name, tagline, color palette, typography, voice/tone, logo concepts
   - `generic`: AI determines based on artifact structure
4. Generate a self-contained HTML file in the same directory as the artifact
5. HTML naming: `{artifact_name}-feedback.html`
6. Report in completion: "Feedback HTML generated at {path}. Human should open, review, and export JSON."

**HTML generation guidelines** (judgment, not template):
- Self-contained single file: inline CSS, inline JS, no external dependencies
- Usable on mobile viewports (min-width 320px); all interactive elements should have visible labels
- Card-based layout: one card per reviewable element
- Each card MUST have:
  - Preview of the element (text snippet, image thumbnail, audio player, or description)
  - AI's analysis/description of the element (what it is, why it was generated this way)
  - Structured verdict options: OK / Modify / Delete / Replace (as buttons or radio)
  - Free-text input field for specific instructions
  - Optional: priority selector (high/medium/low)
- Bottom of page: "Export JSON" button that generates and downloads feedback JSON
- Visual state: cards change border/background on feedback (green=OK, yellow=modify, red=delete)
- File size awareness: always link to media files rather than base64-embed (Colin project HTMLs were 10-50MB due to embedded audio)

**JSON export contract** (CRITICAL — ensures HTML output matches schema):
- The Export JSON button's JavaScript MUST produce output conforming exactly to `.tad/templates/feedback-json-schema.md`
- Field names must match verbatim: `verdict`, `selector_type`, `selector_value`, `structured_feedback`, `priority`, `element_type`, `reviewed`
- Each card's form state maps to one `elements[]` entry
- `meta.iteration` should be read from a `data-iteration` attribute on the page root (set by Blake at generation time)
- `elements_total` = total card count; `reviewed` per element = true only if user interacted with that card
- Element IDs should be semantically meaningful and stable across regenerations (e.g., `hero-title`, `nav-btn-about`, `segment-0015-0030`), NOT sequential (`elem-001`). This enables Alex to reference elements by ID across feedback iterations.

### 4.3 Feedback JSON Schema v1.0

```json
{
  "version": "1.0",
  "artifact_type": "frontend_page|audio|video|design|brand|generic",
  "artifact_path": "relative/path/to/artifact",
  "feedback_html_path": "relative/path/to/feedback.html",
  "timestamp": "2026-06-10T14:30:00Z",
  "elements_total": 12,
  "elements": [
    {
      "id": "hero-title",
      "label": "Page title",
      "element_type": "heading",
      "selector_type": "css",
      "selector_value": "h1.hero-title",
      "reviewed": true,
      "verdict": "modify",
      "structured_feedback": {
        "text": "Updated Title Here",
        "style": "make it larger",
        "position": null
      },
      "free_text": "This title doesn't match our brand voice",
      "priority": "high"
    }
  ],
  "global_notes": "Overall the page looks good but needs more warmth in the color palette",
  "meta": {
    "iteration": 1,
    "prev_feedback": null
  }
}
```

**Schema design decisions:**
- `selector_type` enum: `css` (DOM), `time_range` (audio/video), `spatial` (image coords), `semantic` (description-based)
- `element_type`: captures what the element IS (heading, button, audio_segment, color_swatch, etc.) — zero-cost for Blake to set at generation time, essential for Alex to generate correct modification instructions
- `elements_total` + per-element `reviewed`: distinguishes "user reviewed and said OK" from "user skipped this element entirely"
- `structured_feedback` has typed fields (`text`, `style`, `position`) instead of free-form object — gives Alex parseable instructions
- Element IDs are semantically meaningful and stable across regenerations (e.g., `hero-title`, `nav-btn-about`, `segment-0015-0030`) rather than sequential (`elem-001`) — enables Alex to reference elements by ID across feedback iterations

**Schema versioning**: Phase 2 parser must accept v1.0 JSONs as-is. New fields in future versions must be optional (additive-only). Breaking changes require major version bump and feedback HTML regeneration.
```

### 4.4 Handoff Template §8.5

New section between `## 8.4 Friction Preflight` and `### 8.5 🆕 Test Evidence Required`. Use `## 8.5` heading level (matching `## 8.4`). Renumber current `### 8.5` to `### 8.6` (preserve existing heading text including 🆕 emoji).

**Phase 1 guard**: Add a comment in the template: `<!-- Phase 1: feedback_required MUST be false until Alex read_feedback_protocol is implemented (Phase 2). Setting true before Phase 2 creates an unprocessable artifact. -->`

```markdown
## 8.5 Feedback Collection (Non-Code Artifacts)

<!-- Optional: omit this entire section for code-only tasks. -->
<!-- Phase 1: feedback_required MUST be false until Alex read_feedback_protocol
     is implemented (Phase 2). Setting true before Phase 2 creates feedback HTML
     that nobody can process yet. -->

> Fill this section when the task produces non-code artifacts that require human
> judgment for quality assessment. If the task is code-only, write "N/A".

```yaml
feedback_required: true|false
artifact_type: frontend_page|audio|video|design|brand|generic
suggested_dimensions:
  - "text content"
  - "layout"
  - "color palette"
notes: "Any specific feedback focus areas for Blake"
```
```

### 4.5 Config-workflow.yaml Section

```yaml
feedback_collector:
  enabled: true
  version: "1.0"
  description: "Structured human feedback for non-code AI artifacts"

  artifact_types:
    - frontend_page
    - audio
    - video
    - design
    - brand
    - generic

  default_dimensions:
    frontend_page: ["text_content", "images", "buttons", "sections", "layout", "colors", "typography"]
    audio: ["segments", "tone", "pacing", "volume", "transitions"]
    video: ["timeline_slices", "subtitles", "effects", "transitions", "music"]
    design: ["components", "colors", "typography", "layout", "imagery", "spacing"]
    brand: ["name", "tagline", "color_palette", "typography", "voice_tone", "logo"]
    generic: []

  html_guidelines:
    self_contained: true
    max_embedded_media_kb: 500
    link_media_above: true
    naming: "{artifact_name}-feedback.html"

  json_schema_ref: ".tad/templates/feedback-json-schema.md"
```

---

## 5. Mandatory Questions (Evidence Required)

### MQ1: Historical Code Search
**Question**: Is there prior work related to feedback collection in TAD?
- [x] Yes

**Evidence**:
- Playground v2 (`/playground` command) is the current design iteration tool, but it focuses on visual exploration (picking a style direction), not structured element-level feedback
- Colin voice project has 3 working HTML prototypes at `/Users/sheldonzhao/Downloads/Colin声音项目/`:
  - `podcasts/EP04-colin/segments/EP04-segments/evaluate_v3.html` — per-segment OK/Redo
  - `podcasts/bgm/bgm-clips/annotate.html` — multi-select usage tags per clip
  - `voice-clone/colin/ref-library/annotate.html` — reference audio annotation

**Decision**: Create NEW protocol (not reuse Playground). Colin prototypes serve as design reference only.

### MQ2: Function Existence Verification
Not applicable — this task modifies SKILL files and config, not code functions.

### MQ3-MQ5: Not applicable (no data flow / visual hierarchy / state sync for this task type)

### MQ6: Technical Research
**Research conducted**: NotebookLM deep research with 66 sources (notebook 8c456e11)
**Key findings**: No existing tool does cross-media universal feedback. JSON-as-protocol is simpler than any existing approach. See `.tad/evidence/research/structured-feedback-collector/2026-06-10-ask-findings.md`
**Decision**: Design our own schema based on Colin project patterns (card + preview + structured options + free text → JSON)

---

## 6. Implementation Steps

### Phase 1: Blake SKILL Protocol + Config + Templates (estimated 1-2 hours)

#### Deliverables
- [ ] Blake SKILL.md updated with `feedback_collector_protocol` section
- [ ] Handoff template updated with §8.5 Feedback Collection
- [ ] Feedback JSON schema reference doc created
- [ ] Config-workflow.yaml updated with `feedback_collector` section

#### Implementation Steps

1. **Add `feedback_collector_protocol` to Blake SKILL.md body**
   - Location: insert as a new top-level section after `domain_pack_trace_protocol:` (around line 1487) and before `completion_protocol:` (around line 1504). Use the same YAML structure level as `tad_friction_protocol` for consistency.
   - Content: trigger condition, HTML generation guidelines, JSON export contract, dimension auto-detection heuristics (all from §4.2 above)
   - Keep it concise — judgment guidelines not mechanical templates
   - Must be in BODY not references/ (circular trigger risk per project knowledge)

2. **Add §8.5 to handoff template**
   - File: `.tad/templates/handoff-a-to-b.md`
   - Insert between current §8.4 (Friction Preflight) and §8.5 (Test Evidence Required)
   - Renumber current §8.5 to §8.6
   - Content: feedback_required, artifact_type, suggested_dimensions fields (from §4.4)

3. **Create feedback JSON schema reference**
   - File: `.tad/templates/feedback-json-schema.md`
   - Content: full schema with field descriptions and examples (from §4.3)
   - Include both minimal and full examples

4. **Add `feedback_collector` section to config-workflow.yaml**
   - File: `.tad/config-workflow.yaml`
   - Append at end (before any trailing comments)
   - Content: artifact types, default dimensions, HTML guidelines (from §4.5)

#### Verification
- `grep -c 'feedback_collector_protocol' .claude/skills/blake/SKILL.md` should return ≥1
- `grep -c 'feedback_required' .tad/templates/handoff-a-to-b.md` should return ≥1
- `test -f .tad/templates/feedback-json-schema.md` should pass
- `grep -c 'feedback_collector' .tad/config-workflow.yaml` should return ≥1

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/templates/feedback-json-schema.md  # JSON schema reference for feedback exports
```

### 7.2 Files to Modify
```
.claude/skills/blake/SKILL.md           # Add feedback_collector_protocol section
.tad/templates/handoff-a-to-b.md        # Add §8.5 Feedback Collection
.tad/config-workflow.yaml               # Add feedback_collector section
```

### 7.3 Grounded Against
- `.claude/skills/blake/SKILL.md` (read at 2026-06-10, ~2200 lines — protocol sections for Ralph Loop, Layer 1/2, completion report)
- `.tad/templates/handoff-a-to-b.md` (read at 2026-06-10, ~650 lines — current template has §8.4 Friction Preflight + §8.5 Test Evidence)
- `.tad/config-workflow.yaml` (read at 2026-06-10, ~795 lines — last section is research_notebook)
- `.tad/templates/feedback-json-schema.md` (new — will be created)

---

## 8. Testing Requirements

### 8.1 Structural Verification
- Blake SKILL.md: `feedback_collector_protocol` section exists with trigger, guidelines, and auto-detection
- Handoff template: §8.5 exists with all 3 fields (feedback_required, artifact_type, suggested_dimensions)
- JSON schema doc: contains version, artifact_type, elements[], and meta fields
- Config: feedback_collector section has artifact_types list and default_dimensions map

### 8.2 Content Verification
- Protocol in Blake SKILL body (NOT references/)
- Protocol mentions "见机行事" / contextual generation principle
- HTML guidelines include: self-contained, card layout, structured options + free text, export JSON button
- JSON schema includes iteration tracking (meta.iteration, meta.prev_feedback)

### 8.3 Edge Cases
- What if handoff has no §8.5? → Blake proceeds normally without feedback HTML (backward compatible)
- What if artifact_type is "generic"? → Blake uses LLM judgment for dimensions (documented in protocol)

### 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Blake SKILL.md is large (~2200 lines) | Read relevant sections before editing | Read full SKILL.md | Read only the sections around insertion point + search for existing feedback references | Missing protocol = Gate 3 FAIL |

**Status**: No friction-sensitive prerequisites identified beyond standard file access.

---

## 9. Acceptance Criteria

Blake's implementation is complete when:
- [ ] All 4 files modified/created as specified
- [ ] Protocol is in Blake SKILL body (not references/)
- [ ] JSON schema is complete and includes examples
- [ ] Config section has all artifact types and default dimensions
- [ ] Handoff template §8.5 is properly numbered (existing §8.5 renumbered)
- [ ] No existing functionality broken (Gate 3 grep verification)

---

## 9.1 Spec Compliance Checklist — PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | feedback_collector_protocol exists in Blake SKILL body | post-impl-verifiable | `grep -c 'feedback_collector_protocol' .claude/skills/blake/SKILL.md` | ≥1 | (post-impl) |
| AC2 | Protocol is NOT in references/ | post-impl-verifiable | `ls .claude/skills/blake/references/feedback* 2>/dev/null \| wc -l` | 0 | (post-impl) |
| AC3 | Protocol contains HTML generation guidelines | post-impl-verifiable | `grep -cE 'self.contained\|card.based\|export.*JSON\|见机行事' .claude/skills/blake/SKILL.md` | ≥2 | (post-impl) |
| AC4 | Protocol contains dimension auto-detection | post-impl-verifiable | `grep -cE 'artifact_type.*frontend_page\|default_dimensions\|feedback_collector_protocol' .claude/skills/blake/SKILL.md` | ≥2 | (post-impl) |
| AC5 | Handoff template has §8.5 Feedback Collection | post-impl-verifiable | `grep -c 'feedback_required' .tad/templates/handoff-a-to-b.md` | ≥1 | (post-impl) |
| AC6 | Handoff template §8.5 has artifact_type field | post-impl-verifiable | `grep -c 'artifact_type' .tad/templates/handoff-a-to-b.md` | ≥1 | (post-impl) |
| AC7 | JSON schema doc exists | post-impl-verifiable | `test -f .tad/templates/feedback-json-schema.md && echo EXISTS` | EXISTS | (post-impl) |
| AC8 | JSON schema has elements[] with required fields | post-impl-verifiable | `grep -c 'verdict\|selector\|free_text\|structured_feedback' .tad/templates/feedback-json-schema.md` | ≥3 | (post-impl) |
| AC9 | Config has feedback_collector section | post-impl-verifiable | `grep -c 'feedback_collector:' .tad/config-workflow.yaml` | ≥1 | (post-impl) |
| AC10 | Config has default_dimensions map | post-impl-verifiable | `grep -c 'default_dimensions:' .tad/config-workflow.yaml` | ≥1 | (post-impl) |
| AC11 | Old §8.5 renumbered to §8.6 | post-impl-verifiable | `grep -c '8\.6.*Test Evidence' .tad/templates/handoff-a-to-b.md` | ≥1 | (post-impl) |

---

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0: No spec for JSON export button → schema field mapping | §4.2 HTML guidelines — added "JSON export contract" block | Resolved |
| backend-architect | P0: No schema versioning strategy | §4.3 — added "Schema versioning" paragraph; §10.2 — added constraint | Resolved |
| backend-architect | P1: `selector` field overloaded with 3 addressing schemes | §4.3 — split into `selector_type` enum + `selector_value` | Resolved |
| backend-architect | P1: `structured_feedback` is untyped free-form object | §4.3 — typed fields: `text`, `style`, `position` | Resolved |
| backend-architect | P1: No guard preventing feedback_required: true before Phase 2 | §4.4 — added Phase 1 guard comment in template | Resolved |
| backend-architect | P1: No element ID generation strategy | §4.2 JSON export contract — added semantic ID guidance | Resolved |
| backend-architect | P1: Unclear source of truth: SKILL body vs config dimensions | §10.2 — added source-of-truth clarification | Resolved |
| backend-architect | P1: Asymmetric state risk — HTML generated but no consumer | §10.2 — added Blake completion message requirement | Resolved |
| code-reviewer | P0: Heading level ambiguity at §8.5 insertion point | §4.4 — specified `## 8.5` heading level explicitly | Resolved |
| code-reviewer | P0: AC11 grep uses basic grep with `\|` (literal pipe) | §9.1 AC11 — simplified to single pattern, no alternation needed | Resolved |
| code-reviewer | P1: Blake SKILL insertion point vague | §6 Step 1 — specified concrete anchor: after domain_pack_trace_protocol, before completion_protocol | Resolved |
| code-reviewer | P1: AC3 same grep bug (basic grep with `\|`) | §9.1 AC3 — changed to `grep -cE` | Resolved |
| code-reviewer | P1: AC4 false-positive risk from generic terms | §9.1 AC4 — changed to feedback_collector-specific pattern | Resolved |
| code-reviewer | P1: Epic file path mismatch (handoff-tmpl.yaml) | Epic file updated to reference handoff-a-to-b.md | Resolved |

### Experts Selected

1. **backend-architect** — architectural soundness of the JSON schema, trigger mechanism, and cross-phase integration risks
2. **code-reviewer** — implementation correctness: insertion points, AC grep patterns, file numbering, template compatibility

### Overall Assessment (post-integration)

- backend-architect: PASS (2 P0 resolved, 6 P1 resolved, 6 P2 noted — P2s are nice-to-haves)
- code-reviewer: PASS (2 P0 resolved, 3 P1 resolved + 1 P1 Epic fix, 4 P2 noted)

---

## 10. Important Notes

### 10.1 Critical Warnings
- The feedback_collector_protocol MUST be in Blake's SKILL.md body, NOT in references/. Circular trigger risk: if Blake doesn't know the protocol exists, it can never trigger. See principles.md "Execution Discipline Content Must Stay in SKILL Body."
- Do NOT create a rigid HTML template file. The HTML generation is contextual ("见机行事"). The SKILL protocol provides guidelines (self-contained, card layout, export button), not a template to fill.

### 10.2 Known Constraints
- Blake SKILL.md is already ~2000 lines. The protocol section should be concise (~50-80 lines of YAML-style protocol definition).
- This is Phase 1 only — Alex-side JSON reading and Gate 4 integration are Phase 2.
- **Source of truth for dimensions**: The dimension heuristics in SKILL.md body are the runtime source of truth. Config-workflow.yaml `default_dimensions` is the canonical reference that SKILL.md was derived from. If dimensions need updating, update config first, then sync SKILL.md.
- **Asymmetric state after Phase 1**: Blake can generate feedback HTML, but Alex cannot yet consume the JSON. Blake's completion message MUST include: "Note: Alex feedback processing is not yet implemented (Phase 2). Save the exported JSON for when Phase 2 is complete, or describe the feedback verbally to Alex as a stopgap."
- **Schema versioning**: Phase 2 parser must accept v1.0 JSONs as-is. New fields in future versions must be optional (additive-only). Breaking changes require major version bump and feedback HTML regeneration.

### 10.3 Sub-Agent Usage Suggestions
- [ ] **code-reviewer** — after modifying Blake SKILL.md to verify protocol consistency
- [ ] **test-runner** — not applicable (no code tests for SKILL/config changes)

---

## 11. Decision Rationale

### 11.1 Why "generate contextually" instead of fixed HTML template

| Approach | Pros | Cons | Why not chosen |
|----------|------|------|---------------|
| Fixed template (chosen: NO) | Consistent output, easy to implement | Can't adapt to different artifact types; locks into one layout | Violates "见机行事" principle |
| Contextual generation (chosen: YES) | Adapts to any artifact type; HTML is disposable and zero-cost | Requires Blake to understand the guidelines well | Proven by Colin project (3 different HTML designs for 3 different use cases) |

### 11.2 Why body not references/

Protocol trigger depends on Blake knowing to check handoff §8.5. If the protocol is in references/, Blake must actively decide to read it — but without the protocol context, Blake doesn't know §8.5 is a trigger. This is the circular trigger pattern from project knowledge.

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0
