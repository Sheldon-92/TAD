# Code Review: *dream Knowledge Consolidation

**Reviewer:** code-reviewer (sub-agent)
**Date:** 2026-05-14
**Scope:** dream-validator.sh, SKILL.md dream_protocol, candidate architecture.md

## P0 Issues (Resolved)

1. **Division by zero in validator** — `ORIG_ENTRIES=0` or `ORIG_LINES=0` caused crash under `set -e`. Fixed: added zero-check guards.
2. **`grep -coE` platform-divergent semantics** — BSD vs GNU grep count differently. Fixed: changed to `grep -cE` (line counting) with explicit comment.

## P1 Issues (Resolved)

3. **CWD-dependent path check** — added contract comment requiring project root CWD.
4. **Tilde path expansion missing** — added `${p/#\~/$HOME}` expansion.
5. **Candidate removed ALL Grounded-in lines** — noted as intentional compression; provenance preserved via Supersedes notes + snapshot backup.
6. **Same-day snapshot overwrite** — fixed: timestamp format `{YYYY-MM-DD-HHMMSS}`.
7. **`ls -td` fragile** — fixed: `ls -d ... | sort -r | head -1` for ISO date dirs.

## P2 Observations

8. Merge quality is high — 7 Codex entries → 2, safety flagged correctly.
9. Protocol gap: entries added after candidate generation not detected. Noted for future.
10. "70% topic overlap" vague — fixed: replaced with 3 deterministic merge rules.
11. Missing guard for candidate longer than original — fixed: WARN added.
12. Quick Reference "My Workflow" doesn't mention *dream — minor, Key Commands does.

## Verdict: PASS (after fixes)
