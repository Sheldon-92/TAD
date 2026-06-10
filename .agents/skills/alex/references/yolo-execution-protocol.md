# Yolo Execution Protocol (extracted from SKILL.md for progressive loading)
# Source: .claude/skills/alex/SKILL.md
# Extracted: 2026-06-08 (EPIC-20260608-skill-progressive-loading Phase 2)

yolo_execution_protocol:
  description: "Hybrid Conductor + Workflow YOLO execution"
  trigger: "step7_execution_mode user chose YOLO or semi-auto"
  constraints:
    - "File is source of truth — prompt only passes paths"
    - "Review must be Conductor-spawned sub-agent — don't trust sub-agent claimed review"
    - "Every step persists — write to disk before next step"
    - "Blake sub-agent does implementation + Layer 1 only"
  workflow_invocation: |
    For each ⬚ Planned Phase (TWO workflow calls per phase):
    1. Y1: Activate phase (Conductor)
    2. Y2: Grounding (Conductor reads code, writes grounding file)
    3. Call 1: Workflow({name: 'yolo-epic', args: {steps: ['design'], ...}})
       → Y3 design sub-agent writes HANDOFF.md → Returns {handoff_path}
    4. Y3b: Validate handoff (Conductor — frontmatter, grounding, AC dry-run)
    5. Call 2: Workflow({name: 'yolo-epic', args: {steps: ['review','implement','impl_review'], ...}})
       → Y4 reviewers → Y5 Blake implements → Y6 impl reviewers → Returns budget_report
       Precondition: handoff must exist and be > 50 lines
    6. Y7: Gate judgment (Conductor reads all evidence files from disk)
    7. Y8: Knowledge Assessment + budget report + human checkpoint
  evidence_file_naming: "cr=code-reviewer, arch=backend-architect, fe=frontend-specialist, sec=security-auditor, ux=ux-expert-reviewer, perf=performance-optimizer. Path: .tad/evidence/yolo/{epic-slug}/phase{N}-{step}-{suffix}.md"
  fallback: "If Workflow tool unavailable: follow .tad/archive/protocols/yolo-execution-v1-prose.md verbatim"
  judgment_rules: |
    - Conductor MUST re-read review files from disk before gate judgment
    - ≥2 distinct reviewers at Y4 and Y6; circuit breaker: max 2 retries then honest_partial

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

