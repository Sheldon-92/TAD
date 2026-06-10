# Spec Compliance Review: Friction Protocol Phase 1

**Reviewer**: spec-compliance-reviewer (automated)
**Date**: 2026-06-10
**Handoff**: `.tad/active/handoffs/HANDOFF-20260610-friction-protocol-phase1.md`
**Method**: Per-AC mechanical verification + qualitative placement audit

---

## AC-by-AC Verdict

### AC1: Alex SKILL body contains `tad_friction_protocol` and all five enum values

**Verdict: SATISFIED**

Evidence:
- `tad_friction_protocol` section found at `.agents/skills/alex/SKILL.md` line 698 (body-level, not reference).
- All five enum values verified present via per-anchor `rg -q`:
  - `READY` (line 706)
  - `BLOCKED` (line 707)
  - `DEGRADED_WITH_APPROVAL` (line 708)
  - `EQUIVALENT_SUBSTITUTE` (line 709)
  - `NOT_APPLICABLE_WITH_REASON` (line 710)
- Placement: after `cross_model_awareness.forbidden_implementations` and before `intent_router_protocol`, matching handoff Step 1 concrete placement anchor.
- Also includes: `alex_gate2_obligations`, `anti_rationalization`, `default_action_ladder`, `phase2_deferred`, `forbidden_implementations`.
- Cross-platform: Codex and Claude Code friction explicitly named in `description` block (lines 701-703).
- `.agents/skills/alex/SKILL.md` and `.claude/skills/alex/SKILL.md` are byte-identical (diff confirmed).

### AC2: Blake SKILL body contains `tad_friction_protocol` and says unresolved BLOCKED rows prevent Gate 3 PASS

**Verdict: SATISFIED**

Evidence:
- `tad_friction_protocol` section found at `.agents/skills/blake/SKILL.md` line 305 (body-level).
- All five enum values present in `status_enum` (lines 311-316).
- Gate 3 blocking rule at line 324: `"Unresolved BLOCKED rows prevent Gate 3 PASS -- do not attempt to pass Gate 3 with any BLOCKED friction."` — regex `BLOCKED.*Gate 3.*PASS` matches.
- Self-review prohibition at lines 322, 332: `"Self-review, feedback-integration notes, or a Gate verdict written by Blake are NEVER equivalent substitutes for required expert review."` and `"self-review is NEVER equivalent."`
- Placement: after `cross_model_invocation` reference and before `ralph_loop_execution`, matching handoff Step 2 concrete placement anchor.
- Cross-platform: Codex friction (line 326) and Claude Code friction (line 327) explicitly listed.
- `.agents/skills/blake/SKILL.md` and `.claude/skills/blake/SKILL.md` are byte-identical.

### AC3: Gate SKILL contains Gate 3 Friction Status check and Gate 4 friction review check

**Verdict: SATISFIED**

Evidence:
- **Gate 3**: `Friction_Status_Check` section at line 127, placed after Gate 3 `Prerequisite` block and before `Spec_Compliance_Verification` (line 144), matching handoff Step 3 placement anchor.
  - Contains: `BLOCKED` -> `BLOCK Gate 3` rule (line 134).
  - Contains: `DEGRADED_WITH_APPROVAL` evidence verification (lines 136-138).
  - Contains: `EQUIVALENT_SUBSTITUTE` evidence verification (lines 139-140).
  - Contains: backward compat for pre-Friction-Protocol handoffs (line 131).
  - Contains blocking rule: `"Unresolved BLOCKED row = BLOCK Gate 3"` (line 142).
- **Gate 4**: `Gate4_Friction_Review` section at line 583, placed after Gate 4 `Prerequisite` block and before `Structural_Subagent_Conditionality` (line 598), matching handoff Step 3 placement anchor.
  - Contains: `BLOCKED` -> cannot accept (line 590).
  - Contains: `DEGRADED_WITH_APPROVAL` evidence check (lines 591-592).
  - Contains: `Self-review as substitute for expert review -> REJECT` (line 594).
  - Contains: Alex business-acceptance scope note (line 596).
  - Contains backward compat WARN for missing table (line 587).
- `.agents/skills/gate/SKILL.md` and `.claude/skills/gate/SKILL.md` are byte-identical.

### AC4: Handoff template contains `## 8.4 Friction Preflight` with required columns

**Verdict: SATISFIED**

Evidence:
- `## 8.4 Friction Preflight` found at `.tad/templates/handoff-a-to-b.md` line 478.
- All required columns present in table header (line 484):
  - `Friction Point` -- present
  - `Required Step` -- present
  - `Expected Fix Path` -- present
  - `Allowed Substitute` -- present
  - `Gate Impact` -- present
- Four example rows provided (lines 486-489): reviewer unavailable, dependency install, auth/approval, platform sandbox/network.
- Status enum reference at line 491-492 with all five values.
- Self-review prohibition in example row (line 486): `"self-review is NEVER equivalent"`.
- Cross-platform: Codex and Claude Code mentioned in example row (line 489).
- Placed before `## 9. Acceptance Criteria` (line 496).

### AC5: Completion template contains `## Friction Status (MANDATORY -- Gate 3 BLOCKING)` with required columns

**Verdict: SATISFIED**

