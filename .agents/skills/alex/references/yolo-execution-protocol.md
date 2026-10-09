# Yolo Execution Protocol (extracted from SKILL.md for progressive loading)
# Source: skills/alex/SKILL.md (platform tree)
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
    仅当你自己的可用工具里有 Workflow 工具时才走 workflow（若它是延迟加载的，先用 ToolSearch 取 `select:Workflow`）；没有——Codex、Cursor、OpenCode、以及任何子代理都属于这种情况——就走下面的 WORKFLOW-FALLBACK。不要用 `detect-platform.sh` 的输出来判断：它在 Claude Code 的子代理里同样返回 `claude-code`。
    会话工作目录不是项目根时，用绝对路径 `$(git rev-parse --show-toplevel)/.tad/workflows/claude/yolo-epic.workflow.js`。
    For each ⬚ Planned Phase (TWO workflow calls per phase):
    1. Y1: Activate phase (Conductor)
    2. Y2: Grounding (Conductor reads code, writes grounding file)
    3. Call 1 — design:
       Workflow({
         scriptPath: '.tad/workflows/claude/yolo-epic.workflow.js',
         args: {
           epic_path: ".tad/active/epics/EPIC-{date}-{slug}.md",
           epic_slug: "{slug}",
           phase_number: {N},
           phase_name: "{phase title from Epic}",
           handoff_path: ".tad/active/handoffs/HANDOFF-{date}-{slug}-phase{N}.md",
           completion_path: ".tad/evidence/yolo/{slug}/phase{N}-completion.md",
           grounding_path: ".tad/evidence/yolo/{slug}/phase{N}-grounding.md",
           reviewer_count: 2,
           steps: ["design"]
         }
       })
       → Y3 design sub-agent writes HANDOFF.md → Returns {handoff_path}
       ⚠️ args MUST be a JSON object, NOT a stringified JSON string.
       ⚠️ Six fields are REQUIRED: epic_path, epic_slug, phase_number, phase_name, handoff_path, completion_path.
          grounding_path, reviewer_count, steps and worktree_path are optional.
          Missing a required field → workflow returns immediately with error (0s completion).
    4. Y3b: Validate handoff (Conductor — frontmatter, grounding, AC dry-run)
    5. Call 2 — review + implement + impl_review:
       Workflow({
         scriptPath: '.tad/workflows/claude/yolo-epic.workflow.js',
         args: {
           epic_path: "{same as Call 1}",
           epic_slug: "{same as Call 1}",
           phase_number: {N},
           phase_name: "{same as Call 1}",
           handoff_path: "{same as Call 1 — must exist and be > 50 lines}",
           completion_path: "{same as Call 1}",
           grounding_path: "{same as Call 1}",
           reviewer_count: 2,
           steps: ["review", "implement", "impl_review"]
         }
       })
       → Y4 reviewers → Y5 Blake implements → Y6 impl reviewers → Returns budget_report
       Precondition: handoff must exist and be > 50 lines
    6. Y7: Gate judgment (Conductor reads all evidence files from disk)
    7. Y8: Knowledge Assessment + budget report + human checkpoint
  evidence_file_naming: "cr=code-reviewer, arch=backend-architect, fe=frontend-specialist, sec=security-auditor, ux=ux-expert-reviewer, perf=performance-optimizer. Path: .tad/evidence/yolo/{epic-slug}/phase{N}-{step}-{suffix}.md"
  WORKFLOW-FALLBACK: 没有 Workflow 工具时，按 references/yolo-manual-conductor-protocol.md 由 Conductor 手动派发子代理（设计审查 → 实施 → 实施审查），逐步落盘。
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

