#!/bin/bash
# detect-platform.sh — Runtime detection of available orchestration backend
# Returns: "workflow" | "codex" | "none"
# Known limitation: cannot reliably distinguish Claude Code from Codex
# when BOTH are available. Defaults to "workflow" (higher quality).
# User can override by setting TAD_PLATFORM=codex (or workflow/none).

# Override: user explicitly sets platform
if [ -n "${TAD_PLATFORM:-}" ]; then
  echo "$TAD_PLATFORM"
  exit 0
fi

# Check Codex CLI availability
CODEX_AVAILABLE=0
if command -v codex >/dev/null 2>&1; then
  CODEX_AVAILABLE=1
fi

# Check workflow files exist (proxy for Claude Code project with workflows)
WORKFLOW_AVAILABLE=0
if ls .claude/workflows/*.workflow.js >/dev/null 2>&1; then
  WORKFLOW_AVAILABLE=1
fi

# Priority: workflow > codex > none
# (workflow = Claude Code Workflow tool, higher quality than sequential codex exec)
if [ "$WORKFLOW_AVAILABLE" -eq 1 ]; then
  echo "workflow"
elif [ "$CODEX_AVAILABLE" -eq 1 ]; then
  echo "codex"
else
  echo "none"
fi
