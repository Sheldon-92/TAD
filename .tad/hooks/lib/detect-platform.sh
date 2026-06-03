#!/bin/bash
# detect-platform.sh — Runtime detection of available orchestration backend
# Returns: "workflow" | "codex" | "none"

# Tier 1a: Claude Code with Workflow tool (capability check, not file-system)
if [ -n "${CLAUDE_CODE_SESSION:-}" ] || [ -n "${CC_SESSION:-}" ]; then
  echo "workflow"
  exit 0
fi
# Heuristic fallback: check if parent process is claude (exact match)
if ps -o comm= -p "$PPID" 2>/dev/null | grep -qix "claude"; then
  echo "workflow"
  exit 0
fi

# Tier 1b: Codex CLI available
if command -v codex >/dev/null 2>&1; then
  if codex --version >/dev/null 2>&1; then
    echo "codex"
    exit 0
  fi
fi

# Tier 3: No orchestration available
echo "none"
exit 0
