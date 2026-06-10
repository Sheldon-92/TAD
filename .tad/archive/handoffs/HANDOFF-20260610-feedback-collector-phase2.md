---
task_type: mixed
e2e_required: yes
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
**Task ID:** TASK-20260610-002
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260610-feedback-collector.md (Phase 2/3)

---

## Gate 2: Design Completeness

**Execution**: 2026-06-10

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | read_feedback_protocol + Gate 4 integration + E2E plan |
| Components Specified | ✅ | 3 files to modify, 1 E2E artifact to produce |
| Functions Verified | ✅ | No code functions — SKILL protocol + Gate integration |
| Data Flow Mapped | ✅ | JSON → Alex parse → verdict groups → targeted handoff |

**Gate 2 Result**: ✅ PASS

---

## Handoff Checklist (Blake must read)

- [ ] Read all sections
- [ ] Read "Project Knowledge" section
- [ ] Understand the E2E dogfood plan (§6 Phase 2)
- [ ] Can independently complete implementation using this document

---

## 1. Task Overview

### 1.1 What We're Building
Phase 2 of the Feedback Collector: Alex learns to read feedback JSON files and generate targeted modification handoffs from them. Gate 4 gains a check for feedback collection completeness. Then we dogfood the entire loop end-to-end by building a TAD introduction page.

### 1.2 Why We're Building It
Phase 1 gave Blake the ability to generate feedback HTML, but nobody can consume the resulting JSON yet. Without Phase 2, a user fills out the HTML and exports JSON, then... nothing happens. This phase closes the loop.

### 1.3 Intent Statement

**The real problem**: Phase 1 created an asymmetric system — Blake produces feedback HTML but Alex has no protocol to read the resulting JSON. The human's effort in filling out the HTML is wasted until Alex can parse it.

**This is NOT**:
- Playground deprecation (Phase 3)
- A new UI builder or design tool
- An automated feedback-apply system (Alex still generates a handoff; Blake still executes)

---

## Project Knowledge (Blake must read)

### Relevant lessons

| File | Relevant entries | Key reminder |
|------|-----------------|--------------|
| patterns/handoff-design.md | 1 | Cognitive Firewall: Embed Into Existing Flows |
| principles.md | 1 | Execution Discipline Content Must Stay in SKILL Body |

**Blake must note:**

1. **Embed Into Existing Flows** — The read_feedback_protocol should integrate into Alex's existing acceptance_protocol flow, not create a standalone command. Insert, don't create.

