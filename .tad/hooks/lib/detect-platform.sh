#!/bin/bash
# detect-platform.sh — Runtime detection of available orchestration backend
# Returns: "claude-code" | "codex" | "none"
# v3.0.0: the old Claude workflow backend was removed; only the Codex CLI signal remained.
# Workflow scripts now live in .tad/workflows/claude/ and are called through scriptPath.
# This script's output must NOT be used to decide whether the Workflow tool is available.
# As of Epic multi-harness-restore Phase 3 it has no callers.
# Epic multi-harness-restore (Phase 2): "claude-code" is detected again from the
# CLAUDECODE environment variable. Basis (2026-10-08, measured): the variable is
# present in the environment of Claude Code's Bash-tool processes (Phase 1
# baseline.txt variable-name roster, and the Phase 2 Conductor session, one
# observation each). Spike E (2026-08-03) had measured no automatic harness
# variables in a non-injected environment; do not add any other candidate
# variable based on documentation, only on a measurement.
# User can override by setting TAD_PLATFORM=claude-code|codex (or none).
# Order: TAD_PLATFORM override -> CLAUDECODE non-empty -> codex on PATH -> none.

# Override: user explicitly sets platform
if [ -n "${TAD_PLATFORM:-}" ]; then
  echo "$TAD_PLATFORM"
  exit 0
fi

# Claude Code signal (measured, see header)
if [ -n "${CLAUDECODE:-}" ]; then
  echo "claude-code"
  exit 0
fi

# Check Codex CLI availability
CODEX_AVAILABLE=0
if command -v codex >/dev/null 2>&1; then
  CODEX_AVAILABLE=1
fi

# No-signal fallback preserves the historical conservative routing. When a
# future authenticated spike measures another harness variable, add it above
# this block and update the Spike E set-equality evidence at the same time.
if [ "$CODEX_AVAILABLE" -eq 1 ]; then
  echo "codex"
else
  echo "none"
fi
printf '%s\n' "detect-platform: no automatic harness signal observed; set TAD_PLATFORM to override." >&2
