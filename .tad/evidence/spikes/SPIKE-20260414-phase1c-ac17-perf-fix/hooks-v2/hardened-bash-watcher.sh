#!/bin/bash
# Hardened Bash write-path watcher (Phase 1b, Category 8 — NEW v2).
#
# In production this would be a PreToolUse hook matching Bash tool.
# For this spike, we simulate by consuming the same stdin envelope shape
# that Claude Code would deliver, with tool_name == "Bash" and
# tool_input.command == the bash command string.
#
# Detects Bash attacks that bypass the Write/Edit matcher:
#   1. Redirect into evidence: `echo ... > evidence/...`
#   2. Tee into evidence: `tee evidence/...`
#   3. Heredoc: `cat <<EOF > evidence/...`
#   4. Hardlink/symlink: `ln [-s] ... evidence/...`
#   5. Move into place: `mv X evidence/...`
#   6. Env injection: TAD_SKIP_VALIDATION=1, CLAUDE_SETTINGS_PATH=..., etc.
#
# Fail-closed (5 triggers as hardened-pretool).

set -euo pipefail

# ── TAD Phase 1c AC17 fix: dep-guard (hard-deny if jq/awk missing) ──
source "${BASH_SOURCE[0]%/*}/lib/dep-guard.sh"
require_dep jq
# ── end dep-guard block ──

emit_deny_crash() {
  local reason="${1:-hook crashed - fail closed}"
  printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"'
  printf '%s' "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g'
  printf '%s\n' '"}}'
  exit 0
}
trap 'emit_deny_crash "hook crashed - fail closed (trap)"' ERR

emit_allow() {
  printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow"}}'
  exit 0
}

emit_deny() {
  local reason="$1"
  if command -v jq >/dev/null 2>&1; then
    jq -nc --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  else
    emit_deny_crash "missing dep: jq"
  fi
  exit 0
}

for dep in jq; do
  command -v "$dep" >/dev/null 2>&1 || emit_deny_crash "missing dep: $dep"
done

STDIN_JSON=$(cat) || emit_deny_crash "stdin read failed"
[ -n "$STDIN_JSON" ] || emit_deny_crash "stdin empty (EOF)"

tool_name=$(printf '%s' "$STDIN_JSON" | jq -r '.tool_name // ""' 2>/dev/null) || emit_deny_crash "JSON malformed (tool_name)"
command=$(printf '%s' "$STDIN_JSON" | jq -r '.tool_input.command // ""' 2>/dev/null) || emit_deny_crash "JSON malformed (command)"

[ "$tool_name" = "Bash" ] || emit_allow

# Normalize: strip Unicode homoglyphs, zero-width chars, AND empty quote pairs
# (evi''dence/ attack — shell collapses the pair, but naive string match fails).
# Use hex escapes \x22 (") and \x27 (') to avoid shell-quoting nesting.
normalized=$(printf '%s' "$command" | perl -CSD -MUnicode::Normalize -e '
  my $s = do { local $/; <STDIN> };
  $s = NFKC($s);
  $s =~ s/[\x{200B}\x{200C}\x{200D}\x{FEFF}\x{2060}\x{180E}]//g;
  $s =~ s/\x22\x22//g;  # strip empty "" pairs
  $s =~ s/\x27\x27//g;  # strip empty '' pairs
  print $s;
' 2>/dev/null) || emit_deny_crash "normalization failed"

# Patterns — greedy OR, matched against normalized command
# Use lowercased copy for case-insensitive checks
lower=$(printf '%s' "$normalized" | tr '[:upper:]' '[:lower:]')

# Evidence write-path attacks (cat 8)
# Pattern set — intentionally broad. Any match → deny.
# Direct redirect into evidence path
if printf '%s' "$lower" | grep -qE '(^|[[:space:]&|;\(])(>|>>)[[:space:]]*.tad/evidence/(reviews|overrides)/'; then
  emit_deny "bash redirect into evidence path detected"
fi
# Variable-assignment laundering: X=.tad/evidence/... or X=.tad/active/...
if printf '%s' "$lower" | grep -qE '(^|[[:space:];&|])[a-z_][a-z0-9_]*=[[:space:]]*"?.tad/(evidence|active)/'; then
  emit_deny "bash variable assigned to protected path (.tad/evidence or .tad/active) — laundering attempt"
fi
if printf '%s' "$lower" | grep -qE 'tee[[:space:]]+(-a[[:space:]]+)?.tad/evidence/(reviews|overrides)/'; then
  emit_deny "bash tee into evidence path detected"
fi
if printf '%s' "$lower" | grep -qE '<<[-]?[a-z0-9_"'"'"']*.*>[[:space:]]*.tad/evidence/'; then
  emit_deny "bash heredoc into evidence path detected"
fi
if printf '%s' "$lower" | grep -qE 'ln([[:space:]]+-s)?[[:space:]]+.*[[:space:]]+.tad/evidence/'; then
  emit_deny "bash ln into evidence path detected"
fi
if printf '%s' "$lower" | grep -qE 'mv[[:space:]]+.*[[:space:]]+.tad/evidence/(reviews|overrides)/'; then
  emit_deny "bash mv into evidence path detected"
fi
if printf '%s' "$lower" | grep -qE 'cp[[:space:]]+.*[[:space:]]+.tad/evidence/(reviews|overrides)/'; then
  emit_deny "bash cp into evidence path detected"
fi

# Env injection — dangerous variable assignments near evidence operations
# Common offenders from security-auditor P0-5 guidance.
for var in TAD_SKIP_VALIDATION TAD_DISABLE_HOOKS CLAUDE_SETTINGS_PATH BASH_ENV CDPATH; do
  if printf '%s' "$normalized" | grep -qE "(^|[[:space:];&|])$var=" ; then
    emit_deny "env injection detected: $var="
  fi
done

emit_allow
