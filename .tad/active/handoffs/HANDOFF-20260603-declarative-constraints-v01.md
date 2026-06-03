---
task_type: yaml
e2e_required: no
research_required: no
git_tracked_dirs: [".claude/skills/alex"]
skip_knowledge_assessment: no
gate4_delta: []
---

# Handoff Document for Agent B (Blake)
## TAD v3.1 - Evidence-Based Development

**From:** Alex (Agent A - Solution Lead)
**To:** Blake (Agent B - Execution Master)
**Date:** 2026-06-03
**Project:** TAD Framework
**Task ID:** TASK-20260603-001
**Handoff Version:** 3.1.0
**Epic:** N/A

---

## Gate 2: Design Completeness

**Execution time**: 2026-06-03

| Check Item | Status | Note |
|-----------|--------|------|
| Architecture Complete | OK | Tournament-validated schema v0.2 (post expert-review fixes) |
| Components Specified | OK | Primary: alex/SKILL.md. Also: parity-criterion.md pin update |
| Functions Verified | OK | grep/yq audit commands verified against baseline |
| Data Flow Mapped | OK | Dual presence: frontmatter (structured) + body (judgment text) |

**Gate 2 Result**: PASS (v2 — after P0 fixes from expert review round 1)

**Alex Confirmation**: Design is tournament-validated. Blake can implement from this document alone.

---

## Handoff Checklist (Blake must read)

- [ ] Read all sections
- [ ] Read Project Knowledge section
- [ ] Understand SAFETY constraints (grep count MUST NOT change)
- [ ] Confirm can implement from this document alone

---

## 1. Task Overview

Extract 11 repeated `forbidden_implementations` blocks from alex/SKILL.md body into structured YAML frontmatter. Replace body text with `judgment_ref` cross-references that preserve grep-auditable strings. Net result: SKILL.md body shrinks, mechanical constraints stated once, judgment guidance stays as prose.

**Why now:** Session discovered that alex/SKILL.md has 11 forbidden_implementations blocks (lines 540-4355) repeating nearly identical 5-line patterns. Tournament experiment (7 agents, 322K tokens) produced a validated schema design. The "thin protocol, thick tools" direction makes this the right time.

---

## 2. Requirements

### Functional
- FR1: Add YAML frontmatter `constraints:` block to top of alex/SKILL.md with global `deny` rules and per-section `section_overrides`
- FR2: Replace each of the 11 `forbidden_implementations:` body blocks with a compact `judgment_ref` + judgment-only lines
- FR3: Preserve dual presence: every constraint string currently grepable MUST remain grepable after migration (in frontmatter OR body)
- FR4: Add `migration.provenance` table mapping old line ranges to new frontmatter locations

### Non-Functional
- NFR1: SAFETY — `grep -c 'NOT_via_alex_auto\|forbidden_implementations'` MUST return == 20 (baseline 19 + 1 frontmatter NOT_via_alex_auto dual-presence anchor)
- NFR2: DEDUP — the number of mechanical deny lines in the SKILL.md body (lines containing "MUST NOT register" OR "MUST NOT add to .claude/settings.json" OR "MUST NOT return deny exit code") MUST decrease by >= 20 from baseline. Note: total file length will INCREASE (~+100 lines from frontmatter, ~-33 from body dedup). The value is cognitive deduplication, not line count reduction.
- NFR3: No behavior change — Alex agent behavior must be identical before and after migration

---

## 3. Technical Design

### Schema v0.2 (tournament merged design + expert review P0 fixes)

**P0-FIX-1 (frontmatter merge):** The existing SKILL.md has a 3-line frontmatter block (`name: alex`, `description: ...`). The `description` value contains unquoted `>3` and `*bug` which are invalid YAML. Blake MUST:
1. Quote the existing `description` value with double quotes
2. Merge the new constraints block INTO the same `---...---` frontmatter block
3. Verify `yq --front-matter=extract '.' .claude/skills/alex/SKILL.md` parses without error

**P0-FIX-2 (no SAFETY literal strings in frontmatter):** `deny_ref` replaces `judgment_ref` to avoid `forbidden_implementations` literal string in frontmatter values. This prevents: (a) grep count inflation, (b) codex-parity-check.sh awk parser confusion.

