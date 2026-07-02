# Journal: trajectory-eval-p3 (2026-07-02)

## Shell Portability: pipefail + grep pipeline exit code interaction

**Finding**: `set -euo pipefail` + `FINDINGS=$(grep -oE 'pattern' file | sort -u | wc -l)` — when grep finds zero matches it returns exit code 1. With `pipefail`, the pipeline exit code becomes 1. In bash 5.3.3, this propagates through the variable assignment and triggers `set -e` script exit.

**Fix**: Wrap grep in a group command with `|| true`: `FINDINGS=$({ grep -oE 'pattern' file || true; } | sort -u | wc -l)`. The `|| true` catches grep's exit 1 inside the pipeline, so the pipeline exit code is 0 regardless of whether grep matched anything.

**Distinct from**: The existing "grep -c + || echo 0 double-output" pattern (shell-portability.md). That one is about `grep -c` outputting "0" to stdout AND exiting 1, causing `|| echo 0` to append a second "0". This new pattern is about `pipefail` propagating grep's exit code through a multi-stage pipeline to a variable assignment.

## Shell Portability: grep -c double-output with || echo 0

**Finding**: `HAS_P0=$(grep -ciE '\bP0\b' file || echo 0)` — when grep -c finds 0 matches, it outputs "0" to stdout AND exits with code 1. The `|| echo 0` then also outputs "0". Variable becomes "0\n0" (two lines), causing `[ "$HAS_P0" -gt 0 ]` to fail with "integer expected".

**Fix**: `HAS_P0=$(grep -ciE '\bP0\b' file) || true` — the `|| true` absorbs the exit code without adding extra output. grep -c's stdout "0" is the only value captured.
