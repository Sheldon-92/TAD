#!/bin/bash
# Hard-deny if required dependencies missing.
# Must be sourced BEFORE any payload processing.
# SECURITY: Pin PATH to eliminate attacker-controlled PATH influence on command -v.
export PATH=/usr/bin:/bin:/usr/local/bin

# SECURITY: require_dep's $1 MUST be a hardcoded literal (grep-checkable).
# Never call require_dep with a variable — future contributors must add new literal calls instead.
# Belt-and-suspenders: whitelist regex enforces this contract at runtime.
require_dep() {
  local dep="$1"
  if ! [[ "$dep" =~ ^[a-z0-9_-]+$ ]]; then
    # SECURITY: hardcoded JSON body — never interpolate any variable here.
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"TAD enforcement error: invalid dep name passed to require_dep. Contact TAD maintainer."}}'
    exit 0
  fi
  if ! command -v "$dep" >/dev/null 2>&1; then
    # Cannot use jq here (it may be the missing dep). Emit hardcoded deny.
    # Exit 0 + stdout deny JSON is the validated Claude Code permission-gate contract
    # (Epic 1 Phase 2a proved this; exit != 0 may be treated as hook error → fail-OPEN).
    # SECURITY: message body is a hardcoded literal — no $dep interpolation.
    printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"TAD enforcement requires dependency (missing). Install jq/awk or use TAD_OVERRIDE in next prompt."}}'
    exit 0
  fi
}