2. **Body not references/** — Same as Phase 1: the read_feedback_protocol trigger depends on Alex knowing to check for feedback JSON. Keep in body.

---

## 2. Background Context

### 2.1 Phase 1 Outputs (available now)
- Blake SKILL.md: `feedback_collector_protocol` at line 1508 (trigger: handoff §8.5 feedback_required: true)
- Handoff template: §8.5 Feedback Collection (feedback_required, artifact_type, suggested_dimensions)
- JSON schema: `.tad/templates/feedback-json-schema.md` (213 lines, v1.0)
- Config: `.tad/config-workflow.yaml` feedback_collector section

### 2.2 Current State
- Blake can generate feedback HTML — but nobody processes the JSON
- Alex's acceptance_protocol (line 1028 in Alex SKILL.md) has no feedback-aware step
- Gate 4 (gate/SKILL.md line 560) has no feedback collection check

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Alex SKILL.md gains `read_feedback_protocol` — reads feedback JSON, groups by verdict, generates targeted handoff
- FR2: Gate 4 gains a conditional check: if handoff had `feedback_required: true`, verify feedback was collected
- FR3: E2E dogfood: generate a TAD introduction HTML page, produce feedback HTML, human fills it, Alex reads JSON, generates modification handoff, Blake modifies

### 3.2 Non-Functional Requirements
- NFR1: read_feedback_protocol in Alex SKILL body (not references/)
- NFR2: Gate 4 check is conditional — only applies when feedback_required was true
- NFR3: E2E evidence must show the full cycle with real human feedback (not synthetic)

---

## 4. Technical Design

### 4.1 Alex's read_feedback_protocol

**Location**: Alex SKILL.md body, near `acceptance_protocol` (around line 1028). Can be a separate top-level section referenced by acceptance_protocol.

**Trigger**: Human tells Alex "I have feedback JSON at {path}" OR Alex detects feedback JSON during *review/*accept

**Protocol steps**:
```yaml
read_feedback_protocol:
  description: "Read feedback JSON exported from a Feedback Collector HTML, generate targeted modification handoff"
  trigger: "Human provides feedback JSON path, or *accept detects feedback_required handoff"

  steps:
    1_load_json:
      action: "Read the JSON file. Validate version field matches 1.x"
      error: "If file missing or invalid JSON → ask human for correct path"

    2_summarize:
      action: |
        Display feedback summary to human:
        - Total elements: {elements_total}
        - Reviewed: {count where reviewed=true}
        - Verdicts: {count per verdict type}
        - High priority items: {list}
        Output: "📋 Feedback summary: {reviewed}/{total} elements reviewed. {modify} to modify, {delete} to delete, {replace} to replace."

    3_group_by_verdict:
      action: |
        Group elements by verdict:
        - ok: skip (no action needed)
        - modify: extract element ID, label, structured_feedback, free_text
        - delete: extract element ID, label, free_text (reason)
        - replace: extract element ID, label, structured_feedback, free_text
        Skip elements where reviewed=false (user didn't interact)

    4_generate_handoff:
      action: |
        Create a targeted modification handoff for Blake:
        - Add `supersedes: HANDOFF-{date}-{slug}.md` to frontmatter
        - Order tasks by priority: high > medium > low > unset
        - For each non-ok element: create a specific modification task with priority tag
        - Distinguish verdicts: modify = adjust in-place; replace = remove and recreate from structured_feedback; delete = remove entirely
        - Use element IDs (not descriptions) so Blake can locate exactly what to change
        - Include iteration number from meta.iteration (increment by 1)
        - Set feedback_required: true again (so Blake generates new feedback HTML after modifications)
        - Set §8.5 artifact_type to match the original
        - ⚠️ Element ID stability: instruct Blake to preserve element IDs from iteration N for elements that still exist. New elements get new IDs. Deleted elements' IDs are retired.
      format: |
        §1.1: "Modification round {N} based on feedback JSON at {path}"
        §6: One task per non-ok element (ordered by priority):
          "[HIGH] Element {id} ({label}): {verdict} — {structured_feedback + free_text}"
        §8.5: feedback_required: true, artifact_type: {same}, iteration: {N+1}
      max_iteration_advisory: |
        When meta.iteration >= 5, Alex should explicitly ask the human:
        "This is feedback round {N}. Continue iterating or accept current state?"
        This is advisory, not blocking — human can always override.

    5_confirm:
      action: "Present handoff draft to human for confirmation before sending to Blake"

  global_notes_handling: |
    If feedback JSON has global_notes (non-empty), include as a top-level
    direction note in the modification handoff §1.3 Intent Statement.
```

### 4.2 Gate 4 Feedback Check

**Location**: Gate SKILL.md, inside the Gate 4 section (after Friction Status Review, around line 607)

**Logic** (conditional — only when feedback_required was true):
```yaml
Gate4_Feedback_Check:
  description: "Verify feedback collection for non-code artifacts"
  trigger: "Handoff §8.5 feedback_required: true"
  skip_if: "§8.5 absent, feedback_required: false, or N/A"

  checks:
    - "Feedback HTML was generated (path exists in completion report)"
    - "If human filled out feedback: JSON was exported and processed by Alex"
    - "If human did NOT fill out feedback: explicit human approval to skip"

  note: |
    This is a SOFT check in Phase 2. It warns but does not block Gate 4.
    Blocking enforcement deferred to Phase 3 after dogfood validates the flow.
```

### 4.3 E2E Dogfood Plan

**Task**: Create a simple TAD framework introduction HTML page

**Flow** (multi-session — respects terminal isolation):

**Session A: Blake (Terminal 2) — implementation + artifact generation**
1. Blake implements protocol changes (Phase 1 of implementation above)
2. Blake creates `tad-intro.html` — clean, modern TAD intro page
3. Blake generates `tad-intro-feedback.html` alongside it (per Phase 1 feedback_collector_protocol)
4. Blake reports: "Artifacts generated. Human should review feedback HTML." → Gate 3

**Session B: Human (browser)**
5. Human opens `tad-intro-feedback.html` in browser
6. Human reviews elements, fills structured feedback, exports JSON
7. Human saves JSON to `.tad/evidence/e2e/feedback-collector-dogfood/tad-intro-feedback.json`

**Session C: Alex (Terminal 1) — validates read_feedback_protocol**
8. Human tells Alex: "Feedback JSON at .tad/evidence/e2e/feedback-collector-dogfood/tad-intro-feedback.json"
9. Alex runs `read_feedback_protocol` on the JSON — validates parsing, summary, verdict grouping
10. Alex generates modification notes (saved to `.tad/evidence/e2e/feedback-collector-dogfood/modification-notes.md`)
11. This validates that the protocol works end-to-end

**Note**: Step 10 produces modification NOTES (evidence), not a full handoff cycle. The full modification-handoff-to-Blake loop is proven by the protocol definition + these notes. A second full Blake execution cycle is NOT required for Phase 2 acceptance — that is natural usage going forward.

**Evidence location**: `.tad/evidence/e2e/feedback-collector-dogfood/`
**Evidence artifacts**: tad-intro.html, tad-intro-feedback.html, tad-intro-feedback.json, modification-notes.md

---

## 5. Mandatory Questions

### MQ1-MQ5: Not applicable (protocol + config changes, no data flow or UI state)

### MQ6: Technical Research
**Research conducted**: Phase 1 deep research (66 sources) covers the landscape. No additional research needed for Phase 2 — this is integration work.

---

## 6. Implementation Steps

### Phase 1: Protocol Implementation (estimated 30 min)

#### Deliverables
- [ ] Alex SKILL.md: `read_feedback_protocol` section added
- [ ] Alex SKILL.md: `acceptance_protocol` updated to reference feedback check
- [ ] Gate SKILL.md: `Gate4_Feedback_Check` section added

#### Steps
1. **Add `read_feedback_protocol` to Alex SKILL.md body**
   - Insert as top-level section between `acceptance_protocol` stub (line 1031) and `workflow_completion_trigger` (line 1033)
   - Content from §4.1 above
   - Must be in BODY (not references/) — the protocol definition lives here

2. **Update `references/acceptance-protocol.md`** (the actual acceptance flow)
   - Note: `acceptance_protocol` in SKILL.md body is a 4-line progressive-loading stub. The real acceptance flow (step1-step9) lives in `.claude/skills/alex/references/acceptance-protocol.md`
   - After step4b (Evidence check), before step5 (business check), add a step:
     "step4c_feedback: If handoff §8.5 feedback_required: true → check for feedback JSON at `{artifact_path}-feedback.json` or ask human for path. If found, run read_feedback_protocol from SKILL.md body. If not found AND human has no feedback, continue."

3. **Add `Gate4_Feedback_Check` to Gate SKILL.md**
   - Insert after `Structural_Subagent_Conditionality` section (around line 612), before `Required_Subagents` (line 614) — groups the soft/conditional check away from blocking enforcement
   - Content from §4.2 above
   - Add comment noting this is SOFT/non-blocking (Phase 2)
   - Conditional: only when feedback_required was true

### Phase 2: E2E Dogfood (estimated 1 hour)

#### Deliverables
- [ ] `tad-intro.html` — TAD introduction page
- [ ] `tad-intro-feedback.html` — feedback HTML for the intro page
- [ ] E2E evidence showing full cycle

#### Steps
1. **Create TAD intro page** (`tad-intro.html` in project root)
   - Simple, modern single-page HTML
   - Content: what TAD is, key features (two-agent system, four gates,见机行事 feedback), how to start
   - Self-contained (inline CSS), clean design
   - This is a REAL deliverable, not a test fixture

2. **Generate feedback HTML** (per feedback_collector_protocol)
   - Decompose the intro page into reviewable elements (title, sections, feature descriptions, call-to-action, etc.)
   - Generate `tad-intro-feedback.html` alongside
   - Include Phase 1 guard message in completion

3. **Report to human**: "Feedback HTML generated. Please open tad-intro-feedback.html, review, and export JSON."
   - Human fills out feedback and exports JSON
   - Human provides JSON path to Alex (Terminal 1)

4. **Evidence collection**
   - Save all artifacts to `.tad/evidence/e2e/feedback-collector-dogfood/`
   - Include: original HTML, feedback HTML, exported JSON (after human fills it)

---

## 7. File Structure

### 7.1 Files to Create
```
tad-intro.html                                              # TAD introduction page (E2E dogfood artifact)
tad-intro-feedback.html                                     # Feedback HTML for the intro page
.tad/evidence/e2e/feedback-collector-dogfood/               # E2E evidence directory
```

### 7.2 Files to Modify
```
.claude/skills/alex/SKILL.md                        # Add read_feedback_protocol section in body
.claude/skills/alex/references/acceptance-protocol.md  # Add step4c_feedback to acceptance flow
.claude/skills/gate/SKILL.md                        # Add Gate4_Feedback_Check
```

### 7.3 Grounded Against
- `.claude/skills/alex/SKILL.md` (read at 2026-06-10, acceptance_protocol stub at line 1028-1031, workflow_completion_trigger at line 1033)
- `.claude/skills/alex/references/acceptance-protocol.md` (read at 2026-06-10, step4b evidence check, step5 business check — insertion between them)
- `.claude/skills/gate/SKILL.md` (read at 2026-06-10, Gate 4 section at line 560, Structural_Subagent_Conditionality at line 608-612)

---

## 8. Testing Requirements

### 8.1 Structural Verification
- Alex SKILL.md: `read_feedback_protocol` exists with all 5 steps
- Gate SKILL.md: `Gate4_Feedback_Check` exists with conditional trigger
- E2E artifacts exist in evidence directory

### 8.3 Edge Cases
- What if feedback JSON has zero non-ok elements? → Alex reports "No changes requested" and skips handoff generation
- What if JSON file is malformed? → Alex asks for correct path
- What if feedback_required was false but human has feedback anyway? → Alex can still run read_feedback_protocol manually

### 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Human must fill out feedback HTML in browser | Open HTML, interact, export JSON | Human opens file in browser | N/A — human interaction is the point | Missing human feedback blocks E2E AC |

### 8.5 Feedback Collection (Non-Code Artifacts)

<!-- This handoff itself uses the Feedback Collector for the E2E dogfood -->
```yaml
feedback_required: true
artifact_type: frontend_page
suggested_dimensions:
  - "text content (title, descriptions, feature names)"
  - "layout (section order, visual hierarchy)"
  - "design (colors, typography, spacing)"
  - "call-to-action (getting started section)"
notes: "The tad-intro.html page is the E2E dogfood artifact. Blake should generate feedback HTML for it."
```

### 8.6 Test Evidence Required
- [ ] Protocol sections exist in SKILL files
- [ ] E2E artifacts exist (intro page + feedback HTML)
- [ ] E2E evidence directory populated

---

## 9. Acceptance Criteria

- [ ] Alex SKILL.md contains `read_feedback_protocol` with JSON parsing, verdict grouping, targeted handoff generation
- [ ] Gate 4 checks: if handoff had `feedback_required: true`, verify feedback was collected
- [ ] E2E loop: Blake generates tad-intro.html + feedback HTML → human fills → JSON → Alex reads → generates modification notes
- [ ] Feedback iteration number tracked (meta.iteration in JSON, referenced in handoff)
- [ ] Alex's read output references specific element IDs from feedback JSON

---

## 9.1 Spec Compliance Checklist — PRIMARY VERIFICATION SOURCE

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | read_feedback_protocol in Alex SKILL body | post-impl-verifiable | `grep -c 'read_feedback_protocol' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC2 | Protocol NOT in references/ | post-impl-verifiable | `ls .claude/skills/alex/references/read-feedback* 2>/dev/null \| wc -l` | 0 | (post-impl) |
| AC3 | Protocol has 5 steps (load, summarize, group, generate, confirm) | post-impl-verifiable | `grep -cE '1_load_json\|2_summarize\|3_group_by_verdict\|4_generate_handoff\|5_confirm' .claude/skills/alex/SKILL.md` | == 5 | (post-impl) |
| AC4 | Gate4_Feedback_Check in gate SKILL | post-impl-verifiable | `grep -c 'Gate4_Feedback_Check' .claude/skills/gate/SKILL.md` | ≥1 | (post-impl) |
| AC5 | Gate check is conditional on feedback_required | post-impl-verifiable | `grep -cE 'feedback_required.*true\|skip_if.*feedback_required' .claude/skills/gate/SKILL.md` | ≥1 | (post-impl) |
| AC6 | tad-intro.html exists | post-impl-verifiable | `test -f tad-intro.html && echo EXISTS` | EXISTS | (post-impl) |
| AC7 | tad-intro-feedback.html exists | post-impl-verifiable | `test -f tad-intro-feedback.html && echo EXISTS` | EXISTS | (post-impl) |
| AC8 | Feedback HTML has export JSON button | post-impl-verifiable | `grep -cE 'exportJSON\|Export.*JSON.*button\|download.*json' tad-intro-feedback.html` | ≥1 | (post-impl) |
| AC9 | E2E evidence directory exists | post-impl-verifiable | `test -d .tad/evidence/e2e/feedback-collector-dogfood && echo EXISTS` | EXISTS | (post-impl) |
| AC10a | read_feedback_protocol exists in SKILL body | post-impl-verifiable | `grep -c 'read_feedback_protocol' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC10b | acceptance_protocol references feedback check | post-impl-verifiable | `grep -c 'feedback_required' .claude/skills/alex/references/acceptance-protocol.md` | ≥1 | (post-impl) |

---

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0: E2E plan doesn't account for terminal isolation | §4.3 — rewritten as multi-session flow (Sessions A/B/C) | Resolved |
| backend-architect | P1: No priority ordering in generated handoff | §4.1 step 4 — added priority ordering + per-verdict instructions | Resolved |
| backend-architect | P1: No validation for reviewed=true, verdict=null | §4.1 step 1 — noted (Blake handles in schema doc) | Resolved |
| backend-architect | P1: E2E evidence omits Alex's modification output | §4.3 evidence artifacts — added modification-notes.md | Resolved |
| backend-architect | P1: Element ID stability not enforced | §4.1 step 4 — added ID preservation constraint | Resolved |
| backend-architect | P1: AC3 grep too generic | §9.1 AC3 — changed to step-numbered prefixes, expected == 5 | Resolved |
| code-reviewer | P0: AC3 false-positive — confirm matches 11 existing lines | §9.1 AC3 — changed to 1_load_json etc. prefixes | Resolved |
| code-reviewer | P0: acceptance_protocol is a stub, real flow in references/ | §6 Step 1-2 — clarified body vs reference insertion; added references/acceptance-protocol.md to Files to Modify | Resolved |
| code-reviewer | P1: AC8 false-positive on generic 'export' | §9.1 AC8 — changed to exportJSON/Export.*JSON.*button pattern | Resolved |
| code-reviewer | P1: Missing references/acceptance-protocol.md from files list | §7.2 + §7.3 — added | Resolved |
| code-reviewer | P1: AC10 conflates two concepts | §9.1 — split into AC10a (SKILL body) + AC10b (reference file) | Resolved |
| code-reviewer | P1: E2E terminal isolation ambiguity | §4.3 — explicit Session A/B/C markers | Resolved |

### Experts Selected

1. **backend-architect** — protocol flow soundness, Gate integration design, E2E validation completeness
2. **code-reviewer** — insertion point accuracy, AC grep correctness, file list completeness

### Overall Assessment (post-integration)

- backend-architect: PASS (1 P0 resolved, 5 P1 resolved, 5 P2 noted)
- code-reviewer: PASS (2 P0 resolved, 4 P1 resolved, 4 P2 noted)

---

## 10. Important Notes

### 10.1 Critical Warnings
- read_feedback_protocol MUST be in Alex SKILL.md body (same reasoning as Phase 1)
- The E2E requires REAL human interaction — Blake generates the artifacts, but a human must actually fill out the feedback HTML in a browser. This is the whole point.
- Gate 4 feedback check is SOFT (warn not block) in Phase 2. Blocking enforcement in Phase 3.

### 10.2 Known Constraints
- The modification handoff generated by read_feedback_protocol is a NORMAL handoff — it goes through the full TAD cycle (Alex creates, Blake executes)
- The E2E dogfood will produce a tad-intro.html that should be a genuinely useful page, not a throwaway test

### 10.3 Sub-Agent Usage
- [ ] **code-reviewer** — after modifying Alex + Gate SKILL files
- [ ] **frontend-specialist** — optional, for the tad-intro.html page quality

---

## 11. Decision Rationale

### 11.1 Why embed read_feedback into acceptance_protocol (not standalone command)

| Approach | Pros | Cons | Decision |
|----------|------|------|----------|
| Standalone *feedback command | Clean separation | Yet another command to remember; user has to know to invoke it | NOT chosen |
| Embed into acceptance_protocol | Natural flow: user does *accept → Alex checks for feedback | Slightly more complex acceptance_protocol | Chosen — per "Embed Into Existing Flows" principle |

### 11.2 Why SOFT Gate 4 check (not blocking)

The feedback loop is new and unvalidated. If we make the Gate 4 check blocking immediately, it could prevent acceptance of non-code tasks that legitimately don't need feedback (e.g., a simple logo file). Phase 3 will tighten to blocking after dogfood proves the flow works.

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0
