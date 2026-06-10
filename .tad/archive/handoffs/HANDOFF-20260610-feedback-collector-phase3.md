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
**Task ID:** TASK-20260610-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260610-feedback-collector.md (Phase 3/3 — Final)

---

## Gate 2: Design Completeness

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | Overlay model + Playground deprecation fully designed |
| Components Specified | ✅ | 5 files to modify, 1 E2E re-test |
| Data Flow Mapped | ✅ | Same JSON schema, different HTML generation strategy per artifact_type |

**Gate 2 Result**: ✅ PASS

---

## 1. Task Overview

### 1.1 What We're Building
Phase 2 dogfood proved the protocol works mechanically but exposed a critical UX problem: card-based feedback HTML doesn't work for frontend pages because the user can't see the actual page. This phase fixes it by adding an **overlay model** for spatial artifacts (frontend_page, design) — the feedback HTML embeds the actual page and lets the user click on elements to annotate them in-place. Also deprecates /playground.

### 1.2 Why We're Building It
User feedback (verbatim): "他把这个网页拆成了很多很小的部分，然后他也没有我也不知道他原来长什么样子，整体无法给判断和无法给评价。" The user needs to see the whole page to judge the parts. Card model strips spatial context.

### 1.3 Intent Statement
**The real problem**: A frontend page is a spatial artifact — elements relate to each other visually. Extracting them into isolated cards destroys the context needed for judgment. The user wants to annotate ON the page, like marking up a document.

**This is NOT**:
- A rewrite of the entire feedback system (audio/video card model stays unchanged)
- A Windsurf-level product (we generate a simple overlay HTML, not a browser extension)
- A change to the JSON schema (same schema, different HTML generation)

---

## Project Knowledge (Blake must read)

**Relevant lessons:**
1. **见机行事 core principle** — the overlay HTML is still disposable and zero-cost to regenerate. Don't over-engineer it.
2. **Circular trigger** — feedback_collector_protocol stays in SKILL body. The routing by artifact_type is an UPDATE to the existing protocol, not a new reference file.

---

## 2. Background Context

### 2.1 Phase 2 Dogfood Evidence
- `.tad/evidence/e2e/feedback-collector-dogfood/modification-notes.md` — documents the failure and insight
- User's global_notes: wants overlay on actual page, click-to-annotate like taking notes
- Card model works for: audio segments (Colin project), video timeline slices
- Card model fails for: frontend pages, design layouts (spatial context lost)

### 2.2 Current State
- Blake's `feedback_collector_protocol` (line 1508) generates card-based HTML for ALL artifact types
- No routing by artifact_type exists yet
- /playground is still active (standalone command)

---

## 3. Requirements

### 3.1 Functional Requirements
- FR1: Blake's feedback_collector_protocol routes by artifact_type: `frontend_page`/`design` → overlay model; `audio`/`video`/`brand`/`generic` → card model (unchanged)
- FR2: Overlay feedback HTML embeds the actual artifact page (iframe), overlays a transparent annotation layer, click any element to open annotation panel
- FR3: Same JSON schema output — element IDs, selectors, verdicts, free text, export button
- FR4: /playground deprecated with redirect notice
- FR5: All playground cross-references updated
- FR6: Gate4_Feedback_Check upgraded from SOFT to BLOCKING

### 3.2 Non-Functional Requirements
- NFR1: Overlay HTML must be self-contained (inline CSS/JS, no external deps)
- NFR2: Blake inlines artifact content (no iframe — `file://` cross-origin breaks it)
- NFR3: The annotation panel should be a floating/modal UI that doesn't obscure the full page

---

## 4. Technical Design

### 4.1 Overlay Feedback HTML Architecture

```
┌─────────────────────────────────────────────────┐
│  Feedback Overlay Page (tad-intro-feedback.html) │
│                                                   │
│  ┌─────────────────────────────────────────────┐ │
│  │  INLINED artifact HTML content              │ │
│  │  (copied from tad-intro.html <body>)        │ │
│  │  rendered normally with overlay JS injected  │ │
│  │                                              │ │
│  │  [user hovers → element highlights]          │ │
│  │  [user clicks → annotation panel opens] ──┐  │ │
│  │                                            │  │ │
│  └────────────────────────────────────────────┼──┘ │
│                                                │    │
│  ┌────────────────────────────────────────────▼──┐ │
│  │  Floating Annotation Panel                    │ │
│  │  Element: {clicked element tag + text preview}│ │
│  │  Verdict: [OK] [Modify] [Delete] [Replace]   │ │
│  │  Comment: [________________]                  │ │
│  │  Priority: [High] [Med] [Low]                │ │
│  │  [Save Note]                                  │ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
│  Sidebar: Annotation list (3 of N elements noted)   │
│  Coverage nudge: "Consider: layout, typography,     │
│   color contrast, responsive breakpoints"            │
│  [Export JSON]                                       │
└─────────────────────────────────────────────────────┘
```