Add this INSIDE the existing frontmatter delimiters:

```yaml
---
name: alex
description: "TAD Solution Lead (Agent A). Use for new features (>3 files), architecture changes, complex multi-step requirements, multi-module refactoring. Supports modes: *bug, *discuss, *idea, *learn, *publish, *sync, *playground."
constraints_schema: "v0.2"

constraints:
  enforcement: prompt-level-only

  deny:
    hook_registration: [PreToolUse, PostToolUse, UserPromptSubmit, SessionStart]
    settings_modification:
      paths: [".claude/settings.json"]
      actions: [add, modify, register]
    hook_scripts:
      paths: [".tad/hooks/*.sh"]
      actions: [create, modify]
    exit_codes:
      deny_exit_codes: true
    tool_blocking:
      never_block: [Write, Edit, Read]

  cross_model:
    auto_invoke: false
    NOT_via_alex_auto: true  # AR-001 grep anchor — DO NOT remove
    delegation_requires: user_confirmation
    exceptions:
      - scope: "research_plan.phase_0c_4c_5b"
        action: auto_invoke
        condition: "display+overridable"
        authority: "DR-20260531"
      - scope: "research_plan.complexity_ladder"
        action: suggest_default
        condition: "display+overridable"
        authority: "DR-20260531"

  section_overrides:
    cross_model_awareness:
      deny_ref: "L540"
      deny_extra:
        - action: couple
          target: cross_model_invocation
          with: [skip_knowledge_assessment, express_path]
        - action: bypass
          target: socratic_inquiry
          via: cross_model_delegation

    express_path:
      deny_ref: "L1626"
      deny_extra:
        - action: interpret
          pattern: "express = review-exempt"
          label: Anti-AR-001
        - action: auto_downgrade
          from: standard_tad
          to: express

    experiment_path:
      deny_ref: "L1772"
      deny_extra:
        - action: replace_silently
          target: gate_3_4
        - action: bypass
          target: socratic_inquiry
          via: experiment_shortcut

    step1c_grounding:
      inherits_global: true

    step0_graph:
      deny_ref: "L2915"
      deny_extra:
        - action: auto_index
          target: repository
        - action: block_on_failure
          target: graph_probe

    step1c_lsp:
      inherits_global: true

    step1d_ac_dryrun:
      deny_ref: "L3095"
      deny_extra:
        - action: skip
          rationalizations: ["small handoff = step1d skippable", "all post-impl so step1d value-less"]
        - action: promote_to_blocking_gate
          target: verify-ac-commands.sh

    skip_knowledge_assessment:
      deny_ref: "L4111"
      deny_extra:
        - action: auto_inject_override
          via: hook
        - action: couple
          target: skip_KA
          with: layer2_audit_step4c

    gate4_delta:
      deny_ref: "L4159"
      deny_extra:
        - action: auto_populate
          via: [hook, script]
        - action: block
          target: accept_command
          on: gate4_delta_presence_absence

    skillify:
      deny_ref: "L4232"
      deny_extra:
        - action: auto_accept
          target: candidates
        - action: create_directly
          target: ".claude/skills/{slug}/SKILL.md"
        - action: call_from
          terminal: blake
        - action: auto_invoke
          without: explicit_user_command

    cancel_protocol:
      deny_ref: "L4350"
      deny_extra:
        - action: auto_downgrade
          from: standard_tad
          to: cancel
        - action: interpret
          pattern: "cancel = silent abandonment"
          label: Anti-AR-001
        - action: couple
          target: cancel
          with: skip_knowledge_assessment

  migration:
    source_baseline: { lines: 6145, grep_count: 19 }
    expected_post_migration_grep_count: 20  # +1 from frontmatter NOT_via_alex_auto anchor
    migrated_blocks: 11
    provenance:
      cross_model_awareness: { old_line: 540 }
      express_path: { old_line: 1626 }
      experiment_path: { old_line: 1772 }
      step1c_grounding: { old_line: 2878 }
      step0_graph: { old_line: 2915 }
      step1c_lsp: { old_line: 3016 }
      step1d_ac_dryrun: { old_line: 3095 }
      skip_knowledge_assessment: { old_line: 4111 }
      gate4_delta: { old_line: 4159 }
      skillify: { old_line: 4232 }
      cancel_protocol: { old_line: 4350 }
---
```