Evidence:
- `## Friction Status (MANDATORY -- Gate 3 BLOCKING)` (with warning emoji) found at `.tad/templates/completion-report.md` line 189.
- All required columns present in table header (line 195):
  - `Friction Point` -- present
  - `Status` -- present
  - `Action Taken` -- present
  - `Approval / Substitute Evidence` -- present
  - `Gate Impact` -- present
- Blocking rule at line 200: `"Any unresolved BLOCKED row means Gate 3 cannot PASS."`
- DEGRADED evidence requirements at line 201.
- EQUIVALENT evidence requirements at line 202.
- Self-review prohibition at line 203: `"Self-review is NEVER an equivalent substitute for required expert review."`
- No-friction fallback row guidance at line 204.
- Placed before `## Evidence Checklist (MANDATORY)` (line 208).

### AC6: No new hook/settings/checker script created in Phase 1

**Verdict: SATISFIED**

Evidence:
- `git status --short` shows no files matching `friction-status-check`, `.claude/settings.json`, or `.tad/hooks/.*friction`.
- Modified files are exactly the 6 expected: alex/SKILL.md (x2 mirrors), blake/SKILL.md (x2 mirrors), gate/SKILL.md (x2 mirrors), handoff-a-to-b.md, completion-report.md, NEXT.md.
- Untracked files are: Epic file, handoff directory, decisions JSONL, Alex review evidence -- all expected handoff/evidence artifacts, no checker/hook/settings.
- No `reference:` entry in Alex or Blake SKILL pointing to a friction reference file.

### AC7: NEXT.md references this Epic/Phase 1

**Verdict: SATISFIED**

Evidence:
- NEXT.md line 5: `"EPIC: TAD Friction Protocol -- Phase 1/2 HANDOFF READY 2026-06-10"` with Epic path and handoff path.
- NEXT.md line 6: Phase 2 carry-forward noted: `"after Phase 1 acceptance, create advisory checker for missing Friction Status / blocked-as-pass reports (smoke alarm only; no hook/settings hard block)."` -- preserves Phase 2 visibility per handoff Step 6.

---

## Additional Verification (Beyond ACs)

### Exact Enum Values

**SATISFIED** -- All five values used exactly as specified:
- `READY`
- `BLOCKED`
- `DEGRADED_WITH_APPROVAL`
- `EQUIVALENT_SUBSTITUTE`
- `NOT_APPLICABLE_WITH_REASON`

Verified in: Alex SKILL, Blake SKILL, Gate SKILL (indirectly via status references), handoff template (status enum line), completion template (table placeholder row).

### Self-Review Prohibition

**SATISFIED** -- Explicitly called out in 5 locations:
1. Alex SKILL `EQUIVALENT_SUBSTITUTE` definition (line 709): `"Self-review is NEVER equivalent."`
2. Alex SKILL `anti_rationalization` (line 728): `"self-review is NEVER an equivalent substitute for required expert review."`
3. Blake SKILL `blake_execution_rules` (line 322): `"Self-review, feedback-integration notes, or a Gate verdict written by Blake are NEVER equivalent substitutes."`
4. Blake SKILL `anti_rationalization` (line 332): `"self-review is NEVER equivalent."`
5. Gate SKILL Gate 4 (line 594): `"Self-review as substitute for expert review -> REJECT."`
6. Completion template rules (line 203): `"Self-review is NEVER an equivalent substitute."`
7. Handoff template example row (line 486): `"self-review is NEVER equivalent"`.

### Phase 2 Checker NOT Implemented

**SATISFIED** -- No checker script, hook, or settings change exists. Both Alex and Blake SKILL contain `phase2_deferred` noting this is intentional.

### Protocol in SKILL Body (Not Only References)

**SATISFIED** -- All three SKILL files contain the friction protocol as inline body-level YAML sections. No `reference:` + `load_when:` pattern is used for friction protocol. This avoids the circular-trigger failure documented in `principles.md`.

### Cross-Platform Friction Mentioned

**SATISFIED** -- Both Codex and Claude Code friction types are explicitly listed:
- Alex SKILL description (lines 701-703): Codex (sandbox approval, network restriction, auth expiry, dependency install escalation, subagent/tool availability) and Claude Code (tool permission prompts, plugin/hook availability, subagent quota/refusal).
- Blake SKILL execution rules (lines 326-327): same Codex and Claude Code friction categories.
- Handoff template example row (line 489): `"Request sandbox approval (Codex) or permission (Claude Code)"`.

### Mirror Consistency

**SATISFIED** -- `.agents/skills/` and `.claude/skills/` are byte-identical for all three SKILL files (diff confirmed for alex, blake, gate).

---

## Overall Verdict

**PASS** -- All 7 ACs satisfied. All additional verification checks pass. No issues found.

| AC | Status | Notes |
|----|--------|-------|
| AC1 | SATISFIED | Alex body: protocol + 5 enum values + Gate 2 obligations + cross-platform |
| AC2 | SATISFIED | Blake body: protocol + 5 enum values + BLOCKED/Gate 3 rule + self-review prohibition |
| AC3 | SATISFIED | Gate 3 Friction_Status_Check + Gate 4 Gate4_Friction_Review, correct placement |
| AC4 | SATISFIED | Handoff template 8.4 with all 5 required columns + 4 examples |
| AC5 | SATISFIED | Completion template with all 5 required columns + blocking rule + self-review prohibition |
| AC6 | SATISFIED | No checker/hook/settings created |
| AC7 | SATISFIED | NEXT.md line 5-6 with Epic reference and Phase 2 carry-forward |
