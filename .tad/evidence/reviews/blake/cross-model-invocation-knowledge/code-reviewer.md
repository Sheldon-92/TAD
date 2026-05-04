# Code Review — TASK-20260504-004 Cross-Model CLI Invocation Knowledge

**Reviewer**: code-reviewer subagent
**Date**: 2026-05-04
**Round**: 1 (Round 2 not needed — all P0/P1 resolved)

## Summary

Two P0 correctness defects (invalid Codex flags in flag table; `git diff HEAD~1` wrong semantics) + three P1 design issues (missing forbidden_implementations; duplicate NOT_via_alex_auto keys; venv-PATH gotcha missing) + P2 advisories.

## Findings

### P0 (Resolved)
- **P0-1**: `--permission-mode` and `--settings` rows in Codex flag table are `claude -p` flags, not `codex exec` flags → REMOVED
- **P0-2**: `git diff HEAD~1` includes uncommitted WIP; changed to `git diff HEAD~1..HEAD` in both guide and Blake SKILL

### P1 (Resolved)
- **P1-1**: Missing `forbidden_implementations` blocks in both SKILL sections → ADDED (5 items Alex, 5 items Blake)
- **P1-2**: Duplicate `NOT_via_alex_auto` keys at different YAML scopes → CONSOLIDATED to single top-level boolean
- **P1-3**: No venv-PATH caveat for `command -v` → NOTE ADDED to guide Preflight section
- **P1-4**: AC8 INTENT-PASS-LITERAL-FAIL (5th occurrence of recurring process defect) → Documented in gate4_delta

### P2 (Advisory — not fixed)
- P2-1: stderr silence pattern could be more explicit
- P2-2: Gemini stdin semantics not explicitly stated
- P2-3: SKILL sections could cite validation dates inline

## Verdict: PASS (after P0/P1 fixes applied)

P0=0, P1=0 remaining. AC1-AC8 all verified.
