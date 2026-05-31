#!/bin/bash
# TAD SessionStart Hook — Notebook Dormant Status Recompute
#
# Passively recomputes each research notebook's active/dormant status from
# `last_queried` vs the configured dormant_after_days threshold, so REGISTRY.yaml's
# persisted status does not silently go stale between *list runs.
#
# SAFETY POSTURE (load-bearing — read before editing):
#   This hook updates a DERIVED field only. It is the sanctioned exception to the
#   "Mechanical Enforcement Rejected on Single-User CLI" principle precisely because
#   it never blocks: it always finishes successfully, it never returns a block
#   decision, and it never gates any tool call. If yq is unavailable or any parse
#   fails, it simply does nothing and lets the next *list run recompute.
#   It contains no executable termination-with-failure and emits no block verdict.
#
# Output: empty JSON ({}) — the human-facing summary is owned by startup-health.sh.
# Exit code: always 0.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"
# shellcheck source=lib/notebook-lifecycle.sh
source "${SCRIPT_DIR}/lib/notebook-lifecycle.sh"

# Read stdin JSON from Claude Code.
read_stdin_json

# Only act on real session starts. If source is present and is something else
# (e.g. resume/compact), no-op. Missing/null source → run anyway.
SOURCE=$(get_json_field ".source" || echo "")
if [ -n "$SOURCE" ] && [ "$SOURCE" != "null" ] && [ "$SOURCE" != "startup" ]; then
  output_empty
  exit 0
fi

# Only relevant when TAD + a research registry are present.
REGISTRY=".tad/research-notebooks/REGISTRY.yaml"
if [ -f "$REGISTRY" ]; then
  # All failure paths inside the lib are swallowed; `|| true` is belt-and-suspenders
  # so a non-zero from the recompute can never escape and be read as a block.
  recompute_notebook_dormancy "$REGISTRY" ".tad/config-workflow.yaml" || true
fi

output_empty
exit 0
