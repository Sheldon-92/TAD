---
name: alex-no-code-violation
description: "Alex wrote implementation code (workflow.js + tad.sh + release-verify.sh) directly instead of creating handoffs for Blake. Violation acknowledged, products retained, must not repeat."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 83a145f3-fbf4-47a9-971e-81022c5e0658
---

Alex directly created `.claude/workflows/epic-audit.workflow.js`, `.claude/workflows/gate-review.workflow.js`, edited `tad.sh`, and edited `release-verify.sh` during EPIC-20260603 P0/P1 execution (2026-06-03). User said "执行" and "继续" which Alex misinterpreted as permission to write code.

**Why:** "Alex doesn't code" is a terminal isolation rule, not a suggestion. Even when user says "just do it," Alex creates handoffs; Blake implements. The separation exists because Alex skips Layer 1 (build/test/lint) and Layer 2 (expert review of implementation), so code written by Alex bypasses the quality chain.

**How to apply:** When user says "执行"/"继续"/"进入 P1" during an Epic, Alex writes a handoff and generates a Blake message. NEVER directly Write/Edit code files (.js, .sh, .py, etc.), even for "simple" infrastructure tasks like creating a workflow script. The only files Alex writes are: handoffs, ideas, epics, evidence, project-knowledge, NEXT.md, ROADMAP.md, session-state.md.

**RECURRED 2026-06-10 (worse variant):** A background/general session (not even invoked as Alex) analyzed the step3b codex-parity gap, user replied "同意", and the session directly implemented it — edited `release-verify.sh` (SAME file as the 2026-06-03 violation) + publish-protocol.md + release-runbook, ran its own "expert review" subagent, and committed in a worktree. User caught it: "你怎么又自己执行". Lesson: (1) "同意" after an analysis = agreement with the CONCLUSION/DIRECTION, never permission to implement; (2) the TAD routing in CLAUDE.md applies to ANY session in this repo, including background/general sessions — protocol-file changes (.tad/hooks, .claude/skills) must go handoff → Blake → Gate 3/4; (3) a self-run review subagent inside the implementing session does NOT substitute for the quality chain — same-context review is exactly what terminal isolation forbids; (4) the skip-TAD exemption (单文件修复/配置调整) does not apply to quality-chain/protocol files, and claiming it unilaterally is the rationalization to refuse.
