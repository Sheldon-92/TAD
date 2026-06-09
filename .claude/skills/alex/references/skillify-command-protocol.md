# Skillify Command Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

skillify_command_protocol:
  trigger: "User types *skillify"
  action: |
    1. Analyze current session context — what pattern was the user working on?
    2. If no clear pattern detected:
       Output: "当前 session 没有检测到可提取的工作模式。能描述一下你想 skillify 的模式吗？"
       Wait for user input, then re-analyze.
    3. If pattern detected → run 4 quality gates:
       - Reusable — pattern expected to recur (≥2 future use scenarios imaginable)
       - Non-trivial — multi-step workflow (≥3 steps), not a single rule
       - Verified — pattern was applied in this session and result was correct
         (no revert, no user correction, no retry). Weaker than Gate 3 PASS but
         has a concrete anchor: the session outcome.
       - Not-already-captured — no overlap with existing .claude/skills/ or capability packs
    4. If any gate fails → report which gate failed and why. Offer to proceed anyway
       with user override.
    5. Step 5 — Pattern Type Routing (after gates pass):
       Classify the detected pattern:
       - Does executing this pattern require >1 agent coordinating?
         Yes → type: orchestration → candidate targets .workflow.js
         No  → type: judgment → candidate targets SKILL.md (existing path)
       
       Signal table:
       | Signal | Type | Target |
       |--------|------|--------|
       | "Evaluating X requires checking Y and Z" | judgment | SKILL.md |
       | "Per-AC verifier + skeptic each time" | orchestration | .workflow.js |
       | "N agents compete, judge selects, merge" | orchestration | .workflow.js |
       | "When rubric score is abnormal, check inter-rater reliability" | judgment | SKILL.md |
       | "Loop finding bugs until K dry rounds" | orchestration | .workflow.js |
       
       Write `type` field in SCAND frontmatter. Announce:
       "Pattern classified as {type}. Target: {SKILL.md | .workflow.js}"
    6. If gates pass → draft candidate using .tad/templates/skillify-candidate-template.md,
       show to user for confirmation (display name, steps, trigger conditions).
    7. On confirm → write SCAND-{date}-{slug}.md to .tad/active/skillify-candidates/
       with status: pending and source: "session-explicit"
    8. Output: "✅ Skillify candidate '{slug}' saved. Alex 下次启动时会在 STEP 3.57 提示审批。"
       Or if Alex is currently active: immediately offer to generate the skill
       via the same accept flow as STEP 3.57.
  # Mechanical deny migrated to frontmatter constraints.deny (global) + section_overrides.skillify
  forbidden_implementations:
    - "MUST NOT auto-accept candidates without human review"
    - "MUST NOT create .claude/skills/{slug}/SKILL.md directly — go through candidate→review→accept"
    - "MUST NOT be callable from Blake terminal (Terminal Isolation)"
    - "MUST NOT auto-invoke without explicit user *skillify command"

