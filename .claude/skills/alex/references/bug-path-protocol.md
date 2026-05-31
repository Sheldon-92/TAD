<!-- Extracted from alex/SKILL.md P3 progressive disclosure 2026-05-31. Byte-identical to the original block. -->

bug_path_protocol:
  description: "Quick bug diagnosis → express mini-handoff to Blake"
  trigger: "Intent Router routes to bug mode"

  # ⚠️ NO code exemption — Alex NEVER writes implementation code, even for bugs
  code_policy: "diagnose_only"

  execution:
    step1:
      name: "Understand the Bug"
      action: |
        Ask user to describe the bug:
        - What happened? (symptoms)
        - What was expected?
        - When does it happen? (steps to reproduce)
        If user provides enough info, proceed. If not, ask clarifying questions.

    step2:
      name: "Diagnose"
      action: |
        Read relevant code files.
        Optionally call bug-hunter subagent for complex issues.
        Identify root cause and affected files.
        Output diagnosis to user:
        - Root cause
        - Affected files
        - Proposed fix approach
        - Severity assessment (simple / complex)

    step3:
      name: "Propose Action"
      action: |
        Use AskUserQuestion:
        "I've diagnosed the issue. How would you like to proceed?"
        Options:
        - "Create express mini-handoff for Blake" → step4_handoff
        - "I understand now, I'll handle it myself" → step5_record
        - "This is bigger than a bug — start *analyze" → transition to analyze path

    step4_handoff:
      name: "Generate Express Mini-Handoff"
      action: |
        Create a lightweight handoff in .tad/active/handoffs/HANDOFF-{date}-bugfix-{slug}.md

        Mini-handoff template:
        ```
        # Mini-Handoff: Bugfix — {title}
        **From:** Alex | **To:** Blake | **Date:** {date}
        **Type:** Express Bugfix (skip Socratic, skip expert review)
        **Priority:** {P0/P1/P2}

        ## Bug Description
        {user's description + symptoms}

        ## Root Cause Analysis
        {Alex's diagnosis from step2}

        ## Proposed Fix
        {specific changes: file, line range, what to change}

        ## Affected Files
        {list of files}

        ## Acceptance Criteria
        - [ ] Bug no longer reproduces under reported conditions
        - [ ] No regression in related functionality

        ## Blake Instructions
        - This is an express bugfix — no Socratic inquiry or expert review needed
        - Apply fix → run Ralph Loop Layer 1 (self-check) → verify AC → done
        - If fix turns out to be more complex than described, escalate to user
        ```

        Generate Blake message (same format as standard handoff step7).

    step5_record:
      name: "Record"
      action: |
        If mini-handoff created:
          Add to NEXT.md In Progress: "- [ ] Bugfix: {description} (mini-handoff to Blake)"
        If user handled it themselves:
          No action needed (user manages their own work)

# *discuss Path Protocol
