# Code Review — TASK-20260504-003

**Reviewer**: code-reviewer subagent  
**Date**: 2026-05-04  
**Handoff**: HANDOFF-20260504-research-director-phase2.md

## Critical Issues (P0)

**None.** All 9 Gate 2 P0s (CR-P0-2, CR-P0-3, CR-P0-4, BA-P0-1, BA-P0-2, BA-P0-3, CR-P1-2/AC3/AC4 split) correctly resolved.

## Recommendations (P1)

### P1-1: AC14 in handoff spec says "(B8)" — typo, should be "(B6)"
- **File**: HANDOFF-20260504-research-director-phase2.md line 524
- **Status**: Handoff spec typo, NOT an implementation bug. Implementation correctly delegates to consolidate (B6).
- **Action**: Document as INTENT-PASS-LITERAL-DOC-TYPO in completion report. This is the 5th consecutive phase with AC verification drift.

### P1-2: SKILL.md description said "14 sub-commands" ✅ FIXED
- Updated to "19 sub-commands" 

### P1-3: capabilities.yaml skill_ref listed 14 commands ✅ FIXED
- Updated to 19 commands with all new names listed

### P1-4: No capability entry for `*research-notebook consolidate`
- AC21 doesn't require it. Defer to *evolve cycle.

## Suggestions (P2)

- P2-1: *research-review not in on_start greeting/Quick Reference — discoverability gap
- P2-2: A4 trigger mentions STEP 3.8 outputting consolidation suggestion (spec ambiguity, not defect)
- P2-3: step4_close lacks batch-confirm guard for many 📦 notebooks
- P2-4: No version-pin caveat in quiz/flashcards commands
- P2-5: A2 "先看源质量" could use explicit source-ID resolution instead of nested AskUserQuestion

## Focus Area Verification

1. ✅ Protocol consistency: all new commands follow Step 0 → Steps → REGISTRY pattern
2. ✅ B2 --save-as-note: SKILL explicitly states CALLER'S RESPONSIBILITY; not auto-added
3. ✅ A3 step0_5b: confirmed PEER step (same indent as step0_5, step1)
4. ✅ A4 delegates to B6: "Delegate execution to *research-notebook consolidate (B6). Do NOT re-implement merge logic"
5. ✅ A6 4-step classification: 全景扫描 → 分类诊断(加强/维持/转向/关闭) → 行动建议 → step4 variants
6. ✅ AC18 Research Portfolio AFTER Ideas: line 789 (Ideas) precedes line 798 (Research Portfolio)
7. ✅ YAML structure: no broken code blocks, no indent issues

## Overall Assessment

**PASS** (P1-2 and P1-3 applied; P1-1 is handoff typo documented; P1-4 deferred)
