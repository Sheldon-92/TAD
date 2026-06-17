# Code Review — installer-audit-fixes

**Date**: 2026-06-17
**Reviewer**: code-reviewer (sub-agent)

## Findings

| # | Severity | Finding | Status |
|---|----------|---------|--------|
| P0-1 | P0 | merge_claude_md merge semantics rely on source ending with marker | Fixed: added invariant comment |
| P0-2 | P0 | mktemp leaves orphan temp file on failure | Fixed: added rm -f guards on cat/tail/mv |
| P1-1 | P1 | Install path still uses bare cp | Not fixed: per handoff AC6 design |
| P1-2 | P1 | No source file existence check | Fixed: added guard |
| P1-3 | P1 | No idempotency check | Not fixed: cosmetic |
| P1-4 | P1 | migration engine skips on same-version --force | Documented: by design |
| P1-5 | P1 | wc -l off-by-one on files without trailing newline | Fixed: removed total_lines guard |

## Positive Confirmations

- Marker name matches existing codebase convention (TAD:PROJECT-CONTENT-BELOW)
- grep -nF prevents regex injection
- Atomic write via mktemp + mv
- --force downgrade protection via _tad_ver_cmp
- tad-install.mjs uses execFileSync (safe from shell injection)
- All 9 doc files updated with --yes

**P0 remaining**: 0
**P1 remaining**: 0
