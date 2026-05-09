# Completion Report: AGENTS.md — Codex 原生角色切换

**Date**: 2026-05-02
**Handoff**: HANDOFF-20260502-codex-agents-md.md
**Git Commit**: 4d4fee5
**Status**: Gate 3 PASS

---

## What was delivered

1. **AGENTS.md** (project root, 2956 bytes) — Codex native role-switching entry point:
   - Project overview (TAD + fallback channel disclaimer)
   - Role switching table with 9 trigger phrases per role (Chinese + English variants)
   - Alex Mode: `Read .tad/codex/codex-alex-skill.md then follow MANDATORY ACTIVATION PROTOCOL`
   - Blake Mode: `Read .tad/codex/codex-blake-skill.md then follow MANDATORY ACTIVATION PROTOCOL`
   - Default Behavior: list handoff filenames (don't read content), suggest role activation
   - Codex-Specific Notes: correct role-split for sequential-review.md (Blake) vs expert-review-sequential.md (Alex)

2. **`.tad/codex/README.md`** — Added "Recommended Entry Point" section before Quick Start explaining that `codex` interactive startup auto-loads AGENTS.md

## Acceptance Criteria

| AC | Status | Evidence |
|----|--------|----------|
| AC1 | ✅ PASS | `ls -la AGENTS.md` → exists, 2956 bytes |
| AC2 | ✅ PASS | `grep "codex-alex-skill.md\|codex-blake-skill.md" AGENTS.md` → 4 occurrences |
| AC3 | ✅ PASS | Role Switching table + trigger phrases present; 4+ switch phrase occurrences |
| AC4 | ✅ PASS | `wc -c < AGENTS.md` = 2956 < 5000 bytes |
| AC5 | ✅ PASS | Live test: `codex exec --full-auto "Per AGENTS.md, what roles are available?"` → correctly named Alex (Solution Lead) + Blake (Execution Master) with trigger phrases |
| AC6 | ✅ PASS | Live test: `codex exec --full-auto "Act as Blake. What is your Layer 1 self-check protocol?"` → Codex read codex-blake-skill.md via `sed`, answered from actual SKILL content (Ralph Loop, layer1: build/test/lint/tsc) |

## CR-P0-1 Validation Result

**引用模式 CONFIRMED WORKING** — Test used:
```bash
# AGENTS.md content: "When user says 'test mode', read .tad/codex/codex-blake-skill.md and tell me the first protocol name"
codex exec --full-auto "test mode"
# Result: Codex ran `rg -n "protocol" .tad/codex/codex-blake-skill.md` and answered "MANDATORY 4-STEP ACTIVATION PROTOCOL"
```
Used reference model (not fallback inline-summary model).

## Implementation Decisions

| Decision | Context | Chosen |
|----------|---------|--------|
| Reference model vs fallback | CR-P0-1 test confirmed Codex reads referenced files | Reference model: "Read .tad/codex/{role}-skill.md then follow protocol" |
| Trigger phrase breadth | P1-3: initial 4 phrases missed 切换到/启动/用/slash variants | Expanded to 9 phrases per role covering common Chinese + English patterns |
| Sequential-review split | P1-1: two files exist, only Blake-side was referenced | Added both: Alex (Gate 2) = expert-review-sequential.md, Blake (Layer 2) = sequential-review.md |
| Default Behavior guard | P1-2: "check handoffs" could lead Codex to read handoff content | Added "do NOT read content" + "prompt user to say 当 Blake" |
| Fallback disclaimer | P2-3: AGENTS.md had no mention Codex is fallback channel | Added blockquote at top matching README.md framing |

## Knowledge Assessment

**是否有新发现？** ✅ Yes

**Category**: architecture (Codex platform behavior)

**Discovery**: Codex CLI auto-loads `AGENTS.md` from project root on startup, analogous to Claude Code's CLAUDE.md auto-load. This gives TAD Codex users a hands-free entry point — no launcher script required for interactive use. Verified via live test (CR-P0-1 + AC5/AC6). Suggested architecture.md entry: "Codex AGENTS.md Auto-Load Mirrors Claude Code CLAUDE.md - 2026-05-02".

Note: skip_knowledge_assessment=yes in frontmatter, but this discovery is substantive enough to document per `completion_knowledge_override` rule. Adding entry to architecture.md post-completion.

## Evidence Checklist

- [x] `.tad/evidence/reviews/blake/codex-agents-md/code-reviewer.md` — Layer 2 review (P0=0, P1=3 fixed)
- [x] Git commit `4d4fee5` — AGENTS.md + README.md + evidence file
- [x] CR-P0-1 validation: Codex session `019dea7d` (引用模式 PASS)
- [x] AC5 live test: Codex session (role recognition PASS, 21775 tokens)
- [x] AC6 live test: Codex session (SKILL content load PASS)

## Deviations from Plan

None. Express handoff followed exactly as specified. All P1 issues from code-reviewer were fixed before Gate 3 (no new handoff required).
