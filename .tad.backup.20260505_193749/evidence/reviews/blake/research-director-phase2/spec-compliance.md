# Spec Compliance Review — TASK-20260504-003

**Reviewer**: general-purpose subagent  
**Date**: 2026-05-04  
**Handoff**: HANDOFF-20260504-research-director-phase2.md

## AC Verification Table

| AC# | Status | Evidence | Gap |
|-----|--------|----------|-----|
| AC1 | SATISFIED | research-notebook SKILL line 28: `auth check --test 2>&1 | grep -q 'authenticated'` | None |
| AC2 | SATISFIED | lines 124-128: Step 2.5 source targeting with `--source <id>` flags | None |
| AC3 | SATISFIED | lines 131-138: `--save-as-note --note-title` supported; caller's responsibility | None |
| AC4 | SATISFIED | lines 133,138: `--no-save` flag supported | None |
| AC5 | SATISFIED | lines 376-389: Step 1.5 with `--append`, `--source`, `--retry 3` | None |
| AC6 | SATISFIED | lines 554-578: fulltext command with 3 steps | None |
| AC7 | SATISFIED | lines 583-601: language [set|get|list] all present | None |
| AC8 | SATISFIED | lines 605-639: consolidate command exists, 4-step | None |
| AC9 | SATISFIED | lines 643-697: quiz + flashcards with markdown download | None |
| AC10 | SATISFIED | alex SKILL: step3_5_quiz_generation after learn step3 | None |
| AC11 | SATISFIED | alex SKILL lines 113-133: STEP 3.8 with interacts_with | None |
| AC12 | SATISFIED | lines 629-662: upgraded with fulltext option and deep research | None |
| AC13 | SATISFIED | lines 1931-1947: step0_5b peer step before step1 | None |
| AC14 | SATISFIED | lines 2481-2484: delegates to consolidate, no re-implement | None |
| AC15 | SATISFIED | lines 2444-2460: research_citation_in_handoff section | None |
| AC16 | SATISFIED | line 199 commands list + lines 420-421 enters_standby | None |
| AC17 | SATISFIED | lines 835-883: 4-step protocol with 4-category classification | None |
| AC18 | SATISFIED | step1 scans REGISTRY (line 760) + step2 Research Portfolio after Ideas (line 798) | None |
| AC19 | SATISFIED | lines 667-673: passive_detection_during_discuss block | None |
| AC20 | PARTIALLY_SATISFIED | All SKILL.md execution paths use absolute path. capabilities.yaml cli_command docs use bare path (catalog-only, not execution) | Catalog fields use bare path — acceptable |
| AC21 | SATISFIED | capabilities.yaml lines 75-120: 4 new entries added | None |

## Summary

- NOT_SATISFIED: 0
- PARTIALLY_SATISFIED: 1 (AC20 — catalog field only, not execution path)
- **Overall: PASS**
