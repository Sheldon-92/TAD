# Accept Command (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

accept_command:
  description: "归档 handoff 并更新项目上下文"
  blocking: true

  prerequisite:
    check: "验收是否已通过（step1-7 完成）"
    if_not: "BLOCK - 必须先完成验收流程"

  quick_mode:
    trigger: "User types *accept --quick OR user selects 'batch cleanup' from STEP 3.55"
    description: "Minimal archive — skip all ceremony, just move files"
    steps:
      step1_identify:
        action: |
          If specific slug provided: target that handoff
          If batch mode (from STEP 3.55): target all zombie handoffs
          For each target:
            1. Verify .tad/active/handoffs/HANDOFF-*-{slug}.md exists
            2. Check for matching COMPLETION-*-{slug}.md (optional — may not exist)
      step2_archive:
        action: |
          For each target handoff:
            1. mv HANDOFF to .tad/archive/handoffs/
            2. mv COMPLETION to .tad/archive/handoffs/ (if exists)
            3. If no COMPLETION: log "(no completion report — direct archive)"
      step3_update:
        action: |
          1. Update NEXT.md: find matching entry → mark [x]
          2. If handoff has Epic field:
             → ONLY update Phase Map status marker: 🔄 Active → ✅ Done
             → Do NOT trigger Epic completion check (all-phases-done → archive Epic)
             → Do NOT trigger next-phase AskUserQuestion prompt
             → Do NOT update Phase Detail Block notes or Context for Next Phase
             → These require full *accept (step2b_epic_update has error handling,
               concurrent checks, and Phase Detail Block logic that --quick skips)
          3. Track quick_accept_count: increment counter in session context
             → If quick_accept_count >= 3 since last PROJECT_CONTEXT.md update:
               Output soft reminder: "💡 PROJECT_CONTEXT.md 已 {N} 次 --quick 未更新，
               考虑运行完整 *accept 或 *tad-maintain sync"
          4. Output: "✅ Archived: {slug} (quick mode — no KA, no Layer 2)"
    skipped_steps:
      - "step0_git_check (git status)"
      - "step4 (AC line-by-line)"
      - "step4b (evidence completeness)"
      - "step4c (Layer 2 audit)"
      - "step7 (Knowledge Assessment)"
      - "step_pair_testing_assessment"
      - "step3 (PROJECT_CONTEXT.md update)"
    note: "Full *accept is UNCHANGED. --quick is additive, not replacement."

  steps:
    step0_git_check:
      action: "Git status safety net — 检查是否有未 commit 的变更"
      details: |
        Before archiving, verify implementation code is committed:
        1. Run `git status --porcelain`
        2. If output is empty → PASS, proceed to step1
        3. If output is non-empty:
           a. Display the list of uncommitted changes
           b. BLOCK: "⚠️ 发现未 commit 的变更。归档前必须先 commit 代码。"
           c. Use AskUserQuestion:
              question: "检测到未 commit 的文件变更，无法归档。请先处理："
              options:
                - "我去 Terminal 2 让 Blake commit" → BLOCK, remain in *accept (user returns after commit)
                - "这些变更与本次 handoff 无关，继续归档" → proceed with WARNING in completion report
                - "取消 *accept" → Abort entirely
           d. If user chooses "无关":
              → Log WARNING to completion report: "User override: uncommitted changes deemed unrelated"
              → List the specific files that were overridden
              → Proceed to step1
           e. Otherwise → remain BLOCKED until resolved
      blocking: true
      purpose: "Safety net — catches cases where Blake's step3c was skipped or failed"

    step1:
      action: "将 handoff 移至 .tad/archive/handoffs/"
      from: ".tad/active/handoffs/HANDOFF-*.md"
      to: ".tad/archive/handoffs/"

    step2:
      action: "将 completion report 移至 archive"
      from: ".tad/active/handoffs/COMPLETION-*.md"
      to: ".tad/archive/handoffs/"

    step2b_epic_update:
      action: "检查并更新关联的 Epic（如有）"
      details: |
        1. 使用 step1 归档前已读取的 handoff 头部信息，查找 **Epic** 字段
       （不依赖从 archive 重新读取，避免文件名可能被 -dup- 后缀修改的问题）
        2. 如果没有 Epic 字段 → 跳过，继续 step3
        3. 如果有 Epic 字段:
           a. 解析 Epic 文件名和 Phase 编号
           b. 在 .tad/active/epics/ 中查找该 Epic 文件
           c. 如果文件不存在 → WARNING 日志，继续 step3（不阻塞归档）
           d. 如果文件存在但格式异常 → WARNING 日志，跳过更新，继续 step3
           e. 读取 Epic Phase Map 表格
           f. 并发检查: 确认当前没有其他 🔄 Active phase（除了刚完成的这个）
              - 如果有其他 Active phase → BLOCK，报错，不激活新 phase
           g. 更新 Phase Map: 将当前 phase 标记为 ✅ Done，填入 handoff 链接
           g2. 更新 Phase Detail Block (if exists):
               - Status: 🔄 Active → ✅ Done (accept ⬚ Planned as fallback for backward compat)
               - Append under Notes: "Completed: {date}, Handoff: {filename}, Commit: {hash}"
               If no Phase Detail Block → skip (backward compat with old Epics)
           h. 更新 "Context for Next Phase" section（摘要完成内容、决策、遗留问题）
           i. 检查是否所有 phase 都已完成（从 Phase Map 派生）:
              - 如果全部 ✅ → Epic 标记为 Complete，移至 .tad/archive/epics/（two-phase safety: copy first, verify, then delete source）
              - 如果还有后续 ⬚ Planned phase:
                → AskUserQuestion: "Phase {N} 完成。准备开始 Phase {N+1}: {phase_name} 吗？"
                → 选项: "开始下一阶段" / "稍后再说"
                → 用户选"开始" → Alex 开始下一阶段的设计
                → 用户选"稍后" → 在 NEXT.md 中记录提醒
      error_handling: |
        Epic 更新失败不阻塞 handoff 归档。
        Handoff 是原子操作（step1-2 已完成），Epic 是后续更新。
        失败时记录 WARNING，继续后续 step。

    # Epic 派生状态（不存储独立 Status 字段，从 Phase Map 动态计算）
    epic_derived_rules:
      derived_status_formula:
        planning: "所有 phase 为 ⬚ Planned"
        in_progress: "有任何 🔄 Active 或 ✅ Done（但非全部 ✅）"
        complete: "所有 phase 为 ✅ Done"
      note: "Epic 文件中不写 Status 字段，Alex 在需要时从 Phase Map 计算状态"

      phase_adjustment:
        add: "Alex 在 Phase Map 末尾追加新行（仅 ⬚ Planned），Notes 中记录原因。Also: add corresponding Phase Detail Block using epic-template.md structure (if Phase Details section exists)"
        remove: "仅限 ⬚ Planned 状态的阶段，Notes 中记录原因。Also: remove corresponding Phase Detail Block (if exists)"
        reorder: "仅限 ⬚ Planned 状态的阶段。Also: reorder corresponding Phase Detail Blocks to match new Phase Map order (if exist)"

      error_codes:
        epic_file_missing: "WARNING 日志，继续 *accept 流程（不阻塞归档）"
        epic_format_invalid: "WARNING 日志，跳过自动更新，提醒用户手动修复"
        handoff_ref_mismatch: "WARNING 日志，提示用户确认正确的 phase 编号"
        concurrent_active_violation: "BLOCK - 不允许激活新 phase"
        principle: "Epic 更新失败不阻塞 handoff 归档"

    step3:
      action: "更新 PROJECT_CONTEXT.md"
      trigger: "必须执行"
      details: "见下方 project_context_update"

    step4:
      action: "更新 NEXT.md"
      details: "标记已完成任务 [x]，添加后续任务"

    step5:
      action: "检查 active handoffs 数量"
      max: 3
      if_exceeded: "警告用户清理旧 handoffs"

    step_pair_testing_assessment:
      constraint: "Each TEST_BRIEF.md lives in its own session directory .tad/pair-testing/S{NN}/"
      action: |
        After Gate 4 passes, Alex evaluates whether pair testing is recommended:

        1. Assess: Does this task involve UI changes, user flow changes, or new user-facing features?
           - If clearly NO (backend-only, config, docs, internal refactor) → skip silently, proceed to step_final
           - If YES or UNCERTAIN → proceed to step 2

        2. Use AskUserQuestion to recommend pair testing:
           AskUserQuestion({
             questions: [{
               question: "本次实现涉及用户界面变更，建议做配对 E2E 测试。要现在生成测试简报吗？",
               header: "Pair Testing",
               options: [
                 {label: "生成测试简报 (Recommended)", description: "生成 .tad/pair-testing/{session_id}/TEST_BRIEF.md 用于 Claude Code + Playwright 配对测试 (4D Protocol)"},
                 {label: "跳过，直接归档", description: "不做配对测试，直接完成归档"}
               ],
               multiSelect: false
             }]
           })

        3. If user chooses "生成测试简报":
           session_creation_flow: |
             1. Read .tad/pair-testing/SESSIONS.yaml
                - If not exists → create with empty sessions, total_sessions: 0
                - If YAML parse error (corruption detected):
                  a. mv SESSIONS.yaml → SESSIONS.yaml.corrupt.{timestamp}
                  b. Scan S*/ directories to rebuild manifest
                  c. Infer status: has PAIR_TEST_REPORT.md → "reviewed", no report → "active"
                  d. Write rebuilt SESSIONS.yaml
                  e. Log: "Recovered SESSIONS.yaml from directory scan"
             2. Determine next session ID:
                - Count existing S{NN} directories → next = S{NN+1} (zero-padded: S01, S02, ..., S99, S100+)
             3. Check active session guard:
                - If any session has status "active" → Use AskUserQuestion:
                  "Session {id} ({scope}) is still active. What would you like to do?"
                  Options: "Resume existing session" / "Archive it and start new" / "Cancel"
             4. Check for inheritable context:
                - Find most recent session with status "reviewed" or "archived"
                - If found → read its PAIR_TEST_REPORT.md for findings summary
                - Use AskUserQuestion: "上一次测试 ({prev_scope}) 发现了 {N} 个问题。要在新 brief 中包含回归验证项吗？"
                  Options: "包含回归验证 (Recommended)" / "全新独立测试"
             5. Create directory: .tad/pair-testing/{session_id}/ and .tad/pair-testing/{session_id}/screenshots/
             6. Read `.tad/templates/test-brief-template.md`
             7. Fill ALL sections (1-8) with complete information:
                - Section 1: Product info from project (package.json, README, etc.)
                - Section 2: Test scope based on what was implemented
                - Section 3: Test accounts/data
                - Section 4: Known issues from Blake's completion report
                - Section 4b: Previous Session Context (if inheriting, populate from previous report)
                - Section 5: Design intent, UX expectations, validation goals (Alex's domain knowledge)
                - Section 6: Round-by-Round collaboration guide (fill Round definitions in 6d)
                - Section 7: Output requirements (template default)
                - Section 8: Technical notes (framework-specific testing tips)
             8. Write to `.tad/pair-testing/{session_id}/TEST_BRIEF.md`
             9. Update SESSIONS.yaml: add new session entry, set as active_session
                - Backup SESSIONS.yaml to SESSIONS.yaml.bak before any write
           d. Remind human:
              ".tad/pair-testing/{session_id}/TEST_BRIEF.md 已生成（所有 Section 已填充）
               Session ID: {session_id} | 继承自: {prev_session or 'None'}
               请在 Claude Code 中打开新 terminal，运行配对测试脚本（参考 TEST_BRIEF Section 6h）进行 E2E 测试。
               测试完成后，PAIR_TEST_REPORT.md 保存到 .tad/pair-testing/{session_id}/，
               下次启动 /alex 时我会自动检测并处理。"

        4. If user chooses "跳过" → proceed to step_final
      trigger: "After Gate 4 passes, before step_final"
      purpose: "Evaluate and optionally generate complete test brief for pair E2E testing"

      skip_criteria:
        - "Backend-only changes (no UI impact)"
        - "Configuration/environment changes"
        - "Documentation-only updates"
        - "Internal refactoring with no user-facing behavior change"
        - "Dependency updates with no feature change"

    step_final:
      action: |
        Run document sync in SYNC mode - scoped to the just-accepted handoff.
        Pass the accepted handoff's canonical slug as target_slug to /tad-maintain SYNC.
        1. Archive the specific handoff that was just accepted (target_slug scoping)
        2. Check NEXT.md line count against config thresholds
        3. If over max_lines: archive old completed sections
        4. Update PROJECT_CONTEXT.md active work section
      trigger: "After all other *accept steps complete"
      purpose: "Keep documents synchronized after task completion"

  output: |
    ## *accept 完成

    ✅ Handoff 已归档: {handoff_name}
    ✅ PROJECT_CONTEXT.md 已更新
    ✅ NEXT.md 已更新

    Active handoffs: {count}/3

    💡 If .tad/evidence/traces/ has data: "Trace data available. Run *optimize to analyze execution history and propose improvements."

