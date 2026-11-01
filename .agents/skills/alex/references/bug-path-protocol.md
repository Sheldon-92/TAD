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

    step6_saveable_workflow_check:
      name: "Saveable Workflow Check (conversation light path)"
      action: |
        step5 之后自检一次：本次的复现→定位→修复→验证序列是否构成可复用工作流？
        检测信号（全中才提议，缺一即静默跳过）：
        - 诊断路径有 ≥3 个有序步骤，且已在本会话实际走通（根因已定、修法已明或已派 mini-handoff）
        - 存在可命名的未来触发情境（同类症状、同子系统、或同类环境口径再犯时）
        - 至少一条非显然 gotcha（误导性症状／假根因／环境口径坑）——平凡 typo、拼写类不存
        提议形态（一行、非阻塞，不改变已定的 step3/step4 处置）：
        "这套排查流程（{一句话名}）下次遇到 {触发情境} 还能复用——存成 skill 吗？"
        经 AskUserQuestion（平台绑定交互决策）三选：
        - "存入 skill 库" → 按下方约定当场成文写入；一次确认即全部仪式
        - "先看草稿" → 展示完整草稿，用户一次确认后写入
        - "不用" → 不写任何文件，本 bug 不再重提
        保存约定（与 discuss-path-protocol 的 saveable_workflow_check 同一约定）：
        - 目标：.tad/skill-library/<project>--<slug>.md（与库内现有条目同形），
          并在 .tad/skill-library/_index.md 追加一行索引
        - 条目形状：标题 / Source project / Date / Origin: conversation light path (*bug) /
          Type: workflow / Triggers: 触发关键词 / 有序步骤（真实命令与口径） / Gotchas
        - 绕过范围：不写 T1 SCAND、不经 Gate 4 KA 三问；T2 入库的实质（会话内人类确认）
          收敛为这一次确认本身。Origin 行标明轻路径出身；T3 晋升规则不变（仍需 ≥2 项目证据）。
        - 与 *save-skill / *save-workflow（存 .claude/skills/local/）分工：彼者用户显式
          命令、存项目本地；本步被动检测、存跨项目参考库（T2 层）。用户点名彼者时按彼者走。

# *discuss Path Protocol