### Body Migration Pattern (per section)

**BEFORE** (example: cancel_protocol, lines 4345-4355):
```yaml
  enforcement: "prompt-level-only"

  # P5.3 BA-P0-3: symmetric forbidden_implementations 5-item block
  forbidden_implementations:
    - "MUST NOT register PreToolUse / PostToolUse / UserPromptSubmit hook to auto-trigger *cancel"
    - "MUST NOT add to .claude/settings.json"
    - "MUST NOT couple *cancel to skip_knowledge_assessment ..."
    - "Anti-AR-001: '*cancel = silent abandonment' is a forbidden interpretation ..."
    - "MUST NOT auto-downgrade Standard TAD handoff to *cancel via any mechanism ..."
```

**AFTER**:
```yaml
  enforcement: "prompt-level-only"  # See constraints.enforcement (global)
  # Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.cancel_protocol
  forbidden_implementations:
    - "Anti-AR-001: '*cancel = silent abandonment' is a forbidden interpretation — both reason taxonomy AND rationale text are mandatory"
    - "MUST NOT auto-downgrade Standard TAD handoff to *cancel via any mechanism (no Alex AskUserQuestion suggestion, no signal-word auto-detection)"
    - "MUST NOT couple *cancel to skip_knowledge_assessment (cancelled handoffs bypass Gate 4 by design but MUST still write cancel_reason + cancel_rationale)"
```

**What changes per section:**
- `enforcement:` line gets a comment pointing to frontmatter (no longer standalone declaration)
- Mechanical items removed: "MUST NOT register hook" + "MUST NOT add to settings.json" (covered by global deny)
- Judgment items STAY: AR-001 interpretation, auto-downgrade, coupling (LLM needs the prose context)
- `forbidden_implementations:` header STAYS (preserves grep count)

**Net per section:** ~2-3 mechanical lines removed, header + judgment lines stay.

### Special Cases

**cross_model_awareness (line 540):** 6 items. Items 1-2 are mechanical (hook + settings.json). Items 3-6 are judgment-heavy (DR-20260531 carve-out prose). Remove 2, keep 4.

**step1d_ac_dryrun (line 3095):** 6 items, not 5 (P0-4 fix). Items 1-4 are mechanical (hook, scripts, exit code, tool blocking). Item 5 is judgment (AR-001 rationalization about skipping). Item 6 is HYBRID — contains both mechanical deny (no hook registration for verify-ac-commands.sh) and judgment (advisory smoke alarm rationale). Split: mechanical portion already covered by global deny; keep full text of item 6 as judgment in body (the rationale is load-bearing).

**step1c_grounding (line 2878):** 6 items. Items 1-5 are mechanical. Item 6 ("violation level mirrors anti_rationalization_registry: prompt-only enforcement") is a policy statement. Keep it in body as a comment:
```yaml
  # Mechanical deny: see constraints.deny (global) + constraints.section_overrides.step1c_grounding (inherits_global)
  forbidden_implementations:
    - "MUST NOT register hooks or modify settings — see constraints.deny (global)"
    - "violation level mirrors anti_rationalization_registry: prompt-only enforcement"
```
P1-1 fix: NOT empty array. Keep one MUST NOT redirect + the policy statement. LLM sees a non-empty list, not "nothing forbidden."

**step1c_lsp (line 3016):** 5 items, all mechanical. Same pattern as step1c_grounding:
```yaml
  forbidden_implementations:
    - "MUST NOT register hooks or modify settings — see constraints.deny (global)"
```

**step0_graph (line 2915):** 3 items. Item 1 (auto_index) is domain-specific judgment. Item 2 (settings.json) is mechanical (covered by global deny). Item 3 (<500ms budget) is performance constraint (judgment). Remove item 2, keep items 1 and 3:
```yaml
  forbidden_implementations:
    - "MUST NOT auto-index the repository (TAD never triggers indexing)"
    - "MUST NOT block or slow down if graph probe fails (strict <500ms budget)"
```

