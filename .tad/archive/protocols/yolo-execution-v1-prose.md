# ═══════════════════════════════════════════════════════════
# YOLO Execution Protocol
# Alex 自动驱动 Epic 全部 Phase 执行，所有过程文件持久化
# ═══════════════════════════════════════════════════════════

yolo_execution_protocol:
  description: "Alex 自动驱动 Epic 全部 Phase 执行，所有过程文件持久化"
  trigger: "step7_execution_mode 用户选了 YOLO 或半自动"

  constraints:
    - "文件是 source of truth — prompt 只传路径，不传业务内容"
    - "Review 必须是 Conductor 直接 spawn 的 sub-agent — 不信任 sub-agent 声称的 review"
    - "每步持久化 — 任何产物都写入磁盘再进入下一步"
    - "Blake sub-agent 只做实现 + Layer 1 自检 — 不做 Layer 2、不做 Gate"

  yolo_evidence_structure:
    base: ".tad/evidence/yolo/{epic-slug}/"
    per_phase_files:
      - "phase{N}-grounding.md"
      - "phase{N}-design-review-cr.md"
      - "phase{N}-design-review-{domain}.md"
      - "phase{N}-impl-review-cr.md"
      - "phase{N}-impl-review-{domain}.md"
      - "phase{N}-gate-report.md"
    epic_level:
      - "EPIC-COMPLETION.md"

  per_phase_protocol:
    description: "For each ⬚ Planned Phase in Epic"

    step_Y1:
      name: "Phase Activation"
      action: |
        0. Define template variables for this Phase:
           handoff_path: .tad/active/handoffs/HANDOFF-{YYYY-MM-DD}-{epic-slug}-phase{N}.md
           completion_path: .tad/active/handoffs/COMPLETION-{YYYY-MM-DD}-{epic-slug}-phase{N}.md
           epic_path: .tad/active/epics/EPIC-{date}-{epic-slug}.md
        1. Bash("mkdir -p .tad/evidence/yolo/{epic-slug}")
        2. Read Epic Phase Detail Block for this Phase
        3. Update Phase status: ⬚ Planned → 🔄 Active in Epic file
           (both Phase Map table AND Phase Detail Block Status field)
        4. Write to disk: Epic file updated
        5. Update session-state.md:
           Status: ACTIVE, current_y_step: Y1, Active Task: Phase {N}
        6. Announce: "🔄 Starting Phase {N}: {name}"
        → Proceed to step_Y2.

    step_Y2:
      name: "Grounding (Conductor reads target code → writes to file)"
      action: |
        1. Read target project code relevant to this Phase's scope
           (from Phase Detail Block "Files Likely Affected")
        2. Read project-knowledge files (same as step0_5 Context Refresh)
        3. Write grounding summary to:
           .tad/evidence/yolo/{epic-slug}/phase{N}-grounding.md
           Include: file paths read, key patterns found, line numbers, import conventions
        4. Update session-state.md: current_y_step: Y2
        → Proceed to step_Y3.
      output: "phase{N}-grounding.md on disk"

    step_Y3:
      name: "Design (Alex sub-agent — prompt only contains file paths)"
      action: |
        Spawn Alex sub-agent (subagent_type: general-purpose).
        ⚠️ CORE CONSTRAINT: prompt 只传文件路径，不传业务内容。
        Prompt template:
        ---
        You are Alex designing a feature. Follow these steps:
        1. Read the Epic: {epic_path} — find Phase {N} Detail Block for scope and ACs
        2. Read the grounding file: .tad/evidence/yolo/{epic-slug}/phase{N}-grounding.md
        3. Read the handoff template: .tad/templates/handoff-a-to-b.md for section structure
        4. Based on these files, write a HANDOFF to: {handoff_path}
           Follow the template's section numbering exactly.
           Include YAML frontmatter (task_type, e2e_required, research_required).
        5. Do NOT do expert review — Conductor handles that.
        6. Do NOT call any sub-agents or reviewers.
        ---
        No business content in prompt. Alex sub-agent reads everything from disk.
      output: "HANDOFF.md on disk"
      verify: "test -f {handoff_path} && [ $(wc -l < {handoff_path}) -gt 50 ]"
      on_verify_fail: |
        Re-spawn Alex sub-agent with additional context:
        "Your first attempt produced an incomplete handoff ({wc_lines} lines).
         Re-read {epic_path} Phase {N} and produce a complete handoff to {handoff_path}."
        Circuit breaker: if second attempt also fails verify → honest_partial, pause for human.
      session_state: "current_y_step: Y3"
      → Proceed to step_Y3b.

    step_Y3b:
      name: "Post-Design Validation (Conductor validates sub-agent output)"
      action: |
        Conductor reads the handoff produced by Y3 and runs validation checks
        that sub-agents cannot run (they lack the right tool access or context):
        1. Frontmatter validation: verify task_type, e2e_required, research_required are filled
        2. Pack injection: check .claude/skills/*/SKILL.md (preferred) or .tad/domains/*.yaml (fallback)
           for matching packs, inject quality criteria into handoff ACs (same as step1a in manual mode)
        3. Grounding verification: for each file in handoff Files to Modify section,
           Read head 50 lines and verify file exists + path is correct.
           Append "Grounded Against" line to handoff.
        4. LSP impact analysis (if LSP available): run documentSymbol + incomingCalls
           on key files. Note blast radius in handoff.
        5. AC dry-run: for each AC with a verification command, execute the command
           to confirm it runs without syntax error (not testing correctness, testing runnability)
        6. If any validation fails: fix inline (Conductor has Edit access) or re-spawn Y3
      session_state: "current_y_step: Y3b"
      → Proceed to step_Y4.

    step_Y4:
      name: "Design Review (Conductor spawns ≥2 distinct reviewers)"
      action: |
        ⚠️ Must spawn ≥2 distinct reviewer types (matching production TAD hard_requirement_distinct_reviewers).
        1. Read HANDOFF.md from disk
        2. Spawn code-reviewer sub-agent (MANDATORY):
           prompt: "Review {handoff_path}. Focus on file list completeness + AC verifiability.
                   Check for AR-001 pattern ('this P0 is not important' = VIOLATION). Report P0/P1/P2."
        3. Spawn domain-expert sub-agent (select based on handoff scope —
           use Files Likely Affected to auto-detect: >50% frontend files → frontend-specialist,
           >50% API/service/DB files → backend-architect, auth/secrets → security-auditor):
           prompt: "Review {handoff_path}. Focus on architecture/design quality. Report P0/P1/P2."
        4. Write BOTH review results to disk:
           - .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-cr.md
           - .tad/evidence/yolo/{epic-slug}/phase{N}-design-review-{domain}.md
        5. If ANY P0 found across either reviewer:
           a. Alex (main session) reads BOTH reviews from disk, fixes HANDOFF.md
           b. Write updated HANDOFF.md (v2) to disk
           c. Re-spawn code-reviewer on HANDOFF.md v2 to verify fix
           d. Circuit breaker: max 2 fix-review rounds, then honest_partial + pause for human
        6. If no P0: proceed
        7. Gate 2 judgment: re-read raw review files from disk (not from memory)
        8. Update session-state.md: current_y_step: Y4
        → Proceed to step_Y5.
      output: "2 review files on disk + HANDOFF.md (v2 if fixed)"

    step_Y5:
      name: "Implementation (Blake sub-agent)"
      action: |
        Spawn Blake sub-agent (subagent_type: general-purpose, isolation: worktree).
        Prompt template (STANDARDIZED — Blake gets the same instructions every time):
        ---
        You are Blake implementing a feature. Follow these steps exactly:

        1. Read the handoff: {handoff_path}
        2. Implement all tasks described in the handoff
        3. Run these checks (Layer 1):
           - npx tsc --noEmit (must pass)
           - npm test (must pass)
           - npm run lint (if available)
        4. Write a completion report to: {completion_path}
           Include: files changed, tsc result, test result, AC verification table
        5. Git commit with message: "feat({scope}): {description} [YOLO Phase {N}]"

        LIMITS:
        - Max 3 Layer 1 retry attempts. If same error 3 times → write what you have to COMPLETION.md and exit
        - Max 200 tool calls. If reached → write progress to COMPLETION.md and exit
        - Only modify files within the current project root. If the Phase requires cross-project changes,
          write the change plan to COMPLETION.md §Escalations and flag for human execution

        DO NOT:
        - Call any reviewer or expert sub-agent (you cannot — Conductor handles review)
        - Make design decisions not in the handoff (escalate by noting in COMPLETION.md §Escalations)
        - Skip Layer 1 checks
        ---
      output: "COMPLETION.md on disk + git commit"
      verify: "test -f {completion_path}"
      session_state: "current_y_step: Y5"
      → Proceed to step_Y6.

    step_Y6:
      name: "Implementation Review (Conductor spawns ≥2 distinct reviewers)"
      action: |
        ⚠️ Must spawn ≥2 distinct reviewer types (same as Y4).
        1. Read COMPLETION.md from disk
        2. Read git diff (Blake's commit)
        3. Spawn code-reviewer sub-agent (MANDATORY):
           prompt: "Review implementation at {completion_path}. Check code diff.
                   Verify ACs are met. Check for AR-001 pattern ('this P0 is not important' = VIOLATION).
                   Report P0/P1/P2."
        4. Spawn domain-expert sub-agent (same type as Y4):
           prompt: "Review implementation diff. Focus on architecture quality + blast radius.
                   Report P0/P1/P2."
        5. Write BOTH review results to disk:
           - .tad/evidence/yolo/{epic-slug}/phase{N}-impl-review-cr.md
           - .tad/evidence/yolo/{epic-slug}/phase{N}-impl-review-{domain}.md
        6. If ANY P0 found across either reviewer:
           a. Decide: re-spawn Blake or fix directly?
           b. For simple P0: Alex fixes directly (Edit tool), re-run tsc
           c. For complex P0: re-spawn Blake with prompt:
              "Read {handoff_path} for original spec. Read {impl-review-cr.md} for P0 findings.
               Fix and re-commit."
              (Both paths are file references — no inline content)
           d. Circuit breaker: if re-spawn also fails P0 → honest_partial, pause for human
           e. Write fix result to impl-review appendix
        7. Re-read raw review files from disk before Gate judgment (not from memory)
        8. Update session-state.md: current_y_step: Y6
        → Proceed to step_Y7.
      output: "2 review files on disk"

    step_Y7:
      name: "Gate 3+4 (Conductor judges)"
      action: |
        1. Read: HANDOFF.md + COMPLETION.md + design-review files + impl-review files
        2. AC verification: for each AC in handoff, check completion report's AC table
        3. tsc re-run: Bash("npx tsc --noEmit") to independently verify
        4. gate4_delta capture: compare handoff design intent vs actual implementation,
           note any surprises or deviations in gate report
        5. Write gate report: .tad/evidence/yolo/{epic-slug}/phase{N}-gate-report.md
           Include: AC pass/fail table, reviewer summary, tsc result, gate4_delta, verdict
        6. If PASS:
           a. Update Epic Phase status: 🔄 Active → ✅ Done
              (both Phase Map table AND Phase Detail Block Status field)
           b. Archive handoff + completion to .tad/archive/handoffs/
              (both HANDOFF-*-{slug}.md AND COMPLETION-*-{slug}.md)
              Update NEXT.md: mark corresponding entry [x]
           c. Announce: "✅ Phase {N} complete. Moving to Phase {N+1}."
        7. If FAIL:
           a. Use honest_partial_protocol: mark PARTIAL, do NOT fake PASS
           b. Announce: "❌ Phase {N} Gate failed. Reason: {detail}"
           c. Decision: retry (back to Y5) or pause for human
        8. Update session-state.md: current_y_step: Y7
        → Proceed to step_Y8.
      output: "phase{N}-gate-report.md on disk"

    step_Y8:
      name: "Knowledge Assessment"
      action: |
        1. Review all phase artifacts for new discoveries
        2. If discovery found: write to .tad/project-knowledge/{category}.md
        3. Record in gate report
        4. Update session-state.md: current_y_step: Y8
        → If pause_between_phases: true → proceed to step_Y_pause.
        → Else → If more ⬚ Planned Phases exist → proceed to step_Y1 for Phase {N+1}.
        → If no more Planned Phases → proceed to epic_completion.
      output: "KA entry (if any)"

    step_Y_pause:
      name: "Phase Pause (半自动 mode only)"
      trigger: "pause_between_phases: true AND Phase complete"
      action: |
        AskUserQuestion:
        question: "Phase {N} 完成。Gate PASS。要继续 Phase {N+1} 吗？"
        options:
          - "继续": "自动开始下一个 Phase"
          - "我先看看": "暂停，稍后说'继续'恢复"
          - "停止": "退出 YOLO，剩余 Phase 手动执行"
        If "继续" → proceed to step_Y1 for Phase {N+1}.
        If "我先看看" → pause, update session-state "current_y_step: Y_pause_waiting".
           When user says "继续" → proceed to step_Y1 for Phase {N+1}.
        If "停止" → exit yolo_execution_protocol. Remaining Phases stay ⬚ Planned. Enter standby.

  epic_completion:
    trigger: "所有 Phase 都 ✅ Done"
    action: |
      1. Write final report: .tad/evidence/yolo/{epic-slug}/EPIC-COMPLETION.md
         Include: per-Phase summary, total files changed, total commits, all review references
      2. Run audit-yolo.sh {epic-slug} (Phase 3 of this Epic — skip if script not yet available)
      3. Assess pair testing: if any Phase involved UI/user-flow changes, suggest pair testing
      4. Archive Epic: .tad/active/epics/ → .tad/archive/epics/
         (two-phase safety: copy first, verify, then delete source)
      4b. Verify clean active/:
          残留检查: ls .tad/active/handoffs/*{epic-slug}* 2>/dev/null
          If any files remain: WARN "⚠️ {N} files remain in active/ for this Epic"
          and list them. For each remaining file, execute quick archive:
          mv to .tad/archive/handoffs/ (same as *accept --quick step2_archive).
          This is the actual safety net — catches any per-phase archive that silently failed.
      5. Announce to user:
         "🎉 Epic {name} 全部完成。{N} 个 Phase, {M} 个文件, {K} 个 commit。
          审计报告: .tad/evidence/yolo/{epic-slug}/EPIC-COMPLETION.md
          请验收。"

