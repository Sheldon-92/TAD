---
task_type: yaml
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
**Date:** 2026-07-14
**Project:** TAD Framework
**Task ID:** TASK-20260714-003
**Handoff Version:** 3.1.0
**Epic:** EPIC-20260714-dependency-evolution-awareness.md (Phase 3/3)

---

## Gate 2: Design Completeness

**Execution time**: 2026-07-14

### Gate 2 Checklist

| Check | Status | Notes |
|-------|--------|-------|
| Architecture Complete | ✅ | STEP 3.5b protocol + safety buffer logic + LLM relevance + limitation detection |
| Components Specified | ✅ | 1 new STEP, 1 new command (*deps-update), protocol text with examples |
| Functions Verified | ✅ | Reads existing scan-results.yaml (Phase 2) + REGISTRY.yaml (Phase 1) |
| Data Flow Mapped | ✅ | scan-results + REGISTRY → inline LLM judgment → filtered display |

**Gate 2 Result**: ✅ PASS

**Alex Confirmation**: I have verified all design elements. Blake can independently complete implementation based on this document.

---

## Handoff Checklist (Blake must read)

- [ ] Read all sections
- [ ] Read Project Knowledge section for historical lessons
- [ ] Understand the true intent (not just literal requirements)
- [ ] Can independently complete implementation using this document

---

## 1. Task Overview

### 1.1 Title
Dependency Evolution Awareness — Phase 3: Alex Integration

### 1.2 Background
Phase 1 created the dependency registry (REGISTRY.yaml with rich fields). Phase 2 built the upstream scanner (deps-scan.sh → scan-results.yaml with raw data). Phase 3 is the final piece — wiring scan results into Alex's startup health check with LLM-powered relevance assessment, safety buffer enforcement, and known-limitation resolution detection.

### 1.3 Intent Statement
When the user activates Alex, they should immediately see which of their dependencies have meaningful upstream changes that are safe to evaluate. The noise filter ensures they only see what matters (relevant to their usage + past safety buffer). The limitation detection tells them when a workaround they maintain can be removed because upstream now handles it natively. This is the "last mile" that turns raw scan data into actionable intelligence.

**Key design decision**: LLM relevance assessment is done **inline at startup** — Alex reads scan-results + REGISTRY, judges relevance in the conversation context, and displays filtered results. Results are NOT cached back to scan-results.yaml (keeps scan data pure raw).

---

## 2. Requirements

### 2.1 Functional Requirements

**FR1: Alex STEP 3.5b — Dependency Evolution Check**

A new step in Alex's activation protocol, placed AFTER STEP 3.5 (document health check) and BEFORE STEP 3.55 (zombie cleanup). The step is:

