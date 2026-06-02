# Architecture Review: knowledge-blame-tool

**Reviewer:** backend-architect (Layer 2)
**Date:** 2026-06-02
**Handoff:** HANDOFF-20260602-knowledge-blame-tool

## Findings

### P0

None after empirical verification. Symlink bypass initially flagged as P0 → downgraded after testing showed git blame fails-first on untracked symlinks.

### P1 (Fixed)

**P1-2: python3 dependency for absolute path normalization**
- Only non-coreutils dependency; 14 downstream projects may lack python3
- Fix: Replaced with pure-bash `${FILE#"$REPO_ROOT/"}` prefix strip

**P1-4: Symlink defense-in-depth**
- Even though empirically safe, adding `[ -L "$FILE" ]` closes the class permanently
- Fix: Added one-line symlink check before file existence check

### P1 (Noted)

**P1-1: Untracked file produces misleading BLAME_FAILED**
- Accepted: edge case for on-demand advisory tool. Could improve later.

**P1-3: Handoff section 10.2 stale**
- Alex documentation inconsistency, noted for Gate 4.

## Architecture Assessment

- **Pattern**: Bash script + SKILL advisory rule is correct (matches stale-knowledge-check.sh pattern)
- **Scope**: Three-layer defense (case guard + .. rejection + path normalization) is sufficient
- **Token budget**: 5 lines per query ≈ 200-250 tokens. Well within NFR1 (<500)
- **Sync risk**: Low. Self-contained, no new dependencies (python3 removed), fail-closed
- **Complementarity**: Clean separation from both stale-knowledge-check.sh and codebase-memory-mcp

## Verdict: PASS (after P1-2 and P1-4 fixes applied)
