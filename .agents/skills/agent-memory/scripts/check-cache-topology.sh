#!/usr/bin/env bash
# check-cache-topology.sh — deterministic prompt-cache topology linter (Rule PC1/PC3).
#
# Flags the #1 cache-killer the pack warns about: a dynamic variable
# (timestamp / uuid / now() / per-request id) sitting LEFT of a cache_control
# breakpoint in the cached prefix. Anthropic caching is prefix-based — any byte
# change before a breakpoint invalidates the whole prefix (loses the 0.1x read
# rate). This is a structural check a senior engineer runs in CI; it does not
# "punt to Claude".
#
# Usage:
#   check-cache-topology.sh <file.json|file.py|file.ts ...>
#   cat request.json | check-cache-topology.sh -
# Exit codes: 0 = clean, 1 = topology violation found, 2 = usage error.
#
# Heuristic, not a parser: it locates the LAST cache_control marker and reports
# any dynamic-variable pattern that appears BEFORE it (i.e. in the cached prefix).
set -euo pipefail

DYNAMIC_RE='datetime\.now|Date\.now|time\.time|now\(\)|uuid4|randomUUID|uuid\.uuid|crypto\.randomUUID|request_id|requestId|timestamp'
BREAKPOINT_RE='cache_control'

usage() { echo "usage: $(basename "$0") <file ...|-> " >&2; exit 2; }
[ "$#" -ge 1 ] || usage

scan() {
  # $1 = label, stdin = content
  local label="$1" content line bp_line dyn_line rc=0
  content="$(cat)"
  [ -n "$content" ] || { echo "skip: $label (empty)"; return 0; }

  # Line number of the LAST cache_control breakpoint (the end of the cached prefix).
  bp_line="$(printf '%s\n' "$content" | grep -nE "$BREAKPOINT_RE" | tail -n1 | cut -d: -f1 || true)"

  if [ -z "$bp_line" ]; then
    # No breakpoint at all: only a problem if the file clearly builds a cached prompt.
    if printf '%s\n' "$content" | grep -qiE 'system|messages|tools'; then
      echo "WARN: $label has no cache_control breakpoint — nothing is cached (PC1)."
    fi
    return 0
  fi

  # Any dynamic var BEFORE the last breakpoint = in the cached prefix = violation.
  while IFS=: read -r dyn_line _; do
    [ -n "$dyn_line" ] || continue
    if [ "$dyn_line" -lt "$bp_line" ]; then
      line="$(printf '%s\n' "$content" | sed -n "${dyn_line}p" | sed 's/^[[:space:]]*//')"
      echo "FAIL: $label:$dyn_line — dynamic value LEFT of cache_control (line $bp_line) → full cache miss (PC3): ${line}"
      rc=1
    fi
  done < <(printf '%s\n' "$content" | grep -nE "$DYNAMIC_RE" || true)

  [ "$rc" -eq 0 ] && echo "ok: $label — no dynamic variable in cached prefix"
  return "$rc"
}

status=0
for f in "$@"; do
  if [ "$f" = "-" ]; then
    scan "<stdin>" || status=1
  elif [ -f "$f" ]; then
    scan "$f" < "$f" || status=1
  else
    echo "skip: $f (not a file)" >&2
  fi
done
exit "$status"
