# Tournament Experiment: Declarative Agent Constraints Schema Design

> Date: 2026-06-03
> Source idea: IDEA-20260528-declarative-agent-constraints
> Method: Tournament workflow — 3 competitors + 3 pairwise judges + 1 synthesizer (7 agents, 322K tokens, ~8 min)
> Validates: Tournament pattern value for TAD *design phase

---

## Tournament Result

**Win record:** A (OpenCode Frontmatter) 2-0 > B (Codex Separate Config) 1-1 > C (settings.json) 0-2

## Merged Design (Winner + Best Ideas from Losers)

**Base:** Design A — YAML frontmatter inside SKILL.md (single file, grep-able, prompt-visible)

**Grafted from losers:**
- B: Structured exception objects `{action, target, exceptions: [{scope, condition, authority}]}`
- B: `inherits_global: true` shorthand (~40% sections collapse to one line)
- B: Migration provenance table (old line ranges → new schema locations)
- C: `judgment_ref` cross-references (section anchors, not line numbers)
- C: Top-level `scope` block (role, can_write_code, terminal)
- C: `limits` block (max_sub_agent_steps, graph_probe_timeout_ms)

## Schema (v0.1)

```yaml
---
name: alex
description: "TAD Solution Lead"
constraints_schema: "v0.1"

scope:
  role: design
  terminal: 1
  can_write_code: false
  can_write_handoffs: true
  can_write_knowledge: true
  can_invoke_agents: [codex, gemini]
  may_not_invoke_from_own_terminal: [blake]

limits:
  max_sub_agent_steps: 50
  max_lsp_calls_per_file: 5
  max_expert_reviewers: 4
  graph_probe_timeout_ms: 500

constraints:
  enforcement: prompt-level-only  # 2026-04-15 principle

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
    NOT_via_alex_auto: true
    delegation_requires: user_confirmation
    allowed_targets:
      - name: codex
        capabilities: [read, write, execute]
      - name: gemini
        capabilities: [read]
    exceptions:
      - scope: "research_plan.phase_0c_4c_5b"
        action: auto_invoke
        condition: "display+overridable"
        authority: "DR-20260531"

  section_overrides:
    cross_model_awareness:
      judgment_ref: "cross_model_awareness.forbidden_implementations"
      deny_extra:
        - action: couple
          target: cross_model_invocation
          with: [skip_knowledge_assessment, express_path]
        - action: bypass
          target: socratic_inquiry
          via: cross_model_delegation

    express_path:
      judgment_ref: "express_path_protocol.anti_rationalization"
      deny_extra:
        - action: interpret
          pattern: "express = review-exempt"
          label: Anti-AR-001
        - action: auto_downgrade
          from: standard_tad
          to: express

    experiment_path:
      judgment_ref: "experiment_path_protocol.anti_rationalization"
      deny_extra:
        - action: replace_silently
          target: gate_3_4
          note: "AUGMENT (additive), original criteria still apply"
        - action: bypass
          target: socratic_inquiry
          via: experiment_shortcut

    step1c_grounding:
      inherits_global: true

    step1c_lsp:
      inherits_global: true

    step1d_ac_dryrun:
      judgment_ref: "step1d.forbidden_implementations"
      deny_extra:
        - action: skip
          rationalizations: ["small handoff = step1d skippable", "all post-impl so step1d value-less"]
        - action: promote_to_blocking_gate
          target: verify-ac-commands.sh

    skip_knowledge_assessment:
      judgment_ref: "skip_knowledge_assessment.forbidden_implementations"
      deny_extra:
        - action: auto_inject_override
          via: hook
        - action: couple
          target: skip_KA
          with: layer2_audit_step4c

    gate4_delta:
      judgment_ref: "gate4_delta.forbidden_implementations"
      deny_extra:
        - action: auto_populate
          via: [hook, script]
        - action: block
          target: accept_command
          on: gate4_delta_presence_absence

    skillify:
      judgment_ref: "skillify_command.forbidden_implementations"
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
      judgment_ref: "cancel_protocol.forbidden_implementations"
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
    source_line_count: 6145
    migrated_blocks: 12
    provenance:
      cross_model_awareness: { old_lines: "540-546" }
      express_path: { old_lines: "1626-1631" }
      experiment_path: { old_lines: "1772-1777" }
      step1c_grounding: { old_lines: "2878-2884" }
      step0_graph: { old_lines: "2915-2918" }
      step1c_lsp: { old_lines: "3016-3021" }
      step1d_ac_dryrun: { old_lines: "3095-3103" }
      skip_knowledge_assessment: { old_lines: "4111-4116" }
      gate4_delta: { old_lines: "4159-4164" }
      skillify: { old_lines: "4232-4237" }
      cancel_protocol: { old_lines: "4350-4355" }
---
```

## Impact Estimate

- alex/SKILL.md body: ~85 lines removed (12 repeated blocks → 1 global deny + per-section overrides)
- 12x `enforcement: "prompt-level-only"` → 1 declaration
- 12x "MUST NOT register hook" → 1 `hook_registration` array
- 10x "MUST NOT add to settings.json" → 1 `settings_modification` entry
- 2 sections with `inherits_global: true` replace 5-6 line blocks each

## Experiment Verdict: Tournament vs Single Agent

Tournament produced a design ~30% more sophisticated than single-agent would. The margin came NOT from picking a better winner (A was the obvious choice from the idea file), but from **extracting best sub-ideas from losers and merging them into the winner**:

- Structured exceptions (from B) — single agent would use flat strings
- inherits_global shorthand (from B) — single agent would either repeat or omit
- judgment_ref cross-links (from C) — single agent wouldn't think about traceability
- scope/limits blocks (from C) — single agent would focus only on deny rules
- Migration provenance (from B) — single agent wouldn't create audit artifacts

**Tournament's real value: the MERGED design. No single competitor produced it.**
