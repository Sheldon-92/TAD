# Layer 2 Code Review — Web Backend Capability Pack

**Date**: 2026-05-07
**Reviewer**: code-reviewer sub-agent
**Scope**: CAPABILITY.md, install.sh, all 4 scripts, references/security.md, references/database.md

## Verdict: PASS (post-fix)

P0 found: 1 (fixed before Layer 2 final verdict)
P1 found: 2 (fixed)
P2 found: 3 (advisory)

## P0 (Fixed)

### P0-1: readiness-score.sh silent abort on projects without src/app/lib
`set -euo pipefail` + `$(grep ... "$ROOT/src" "$ROOT/app" "$ROOT/lib")` caused
script to abort silently when any of the three directories didn't exist (grep exits 2).
**Fix**: Built SRC_DIRS array of existing directories; same pattern applied to PC-12 and PC-15.

## P1 (Fixed)

### P1-1: Spectral OWASP ruleset invocation
`npx --yes @stoplight/spectral-cli --ruleset @stoplight/spectral-owasp-rules` failed
because the OWASP rules package was not installed alongside spectral-cli.
**Fix**: Changed to `npx --yes -p @stoplight/spectral-cli -p @stoplight/spectral-owasp-rules`
to install both packages in the same npx invocation.

### P1-2: pip-audit --severity flag doesn't exist
pip-audit has no `--severity high` flag.
**Fix**: Removed `--severity high` from security-scan.sh pip-audit invocation.

## P2 (Advisory — not blocking)

### P2-1: EXCLUDE_DIRS/EXCLUDE_FILES unquoted strings in security-scan.sh
Future maintainer adding path with spaces would silently break grep. Worth migrating
to bash arrays, but non-blocking for current use.

### P2-2: install.sh silently ignores --global when .claude/ exists locally
Should print a note. Non-blocking.

### P2-3: schema-check.sh soft-delete heuristic checks whole corpus not per-table
The while loop checks `grep -qi "deleted_at"` against ALL_SQL, so if any table has
deleted_at, no table is ever flagged. Heuristic quality issue.

## What's Working Well
- CAPABILITY.md is a genuinely pure router with zero inline rules
- Anti-skip table arguments are empirically defensible
- All "never" usage in references is properly context-scoped or has explicit exceptions
- Phase 3 stubs use correct exit 2 with informative messages
- bash -n passes all 4 scripts