```yaml
STEP 3.5b: Dependency Evolution Check
  trigger: "After STEP 3.5 document health check completes"
  blocking: false
  suppress_if: ".tad/dependencies/scan-results.yaml not found"
  action: |
    1. Read .tad/dependencies/scan-results.yaml
       → If not found: skip silently (project has no scan data yet)
       → If last_scan older than 30 days: append warning
         "⚠️ Dependency scan is {N} days old. Run *deps-check to refresh."

    2. Read .tad/dependencies/REGISTRY.yaml
       → If not found: skip (inconsistent state — scan exists but no registry)

    3. For each result where version_changed == true AND scan_status == "success":

       a. SAFETY BUFFER computation:
          Look up safety_tier from REGISTRY for this dependency.
          Match scan_result.dependency to REGISTRY.name (exact string match).
          If dependency not found in REGISTRY: skip with warning "orphan scan entry".
          Compute buffer_days: L1 → 7, L2 → 14, L3 → 30
          If days_since_release >= buffer_days → buffer_status = "evaluable"
          If days_since_release < buffer_days → buffer_status = "observing"
          urgent_security detection (two paths, either triggers):
            Path 1: security_advisories is non-empty
            Path 2: changelog_text matches CVE pattern (regex: /CVE-\d{4}-\d+/)
          If either path matches → buffer_status = "urgent_security"
            (overrides tier AND buffer — always show immediately)
          Rationale: GitHub SecurityAdvisory API may not have entries for CVEs
          published only via NVD or listed only in release notes. The jq 1.8.2
          case proves this: 14 CVEs in changelog but security_advisories: [].
          Safety buffer is for supply-chain risk, NOT for suppressing security fixes.

       b. LLM RELEVANCE ASSESSMENT (inline, not cached):
          Read capabilities_used from REGISTRY for this dependency.
          Read changelog_text from scan-results for this dependency.
          Alex judges: does the changelog mention changes relevant to
          the specific capabilities listed in capabilities_used?
          Assign: relevance = HIGH | MEDIUM | LOW
          - HIGH: changelog directly mentions a capability the user uses
          - MEDIUM: changelog mentions the same domain/module but not a specific capability
          - LOW: changelog is unrelated to user's usage (e.g., bugfix in unused feature)

       c. LIMITATION RESOLUTION detection:
          Read known_limitations from REGISTRY for this dependency.
          For each limitation where resolved_by_upstream == false:
            Alex judges: does the changelog_text suggest this limitation
            is now resolved in the new version?
            Confidence threshold: **err toward false positives** — surface
            candidates even if uncertain. Results are labeled "potentially_resolved"
            and confirmed by user via *deps-update AskUserQuestion.
            If yes or maybe → mark as potentially_resolved, include in output.

    4. NOISE FILTER:
       Only display dependencies where:
       - buffer_status == "evaluable" AND relevance >= MEDIUM
       - OR buffer_status == "urgent_security" (always show, regardless of relevance)
       All "observing" dependencies are suppressed unless urgent_security.
       For multi-topic changelogs: assign MAX relevance across all changes.

    5. OUTPUT FORMAT:
       If 0 deps pass filter AND no urgent_security:
         → "📦 Dependencies: {total_changed} updated, all within safety buffer or low relevance"
       If deps pass filter:
         → For each evaluable + relevant:
           "📦 {name} {current} → {latest} ({days}d ago, past {tier} buffer):
            {1-line relevance summary from LLM}"
         → For each with potentially_resolved limitation:
           "  💡 Limitation {id} may be resolved: {limitation.description}"
         → For each urgent_security:
           "🔴 {name}: {advisory_count} security advisory(ies) — evaluate immediately
            {first advisory summary}"

    6. STALENESS CHECK (independent of version changes):
       If last_scan > 30 days: append "⚠️ Scan data is {N} days old"
       If last_scan > 7 days AND < 30 days: no warning (weekly scan expected)
  
  interacts_with: |
    Independent of STEP 3.5 (document health), STEP 3.55 (zombie cleanup),
    and STEP 3.6 (pair test detection). Does NOT suppress any other step.
    STEP 3.7 (session state) runs after this.
  output: "Brief dependency status line, or silent if nothing actionable"
```

**FR2: `*deps-update` Command**

Records that a dependency has been upgraded:
1. `*deps-update <name>` — Alex asks for the new version
2. Updates REGISTRY.yaml:
   - `current_version` → new value
   - `version_pinned_at` → today's date
   - `last_checked` → today's date
3. If the dependency had `known_limitations` with `resolved_by_upstream: false` that were flagged as `potentially_resolved` by STEP 3.5b:
   - AskUserQuestion per limitation: "Limitation {id} was flagged as potentially resolved. Confirm resolved?"
   - If confirmed → set `resolved_by_upstream: true`
   - If not confirmed → keep `resolved_by_upstream: false`
4. Output: "✅ {name} updated to {version}. {N} limitations confirmed resolved."

**FR3: Safety Buffer Constants**

Define in the STEP 3.5b protocol (not in a separate config file — keep it simple):
```
L1 = 7 days   (npm/pip packages, AI model APIs, CLI tools)
L2 = 14 days  (platform features — OpenClaw, Supabase, NotebookLM)
L3 = 30 days  (major version upgrades — Next.js, framework breaking changes)
```

These are defaults from the user's confirmed design. Not configurable in Phase 3 (configuration is a future enhancement if needed).

---

## 3. Design Summary

### Data Flow at Startup
```
Alex STEP 3.5b
  ├─ Read scan-results.yaml (raw upstream data from Phase 2)
  ├─ Read REGISTRY.yaml (capabilities_used, known_limitations, safety_tier)
  ├─ For each version_changed dep:
  │   ├─ Compute buffer_status (safety_tier → days threshold → compare days_since_release)
  │   ├─ LLM judges relevance (changelog_text vs capabilities_used) → HIGH/MEDIUM/LOW
  │   └─ LLM checks limitation resolution (changelog_text vs known_limitations)
  ├─ Filter: evaluable + relevant >= MEDIUM, or urgent_security
  └─ Display filtered results
```

### *deps-update Flow
```
User: *deps-update notebooklm-cli
Alex: "What version did you upgrade to?"
User: "0.6.1"
Alex: → Edit REGISTRY.yaml (current_version, version_pinned_at, last_checked)
      → Check potentially_resolved limitations
      → AskUserQuestion per limitation
      → Update resolved_by_upstream flags
      → "✅ notebooklm-cli updated to 0.6.1. 1 limitation confirmed resolved."
```

---

## 4. Implementation Guidance

