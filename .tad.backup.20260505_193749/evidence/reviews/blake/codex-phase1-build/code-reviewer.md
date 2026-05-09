# Code Review — codex-phase1-build

**Date**: 2026-05-01
**Reviewer**: code-reviewer (subagent)
**Overall**: PASS (P0=0, P1=1 fixed before Gate 3, P2=7 advisories)

## P1 Issues (Fixed)

### P1-1 (FIXED): Pre-flight write-test cleanup outside if/else
**Location**: codex-tad-blake.sh lines 49-59
**Issue**: `rm -f` was inside `else` branch. Sentinel `/tmp/.tad-write-test` had fixed name (concurrent-run race). With set -e, rm failure could terminate script.
**Fix applied**: Switched to mktemp for unique per-process path. Moved `rm -f` outside if/else (always cleanup). Changed 3-second auto-continue to `exit 1` with clear message (avoids burning token budget in known-broken sandbox).
**Status**: RESOLVED

## P2 Issues (Advisory)

### P2-1 (Addressed in P1 fix): 3-second auto-continue past known-broken sandbox
Resolved by changing to `exit 1` — user gets clear error instead of continuing into failure.

### P2-2: wc -c produces leading whitespace in echoed sizes
The `Size:    26576 bytes` leading spaces come from BSD wc on macOS. Cosmetic; AC9/AC10 use `wc -c < FILE` directly so this doesn't affect AC verification. Low priority.

### P2-3: portable-extract.sh cp -r non-idempotent
`cp -r .tad/codex/ dst/.tad/codex/` on macOS BSD creates nested `dst/.tad/codex/codex/` on re-runs. Suggest `rm -rf "$OUTPUT_DIR"` at start or `cp -R "$src/." "$dst/"` form.

### P2-4: portable-extract.sh always exits 0 even when files skipped
Should exit 2 when skip_count > 0 to signal partial extraction to callers.

### P2-5: Flag handling accepts only first positional arg
`case "${1:-}"` doesn't handle `--dry-run --help` combos. Sufficient for current UX.

### P2-6: Unknown flags silently ignored
Add `*) echo "unknown flag: $1"; exit 2 ;;` clause to case statement.

### P2-7: Alex launcher always exits 0 on read-only sandbox
Alex is read-only by design (design/analysis only, no file writes). No pre-flight test needed for Alex. Consistent with §4.2 design.

## Architecture Notes
- Project root detection via `dirname "$0"` is correct and resilient to symlinks
- Codex CLI invocation `cat file | codex exec --full-auto "prompt"` matches §10.3 verified syntax
- No injection vectors found
- All scripts have `set -euo pipefail`
- AC1-AC12 verification confirmed (except AC11 pending completion protocol)

## Verdict
**PASS** — P0=0, P1=0 (1 P1 fixed), P2=7 advisory
