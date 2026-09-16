#!/usr/bin/env bash
# memory-redirect.sh — RETIRED in TAD v3.0.0.
# This tool pointed Claude Code auto-memory (.claude/settings.local.json +
# ~/.claude/projects/<slug>/memory) at .tad/memory/. The Claude Code runtime
# path was removed, so this Claude-only memory layer is retired with it.
# .tad/memory/ itself is untouched — only the redirect mechanism is gone.
# Any invocation fails closed with this explanation (no mutation).
set -euo pipefail

echo "ERROR: memory-redirect.sh was retired in TAD v3.0.0 (Claude Code memory layer removed)." >&2
echo "  .tad/memory/ is left in place (data untouched); no redirect is performed." >&2
exit 2