### 4.1 This Phase is Protocol Text, Not Code
Unlike Phase 1/2, Phase 3 produces **Alex SKILL.md protocol additions**, not bash scripts or YAML schemas. Blake writes protocol YAML that defines Alex's behavior. The protocol references existing files (scan-results.yaml, REGISTRY.yaml) created by Phase 1/2.

### 4.2 STEP 3.5b Placement in SKILL.md
Insert **immediately after** the existing STEP 3.5 block (document health check — search for `STEP 3.5: Document health check`) and **before STEP 3.6** (Pair test report detection). Follow the exact YAML structure of existing STEPs (name, action, blocking, suppress_if, interacts_with, output fields).

### 4.3 LLM Relevance Assessment — No Sub-Agent
The relevance assessment is done by Alex itself in the activation flow — NOT by spawning a sub-agent. Alex IS the LLM. The protocol text describes WHAT to judge (changelog vs capabilities_used), and Alex uses its natural language understanding to make the assessment. No `Agent` tool call needed.

### 4.4 REGISTRY.yaml Editing for *deps-update
Use the `Edit` tool (not yq -i) to update REGISTRY.yaml fields. This avoids yq's whole-file normalization issue (shell-portability pattern). The protocol should specify which fields to update and what values to set.

### 4.5 Alex SKILL Routing for *deps-update
Add `*deps-update` to:
- `commands:` section
- `explicit_commands` array
- `route_targets` mapping → `deps_update_protocol`
- Protocol details in `deps-protocol.md` reference file (append section)
- `load_when`: "When *deps-update is invoked, Read the reference for the update flow."

### 4.6 Circular Trigger Safety
STEP 3.5b MUST stay in SKILL.md body (not extracted to references/). The trigger is "after STEP 3.5" — if extracted, Alex wouldn't know the step exists, so it would never fire. This is the same circular-trigger pattern from the L1 principle "Execution Discipline Content Must Stay in SKILL Body."

---

## 5. Scope

### 5.1 In Scope
- STEP 3.5b protocol in Alex SKILL.md body
- Safety buffer computation logic (L1/L2/L3 → days → buffer_status)
- LLM relevance assessment (inline, changelog vs capabilities_used)
- Known limitation resolution detection (changelog vs known_limitations)
- Noise filter (evaluable + relevant >= MEDIUM, or urgent_security)
- `*deps-update` command (update version + confirm limitation resolution)
- Staleness warning (scan > 30 days old)

### 5.2 Out of Scope
- Auto-upgrading code or dependencies
- Configurable buffer thresholds (hardcoded L1/L2/L3 for now)
- Sub-agent spawning for relevance assessment (Alex judges inline)
- Modifying deps-scan.sh or scan-results schema
- Cross-project dependency dashboards

---

## 6. Files to Modify

| File | Action | Description |
|------|--------|-------------|
| `.claude/skills/alex/SKILL.md` | MODIFY | Add STEP 3.5b (body), *deps-update command + route |
| `.claude/skills/alex/references/deps-protocol.md` | MODIFY | Add deps_update_protocol section |

---

## 7. Testing Checklist

- [ ] STEP 3.5b protocol text exists in SKILL.md body (not in references/)
- [ ] STEP 3.5b correctly placed between STEP 3.5 and STEP 3.55
- [ ] Safety buffer constants defined: L1=7, L2=14, L3=30
- [ ] Protocol describes LLM relevance assessment (changelog vs capabilities_used)
- [ ] Protocol describes limitation resolution detection (changelog vs known_limitations)
- [ ] Noise filter logic specified (evaluable + MEDIUM+, or urgent_security)
- [ ] *deps-update command routed (explicit_commands + route_targets)
- [ ] deps_update_protocol in deps-protocol.md reference file
- [ ] Staleness warning at 30 days threshold
- [ ] Output format examples included in protocol

---

## 8. Additional Metadata

### 8.1 Priority
Medium — completes the Epic

### 8.2 Estimated Effort
Small — protocol text additions to SKILL.md + reference file

### 8.3 Risk Assessment
- Low risk: no bash scripts, no API calls, no file creation
- Main risk: STEP 3.5b protocol being too verbose (bloating SKILL.md context load)
- Mitigation: keep STEP 3.5b concise (~50 lines YAML in body, SKILL.md grows from ~1862 to ~1912 lines — modest increase). Detailed *deps-update flow goes to reference file (safe per circular trigger test).

### 8.4 Friction Preflight
- No external dependencies needed
- Friction Status: READY

### 8.5 Feedback Collection
- feedback_required: false

---

## 9. Acceptance Criteria

### 9.1 Spec Compliance Checklist

