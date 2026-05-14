# Code Review: audit-yolo.sh

**Reviewer**: code-reviewer (Layer 2)
**Date**: 2026-05-14

## P0 (Fixed)
- **P0-2**: `IFS=$'\n\t'` breaks `for n in $PHASES` word splitting on spaces — showstopper for multi-phase. Fix: switched to bash array `PHASES_ARR`.
- **P0-1**: Arithmetic with potentially empty vars under `set -e`. Fix: added `${var:-0}` defensive defaults.

## P1 (Fixed)
- **P1-1**: `head -1` SIGPIPE risk with pipefail. Fix: replaced with `-print -quit` and `sed -n '1p'`.
- **P1-3**: P0/P1/P2 regex too permissive. Fix: `(^|[^A-Za-z0-9])P[012]([^A-Za-z0-9]|$)`.
- **P1-7**: `wc -l > 100` broken shell. Not applicable — threshold not in final version.

## P2 (Advisory)
- P2-3: AC count counts unchecked only → now counts both `[x]` and `[ ]`
- P2-4: Epic search order → now active first, archive second

## Verdict: PASS
