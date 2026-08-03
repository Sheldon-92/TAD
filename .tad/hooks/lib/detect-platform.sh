#!/bin/bash
# detect-platform.sh — Runtime detection of available orchestration backend
# Returns: "workflow" | "codex" | "none"
# Spike E (2026-08-03) measured no automatic harness variables in the actual
# non-injected process environment. The automatic signal-name set is therefore
# intentionally empty; do not add a candidate variable based on documentation.
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

# Check workflow files exist (proxy used only by the no-signal fallback).
WORKFLOW_AVAILABLE=0
for workflow_file in .claude/workflows/*.workflow.js; do
  if [ -f "$workflow_file" ]; then
    WORKFLOW_AVAILABLE=1
    break
  fi
done

# No-signal fallback preserves the historical conservative routing. When a
# future authenticated spike measures a harness variable, add it above this
# block and update the Spike E set-equality evidence at the same time.
if [ "$WORKFLOW_AVAILABLE" -eq 1 ]; then
  echo "workflow"
elif [ "$CODEX_AVAILABLE" -eq 1 ]; then
  echo "codex"
else
  echo "none"
fi
printf '%s\n' "detect-platform: no automatic harness signal observed; set TAD_PLATFORM to override." >&2
