# Express Path Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

express_path_protocol:
  description: "Quick path for trivial bugfix / small UX polish. Skips ceremony, keeps ≥1 review."

  trigger:
    type: "user_explicit_only"
    activation_word: "*express"
    NOT_via_alex_suggestion: |
      Alex MUST NOT proactively recommend *express. Specifically:
      (a) MUST NOT add *express to adaptive_complexity_protocol step2 AskUserQuestion options
      (b) MUST NOT pre-select *express as Recommended (Option 1) in intent_router_protocol step3
          even if signal-word detection favors it (signal detection of express keywords routes to
          analyze with a 'looks small — start *analyze; user can downgrade by typing *express' note)
      (c) MUST NOT use AskUserQuestion to suggest *express in any other workflow step
      Reason: avoids anti-rationalization (AR-001) where Alex auto-downgrades scope to fit
      *express. User must explicitly type *express to opt in.

  scope_constraints:
    file_count_max: 5   # files in §6 Files to Modify / Create (L4: 2026-04-27 widened from 3 per Opus 4.7 token-economics relief)
    over_limit_action: |
      Use AskUserQuestion: "你的 *express 涉及 {N} 文件，超出 *express ≤5 文件硬上限。
      要降到 Standard TAD 还是拆成多个 *express?"
      Options:
        - "降到 Standard TAD (Recommended for >5 files)"
        - "拆成多个 *express handoffs (each ≤5 files)"
        - "我理解但坚持 *express 单 handoff (override — 解释原因)"
      override 选项需用户写明原因，**强制**记入 §11 Decision Summary 一行
      (Gate 2 检查若 §11 未含 override row → FAIL)

  required_steps:
    # ⚠️ AR-001 hard guarantee: cannot be skipped (text grep'd by AC-P3.1-h).
    # The literal phrase "expert review" + "code-reviewer" must remain on consecutive
    # tokens within ~30 lines following `express_path_protocol:` header.
    - "step1 draft creation (handoff scaffold + frontmatter)"
    - "step1b frontmatter validation (含 git_tracked_dirs)"
    - "step1c grounding pass (P2.2 — Read 目标文件 head 50)"
    - "step2 expert review with ≥1 expert (code-reviewer 必选; ≥1 expert; 视场景可加第 2 个)"
    - "step4 Audit Trail integration (P1.5 dogfood — *express 仍含 Audit Trail，记录 ≥1 review 的可审计证据)"
    - "step5 Gate 2 check"
    - "step7 Blake message generation with 人话版"
    - "Gate 3 v2 (Blake side: build/test/lint + Layer 2 ≥1 expert)"
    - "Gate 4 v2 acceptance (Alex side)"

  skipped_steps:
    - "Socratic Inquiry Protocol (3-5 rounds)"
    - "Adaptive Complexity Protocol step2 (no scope choice — *express IS the scope)"
    - "Epic Phase Map evaluation (express handoffs not part of Epics)"
    - "Knowledge Assessment ceremony (skip_knowledge_assessment defaults to yes; Blake can override unskip per P3.3)"

  enforcement: "prompt-level-only"  # See constraints.enforcement (global)
  # Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.express_path
  forbidden_implementations:
    - "Anti-AR-001: 'express = review-exempt' is a forbidden interpretation"
    - "MUST NOT auto-downgrade Standard TAD handoff to *express via any mechanism"

  when_appropriate:
    - "Single-file CSS / copy / config tweak (Next Guest pattern)"
    - "Trivial bugfix where root cause is obvious and fix is ≤10 lines"
    - "Small UX polish (label change, color swap, spacing)"
    - "Same-day supersede correction (small follow-up to a recent handoff)"
  when_NOT_appropriate:
    - "Architecture or contract change (interface, protocol, shared schema)"
    - "Multi-module refactor"
    - "Anything affecting >5 files (use over_limit_action AskUserQuestion) — L4 (2026-04-27): widened from 3"
    - "Security-adjacent changes (auth/token/encrypt → Standard TAD with security review)"
    - "Performance-adjacent changes (optimization → use *experiment instead)"

  # slug_convention (2026-05-31, doc-only): *express handoff slug MUST contain the
  # word `express`. layer2-audit.sh is_express_slug() already detects express via
  # word-boundary slug match; this convention is what lets that detection fire so an
  # *express bugfix doesn't trip a false Tier-1 (≥2 reviewer) WARN.
  # NOTE: this is a NAMING rule only — it does NOT relax required_steps above
  # (expert review + code-reviewer 必选 remains hard). No audit code change.
  slug_convention:
    rule: |
      When drafting an *express handoff, the slug in
      HANDOFF-YYYYMMDD-<slug>.md MUST contain the token `express`
      (e.g. `express-fix-foo`, `bugfix-foo-express`, or `express`).
    rationale: |
      layer2-audit.sh is_express_slug() matches express|*-express|*-express-*|express-*
      on a word boundary. A `*express` handoff named `bugfix-foo` with task_type=code
      would NOT match → audit treats it as Standard Tier-1 and WARNs on <2 reviewers,
      even though *express legitimately keeps only ≥1 code-reviewer. Putting `express`
      in the slug makes the detection fire correctly. Doc-only fix — audit logic is
      already correct and MUST NOT be changed.