---

## 4. Files to Modify

| File | Action | Scope |
|------|--------|-------|
| `.claude/skills/alex/SKILL.md` | MODIFY | Fix existing frontmatter YAML + add constraints block + migrate 11 body blocks |
| `.tad/hooks/lib/parity-criterion.md` | MODIFY | Update pin table to reflect skillify addition (pre-existing drift P1-6) |

**Grounded Against** (Alex step1c, all 11 blocks read 2026-06-03):
- .claude/skills/alex/SKILL.md line 1-4 (existing frontmatter — broken YAML confirmed)
- .claude/skills/alex/SKILL.md line 540 (cross_model_awareness — 6 items, 2 mechanical + 4 judgment)
- .claude/skills/alex/SKILL.md line 1626 (express_path — 5 items standard)
- .claude/skills/alex/SKILL.md line 1772 (experiment_path — 5 items standard)
- .claude/skills/alex/SKILL.md line 2878 (step1c_grounding — 6 items, 5 mechanical + 1 policy)
- .claude/skills/alex/SKILL.md line 2915 (step0_graph — 3 items, 1 mechanical + 2 judgment)
- .claude/skills/alex/SKILL.md line 3016 (step1c_lsp — 5 items, all mechanical)
- .claude/skills/alex/SKILL.md line 3095 (step1d_ac_dryrun — 6 items, 4 mechanical + 2 judgment/hybrid)
- .claude/skills/alex/SKILL.md line 4111 (skip_knowledge_assessment — 5 items standard)
- .claude/skills/alex/SKILL.md line 4159 (gate4_delta — 5 items standard)
- .claude/skills/alex/SKILL.md line 4232 (skillify — 4+1 items)
- .claude/skills/alex/SKILL.md line 4350 (cancel_protocol — 5 items standard)

---

## 5. Acceptance Criteria

### 5.1 Spec Compliance Checklist

| AC | Requirement | Verification Method | Expected Evidence |
|----|------------|--------------------|--------------------|
| AC1 | SAFETY: grep count preserved | `grep -c 'NOT_via_alex_auto\|forbidden_implementations' .claude/skills/alex/SKILL.md` | == 20 (baseline 19 + 1 new frontmatter NOT_via_alex_auto anchor = 20. All 19 original lines preserved; 1 added as dual-presence redundancy) |
| AC2 | Frontmatter parseable | `yq --front-matter=extract '.constraints.deny.hook_registration' .claude/skills/alex/SKILL.md` | Returns `[PreToolUse, PostToolUse, UserPromptSubmit, SessionStart]` |
| AC3 | All 11 provenance entries | `yq --front-matter=extract '.constraints.migration.migrated_blocks' .claude/skills/alex/SKILL.md` | Returns 11 |
| AC4 | AR-001 anchor survives in both locations | `grep -c 'NOT_via_alex_auto' .claude/skills/alex/SKILL.md` | >= 2 (one in frontmatter, one in body L538) |
| AC5 | No behavior change | Load /alex in a fresh session, run *help, verify all commands respond | Commands work as before |
| AC6 | deny_ref cross-references | For each section_override with `deny_ref: "L{N}"`: grep body line N confirms `forbidden_implementations:` header exists | All 9 deny_ref anchors resolve |
| AC7 | No empty forbidden_implementations arrays | `grep -c 'forbidden_implementations: \[\]' .claude/skills/alex/SKILL.md` | == 0 (P1-1 fix: every section keeps >=1 item) |
| AC8 | Existing frontmatter valid YAML | `yq --front-matter=extract '.' .claude/skills/alex/SKILL.md 2>&1` | Exit 0, no parse errors |
| AC9 | Parity criterion pin updated | `grep 'PIN:alex' .tad/hooks/lib/parity-criterion.md` | NOT_via_alex_auto pin = 6 (was 5, +1 frontmatter anchor). forbidden_implementations pin unchanged |

