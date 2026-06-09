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
       → If yes: Skillify 4-gate + Step 5 (same path)
    3. Q3 (workflow): "Should this workflow be improved based on what just happened?"
       → If yes (defect): record for future bugfix handoff
       → If yes (new pattern): write SCAND candidate with type: orchestration
    
    Lightweight = 1 AskUserQuestion with 3 sub-questions, not 3 separate interactions.
    Skip if workflow was a TAD framework management task (*publish, *sync).
  threshold_rationale: |
    agent_count >= 3 filters out trivial 2-agent workflows (e.g., simple parallel search).
    All 5 current production workflows use >= 3 agents — threshold validated against existing corpus.
  agent_count_source: |
    agent_count comes from the Workflow tool's TASK-NOTIFICATION envelope
    (<usage><agent_count>N</agent_count></usage>), NOT from the workflow
    script's return value. The runtime provides this automatically for every
    workflow run. Alex reads it from the notification, not from the .workflow.js.

