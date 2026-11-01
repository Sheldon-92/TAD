#!/bin/bash
# TAD SessionStart Hook — Project Health Summary
# Injects TAD status into every new session via additionalContext.
# Output: JSON with hookSpecificOutput wrapper.
# Exit code: always 0 (never block session startup).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=lib/hook-envelope.sh
source "${SCRIPT_DIR}/lib/hook-envelope.sh"
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# Check normalized source — only run on "startup" (or if field missing, run anyway).
# HOOK_SOURCE is intentionally empty when Codex has no equivalent field.
SOURCE="${HOOK_SOURCE:-}"

# Post-compact reminder (FR4, HANDOFF-20260712-precompact-session-state-hook):
# after a compaction, point the agent at the agent-written session state plus the
# newest mechanical PreCompact snapshot. Must run BEFORE the non-startup early exit.
if [ "$SOURCE" = "compact" ]; then
  output_response "SessionStart" "Post-compact: read .tad/active/session-state.md + newest .tad/active/precompact/snapshot-*.md before continuing."
  exit 0
fi

if [ -n "$SOURCE" ] && [ "$SOURCE" != "null" ] && [ "$SOURCE" != "startup" ]; then
  output_empty
  exit 0
fi

# Check if TAD is initialized
if [ ! -d ".tad" ]; then
  output_response "SessionStart" "TAD not initialized in this project."
  exit 0
fi

# Gather health metrics
HANDOFF_COUNT=$(safe_count ".tad/active/handoffs/HANDOFF-*.md")
EPIC_COUNT=$(safe_count ".tad/active/epics/EPIC-*.md")
IDEA_COUNT=$(safe_count ".tad/active/ideas/IDEA-*.md")

# Check for blocked items in NEXT.md
HAS_BLOCKED=""
if [ -f "NEXT.md" ] && grep -q "## Blocked" NEXT.md 2>/dev/null; then
  HAS_BLOCKED=" | has blocked items"
fi

# Claude Code reads CLAUDE.md instead of AGENTS.md when both exist, so a CLAUDE.md that does not pull
# AGENTS.md in silently switches TAD routing off. Read-only warning; a symlinked CLAUDE.md (usually
# CLAUDE.md -> AGENTS.md) is left alone. The wording names Claude Code because this hook runs on every
# harness and cannot tell which one it is on. Uses the same own-line @AGENTS.md pattern as the installer (tad.sh).
CLAUDE_MD_WARN=""
if [ -f "AGENTS.md" ] && [ -f "CLAUDE.md" ] && [ ! -L "CLAUDE.md" ] && ! grep -Eq '^@AGENTS\.md[[:space:]]*$' CLAUDE.md 2>/dev/null; then
  CLAUDE_MD_WARN=" | CLAUDE.md has no @AGENTS.md line: Claude Code will not load AGENTS.md"
fi

# Read TAD version
VERSION="unknown"
if [ -f ".tad/config.yaml" ]; then
  # Extract version from config.yaml
  if [ "$HAS_JQ" = true ] && command -v yq >/dev/null 2>&1; then
    VERSION=$(yq -r '.version' .tad/config.yaml 2>/dev/null || echo "unknown")
  else
    VERSION=$(grep -m1 '^version:' .tad/config.yaml 2>/dev/null | sed 's/version:[[:space:]]*//' | tr -d '"' || echo "unknown")
  fi
fi

# Component health check (IDEA-20260403-session-health-check): verify framework
# components are intact at startup — hook scripts exist and parse, the config
# version carriers agree, and core templates exist non-empty. Warning only:
# this hook never blocks startup (see header contract); broken components are
# NAMED in the summary so the breakage is visible instead of silent.
COMPONENT_BROKEN=""
component_flag() {
  if [ -n "$COMPONENT_BROKEN" ]; then
    COMPONENT_BROKEN="${COMPONENT_BROKEN}; $1"
  else
    COMPONENT_BROKEN="$1"
  fi
}

