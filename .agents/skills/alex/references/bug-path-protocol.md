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
        When the bug is in an accepted result (an archived handoff or a completed Epic), write one escape-log line with the diagnosis into `.tad/evidence/escape-log.md` (created from `.tad/templates/escape-log.md` when absent; its rule table names the gate that should have caught it).
        Identify root cause and affected files.
        Output diagnosis to user:
        - Root cause
        - Affected files
        - Proposed fix approach
        - Severity assessment (simple / complex)

    step3:
      name: "Propose Action"
      action: |
        <!-- Platform binding: interactive-decision tool or numbered-options text（见平台绑定交互决策条款） -->
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
        ---
        express: true
        task_type: code
        risk_triggers: [none]   # Alex fills: closed list in .tad/templates/review-contract.md §5 (security | data | money | ui | platform | domain, or none)
        real_paths:
          - id: RP1
            path: "the reported symptom's path"
            run: "{repro command}"
        ---
        # Mini-Handoff: Bugfix — {title}
        **From:** Alex | **To:** Blake | **Date:** {date}
        **Type:** Express Bugfix (requirement playback confirmed; no Gate 2 — the fix is named by the diagnosis; Gate 3 reviewers per .tad/templates/review-contract.md)
        **Priority:** {P0/P1/P2}

        ## Bug Description
        {user's description + symptoms}

        ## Root Cause Analysis
        {Alex's diagnosis from step2}

        ## Proposed Fix
        {specific changes: file, line range, what to change}

        ## Affected Files
        {list of files}

        ## 9.1 Spec Compliance Checklist
        Mini-handoff AC must include a legal runnable Verification Method — mini-handoff includes §9.1 Spec Compliance Checklist (one row is enough; without this table Gate 3 empty-guard BLOCKS and the Method can never be checked).
        | # | Acceptance Criterion | Verification Type | Verification Method | Expected Evidence | Verified Output |
        |---|---------------------|-------------------|---------------------|-------------------|-----------------|
        | 1 | Reported symptom fixed, no related regression | post-impl-verifiable | `{repro command or failing-then-passing test, e.g. pytest tests/test_slug.py -k bugfix}` | exit 0, symptom gone under reported conditions | (post-impl) |

        ## Blake Instructions
        - This is an express bugfix — requirement clarification was a playback (no unclear block)
        - Apply fix → Layer 1 → commit → Gate 3 reviewers run + consistency (+ domain if security/data/money) per the review contract → then Alex `*accept` (Gate 4 acceptor, runs the reported repro)
        - If fix turns out to be more complex than described, escalate to Alex
        ```

        Gate 1 (bug mode): run `bash .tad/hooks/lib/gate1-format-check.sh` on the mini-handoff (Bug Description present, §9.1 has the repro row); the human's confirmed playback of the symptom is the content half.

        Generate Blake message (same format as standard handoff step7).

    step5_record:
      name: "Record"
      action: |
        If mini-handoff created:
          Add to NEXT.md In Progress: "- [ ] Bugfix: {description} (mini-handoff to Blake)"
        If user handled it themselves:
          No action needed (user manages their own work)

# *discuss Path Protocol
