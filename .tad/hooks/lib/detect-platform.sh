#!/bin/bash
# detect-platform.sh — Runtime detection of available orchestration backend
# Returns: "codex" | "none"
# v3.0.0: the Claude workflow backend (.claude/workflows) was removed;
# only the Codex CLI signal remains.
# Spike E (2026-08-03) measured no automatic harness variables in the actual
# non-injected process environment. The automatic signal-name set is therefore
# intentionally empty; do not add a candidate variable based on documentation.
# User can override by setting TAD_PLATFORM=codex (or none).

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

# No-signal fallback preserves the historical conservative routing. When a
# future authenticated spike measures a harness variable, add it above this
# block and update the Spike E set-equality evidence at the same time.
if [ "$CODEX_AVAILABLE" -eq 1 ]; then
  echo "codex"
else
  echo "none"
fi
printf '%s\n' "detect-platform: no automatic harness signal observed; set TAD_PLATFORM to override." >&2