| AC# | Description | Verification Method | Expected Evidence |
|-----|-------------|-------------------|-------------------|
| AC1 | STEP 3.5b exists in SKILL.md body | `grep -c 'STEP 3.5b\|Dependency Evolution Check' .claude/skills/alex/SKILL.md` | ≥2 |
| AC2 | STEP 3.5b placed after 3.5, before 3.6 | `awk '/STEP 3.5:/{a=NR} /STEP 3.5b/{b=NR} /STEP 3.6:/{c=NR} END{print (a<b && b<c)?"OK":"FAIL"}' .claude/skills/alex/SKILL.md` | OK |
| AC3 | Safety buffer constants present | `grep -c 'L1.*7\|L2.*14\|L3.*30' .claude/skills/alex/SKILL.md` | ≥3 |
| AC4 | LLM relevance assessment described | `grep -c 'capabilities_used\|relevance.*HIGH\|MEDIUM\|LOW' .claude/skills/alex/SKILL.md` | ≥2 |
| AC5 | Limitation resolution detection described | `grep -c 'known_limitations\|resolved_by_upstream\|potentially_resolved\|workaround.*removable' .claude/skills/alex/SKILL.md` | ≥2 |
| AC6 | Noise filter logic present | `grep -c 'evaluable.*MEDIUM\|urgent_security\|noise.filter\|buffer_status' .claude/skills/alex/SKILL.md` | ≥2 |
| AC7 | *deps-update in explicit_commands | `grep 'explicit_commands' .claude/skills/alex/SKILL.md \| grep -c 'deps-update'` | 1 |
| AC8 | deps_update_protocol in reference file | `grep -c 'deps_update_protocol\|deps-update' .claude/skills/alex/references/deps-protocol.md` | ≥2 |
| AC9 | Staleness warning at 30 days | `grep -c '30.*days\|staleness\|days.*old' .claude/skills/alex/SKILL.md` | ≥1 |
| AC10 | Change scope as planned | `git diff --stat` | Only §6 files changed |

---

## 10. Required Evidence Manifest

```yaml
expert_reviews:
  - .tad/evidence/reviews/blake/deps-alex-integration/spec-compliance.md
  - .tad/evidence/reviews/blake/deps-alex-integration/code-review.md
gate_verdicts:
  - .tad/evidence/reviews/blake/deps-alex-integration/gate3-report.md
completion:
  - .tad/active/handoffs/COMPLETION-20260714-deps-alex-integration.md
blake_reviews: []
knowledge_updates: []
```

---

## 11. Decision Summary

| # | Decision | Rationale | Alternatives Considered |
|---|----------|-----------|------------------------|
| D1 | LLM assessment inline, not cached | Keeps scan-results pure raw data; Alex IS the LLM, no sub-agent needed; assessment may improve with model upgrades without re-scanning | Cache results (rejected: adds write-back complexity, stale cache risk) |
| D2 | STEP 3.5b in body, not reference | Circular trigger safety — startup step must be visible to fire | Reference (rejected: L1 principle violation) |
| D3 | Buffer constants hardcoded, not configurable | Simplicity; user confirmed 7/14/30 in *discuss; configuration is future enhancement | Config file (rejected: premature for 3 constants) |
| D4 | Edit tool for *deps-update, not yq -i | Avoids yq whole-file normalization (shell-portability pattern) | yq -i (rejected: known gotcha) |

---

## Project Knowledge

### Blake must note these historical lessons:

- **Execution Discipline: Circular Trigger Test** (principles.md) — STEP 3.5b MUST stay in SKILL.md body. If extracted to references/, the agent won't know it exists and the trigger never fires.
- **yq -i Normalizes Whole File** (patterns/shell-portability.md) — *deps-update must use Edit tool for REGISTRY.yaml, not yq -i.
- **AI/Human Judgment Domain Awareness** (principles.md) — The LLM relevance assessment is in AI's domain (text analysis). The decision to actually upgrade is in human's domain (risk tolerance, timing). STEP 3.5b surfaces information; human decides action.

---

## Message to Blake

📨 **Blake Implementation Task**

| Field | Value |
|-------|-------|
| **Task** | Dependency Evolution Awareness — Phase 3: Alex Integration |
| **Handoff** | `.tad/active/handoffs/HANDOFF-20260714-deps-alex-integration.md` |
| **Epic** | EPIC-20260714-dependency-evolution-awareness.md (Phase 3/3) |
| **Priority** | Medium |
| **Scope** | STEP 3.5b startup protocol + safety buffer + LLM relevance + limitation detection + *deps-update |
| **Key Files** | `.claude/skills/alex/SKILL.md` (MODIFY — STEP 3.5b in body + command), `.claude/skills/alex/references/deps-protocol.md` (MODIFY — update protocol) |
| **Critical** | STEP 3.5b MUST stay in SKILL body (circular trigger). LLM assessment is inline (no sub-agent). Use Edit tool for REGISTRY updates (not yq -i). |
