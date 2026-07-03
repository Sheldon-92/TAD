# Workflow Completion Trigger (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

workflow_completion_trigger:
  description: "Lightweight three-question assessment after significant workflow execution"
  trigger: "Workflow tool returns result with usage.agent_count >= 3"
  blocking: false
  action: |
    After a Workflow tool call completes with agent_count >= 3:
    1. Q1 (knowledge): "Did this workflow execution reveal something new?"
       → If yes: record to .tad/project-knowledge/ (same as Gate 4 C)
    2. Q2 (skill): "Did the workflow expose a reusable judgment pattern?"
       → If yes: auto-generate SCAND (see auto_gen_scand below)
         with type: judgment
    3. Q3 (workflow): "Should this workflow be improved based on what just happened?"
       → If yes (defect): record for future bugfix handoff
       → If yes (new pattern): auto-generate SCAND (see auto_gen_scand below)
         with type: orchestration
    
    Lightweight = 1 AskUserQuestion with 3 sub-questions, not 3 separate interactions.
    Skip if workflow was a TAD framework management task (*publish, *sync).

  auto_gen_scand:
    trigger: "Q2 or Q3 answered 'yes' for reusable pattern"
    steps:
      1. Extract pattern from workflow context:
         - What agents were spawned and in what order
         - What each agent's prompt/task was (abstract to pattern, not literal text)
         - What the overall pipeline achieved
      2. Variabilize: replace episode-specific values with placeholders
         (per Knowledge Recording principle: "reusability is a mechanical test —
          can you variabilize the episode-specific values?")
         Examples: specific file paths → {target_file}, specific pack names → {pack_name}
      3. Generate SCAND using template .tad/templates/skillify-candidate-template.md.
         Complete frontmatter field mapping:
         
         | Field | Value | Source |
         |-------|-------|--------|
         | name | derive kebab-case slug from pattern | auto |
         | date | current date YYYY-MM-DD | auto |
         | status | draft | CONSTRAINT: discoverer MUST NOT set beyond draft |
         | type | judgment (Q2) or orchestration (Q3) | from question path |
         | tier | ~ | CONSTRAINT: set ONLY by *harvest, NEVER by discoverer |
         | materialized_at | ~ | T1 ceremony only |
         | reference_at | ~ | T2 harvest only |
         | source | "workflow-completion:{workflow-name}" | new convention for auto-gen |
         | trigger_conditions | derived from pattern — when would this apply? | extracted from workflow context |
         | reusable | ~ | auto-gen skips 4-gate; *harvest evaluates |
         | non_trivial | ~ | auto-gen skips 4-gate; *harvest evaluates |
         | verified | ~ | auto-gen skips 4-gate; *harvest evaluates |
         | not_already_captured | ~ | auto-gen skips 4-gate; *harvest evaluates |
         
         Body sections:
         - ## Pattern: {pattern name} — from workflow pattern
         - ### When to Use — from trigger_conditions
         - ### Steps — extracted + variabilized workflow pattern
         - ### Quality Criteria — from workflow success criteria
         - ### Anti-Patterns — from workflow failure modes (if observed)
         - ## Evidence — link to the workflow run
         - ## Proposed Skill Outline — name + description (Anthropic-standard ≤1024, third-person, "what + when")

      4. Write to .tad/active/skillify-candidates/SCAND-{date}-{slug}-{type}.md
         (type suffix prevents collision when both Q2 and Q3 generate SCANDs)
      5. Report: "📋 SCAND auto-generated: {slug}-{type}. Review via *harvest."
    
    skip_option: "User can say 'skip' at the Q2/Q3 AskUserQuestion to skip auto-gen"
    
    variabilize_test: |
      Before writing the SCAND, apply the variabilize test:
      "Can I replace every episode-specific value with a placeholder and
       the pattern still makes sense for a DIFFERENT task?"
      If NO → don't write SCAND, report: "Pattern is too episode-specific to reuse."
    
    dual_yes_handling: |
      When both Q2 AND Q3 are "yes": generate two SCANDs with different type suffixes.
      Each SCAND's Evidence section cross-references the other:
      "See also SCAND-{date}-{slug}-{other-type}.md from same workflow run."
  threshold_rationale: |
    agent_count >= 3 filters out trivial 2-agent workflows (e.g., simple parallel search).
    All 5 current production workflows use >= 3 agents — threshold validated against existing corpus.
  agent_count_source: |
    agent_count comes from the Workflow tool's TASK-NOTIFICATION envelope
    (<usage><agent_count>N</agent_count></usage>), NOT from the workflow
    script's return value. The runtime provides this automatically for every
    workflow run. Alex reads it from the notification, not from the .workflow.js.