# 1. Hook scripts: shipped lifecycle entry points + the libs this hook sources.
for hook_file in \
  .tad/hooks/startup-health.sh \
  .tad/hooks/post-write-sync.sh \
  .tad/hooks/pre-accept-check.sh \
  .tad/hooks/pre-gate-check.sh \
  .tad/hooks/precompact-session-snapshot.sh \
  .tad/hooks/trace-step.sh \
  .tad/hooks/notebook-dormant-sync.sh \
  .tad/hooks/lib/hook-envelope.sh \
  .tad/hooks/lib/common.sh
do
  if [ ! -f "$hook_file" ]; then
    component_flag "missing hook script: ${hook_file}"
  elif ! bash -n "$hook_file" 2>/dev/null; then
    component_flag "hook script fails bash -n: ${hook_file}"
  fi
done

# 2. Config version consistency: version.txt, TAD-VERSION and config.yaml
#    (VERSION read above) must all agree; a missing carrier is itself broken.
VERSION_TXT=""
[ -f ".tad/version.txt" ] && VERSION_TXT=$(tr -d '[:space:]' < .tad/version.txt)
VERSION_FILE=""
[ -f ".tad/TAD-VERSION" ] && VERSION_FILE=$(tr -d '[:space:]' < .tad/TAD-VERSION)
if [ -z "$VERSION_TXT" ]; then
  component_flag "missing version carrier: .tad/version.txt"
fi
if [ -z "$VERSION_FILE" ]; then
  component_flag "missing version carrier: .tad/TAD-VERSION"
fi
if [ -n "$VERSION_TXT" ] && [ -n "$VERSION_FILE" ] && [ "$VERSION_TXT" != "$VERSION_FILE" ]; then
  component_flag "version mismatch: version.txt=${VERSION_TXT} vs TAD-VERSION=${VERSION_FILE}"
fi
if [ -n "$VERSION_TXT" ] && [ "$VERSION" != "unknown" ] && [ "$VERSION_TXT" != "$VERSION" ]; then
  component_flag "version mismatch: version.txt=${VERSION_TXT} vs config.yaml=${VERSION}"
fi

# 3. Core templates intact (exist and non-empty).
for template_file in \
  .tad/templates/completion-report.md \
  .tad/templates/deliverable-completion.md \
  .tad/templates/deliverable-handoff.md
do
  if [ ! -s "$template_file" ]; then
    component_flag "template missing or empty: ${template_file}"
  fi
done

COMPONENT_WARN=""
if [ -n "$COMPONENT_BROKEN" ]; then
  COMPONENT_WARN=" | ⚠ BROKEN components: ${COMPONENT_BROKEN}"
fi

# Build summary
SUMMARY="TAD v${VERSION} | ${HANDOFF_COUNT} handoffs | ${EPIC_COUNT} epics | ${IDEA_COUNT} ideas${HAS_BLOCKED} | Hooks: active${CLAUDE_MD_WARN}${COMPONENT_WARN}"

# Update reminder (EPIC-20261022-tad-update-flow Phase 2): at most one extra line per day per project,
# only when a newer TAD exists and the envelope names a session. Reminder only: it starts nothing.
if [ -f "${SCRIPT_DIR}/lib/update-reminder.sh" ]; then
  # shellcheck source=lib/update-reminder.sh
  source "${SCRIPT_DIR}/lib/update-reminder.sh" 2>/dev/null || true
  REMINDER_LINE=""
  if command -v update_reminder_line >/dev/null 2>&1; then
    REMINDER_LINE="$(update_reminder_line 2>/dev/null || true)"
  fi
  if [ -n "$REMINDER_LINE" ]; then
    SUMMARY="${SUMMARY}
${REMINDER_LINE}"
  fi
fi

output_response "SessionStart" "$SUMMARY"
exit 0
