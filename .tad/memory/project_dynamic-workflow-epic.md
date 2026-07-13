---
name: dynamic-workflow-epic
description: "Dynamic Workflow Integration Epic complete (6 phases). 5 workflows + 1 cross-platform adapter. Codex 3-round audit 12→16→18/25. 2 P2 remain (cwd-relative detect-platform, test harness)."
metadata: 
  node_type: memory
  type: project
  originSessionId: 83a145f3-fbf4-47a9-971e-81022c5e0658
---

Epic EPIC-20260603-dynamic-workflow-integration completed 2026-06-03 (archived). Source: Thariq article "A harness for every task: dynamic workflows in Claude Code."

**Why:** TAD's orchestration was static SKILL.md prose (~6000 lines). Dynamic workflows make orchestration deterministic JS, SKILL.md keeps only judgment rules.

**Deliverables:**
- `.claude/workflows/epic-audit.workflow.js` (fan-out + adversarial + synthesis)
- `.claude/workflows/gate-review.workflow.js` (per-AC verifier + skeptic)
- `.claude/workflows/tournament-design.workflow.js` (N competitors + pairwise judge + merge)
- `.claude/workflows/yolo-epic.workflow.js` (hybrid Conductor + workflow, budget reporting)
- `.claude/workflows/loop-discover.workflow.js` (loop until K dry rounds)
- `.tad/hooks/lib/detect-platform.sh` + `.tad/codex/tournament-codex.sh` (cross-platform)
- SKILL.md reduced by 211 lines (YOLO 240→30 line stub)

**Codex 3-round audit:** 12/25 → 16/25 → 18/25. Safety 2→3→4. Two P0 safety bugs found and fixed (YOLO stop-on-P0 + Y6 fail-closed).

**How to apply:** Remaining P2s for next session: (1) detect-platform.sh cwd-relative → use `$TAD_ROOT` or `git rev-parse --show-toplevel`; (2) implement 5-case deterministic test harness from `.tad/evidence/research/2026-06-03-workflow-safety-validation.md` follow-up section. These two get Codex to 20+/25 PRODUCTION-READY.

**Alex violation recorded:** P0/P1 Alex wrote workflow code directly (feedback_alex-no-code-violation.md). P2-P5 corrected to strict handoff flow.
