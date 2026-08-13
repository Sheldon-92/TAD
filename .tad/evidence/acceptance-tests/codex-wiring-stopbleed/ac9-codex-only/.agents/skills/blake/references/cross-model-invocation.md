# Cross Model Invocation (extracted from blake/SKILL.md for progressive loading)
# Source: .claude/skills/blake/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 3)

cross_model_invocation:
  description: "Blake knows how to invoke Codex/Gemini CLI for delegated tasks"
  reference: ".tad/guides/cross-model-invocation.md"

  preflight:
    codex: "command -v codex >/dev/null 2>&1"
    gemini: "command -v gemini >/dev/null 2>&1"
    on_not_found:
      if_user_explicitly_requested: |
        告知用户工具不可用："{tool} CLI 未安装，我用自身能力完成。"
        然后用自身能力完成任务。
      if_system_suggested_or_handoff: |
        静默回退 — 用自身能力完成任务。
        不向用户报错，不建议安装，不提及工具缺失。

  scenarios:
    codex_review:
      when: "用户或 handoff 要求用 Codex 做 code review"
      command_template: |
        git diff HEAD~1..HEAD > /tmp/tad-review-diff.txt
        { echo "Review this diff:"; cat /tmp/tad-review-diff.txt; } \
          | codex exec --full-auto "Provide structured code review with P0/P1/P2 findings"
      output_integration: "整合到 Layer 2 报告作为 'External Review (Codex)' 补充视角"
      not_a_substitute: "不替代内部 code-reviewer sub-agent — 是额外独立视角"

    codex_implement:
      when: "用户要求用 Codex 实现某个功能或生成代码"
      command_template: |
        codex exec --full-auto "specific implementation prompt"
      note: "Codex 可写文件（workspace-write sandbox）"
      non_git_caveat: "非 git 目录加 --skip-git-repo-check flag"

    gemini_research:
      when: "用户要求用 Gemini 做研究或分析"
      command_template: |
        gemini -p "structured research prompt with output format instructions"
      output_note: "只读输出 — 用于决策参考，Gemini 不能直接写文件"
      regex_warning: "Gemini 输出的正则是 PCRE 风格，用于 hook 前必须用 grep -E 验证"

  error_handling:
    exit_nonzero: "报告调用失败 + 回退到自身能力"
    stderr_noise: "忽略 Codex 的 'failed to record rollout items' stderr — 良性噪音，用 exit code 判断"
    timeout:
      mechanism: "Bash tool timeout 参数设为 120000 (2 分钟 wall clock)"
      rationale: "Codex exec 复杂 review 可能 30-60s，2min 更安全"
      shell_alternative: "或在命令前加 timeout 120 codex exec ..."

  direct_user_invocation: |
    用户在 Blake terminal 直接说"用 Codex review"时，Blake 不需要 Alex 中转。
    直接执行 preflight → 调用 → 整合结果。

  forbidden_implementations:
    - "MUST NOT auto-invoke codex/gemini without explicit handoff instruction or user request"
    - "MUST NOT register codex/gemini call as a PreToolUse hook"
    - "MUST NOT substitute codex review for the layer2_expert_review distinct-reviewer requirement (not a substitute for code-reviewer sub-agent)"
    - "MUST NOT silence codex/gemini errors when user explicitly requested the tool (apply 告知 path)"
    - "MUST NOT chain codex implementation into automatic commit/push without Layer 1 self-check"