### AC Dry-Run Log (Alex step1d):
- AC1: Pre-impl-verifiable. `grep -c 'NOT_via_alex_auto\|forbidden_implementations' .claude/skills/alex/SKILL.md` = 19. Verified.
- AC2: Post-impl-verifiable. `yq --front-matter=extract` syntax validated with `bash -n`.
- AC3: Post-impl-verifiable. yq command syntax-validated.
- AC4: Pre-impl-verifiable. `grep -c 'NOT_via_alex_auto' .claude/skills/alex/SKILL.md` = 4 (current body has 4 occurrences). Post-migration expect >= 5. Verified baseline.
- AC5: Post-impl-verifiable. Manual test.
- AC6: Post-impl-verifiable. grep per deny_ref line number.
- AC7: Post-impl-verifiable. grep for empty arrays.
- AC8: Post-impl-verifiable. yq parse test.
- AC9: Post-impl-verifiable. grep pin table.

---

## 6. Important Notes

### 6.1 SAFETY Rules
- **Path Layering principle (2026-04-24):** `grep -c` SAFETY count is a smoke alarm. Body text is where the LLM reads constraints. Frontmatter is structured backup. BOTH must survive.
- **Rewiring Gate Prose principle (2026-05-31):** When rewording prose that cites a constraint, RETAIN the constraint citation. This is why `forbidden_implementations:` headers stay even when items migrate.
- **Judgment-Only Skill Files (2026-04-04):** Constraint rules MUST survive slimming. This migration moves mechanical rules to frontmatter but KEEPS judgment rules in body.

### 6.2 What NOT to do
- DO NOT delete any `forbidden_implementations:` key from body (breaks grep count)
- DO NOT move judgment items (AR-001 interpretations, coupling rules) out of body (LLM needs the prose context)
- DO NOT use `forbidden_implementations: []` empty arrays (LLM reads empty array as "nothing forbidden" — keep >=1 item per P1-1)
- DO NOT use the literal string `forbidden_implementations` in any frontmatter value (use `deny_ref` instead — prevents grep inflation + codex-parity-check.sh breakage)
- DO NOT add `scope:` or `limits:` blocks (deferred to phase 2 per Socratic agreement)
- DO NOT touch blake/SKILL.md (Alex only per Socratic agreement)
- DO NOT touch the `anti_rationalization_registry` section (lines 6081-6146, delimited by `<!-- anti_rationalization_registry:BEGIN/END -->` markers — this section has its own extraction contract and is NOT part of this migration)
- DO NOT create a second `---...---` frontmatter block — merge into the existing one

---

## 7. Project Knowledge

### Blake must note:
- **Path Layering principle**: grep count is smoke alarm, line-set diff is ground truth
- **Rewiring Gate Prose principle**: keep constraint name in reworded text
- **Judgment-Only Skill Files**: constraint rules != mechanical logic

---

## 8. Decision Summary

| # | Decision | Options Considered | Chosen | Rationale |
|---|----------|-------------------|--------|-----------|
| 1 | Schema location | Frontmatter / Separate file / settings.json | Frontmatter in SKILL.md | Tournament winner (2-0). Single file, grep-able, prompt-visible |
| 2 | SAFETY strategy | Dual presence / Migrate grep to yq | Dual presence | Redundant but safe. grep audit unchanged, yq adds structured query |
| 3 | MVP scope | All 3 layers / deny+overrides / deny only | deny + section_overrides | Core value (dedup) without scope/limits complexity |
| 4 | Migration per section | Remove block / Empty array / Keep judgment | Keep judgment items + empty mechanical | Preserves grep count + LLM context |

Tournament evidence: `.tad/evidence/research/2026-06-03-tournament-declarative-constraints-result.md`

---

## 9. Required Evidence Manifest

```yaml
expert_reviews:
  - path: .tad/evidence/reviews/blake/declarative-constraints-v01/code-review.md
    required: true
  - path: .tad/evidence/reviews/blake/declarative-constraints-v01/spec-compliance.md
    required: true
gate_verdicts:
  - path: .tad/evidence/reviews/blake/declarative-constraints-v01/gate3-verdict.md
    required: true
completion:
  - path: .tad/active/handoffs/COMPLETION-20260603-declarative-constraints-v01.md
    required: true
knowledge_updates:
  - path: .tad/project-knowledge/patterns/declarative-constraints.md
    required: false
```
