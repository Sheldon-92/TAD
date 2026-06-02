# Code Review: knowledge-blame-tool

**Reviewer:** code-reviewer (Layer 2)
**Date:** 2026-06-02
**Handoff:** HANDOFF-20260602-knowledge-blame-tool

## Findings

### P0 (Fixed)

**P0-1: SIGPIPE exit 141 in summary mode**
- `git log | head -5` under `set -o pipefail` exits 141 when git log produces >5 lines
- Fix: Changed to `git log -5` (limit at git level, no pipe breakage)

### P1 (Fixed)

**P1-1: Unbound variable on missing option argument**
- `--line` or `--search` without a value → `$2: unbound variable` under `set -u`
- Fix: Added `[ $# -ge 2 ]` guard before accessing `$2`

**P1-2: Handoff section 10.2 stale (says 20 lines, impl is 5)**
- Alex-side documentation inconsistency. Noted for Gate 4.

### P2

- P2-1: python3 dependency for path conversion → replaced with pure-bash prefix strip
- P2-2: Glob wildcard in case allows nested paths (harmless, no such paths exist)
- P2-3: Handoff Task 3 template had stale /CONTEXT — Blake correctly omitted
- P2-4: CWD-relative path check (mitigated: agents always run from repo root)

## Verdict: PASS (after P0-1 fix applied)