**CRITICAL: Inline, NOT iframe.** The `file://` protocol treats each file as a different origin — iframe + `contentDocument` traversal fails silently in Chrome/Safari. Fix: Blake COPIES the artifact's `<body>` content directly into the feedback HTML, then injects the overlay JavaScript and annotation CSS. No cross-origin issues, no event propagation complexity.

**How it works:**
1. Blake reads the artifact HTML, extracts `<body>` content (and relevant `<style>` blocks)
2. Inlines that content into the feedback HTML, wrapped in a container div
3. Injects overlay JavaScript: hover → highlight element (outline), click → open floating annotation panel
4. Each annotation creates an element entry in the JSON (auto-detecting CSS selector from the element's tag/class/id, element type from tag name, label from text content)
5. Sidebar shows annotation list + coverage nudge ("Consider reviewing: layout, typography, color contrast")
6. Export JSON button produces the same schema as card model

**Key differences from card model:**
- Card: Blake pre-decomposes → user reviews pre-selected elements
- Overlay: user CHOOSES which elements to annotate → Blake provides annotation UI + coverage nudge
- Coverage nudge: `suggested_dimensions` from §8.5 displayed as a sidebar checklist prompt (not forced, just a reminder)

### 4.2 Protocol Update in Blake SKILL.md

Update `feedback_collector_protocol` (line 1508) step `3_generate_html`:

```yaml
3_generate_html:
  action: |
    Route by artifact_type from handoff §8.5:

    OVERLAY mode (frontend_page, design):
      Generate feedback HTML that:
      - INLINES the artifact's <body> content + <style> blocks (NOT iframe — file:// cross-origin breaks it)
      - Wraps inlined content in a container div, injects overlay JS
      - Hover → element highlights (outline); click → floating annotation panel
      - Auto-detects CSS selector + element type + label from clicked element
      - Sidebar: annotation list + coverage nudge from suggested_dimensions
      - Export JSON (same schema)
      Naming: {artifact_name}-feedback.html (same as before)

    CARD mode (audio, video, brand, generic):
      No change — use existing card-based generation (Phase 1 guidelines)
```

### 4.3 Playground Deprecation

1. `/playground` SKILL.md: add deprecation notice at top, redirect to Feedback Collector
2. Alex SKILL.md `playground_reference` (line 841): update to `feedback_collector_reference`, point to Blake's protocol
3. Config-workflow.yaml `playground` section: add `deprecated: true`, migration note
4. `deprecation.yaml`: add entry `playground → feedback-collector` with date and version
5. Alex SKILL.md `global_skill_exclusion`: update `frontend-design:frontend-design` entry to reference Feedback Collector instead of /playground

### 4.4 Gate 4 Upgrade

Update `Gate4_Feedback_Check` in gate/SKILL.md: change from SOFT (warn) to BLOCKING when `feedback_required: true`.

---

## 6. Implementation Steps

### Step 1: Update Blake's feedback_collector_protocol (~30 min)

1. Open `.claude/skills/blake/SKILL.md`, find `feedback_collector_protocol` (line 1508)
2. Update `3_generate_html` step to route by artifact_type (overlay vs card)
3. Add overlay HTML generation guidelines (from §4.1)
4. Keep card model guidelines unchanged for audio/video/brand/generic

### Step 2: E2E re-test with overlay (~30 min)

1. Delete existing `tad-intro-feedback.html` (card version)
2. Regenerate feedback HTML for `tad-intro.html` using the UPDATED overlay protocol
3. Verify: new feedback HTML iframes tad-intro.html, user can click elements to annotate
4. Save new feedback HTML to `.tad/evidence/e2e/feedback-collector-dogfood/tad-intro-feedback-v2-overlay.html`

### Step 3: Playground deprecation + cleanup (~20 min)

1. Add deprecation notice to `.claude/skills/playground/SKILL.md` (top of file, before activation protocol)
2. Update Alex SKILL.md `playground_reference` (line 841) → `feedback_collector_reference` pointing to Blake's protocol
3. Update ALL other `/playground` references in Alex SKILL.md (lines 503-504 global_skill_exclusion, 542/658/838 comments, 1447-1499 help text) → reference Feedback Collector
4. Update `.claude/skills/alex/references/design-protocol.md` — 3 /playground references (lines 267, 268, 283) → Feedback Collector
5. Update `config-workflow.yaml` playground section: `deprecated: true` with migration note
6. Add entry to `.tad/deprecation.yaml` (match existing format: version key, description, files list, date)
7. Update Alex `global_skill_exclusion` frontend-design entry
8. Remove `phase1_guard` from Blake SKILL.md (line ~1561) — Phase 2 reader is operational, guard is stale

### Step 4: Gate 4 upgrade (~5 min)

1. Update `Gate4_Feedback_Check` in gate/SKILL.md: SOFT → BLOCKING

---

## 7. File Structure

### 7.1 Files to Create
```
.tad/evidence/e2e/feedback-collector-dogfood/tad-intro-feedback-v2-overlay.html  # overlay E2E evidence
```

### 7.2 Files to Modify
```
.claude/skills/blake/SKILL.md          # Update feedback_collector_protocol with overlay routing + remove phase1_guard
.claude/skills/playground/SKILL.md     # Deprecation notice
.claude/skills/alex/SKILL.md           # playground_reference → feedback_collector_reference + update all /playground refs
.claude/skills/alex/references/design-protocol.md  # Update 3 /playground references to Feedback Collector
.tad/config-workflow.yaml              # Mark playground deprecated
.tad/deprecation.yaml                  # Add playground entry
.claude/skills/gate/SKILL.md           # Gate4_Feedback_Check: SOFT → BLOCKING
tad-intro-feedback.html                # Regenerate with inline overlay model
```

---

## 8. Testing Requirements

### 8.4 Friction Preflight

| Friction Point | Required Step | Expected Fix Path | Allowed Substitute | Gate Impact |
|----------------|---------------|-------------------|--------------------|-------------|
| Many /playground references scattered across Alex SKILL | Enumerate and update each reference | Systematic grep + replace per Step 3 | N/A | Stale references = AC11 FAIL |

### 8.5 Feedback Collection (Non-Code Artifacts)

```yaml
feedback_required: true
artifact_type: frontend_page
suggested_dimensions: []  # overlay mode: user drives decomposition
notes: "E2E re-test of overlay model. User should be able to click elements on the actual page to annotate."
```

---

## 9. Acceptance Criteria

- [ ] Blake's protocol routes by artifact_type (overlay for frontend_page/design, cards for audio/video/brand/generic)
- [ ] Overlay feedback HTML embeds tad-intro.html via iframe, user can click elements to annotate
- [ ] Overlay annotations export same JSON schema (version 1.0, elements with id/selector/verdict/free_text)
- [ ] /playground SKILL.md has deprecation notice
- [ ] Alex SKILL.md playground_reference replaced with feedback_collector_reference
- [ ] Config-workflow.yaml playground.deprecated = true
- [ ] deprecation.yaml has playground entry
- [ ] Gate4_Feedback_Check is BLOCKING (not SOFT)
- [ ] No broken /playground references in active SKILL/config files

---

## 9.1 Spec Compliance Checklist

| # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
|---|---------------------|-------------------|--------------------|--------------------|-----------------|
| AC1 | Protocol routes by artifact_type | post-impl-verifiable | `grep -cE 'OVERLAY.*mode\|overlay.*frontend_page\|CARD.*mode' .claude/skills/blake/SKILL.md` | ≥2 | (post-impl) |
| AC2 | Overlay HTML embeds artifact via iframe | post-impl-verifiable | `grep -cE 'iframe\|<iframe' tad-intro-feedback.html` | ≥1 | (post-impl) |
| AC3 | Overlay has click-to-annotate | post-impl-verifiable | `grep -cE 'click\|annotation\|annotate' tad-intro-feedback.html` | ≥2 | (post-impl) |
| AC4 | Overlay exports JSON with same schema | post-impl-verifiable | `grep -cE 'exportJSON\|Export.*JSON\|elements_total\|selector_type' tad-intro-feedback.html` | ≥2 | (post-impl) |
| AC5 | Playground deprecated | post-impl-verifiable | `head -5 .claude/skills/playground/SKILL.md \| grep -ci 'deprecated'` | ≥1 | (post-impl) |
| AC6 | Alex references updated | post-impl-verifiable | `grep -c 'feedback_collector_reference' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC7 | Config playground deprecated | post-impl-verifiable | `grep -cE 'deprecated.*true' .tad/config-workflow.yaml` | ≥1 | (post-impl) |
| AC8 | deprecation.yaml entry | post-impl-verifiable | `grep -c 'playground' .tad/deprecation.yaml` | ≥1 | (post-impl) |
| AC9 | Gate4 feedback check BLOCKING | post-impl-verifiable | `sed -n '/Gate4_Feedback_Check/,/^[A-Z]/p' .claude/skills/gate/SKILL.md \| grep -cE 'blocking'` | ≥1 | (post-impl) |
| AC10 | playground_reference replaced | post-impl-verifiable | `grep -c 'feedback_collector_reference' .claude/skills/alex/SKILL.md` | ≥1 | (post-impl) |
| AC11 | design-protocol.md updated | post-impl-verifiable | `grep -c '/playground' .claude/skills/alex/references/design-protocol.md` | 0 | (post-impl) |
| AC12 | phase1_guard removed or updated | post-impl-verifiable | `grep -c 'Phase 1 only.*Alex cannot' .claude/skills/blake/SKILL.md` | 0 | (post-impl) |

---

## 9.2 Expert Review Status

### Audit Trail

| Reviewer | Issue | Resolution Section | Status |
|----------|-------|-------------------|--------|
| backend-architect | P0: iframe file:// cross-origin breaks default usage | §4.1 — changed to INLINE model (copy body content, no iframe) | Resolved |
| backend-architect | P1: Event propagation unspecified for iframe click | §4.1 — moot (inline eliminates iframe boundary) | Resolved |
| backend-architect | P1: phase1_guard stale | §6 Step 3.8 — added removal instruction | Resolved |
| backend-architect | P1: Playground deprecation leaves orphaned dirs | §10.2 — noted as acceptable (deprecated ≠ deleted) | Deferred (Phase 3 only deprecates, does not delete) |
| backend-architect | P1: AC10 too narrow (only 3 files) | §9.1 — replaced with targeted AC10 + added AC11 for design-protocol.md | Resolved |
| code-reviewer | P0: AC10 will never reach 0 (14 existing /playground matches) | §9.1 — replaced with functional check (feedback_collector_reference exists) + AC11 (design-protocol clean) | Resolved |
| code-reviewer | P0: AC9 tautology (38 existing BLOCKING matches) | §9.1 — scoped to Gate4_Feedback_Check section via sed | Resolved |
| code-reviewer | P1: Missing design-protocol.md from file list | §7.2 — added | Resolved |
| code-reviewer | P1: phase1_guard stale (duplicate) | §6 Step 3.8 + AC12 — added | Resolved |
| code-reviewer | P1: Gate 2 count mismatch (5 vs 7) | Noted — cosmetic, Blake reads file list not Gate 2 prose | Deferred |

### Experts Selected

1. **backend-architect** — overlay architecture (iframe vs inline), cross-origin risks, Gate upgrade safety
2. **code-reviewer** — AC verification correctness, file list completeness, insertion point accuracy

### Overall Assessment (post-integration)

- backend-architect: PASS (1 P0 resolved, 4 P1 resolved/deferred, 3 P2 noted)
- code-reviewer: PASS (2 P0 resolved, 4 P1 resolved/deferred, 3 P2 noted)

---

## 10. Important Notes

### 10.1 Critical Warnings
- iframe same-origin: feedback HTML and artifact MUST be in the same directory
- The overlay model changes WHO decomposes: Blake no longer pre-selects elements; the USER clicks what they want to annotate. This is a fundamental UX shift from "AI-driven decomposition" to "human-driven decomposition"
- Card model for audio/video stays UNCHANGED — don't touch it

### 10.2 Known Constraints
- iframe can't access cross-origin content. If artifact is served from a dev server (localhost:3000), the feedback HTML must also be served from the same origin. For static HTML files in the same directory, this is not an issue.
- The overlay JavaScript needs to traverse the iframe's DOM to detect what the user clicked. This works for same-origin iframes.

---

**Handoff Created By**: Alex (Agent A)
**Date**: 2026-06-10
**Version**: 3.1.0
